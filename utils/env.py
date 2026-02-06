"""Shared environment-variable parsing helpers for yul2venom."""

from __future__ import annotations

import os
from typing import Optional

TRUE_VALUES = {"1", "true", "yes", "on"}
FALSE_VALUES = {"0", "false", "no", "off"}


def _normalize(value: str) -> str:
    return value.strip().lower()


def env_str(name: str, default: Optional[str] = None) -> Optional[str]:
    value = os.getenv(name)
    return value if value is not None else default


def env_bool(name: str, default: bool = False) -> bool:
    value = os.getenv(name)
    if value is None:
        return default
    lowered = _normalize(value)
    if lowered in TRUE_VALUES:
        return True
    if lowered in FALSE_VALUES:
        return False
    return default


def env_bool_opt(name: str) -> Optional[bool]:
    value = os.getenv(name)
    if value is None:
        return None
    lowered = _normalize(value)
    if lowered in TRUE_VALUES:
        return True
    if lowered in FALSE_VALUES:
        return False
    return None


def env_int_opt(name: str) -> Optional[int]:
    value = os.getenv(name)
    if value is None:
        return None
    try:
        return int(value.strip())
    except (TypeError, ValueError):
        return None
