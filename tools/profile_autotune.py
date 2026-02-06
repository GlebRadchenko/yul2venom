#!/usr/bin/env python3
"""
Generic yul2venom profile auto-tuner.

It searches a knob space and evaluates candidates with:
  score = alpha * deploy_bytes + beta * runtime_gas

Inputs are workload-driven via --targets-file (JSON), so this script contains
no project-specific assumptions.
"""

from __future__ import annotations

import argparse
import dataclasses
import itertools
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Iterable, Optional


DJMP_RE = re.compile(r"(?m)^(\s*djmp_threshold:\s*)\d+(\s*)$")
DEFAULT_GAS_REGEX = r"\(gas:\s*(\d+)\)"


@dataclasses.dataclass
class Target:
    name: str
    config: Path
    output: Path
    runtime_output: Path
    transpile_args: list[str]

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "config": str(self.config),
            "output": str(self.output),
            "runtime_output": str(self.runtime_output),
            "transpile_args": list(self.transpile_args),
        }

    @classmethod
    def from_dict(cls, data: dict, cwd: Path, default_transpile_args: list[str]) -> "Target":
        name = str(data.get("name") or "")
        config = Path(data.get("config", "")).expanduser()
        output = Path(data.get("output", "")).expanduser()
        if not name or not str(config) or not str(output):
            raise ValueError("each target must define non-empty name/config/output")

        config = config if config.is_absolute() else (cwd / config)
        output = output if output.is_absolute() else (cwd / output)

        runtime_raw = data.get("runtime_output")
        if runtime_raw:
            runtime_output = Path(runtime_raw).expanduser()
            runtime_output = runtime_output if runtime_output.is_absolute() else (cwd / runtime_output)
        else:
            s = str(output)
            runtime_output = Path(f"{s[:-4]}_runtime.bin") if s.endswith(".bin") else Path(f"{s}_runtime.bin")

        ta = data.get("transpile_args")
        if ta is None:
            transpile_args = list(default_transpile_args)
        elif isinstance(ta, list):
            transpile_args = [str(x) for x in ta]
        else:
            raise ValueError("target.transpile_args must be a list when provided")

        return cls(
            name=name,
            config=config,
            output=output,
            runtime_output=runtime_output,
            transpile_args=transpile_args,
        )


@dataclasses.dataclass
class Candidate:
    stmt_threshold: int
    djmp_threshold: int
    load_elimination: bool

    def short(self) -> str:
        load = "on" if self.load_elimination else "off"
        return f"stmt={self.stmt_threshold},djmp={self.djmp_threshold},load_elim={load}"


@dataclasses.dataclass
class CandidateResult:
    candidate: Candidate
    deploy_total_bytes: int
    runtime_total_bytes: int
    test_gas: int
    execution_gas: int | None
    per_target: dict[str, dict[str, int]]
    score: float

    def to_dict(self) -> dict:
        return {
            "candidate": dataclasses.asdict(self.candidate),
            "deploy_total_bytes": self.deploy_total_bytes,
            "runtime_total_bytes": self.runtime_total_bytes,
            "test_gas": self.test_gas,
            "execution_gas": self.execution_gas,
            "per_target": self.per_target,
            "score": self.score,
        }


def _parse_csv_ints(raw: str) -> list[int]:
    vals = [int(tok.strip()) for tok in raw.split(",") if tok.strip()]
    if not vals:
        raise ValueError(f"empty integer list: {raw!r}")
    return vals


def _parse_csv_bools(raw: str) -> list[bool]:
    out: list[bool] = []
    for tok in raw.split(","):
        t = tok.strip().lower()
        if not t:
            continue
        if t in ("1", "true", "yes", "on"):
            out.append(True)
        elif t in ("0", "false", "no", "off"):
            out.append(False)
        else:
            raise ValueError(f"invalid bool token: {tok!r}")
    if not out:
        raise ValueError(f"empty bool list: {raw!r}")
    return out


def _run(cmd: list[str], cwd: Path, env: dict[str, str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=cwd, env=env, text=True, capture_output=True)


def _patch_djmp_threshold(base_cfg: Path, djmp_threshold: int, temp_dir: Path) -> Path:
    src = base_cfg.read_text()
    out_text, n = DJMP_RE.subn(lambda m: f"{m.group(1)}{djmp_threshold}{m.group(2)}", src, count=1)
    if n != 1:
        raise RuntimeError("failed to patch djmp_threshold in transpiler config")
    out = temp_dir / f"profile_autotune_djmp_{djmp_threshold}.yaml"
    out.write_text(out_text)
    return out


def _parse_first_int(regex: re.Pattern[str], text: str) -> Optional[int]:
    m = regex.search(text)
    if m is None:
        return None
    return int(m.group(1))


def _load_targets(targets_file: Path, cwd: Path, default_transpile_args: list[str]) -> list[Target]:
    raw = json.loads(targets_file.read_text())
    if not isinstance(raw, list):
        raise ValueError("targets file must contain a JSON array")
    targets = [Target.from_dict(item, cwd, default_transpile_args) for item in raw]
    if not targets:
        raise ValueError("targets file must contain at least one target")
    return targets


def _transpile_targets(
    *,
    transpiler: Path,
    transpiler_cfg: Path,
    cwd: Path,
    targets: list[Target],
    env: dict[str, str],
) -> tuple[int, int, dict[str, dict[str, int]]]:
    deploy_total = 0
    runtime_total = 0
    per_target: dict[str, dict[str, int]] = {}

    for t in targets:
        cmd = [
            "python3.11",
            str(transpiler),
            "transpile",
            str(t.config),
            "--transpiler-config",
            str(transpiler_cfg),
            *t.transpile_args,
            "-o",
            str(t.output),
        ]
        proc = _run(cmd, cwd, env)
        if proc.returncode != 0:
            raise RuntimeError(
                f"transpile failed for target={t.name}:\n"
                f"CMD: {' '.join(cmd)}\nSTDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}"
            )

        if not t.output.exists():
            raise RuntimeError(f"missing output for target={t.name}: {t.output}")
        if not t.runtime_output.exists():
            raise RuntimeError(
                f"missing runtime output for target={t.name}: {t.runtime_output} "
                "(set runtime_output explicitly in targets file if naming differs)"
            )

        deploy_bytes = t.output.stat().st_size
        runtime_bytes = t.runtime_output.stat().st_size
        deploy_total += deploy_bytes
        runtime_total += runtime_bytes
        per_target[t.name] = {
            "deploy_bytes": deploy_bytes,
            "runtime_bytes": runtime_bytes,
        }

    return deploy_total, runtime_total, per_target


def _evaluate_candidate(
    *,
    candidate: Candidate,
    transpiler: Path,
    patched_cfg: Path,
    cwd: Path,
    targets: list[Target],
    base_env: dict[str, str],
    alpha: float,
    beta: float,
    always_inline: int,
    call_threshold: int,
    test_cmd: list[str] | None,
    test_gas_re: re.Pattern[str] | None,
    execution_gas_re: re.Pattern[str] | None,
) -> CandidateResult:
    env = dict(base_env)
    env["Y2V_INLINE_STMT_THRESHOLD"] = str(candidate.stmt_threshold)
    env["Y2V_INLINE_ALWAYS_MAX"] = str(always_inline)
    env["Y2V_INLINE_CALL_THRESHOLD"] = str(call_threshold)
    env["Y2V_NATIVE_DISABLE_LOAD_ELIMINATION"] = "0" if candidate.load_elimination else "1"

    deploy_total, runtime_total, per_target = _transpile_targets(
        transpiler=transpiler,
        transpiler_cfg=patched_cfg,
        cwd=cwd,
        targets=targets,
        env=env,
    )

    test_gas = 0
    execution_gas: int | None = None

    if test_cmd:
        proc = _run(test_cmd, cwd, env)
        if proc.returncode != 0:
            raise RuntimeError(
                f"test command failed for {candidate.short()}:\n"
                f"CMD: {' '.join(test_cmd)}\nSTDOUT:\n{proc.stdout}\nSTDERR:\n{proc.stderr}"
            )
        merged = proc.stdout + "\n" + proc.stderr
        if test_gas_re is None:
            raise RuntimeError("test command provided without test gas regex")
        parsed_test_gas = _parse_first_int(test_gas_re, merged)
        if parsed_test_gas is None:
            raise RuntimeError("could not parse test gas from test output")
        test_gas = parsed_test_gas
        if execution_gas_re is not None:
            execution_gas = _parse_first_int(execution_gas_re, merged)

    score = alpha * deploy_total + beta * test_gas

    return CandidateResult(
        candidate=candidate,
        deploy_total_bytes=deploy_total,
        runtime_total_bytes=runtime_total,
        test_gas=test_gas,
        execution_gas=execution_gas,
        per_target=per_target,
        score=score,
    )


def _iter_candidates(
    stmt_values: Iterable[int],
    djmp_values: Iterable[int],
    load_elim_values: Iterable[bool],
) -> Iterable[Candidate]:
    for stmt, djmp, load_elim in itertools.product(stmt_values, djmp_values, load_elim_values):
        yield Candidate(stmt_threshold=stmt, djmp_threshold=djmp, load_elimination=load_elim)


def main() -> int:
    parser = argparse.ArgumentParser(description="Auto-tune yul2venom profile knobs.")
    parser.add_argument("--cwd", type=Path, default=Path.cwd(), help="working directory for transpile/test")
    parser.add_argument(
        "--transpiler",
        type=Path,
        default=(Path(__file__).resolve().parents[1] / "yul2venom.py"),
        help="path to yul2venom.py",
    )
    parser.add_argument(
        "--transpiler-config",
        type=Path,
        default=(Path(__file__).resolve().parents[1] / "yul2venom.config.yaml"),
        help="base transpiler config path (djmp_threshold is patched per candidate)",
    )
    parser.add_argument(
        "--targets-file",
        type=Path,
        required=True,
        help="JSON array of targets: [{name, config, output, runtime_output?, transpile_args?}]",
    )
    parser.add_argument(
        "--default-transpile-args",
        default="--with-init",
        help="default extra args passed to transpile for targets without transpile_args",
    )
    parser.add_argument("--test-cmd", default=None, help="optional command run after transpile")
    parser.add_argument(
        "--test-gas-regex",
        default=DEFAULT_GAS_REGEX,
        help="regex with one capture group for test gas (used when --test-cmd is set)",
    )
    parser.add_argument(
        "--trade-gas-regex",
        default=None,
        help="optional regex with one capture group for secondary gas metric",
    )
    parser.add_argument("--stmt-values", default="4,5,6")
    parser.add_argument("--djmp-values", default="4,5,6")
    parser.add_argument("--load-elim-values", default="true,false")
    parser.add_argument("--always-inline", type=int, default=3)
    parser.add_argument("--call-threshold", type=int, default=0)
    parser.add_argument("--alpha", type=float, default=1.0, help="weight for deploy bytes")
    parser.add_argument("--beta", type=float, default=1.0, help="weight for test gas")
    parser.add_argument("--top-k", type=int, default=5)
    parser.add_argument("--json-out", type=Path, default=None)
    args = parser.parse_args()

    cwd = args.cwd.expanduser().resolve()
    transpiler = args.transpiler.expanduser().resolve()
    transpiler_cfg = args.transpiler_config.expanduser().resolve()
    targets_file = args.targets_file.expanduser().resolve()

    stmt_values = _parse_csv_ints(args.stmt_values)
    djmp_values = _parse_csv_ints(args.djmp_values)
    load_elim_values = _parse_csv_bools(args.load_elim_values)
    default_transpile_args = shlex.split(args.default_transpile_args)

    targets = _load_targets(targets_file, cwd, default_transpile_args)

    test_cmd = shlex.split(args.test_cmd) if args.test_cmd else None
    test_gas_re = re.compile(args.test_gas_regex) if args.test_cmd else None
    execution_gas_re = re.compile(args.execution_gas_regex) if args.execution_gas_regex else None

    if args.beta != 0 and test_cmd is None:
        print("WARNING: beta is non-zero but no --test-cmd provided; gas term will be 0", file=sys.stderr)

    base_env = dict(os.environ)
    results: list[CandidateResult] = []
    errors: list[dict[str, str]] = []

    with tempfile.TemporaryDirectory(prefix="y2v_profile_autotune_") as td:
        temp_root = Path(td)
        candidates = list(_iter_candidates(stmt_values, djmp_values, load_elim_values))
        total = len(candidates)
        for idx, candidate in enumerate(candidates, start=1):
            print(f"[{idx}/{total}] {candidate.short()}", flush=True)
            try:
                patched_cfg = _patch_djmp_threshold(transpiler_cfg, candidate.djmp_threshold, temp_root)
                result = _evaluate_candidate(
                    candidate=candidate,
                    transpiler=transpiler,
                    patched_cfg=patched_cfg,
                    cwd=cwd,
                    targets=targets,
                    base_env=base_env,
                    alpha=args.alpha,
                    beta=args.beta,
                    always_inline=args.always_inline,
                    call_threshold=args.call_threshold,
                    test_cmd=test_cmd,
                    test_gas_re=test_gas_re,
                    execution_gas_re=execution_gas_re,
                )
                results.append(result)
                print(
                    "  ok "
                    f"deploy={result.deploy_total_bytes} runtime={result.runtime_total_bytes} "
                    f"test_gas={result.test_gas} score={result.score:.2f}",
                    flush=True,
                )
            except Exception as exc:
                msg = str(exc)
                errors.append({"candidate": candidate.short(), "error": msg})
                print(f"  fail {msg}", flush=True)

    if not results:
        payload = {"results": [], "errors": errors}
        if args.json_out:
            args.json_out.write_text(json.dumps(payload, indent=2))
        print("No successful candidates.", file=sys.stderr)
        return 1

    results.sort(key=lambda r: r.score)
    best = results[0]

    print("\nTop candidates:")
    for i, item in enumerate(results[: args.top_k], start=1):
        print(
            f"{i}. {item.candidate.short()} | deploy={item.deploy_total_bytes} "
            f"runtime={item.runtime_total_bytes} test_gas={item.test_gas} "
            f"execution_gas={item.execution_gas} score={item.score:.2f}"
        )

    print("\nBest candidate:")
    print(
        f"{best.candidate.short()} | deploy={best.deploy_total_bytes} "
        f"runtime={best.runtime_total_bytes} test_gas={best.test_gas} "
        f"execution_gas={best.execution_gas} score={best.score:.2f}"
    )

    if args.json_out:
        payload = {
            "objective": {
                "alpha": args.alpha,
                "beta": args.beta,
                "formula": "alpha * deploy_bytes + beta * runtime_gas",
            },
            "targets": [t.to_dict() for t in targets],
            "results": [r.to_dict() for r in results],
            "errors": errors,
        }
        args.json_out.write_text(json.dumps(payload, indent=2))
        print(f"\nWrote JSON results to {args.json_out}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
