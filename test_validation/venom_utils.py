"""
Utility helpers for asserting properties about Venom IR contexts in tests.
"""

from __future__ import annotations


def assert_ctx_eq(expected_ctx, actual_ctx) -> None:
    """
    Assert that two Venom IR contexts are equal.

    The contexts expose a stable string representation, so we delegate to that
    for comparison while providing a readable diff-friendly message when they
    differ.
    """
    expected_str = str(expected_ctx)
    actual_str = str(actual_ctx)

    if expected_str != actual_str:
        diff_message = [
            "Venom IR contexts differ:",
            "--- expected ---",
            expected_str,
            "--- actual ---",
            actual_str,
        ]
        raise AssertionError("\n".join(diff_message))
