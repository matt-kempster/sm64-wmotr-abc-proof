(* kept: the generated-data justification of HeightBudgetArith.POLE_UP for a
   future top-of-pole walk; not load-bearing until the anim buffer's contents
   are a frame-world fact (TRUST.md 0.8(f) lists what that needs). *)
(* ======================================================================= *)
(* GOAL 2: the handstand's y translation, read off Mario's REAL animation   *)
(* data (generated/mario_anim_data.v).                                      *)
(*                                                                          *)
(* What moves pos[1] at the top of a pole.  act_top_of_pole and             *)
(* act_top_of_pole_transition (mario_actions_automatic.c:263-298) end with  *)
(*     set_pole_position(m, return_mario_anim_y_translation(m));            *)
(* and set_pole_position (:58-111) sets                                     *)
(*     pos[1] = usedObj->oPosY + oMarioPolePos + offsetY.                   *)
(* return_mario_anim_y_translation (mario.c:216) is translation[1] of       *)
(* find_mario_anim_flags_and_translation (mario.c:173-200): the s16 sample  *)
(* values[retrieve_animation_index(frame, &index)] / 4.0f of the y channel  *)
(* (the SECOND (count, start) pair of the index table; the first call       *)
(* reads x and advances the pointer by 2), stored to an s16.  So the        *)
(* animation data DOES move m->pos[1]: it is not rendering-only (animYTrans *)
(* / unkB0 is).  The anims are the ones the generated bodies pass to        *)
(* set_mario_animation: 9 in act_top_of_pole, 11 / 12 in the transition     *)
(* (`top_of_pole_anim_ids`, read off generated/mario_actions_automatic.v).  *)
(*                                                                          *)
(* The data.  The real build runs the vendor's tools/mario_anims_converter  *)
(* .py over assets/anims/*.inc.c into mario_anim_data.c, one C object       *)
(* gMarioAnims = { numEntries; addrPlaceholder; entries[209] (offset,size); *)
(* the struct Animation headers, index and value arrays }, placed in the    *)
(* ROM `assets` segment (sm64.ld:1334).  It is the DMA source of            *)
(* load_patchable_table (memory.c:567): entry `id` is DMA'd to bufTarget,   *)
(* and set_mario_animation relocates the header's values / index fields     *)
(* (offsets from the header) to absolute pointers (mario.c:69-71).  The     *)
(* decoder `anim_y` below follows exactly that path through the clightgen'd *)
(* initializer: entries[id] -> header -> index pair 1 -> values, with       *)
(* retrieve_animation_index's clamp (graph_node.c), and it FAILS unless the *)
(* sample lies inside the DMA'd range [offset, offset + size).              *)
(*                                                                          *)
(* Result (`handstand_y_bound`): for every frame f >= -1, the sample is in  *)
(* [-4, 696], so translation[1] <= 174 and the reach above the pole's       *)
(* hitbox top is at most -100 + 174 + 79 = 153 <= POLE_UP = 160             *)
(* (`pole_up_covers_handstand`).  This replaces the tool-read 174           *)
(* (tools/goal2_pole_anim.py) by a generated-data fact.                     *)
(*                                                                          *)
(* NOT established here (TRUST.md 0.8(f)): that after load_patchable_table  *)
(* the buffer holds these bytes (the DMA floor 3.5 says only "data"; the    *)
(* table gMarioAnimsBuf.dmaTable is built at boot by setup_dma_table_list,  *)
(* which is not run); that the frame is >= -1 (animFrame is advanced by the *)
(* unlinked rendering code).  (Until 2026-10-22 the relocated pointer was  *)
(* also shifted by VIRTUAL_TO_PHYSICAL and never shifted back, so the read  *)
(* had no execution; repaired, AnimRoundTrip.v, TRUST 2.2.)                 *)
(* No proof consumes this bound yet: the top-of-                            *)
(* pole cases are inside HeightFrame's open Hauto_case row.                 *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool Reals Lra Lia.
From compcert Require Import Coqlib Maps Errors Integers AST Ctypes Clight.
From SM64.Generated Require mario_anim_data mario_actions_automatic.
From SM64.Proofs Require Import HeightBudgetArith.
Import ListNotations.

Local Open Scope Z_scope.

(* ----------------------------------------------------------------------- *)
(* 1. The anim ids the top-of-pole handlers pass to set_mario_animation.    *)
(* ----------------------------------------------------------------------- *)
Fixpoint sma_ids (s : statement) : list Z :=
  match s with
  | Scall _ (Evar f _) (_ :: Econst_int i _ :: nil) =>
      if Pos.eqb f mario_actions_automatic._set_mario_animation then [Int.signed i] else []
  | Ssequence a b => sma_ids a ++ sma_ids b
  | Sifthenelse _ a b => sma_ids a ++ sma_ids b
  | Sloop a b => sma_ids a ++ sma_ids b
  | Slabel _ a => sma_ids a
  | Sswitch _ ls => sma_ids_ls ls
  | _ => []
  end
with sma_ids_ls (ls : labeled_statements) : list Z :=
  match ls with
  | LSnil => []
  | LScons _ a r => sma_ids a ++ sma_ids_ls r
  end.

(* MARIO_ANIM_HANDSTAND_IDLE, _START_HANDSTAND, _RETURN_FROM_HANDSTAND *)
Definition HANDSTAND : list Z := [9; 11; 12].

Lemma top_of_pole_anim_ids :
  sma_ids (fn_body mario_actions_automatic.f_act_top_of_pole) = [9] /\
  sma_ids (fn_body mario_actions_automatic.f_act_top_of_pole_transition) = [11; 12].
Proof. vm_compute. auto. Qed.

(* ----------------------------------------------------------------------- *)
(* 2. The layout CompCert gives the generated composites.                   *)
(* ----------------------------------------------------------------------- *)
Definition cenv : composite_env := prog_comp_env mario_anim_data.prog.

Definition member_ofs (c f : ident) : option Z :=
  match PTree.get c cenv with
  | Some co => match field_offset cenv f (co_members co) with
               | OK (o, Full) => Some o
               | _ => None
               end
  | None => None
  end.

(* struct Animation: values at 12, index at 16; struct MarioAnimsObj:
   numEntries at 0, entries at 8; struct OffsetSizePair: offset 0, size 4 *)
Definition OFS_VALUES := 12.
Definition OFS_INDEX := 16.
Definition OFS_ENTRIES := 8.

Lemma anim_layout :
  member_ofs mario_anim_data._Animation mario_anim_data._values = Some OFS_VALUES /\
  member_ofs mario_anim_data._Animation mario_anim_data._index = Some OFS_INDEX /\
  member_ofs mario_anim_data._MarioAnimsObj mario_anim_data._numEntries = Some 0 /\
  member_ofs mario_anim_data._MarioAnimsObj mario_anim_data._entries = Some OFS_ENTRIES /\
  member_ofs mario_anim_data._OffsetSizePair mario_anim_data._offset = Some 0 /\
  member_ofs mario_anim_data._OffsetSizePair mario_anim_data._size = Some 4 /\
  option_map co_sizeof (PTree.get mario_anim_data._OffsetSizePair cenv) = Some 8.
Proof. vm_compute. repeat split. Qed.

(* ----------------------------------------------------------------------- *)
(* 3. Reading the initializer at a byte offset.                             *)
(* ----------------------------------------------------------------------- *)
(* the init item that Genv.store_init_data stores at byte offset o (items
   are stored back to back, each init_data_size long) *)
Fixpoint item_at (l : list init_data) (o : Z) : option init_data :=
  match l with
  | nil => None
  | d :: r =>
      if o =? 0 then Some d
      else if o <? init_data_size d then None
      else item_at r (o - init_data_size d)
  end.

Definition IMG : list init_data := gvar_init mario_anim_data.v_gMarioAnims.

Definition rd16s (o : Z) : option Z :=
  match item_at IMG o with Some (Init_int16 i) => Some (Int.signed i) | _ => None end.
Definition rd16u (o : Z) : option Z :=
  match item_at IMG o with Some (Init_int16 i) => Some (Int.unsigned i) | _ => None end.
Definition rd32u (o : Z) : option Z :=
  match item_at IMG o with Some (Init_int32 i) => Some (Int.unsigned i) | _ => None end.

(* ----------------------------------------------------------------------- *)
(* 4. The y channel of DMA table entry `id`.                                *)
(* ----------------------------------------------------------------------- *)
(* (header offset h, DMA size sz, values offset vrel from h, y count, y start) *)
Definition y_hdr (id : Z) : option (Z * Z * Z * Z * Z) :=
  match rd32u 0 with
  | Some n =>
      if (0 <=? id) && (id <? n) then
        match rd32u (OFS_ENTRIES + 8 * id), rd32u (OFS_ENTRIES + 8 * id + 4) with
        | Some h, Some sz =>
            match rd32u (h + OFS_VALUES), rd32u (h + OFS_INDEX) with
            | Some vrel, Some irel =>
                match rd16u (h + irel + 4), rd16u (h + irel + 6) with
                | Some cnt, Some st => Some (h, sz, vrel, cnt, st)
                | _, _ => None
                end
            | _, _ => None
            end
        | _, _ => None
        end
      else None
  | None => None
  end.

(* the sample at value index k, only if it lies inside the DMA'd bytes *)
Definition y_read (h sz vrel k : Z) : option Z :=
  let o := vrel + 2 * k in
  if (0 <=? o) && (o + 2 <=? sz) then rd16s (h + o) else None.

(* retrieve_animation_index (graph_node.c): start + frame below count,
   else the last sample *)
Definition y_index (cnt st f : Z) : Z := if f <? cnt then st + f else st + cnt - 1.

Definition anim_y (id f : Z) : option Z :=
  match y_hdr id with
  | Some (h, sz, vrel, cnt, st) => y_read h sz vrel (y_index cnt st f)
  | None => None
  end.

(* ----------------------------------------------------------------------- *)
(* 5. The bound.                                                            *)
(* ----------------------------------------------------------------------- *)
Definition zrange (lo : Z) (n : nat) : list Z := map (fun i => lo + Z.of_nat i) (seq 0 n).

Lemma in_zrange : forall lo n k, lo <= k < lo + Z.of_nat n -> In k (zrange lo n).
Proof.
  intros lo n k Hk. unfold zrange. apply in_map_iff.
  exists (Z.to_nat (k - lo)). split; [ lia | apply in_seq; lia ].
Qed.

Definition in_box (lo hi : Z) (r : option Z) : bool :=
  match r with Some v => (lo <=? v) && (v <=? hi) | None => false end.

(* every index frame >= -1 can reach, st - 1 .. st + cnt - 1, reads a
   sample in [lo, hi] *)
Definition y_check (lo hi id : Z) : bool :=
  match y_hdr id with
  | Some (h, sz, vrel, cnt, st) =>
      (1 <=? cnt) &&
      forallb (fun k => in_box lo hi (y_read h sz vrel k)) (zrange (st - 1) (Z.to_nat (cnt + 1)))
  | None => false
  end.

Lemma y_check_sound : forall lo hi id f,
  y_check lo hi id = true -> -1 <= f -> exists v, anim_y id f = Some v /\ lo <= v <= hi.
Proof.
  intros lo hi id f Hc Hf. unfold y_check, anim_y in *.
  destruct (y_hdr id) as [ [ [ [ [h sz] vrel] cnt] st] | ]; [ | discriminate ].
  apply andb_true_iff in Hc as [Hcnt Hc]. apply Z.leb_le in Hcnt.
  rewrite forallb_forall in Hc.
  assert (Hin : In (y_index cnt st f) (zrange (st - 1) (Z.to_nat (cnt + 1)))).
  { apply in_zrange. unfold y_index. destruct (Z.ltb_spec f cnt); lia. }
  specialize (Hc _ Hin). unfold in_box in Hc.
  destruct (y_read h sz vrel (y_index cnt st f)) as [v | ]; [ | discriminate ].
  apply andb_true_iff in Hc as [H1 H2]. apply Z.leb_le in H1. apply Z.leb_le in H2.
  exists v. auto.
Qed.

Lemma handstand_checks : forallb (y_check (-4) 696) HANDSTAND = true.
Proof. vm_compute. reflexivity. Qed.

(* the bound is tight: the idle handstand holds 696 (174 after / 4) *)
Lemma handstand_y_attained : anim_y 9 0 = Some 696.
Proof. vm_compute. reflexivity. Qed.

Theorem handstand_y_bound : forall id f, In id HANDSTAND -> -1 <= f ->
  exists v, anim_y id f = Some v /\ -4 <= v <= 696.
Proof.
  intros id f Hid Hf. apply y_check_sound; auto.
  pose proof handstand_checks as H. rewrite forallb_forall in H. auto.
Qed.

(* translation[1] = (s16)(v / 4.0f): v / 4 is exact in binary32 (|v| < 2^24),
   and the s16 conversion truncates toward zero, i.e. Z.quot v 4 *)
Theorem pole_up_covers_handstand : forall id f v,
  In id HANDSTAND -> -1 <= f -> anim_y id f = Some v ->
  (IZR (-100 + Z.quot v 4 + 79) <= POLE_UP)%R.
Proof.
  intros id f v Hid Hf Hv.
  destruct (handstand_y_bound id f Hid Hf) as (v' & Hv' & Hlo & Hhi).
  rewrite Hv in Hv'. injection Hv' as <-.
  assert (Z.quot v 4 <= 174).
  { change 174 with (Z.quot 696 4). apply Z.quot_le_mono; lia. }
  unfold POLE_UP. apply IZR_le. lia.
Qed.
