# Rank 1: from the final query to the remembered owner

The final platform check is now connected to the actual US/JP query and owner
stores. This is a local execution result. Rank 1's full impossibility claim
remains open, and no clean exception was found in this batch.

## What the game actually checks

Object collision happens before Mario's action. Mario's ordinary behavior then
copies State into the raw Object. Later, after the other object updates and
unloading, `update_mario_platform` makes its own floor query. These are different
checkpoints. The position that touched the warp is not automatically the position
used by this last query.

The last query reads all three coordinates from the raw Mario Object. It saves
that Y, calls the real `find_floor`, and compares the saved Y with the returned
height. With an owned floor, the rounded absolute difference must be less than
four. If it is, both platform references receive that floor's owner. If it is
not, both are cleared. The successful branch does not test whether the owner is
active. An inactive object therefore cannot be dismissed just because it is
inactive; the surface, pointer and remaining object bytes still need analysis.

## The new checked connection

`Rank1FinalPlatformQuery.v` extracts the actual raw-coordinate reads, the resolved
US/JP `find_floor` execution, its returned memory and the following statements.
It also proves that the complete generated body reaches that segment when its
incoming Mario Object is a real non-null pointer.

`Rank1PlatformInstallation.v` proves the successful owner test and both stores.
It joins them to the real rounded distance test and then to the preceding
query. The main theorem is
`r1o_final_query_connects_raw_position_to_owner`, consumed by
`MainTheorem.current_rank1_six_residual_audit_boundary`.

The theorem allows movement, raw collision and display positions to disagree.
It does not grant a frame for `find_floor`: the returned floor pointer, owner
and current Mario Object pointer are read from its actual returned memory.
The saved query Y still comes from before the call. The later owner stores are
proved to preserve every cell disjoint from their two destinations.

The explicit conditions are readable incoming raw coordinates, the actual
global bindings and local floor variable, a completed defined execution, and
ordinary separation of the global platform cell from the local floor cell,
surface and Mario Object storage. The owned-result specialization additionally
uses the floor, owner and Mario pointers actually present after the query.
These conditions do not identify which live floor will be selected. The new
top-level result covers the complete function **body**, starting after local
allocation and ending before local deallocation; it is not a proof of the
surrounding frame, warp, or Area-2 entry.

## What this rules out, and what it does not

The existing exact distance calculation rejects the checked top height
1938.8648681640625 when the saved raw Y is still 768. The new query connection
explains where that saved Y comes from. Merely keeping a high display while the
final raw position stays low cannot make this query remember that top. A floor
query's 78-unit allowance is also not the four-unit platform test.

This does not show that the final raw position must stay low. In the proposed
Ink mechanism, collision can consume the low position first, and a later
ordinary copy can put the raw Object at the useful high position before the
final query. Excluding that sequence by requiring the two samples to agree
would assume away the very mechanism being tested.

## The remaining Rank 1 claim

For every allowed upper-warp history, derive the positions at warp contact,
accepted-warp return and final query; derive the real static/dynamic list
selection and owner at that last query; then follow any retained address through
unloading, reuse and the first Area-2 apply. An exclusion needs those derived
facts to prevent the useful combination. A clean exception needs them to
produce it from the accepted start. The supplied JP setup shows conditional
payoff, while the 2,462-frame clean recording excludes only that recording.

The subjective atlas estimate stays at **1–2%**. This batch narrows the proof
interface; it adds neither an exhaustive controller search nor an all-history
impossibility theorem.

## Validation

Selected audit `build/audit/20260926-210704-9ushw0ao` passed on Coq 8.16.1
and CompCert 3.15 through the existing WSL pipeline and memory limit. It checked
620 registered sources, no proof holes or link problems, and a main import
closure of 448 out of 542 proof modules (94 standalone). The Rank 1 main
boundary, raw-query connection, combined owner connection and two-store theorem
each use seven allowed foundations, with no project-local axioms. These are
mechanical checks of the stated results, not a universal gameplay proof.
