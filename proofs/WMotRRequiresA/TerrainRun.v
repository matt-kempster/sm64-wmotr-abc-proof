(* spine-root: GOAL 2's floor premise (AirMatch.floor_data, TRUST 0.8) is
   checked on WMotR's REAL loaded terrain -- the partition the generated
   alloc_surface_pools + load_area_terrain build from WMotR's collision data. *)
(* ====================================================================== *)
(* TerrainRun (GOAL 2): run the real level-terrain loader, then check     *)
(* floor_data on its output.                                               *)
(*                                                                          *)
(* Over every 34-TU link (surface_load.c, macro_special_objects.c and     *)
(* WMotR's level data linked):                                             *)
(*   - the memory: the link's globals (MemBuild.alloc_globs: the data the *)
(*     linked definitions hold, WMotR's collision array included) plus    *)
(*     the main pool as one fresh block (TRUST 3.6), with main_pool_init's *)
(*     post-state written in (main_pool_init itself has no CompCert       *)
(*     execution: ALIGN16 does integer arithmetic on a pointer, TRUST     *)
(*     3.6 detail);                                                         *)
(*   - the run: the generated alloc_surface_pools (two main_pool_alloc    *)
(*     calls), then load_area_terrain(1, wmotr_seg7_collision, NULL,      *)
(*     NULL), executed by the sound Clight interpreter.  No macro objects *)
(*     are spawned (macroObjects = NULL; WMotR's macro objects are boxes / *)
(*     cannons, 0.8(b)); the one special object is special_null_start;    *)
(*   - the checks, by vm_compute on the resulting memory M:               *)
(*       floor_data: every surface on a floor list of either partition    *)
(*       passes TerrainBound.tri_chk, so every Hit_at height is finite,    *)
(*       |h| <= 16384 and within +-1 of that surface's y-range;           *)
(*       decoder agreement: each such surface IS a floor triangle of       *)
(*       WMotRLevel.static_tris (type and all nine coordinates), so the   *)
(*       ranges are wmotr_floor's (TRUST 0.8(a) for this memory).          *)
(*                                                                          *)
(* floor_data M and the agreement are unconditional facts about M.  That  *)
(* M is what the generated loader computes rests on the interpreter's two *)
(* external answers, stated as the hypothesis [world_ok], not as a trust  *)
(* row: sqrtf returns the IEEE single-precision square root (the VR4300   *)
(* sqrt.s; TRUST 3.5 makes no claim about its value), and                 *)
(* reset_red_coins_collected (ingame_menu.c, not linked) returns without  *)
(* changing memory.                                                         *)
(*                                                                          *)
(* Not yet: this memory is not StartSat's witness (that one is built from *)
(* Genv.init_mem plus the entry stores and has an empty partition).        *)
(* ====================================================================== *)

From Coq Require Import String List ZArith Reals Lia Lra.
From compcert Require Import Coqlib Integers Floats Values AST Memory Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import LinkedTwelve HeightInvariant WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight AirMatch TerrainBound.
Require SM64.Generated.surface_load.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Local Open Scope string_scope.

(* ---------------------------------------------------------------------- *)
(* The interpreter's external answers.                                     *)
(* ---------------------------------------------------------------------- *)
Definition world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) :=
  match ef, args with
  | EF_external n _, [Vsingle x] =>
      if String.eqb n "sqrtf" then Some (E0, Vsingle (Float32.sqrt x), m) else None
  | EF_external n _, [] =>
      if String.eqb n "reset_red_coins_collected" then Some (E0, Vundef, m) else None
  | _, _ => None
  end.

(* what the run assumes of the two externals *)
Definition world_ok (ge : genv) : Prop :=
  forall ef args m t v m', world ef args m = Some (t, v, m') -> external_call ef ge args m t v m'.

Definition externs (i : ident) : option Z := None.

(* ---------------------------------------------------------------------- *)
(* The memory: globals, plus the main pool (TRUST 3.6) in main_pool_init's *)
(* post-state on a 16-aligned block of POOL bytes.                         *)
(* ---------------------------------------------------------------------- *)
Definition POOL : Z := 262144.

Definition pool_writes (s1 s2 s3 s4 s5 bp : block) : list wr :=
  [W Mint32 s1 0 (Vptr bp (Ptrofs.repr 16));                 (* sPoolStart = start + 16 *)
   W Mint32 s2 0 (Vptr bp (Ptrofs.repr (POOL - 16)));        (* sPoolEnd = end - 16 *)
   W Mint32 s3 0 (Vint (Int.repr (POOL - 32)));              (* sPoolFreeSpace *)
   W Mint32 s4 0 (Vptr bp Ptrofs.zero);                      (* sPoolListHeadL = start *)
   W Mint32 s5 0 (Vptr bp (Ptrofs.repr (POOL - 16)));        (* sPoolListHeadR = sPoolEnd *)
   W Mint32 bp 0 (Vint Int.zero); W Mint32 bp 4 (Vint Int.zero)]          (* L->prev/next *)
  ++ [W Mint32 bp (POOL - 16) (Vint Int.zero); W Mint32 bp (POOL - 12) (Vint Int.zero)].

Definition build (ge : genv) (ast : AST.program (Ctypes.fundef function) type) : option mem :=
  match alloc_globs ge externs Mem.empty (AST.prog_defs ast) with
  | Some m0 =>
      match fresh m0 POOL, sym ge "sPoolStart", sym ge "sPoolEnd", sym ge "sPoolFreeSpace",
            sym ge "sPoolListHeadL", sym ge "sPoolListHeadR" with
      | Some (m1, bp), Some s1, Some s2, Some s3, Some s4, Some s5 =>
          match apply_writes m1 (pool_writes s1 s2 s3 s4 s5 bp) 0 with
          | inl m2 => Some m2
          | inr _ => None
          end
      | _, _, _, _, _, _ => None
      end
  | None => None
  end.

(* ---------------------------------------------------------------------- *)
(* The checker over a memory.                                              *)
(* ---------------------------------------------------------------------- *)
Definition ldi (m : mem) (bs : block) (os : ptrofs) (k : Z) : option int :=
  match CM.load Mint16signed m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr k))) with
  | Some (Vint i) => Some i
  | _ => None
  end.

Definition ldf (m : mem) (bs : block) (os : ptrofs) (k : Z) : option float32 :=
  match CM.load Mfloat32 m bs (Ptrofs.unsigned (Ptrofs.add os (Ptrofs.repr k))) with
  | Some (Vsingle f) => Some f
  | _ => None
  end.

Definition vtx_is (v : WMotRLevel.vtx) (x y z : int) : bool :=
  let '(a, b, c) := v in
  Z.eqb a (Int.signed x) && Z.eqb b (Int.signed y) && Z.eqb c (Int.signed z).

Definition tri_is (ty x1 y1 z1 x2 y2 z2 x3 y3 z3 : int) (t : WMotRLevel.tri) : bool :=
  Z.eqb (t_type t) (Int.signed ty) && vtx_is (t_v1 t) x1 y1 z1 && vtx_is (t_v2 t) x2 y2 z2
  && vtx_is (t_v3 t) x3 y3 z3 && is_floor t.

(* Surface: type@0, vertex1@10, vertex2@16, vertex3@22 (x, y, z s16),
   normal@28 (x, y, z f32), originOffset@40 *)
Definition surf_ok (m : mem) (s : val) : bool :=
  match s with
  | Vptr bs os =>
      match ldi m bs os 0, ldi m bs os 10, ldi m bs os 12, ldi m bs os 14,
            ldi m bs os 16, ldi m bs os 18, ldi m bs os 20,
            ldi m bs os 22, ldi m bs os 24, ldi m bs os 26 with
      | Some ty, Some x1, Some y1, Some z1, Some x2, Some y2, Some z2, Some x3, Some y3, Some z3 =>
          match ldf m bs os 28, ldf m bs os 32, ldf m bs os 36, ldf m bs os 40 with
          | Some nx, Some ny, Some nz, Some oo =>
              match find (tri_is ty x1 y1 z1 x2 y2 z2 x3 y3 z3) static_tris with
              | Some t => tri_chk x1 z1 x2 z2 x3 z3 nx ny nz oo (tri_ylo t) (tri_yhi t)
              | None => false
              end
          | _, _, _, _ => false
          end
      | _, _, _, _, _, _, _, _, _, _ => false
      end
  | _ => false
  end.

Fixpoint walk (fuel : nat) (m : mem) (v : val) : bool :=
  match v with
  | Vptr bn on =>
      match fuel with
      | O => false
      | S f =>
          match CM.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_SURF))) with
          | Some s => surf_ok m s
          | None => true
          end
          && match CM.load Mint32 m bn (Ptrofs.unsigned (Ptrofs.add on (Ptrofs.repr SN_NEXT))) with
             | Some nx => walk f m nx
             | None => true
             end
      end
  | _ => true
  end.

Definition z16 : list Z := [0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15]%Z.

Definition cells_ok (fuel : nat) (m : mem) (bp : block) : bool :=
  forallb (fun z => forallb (fun x =>
      match CM.load Mint32 m bp (Ptrofs.unsigned (Ptrofs.repr (384 * z + 24 * x))) with
      | Some hd => walk fuel m hd
      | None => true
      end) z16) z16.

Definition parts_ok (fuel : nat) (ge : genv) (m : mem) : bool :=
  forallb (fun id => match Genv.find_symbol ge id with
                     | Some bp => cells_ok fuel m bp
                     | None => true
                     end) part_ids.

(* ---------------------------------------------------------------------- *)
(* Soundness of the checker.                                               *)
(* ---------------------------------------------------------------------- *)
Lemma ldi_ok : forall m bs os k i,
  Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr k))) = Some (Vint i) ->
  ldi m bs os k = Some i.
Proof. intros. unfold ldi. rewrite CM.load_eq. simpl in H. rewrite H. reflexivity. Qed.

Lemma ldf_ok : forall m bs os k f,
  Mem.loadv Mfloat32 m (Vptr bs (Ptrofs.add os (Ptrofs.repr k))) = Some (Vsingle f) ->
  ldf m bs os k = Some f.
Proof. intros. unfold ldf. rewrite CM.load_eq. simpl in H. rewrite H. reflexivity. Qed.

Lemma tri_is_floor : forall ty x1 y1 z1 x2 y2 z2 x3 y3 z3 t,
  tri_is ty x1 y1 z1 x2 y2 z2 x3 y3 z3 t = true -> is_floor t = true.
Proof. intros. unfold tri_is in H. apply andb_prop in H as [_ H]. exact H. Qed.

Lemma surf_ok_sound : forall m s, surf_ok m s = true ->
  forall xv zv h, ffl_hit16 m s xv zv h -> F32 h = true /\ (Rabs (R2 h) <= 16384)%R /\ wmotr_floor (R2 h).
Proof.
  intros m s S xv zv h ((bs & os & X & Z & x1 & z1 & x2 & z2 & x3 & z3 & nx & ny & nz & oo &
                          -> & -> & -> & L1 & L2 & L3 & L4 & L5 & L6 & F1 & F2 & F3 & F4 &
                          E1 & E2 & E3 & _ & ->) & SX & SZ).
  unfold surf_ok in S.
  rewrite (ldi_ok _ _ _ _ _ L1), (ldi_ok _ _ _ _ _ L2), (ldi_ok _ _ _ _ _ L3),
          (ldi_ok _ _ _ _ _ L4), (ldi_ok _ _ _ _ _ L5), (ldi_ok _ _ _ _ _ L6) in S.
  rewrite (ldf_ok _ _ _ _ _ F1), (ldf_ok _ _ _ _ _ F2), (ldf_ok _ _ _ _ _ F3),
          (ldf_ok _ _ _ _ _ F4) in S.
  destruct (ldi m bs os 0) as [ty|]; [ | discriminate ].
  destruct (ldi m bs os 12) as [y1|]; [ | discriminate ].
  destruct (ldi m bs os 18) as [y2|]; [ | discriminate ].
  destruct (ldi m bs os 24) as [y3|]; [ | discriminate ].
  destruct (find _ static_tris) as [t|] eqn:Ef; [ | discriminate ].
  apply find_some in Ef as [Hin Ht].
  destruct SX as (X' & HX & SX). destruct SZ as (Z' & HZ & SZ).
  injection HX as <-. injection HZ as <-.
  destruct (tri_chk_sound X Z x1 z1 x2 z2 x3 z3 nx ny nz oo _ _ S SX SZ E1 E2 E3) as (Fh & Ah & Rh).
  split; [ exact Fh | split; [ exact Ah | ] ].
  left. exists t. split; [ exact Hin | split; [ exact (tri_is_floor _ _ _ _ _ _ _ _ _ _ _ Ht) | exact Rh ] ].
Qed.

Lemma walk_sound : forall fuel m v s, walk fuel m v = true -> on_list m v s -> surf_ok m s = true.
Proof.
  induction fuel as [|f IH]; intros m v s W L; inversion L; subst; simpl in W;
    try discriminate.
  - apply andb_prop in W as [W _]. rewrite CM.load_eq in W. simpl in H. rewrite H in W. exact W.
  - apply andb_prop in W as [_ W]. rewrite CM.load_eq in W. simpl in H. rewrite H in W.
    exact (IH _ _ _ W H0).
Qed.

Lemma in_z16 : forall z, (0 <= z < 16)%Z -> In z z16.
Proof.
  intros z Hz. unfold z16. simpl. lia.
Qed.

Theorem parts_ok_floor_data : forall fuel ge m, parts_ok fuel ge m = true -> floor_data ge m.
Proof.
  intros fuel ge m P h (hd & s & xv & zv & FH & OL & HH).
  destruct FH as (id & bp & z & x & Hin & Hs & Hz & Hx & Hl).
  unfold parts_ok in P. rewrite forallb_forall in P. specialize (P id Hin). rewrite Hs in P.
  unfold cells_ok in P. rewrite forallb_forall in P. specialize (P z (in_z16 z Hz)).
  rewrite forallb_forall in P. specialize (P x (in_z16 x Hx)).
  rewrite CM.load_eq in P. unfold Mem.loadv in Hl. rewrite Hl in P.
  exact (surf_ok_sound m s (walk_sound _ _ _ _ P OL) xv zv h HH).
Qed.

(* decoder agreement: every surface on a floor list is one of the decoder's floor
   triangles, field for field *)
Definition surf_is (m : mem) (s : val) (t : WMotRLevel.tri) : Prop :=
  exists bs os, s = Vptr bs os /\
    let '(x1, y1, z1) := t_v1 t in let '(x2, y2, z2) := t_v2 t in let '(x3, y3, z3) := t_v3 t in
    forall k c, In (k, c) [(0, t_type t); (10, x1); (12, y1); (14, z1); (16, x2); (18, y2);
                           (20, z2); (22, x3); (24, y3); (26, z3)]%Z ->
      exists i, Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr k))) = Some (Vint i)
                /\ Int.signed i = c.

Definition static_agree (ge : genv) (m : mem) : Prop :=
  forall hd s, floor_head ge m hd -> on_list m hd s ->
    exists t, In t static_tris /\ is_floor t = true /\ surf_is m s t.

Lemma ldi_back : forall m bs os k i, ldi m bs os k = Some i ->
  Mem.loadv Mint16signed m (Vptr bs (Ptrofs.add os (Ptrofs.repr k))) = Some (Vint i).
Proof.
  intros m bs os k i H. unfold ldi in H. rewrite CM.load_eq in H. simpl.
  destruct (Mem.load _ _ _ _) as [[]|]; try discriminate. injection H as ->. reflexivity.
Qed.

Lemma surf_ok_agree : forall m s, surf_ok m s = true ->
  exists t, In t static_tris /\ is_floor t = true /\ surf_is m s t.
Proof.
  intros m s S. unfold surf_ok in S. destruct s as [| | | | | bs os]; try discriminate.
  destruct (ldi m bs os 0) as [ty|] eqn:L0; [ | discriminate ].
  destruct (ldi m bs os 10) as [x1|] eqn:L1; [ | discriminate ].
  destruct (ldi m bs os 12) as [y1|] eqn:L2; [ | discriminate ].
  destruct (ldi m bs os 14) as [z1|] eqn:L3; [ | discriminate ].
  destruct (ldi m bs os 16) as [x2|] eqn:L4; [ | discriminate ].
  destruct (ldi m bs os 18) as [y2|] eqn:L5; [ | discriminate ].
  destruct (ldi m bs os 20) as [z2|] eqn:L6; [ | discriminate ].
  destruct (ldi m bs os 22) as [x3|] eqn:L7; [ | discriminate ].
  destruct (ldi m bs os 24) as [y3|] eqn:L8; [ | discriminate ].
  destruct (ldi m bs os 26) as [z3|] eqn:L9; [ | discriminate ].
  destruct (ldf m bs os 28); [ | discriminate ].
  destruct (ldf m bs os 32); [ | discriminate ].
  destruct (ldf m bs os 36); [ | discriminate ].
  destruct (ldf m bs os 40); [ | discriminate ].
  destruct (find _ static_tris) as [t|] eqn:Ef; [ | discriminate ].
  apply find_some in Ef as [Hin Ht].
  exists t. split; [ exact Hin | split; [ exact (tri_is_floor _ _ _ _ _ _ _ _ _ _ _ Ht) | ] ].
  exists bs, os. split; [ reflexivity | ].
  unfold tri_is, vtx_is in Ht.
  destruct t as [tt [[a1 b1] c1] [[a2 b2] c2] [[a3 b3] c3]]. cbn [t_type t_v1 t_v2 t_v3] in Ht |- *. cbv beta iota zeta in Ht |- *.
  repeat match goal with H : (_ && _) = true |- _ => apply andb_prop in H as [? ?] end.
  repeat match goal with H : Z.eqb _ _ = true |- _ => apply Z.eqb_eq in H end.
  intros k c Hk. cbn [In] in Hk.
  destruct Hk as [Hk|[Hk|[Hk|[Hk|[Hk|[Hk|[Hk|[Hk|[Hk|[Hk|[]]]]]]]]]]];
    injection Hk as <- <-;
    eexists; (split; [ apply ldi_back; eassumption | congruence ]).
Qed.

Theorem parts_ok_agree : forall fuel ge m, parts_ok fuel ge m = true -> static_agree ge m.
Proof.
  intros fuel ge m P hd s FH OL.
  destruct FH as (id & bp & z & x & Hin & Hs & Hz & Hx & Hl).
  unfold parts_ok in P. rewrite forallb_forall in P. specialize (P id Hin). rewrite Hs in P.
  unfold cells_ok in P. rewrite forallb_forall in P. specialize (P z (in_z16 z Hz)).
  rewrite forallb_forall in P. specialize (P x (in_z16 x Hx)).
  rewrite CM.load_eq in P. unfold Mem.loadv in Hl. rewrite Hl in P.
  exact (surf_ok_agree m s (walk_sound _ _ _ _ P OL)).
Qed.

(* ---------------------------------------------------------------------- *)
(* The run.                                                                 *)
(* ---------------------------------------------------------------------- *)
Definition FUEL : nat := Z.to_nat 2000000.
Definition WFUEL : nat := Z.to_nat 10000.

(* how many surfaces the loader allocated (non-vacuity) *)
Definition NSURF : Z := 1352.

Definition check_gen (fuel : nat) (ge : genv) (m : mem) : bool :=
  match ex_call ge world fuel m (Internal SM64.Generated.surface_load.f_alloc_surface_pools) [] with
  | Done _ (_, m1, _) =>
      match sym ge "wmotr_seg7_collision", sym ge "gSurfacesAllocated" with
      | Some bc, Some bn =>
          match ex_call ge world fuel m1 (Internal SM64.Generated.surface_load.f_load_area_terrain)
                  [Vint (Int.repr 1); Vptr bc Ptrofs.zero; Vint Int.zero; Vint Int.zero] with
          | Done _ (_, m2, _) =>
              parts_ok WFUEL ge m2
              && match CM.load Mint32 m2 bn 0 with
                 | Some (Vint n) => Z.eqb (Int.signed n) NSURF
                 | _ => false
                 end
          | _ => false
          end
      | _, _ => false
      end
  | _ => false
  end.

Definition witness_gen (oge : option genv)
    (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      match build ge ast with
      | Some m => check_gen FUEL ge m
      | None => false
      end
  | _, _ => false
  end.

Definition witness_ok : bool := witness_gen ge12 ast12.

Lemma witness_ok_true : witness_ok = true.
Proof. vm_compute. reflexivity. Qed.

Lemma check_gen_sound : forall fuel (ge : genv) m, check_gen fuel ge m = true ->
  exists m1 m2 bc bn n,
    Genv.find_symbol ge (id "wmotr_seg7_collision") = Some bc
    /\ Genv.find_symbol ge (id "gSurfacesAllocated") = Some bn
    /\ floor_data ge m2 /\ static_agree ge m2
    /\ Mem.load Mint32 m2 bn 0 = Some (Vint n) /\ Int.signed n = NSURF
    /\ (world_ok ge ->
        exists t1 v1 t2 v2,
          eval_funcall function_entry2 ge m
            (Internal SM64.Generated.surface_load.f_alloc_surface_pools) [] t1 m1 v1
          /\ eval_funcall function_entry2 ge m1
            (Internal SM64.Generated.surface_load.f_load_area_terrain)
            [Vint (Int.repr 1); Vptr bc Ptrofs.zero; Vint Int.zero; Vint Int.zero] t2 m2 v2).
Proof.
  intros fuel ge m H. unfold check_gen in H.
  destruct (ex_call ge world fuel m _ []) as [[[t1 m1] v1]| ? ? ?] eqn:R1; [ | discriminate ].
  unfold sym in H.
  destruct (Genv.find_symbol ge (id "wmotr_seg7_collision")) as [bc|] eqn:Hbc; [ | discriminate ].
  destruct (Genv.find_symbol ge (id "gSurfacesAllocated")) as [bn|] eqn:Hbn; [ | discriminate ].
  destruct (ex_call ge world fuel m1 _ _) as [[[t2 m2] v2]| ? ? ?] eqn:R2; [ | discriminate ].
  apply andb_prop in H as [P N].
  rewrite CM.load_eq in N.
  destruct (Mem.load Mint32 m2 bn 0) as [[| n | | | | ]|] eqn:Hn; try discriminate.
  apply Z.eqb_eq in N.
  exists m1, m2, bc, bn, n.
  refine (conj eq_refl (conj eq_refl (conj (parts_ok_floor_data _ _ _ P)
            (conj (parts_ok_agree _ _ _ P) (conj Hn (conj N _)))))).
  intros W. exists t1, v1, t2, v2. split.
  - exact (ex_call_sound ge world W _ _ _ _ _ _ _ R1).
  - exact (ex_call_sound ge world W _ _ _ _ _ _ _ R2).
Qed.

(* THE RUN: over every 34-TU link, the real alloc_surface_pools +
   load_area_terrain on WMotR's collision data produce a memory whose
   collision partition satisfies floor_data and agrees with the decoder,
   with NSURF surfaces allocated. *)
Theorem terrain_runs : forall lp, linked12 lp ->
  exists m m1 m2 bc bn n,
    Genv.find_symbol (globalenv lp) (id "wmotr_seg7_collision") = Some bc
    /\ Genv.find_symbol (globalenv lp) (id "gSurfacesAllocated") = Some bn
    /\ floor_data (globalenv lp) m2
    /\ static_agree (globalenv lp) m2
    /\ Mem.load Mint32 m2 bn 0 = Some (Vint n) /\ Int.signed n = NSURF
    /\ (world_ok (globalenv lp) ->
        exists t1 v1 t2 v2,
          eval_funcall function_entry2 (globalenv lp) m
            (Internal SM64.Generated.surface_load.f_alloc_surface_pools) [] t1 m1 v1
          /\ eval_funcall function_entry2 (globalenv lp) m1
            (Internal SM64.Generated.surface_load.f_load_area_terrain)
            [Vint (Int.repr 1); Vptr bc Ptrofs.zero; Vint Int.zero; Vint Int.zero] t2 m2 v2).
Proof.
  intros lp Hlink.
  pose proof witness_ok_true as W. unfold witness_ok in W.
  rewrite (ge12_ok lp Hlink), (ast12_ok lp Hlink) in W. unfold witness_gen in W.
  destruct (build (globalenv lp) (program_of_program lp)) as [m|]; [ | discriminate ].
  destruct (check_gen_sound _ _ _ W) as (m1 & m2 & bc & bn & n & H).
  exists m, m1, m2, bc, bn, n. exact H.
Qed.
