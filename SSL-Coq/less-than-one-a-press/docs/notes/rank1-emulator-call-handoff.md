# Rank 1: the first emulator call handoff

Follow-up: the [controller-grounded candidate loop](rank1-candidate-feedback.md)
now connects new input proposals to reached floor calls and feeds their results
back into the target query. This earlier report records the separate first
call-adapter experiment; its arbitrary-memory query remains incomplete.

27 September 2026. **The first scoped call bridge works. The requested
one-second exhaustive backward search is still incomplete.** No Coq theorem,
new gameplay trajectory, Ink witness or impossibility result is added.

## What “pending obligation” means

It means “we still owe this call an answer.” The search records the call,
its arguments, the state before it, and the condition needed afterward. It
can continue forming a proposed predecessor while keeping this unanswered
piece visible. That proposal is not an execution until the missing piece is
checked. Pending does not mean impossible, harmless, or finished.

For example, the retail controller-acquisition call changes its request
buffer; the later pad-read call supplies the controller data. Pretending
either is a no-op would be wrong. A matching emulator observation can answer
one concrete case. A different controller history or unmatched state remains
open. An empty cache is not evidence against a route.

## What was implemented

The new read-only [emulator observer](../../instrumentation/rank1-emulator-handoff/probe.c)
records exact entries and returns for osContStartReadData and
osContGetReadData. It also records the live native-call operand and receiving
Object slot, and the completed platform-retention checkpoint. It uses the
authenticated retail JP ROM and the existing controller-only replay from the
accepted level-select start. It neither writes gameplay memory nor supplies
a gap, pose, action, floor or RNG state. The old runner's directory name
contains “wafel”; this capture executes Mupen64Plus, not Wafel.

The [oracle adapter](../../instrumentation/rank1-backward-search/emulator_oracle.py)
pairs entries and returns, checks their PCs and stack pointers, and requires
an exact capture/event/version identity before answering. The
[hybrid engine](../../instrumentation/rank1-backward-search/hybrid_engine.py)
keeps the actual generated caller and carries its required postcondition
backward through the reply. A conflicting observed output is rejected.
Wrong versions, wrong events and unknown states get no reply.

The byte adapter covers the controller pads and the three position vectors.
It maps their explicit retail and generated layouts. OS queue pointers and
device state are recorded where available but are not silently relocated.
All memory outside the mapped footprint remains unconstrained. The anchor
identifies an experiment; agreement on these few bytes does not prove that
an arbitrary solver state is that experiment. This is a partial observation
bridge, not a full snapshot importer or a proved Clight/retail refinement.

The search now retains external and unmatched indirect calls as named
relations with unknown effects. It does not assume memory or checkpoint-count
preservation. Guarded branches expand selected actual source callbacks and
keep the other live-pointer alternatives pending. An optional lazy mode
builds the controller/scheduler/retention portion first and marks omitted
calls as obligations. Its satisfiable answers are explicitly labelled
unverified proposals. An opaque call cannot satisfy an impossible target.

Two interpreter repairs support that work: aggregate copies read the
original bytes and reject partial overlap, and temporary-initialization
flags exclude undefined branches without assuming a stock switch value.
These repairs do not add gameplay assumptions or change generated source.

## The one-second experiment

The clean JP replay window covers polls 2651–2680. The observer sees exactly
30 completed retention checks, with the top timer advancing from 102 through
131. This chooses a real timing window; it does not supply the desired
retention outcome. Mario's three observed Y values remain signed zero, and
both remembered platform fields remain null. The checked top is not retained
in this known replay.

| Check | Result | What it means |
| --- | --- | --- |
| Controller call entries and returns | 60 paired, none missing | Thirty acquisition calls and thirty pad-read calls were observed at exact boundaries. |
| Generated caller queries using those replies | 60 accepted; 60 conflicting replies rejected | The scoped backward call bridge consumes the emulator evidence. These are separate call cases, not a reversed complete second. |
| Actual call effects | Request buffer changes in all 30 acquisitions; pads change in 20 reads | The calls cannot both be replaced by blanket no-ops. No position change was observed in the mapped footprint of these cases. |
| Live native dispatch | 3,628 invocations; 36 generated body names; no unmapped target | This is a finite receiver/operand inventory. The callee effects and all other histories are not thereby proved. |
| Existing baseline receipts | Passed unchanged | The new observer reproduces the earlier clean replay and its failed installation result. |
| Application regressions | 50-test suite passed, then one additional loop-definedness test passed | Interpreter and adapter checks; no new Coq result. |

The broader 30-update source-expansion attempt reached its 180-second limit.
Its last saved progress had 203 function definitions, 20,760 statements and
1,072 pending call sites, after about 160 seconds. These are construction
counts, not executed gameplay updates or distinct controller sequences.

The lazy 30-update query does build and returns SAT in about five seconds,
with 14 defined source bodies and 64 pending call sites. SAT here only means
that the relaxed formula allows a proposal. Its unknown calls can still
provide unvalidated memory and checkpoint effects. **No exact replay anchor
was derived for those symbolic calls, and zero emulator replies were applied
to that broad query.** Its model is not a controller trajectory. The 60
successful anchored call checks above must not be conflated with this result.

## What remains, precisely

The next missing connection is between a particular solver-proposed call
occurrence and an executable emulator state. Shared relations currently hide
intermediate occurrences inside existential formulas. We must expose a
concrete occurrence, join it to a controller-reached replay state with its
relevant history, and consume a sufficiently complete reply for the next
backward condition. Naming a recorded event is enough for the integration
test, but does not derive that join for an arbitrary predecessor.

Then the remaining calls on that proposed path must be checked or expanded
as needed. Unmatched alternatives must stay in the search frontier. The
emulator does not invert unknown state automatically, and the partial reply
does not establish a whole-memory frame. No extra hardware proof is being
required just to test an individual gameplay candidate.

Consequently, there is still no complete-update coverage rate from which to
price three or five seconds. No case moves to Already proved. Rank 1 remains
open at its unchanged subjective 1–2%; all 45 atlas estimates are unchanged.

## Reproduction and evidence

See the [runner instructions](../../instrumentation/rank1-emulator-handoff/README.md)
and [compact receipt](../../instrumentation/rank1-emulator-handoff/report.json).
Raw capture, full per-call checks, query and model stay in the ignored build
directory. The ROM and conversation exports are not committed or published.
The code uses the existing pinned source revision
9921382a68bb0c865e5e45eb594d9c64db59b1af and actual generated JP Clight.
US runtime delegation has not been tested and cannot use the JP replies.
