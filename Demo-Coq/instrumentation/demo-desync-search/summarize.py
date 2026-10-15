#!/usr/bin/env python3
"""Produce a metadata-only receipt from completed finite observer trials."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent


def fields(line):
    return dict(part.split("=", 1) for part in line.split(",")[2:] if "=" in part)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("names", nargs="+")
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    result = {"scope": "finite authenticated retail-ROM emulator observations outside Coq; not an all-gameplay theorem",
              "source_pin": "9921382a68bb0c865e5e45eb594d9c64db59b1af", "trials": []}
    for name in args.names:
        if not name.isidentifier():
            raise RuntimeError("invalid trial name")
        folder = HERE / "build" / name
        manifest = json.loads((folder / "manifest.json").read_text())
        assert manifest["observer_sha256"] == sha(HERE / "observer.c"), "trial observer differs from current source"
        assert manifest["runner_sha256"] == sha(HERE / "run.py"), "trial runner differs from current source"
        summary = json.loads((folder / "summary.json").read_text())
        lines = (folder / "trace.csv").read_text().splitlines()
        loads = [fields(line) for line in lines if line.startswith("DLOAD,")]
        frames = [fields(line) for line in lines if line.startswith("DGAME,")]
        final = [fields(line) for line in lines if line.startswith("DSUMMARY,")]
        assert len(final) == 1 and int(final[0]["gameplayCalls"]) == len(frames)
        assert int(final[0]["episodes"]) == len(loads)
        assert summary["emulator_exit"] == 0 and not summary["observer_errors"]
        assert final[0]["errors"] == "0" and final[0]["mismatchCalls"] == "0"
        assert all(row["mismatch"] == "0" and row["level"] == row["expected"] for row in frames)
        terrain_authenticated = bool(manifest.get("terrain_receipts"))
        if terrain_authenticated:
            assert all(row["terrainLevel"] == row["expected"] and row["terrainName"] != "NONE"
                       and row["terrainPrefixBytes"] == "256" for row in frames)
        assert summary["checks"]["cheats_disabled"] and summary["checks"]["code_hashes_verified"]
        episode_receipts = []
        for load in loads:
            episode_frames = [row for row in frames if row["episode"] == load["episode"]]
            source_stream = next(stream for stream in manifest["stream_receipts"] if stream["name"] == load["stream"])
            episode_receipts.append({"episode": int(load["episode"]), "stream": load["stream"],
                "header_level": int(load["level"]), "first_input_global_frame": int(load["frame"]),
                "level_enum": source_stream.get("level_enum"), "level_folder": source_stream.get("level_folder"),
                "observed_updates": len(episode_frames),
                "first_update_global_frame": int(episode_frames[0]["frame"]) if episode_frames else None,
                "last_update_global_frame": int(episode_frames[-1]["frame"]) if episode_frames else None,
                "observed_level_numbers": sorted({int(row["level"]) for row in episode_frames}),
                "observed_area_indices": sorted({int(row["areaIndex"]) for row in episode_frames}),
                "observed_terrain_pointers": sorted({row["terrain"] for row in episode_frames}),
                "observed_terrain_names": sorted({row["terrainName"] for row in episode_frames}) if terrain_authenticated else [],
                "observed_play_modes": sorted({int(row["mode"]) for row in episode_frames})})
        result["trials"].append({"trial": name, "version": manifest["version"],
            "rom_sha1": manifest["rom_sha1"], "rom_sha256": manifest["rom_sha256"],
            "elf_sha256": manifest["elf_sha256"], "observer_sha256": manifest["observer_sha256"],
            "runner_sha256": manifest["runner_sha256"], "trace_sha256": sha(folder / "trace.csv"),
            "observed_code_receipts": manifest["code_receipts"],
            "terrain_receipts": manifest.get("terrain_receipts", []),
            "loaded_terrain_check": "byte-exact 256-byte prefixes, distinct among declared demo areas; ELF data byte-matched to authenticated retail ROM MIO0 output" if terrain_authenticated else "pointer observation only; no independent terrain-byte authentication",
            "initialization": manifest["initialization"], "start_at": manifest["start_at"],
            "start_frames": manifest["start_frames"], "reset_title": manifest.get("reset_title", False),
            "rendered_frame_cutoff": int(manifest["command"][manifest["command"].index("--testshots")+1]),
            "observed_active_demo_updates": len(frames), "mismatched_updates": 0,
            "initial_stream_comparison": "byte-exact comparison with authenticated ROM stream before timer mutation",
            "all_observed_painting_tables_null": all(row["painting"] == "00000000" for row in frames),
            "all_observed_instant_tables_null": all(row["instant"] == "00000000" for row in frames),
            "observer_errors": 0, "checks": summary["checks"], "episodes": episode_receipts})
    text = json.dumps(result, indent=2) + "\n"
    if args.write:
        (HERE / "results.json").write_text(text)
    else:
        print(text)


if __name__ == "__main__":
    main()
