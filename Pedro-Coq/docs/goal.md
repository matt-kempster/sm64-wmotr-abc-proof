# Goal

Prove, for the pinned US and JP retail programs, that controller-selectable
Mario behavior inside every stock Pedro spot can controllably advance the
global gameplay PRNG, and prove a concrete Tic Tock Clock spinner realization
that can use that control to preserve the required spinner-angle regime.

The desired end result has two layers.

1. **Generic stock claim.** For every stock Pedro spot in the scoped versions,
   exhibit a reachable in-spot state and two legal controller continuations
   that preserve the Pedro configuration while producing different,
   predictable `gRandomSeed16` traces.
2. **TTC spinner claim.** Exhibit a retail-reachable TTC random-setting trace
   that enters a spinner Pedro spot and uses the in-spot RNG control to keep the
   relevant spinner inside the collision-angle interval required for Mario to
   remain in the spot.

The second layer says *angle interval*, not exact mathematical stasis. The
pinned source gives random-mode spinners a nonzero pitch speed of 200 outside
their five-frame post-direction-change pause, so an exact forever-fixed random
spinner would contradict the source.

## Semantic target

The final claims must be stated over executions of the mechanically generated
and properly linked CompCert Clight programs. Geometry must be derived from the
generated TTC macro and collision initializers. Emulator traces may supply
witness discovery and regression evidence, but do not replace the Clight proof.

No theorem may silently extend the result to EU, Shindou, or iQue.
