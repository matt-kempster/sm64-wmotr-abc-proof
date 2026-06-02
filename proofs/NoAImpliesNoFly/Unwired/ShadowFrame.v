(* ShadowFrame.v -- Milestone 1: the SAME generic syntactic analysis (Frame.v),
 * now run against a real SM64 translation unit (vendor/sm64/src/game/shadow.c,
 * VERSION=us), not the toy.
 *
 * The point of M1 is the pipeline, not new math: clightgen turned a 900-line
 * production C file into Clight, and the identical writes_global computation
 * discharges by reflexivity on its real functions. Nothing here is bespoke to
 * shadow.c beyond naming the functions and globals to check.
 *)

From SM64.Proofs Require Import Frame.
From SM64.Generated Require Import shadow.

(* create_shadow_below_xyz stores into the file-static sSurfaceTypeBelowShadow
   (shadow.c:865: `sSurfaceTypeBelowShadow = pfloor->type;`). *)
Example below_xyz_writes_surface_type :
  writes_global f_create_shadow_below_xyz _sSurfaceTypeBelowShadow = true.
Proof. reflexivity. Qed.

(* ...and into sMarioOnFlyingCarpet (shadow.c:860). *)
Example below_xyz_writes_flying_carpet :
  writes_global f_create_shadow_below_xyz _sMarioOnFlyingCarpet = true.
Proof. reflexivity. Qed.

(* atan2_deg is pure arithmetic: it assigns to no file-scope global. *)
Example atan2_deg_writes_no_surface_type :
  writes_global f_atan2_deg _sSurfaceTypeBelowShadow = false.
Proof. reflexivity. Qed.

(* It also directly assigns gShadowAboveWaterOrLava (shadow.c:858). I originally
   guessed this was false; reflexivity corrected me -- a small reminder that the
   analysis reads the AST, not our intentions. *)
Example below_xyz_writes_above_water :
  writes_global f_create_shadow_below_xyz _gShadowAboveWaterOrLava = true.
Proof. reflexivity. Qed.

(* Honest scope reminder (same conservativeness as Frame.v): this is
   intra-procedural and direct-assignment only. create_shadow_circle_9_verts
   never *directly* assigns gShadowAboveWaterOrLava; any effect it has on shadow
   state flows through callees, which this analysis does not chase. So it reports
   false -- a sound interprocedural frame summary is M2+ work, not claimed here. *)
Example circle9_does_not_directly_write_above_water :
  writes_global f_create_shadow_circle_9_verts _gShadowAboveWaterOrLava = false.
Proof. reflexivity. Qed.
