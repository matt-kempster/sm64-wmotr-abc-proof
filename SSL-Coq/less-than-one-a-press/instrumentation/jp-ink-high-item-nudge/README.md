# Original JP: two conditional high-rider handoffs

Mode1 uses small box23 at H25000; mode2 uses ordinary black Bob-omb39 at H67277. Both complete useful Area2 arrival `(365.5927734375,5500,-1096.8026123046875)` after25 high-suffix updates.

The low shell mount is native after a disclosed low FREEFALL/shell setup. High M/C/gfx XYZ and actor XYZ are then supplied at stored top timer130, with Z; no action or pointer is written at that high cut. The setup remains conditional, not a gameplay route. Exactly36 writes per run are checked against address/width/time allowlists. All A counters are zero.

Run in Ubuntu24.04 WSL from `SSL-Coq/less-than-one-a-press`, with fresh output directories:

```sh
bash instrumentation/jp-ink-high-item-nudge/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/NEW-small 1
bash instrumentation/jp-ink-high-item-nudge/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/NEW-bobomb 2
```

The runner authenticates the original JP ROM and uses the established Mupen64Plus2.5.9 interpreter/Rice/HLE RSP pipeline. No ROM patch is applied. New probe/checker code is based on `jp-ink-item-combinations`; the mode12 prefix is credited to `jp-clean-gap-search` and retains its debug level-selection startup grant.

Each record has53 camera observations. Camera steps28/29 are absent during transition, so ROM platform retention is sampled; continuous retention is separately checked in Wafel. The comparison has24 available boundaries ×37 scalar fields/components. Bob-omb matches all888 comparisons. Small box has one earlier low-mount subtype mismatch (ROM2 vs Wafel0), and all producer-through-arrival fields match. The checker reports the real strict mismatch while validating the useful outcome and disclosed writes. Neither result is full-state equivalence.

Recheck archived evidence without ROM/emulator:

```sh
python3 instrumentation/jp-ink-high-item-nudge/check.py instrumentation/jp-ink-high-item-nudge/records/small-25000 1 --archived
python3 instrumentation/jp-ink-high-item-nudge/check.py instrumentation/jp-ink-high-item-nudge/records/bobomb-67277 2 --archived
```

`expected.json.gz` freezes the two Wafel controls and source-archive hash. The hash `fedffccfb1b48ade51b8617fde054dfd0969d0d830df48324418efc28146c1e1` matches the current corrected `ink-high-item-nudge/results.json.gz`; freezing occurred after the supplied-slide metadata rewrite. `prepare_expected.py` confirms the selected riding records remain equal if rerun against the current Wafel archive; it does not simulate new histories. `archive.py` preserves text and source snapshots only. No ROM, compiled plugin or video is included. Detailed setup, timing, comparison limits and versions are in `docs/notes/ink-high-item-nudge-rom.md`.
