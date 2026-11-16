# Cap in hand really does preserve HOLP: five conditional controls

15 November 2026. This is distinct from an ordinary hands-free action that
retains a held pointer. A single initial flags grant clears CAP_ON_HEAD0x10
and sets CAP_IN_HAND0x20. Native updates then select handState3 (holding cap),
whose Mario geometry branch omits the held-object node. No hand state, grab
position, rendering flag or HOLP is patched on later updates.

All four cap cases retain the initial remote HOLP throughout AIR_THROW's
windup and perform an actual native Box throw on its fourth update. The
paired ordinary control overwrites HOLP and throws elsewhere. Thus this
specific rendering state addresses the preceding HOLP-overwrite obstruction.
Its acquisition remains explicitly supplied; it is not established through
controller gameplay here.

The four cap cases start at `(phase,Y)` `(120,1930),(120,2000),(123,1930),
`(124,2000)`. The ordinary control uses `(120,1930)`. All retain the actual
remotely thrown shell atY1800, supplied native free91 Bob, initial Box carry
HOLD_FREEFALL, zero forward speed, velocity−16, yaw0 and HOLP
`(-2102.720703125,1920,-1151.5618896484375)`. B starts AIR_THROW and fresh Z
is scheduled for128. Only controller inputs follow the initial setup, A off.

In the matched1930 case the cap version's phase123 throw leaves the Box at
`(-2102.720703125,1937.3912353515625,-1119.5618896484375)` with forward40.
The initial HOLP persists exactly. Without the cap grant, the Box instead
ends at `(-1943.83251953125,1978.531494140625,-1262.09423828125)`.
Both are post-callback observations, not immediate throw-assignment values.

None of the five cases captures the top or gives useful displacement. The
phase120/Y1930 case mounts too early on124, then becomes RIDING_SHELL_FALL125
before Z128. The123/Y1930 case mounts127, Z128 creates a slide but at the wrong
position. The124/Y2000 case is still AIR_THROW on128. In addition, a thrown
Box has forward velocity and travels away from the supplied release origin;
placing it initially at the former stationary-drop origin is not a final
shove-position solution. These observations motivate the separately bounded
Hat-in-Hand placement search, rather than invalidating the HOLP result.

All five45-update continuations were independently reconstructed twice
(225 boundaries per reconstruction). No new original-ROM replay or Coq
theorem is claimed. The exact cap flag edit, derived hand state, actual Box
release and flight, Mario M/C/G/HOLP and collision/cache/platform fields are
in `cap-results.json.gz`. `cap-control.py --verify` reproduces the archive.
Source/runtime revisions match `README.md`; `cap-verification.json` binds
this control's bytes and the relevant hand-model/renderer source.
