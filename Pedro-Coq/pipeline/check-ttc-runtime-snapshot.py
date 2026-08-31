#!/usr/bin/env python3
"""Check the committed TTC debug-replay receipts and their Coq projection."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


if not __debug__:
    raise SystemExit(
        "receipt validation requires Python assertions; do not use -O or "
        "PYTHONOPTIMIZE"
    )


ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "instrumentation" / "ttc-runtime-snapshot" / "results"
PROOF = ROOT / "proofs" / "TTCDebugBoundary.v"
CENSUS_PROOF = ROOT / "proofs" / "TTCRNGCensus.v"
SQRT_PROOF = ROOT / "proofs" / "TTCRetailSqrt.v"

OBJECT_SIZE = 0x260
OBJECT_COUNT = 240
LIST_COUNT = 13

# Retail virtual addresses from the version-specific linker maps used by the
# instrumentation build.  Checking these exact bases is stronger than trying
# to infer a pool base from the pointers that the receipt is meant to certify.
OBJECT_POOL_BASE = {
    "US": 0x8033D488,
    "JP": 0x8033C118,
}
OBJECT_LISTS_BASE = {
    "US": 0x8033CBE0,
    "JP": 0x8033B870,
}
OBJECT_LIST_STRIDE = 0x68

RNG_BEHAVIOR = {
    "US": {
        "outside-list2": 0x800EE2F4,
        "dust-puff1": 0x800ED65C,
        "dust-puff2": 0x800ED680,
    },
    "JP": {
        "outside-list2": 0x800EB474,
        "dust-puff1": 0x800EA7FC,
        "dust-puff2": 0x800EA820,
    },
}
RNG_OWNER_BY_LIST = {2: "outside-list2", 8: "dust-puff1", 12: "dust-puff2"}
COQ_OWNER = {
    "outside-list2": "TTCDebugOutsideList2",
    "dust-puff1": "TTCDebugDustPuff1",
    "dust-puff2": "TTCDebugDustPuff2",
}

RETAIL_SQRTF = {
    "US": {
        "sha256": "17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91",
        "va": 0x80323A50,
        "rom": 0x000DEA50,
        "bytes": "03e00008460060040000000000000000",
    },
    "JP": {
        "sha256": "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317",
        "va": 0x80322B20,
        "rom": 0x000DDB20,
        "bytes": "03e00008460060040000000000000000",
    },
}


def coq_behavior_addresses() -> dict[str, dict[str, int]]:
    source = PROOF.read_text()
    table = re.search(
        r"Definition ttc_debug_rng_behavior_address\b(?P<body>.*?)\bend\.",
        source,
        re.DOTALL,
    )
    assert table, "could not find Coq behavior-address table"
    result: dict[str, dict[str, int]] = {"US": {}, "JP": {}}
    owner_names = {
        "TTCDebugOutsideList2": "outside-list2",
        "TTCDebugDustPuff1": "dust-puff1",
        "TTCDebugDustPuff2": "dust-puff2",
    }
    for version_name, version in (("VersionUS", "US"), ("VersionJP", "JP")):
        for coq_owner, owner in owner_names.items():
            match = re.search(
                rf"\|\s*{version_name},\s*{coq_owner}\s*=>\s*(\d+)",
                table.group("body"),
            )
            assert match, f"missing Coq behavior address for {version}/{owner}"
            result[version][owner] = int(match.group(1))
    return result


def coq_census_outside_behavior_addresses() -> dict[str, int]:
    source = CENSUS_PROOF.read_text()
    table = re.search(
        r"Definition expected_ttc_debug_outside_behavior_address\b"
        r"(?P<body>.*?)\bend\.",
        source,
        re.DOTALL,
    )
    assert table, "could not find census outside-behavior address table"
    result: dict[str, int] = {}
    for version_name, version in (("VersionUS", "US"), ("VersionJP", "JP")):
        match = re.search(
            rf"\|\s*{version_name}\s*=>\s*(\d+)", table.group("body")
        )
        assert match, f"missing census outside-behavior address for {version}"
        result[version] = int(match.group(1))
    return result


def coq_sqrtf_images() -> dict[str, dict[str, object]]:
    source = SQRT_PROOF.read_text()
    byte_match = re.search(
        r"Definition retail_sqrtf_bytes\s*:\s*list Z\s*:=\s*"
        r"\[(?P<body>.*?)\]\.",
        source,
        re.DOTALL,
    )
    assert byte_match, "could not find Coq retail_sqrtf_bytes"
    byte_values = [int(value) for value in re.findall(r"\d+", byte_match.group("body"))]
    assert all(0 <= value <= 255 for value in byte_values)
    byte_hex = bytes(byte_values).hex()

    result: dict[str, dict[str, object]] = {}
    for prefix, version in (("us", "US"), ("jp", "JP")):
        image_match = re.search(
            rf"Definition {prefix}_retail_sqrtf_image\s*:\s*RetailSqrtfImage\s*:=\s*"
            rf"\{{\|\s*sqrtf_virtual_address\s*:=\s*(?P<va>\d+);.*?"
            rf"sqrtf_rom_offset\s*:=\s*(?P<rom>\d+);.*?"
            rf"sqrtf_bytes\s*:=\s*retail_sqrtf_bytes\s*\|\}}\.",
            source,
            re.DOTALL,
        )
        assert image_match, f"could not find Coq {version} sqrtf image"
        result[version] = {
            "va": int(image_match.group("va")),
            "rom": int(image_match.group("rom")),
            "bytes": byte_hex,
        }
    return result


def load_sqrtf_receipt(version: str) -> dict[str, object]:
    lines = (RESULTS / f"{version.lower()}.sqrtf").read_text().splitlines()
    assert len(lines) == 1, f"{version}: expected one sqrtf receipt"
    fields = lines[0].split(",")
    assert fields[:2] == ["SQRTF", version], f"{version}: malformed sqrtf receipt"
    values = dict(field.split("=", 1) for field in fields[2:])
    assert set(values) == {"sha256", "va", "rom", "bytes"}
    return {
        "sha256": values["sha256"],
        "va": int(values["va"], 16),
        "rom": int(values["rom"], 16),
        "bytes": values["bytes"],
    }


@dataclass(frozen=True)
class Row:
    slot: int
    bucket: int
    active: int
    behavior: int
    action: int
    timer: int
    next_pointer: int
    previous_pointer: int

    @property
    def address_offset(self) -> int:
        return self.slot * OBJECT_SIZE


@dataclass(frozen=True)
class RngEvent:
    version: str
    call: int
    timer: int
    caller: int
    object_pointer: int
    slot: int
    bucket: int
    behavior: int
    action: int
    object_timer: int
    ttc_speed: int
    seed_before: int
    seed_after: int
    returned: int
    mario_particle_flags: int
    mario_active_particles: int
    frame: str

    @property
    def owner(self) -> str:
        return RNG_OWNER_BY_LIST[self.bucket]

    def normalized(self) -> tuple[object, ...]:
        return (
            self.call,
            self.timer,
            self.owner,
            self.slot,
            self.bucket,
            self.action,
            self.object_timer,
            self.ttc_speed,
            self.seed_before,
            self.seed_after,
            self.returned,
            self.mario_particle_flags,
            self.mario_active_particles,
            self.frame,
        )


SUMMARY_RE = re.compile(
    r"^TTC_SNAPSHOT,(?P<version>US|JP),timer=(?P<timer>\d+),"
    r"level=(?P<level>\d+),area=(?P<area>\d+),"
    r"ttcSpeed=(?P<ttc_speed>\d+),mario=(?P<mario>[0-9a-f]+),"
    r"marioSlot=(?P<mario_slot>\d+),particleFlags=(?P<particles>[0-9a-f]+),"
    r"activeParticles=(?P<active_particles>[0-9a-f]+),"
    r"timeStop=(?P<time_stop>[0-9a-f]+),free=(?P<free>\d+),"
    r"unimportant=(?P<unimportant>\d+),active=(?P<active>\d+),"
    r"reserve=(?P<reserve>\d+),listIntegrity=(?P<integrity>[01]),"
    r"dustRequest=(?P<dust>[01]),dustBitClear=(?P<clear>[01]),"
    r"normalTime=(?P<normal>[01]),"
)

ROW_RE = re.compile(
    r"^TTC_OBJECT,(?P<version>US|JP),slot=(?P<slot>\d+),"
    r"list=(?P<bucket>-?\d+),active=(?P<active>[0-9a-f]+),"
    r"behavior=(?P<behavior>[0-9a-f]+),action=(?P<action>-?\d+),"
    r"timer=(?P<timer>-?\d+),next=(?P<next>[0-9a-f]+),"
    r"prev=(?P<previous>[0-9a-f]+)$"
)


def load(version: str) -> tuple[dict[str, str], list[Row]]:
    lines = (RESULTS / f"{version.lower()}.snapshot").read_text().splitlines()
    summaries = [SUMMARY_RE.match(line) for line in lines]
    summaries = [match for match in summaries if match]
    assert len(summaries) == 1, f"{version}: expected one summary"
    summary = summaries[0].groupdict()
    assert summary["version"] == version

    rows: list[Row] = []
    for line in lines:
        match = ROW_RE.match(line)
        if not match:
            continue
        values = match.groupdict()
        assert values["version"] == version
        rows.append(
            Row(
                slot=int(values["slot"]),
                bucket=int(values["bucket"]),
                active=int(values["active"], 16),
                behavior=int(values["behavior"], 16),
                action=int(values["action"]),
                timer=int(values["timer"]),
                next_pointer=int(values["next"], 16),
                previous_pointer=int(values["previous"], 16),
            )
        )
    assert len(rows) == OBJECT_COUNT, f"{version}: expected 240 object rows"
    return summary, rows


def load_rng(version: str) -> list[RngEvent]:
    events: list[RngEvent] = []
    for line in (RESULTS / f"{version.lower()}.rng").read_text().splitlines():
        if not line:
            continue
        fields = line.split(",")
        assert fields[:2] == ["TTC_RNG", version], f"{version}: malformed RNG line"
        values = dict(field.split("=", 1) for field in fields[2:])
        assert set(values) == {
            "call",
            "timer",
            "caller",
            "object",
            "slot",
            "list",
            "behavior",
            "action",
            "objectTimer",
            "ttcSpeed",
            "seedBefore",
            "seedAfter",
            "return",
            "marioParticleFlags",
            "marioActiveParticles",
            "frame",
        }, f"{version}: incomplete RNG event"
        events.append(
            RngEvent(
                version=version,
                call=int(values["call"]),
                timer=int(values["timer"]),
                caller=int(values["caller"], 16),
                object_pointer=int(values["object"], 16),
                slot=int(values["slot"]),
                bucket=int(values["list"]),
                behavior=int(values["behavior"], 16),
                action=int(values["action"]),
                object_timer=int(values["objectTimer"]),
                ttc_speed=int(values["ttcSpeed"]),
                seed_before=int(values["seedBefore"], 16),
                seed_after=int(values["seedAfter"], 16),
                returned=int(values["return"], 16),
                mario_particle_flags=int(values["marioParticleFlags"], 16),
                mario_active_particles=int(values["marioActiveParticles"], 16),
                frame=values["frame"],
            )
        )
    return events


def check(version: str, summary: dict[str, str], rows: list[Row]) -> list[int]:
    by_slot = {row.slot: row for row in rows}
    assert set(by_slot) == set(range(OBJECT_COUNT)), f"{version}: slot partition"
    assert all(row.bucket == -1 or 0 <= row.bucket < LIST_COUNT for row in rows)
    assert all((row.active == 0) == (row.bucket == -1) for row in rows)

    free_rows = [row for row in rows if row.bucket == -1]
    active_rows = [row for row in rows if row.bucket >= 0]
    unimportant = [row for row in rows if row.bucket == 12]
    assert len(free_rows) == int(summary["free"])
    assert len(active_rows) == int(summary["active"])
    assert len(unimportant) == int(summary["unimportant"])
    assert len(free_rows) + len(unimportant) == int(summary["reserve"])
    assert len(free_rows) == 115 and len(active_rows) == 125
    assert len(unimportant) == 1 and int(summary["reserve"]) == 116
    assert int(summary["reserve"]) >= 3
    assert {row.slot for row in active_rows} == set(range(125))
    assert {row.slot for row in free_rows} == set(range(125, OBJECT_COUNT))
    assert rows[:len(free_rows)] == free_rows, f"{version}: free traversal order"
    assert [row.bucket for row in active_rows] == sorted(
        row.bucket for row in active_rows
    ), f"{version}: object-list traversal order"
    assert int(summary["mario_slot"]) == 119
    assert by_slot[119].bucket == 0

    assert int(summary["timer"]) == 414
    assert int(summary["level"]) == 14 and int(summary["area"]) == 1
    assert int(summary["ttc_speed"]) == 0, f"{version}: receipt is not SLOW mode"
    assert int(summary["particles"], 16) & 1 == 1
    assert int(summary["active_particles"], 16) & 1 == 0
    assert int(summary["time_stop"], 16) == 0
    assert summary["integrity"] == summary["dust"] == "1"
    assert summary["clear"] == summary["normal"] == "1"

    base = OBJECT_POOL_BASE[version]
    list_base = OBJECT_LISTS_BASE[version]
    address = lambda row: base + row.address_offset
    object_addresses = {address(row) for row in rows}
    sentinels = {
        list_base + bucket * OBJECT_LIST_STRIDE for bucket in range(LIST_COUNT)
    }
    assert object_addresses.isdisjoint(sentinels)
    assert int(summary["mario"], 16) == address(by_slot[119])

    for current, following in zip(free_rows, free_rows[1:]):
        assert current.next_pointer == address(following), f"{version}: free next"
    assert free_rows[-1].next_pointer == 0, f"{version}: free terminator"
    assert all(row.previous_pointer == 0 for row in free_rows), (
        f"{version}: free previous fields"
    )

    for bucket in range(LIST_COUNT):
        listed = [row for row in rows if row.bucket == bucket]
        if not listed:
            continue
        sentinel = list_base + bucket * OBJECT_LIST_STRIDE
        assert listed[0].previous_pointer == sentinel
        assert listed[-1].next_pointer == sentinel
        for previous, current, following in zip(
            [None] + listed[:-1], listed, listed[1:] + [None]
        ):
            if previous is not None:
                assert current.previous_pointer == address(previous)
            if following is not None:
                assert current.next_pointer == address(following)

    allowed_pointers = object_addresses | sentinels | {0}
    assert all(
        row.next_pointer in allowed_pointers
        and row.previous_pointer in allowed_pointers
        for row in rows
    ), f"{version}: pointer outside object pool/list sentinels"

    return [by_slot[slot].bucket for slot in range(125)]


def random_u16_step(seed: int) -> int:
    seed = 0 if seed == 0x560A else seed & 0xFFFF
    temp1 = (((seed & 0xFF) << 8) ^ seed) & 0xFFFF
    seed1 = (((temp1 & 0xFF) << 8) + ((temp1 & 0xFF00) >> 8)) & 0xFFFF
    temp1 = ((((temp1 & 0xFF) << 1) ^ seed1)) & 0xFFFF
    temp2 = ((temp1 >> 1) ^ 0xFF80) & 0xFFFF
    if temp1 % 2 == 0:
        return 0 if temp2 == 0xAA55 else (temp2 ^ 0x1FF4) & 0xFFFF
    return (temp2 ^ 0x8180) & 0xFFFF


def check_rng(version: str, events: list[RngEvent]) -> list[tuple[object, ...]]:
    assert len(events) == 10, f"{version}: exact F/F+1 RNG event count"
    expected_calls = list(range(33, 43))
    expected_timers = [414] * 5 + [415] * 5
    expected_frames = ["F"] * 5 + ["F+1"] * 5
    expected_slots = [92, 126, 126, 127, 127, 92, 128, 128, 129, 129]
    expected_buckets = [2, 8, 8, 12, 12] * 2
    expected_object_timers = [17, 0, 0, 0, 0, 18, 0, 0, 0, 0]
    expected_before = [
        0x66A4,
        0xB2B1,
        0x2630,
        0xF84F,
        0x5994,
        0x34F2,
        0x99E5,
        0x922F,
        0x69F1,
        0x9849,
    ]
    expected_after = expected_before[1:] + [0x5AA1]

    assert [event.call for event in events] == expected_calls
    assert [event.timer for event in events] == expected_timers
    assert [event.frame for event in events] == expected_frames
    assert [event.slot for event in events] == expected_slots
    assert [event.bucket for event in events] == expected_buckets
    assert [event.object_timer for event in events] == expected_object_timers
    assert [event.seed_before for event in events] == expected_before
    assert [event.seed_after for event in events] == expected_after
    assert all(event.action == 0 for event in events)
    assert all(event.caller == 0x80383CC4 for event in events)
    assert all(event.ttc_speed == 0 for event in events)
    assert all(event.returned == event.seed_after for event in events)
    assert all(event.mario_particle_flags & 1 == 1 for event in events)
    assert all(
        event.object_pointer
        == OBJECT_POOL_BASE[version] + event.slot * OBJECT_SIZE
        for event in events
    )
    assert all(
        event.behavior == RNG_BEHAVIOR[version][event.owner]
        for event in events
    )
    assert all(
        random_u16_step(event.seed_before) == event.seed_after for event in events
    )

    # Call numbers are assigned at every authenticated TTC random_u16 entry and
    # only emitted when its authenticated epilogue is reached.  Contiguity from
    # the last F call through the first F+1 call, together with the seed chain,
    # excludes an unlogged TTC call between these frame boundaries.
    assert all(
        first.call + 1 == second.call
        and first.seed_after == second.seed_before
        for first, second in zip(events, events[1:])
    )
    for offset in (0, 5):
        frame = events[offset : offset + 5]
        assert frame[0].owner == "outside-list2"
        assert frame[0].mario_active_particles & 1 == 1
        assert sum(event.owner.startswith("dust-") for event in frame) == 4
        assert all(event.mario_active_particles & 1 == 0 for event in frame[1:])

    return [event.normalized() for event in events]


def coq_active_buckets() -> list[int]:
    source = PROOF.read_text()
    match = re.search(
        r"Definition ttc_level_select_active_buckets : list nat :=\s*"
        r"\(\[(?P<body>.*?)\]\)%nat\.\s*\n\s*"
        r"Definition ttc_level_select_slot_buckets",
        source,
        re.DOTALL,
    )
    assert match, "could not find the Coq bucket receipt"
    return [int(value) for value in re.findall(r"\d+", match.group("body"))]


def coq_debug_rng_events(name: str) -> list[tuple[object, ...]]:
    source = PROOF.read_text()
    definition = re.search(
        rf"Definition {re.escape(name)} : list TTCDebugRngEvent :=\s*"
        r"\[(?P<body>.*?)\]\.",
        source,
        re.DOTALL,
    )
    assert definition, f"could not find Coq RNG event list {name}"
    event_re = re.compile(
        r"ttc_debug_rng_event\s+"
        r"(?P<call>\d+)(?:%nat)?\s+"
        r"(?P<timer>\d+)(?:%nat)?\s+"
        r"(?P<owner>TTCDebug\w+)\s+"
        r"(?P<slot>\d+)(?:%nat)?\s+"
        r"(?P<bucket>\d+)(?:%nat)?\s+"
        r"(?P<action>-?\d+)\s+(?P<object_timer>-?\d+)\s+"
        r"(?P<before>\d+)\s+(?P<after>\d+)"
    )
    events: list[tuple[object, ...]] = []
    for match in event_re.finditer(definition.group("body")):
        values = match.groupdict()
        events.append(
            (
                int(values["call"]),
                int(values["timer"]),
                values["owner"],
                int(values["slot"]),
                int(values["bucket"]),
                int(values["action"]),
                int(values["object_timer"]),
                int(values["before"]),
                int(values["after"]),
            )
        )
    assert len(events) == 5, f"{name}: expected five Coq events"
    return events


def main() -> None:
    projected_addresses = coq_behavior_addresses()
    assert projected_addresses == RNG_BEHAVIOR
    census_outside_addresses = coq_census_outside_behavior_addresses()
    assert census_outside_addresses == {
        version: addresses["outside-list2"]
        for version, addresses in RNG_BEHAVIOR.items()
    }
    coq_sqrtf = coq_sqrtf_images()
    for version, expected in RETAIL_SQRTF.items():
        assert load_sqrtf_receipt(version) == expected
        assert coq_sqrtf[version] == {
            key: expected[key] for key in ("va", "rom", "bytes")
        }

    us_summary, us_rows = load("US")
    jp_summary, jp_rows = load("JP")
    us_buckets = check("US", us_summary, us_rows)
    jp_buckets = check("JP", jp_summary, jp_rows)
    assert us_buckets == jp_buckets == coq_active_buckets()

    us_rng = load_rng("US")
    jp_rng = load_rng("JP")
    normalized_us_rng = check_rng("US", us_rng)
    normalized_jp_rng = check_rng("JP", jp_rng)
    assert normalized_us_rng == normalized_jp_rng

    coq_rng = coq_debug_rng_events("ttc_debug_slow_frame_f_events")
    coq_rng += coq_debug_rng_events("ttc_debug_slow_frame_f1_events")
    expected_coq_rng = [
        (
            event.call,
            event.timer,
            COQ_OWNER[event.owner],
            event.slot,
            event.bucket,
            event.action,
            event.object_timer,
            event.seed_before,
            event.seed_after,
        )
        for event in us_rng
    ]
    assert coq_rng == expected_coq_rng

    normalized_us = [
        (row.slot, row.bucket, row.active, row.action, row.timer) for row in us_rows
    ]
    normalized_jp = [
        (row.slot, row.bucket, row.active, row.action, row.timer) for row in jp_rows
    ]
    assert normalized_us == normalized_jp
    print(
        "TTC SLOW debug-replay census, complete F/F+1 RNG receipts, and "
        "retail sqrtf byte receipts agree with their Coq projections (US/JP)."
    )


if __name__ == "__main__":
    main()
