#!/usr/bin/env python3
"""Check that the Coq finite receipt transcribes the observed debugger data.

This is a data-integrity check, not an IDO-to-Clight simulation theorem.
The runner separately authenticates the ROM and requires the exact canonical
receipt and the old Rank-5 regression receipt.
"""

import pathlib
import re
import sys


def require(condition, message):
    if not condition:
        raise SystemExit(message)


def main():
    require(len(sys.argv) == 3, "usage: verify_receipt.py receipt.txt proof.v")
    records = {}
    for line in pathlib.Path(sys.argv[1]).read_text().splitlines():
        kind, *fields = line.split(",")
        pairs = [field.split("=", 1) for field in fields]
        require(all(len(pair) == 2 for pair in pairs), "malformed receipt field")
        row = dict(pairs)
        require(len(row) == len(pairs), "duplicate receipt field")
        records.setdefault(kind, []).append(row)
    source = pathlib.Path(sys.argv[2]).read_text()

    def scalar(name):
        hits = re.findall(r"Definition " + re.escape(name) + r" : Z := (\d+)\.", source)
        require(len(hits) == 1, f"missing or repeated Coq scalar: {name}")
        return int(hits[0])

    def vector(name):
        hits = re.findall(r"Definition " + re.escape(name)
                          + r" : list Z :=\s*\[([\d;\s]+)\]\.", source)
        require(len(hits) == 1, f"missing or repeated Coq vector: {name}")
        return [int(value.strip()) for value in hits[0].split(";")]

    results = records.get("RANK13_RESULT", [])
    require(len(results) == 1, "expected exactly one final result")
    metrics = {name: int(value) for name, value in results[0].items()}
    pairs = re.findall(r"Definition jp_rank13_([A-Za-z][A-Za-z0-9]*) : Z := (\d+)\.", source)
    coq_metrics = {name: int(value) for name, value in pairs}
    require(len(coq_metrics) == len(pairs), "duplicate Coq counter")
    require(metrics == coq_metrics, "Coq metrics do not match the actual result")
    require(metrics["invariant"] == 1, "the observed audit did not pass")

    components = records.get("RANK13_COPY_COMPONENT", [])
    require([int(row["component"]) for row in components] == [0, 1, 2],
            "missing or repeated copy component")
    require([int(row["stores"]) for row in components]
            == vector("jp_ranks13_component_stores"), "copy stores differ")
    require([int(row["readbacks"]) for row in components]
            == vector("jp_ranks13_component_readbacks"), "copy readbacks differ")
    handler_definition = re.findall(
        r"Definition jp_ranks13_handler_counts : list \(Z \* Z \* Z\) :=\s*\[([^]]+)\]\.", source)
    require(len(handler_definition) == 1, "missing handler-count definition")
    handlers = [tuple(int(row[key]) for key in ("index", "calls", "nonzeroReturns"))
                for row in records.get("RANK13_HANDLER", [])]
    coq_handlers = [tuple(map(int, values)) for values in
                    re.findall(r"\((\d+), (\d+), (\d+)\)", handler_definition[0])]
    require(handlers == coq_handlers, "handler counts differ")

    xyz = vector("jp_ranks13_warp_xyz_bits")
    floor = scalar("jp_ranks13_warp_floor")
    height = scalar("jp_ranks13_warp_floor_height")
    owner = scalar("jp_ranks13_warp_floor_owner")
    timers = vector("jp_ranks13_warp_query_timers")
    snapshots = records.get("RANK13_WARP_SNAPSHOT", [])
    require(len(snapshots) == scalar("jp_ranks13_snapshot_count"), "snapshot count differs")
    common_stages = ["post-inputs", "post-interactions", "disappeared-entry",
                     "disappeared-return-zero", "copy-entry", "copy-return"]
    first_stages = ["post-inputs", "accept-nonfading", "warp-return-one"] + common_stages[1:]
    expected_stages = [(timer, stage) for index, timer in enumerate(timers)
                       for stage in (first_stages if index == 0 else common_stages)]
    require([(int(row["timer"]), row["kind"]) for row in snapshots] == expected_stages,
            "warp stage chronology differs")
    for row in snapshots:
        require(all([int(word, 16) for word in row[key].split(":")] == xyz
                    for key in ("state", "object")), "a warp position differs")
        require([int(row[key], 16) for key in ("floor", "floorHeight", "owner")]
                == [floor, height, owner], "a cached floor/height/owner differs")
        pre_accept = int(row["timer"]) == timers[0] and row["kind"] in first_stages[:2]
        require(int(row["action"], 16) == (0x0C000232 if pre_accept else 0x1300),
                "unexpected warp action")
        require(int(row["used"], 16) == (0x80343578 if pre_accept else 0x80345918),
                "unexpected used-object identity")
    queries = records.get("RANK13_FINAL_QUERY", [])
    require([int(row["timer"]) for row in queries] == timers, "final-query timers differ")
    for row in queries:
        require(int(row["floor"], 16) == floor, "final query selected another floor")
        require([int(word, 16) for word in row["object"].split(":")] == xyz,
                "final query used another Object position")
    print("Coq receipt matches every counter, copy component, handler, warp snapshot, and final query.")


if __name__ == "__main__":
    main()
