# Item combinations: a usable handoff after native slide entry

14 November 2026. **Yes: a Koopa shell, Crazy Box and pink Bob-omb Buddy can
jointly produce the useful Ink handoff, with Mario entering the slide
natively.** The selected result now passes on the original Japanese ROM.
It starts with supplied low airborne Mario at Y1810, uses Z once, and has
no subsequent Mario edits. Actor positions are still supplied at several
updates, so a complete no-new-A route remains open.

Here “Mario movement” means entering or retaining the actual crawl/walk/
ground-slide code needed by the producer. A bounce or velocity change alone
does not meet that requirement. “Sideways movement” means the X/Z shove
after the fresh floor cache is prepared. All three species in the successful
test occur in stock SSL Area 1. They are ordinary native actors, not cloned
enemies; stock availability does not establish their delivery.

**Buddy delivery follow-up:** [the movement investigation](ink-buddy-movement.md) confirms that native release can relocate him only after a supplied pickup-reference change. Ordinary contact and the named cloning predecessors do not establish that acquisition. The Buddy position in this handoff therefore remains a grant.

## What the three actors do

The shell supplies the action entry at128. Its accepted mount stops later
interaction handlers that update, so the solution waits until129 for the
Crazy Box and Buddy's distinct pushes. Their geometry puts Mario where the
next update can acquire the low pad floor. Another supplied Box position at
130 pushes him past the pad while leaving that cache unchanged. The stopped
slide alignment then produces low movement/collision and high stored
graphics. At131 the real warp is accepted, the failed low floor query retries
at stored graphics XYZ, and the top becomes the retained platform.

The prior one-update shell-plus-box failures remain correct: this is a
different **multi-update** sequence. The successful producer starts at
Y1830.177978515625 and different X/Z. The old fixed-position integer windows
1741–1801 and21778–32767 were not universal height bounds.

| Update processed | M=C at end, approximately | Stored graphics D.Y | Floor / platform / action |
| --- | --- | --- | --- |
| Supplied before128 | (−1922.44043,1810,−1223.34131) | 1810 | FREEFALL; no ground action is assigned |
| 128: shell contact + Z | (−1920,1799.28699,−1210) | 1799.28699 | Top floor/platform; native BUTT_SLIDE |
| 129: Box + Buddy | (−2140.03198,1830.17798,−1115.02917) | 1799.28699 | Top floor; platform NULL; BUTT_SLIDE |
| 130: later Box position | (−2210.06226,768,−1075.10889) | 1830.17798 | Fresh static floor 768, no platform; ends BUTT_SLIDE_STOP |
| 131: accepted warp and retry | (−2210.06226,1906.03516,−1075.10889) | 1906.03516 | Real warp64; top61 is floor/platform; DISAPPEARED |
| Area 2 arrival | (365.59277,5500,−1096.80261) | — | Useful spawning displacement |

The producer gap is **1062.177978515625**. D denotes `header.gfx.pos`, not
the visibly drawn model. The original-ROM trace verifies end-update fields,
accepted warp/top capture, retention through top deactivation and the actual
arrival. The internal fresh-cache/quarter-step explanation additionally uses
the Wafel trace and source; the ROM observer has no new internal quarter
breakpoint. The [ROM runner, setup ledger and preserved records](../../instrumentation/jp-ink-item-combinations/README.md)
give the exact reproducible inputs and writes.

## Supplied prerequisites and removal checks

The inherited A-off four-pillar prefix uses the disclosed pre-game debug
level select. Shell-box slot32 action4 is supplied before125 to create the
real shell. Before128, the sole Mario cut supplies the position above,
FREEFALL, zero action state/timer, speed20, velocity(0,−16,20) and facing0.
The shell is placed at the same X/Z, Y1800. Input128 is Z with neutral stick;
all subsequent inputs are neutral. There is no held-A dependency.

Before129, Box49 is placed at
`(-1990.710693359375,1799.2869873046875,-1280.710693359375)` and Buddy15 at
`(-2054.455810546875,1799.2869873046875,-1208.867919921875)`.
Before130, Box49 is repositioned to
`(-2117.125244140625,1830.177978515625,-1128.1343994140625)`.
Their dimensions, types, statuses, velocities and behavior remain native.
No floor, ceiling, platform, top phase or warp value is supplied. These
actor cuts are not a demonstrated HOLP throw or continuous delivery history.

The original-JP positive preserves53 observations; the identical comparison
without the Buddy placement preserves55 and stays in Area 1. Its129 result
is (−2059.11011,1867.03088,−1191.78943), still on the top;130 still has a
top floor rather than fresh floor 768. Wafel separately checks removal of
the first Box cut, Buddy cut, later Box cut and initial shell. The same
later recipe fails in each comparison. Without the shell, Z starts ground
pound; neutral ordinary-landing controls also fail this unchanged recipe.
That does not exclude a retuned landing route.

The [native-entry study](ink-item-native-slide-combinations.md) preserves
the exploratory near misses, inverse geometry search, fresh-run checks and
the low-Y refinement. Initial Y1810 and1830 work at the corrected X/Z;
Y1900 fails that selected low-entry recipe. These are tested points, not a
proved minimum or continuous working interval. The originally found high
airborne seed at (−1920,21700,−1210) also works, as do its tested19900/20100
variants with unchanged later actor cuts.

## Two- and three-item controls, including VPUs

Separate [combination tests](ink-item-combinations.md) start Mario already
BUTT_SLIDE at (−1950,Y,−939). They find genuine composed pushes: for selected
shell+Box, Buddy+Box and shell+Box+Buddy placements, removing **any one**
actor loses the useful arrival. Those controls establish contributions of
both/two or all/three actors, while still granting the initial ground action.

| Combination | Stock SSL Area 1? | Action requirement | Tested full outcome |
| --- | --- | --- | --- |
| Shell → Box + Buddy → Box again | Yes, all three | Native slide entry from supplied FREEFALL1810/1830 | Useful handoff; selected1810 positive and no-Buddy comparison checked on original JP |
| Shell + Crazy Box | Yes | Already butt-sliding | Necessary-pair handoff atY25000 and90536; removals fail |
| Buddy + Crazy Box | Yes | Already butt-sliding | Necessary-pair handoff atY25000 and90536; removals fail |
| Shell + Crazy Box + Buddy in one pass | Yes | Already butt-sliding | Necessary-triple handoff atY25000 and90536; removals fail |
| Carry-state Goomba + shell + Box | Yes species; clone history supplied | Starts AIR | Bounce prevents descending shell mount; later pushes run but no productive ground entry |

90536 is25000+65536. The same new necessary-push geometries atY67277 instead
take the ordinary warp: their aliased retry height1741 misses the higher
top faces and selects static floor1280. This does not invalidate the older
default-position67277 handoff. It shows why changing X/Z or the height's
residue requires a new full test. An equivalent terrain alias is not by
itself a demonstrated handoff, and floor 768 is not returned shifted by a
VPU offset.

The high one-pass search screens1,280 supplied-AIR recipes from19 stock
pair/triple families atY25000/67277. Two hundred execute a high target
ground action, but none captures the top in the four-update screen. Selected
full histories and removals are checked independently. These finite
failures coexist with the multi-update supported positive above; they are
not an exhaustive exclusion of item combinations.

## Which local items supply which effect?

The [complete JP source inventory](ink-item-combination-source.md) covers
all31 dispatched types, all32 defined bits,85 grouped handler branches and
12 related callback/automatic mechanisms. Its [machine-readable matrix](ink-item-combination-matrix.json)
marks stock SSL Area 1 sources and absent types. It is reviewed source
evidence, not a Coq certificate for every possible actor history.

| Actor or mechanism | Relevant action effect | Sideways effect | Availability / caveat |
| --- | --- | --- | --- |
| Koopa shell | Mount genuinely creates ground-shell action; Z can enter slide | Failed mount can push; successful mount terminates before later items | Stock shell-box child; creation/delivery remains required |
| Crazy Box, Bob-omb, small box | Ordinary push does not construct ground action | GRABBABLE fallback push | All local; share one interaction type, so not independent same-pass push slots |
| Pink Bob-omb Buddy | Dialogue needs already idle/walking; ordinary contact preserves action | Separate TEXT/NPC push | Local cannon Buddy; native behavior/motion persists |
| Goomba, Pokey part, Klepto | Ordinary bounce retains AIR; damage gives air knockback from AIR | Bounce is Y/velocity, not the needed X/Z shove | Local; Pokey children need initialization; Klepto has a distinct type |
| Fly Guy | Twirl bounce is airborne and terminates the interaction pass | No ordinary fallback X/Z shove | Local; same BOUNCE_TOP type as Goomba/Pokey |
| Palm tree | Pole capture/release follows automatic-action guards | Live tree has a pre-Mario push | Local, but push precedes fresh floor preparation; frozen tree loses callback |
| Tweester / cannon | Twirling exit / cannon shot; cannon firing requires A | Not the post-cache box-style shove | Local; prefix Tweesters have zero live hitbox dimensions until prepared |
| Tox Box / solid surfaces | Can supply real support; visible roll is not proof of angular carry | Terrain/platform mechanics, separate from type table | Local; native Tox roll does not set the angular velocities needed for a vertical PU lever |
| Igloo barrier / bully | Igloo push can precede shell mount; bully effective contact terminates | Real push handlers | Absent from reviewed stock SSL Area 1; not silently imported |

Coins, stars, warps, caps, signs, flames, explosions and every remaining
table entry are classified in the complete inventory. Native callbacks and
solid collision are treated separately rather than inventing a handler for
type0. No arbitrary absent species or interaction-type edit is used in the
runtime combinations.

The [32 clone controls](ink-item-clone-controls.md) match256 fresh-runtime
boundaries. A carry-script Goomba retains its actual BOUNCE_TOP interaction;
it does not become a generic ground-action platform. Its first bounce leaves
INTERACTED set, and the stopped callback does not clear it for the next
overlap. Crazy Box's plain push can remain repeatable, but direct freezing
of HOLDABLE actors is a separately labeled forced diagnostic. No legitimate
fake-pickup lineage or clone delivery is constructed here.

## Route assessment and the next experiment

**Mario side:** native action entry and a usable producer now have a verified
conditional predecessor, including an original-JP low-air witness. The
initial FREEFALL pose is still supplied; the complete controller approach
to it has not been replayed. **Actor side:** the species are local, but their
placements and the later Box relocation remain supplied. **Joined timing:**
the chosen cuts demonstrate the complete accepted warp, retained platform
and useful arrival. Joining them through allowed gameplay remains open.

The first concrete remaining delivery problem is the Box's change of
position between129 and130. A useful next experiment is to replace that
cut with two naturally prepared grabbables: the first overlaps the old
collision position before129, while a second initially misses it and is
encountered only after the first repositioning. Same-type selection and
the four-object collision limit must be checked; this is a proposed test,
not an additional established actor route. A lower-object-count alternative
is to find a real thrown-Box trajectory or a retuned ordinary landing.

This changes the evidence from “tested native entry gives only ordinary
warp” to “selected native entry plus supplied actors gives useful spawning
displacement.” It does not settle either target star or provide a clean
counterexample. All 45 subjective estimates stay unchanged, including
Rank 1 **1–2%** and Ink Rank 2 **<1%**. No new video is made.

## Revisions, tools and proof boundary

The investigation started from pushed proof revision
`08b72af44fbb54aaef3ed7f8be399868ba75db98`; fetch found no newer branch tip.
Decompile HEAD is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` with existing
local modifications preserved. Stock selectors use
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; disabled TAS-hack additions are
excluded. Wafel0.8.5/Python3.9.13 uses JP DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`
and input prefix SHA256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
ROM authentication, emulator versions, exact setup ledgers, source hashes,
full selected traces and rerun commands are preserved in the linked studies.

No new Coq file or lemma was added, and no new Coq build is claimed. Existing
actual-Clight bounce, air-refresh, idle-OFF_FLOOR and pending-death guards
retain their explicit reached-state/storage/numeric hypotheses. In
particular, neither a failed search nor the full source matrix becomes a
global no-route theorem, and the main-universe bounce bound is not silently
extended to raw VPU coordinates. The new progress here is execution
evidence for a concrete predecessor, not a discharged global proof premise.
