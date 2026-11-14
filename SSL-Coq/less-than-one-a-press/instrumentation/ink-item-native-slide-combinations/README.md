# Native slide plus Buddy/box combinations

The [report](../../docs/notes/ink-item-native-slide-combinations.md) gives the verdict and exact low-air witness. The [durable receipt](../../docs/notes/ink-item-native-slide-combinations-receipt.json) packages selected full histories, all positive inverse-search recipes, menus and raw hashes. This directory owns Wafel experiments. Original-ROM validation is maintained separately in [jp-ink-item-combinations](../jp-ink-item-combinations/README.md).

Run from `SSL-Coq/less-than-one-a-press`, using the existing local embedded Python. Every output uses exclusive creation: choose fresh filenames rather than overwriting earlier data.

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-item-native-slide-combinations/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-item-native-slide-combinations-recheck.json
& build/wafel-pilot/python/python.exe instrumentation/ink-item-native-slide-combinations/refine.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-item-native-slide-refine-recheck.json
& build/wafel-pilot/python/python.exe instrumentation/ink-item-native-slide-combinations/inverse.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-item-native-slide-inverse-recheck.json
& build/wafel-pilot/python/python.exe instrumentation/ink-item-native-slide-combinations/controls.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-item-native-slide-inverse-recheck.json build/wafel-pilot/ink-item-native-slide-controls-recheck.json
& build/wafel-pilot/python/python.exe instrumentation/ink-item-native-slide-combinations/low_entry.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-item-native-slide-controls-recheck.json build/wafel-pilot/ink-item-native-slide-low-entry-recheck.json
& build/wafel-pilot/python/python.exe instrumentation/ink-item-native-slide-combinations/no_shell.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-item-native-slide-low-entry-recheck.json build/wafel-pilot/ink-item-native-slide-no-shell-recheck.json
```

`package.py OUTPUT` packages the six canonical `*-20261114.json` files listed in its `NAMES` table. It does not rerun the game. The durable receipt's original generation command was:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-item-native-slide-combinations/package.py docs/notes/ink-item-native-slide-combinations-receipt.json
```

`search.py` supplies a single airborne Mario pose and a native shell placement through the existing `make_seed`; Z creates the ground action natively. It subsequently permits only controller writes and XYZ changes to the existing Crazy Box, Buddy, and optional shell. The low positive uses no later shell cut. `no_shell.py` explicitly omits the initial shell relocation and records that shell's untouched remote position. No script writes ground actions, floor/cache/platform pointers, object interaction types/radii/status, warp state, or post-initializer Mario position.

The optional inverse radial computation only proposes actor positions. Actual collision registration, wall correction, floor selection, action changes, capture, platform retention and Area 2 arrival all run in the native game. All complete selected histories compare equal with a second reconstruction from the input prefix. There is no RNG reseeding; the input prefix and ordinary native RNG evolution determine each saved state.

The first attempted `refine.py` launch failed before game execution because embedded Python did not include the script directory on `sys.path`; the script now adds it explicitly, and the recorded canonical run passed. The large inverse-search output remains in `build/wafel-pilot` (88,188,709 bytes); the compact durable package retains its SHA256 and every positive recipe without duplicating all 338 complete histories.
