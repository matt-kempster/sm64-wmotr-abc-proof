# Stock upper-warp and pyramid-top motion

`proofs/StockWarpTopMotion.v` narrows the physical-co-location branch of the
installer search using the generated US and JP Clight units.

The exact stock `bhvWarp` behavior script calls `bhv_warp_loop`.  In both
generated native bodies, that callback does not access or assign the object's
raw X, Y, or Z position slots and has no direct native callee.  The proof ties
that behavior to the exact Area-1 upper-warp LevelScript record.  This is a
source-shape fact; it is not yet a small-step proof that every live execution
of the behavior preserves the position fields.

The stock pyramid top does move.  Its spinning body directly writes X and Y,
but never Z; its initializer, dispatcher, and explosion bodies contain no
direct position assignment.  A finite CompCert binary32 mirror checks every
spinning timer from 0 through 150.  In that mirror X remains between `-2087`
and `-2007`, Y remains at least the home value `1536` and below `1879`, and Z
is always `-1023`.  The timer-131 pose agrees bit-for-bit with the separate
surface fixture.  Once the explicit live Clight refinement is proved, these
bounds would exclude the mirrored stock motion from carrying the top down to
the fixed upper warp; that refinement is not currently inhabited.

This is a generated-source and finite-value certificate, not a whole-program
frame theorem.  It does not exclude a store through an aliased object pointer,
a different behavior moving or cloning the warp or top, corruption of object
identity or allocation epoch, or a live execution that violates the modeled
initial state.  Those cases remain in
`StockTopMotionClightRefinementObligation` and
`StockWarpExternalRelocationAndCloneObligation`; they must be closed before the
physical-co-location installer family is eliminated for retail execution.
