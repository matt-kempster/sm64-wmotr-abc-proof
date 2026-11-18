"""Compare stock neutral-push actors at the two low shell-slide boundaries in JP Wafel."""
import argparse
import gzip
import hashlib
import importlib.util
import json
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent
OLD = HERE.parent / "ink-shell-carried-bob-mount"
spec = importlib.util.spec_from_file_location("carried_low_fixture", OLD / "check.py")
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)

ACTORS = {15: ("Buddy", -10), 23: ("small crate", -5), 40: ("ordinary Bob-omb", -5),
          49: ("Crazy Box", -5), 71: ("already used frozen shell", 2)}
AFTER_FIRST = [-2117.02685546875, 1839.447265625, -1113.008544921875]
FINAL = [-2200, 768, -1075]
USEFUL = [365.5927734375, 5500, -1096.8026123046875]
PARK = [5900, 51, 3440]


def xyz(g, slot, point):
    for axis, val in zip("XYZ", point):
        g.g.write(f"gObjectPool[{slot}].oPos" + axis, val)


def play_edits(g, edits):
    for edit in edits:
        val = edit["after"]
        if isinstance(val, str):
            val = g.address(val)
        g.g.write(edit["path"], val)


def sample(g, o):
    return c.r.snapshot(g, o, False)


def mounted(g, o, state, first_bob):
    ref = json.loads((OLD / "no-box.json").read_bytes())
    g.load_state(state)
    play_edits(g, ref["initialEdits"])
    for i, pad in enumerate(ref["controls"][:3]):
        if i == 2:
            edits = ref["cuts"][0]["edits"]
            if first_bob == 40:
                edits = json.loads(json.dumps(edits).replace("gObjectPool[39]", "gObjectPool[40]"))
            play_edits(g, edits)
        c.iso.advance(g, pad)
        actual = sample(g, o)
        assert all(actual[k] == ref["expected"][i][k] for k in actual if k != "collisions" or first_bob == 39)
    return g.save_state()


def role_start(g, o, after_mount, first):
    g.load_state(after_mount)
    if first:
        xyz(g, 39, PARK)
    else:
        c.iso.advance(g, c.iso.NEUTRAL)
        assert sample(g, o)["M"] == AFTER_FIRST
    saved = g.save_state()
    collision = sample(g, o)["C"]
    c.iso.advance(g, c.iso.NEUTRAL)
    movement = c.r.action_pos(g)
    g.load_state(saved)
    if not first:
        # The remaining first Bob can nudge an unopposed trial a second time.
        # With no platform after 129, the before-interaction M is the start M.
        assert sample(g, o)["platform"] == -1
        movement = sample(g, o)["M"]
    return saved, movement, collision


def positions(p, collision, target, radius, padding):
    # Invert only the nominal radial correction. All placements are actually played.
    separation = radius + 37 + padding
    points = {}
    for dx in [-12, -6, -2, 0, 2, 6, 12]:
        for dz in [-12, -6, -2, -0.75, 0, 2, 6, 12]:
            x, z = target[0] + dx, target[2] + dz
            length = math.hypot(x - p[0], z - p[2])
            if 0 < length < separation:
                point = [x - separation * (x - p[0]) / length, collision[1],
                         z - separation * (z - p[2]) / length]
                points[tuple(map(c.r.f32, point))] = None
    # Include hitbox overlaps on the line from the collision centre toward the target,
    # even when the target itself exceeds the nominal shove length.
    vx, vz = target[0] - collision[0], target[2] - collision[2]
    length = math.hypot(vx, vz)
    for d in [0, 1, 20, 40, radius, radius + 30]:
        point = [collision[0] + vx * d / length, collision[1], collision[2] + vz * d / length]
        points[tuple(map(c.r.f32, point))] = None
    return list(points)


def play(g, o, start, first, slot=None, point=None):
    g.load_state(start)
    if slot is not None:
        xyz(g, slot, point)
    rows = []
    if first:
        rows.append(c.r.advance(g, o))
        xyz(g, 49, c.b.BOX)
    producer = c.r.advance(g, o)
    accept = c.r.advance(g, o)
    rows.extend([producer, accept])
    capture = accept["used"] == 64 and accept["floorOwner"] == accept["platform"] == 61
    # Continue every captured and every omission control through arrival or a bounded suffix.
    if capture or slot is None:
        for _ in range(40):
            if rows[-1]["area"] != 1:
                break
            rows.append(c.r.advance(g, o))
    retained = capture and all(s["platform"] == 61 for s in rows[(2 if first else 1):] if s["area"] == 1)
    useful = retained and rows[-1]["area"] == 2 and rows[-1]["M"] == USEFUL
    return dict(slot=slot, position=point, contact=slot in rows[0]["collisions"],
                actorUpdate=rows[0], producer=producer, accepted=accept, capture=capture,
                retained=retained, useful=useful, arrival=rows[-1]["M"] if rows[-1]["area"] == 2 else None,
                continuation=rows if capture or slot is None else None)


def run():
    g, o, initial, _, _ = c.root()
    after_mount = mounted(g, o, initial, 39)
    swapped = mounted(g, o, initial, 40)
    result = {}
    for label, first, mount in [("first", True, after_mount), ("final", False, after_mount),
                                ("finalSwappedBobs", False, swapped)]:
        start, p, collision = role_start(g, o, mount, first)
        control = play(g, o, start, first)
        assert not control["capture"]
        result[label] = dict(proposalOrigin=p, collision=collision, omission=control, actors={})
        actors = dict(ACTORS)
        if label == "final":
            actors[39] = ("released first Bob-omb repositioned for a second shove", -5)
        if label == "finalSwappedBobs":
            actors = {39: ("ordinary Bob-omb before slot 40", -5)}
        for slot, (name, padding) in actors.items():
            g.load_state(start)
            actor = c.iso.actor_snapshot(g, slot)
            assert actor["activeFlags"] and actor["hitboxRadius"] > 0, (slot, actor)
            menu = positions(p, collision, AFTER_FIRST if first else FINAL, actor["hitboxRadius"], padding)
            rows = [play(g, o, start, first, slot, point) for point in menu]
            result[label]["actors"][str(slot)] = dict(name=name, actor=actor, trials=rows)
            print(label, name, len(rows), "contact", sum(t["contact"] for t in rows),
                  "useful", sum(t["useful"] for t in rows), flush=True)
    return result


def export_swapped(result):
    """Translate one independently played two-Bob success into the inherited JP replay format."""
    row = next(t for t in result["finalSwappedBobs"]["actors"]["39"]["trials"] if t["useful"])
    recipe = json.loads((OLD / "no-box.json").read_bytes())
    recipe["name"] = "swapped-bobs"
    edits = recipe["cuts"][0]["edits"]
    recipe["cuts"][0]["edits"] = json.loads(json.dumps(edits).replace("gObjectPool[39]", "gObjectPool[40]"))
    recipe["provenance"] = {"scope": __doc__, "swappedDonorSlot": 40, "finalXYZSlot": 39}
    recipe["sourceArtifact"] = "instrumentation/ink-low-shove-roles/comparison.json.gz"
    g, o, start, _, _ = c.root()
    g.load_state(start)
    play_edits(g, recipe["initialEdits"])
    rows = []
    pads = []
    for i in range(46):
        phase = g.read("gObjectPool[61].oTimer")
        if i == 2:
            assert phase == 128
            for ed in recipe["cuts"][0]["edits"]:
                current = g.read(ed["path"])
                ed["before"] = c.iso.ptr(g, o, current) if hasattr(current, "is_null") else current
                play_edits(g, [ed])
        if i == 4:
            assert phase == 130
            edits = []
            for axis, val in zip("XYZ", row["position"]):
                path = "gObjectPool[39].oPos" + axis
                edits.append(dict(path=path, before=g.read(path), after=val))
            play_edits(g, edits)
            recipe["cuts"].append(dict(phase=130, edits=edits))
        pad = c.iso.Z if i in (0, 2) else c.iso.NEUTRAL
        c.iso.advance(g, pad)
        state = c.snap(g, o)
        state["actors"]["40"] = c.iso.actor_snapshot(g, 40)
        rows.append(state)
        pads.append(pad)
        if state["area"] == 2:
            break
    assert rows[3]["M"] == AFTER_FIRST
    assert rows[5]["used"] == 64 and rows[5]["platform"] == 61
    assert rows[-1]["M"] == USEFUL
    recipe.update(expected=rows, expectedRichSamples=rows, controls=pads)
    return (json.dumps(recipe, separators=(",", ":")) + "\n").encode()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    output = HERE / "comparison.json.gz"
    result = run()
    raw = (json.dumps(result, separators=(",", ":")) + "\n").encode()
    native_recipe = export_swapped(result)
    exported = HERE / "swapped-bobs.json"
    if args.verify:
        assert gzip.decompress(output.read_bytes()) == raw
        assert exported.read_bytes() == native_recipe
    else:
        output.write_bytes(gzip.compress(raw, mtime=0))
        exported.write_bytes(native_recipe)
    print(hashlib.sha256(raw).hexdigest())
