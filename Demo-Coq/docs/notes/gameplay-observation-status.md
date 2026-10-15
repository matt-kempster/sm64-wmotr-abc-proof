# Status of the primary gameplay specification

The full claim remains **OPEN**. The first unchecked checklist item is now
**partially formalized, not complete**. No major unchecked gameplay obligation
has been closed. Work below refines that existing item; it does not add new
checklist goals. Further local input/exit case expansion remains deferred.

## What now observes actual input application

`proofs/DemoExecutionHistory.v` indexes original `Clight.step2` transitions.
Its prefix theorem recovers an ordinary CompCert execution. This record does
not supply permitted initial states or prove boot reachability.

`proofs/DemoGameplayConsumptionObservation.v` observes evaluation of an actual
`Controller` input-field load and its actual silent Clight step. The evaluated
controller address and value are explicit. Continuation certificates identify
the generated object/camera-update calls under `play_mode_normal`,
`basic_update` and the level-script object-update command. An exact selector
checks a real `update_camera` buttonPressed read in both US and JP ASTs.
A constructed readable memory witnesses that local read; it is not a boot or
authentic-demo witness.

The observation requires no title-fade, play-mode, level-equality, P1-alias,
scene-coherence or nonzero-input condition. Mere polling and Start/END
bookkeeping do not qualify as a gameplay application. A real read under a
qualifying update context remains eligible during a fade. We have not proved
that the current root/read-syntax inventory covers every gameplay consumer.

`proofs/DemoInputOriginObservation.v` specifies receipts over the same history:
actual matched loader/DMA/reader/playback calls and returns; table selection
separate from backing DMA occurrence or cache reuse; a record's pre-playback
address; completed controller outputs; and byte preservation to the read.
The pointer after emission may already refer to the next record. Reused buffers
and advanced demo indices therefore do not stand in for sequence identity.
Positive records and EOF-generated terminal input have separate receipts.
Header/payload preservation permits playback's legitimate timer-byte writes.

`proofs/DemoGameplayObservationConnection.v` connects those receipts to the
actual generated camera buttonPressed load and the next actual history step.
The capstone consumes this conditional connection and the observation facts.
It still assumes the receipts, matching site, layout and protected-byte history.
It does not derive them from boot, authenticate their ROM source, or identify
the loaded level. This is partial specification/connection work, not the full
no-desync statement or a new completed gameplay invariant.

## Raw scene observations and source ownership metadata

`DemoGameplaySceneObservation.v` pairs every existing actual controller-read
observation with a total probe of the same memory index. The result distinguishes
missing symbols, unreadable current cells, null/invalid current values,
unavailable typed Area fields and a present raw snapshot. Failure remains an
observation. No source-owner or scene-coherence condition erases the input read.
`DemoAreaSceneObservation.v` checks the generated Area layout and actual field
expressions and transports the observed pointer/fields under exact byte frames.
This establishes raw scene observation, not independently materialized level identity.

`DemoSceneSourceInventory.v` parses the complete seven selected entry initializers
at command boundaries and records all nine declared areas per version, including
CCM2/JRB2. The owner key comes from actual level dispatch, independently of demo
inputs. Geometry and terrain operand words are checked against the authenticated
script/ELF receipt. The [inventory scope](scene-source-inventory.md) separates
raw source relocations from processed geometry, active images and runtime ownership.
The new checker is part of the existing script-images pipeline target.

## Scene construction requires an execution correspondence

The real geometry and terrain builders are now mechanically translated in both
versions. All 44 generated ASTs reproduce twice, and the preceding 40 are byte-identical.
At actual selected builder reads, `DemoSceneAddressBoundary.v` proves that an
integer pointer temporary has no next ordinary Clight step. Keeping the operand
symbolic instead encounters the already proved address-helper bit-shift failure.
The [exact diagnostic](scene-address-boundary.md) is about the proof representation,
not a retail fault or desync. A completed-load receipt over these unrefined
states could have no authentic witness, so no such receipt is asserted.

`DemoSceneAddressView.v` executes the actual numeric helper and explicitly decodes
its result into a supplied block under arithmetic placement bounds. This does
not prove active-image selection, authentic bytes, asset extent, a loader epoch
or either representation-crossing step. Its [scope](scene-address-view.md)
explicitly distinguishes a decoder/load equality (which can be None=None) from
readable data and actual execution. The local one-byte arbitrary-block witness
is arithmetic inhabitation only. A source/native execution correspondence and
an authentic gameplay history remain required.

## Candidate external memory/event policy

`proofs/DemoPermittedExternalSpec.v` constrains actual `Events.external_call`
transitions for a finite SDK/math subset. It carries one controller/DMA phase
through the history, constrains argument/return values and memory effects,
keeps that phase on internal steps, and explicitly rejects builtin invocation
so it cannot bypass the policy. Unknown externals, including omitted game
functions, are rejected. The capstone consumes these policy-structure facts.

This is a **candidate partial policy**, not the permitted retail environment.
It has no initial-state predicate or boot witness. Normal-boot EEPROM long
reads/writes are absent. SDK/private-memory refinement, shared SI/PIF behavior,
queue FIFO/blocking/wakeup, failed calls, input-domain coverage and asynchronous
DMA/scheduling remain unproved. Numerical DMA addresses also require the
symbolic-pointer/native-address bridge. The [policy scope](permitted-external-policy.md)
gives exact effects and limitations. No jointly inhabited authentic gameplay
history satisfying this policy and the origin receipts has been established.

## What still prevents completing the checklist item

- **Loaded-scene provenance:** raw same-index snapshots and source declarations
  are now formalized, but they do not independently identify materialized geometry,
  collision, area and script ownership through real loading. `struct Area`
  has no level field; area slots and segmented addresses are reused. Non-null
  area, area index1, or `gCurrLevelNum` alone is insufficient. Processed geometry
  pointers differ from raw script symbols. CCM/JRB area2 declarations are checked;
  their runtime level/lifetime ownership remains unproved.
- **Complete read and producer coverage:** include the missing Mario and
  object/behavior/helper units, embedded expressions and every reached update
  route. Classify physical input, positive demo records, EOF and derived/P3
  copies from producer history, without hiding a read when classification or
  scene coherence fails. Current origin transport covers P1 fields only.
- **Permitted starts and adequate externals:** specify native boot, initialized
  save/EEPROM states, scheduler and hardware events without assuming stream/level
  agreement; justify that the specification covers intended normal histories.
  The generated inventory has no complete linked ordinary `main`/boot program.
- **Authenticity and non-vacuity:** connect actual ROM bytes, active images,
  numerical/segmented address behavior and SDK calls, then exhibit an authentic
  boot-to-gameplay history and establish the intended-domain coverage.

The original `DemoGameplayBoundary.v:demo_normal_update_observation` remains
an unused entry-state predicate. The new actual-read connection is distinct
from it. A green component build does not close the missing items above.

## Source evidence that narrows the remaining invariant

The [title-fade source chain](demo-title-fade-source-chain.md) records actual
input-before-interpreter ordering, SLEEP/CLEAR_LEVEL and callback guards against
the straightforward next-demo/old-scene candidate. It is source review, not a
Coq callback-closure or boot proof. The [ordinary-destination writer audit](demo-ordinary-destination-source-audit.md)
finds only `initiate_warp` as a direct nonzero destination producer; its delayed
calls are guarded by no-demo, with painting and paused-exit cases separate.
This points to a mutual zero-destination/not-paused preservation invariant,
rather than requiring trajectory/RNG enumeration for that specific route.
Indirect/assembly/external writes and the real memory/initialization invariant
remain unproved. No new retail trial or reachable counterexample is claimed.

## Intended full statement, still unfinished

For every permitted real execution, whenever an authentic demo record's
emitted inputs are actually applied by a gameplay consumer, the independently
identified materialized scene belongs to that demo's header level. A disproof
uses the same boundary/provenance with unequal levels. The full statement,
its coverage and its permitted normal-boot environment are not yet formalized
at the required scope. The checklist item stays unchecked.
