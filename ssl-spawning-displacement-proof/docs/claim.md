# Claim

In JP SM64, a stale `gMarioPlatform` pointer can survive the outside-to-inside
SSL pyramid area transition.  If the old object slot is reused by an area-2
object before the first object update, then
`apply_mario_platform_displacement()` uses the fields currently stored at that
slot.  It does not first validate that the object is active, loaded, a platform,
owned by Mario's current floor, or the same object Mario stood on previously.

For SSL, Spindel is the most interesting target because active Spindel movement
sets both `oVelZ` and `oAngleVelPitch`; the elevator and moving walls are mostly
vertical displacement targets.

The outside pyramid top remains a valid object-owned seed platform in general,
but not via the top-entry warp while standing on it.  The top-entry warp's
hitbox is horizontally centered near the pyramid top, yet vertically spans only
`768..818`; the spinning pyramid-top collision starts at world Y `1281` and
rises from there.
