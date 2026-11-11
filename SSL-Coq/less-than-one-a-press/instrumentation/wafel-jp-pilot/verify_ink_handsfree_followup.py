"""Read-only audit of the final clean-acquisition and continuation evidence.

Run with ordinary Python from any directory. Ignored raw reports and the pinned
DLL/capture must be present at their recorded project paths. This independently
recomputes receipt projections, retained sample summaries and input hashes. It
checks the stored fresh-replay records; it does not rerun gameplay, establish
unrecorded histories, or turn the supplied roof cuts into clean acquisitions.
"""
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = ROOT / "instrumentation/wafel-jp-pilot"
CRAWL = 0x04008448


def check(condition, message):
    if not condition:
        raise AssertionError(message)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def read(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def input_hash(inputs):
    return hashlib.sha256(json.dumps(inputs, separators=(",", ":")).encode()).hexdigest()


def jsonl(inputs):
    return "".join(json.dumps(p, separators=(",", ":")) + "\n" for p in inputs).encode()


def acquisition_summary(trial):
    rows = trial["samples"]
    held = [s for s in rows if s["held"] == 47]
    first = next(iter(held), None)
    later = [] if first is None else [s for s in rows if s["n"] > first["n"]]
    released = next((s for s in later if s["held"] != 47 and s["boxBehavior"]
                     and s["boxActive"] and s["boxHeld"] == 0), None)
    deleted = next((s for s in later if not s["boxBehavior"] or not s["boxActive"]), None)
    hf = trial["firstHandsfreeExit"]
    hfheld = [] if hf is None else [s for s in held if s["n"] >= hf["sample"]["n"]]
    return dict(policy=trial["policy"], updates=len(trial["inputs"]), pressedB=trial["pressedB"],
                inputSha256=input_hash(trial["inputs"]), pickup=first, firstHandsfreeExit=hf,
                freeRelease=released, firstDeletion=deleted, heldUpdates=len(held),
                maximumHeldY=max((s["movement"][1] for s in held), default=None),
                maximumHandsfreeHeldY=max((s["movement"][1] for s in hfheld), default=None),
                crawlUpdates=sum(s["action"] == CRAWL for s in rows),
                maximumPillars=max((s["pillars"] for s in rows if s["pillars"] is not None), default=None),
                spinningTopSamples=sum(s["topBehavior"] and s["topAction"] == 1 for s in rows), final=rows[-1])


def acquisition_projection(raw, path):
    result = {k: v for k, v in raw.items() if k not in ("trials", "selected")}
    result.update(rawReportName=path, rawReportSha256=sha(ROOT / path),
                  trials=[acquisition_summary(t) for t in raw["trials"]], selected=[])
    for trial in raw["selected"]:
        chosen = {s["timer"]: s for s in (trial["samples"][0], trial["samples"][-1])}
        for key in ("pickup", "freeRelease", "firstDeletion"):
            row = trial["summary"][key]
            if row is not None:
                n = row["n"]
                chosen.update((s["timer"], s) for s in trial["samples"][max(0, n - 2):n + 1])
        n = trial["summary"]["firstHandsfreeExit"]["sample"]["n"]
        chosen.update((s["timer"], s) for s in trial["samples"][n - 2:n + 1])
        result["selected"].append({**{k: v for k, v in trial.items() if k != "samples"},
                                   "selectedSamples": [chosen[k] for k in sorted(chosen)]})
    return result


def continuation_summary(trial):
    rows = trial["samples"]
    slot = rows[0]["actor"]["slot"]
    drop = next((i for i, s in enumerate(rows) if s["held"] != slot), None)
    alive = lambda s: s["actor"]["isJumpingBox"] and bool(s["actor"]["activeFlags"])
    deleted = next((s for s in rows if not alive(s)), None)
    crawls = [s for s in rows if s["action"] == CRAWL]
    return dict(kind=trial["kind"], seedIndex=trial["seedIndex"], policy=trial["policy"],
                updates=len(trial["inputs"]), inputSha256=input_hash(trial["inputs"]),
                firstCrawl=next(iter(crawls), None), maxCrawlY=max((s["movement"][1] for s in crawls), default=None),
                freeActorCrawlSamples=sum(alive(s) and s["actor"]["oHeldState"] == 0
                                         and s["actor"]["oIntangibleTimer"] == 0 for s in crawls),
                release=None if drop is None else dict(before=rows[max(0, drop - 1)], after=rows[drop]),
                firstDeletion=deleted,
                freeLifetimeUpdates=None if drop is None or deleted is None else deleted["n"] - rows[drop]["n"],
                maxY=max(s["movement"][1] for s in rows), maxYAfterStart=max(s["movement"][1] for s in rows[1:]),
                phase130=next((s for s in rows if s["topIsPyramid"] and s["topAction"] == 1 and s["topTimer"] == 130), None),
                final=rows[-1])


def continuation_projection(raw, path):
    columns = ["kind", "seedIndex", "policy", "updates", "inputSha256", "maximumY", "maximumCrawlY",
               "firstCrawlTimer", "releaseTimer", "releaseMarioXYZ", "releaseActorXYZ", "firstDeletionTimer",
               "freeLifetimeUpdates", "freeActorCrawlSamples", "phase130MarioXYZ", "finalMarioXYZ"]
    rows = []
    for trial in raw["trials"]:
        s = trial["summary"]
        drop = None if s["release"] is None else s["release"]["after"]
        rows.append([s["kind"], s["seedIndex"], s["policy"], s["updates"], s["inputSha256"], s["maxY"], s["maxCrawlY"],
                     None if s["firstCrawl"] is None else s["firstCrawl"]["timer"], None if drop is None else drop["timer"],
                     None if drop is None else drop["movement"], None if drop is None else [drop["actor"]["oPos" + a] for a in "XYZ"],
                     None if s["firstDeletion"] is None else s["firstDeletion"]["timer"], s["freeLifetimeUpdates"],
                     s["freeActorCrawlSamples"], None if s["phase130"] is None else s["phase130"]["movement"], s["final"]["movement"]])
    selected = []
    for trial in raw["selected"]:
        samples = trial["samples"]
        indices, prior = {0, len(samples) - 1}, None
        for i, s in enumerate(samples):
            key = (s["action"], s["held"], s["actor"]["isJumpingBox"], s["actor"]["activeFlags"])
            if key != prior:
                indices.update((max(0, i - 1), i))
            prior = key
        selected.append({**{k: v for k, v in trial.items() if k != "samples"},
                         "selectedSnapshots": [samples[i] for i in sorted(indices)], "allSnapshotCount": len(samples)})
    return {**{k: v for k, v in raw.items() if k not in ("trials", "beams", "selected")},
            "rawReportName": path, "rawReportSha256": sha(ROOT / path), "trialColumns": columns,
            "trialRows": rows, "selected": selected,
            "beams": [{k: v for k, v in b.items() if k != "finalTrail"} for b in raw["beams"]]}


def audit_inputs(value, counts):
    if isinstance(value, dict):
        if isinstance(value.get("buttons"), int):
            check(0 <= value["buttons"] <= 65535 and not value["buttons"] & 0x8000, "A/button bounds")
            check(len(value["stick"]) == 2 and all(isinstance(x, int) and -128 <= x <= 127 for x in value["stick"]), "stick bounds")
            counts[0] += 1
        if isinstance(value.get("input"), int):
            check(not value["input"] & 0x82, "Mario A-pressed/down flag")
            counts[1] += 1
        for child in value.values():
            audit_inputs(child, counts)
    elif isinstance(value, list):
        for child in value:
            audit_inputs(child, counts)


def main():
    capture_path = ROOT / "build/wafel-pilot/capture.bKv95w/inputs.jsonl"
    capture = [json.loads(line) for line in capture_path.read_text().splitlines()]
    prefix = [dict(buttons=r["buttons"], stick=r["stick"]) for r in capture[:350]]
    clean_path = "build/wafel-pilot/ink-clean-handsfree-20261112-final.json"
    cont_path = "build/wafel-pilot/ink-handsfree-continuations-20261112-final.json"
    clean, cont = read(ROOT / clean_path), read(ROOT / cont_path)
    for raw, script in ((clean, "ink_clean_handsfree.py"), (cont, "ink_handsfree_continuations.py")):
        check(raw["schema"] == 1, "schema")
        check(raw["scriptSha256"] == sha(SCRIPTS / script), "current script hash: " + script)
        check(raw["baselineSha256"] == sha(capture_path), "accepted capture hash")
        check(raw["runtimeSha256"] == sha(ROOT / "build/wafel-pilot/sm64_jp.dll"), "runtime hash")
        check(b"\r" not in (SCRIPTS / script).read_bytes(), "study script LF rule")
    check(acquisition_projection(clean, clean_path) == read(ROOT / "docs/notes/ink-clean-handsfree-receipt.json"), "exact acquisition receipt")
    check(continuation_projection(cont, cont_path) == read(ROOT / "docs/notes/ink-handsfree-continuations-receipt.json"), "exact continuation receipt")
    check(clean["prefixInputCount"] == 350 and clean["prefixAFrames"] == 0 and clean["gameplaySetupWrites"] == [], "clean setup scope")
    check(clean["preEntrySetup"] == "create_game sets gDebugLevelSelect=1 before level entry", "accepted pre-entry scope")
    expected_policies = [dict(waypoint=list(w), triggerRadius=r) for w in ((1120,7100),(600,7100),(1600,7100),(1120,7300)) for r in (110,140,180,240,320)]
    check([t["policy"] for t in clean["trials"]] == expected_policies, "20 acquisition policies")
    check(clean["policies"] == dict(waypoints=[[1120,7100],[600,7100],[1600,7100],[1120,7300]],
          triggerRadii=[110,140,180,240,320], horizon=260), "acquisition policy bounds")
    summaries = []
    for t in clean["trials"]:
        check(len(t["inputs"]) == len(t["samples"]) == 260, "acquisition horizon")
        check([s["n"] for s in t["samples"]] == list(range(1, 261)), "acquisition sample indices")
        hf = t["firstHandsfreeExit"]
        if hf is not None:
            check("ACT_DIVE_PICKING_UP" in hf["actionEntries"] and hf["sample"] == t["samples"][hf["sample"]["n"] - 1]
                  and hf["sample"]["held"] == 47 and hf["sample"]["action"] == 0x008C0453,
                  "actual retained dive-pickup to hands-free stomach-slide evidence")
        summaries.append(acquisition_summary(t))
    calculated = dict(policies=len(summaries), uniqueInputHistories=len({s["inputSha256"] for s in summaries}),
                      updates=sum(s["updates"] for s in summaries), pickupPolicies=sum(s["pickup"] is not None for s in summaries),
                      handsfreePolicies=sum(s["firstHandsfreeExit"] is not None for s in summaries),
                      uniqueHandsfreeHistories=len({s["inputSha256"] for s in summaries if s["firstHandsfreeExit"] is not None}),
                      crawlUpdates=sum(s["crawlUpdates"] for s in summaries), maximumPillars=max(s["maximumPillars"] for s in summaries),
                      spinningTopSamples=sum(s["spinningTopSamples"] for s in summaries))
    check(calculated == clean["summary"] == dict(policies=20, uniqueInputHistories=13, updates=5200, pickupPolicies=20,
          handsfreePolicies=9, uniqueHandsfreeHistories=5, crawlUpdates=0, maximumPillars=0, spinningTopSamples=0), "acquisition totals/distinct histories")
    check(len(clean["selected"]) == 2, "two acquisition fresh replays")
    for witness in clean["selected"]:
        trial = next(t for t in clean["trials"] if t["policy"] == witness["policy"])
        check(all(witness[k] == trial[k] for k in ("inputs", "samples", "events")), "acquisition fresh trial correspondence")
        check(witness["summary"] == acquisition_summary(trial), "acquisition selected summary")
        check(witness["fullInputs"] == prefix + witness["inputs"] and witness["fullInputCount"] == 610, "610-input clean history")
        check(witness["fullInputSha256"] == hashlib.sha256(jsonl(witness["fullInputs"])).hexdigest(), "canonical LF input hash")
        check(witness["freshReplay"] == dict(passed=True, prefixInputCount=350, branchInputCount=260,
              comparedBranchSnapshots=260, comparedInitialSnapshot=True, gameplaySetupWrites=[]), "stored acquisition fresh replay")
    for source in cont["sourceReports"]:
        check(source["sha256"] == sha(ROOT / source["path"]), "source report hash")
    check(cont["sourceReports"][1]["path"] == clean_path, "final acquisition source")
    for name, digest in cont["helperSha256"].items():
        check(digest == sha(SCRIPTS / name), "current helper hash: " + name)
    roof = read(ROOT / cont["sourceReports"][0]["path"])
    allowed = {"gMarioState.pos", "gMarioObject.header.gfx.pos"} | {"gMarioObject.oPos" + a for a in "XYZ"} | {"gObjectPool[49].oPos" + a for a in "XYZ"}
    check([(s["kind"], s["seedIndex"]) for s in cont["seeds"]] == [("roof", i) for i in range(18)] + [("clean", 0)], "19 seed identities")
    for seed in cont["seeds"]:
        if seed["kind"] == "roof":
            source = roof["focusedDive"]["trials"][seed["seedIndex"]]
            check(len(seed["initialEdits"]) == 8 and {e["path"] for e in seed["initialEdits"]} == allowed
                  and seed["initialEdits"] == source["initialEdits"], "sole supplied XYZ cut")
            check(seed["runup"] == roof["focusedDive"]["runup"] and seed["runup"]["nonControllerEdits"] == [], "native run-up")
            check(seed["afterCutAcquisitionInputs"] == source["controls"][:source["firstHandsfreeExit"]["update"]], "roof acquisition prefix")
        else:
            check(seed["initialEdits"] == [] and seed["acceptedPrefixInputs"] == 350, "clean seed edit scope")
            check(seed["acquisitionInputs"] == clean["selected"][0]["inputs"][:86]
                  and seed["fullControllerPrefix"] == prefix + seed["acquisitionInputs"], "clean 436-input seed")
            original = clean["selected"][0]["samples"][85]
            check(all(seed["start"][k] == original[k] for k in seed["start"].keys() & original.keys() if k != "n"), "cross-study checkpoint equality")
    totals = {}
    for kind, horizon, per_seed, number in (("roof", 130, 22, 396), ("clean", 220, 40, 40)):
        trials = [t for t in cont["trials"] if t["kind"] == kind]
        check(len(trials) == number and all(len(t["inputs"]) == horizon for t in trials), "continuation horizon/count")
        targets = ([[1120,6500],[500,6500],[1500,6500],[1120,5800],[2000,5000],[1120,5500]] if kind == "clean"
                   else [[-2559,-1535],[-2500,-1450],[-2000,-1535],[-2000,-1024],[-1950,-939],[-1500,-1024]])
        expected = [dict(mode="target", target=t, magnitude=m, periodicB=b) for t in targets
                    for m in (32,64,127) for b in ((False,True) if kind == "clean" else (False,))]
        expected += [dict(mode=mode, target=None, magnitude=127, periodicB=b)
                     for mode in ("brake", "neutral") for b in (False, True)]
        for index in {t["seedIndex"] for t in trials}:
            subset = [t for t in trials if t["seedIndex"] == index]
            check(len(subset) == per_seed and len({json.dumps(t["policy"], sort_keys=True) for t in subset}) == per_seed, "distinct policies per seed")
            check([t["policy"] for t in subset] == expected, "continuation policy menu")
        check(len({(t["seedIndex"], input_hash(t["inputs"])) for t in trials}) == number, "distinct seeded suffix histories")
        for t in trials:
            s = t["summary"]
            check(all(s[k] == t[k] for k in ("kind", "seedIndex", "policy")) and s["updates"] == horizon
                  and s["inputSha256"] == input_hash(t["inputs"]), "continuation trial metadata")
        totals[kind + "Policies"] = len(trials)
        totals[kind + "Updates"] = sum(len(t["inputs"]) for t in trials)
        totals[kind + "CrawlPolicies"] = sum(t["summary"]["firstCrawl"] is not None for t in trials)
    totals.update(maximumCrawlY=max(t["summary"]["maxCrawlY"] for t in cont["trials"] if t["summary"]["maxCrawlY"] is not None),
                  freeActorCrawlSamples=sum(t["summary"]["freeActorCrawlSamples"] for t in cont["trials"]),
                  beamContinuations=sum(b["testedContinuations"] for b in cont["beams"]), beamCrawlCandidates=sum(b["crawlCandidates"] for b in cont["beams"]))
    check(totals == cont["summary"] == dict(roofPolicies=396, roofUpdates=51480, roofCrawlPolicies=0, cleanPolicies=40,
          cleanUpdates=8800, cleanCrawlPolicies=22, maximumCrawlY=38.0, freeActorCrawlSamples=0,
          beamContinuations=1143, beamCrawlCandidates=0), "continuation recorded totals")
    check([b["seedIndex"] for b in cont["beams"]] == [0, 6, 12], "beam seeds")
    for beam in cont["beams"]:
        check((beam["width"], beam["horizon"], beam["menuSize"]) == (12, 110, 9), "beam bounds")
        retained, tested = 1, 0
        for depth, step in enumerate(beam["depths"], 1):
            tested += retained * 9
            check(step["depth"] == depth <= 110 and 0 <= step["retained"] <= min(12, step["passing"])
                  and step["passing"] <= retained * 9, "beam depth accounting")
            retained = step["retained"]
        check(tested == beam["testedContinuations"] and retained == 0, "bounded beam termination")
    check(len(cont["selected"]) == 5, "five continuation fresh replays")
    for w in cont["selected"]:
        seed = next(s for s in cont["seeds"] if (s["kind"], s["seedIndex"]) == (w["kind"], w["seedIndex"]))
        check(w["seed"] == {k: v for k, v in seed.items() if k != "start"} and w["samples"][0] == seed["start"], "fresh continuation starting boundary")
        check(w["summary"] == continuation_summary(w), "retained continuation sample summary")
        check([s["n"] for s in w["samples"]] == list(range(len(w["inputs"]) + 1)), "continuation sample indices")
        check(w["freshReplay"] == dict(passed=True, comparedContinuationSnapshots=len(w["samples"]),
              continuationInputs=len(w["inputs"]), intermediateGameplayEdits=0), "stored continuation fresh replay")
        if w["kind"] == "clean":
            source = next(t for t in cont["trials"] if t["kind"] == "clean" and t["policy"] == w["policy"])
            check(w["inputs"] == source["inputs"] and w["summary"] == source["summary"], "selected clean trial correspondence")
        else:
            source = next(b["finalTrail"] for b in cont["beams"] if b["seedIndex"] == w["seedIndex"])
            check(all(w[k] == source[k] for k in source), "selected beam correspondence")
    check(sum(len(w["samples"]) for w in cont["selected"]) == 483, "483 retained fresh continuation snapshots")
    witness = next(w for w in cont["selected"] if w["label"] == "clean-earliest-crawl")
    video_path = ROOT / "instrumentation/jp-ink-handsfree-demo/clean-component-inputs.jsonl"
    video = video_path.read_bytes()
    full = witness["seed"]["fullControllerPrefix"] + witness["inputs"]
    check(len(full) == 656 and video == jsonl(full) and b"\r" not in video, "canonical LF 656 video controls")
    check(sha(video_path) == "939be001b98ad1f92bdbee46ec7b0a0b5d644d09ad05f1931769369e367e4643", "committed video input hash")
    check(b"\r" not in Path(__file__).read_bytes(), "verifier LF rule")
    counts = [0, 0]
    for report in (clean, cont, prefix):
        audit_inputs(report, counts)
    print(json.dumps(dict(passed=True, mode="read-only evidence audit; no new gameplay replay",
          acquisitionSummary=calculated, continuationSummary=totals,
          storedFreshReplayEvidence=dict(acquisitionRuns=2, acquisitionPostInputSnapshots=520,
              acquisitionInitialSnapshots=2, continuationRuns=5, continuationSnapshotsIncludingInitial=483),
          rawSha256=dict(acquisition=sha(ROOT / clean_path), continuation=sha(ROOT / cont_path)),
          canonicalVideoInputs=656, canonicalVideoSha256=sha(video_path),
          retainedButtonRecords=counts[0], retainedMarioInputRecords=counts[1]), indent=2))


if __name__ == "__main__":
    main()
