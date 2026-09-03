#!/usr/bin/env python3
"""Check observed fixture receipts; never infer a clean entry or Clight trace.

Input: one or more trace.txt paths emitted by run.sh. --receipt prints a
compact JSON record for review; --self-test also rejects altered evidence.
Only reads files. No ROM bytes or emulator memory are changed by this tool.
"""

import argparse
import copy
import hashlib
import json
import math
from pathlib import Path
import re
import struct


def require(condition, message):
    if not condition:
        raise ValueError(message)


def parse_trace(text):
    records = []
    for line in text.splitlines():
        if not line.startswith(("H11_", "R11_FIXTURE_WRITE,", "R11_STAGE,")):
            continue
        tag, *fields = re.split(r",(?=[A-Za-z_][A-Za-z_0-9]*=)", line)
        record = {"tag": tag}
        for field in fields:
            key, value = field.split("=", 1)
            require(key not in record, f"duplicate field {key}")
            record[key] = value
        records.append(record)
    return records


def vector(record, name="pos"):
    value = record[name]
    require(value.startswith("(") and value.endswith(")"), f"bad {name}")
    coordinates = tuple(float(part) for part in value[1:-1].split(","))
    require(len(coordinates) == 3 and all(map(math.isfinite, coordinates)),
            f"non-finite or malformed {name}")
    return coordinates


def bits(value):
    return struct.unpack(">I", struct.pack(">f", value))[0]


def in_south_target(position):
    x, y, z = position
    return -101 <= x <= 102 and 3942 <= y <= 6144 and 922 <= z <= 1229


def validate(records):
    def all_of(tag):
        return [record for record in records if record["tag"] == tag]

    def one(tag):
        found = all_of(tag)
        require(len(found) == 1, f"expected one {tag}, got {len(found)}")
        return found[0]

    stage = one("R11_STAGE")
    before = one("H11_BEFORE_GOOMBA")
    placed = one("H11_PLACED")
    result = one("H11_RESULT")
    knockback = one("H11_FIRST_KNOCKBACK")
    target = one("H11_TARGET")
    mode = int(placed["mode"])
    require(mode in (0, 1, 2) and int(result["mode"]) == mode, "mode mismatch")
    expected_y = (4194.0, 4020.0, 4070.0)[mode]
    expected_action = (0x00100345, 0x08100340, 0x00100344)[mode]
    require(int(placed["marioAction"], 16) == expected_action, "wrong pole action")
    require(float(placed["y"]) == expected_y, "wrong contact height")
    require(float(placed["vy"]) == float(placed["forwardVel"]) == 0,
            "contact must have no preloaded velocity")
    require(int(result["placed"]) == int(result["sawKnockback"]) == 1,
            "fixture or damage never executed")
    require(float(result["contactY"]) == float(result["firstY"]) == expected_y,
            "summary lost height")
    require(int(result["crossed"]) == 1, "no observed target crossing")
    for field in ("aPressedFrames", "aDownFrames", "controllerAFrames"):
        require(int(result[field]) == 0, f"nonzero {field}")

    # The 23 inherited pole writes are distinct from the earlier Area-2 loader.
    mario = int(stage["mario"], 16)
    pole = int(stage["pole"], 16)
    state = 0x80339E00
    expected_pole_writes = {
        state + 0x0C: 0x08100340, state + 0x10: 0x08100340,
        state + 0x18: 0, state + 0x1C: 0, state + 0x2C: 0,
        state + 0x48: 0, state + 0x4C: 0, state + 0x50: 0,
        state + 0x54: 0, state + 0x78: pole, state + 0x80: pole,
        mario + 0x10C: 0, mario + 0x110: bits(820.0), 0x8032FED4: 0,
    }
    for index, value in enumerate((0.0, 4020.0, 1331.0)):
        expected_pole_writes[state + 0x3C + 4 * index] = bits(value)
        expected_pole_writes[mario + 0xA0 + 4 * index] = bits(value)
        expected_pole_writes[mario + 0x20 + 4 * index] = bits(value)
    pole_writes = all_of("R11_FIXTURE_WRITE")
    require(len(pole_writes) == int(stage["fixtureWrites"]) == 23,
            "wrong inherited pole-write count")
    actual_pole_writes = {int(r["address"], 16): int(r["value"], 16)
                          for r in pole_writes}
    require(actual_pole_writes == expected_pole_writes, "changed pole fixture")

    goomba = int(before["object"], 16)
    require(goomba == int(placed["object"], 16), "changed Goomba identity")
    require(int(before["behavior"], 16) == 0x800ECA2C,
            "not the observed stock Goomba behavior")
    require(vector(before, "home") == (3263.0, 640.0, 3157.0), "changed home")
    require(int(before["intangible"]) == 0 and int(before["flags"], 16) != 0,
            "Goomba is inactive or intangible")
    extra = all_of("H11_FIXTURE_WRITE")
    require(len(extra) == int(placed["extraWrites"]) == int(result["extraWrites"]) == 3,
            "expected exactly three extra coordinate writes")
    expected_extra = [(goomba + 0xA0, bits(0.0)),
                      (goomba + 0xA4, bits(expected_y)),
                      (goomba + 0xA8, bits(1371.0))]
    require([(int(r["address"], 16), int(r["value"], 16)) for r in extra]
            == expected_extra, "extra writes are not exactly Goomba XYZ")
    require(records.index(extra[-1]) < records.index(placed),
            "write after declared placement")

    inputs = all_of("H11_INPUT")
    frames = all_of("H11_FRAME")
    require(inputs and len(frames) >= 50, "incomplete input/frame receipt")
    for series in (inputs, frames):
        timers = [int(r["timer"]) for r in series]
        require(all(b == a + 1 for a, b in zip(timers, timers[1:])),
                "not a consecutive distinct-timer sequence")
    placement_timer = int(placed["timer"])
    require(int(inputs[0]["timer"]) == int(stage["timer"]), "missing initial input")
    require(int(frames[0]["timer"]) == placement_timer, "missing contact sample")
    require(vector(frames[0]) == (0.0, expected_y, 1331.0), "wrong contact XYZ")
    for record in inputs:
        require(int(record["A"]) == 0, "controller A supplied")
        if int(record["timer"]) >= placement_timer:
            require(all(int(record[field]) == 0 for field in ("X", "Y", "A", "B", "Z")),
                    "post-placement controller was not neutral")
    contact_input = next(r for r in inputs if int(r["timer"]) == placement_timer)
    if mode == 2:
        require(contact_input["anim"] == "12" and contact_input["frame"] == "0",
                "not the last reverse-animation frame")
        require(contact_input["Z"] == "0", "inherited Z was not suppressed")
    for frame in frames:
        xyz = vector(frame)
        observed_bits = tuple(int(word) for word in frame["bits"][1:-1].split(","))
        require(tuple(map(bits, xyz)) == observed_bits, "decimal/Float32 mismatch")
        require(all(int(frame[field]) == 0 for field in ("A", "B", "Z")),
                "post-placement button supplied")
    require(knockback["action"] == "010208b0", "not ordinary backward air knockback")
    require(int(knockback["timer"]) == placement_timer + 1, "delayed damage")
    require(vector(knockback) == (0.0, expected_y, 1315.0), "wrong first knockback XYZ")
    require(float(knockback["vy"]) == -4 and float(knockback["forwardVel"]) == -16,
            "unexpected knockback speed")
    first_air = next(r for r in frames if r["action"] == "010208b0")
    require(vector(first_air) == vector(knockback) and
            first_air["timer"] == knockback["timer"], "knockback marker mismatch")
    crossing = next((r for r in frames if in_south_target(vector(r))), None)
    require(crossing is not None and vector(crossing) == vector(target) and
            crossing["timer"] == target["timer"], "target marker mismatch")
    require(crossing["floor"] == "801a1000" and float(crossing["floorHeight"]) == 3942,
            "unexpected target-floor observation")
    landing = next((r for r in frames if r["action"] == "00020462" and
                    vector(r)[1] == 3942 and in_south_target(vector(r))), None)
    require(landing is not None, "no observed landing on the ring")
    settled = next((r for r in frames if r["action"] == "0c400201" and
                    vector(r)[1] == 3942 and in_south_target(vector(r))), None)
    require(settled is not None, "no observed idle recovery on target side")
    return {
        "mode": mode, "stage": stage, "pole_fixture_writes": pole_writes,
        "before_goomba": before, "extra_goomba_writes": extra,
        "placed": placed, "contact_input": contact_input,
        "first_knockback": first_air, "first_target": crossing,
        "first_landing": landing, "first_idle": settled,
        "frames_through_landing": frames[:frames.index(landing) + 1],
        "input_samples": len(inputs), "position_samples": len(frames),
        "result": result,
    }


def negative_tests(records):
    def alter(tag, field, value):
        bad = copy.deepcopy(records)
        next(r for r in bad if r["tag"] == tag)[field] = value
        return bad

    bad_cases = [
        alter("H11_RESULT", "aPressedFrames", "1"),
        alter("H11_FIXTURE_WRITE", "address", "80339e40"),
        alter("H11_FIRST_KNOCKBACK", "pos", "(0,4021,1315)"),
        alter("H11_TARGET", "pos", "(0,4110,1331)"),
        alter("H11_BEFORE_GOOMBA", "behavior", "00000000"),
        alter("H11_FRAME", "bits", "(0,0,0)"),
        alter("H11_INPUT", "A", "1"),
    ]
    for bad in bad_cases:
        try:
            validate(bad)
        except ValueError:
            continue
        raise ValueError("negative test accepted altered evidence")
    return len(bad_cases)


def sha256_lf(path):
    return hashlib.sha256(path.read_bytes().replace(b"\r\n", b"\n")).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("traces", nargs="+", type=Path)
    parser.add_argument("--receipt", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    runs = []
    for path in args.traces:
        records = parse_trace(path.read_text(encoding="utf-8"))
        run = validate(records)
        run["trace_sha256_lf"] = sha256_lf(path)
        if args.self_test:
            run["rejected_altered_receipts"] = negative_tests(records)
        runs.append(run)
    require(len({run["mode"] for run in runs}) == len(runs), "duplicate run modes")
    if args.receipt:
        folder = Path(__file__).resolve().parent
        print(json.dumps({
            "scope": "Fixture-assisted JP suffix only; NOT clean entry, quarter-step trace, "
                     "star collection, or IDO-to-Clight bridge.",
            "rom_md5": "85d61f5525af708c9f1e84dce6dc10e9",
            "rom_sha256": "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317",
            "probe_sha256_lf": sha256_lf(folder / "jp_rank11_handstand_damage_probe.c"),
            "input_phase": "H11_INPUT is after wrapper overrides, for the next update; "
                           "H11_FRAME reads memory at that poll.",
            "runs": sorted(runs, key=lambda run: run["mode"]),
        }, indent=2))
    else:
        for run in runs:
            print(f"Validated mode {run['mode']}: height retained, target crossed, "
                  f"ring landed, idle recovered, 23+3 fixture writes, zero A; "
                  f"{run.get('rejected_altered_receipts', 0)} negative tests.")


if __name__ == "__main__":
    main()
