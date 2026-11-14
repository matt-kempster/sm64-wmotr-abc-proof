# Upper-face push predecessors

This finite Wafel JP experiment asks whether a late actor shove can convert a
state supported by the spinning top into an unsupported ground action, then
produce the fresh low-pad cache and useful handoff on the following update.
It differs from walking off an edge: a stopped quarter can keep the old floor
cache and reach alignment after an actor has already displaced Mario.

Each initial cut supplies Mario's synchronized M/C/D position, named ground
action, action state/timer, facing, forward/horizontal/slide velocity and slide
yaw. Y is calculated from the actual old upper-face query plane at the supplied
X/Z. This is a supplied real-surface seed, **not** an established controller
history or a native landing preparation. It does not write floor/cache,
platform, top, timer, collision surfaces or RNG. Actor XYZ is supplied once at
the cut. The shell variant additionally supplies shell-box action 4 at phase
127 and allows two native updates to spawn a real shell. After the cut a write
guard permits controller-pad fields only. All inputs and native A flags are
checked A-off.

Use the project's existing Windows Wafel Python: the pinned native runtime is
a Windows DLL. Original-ROM emulator validation belongs in Ubuntu-24.04. From
`SSL-Coq/less-than-one-a-press`, with fresh output names:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/ink-mario-entry-search/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/ink-mario-entry-search/direct-NEW.json --direct
& ./build/wafel-pilot/python/python.exe instrumentation/ink-mario-entry-search/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/ink-mario-entry-search/two-NEW.json --direct --two
& ./build/wafel-pilot/python/python.exe instrumentation/ink-mario-entry-search/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/ink-mario-entry-search/swapped-NEW.json --direct --two --swap
& ./build/wafel-pilot/python/python.exe instrumentation/ink-mario-entry-search/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/ink-mario-entry-search/shell-NEW.json --direct --two --shell
& ./build/wafel-pilot/python/python.exe instrumentation/ink-mario-entry-search/verify.py build/ink-mario-entry-search/direct-NEW.json build/ink-mario-entry-search/two-NEW.json build/ink-mario-entry-search/swapped-NEW.json build/ink-mario-entry-search/shell-NEW.json --output build/ink-mario-entry-search/receipt-NEW.json
```

The code contains the exact finite menus and rounding. Each accepted recipe
runs three updates (129, 130, 131). Eight ranked examples per menu are followed
through their Area-2 transition or a 32-update cap and replayed both from the
saved root and a separately reconstructed root. The guard, ledger, every input,
M/C/D, native action, cache, platform, collision list, primary Crazy Box (slot
49) state and action/
movement event projection are retained. Wafel's `_placeholder` event field is
compared but is **not interpreted as a quarter-step result**.

The recipe `push` is a position-proposal parameter, not a measurement of the
native displacement. In particular, the swapped Bob-omb menu uses 72 in its
proposal geometry; the native Bob-omb's actual hitbox radius is 65, and its
combined push radius with Mario and padding is 97. The native execution, not
the proposal formula, determines the result. Secondary-actor state is not
fully logged by the four broad menus; the explicit XYZ edits and collision
lists are retained.

The search ranks immediate top capture first, then a large gap with low cache,
then proximity to the old useful X/Z. A finite negative result does not rule
out other speeds, phases, actor motion, simultaneous interactions or histories.
The unshifted direct menu supersedes an exploratory inverse-carry pilot: after
the selected push the native platform re-query clears the platform reference,
so assuming a next-frame rotation was incorrect. Historical pilot reports stay
in ignored build output and are excluded from final coverage.

The bounded contact-timing refinement varies the first box's Y and a second
Bob-omb's X/Y from the closest retained seed. It records the Bob-omb's native
state as well as the primary box. It has 432 candidates, five separately
replayed full histories, and no successful top capture:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/ink-mario-entry-search/contact_timing.py build/ink-mario-entry-search/contact-NEW.json
```

The permanent reports are `docs/notes/ink-mario-entry-runtime.md`,
`ink-mario-entry-runtime-receipt.json`, and `ink-mario-entry-contact-receipt.json`.
The newer native landing preparation is a separate experiment documented in
`docs/notes/ink-supported-slide-preparation.md`.
