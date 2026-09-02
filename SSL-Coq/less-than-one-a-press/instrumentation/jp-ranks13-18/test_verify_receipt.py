#!/usr/bin/env python3
"""Fail-closed transcription-check tests; no emulator or ROM is required."""

import contextlib
import io
import pathlib
import sys
import unittest
from unittest import mock

import verify_receipt

HERE = pathlib.Path(__file__).resolve().parent
RECEIPT = (HERE / "expected-copy-interaction-receipt.txt").read_text()
PROOF = (HERE.parent.parent / "proofs/Area1Ranks13To18TraceReceipt.v").read_text()


class ReceiptTests(unittest.TestCase):
    def run_check(self, receipt=RECEIPT, proof=PROOF):
        with mock.patch.object(sys, "argv", ["verify_receipt.py", "receipt", "proof"]):
            with mock.patch.object(pathlib.Path, "read_text", side_effect=[receipt, proof]):
                with contextlib.redirect_stdout(io.StringIO()):
                    verify_receipt.main()

    def test_checked_receipt_matches(self):
        self.run_check()

    def test_changed_counter_is_rejected(self):
        with self.assertRaises(SystemExit):
            self.run_check(RECEIPT.replace("handlerCalls=65", "handlerCalls=66"))

    def test_added_metric_is_rejected(self):
        with self.assertRaises(SystemExit):
            self.run_check(RECEIPT.replace("invariant=1", "invariant=1,unclassified=1"))

    def test_duplicate_metric_is_rejected(self):
        with self.assertRaises(SystemExit):
            self.run_check(RECEIPT.replace("invariant=1", "invariant=1,invariant=1"))

    def test_copy_readback_change_is_rejected(self):
        with self.assertRaises(SystemExit):
            self.run_check(RECEIPT.replace("readbacks=2462", "readbacks=2461", 1))

    def test_transient_warp_position_change_is_rejected(self):
        with self.assertRaises(SystemExit):
            self.run_check(RECEIPT.replace("state=c4fe3c24", "state=c4fe3c25", 1))

    def test_changed_floor_owner_is_rejected(self):
        with self.assertRaises(SystemExit):
            self.run_check(RECEIPT.replace("owner=00000000", "owner=80345918", 1))

    def test_changed_final_floor_is_rejected(self):
        with self.assertRaises(SystemExit):
            self.run_check(RECEIPT.replace(
                "RANK13_FINAL_QUERY,timer=2807,floor=80195db0",
                "RANK13_FINAL_QUERY,timer=2807,floor=80195de0"))

    def test_missing_snapshot_is_rejected(self):
        lines = RECEIPT.splitlines()
        first = next(i for i, line in enumerate(lines) if line.startswith("RANK13_WARP_SNAPSHOT"))
        with self.assertRaises(SystemExit):
            self.run_check("\n".join(lines[:first] + lines[first + 1:]))

    def test_changed_coq_counter_is_rejected(self):
        with self.assertRaises(SystemExit):
            self.run_check(proof=PROOF.replace(
                "Definition jp_rank13_frames : Z := 2462.",
                "Definition jp_rank13_frames : Z := 2463."))


if __name__ == "__main__":
    unittest.main()
