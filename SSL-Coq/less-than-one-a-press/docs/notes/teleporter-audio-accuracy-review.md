# Audio proof accuracy review — 21 October 2026

Follow-up: the [subsequent seven-query rerun](teleporter-wrong-warp.md#assumption-query-timeout-follow-up-21-october-2026)
passes without proof, pipeline or limit changes. The initial failed audit below
remains a historical result; its timeout cause was not identified.

The reviewed proof source is commit `a1ff8b162e1d9816ac2b102e395047349358ed81`.
The external-call analysis is substantially correct: it identifies an
applicability gap, not an invalid Coq proof. No proof file or selected program
semantics was changed for this review.

`TeleporterAudioFrame` proves a conditional contract for the actual generated
five-function US/JP internal audio closure. `TAFAudioResolution` requires all
five symbols to resolve to their exact internal bodies. The selected 38-unit
program instead contains one `External (EF_external ...)` sound-stop definition;
the other four functions and three named audio globals are absent. The US
viewport repair retains the External constructor. Consequently that resolution
premise cannot hold in the current selected environment. Specializing the
conditional theorem there cannot supply an actual external-call frame.

This does not invalidate the theorem: it applies to environments satisfying its
stated internal bindings. `current_bobomb_source_memory_boundary` conjoins this
conditional contract with other contracts; it neither establishes that premise
for the selected program nor concludes selected-call audio preservation.
Registration, import reachability and successful assumption audits do not add
that semantic connection. The existing Main comments already identify this gap.

The unload-order description is accurate in both generated versions: deactivate,
clear prevObj, clear throwMatrix, call sound-stop on cameraToObject, then perform
the graph operations and deallocation. `tol_selected_unload_resolves` resolves
unload_object itself, not its sound-stop callee. The needed frame must concern
the actual selected external call and its reached argument, pre/post memories
and gObjectPool block. Empty trace is a separate condition.

The CompCert argument is also sound at the stated scope. In installed CompCert
3.15 `common/Events.v`, `external_call` maps EF_external to the unspecified
`external_functions_sem`, constrained by `extcall_properties`.
`extcall_free_ok` proves those properties for the same pointer-to-void signature.
Its pointer case uses a size header load and Mem.free, returns Vundef and has E0
trace. With the stated freeable-range and header conditions it can remove
permissions from a previously readable pool cell. Thus generic external-call
properties and silence alone do not entail the requested frame. This is a
metatheoretic alternative interpretation, not a claim about stock audio or an
actual reached unload. No new Coq countermodel theorem was added in this review.
Simply changing the declaration to Internal would change the selected semantics;
a real external-effect specification or a justified correspondence/refinement is
still needed. Assuming the desired frame would retain the original obligation.

The validation qualifications matter. A clean pinned checkout has 679 sources;
the recorded October 19 audit counted 681 because it included two pre-existing
untracked working-tree modules. Those figures describe different scopes and are
consistent. Both salvaged source hashes match the recorded audit. The earlier
reviewer's missing-toolchain statement describes that review environment, not
this machine's Ubuntu WSL switch.

Here the existing seven-query pipeline audit `20261021-102643-rswo_fez` was rerun using
sm64-item-proof, Coq 8.16.1 and CompCert 3.15, with the established 6815744-KB cap
and 600/240-second time limits. The fresh full audit is not a PASS: MainTheorem assumption queries that time out at the established 240-second limit are recorded as failures. The salvaged AudioFrame, PoolPartition and separated-cell assumption queries pass; the complete October 19 PASS remains historical evidence, not a fresh result.
The [record](teleporter-audio-accuracy-review.json) preserves each check's actual outcome. This review does not
turn the source-level binding analysis into a newly proved selected bridge.
The [validation record](teleporter-audio-accuracy-review.json) records the pinned census and audit scope.
All proof files, selected semantics, raw archives, 45 route estimates and overall
gameplay verdicts remain unchanged. No VC analysis was resumed.
