# Goal

Prove the core JP spawning displacement mechanism for Super Mario 64 SSL:

1. `VERSION_JP` area spawning does not clear `gMarioPlatform`.
2. `apply_mario_platform_displacement()` trusts the non-null pointer currently
   stored in `gMarioPlatform`.
3. Object free-list reuse can make a deallocated platform slot become the slot
   of a later SSL area-2 object.
4. On the first object update after the transition, platform displacement runs
   before `update_mario_platform()` recomputes the pointer.
5. If the reused object is Spindel in an active movement state, the displacement
   uses nonzero `oVelZ` and `oAngleVelPitch` from that Spindel object.

The target is a conditional engine theorem, not full star collection.
