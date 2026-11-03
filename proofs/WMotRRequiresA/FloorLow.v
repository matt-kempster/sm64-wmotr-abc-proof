(* spine (via AirMove / HeightInvariant): chunk 3 (b), the y floor,
   consumes wmotr_floor_dp *)
(* ====================================================================== *)
(* FloorLow (GOAL 2, chunk 3 (a)): every WMotR floor height is at or above *)
(* the death plane.                                                         *)
(*                                                                          *)
(* WMotRLevel.wmotr_floor_low gives -11000 (find_floor's no-floor value).  *)
(* This is the level fact the y floor needs: the lowest floor triangle of   *)
(* WMotR's static collision is the death plane (y = -8191, two COL_TRIs,   *)
(* FfComplete.dp_A / dp_B), and every object floor range (the exclamation   *)
(* boxes and cannon lids) is far above it.  floor_in allows 1 unit of slack *)
(* below a triangle's lowest vertex (binary32 plane heights), so the bound  *)
(* is -8192.  Checked by vm_compute over the clightgen'd level data; the   *)
(* theorem is stated over any lists, as in WMotRLevel, so the kernel never *)
(* unfolds the data.                                                        *)
(* ====================================================================== *)
From Coq Require Import ZArith List Bool Reals Lra Lia.
From SM64.Proofs.WMotRRequiresA Require Import WMotRLevel.
Import ListNotations.
Local Open Scope R_scope.

(* the death plane's height *)
Definition DP_Y : Z := -8191.

Definition dp_check_static (L : list tri) : bool :=
  forallb (fun t => negb (is_floor t) || (DP_Y <=? tri_ylo t)%Z) L.
Definition dp_check_objects (O : list (Z * Z)) : bool :=
  forallb (fun '(lo, hi) => (DP_Y <=? lo)%Z) O.

Lemma dp_generic : forall L O, dp_check_static L = true -> dp_check_objects O = true ->
  forall h, floor_in L O h -> IZR DP_Y - 1 <= h.
Proof.
  intros L O Hs Ho h Hf.
  destruct Hf as [(t & Hin & Hfl & Hlo & Hhi) | (lo & hi & Hin & Hlo & Hhi)].
  - unfold dp_check_static in Hs. rewrite forallb_forall in Hs.
    specialize (Hs t Hin). rewrite Hfl in Hs. simpl in Hs.
    apply Z.leb_le in Hs. apply IZR_le in Hs. lra.
  - unfold dp_check_objects in Ho. rewrite forallb_forall in Ho.
    specialize (Ho (lo, hi) Hin). simpl in Ho.
    apply Z.leb_le in Ho. apply IZR_le in Ho. lra.
Qed.

(* the death plane is the lowest floor: every WMotR floor height is at or
   above -8192 (the plane at -8191, less floor_in's 1 unit of slack) *)
Theorem wmotr_floor_dp : forall h, wmotr_floor h -> -8192 <= h.
Proof.
  intros h Hf.
  assert (E : IZR DP_Y - 1 = -8192) by (unfold DP_Y; lra).
  rewrite <- E.
  apply (dp_generic static_tris object_floor_ranges); [vm_compute; reflexivity | vm_compute; reflexivity | exact Hf].
Qed.

(* the bound is tight: some floor triangle has its lowest vertex at the
   death plane (so -8191 is not an artifact of an empty check) *)
Lemma dp_attained : existsb (fun t => is_floor t && (tri_ylo t =? DP_Y)%Z) static_tris = true.
Proof. vm_compute. reflexivity. Qed.
