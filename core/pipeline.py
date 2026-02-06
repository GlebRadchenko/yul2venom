"""Programmatic wrapper around the Yul2Venom CLI transpile command."""

from __future__ import annotations

import subprocess
import sys
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import List, Optional


PROJECT_ROOT = Path(__file__).resolve().parent.parent
CLI_PATH = PROJECT_ROOT / "yul2venom.py"


class YulOptLevel(str, Enum):
    SAFE = "safe"
    STANDARD = "standard"
    AGGRESSIVE = "aggressive"
    MAXIMUM = "maximum"


@dataclass
class TranspilationConfig:
    config_path: str
    yul_path: Optional[str] = None
    output_path: Optional[str] = None
    optimize: Optional[str] = None
    yul_opt: bool = False
    yul_opt_level: Optional[YulOptLevel] = None
    strip_checks: bool = False
    runtime_only: bool = False
    with_init: bool = False
    dump_ir: bool = False
    vnm_out: Optional[str] = None
    transpiler_config: Optional[str] = None
    python_executable: str = sys.executable

    def to_command(self) -> List[str]:
        cmd = [self.python_executable, str(CLI_PATH), "transpile", self.config_path]
        if self.yul_path:
            cmd.extend(["--yul", self.yul_path])
        if self.output_path:
            cmd.extend(["--output", self.output_path])
        if self.optimize:
            cmd.extend(["--optimize", self.optimize])
        if self.yul_opt:
            cmd.append("--yul-opt")
        if self.yul_opt_level:
            cmd.extend(["--yul-opt-level", self.yul_opt_level.value])
        if self.strip_checks:
            cmd.append("--strip-checks")
        if self.runtime_only:
            cmd.append("--runtime-only")
        if self.with_init:
            cmd.append("--with-init")
        if self.dump_ir:
            cmd.append("--dump-ir")
        if self.vnm_out:
            cmd.extend(["--vnm-out", self.vnm_out])
        if self.transpiler_config:
            cmd.extend(["--transpiler-config", self.transpiler_config])
        return cmd


@dataclass
class TranspilationResult:
    success: bool
    exit_code: int
    stdout: str
    stderr: str
    command: List[str]
    output_path: Optional[str] = None


class TranspilationPipeline:
    def __init__(self, config: TranspilationConfig):
        self.config = config

    def _run_command(self, cmd: List[str]) -> subprocess.CompletedProcess:
        return subprocess.run(
            cmd,
            cwd=str(PROJECT_ROOT),
            text=True,
            capture_output=True,
        )

    def run(self) -> TranspilationResult:
        cmd = self.config.to_command()
        proc = self._run_command(cmd)
        return TranspilationResult(
            success=proc.returncode == 0,
            exit_code=proc.returncode,
            stdout=proc.stdout,
            stderr=proc.stderr,
            command=cmd,
            output_path=self.config.output_path,
        )


def transpile(config: TranspilationConfig | str, **kwargs) -> TranspilationResult:
    if isinstance(config, str):
        cfg = TranspilationConfig(config_path=config, **kwargs)
    else:
        if kwargs:
            raise ValueError("kwargs are only allowed when config is a path string")
        cfg = config
    return TranspilationPipeline(cfg).run()
