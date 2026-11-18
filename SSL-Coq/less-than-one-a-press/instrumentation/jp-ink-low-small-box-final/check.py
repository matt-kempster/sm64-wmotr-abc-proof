"""Compare both shoves, terrain, warp and destination against the selected Wafel case."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent
library_path = HERE.parent / "jp-ink-shell-three-releases/compare.py"
spec = importlib.util.spec_from_file_location("jp_trace", library_path)
trace = importlib.util.module_from_spec(spec)
spec.loader.exec_module(trace)
ROM_SHA256 = "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
USEFUL = [365.5927734375, 5500.0, -1096.8026123046875]
ORDINARY = [0.0, 5500.0, 256.0]


def vector(s):
    return list(map(trace.bits, trace.xyz(s)))


def check(recipe, payload):
    case = json.loads(recipe.read_bytes())
    assert case["name"] in {"positive", "control", "swapped-bobs"}
    swapped = case["name"] == "swapped-bobs"
    first_slot, last_slot = (40, 39) if swapped else (39, 23)
    lines = payload.decode(errors="replace").splitlines()
    def records(tag):
        return [trace.fields(line) for line in lines if line.startswith(tag + ",")]

    assert not any(line.startswith("SC_ERROR") for line in lines)
    states = {int(s["bridge"]): s for s in records("SC_STATE") if int(s["bridge"]) > 0}
    actors = {slot: {int(s["bridge"]): s for s in records(tag)}
              for slot, tag in [(last_slot, "SB_BOX"), (first_slot, "EB_BOB")]}
    expected = case["expected"]
    missing = sorted(set(range(1, len(expected) + 1)) - set(states))
    assert missing == [27, 28], missing  # No camera callback across the warp transition.
    comparisons = 0
    for i, row in enumerate(expected, 1):
        if i in missing:
            continue
        actual = states[i]
        pairs = [(int(actual[k]), row[k]) for k in
                 ["area", "topTimer", "topAction", "actionState", "actionTimer", "input"]]
        pairs.append((int(actual["action"], 16), row["action"]))
        pairs.extend((trace.slot(actual[k]), row[k]) for k in
                     ["held", "used", "ridden", "platform", "floorOwner"])
        pairs.extend((vector(actual[k]), list(map(trace.bits, row[k]))) for k in ["M", "C", "G"])
        pairs.append((trace.bits(float(actual["floorY"])), trace.bits(row["floorY"])))
        contacts = actual["collided"].strip("()").split(",")[:int(actual["collidedCount"])]
        pairs.append((list(map(trace.slot, contacts)), row["collisions"]))
        # Compare the native shell state and the two live pusher profiles.
        for a, b in [("shellActive", "activeFlags"), ("shellIntangible", "oIntangibleTimer"),
                     ("shellType", "oInteractType"), ("shellStatus", "oInteractStatus"),
                     ("shellHeld", "oHeldState")]:
            pairs.append((int(actual[a]), row["shell"][b]))
        for slot in actors:
            native = actors[slot][i]
            sample = row["actors"][str(slot)]
            for a, b in [("type", "oInteractType"), ("active", "activeFlags"), ("held", "oHeldState"),
                         ("status", "oInteractStatus"), ("intangible", "oIntangibleTimer"),
                         ("action", "oAction")]:
                pairs.append((int(native[a]), sample[b]))
            for a, b in [("radius", "hitboxRadius"), ("height", "hitboxHeight")]:
                pairs.append((trace.bits(float(native[a])), trace.bits(sample[b])))
            pairs.append((vector(native["pos"]), list(map(trace.bits, sample["position"]))))
        for index, (got, want) in enumerate(pairs):
            assert got == want, (case["name"], i, index, got, want)
        comparisons += len(pairs)

    def collision_slots(s):
        return list(map(trace.slot, s["collided"].strip("()").split(",")[:int(s["collidedCount"])]))

    writes = records("SC_WRITE")
    assert writes
    later = [w for w in writes if int(w["bridge"]) > 2]
    if swapped:
        assert [(int(w["bridge"]), w["field"]) for w in later] == [
            (4, f"gObjectPool[39].oPos{a}") for a in "XYZ"]
    else:
        assert not later
    assert not any(w["field"].startswith("gObjectPool[23]") and int(w["bridge"]) > 0 for w in writes)
    assert not any(w["field"].startswith("gObjectPool[49]") for w in writes)
    assert trace.slot(records("SC_AFTER_CUT")[0]["held"]) == (-1 if swapped else 23)
    assert trace.slot(records("SC_AFTER_RELEASE_SETUP")[0]["held"]) == first_slot
    assert trace.slot(states[1]["held"]) == -1 and int(actors[last_slot][1]["held"]) == 0
    assert int(states[3]["shellStatus"]) == 0x400000 and trace.slot(states[3]["held"]) == -1
    assert all(s["A"] == "0" and not int(s["buttons"]) & 0x8000 for s in records("SC_INPUT"))
    audit = records("RESULT")[-1]
    assert all(audit[k] == "0" for k in ["aDownFrames", "aPressedFrames", "controllerAFrames"])
    pushes = []
    for bridge, slot in [(4, first_slot), (5, last_slot)]:
        calls = [s for s in records("SB_SHOVE") if int(s["bridge"]) == bridge]
        if bridge == 4:
            # Recontact with the released shell also calls the helper. Prove
            # that it moves neither coordinate before attributing the shove.
            assert [trace.slot(s["actor"]) for s in calls[:2]] == [71, 71]
            assert [s["pc"] for s in calls[:2]] == ["8024d3d8", "8024d57c"]
            assert vector(calls[0]["M"]) == vector(calls[1]["M"])
            calls = calls[2:]
        assert [s["pc"] for s in calls] == ["8024d3d8", "8024d57c"], calls
        assert all(trace.slot(s["actor"]) == slot for s in calls)
        assert slot in collision_slots(states[bridge])
        assert vector(calls[0]["M"]) != vector(calls[1]["M"])
        pushes.append(dict(update=125 + bridge, slot=slot, actor=calls[0]["actorXYZ"],
                           radius=float(calls[0]["radius"]), before=calls[0]["M"], after=calls[1]["M"]))
    queries = [s for s in records("FD_QUERY") if s["current"] == "80346038"]
    geometry = [s for s in queries if int(s["bridge"]) == 5 and s["caller"] == "802538a0"]
    assert geometry and float(geometry[0]["result"]) == 768
    assert float(states[5]["floorY"]) == 768
    area2 = next(s for s in states.values() if int(s["area"]) == 2)
    useful = vector(area2["M"]) == list(map(trace.bits, USEFUL))
    assert useful == (case["name"] != "control")
    capture = [i for i, s in states.items() if s["area"] == "1" and trace.slot(s["used"]) == 64
               and trace.slot(s["platform"]) == trace.slot(s["floorOwner"]) == 61]
    warp_queries = [s for s in queries if int(s["bridge"]) == 6 and s["caller"] in {"802538a0", "802538e4"}]
    if useful:
        assert [q["caller"] for q in warp_queries] == ["802538a0", "802538e4"]
        assert warp_queries[0]["surface"] == "00000000" and float(warp_queries[0]["result"]) == -11000
        assert vector(warp_queries[1]["query"]) == vector(states[5]["G"])
        assert trace.slot(warp_queries[1]["owner"]) == 61
        assert capture[0] == 6
        assert all(trace.slot(s["platform"]) == 61 for i, s in states.items()
                   if 6 <= i and s["area"] == "1")
        assert float(states[5]["floorY"]) == trace.xyz(states[5]["M"])[1] == 768
        assert trace.xyz(states[5]["G"])[1] > 1800
    else:
        assert [q["caller"] for q in warp_queries] == ["802538a0"] and float(warp_queries[0]["result"]) == 768
        assert not capture and vector(area2["M"]) == list(map(trace.bits, ORDINARY))
    return dict(case=case["name"], romSHA256=ROM_SHA256,
                rawLogSHA256=hashlib.sha256(payload).hexdigest(),
                recipeSHA256=hashlib.sha256(recipe.read_bytes()).hexdigest(),
                comparedCameraUpdates=len(expected)-len(missing), missingCameraBoundaries=missing,
                comparisons=comparisons, gameplayWrites=len(writes), lastWriteBeforeUpdate=130 if swapped else 128,
                pushes=pushes, freshFloor=geometry[0], warpQueries=warp_queries,
                producer={k:states[5][k] for k in ["M","C","G","floorY"]},
                capturedOnUpdate=(125 + capture[0]) if capture else None,
                topRetainedToWarp=bool(capture), arrival=area2["M"], useful=useful)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("recipe", type=Path)
    parser.add_argument("log", type=Path)
    parser.add_argument("--record", type=Path, help="write a small receipt beside an archived raw log")
    parser.add_argument("--archive", type=Path, help="preserve the checked raw log with lossless compression")
    args = parser.parse_args()
    payload = args.log.read_bytes()
    if args.log.suffix == ".gz":
        payload = gzip.decompress(payload)
    result = check(args.recipe, payload)
    summary = json.dumps(result, indent=2) + "\n"
    if args.record:
        args.record.write_bytes(summary.encode())
    if args.archive:
        args.archive.write_bytes(gzip.compress(payload, mtime=0))
    print(summary)
