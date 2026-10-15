# Status of the primary gameplay specification

The full claim remains **OPEN**. The first unchecked checklist item is not
formalized to the required scope. Recent input and exit extensions discharge
local execution subcases; they do not close this item or the other major
unchecked gameplay obligations. Further local case expansion is deferred while
the actual observation and admissible-execution specification take priority.

## What currently exists

`proofs/DemoGameplayBoundary.v` defines `demo_normal_update_observation` as a
`Callstate` of generated `play_mode_normal` plus loads of `gCurrDemoInput` and
`gCurrLevelNum`. No proof or capstone clause consumes this predicate. Its own
comment explicitly omits initialized area, authentic stream and consumed-record
provenance. It is a preliminary entry-state observation, not the requested
loaded-gameplay/input-application boundary.

The input proofs execute actual playback and controller processing under
explicit entry resources. They identify locally emitted controller values.
They do not carry an authenticated load/record receipt through the interpreter
and object dispatch to the instant Mario uses those values. No project
definition yet specifies the full permitted normal-boot states and external
memory/event histories.

## What the real source requires the observation to capture

One concrete pinned-source gameplay button application is in
`src/game/mario.c:update_mario_button_inputs`, beginning with
`m->controller->buttonPressed`; joystick application reads the controller's
processed axes and magnitude. `execute_mario_action` calls `update_mario_inputs`,
which calls these routines. Mario's translation unit is not among the current
generated units, so this actual read has no generated observation hook yet.
The object/behavior dispatch and surface-loading units also remain outside
the current generated inventory. Mario's read is a useful witness, not a
complete consumption-site definition: camera and object helpers also read
gameplay controller fields. A checked set of actual applications or a proved
dominating update observation must cover those uses too.

Observing only `play_mode_normal` would miss other actual update routes:
`basic_update` transition callbacks and the level-script object-update command
can also reach object/Mario processing. Conversely, a title-fade label alone
must not exclude an observation. If recorded inputs really reach Mario in an
old loaded scene during a fade, that is an eligible mismatch. Only polling or
bookkeeping without actual gameplay application can be excluded; absence of
such application must be established from the real execution.

Sequence provenance must identify the authenticated table entry and load
occurrence. The same demo buffer is reused for later sequences, and the global
demo index is incremented immediately after loading. At timer1 the current
record pointer advances before Mario applies the emitted values. Buffer block,
current index and current pointer alone therefore do not identify the record
whose inputs were applied.

Loaded-level identity must independently follow actual area/script/geometry
and collision loading. `struct Area` has no level-number field, and area slots
are reused across levels. A non-null `gCurrentArea`, area index1, or a scalar
`gCurrLevelNum` comparison is insufficient. The real area commands install
processed geometry and relocated terrain pointers; `load_area` materializes
terrain and spawns objects. Shared segmented addresses require active-image
provenance. Later areas within CCM or JRB still belong to the same level.

## Initial states and external behavior are also unspecified

The current generated units do not supply a complete linked boot program or
a normal-boot execution witness. Their selected `main` atom does not have a
matching ordinary `int main(void)` definition. The real source starts through
native boot and OS-created threads before `thread5_game_loop`; an arbitrary
memory at that game-thread entry is only a conditional starting point.
Existing metadata-normalization lemmas preserve initial states if they exist;
they do not establish such a boot state or a gameplay execution.

CompCert's general external-call assumptions do not supply the N64 hardware
contract. Restricting observable event names/values alone does not restrict
silent DMA or controller-memory writes. The specification must also constrain
the exact named calls' return values, memory footprints and scheduling, and
justify a nonempty permitted implementation. Omitted game functions such as
object updates or terrain loading must not be treated as arbitrary hardware
actions. ROM/version, initialized memory/address image and the permitted
retail save/EEPROM states must be specified without assuming the desired
demo/level agreement.

## Intended full statement, still unformalized

For every permitted real execution, whenever an authentic demo record's
emitted inputs are actually applied by a gameplay consumer, the independently identified
materialized gameplay scene belongs to that demo's header level. A disproof
uses the same observation and provenance with unequal levels.

The next work is to express that statement over real CompCert states and
transitions, define the permitted start and external memory/event relation,
and require a non-vacuous authentic gameplay witness. Stream provenance and
loaded-scene provenance must not assume their levels equal. This is the
existing first checklist obligation; it is not counted as completed by this
status note, by another local execution lemma, or by a module-count increase.

Coverage is part of the obligation: missing provenance must not make a real
gameplay input read disappear from the observations. In particular, do not require
Mario/current-area/terrain agreement as an eligibility premise and thereby
exclude a possible incoherent execution. Classify actual demo-derived reads
and establish the necessary scene coherence. EOF-generated neutral/END input
and ordinary record-derived input also need distinct origins. Authentication
must account for the timer bytes that playback legitimately mutates.
