# Original-JP hands-free and handoff recordings

These are three independent recordings of the authenticated retail JP ROM,
using Mupen64Plus 2.5.9, its interpreter, Rice 2.5.9, HLE RSP and dummy audio.
All use the stock camera and the established pre-entry debug level-select
setup (`--cheats 6`). The videos are silent native game frames; the separate
commentary renderer adds explanatory text. No generated imagery is used.

The clean chapter establishes a controller-produced **low** component after
that accepted entry: pickup, hands-free sliding, release, then crawl at Y=38.
It does not complete the pyramid route. The other chapters deliberately
contain supplied state, and are not continuations of the clean chapter.

| Chapter | Game-data edits | Result |
| --- | --- | --- |
| `run-clean.sh` | None after accepted entry | Box47 acquired, retained in an ordinary slide action, dropped; box disappears before crawl at Y=38. |
| `run.sh` | One M/C/D position cut and box49 XYZ cut: twelve words | Controller-produced dive picks up the positioned box, then enters hands-free butt sliding. The recorded continuation dies in quicksand. |
| `run-handoff.sh` | Crawl action at stored timer 129; twelve position words at stored timer 130 | A native update establishes the 100-unit crawl hitbox before contact; box push produces the 973-unit split and subsequent top capture, then Area 2 arrival outside the elevator footprint. |

All three use zero A inputs. “Hands-free” means that a normal, non-holding
action retains `heldObj`; it does not mean the rendered hands must look empty.
The hands-free chapters do not install Ink. The handoff chapter still supplies
its high Mario and box positions and an already-established crawl.

## Reproduction

Run in Ubuntu-24.04 from `SSL-Coq/less-than-one-a-press`. Every output directory
must be fresh. ROM bytes are neither copied into the repository nor published.

```sh
bash instrumentation/jp-ink-handsfree-demo/run-clean.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 \
  build/jp-ink-clean-handsfree-crawl-demo-REPLAY \
  instrumentation/jp-ink-handsfree-demo/clean-component-inputs.jsonl

bash instrumentation/jp-ink-handsfree-demo/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 \
  build/jp-ink-handsfree-demo-REPLAY \
  docs/notes/ink-box-handsfree-receipt.json

bash instrumentation/jp-ink-handsfree-demo/run-handoff.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 \
  build/jp-ink-handoff-demo-REPLAY
```

The original supplied-position run used the complete checked raw record
`build/wafel-pilot/ink-box-handsfree-20261112-checked.json`; its selected 6 + 140
controls and samples also appear in the committed hands-free receipt above.
`check.py` validates that chapter. `check-handoff.py OUTPUT` validates the
separate handoff. For the already recorded clean witness comparison:

```sh
python3 instrumentation/jp-ink-handsfree-demo/check-clean.py \
  build/jp-ink-clean-handsfree-crawl-demo-20261112-a \
  build/wafel-pilot/ink-clean-handsfree-20261112-final.json \
  build/wafel-pilot/clean-handsfree-continuation-probe.json
```

The raw comparison inputs are named and hashed in the native receipt. The
clean controller JSONL is committed here, so native replay itself does not
depend on those ignored comparison records. The clean chapter follows all 656
inputs; screenshots begin around its 350-input branch point.
`run-clean.sh` compares a fresh recording to the committed original native
trace using `check-replay.py`; this check works after cloning the repository.
The separate Wafel comparison above requires its named local raw records.
The committed JSONL uses canonical LF endings; the original captured JSONL
used CRLF. Their parsed controller sequences are identical, while their byte
hashes differ. Each is hashed separately in the provenance and native receipt.

## Results and frame alignment

The captured output directories are `build/jp-ink-clean-handsfree-crawl-demo-20261112-a`,
`build/jp-ink-handsfree-demo-20261112-a`, and
`build/jp-ink-handoff-demo-20261112-a`. Their `receipt.json` files are copied
under `docs/media/ink-handsfree-native/`, with their instrumentation traces.

The clean chapter matches 305 distinct Wafel snapshots in the logged
projection; the supplied-position chapter matches 146. Matching uses binary32
values recovered from nine-significant-digit logs for M/C/D, boxXYZ and
floorY, plus action, held slot, area and top action/timer. It is not a
whole-memory equivalence check. Wafel's after-advance global timer is two
greater than this native camera-callback timer in all compared samples;
absolute global timers are not silently treated as equal.

Rice screenshots contain the preceding completed framebuffer. Accordingly:

| Native PNG index | Clean chapter: completed total input | Milestone |
| --- | --- | --- |
|75|424|Native box pickup|
|86|435|Dive-picking-up action|
|87|436|Hands-free stomach slide, box 47 retained|
|166|515|Native drop at Y=38|
|167|516|Box inactive|
|179|528|First crawl at Y=38|

For clean PNG index `n`, the completed input is `349+n`. For the supplied
hands-free chapter, PNG index `n` is completed chapter input `n`; index 0 is the
preceding frame. Its position cut precedes input 7, followed by pickup at 7,
dive-picking-up at 24, hands-free holding at 25, and quicksand death at 86.

For the separate handoff, crawl is supplied before input 5 and positions
before input 6. The split and top capture are completed inputs 6 and 7,
shown in PNGs 6 and 7. Inputs 28 and 29 have no camera callback in the trace.
The first Area 2 state is completed input 30. The callback on input 31 requests
PNG 28, which captures that preceding input-30 framebuffer. From PNG 28 on,
the completed input is `n+2` in the recorded callback sequence. The original
video's Area 2 pause uses PNG 30, a later frame of the wipe. The archived
receipt's simplified PNG mapping omits this transition offset. The final
CLI-requested PNG in each folder is an extra later image.

All three final-source probe builds were byte-identical to the captured
`probe.so` binaries. The native receipts pin the ROM, logs, traces and every
PNG. The combined provenance file also pins the source and probe binaries.
