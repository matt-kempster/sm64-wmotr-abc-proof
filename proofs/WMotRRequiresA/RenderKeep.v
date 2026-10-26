(* ===================================================================== *)
(* RenderKeep (GOAL 2): Mario's REAL render call keeps the height        *)
(* invariant's world (HeightFrame.PhiW), 2026-10-23.                     *)
(*                                                                       *)
(* The render flank is the real geo_set_animation_globals call on        *)
(* &marioObj->header.gfx.animInfo (RenderFlank.render_call).  Its walked *)
(* footprint (RenderSet.gsag_footprint) is Mario's animFrame / animTimer *)
(* / animFrameAccelAssist (object + 64 .. 72) and the six gCurrAnim*     *)
(* render globals.  This file proves that every conjunct of PhiW -- the  *)
(* height cells, the WMotR world, anim_apart / mobj_apart, FfWorld.ffw   *)
(* (closedness, the partition's world fact, floor_data), used_ok,        *)
(* AnimWorld.anim_w and lvl_w -- survives that call:                     *)
(*   - nothing PhiW reads lies in the footprint: Mario's cells and the   *)
(*     collided / used objects' cells are off object + 64 .. 72, and the *)
(*     render globals are apart from Mario's object and the partition    *)
(*     (AnimWorld.rg_apart, carried by anim_w since 2026-10-23);         *)
(*   - the one cell PhiW reads that the call writes, animFrame in a pole *)
(*     action with a handstand animation loaded, stays in [-1, loopEnd]: *)
(*     RenderSet.gsag_frame over the loaded header (loopStart 0, loopEnd *)
(*     52 / 17 / 17, AnimData.buf_cells).                                *)
(* What the frame world does NOT carry is the render step's premise      *)
(* (render_surf_apart): Mario's wall / ceiling / floor surfaces are not  *)
(* in a render global's block.  The frame rows keep those three pointers *)
(* off the walk's regions (FfWorld.ffw) but not off every global, so     *)
(* carrying it needs a clause in every frame-world row.                  *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Integers Values AST Ctypes Clight ClightBigstep
  Memory Maps Globalenvs Linking Events Errors.
From SM64.Generated Require graph_node rendering_graph_node memory mario level_update
  surface_collision camera audio_external sound_init game_init.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve
  ActionValueFrame NoAImpliesNoFlyLinked.
From SM64.Proofs Require Import HeightInvariant WMotRWorld NoAActions FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim RenderSet RenderFlank
  FloorList FloorExec FfWorld AnimData AnimWorld PlatformEff.
From SM64.Proofs.WMotRRequiresA Require AnimKeep LevelGvars.
From SM64.Proofs Require Import Generic.ClosedMem.
Import ListNotations.

Local Open Scope Z_scope.

(* a flank step's surface premise: Mario's wall / ceiling / floor surfaces
   are not stored in the block of one of the globals Xs the step writes (in
   the game they are sSurfacePool / static-pool surfaces) *)
Definition surf_apart (lp : Clight.program) (bm : block) (Xs : list ident) (m : mem) : Prop :=
  forall id b off sb so, In id Xs -> Genv.find_symbol (lp_ge lp) id = Some b ->
    (off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF) ->
    Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> b.

(* the render step's: the six render globals *)
Definition render_surf_apart (lp : Clight.program) (bm : block) (m : mem) : Prop :=
  surf_apart lp bm render_gvars m.

(* the conjunction HeightFrame.PhiW names *)
Definition phiw (lp : Clight.program) (bm : block) (m : mem) : Prop :=
  height_invariant bm R_noA m /\ wmotr_world bm m /\ anim_apart lp bm m /\ mobj_apart bm m
  /\ ffw (lp_ge lp) bm m /\ used_ok bm m /\ AnimWorld.anim_w (lp_ge lp) bm m /\ lvl_w (lp_ge lp) m.

Lemma nin_rg : forall id, existsb (Pos.eqb id) flank_gvars = false -> ~ In id flank_gvars.
Proof.
  intros id H Hin. assert (E : existsb (Pos.eqb id) flank_gvars = true)
    by (apply existsb_exists; exists id; split; [exact Hin | apply Pos.eqb_refl]).
  congruence.
Qed.

(* the kept part of gMarioStates for a flank keep: bmw minus the two
   counters update_hud_values may clamp (numCoins at 168, numLives at 173;
   the level phase, LevelKeep).  PhiW reads neither. *)
Definition bmk (ch : memory_chunk) (z : Z) : Prop :=
  bmw ch z /\ (z + size_chunk ch <= 168 \/ 170 <= z) /\ (z + size_chunk ch <= 173 \/ 174 <= z).

Definition bmkb (ch : memory_chunk) (z : Z) : bool :=
  bmwb ch z && ((z + size_chunk ch <=? 168) || (170 <=? z))
  && ((z + size_chunk ch <=? 173) || (174 <=? z)).

Lemma bmkb_ok : forall ch z, bmkb ch z = true -> bmk ch z.
Proof.
  intros ch z H. unfold bmkb in H. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  split; [ exact (bmwb_ok ch z H1) | split ].
  - apply orb_true_iff in H2 as [H2 | H2]; [ left | right ]; apply Z.leb_le; exact H2.
  - apply orb_true_iff in H3 as [H3 | H3]; [ left | right ]; apply Z.leb_le; exact H3.
Qed.

Lemma bmk_bmw : forall ch z, bmk ch z -> bmw ch z.
Proof. intros ch z H. exact (proj1 H). Qed.

Ltac bmk_c := apply bmkb_ok; vm_compute; reflexivity.
Ltac bmk_t := first
  [ bmk_c
  | match goal with
    | H : ?z = _ \/ _ |- bmk _ ?z => destruct H as [-> | [-> | ->]]; bmk_c
    | H : ?z = _ \/ _ |- bmk _ ?z => destruct H as [-> | ->]; bmk_c
    end ].

Lemma max_mod : Ptrofs.max_unsigned = Ptrofs.modulus - 1.
Proof. reflexivity. Qed.

Lemma signed_small : forall z, -32768 <= z <= 32767 -> Int.signed (Int.repr z) = z.
Proof.
  intros z Hz. apply Int.signed_repr.
  change Int.min_signed with (-2147483648). change Int.max_signed with 2147483647. lia.
Qed.

Section RK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable bm : block.
  Notation G := (lp_ge lp).
  Notation u := Ptrofs.unsigned.

  (* ===================================================================== *)
  (* 0. A flank step writing the globals Xs (some of AnimWorld.flank_gvars:*)
  (*    the render globals for the render step, D_8032FEC0 for the         *)
  (*    platform step, PlatformKeep).                                      *)
  (* ===================================================================== *)
  Section XG.
  Variable Xs : list ident.
  Hypothesis HXs : incl Xs flank_gvars.
  (* a step that keeps lvl_w by k_all writes no warp cell (the level POST
     tail writes them and uses k_all_lvl) *)
  Hypothesis HXw : forall id, In id Xs -> ~ In id LevelGvars.warp_gvars.

  (* a written global's block *)
  Definition rgb (b : block) : Prop := exists id, In id Xs /\ Genv.find_symbol G id = Some b.

  Lemma rgb_not : forall id b, Genv.find_symbol G id = Some b ->
    existsb (Pos.eqb id) flank_gvars = false -> ~ rgb b.
  Proof.
    intros id b Hs Hn (id' & Hin & Hs').
    assert (Ne : id <> id') by (intros <-; exact (nin_rg id Hn (HXs id Hin))).
    exact (Genv.global_addresses_distinct G Ne Hs Hs' eq_refl).
  Qed.

  Lemma rgb_not_w : forall id b, Genv.find_symbol G id = Some b ->
    In id LevelGvars.warp_gvars -> ~ rgb b.
  Proof.
    intros id b Hs Hw (id' & Hin & Hs').
    destruct (peq id id') as [<- | Ne]; [ exact (HXw id Hin Hw) | ].
    exact (Genv.global_addresses_distinct G Ne Hs Hs' eq_refl).
  Qed.

  (* the written globals' blocks, as a region list *)
  Definition rg_blocks : list block :=
    flat_map (fun id => match Genv.find_symbol G id with Some b => [b] | None => [] end) Xs.

  Lemma rg_blocks_in : forall b, In b rg_blocks <-> rgb b.
  Proof.
    intros b. unfold rg_blocks, rgb. rewrite in_flat_map. split.
    - intros (id & Hin & Hb). destruct (Genv.find_symbol G id) as [b'|] eqn:E; [| destruct Hb].
      destruct Hb as [<- | []]. exists id. exact (conj Hin E).
    - intros (id & Hin & Hs). exists id. rewrite Hs. split; [exact Hin | left; reflexivity].
  Qed.

  Definition rgl : list (option val) := map (fun b => Some (Vptr b Ptrofs.zero)) rg_blocks.

  Lemma rblk_rgl : forall b, rblk rgl b -> rgb b.
  Proof.
    intros b (o & Hin). unfold rgl in Hin. apply in_map_iff in Hin as (b' & E & Hin).
    injection E as -> _. apply rg_blocks_in. exact Hin.
  Qed.

  Lemma rgl_rblk : forall b, rgb b -> rblk rgl b.
  Proof.
    intros b H. exists Ptrofs.zero. unfold rgl. apply in_map_iff. exists b. split; [reflexivity |].
    apply rg_blocks_in. exact H.
  Qed.

  Lemma rblk_app_or : forall a c b, rblk (a ++ c) b -> rblk a b \/ rblk c b.
  Proof.
    intros a c b (o & Hin). apply in_app_or in Hin as [H | H]; [left | right]; exists o; exact H.
  Qed.

  Lemma rblk_app_l : forall a c b, rblk a b -> rblk (a ++ c) b.
  Proof. intros a c b (o & Hin). exists o. apply in_or_app. left. exact Hin. Qed.

  Lemma rblk_app_r : forall a c b, rblk c b -> rblk (a ++ c) b.
  Proof. intros a c b (o & Hin). exists o. apply in_or_app. right. exact Hin. Qed.

  (* the frame's world fact over the render globals' blocks too *)
  Lemma Wff_blks : forall m gp bs vs,
    (forall b, In b bs -> rgb b /\ tab_apart G m b) -> Wff G m gp SZ_SURFACE vs ->
    Wff G m gp SZ_SURFACE (vs ++ map (fun b => Some (Vptr b Ptrofs.zero)) bs).
  Proof.
    intros m gp bs. induction bs as [| b bs IH]; intros vs HB W.
    - cbn [map]. rewrite app_nil_r. exact W.
    - cbn [map].
      replace (vs ++ Some (Vptr b Ptrofs.zero) :: map (fun b0 => Some (Vptr b0 Ptrofs.zero)) bs)
        with ((vs ++ [Some (Vptr b Ptrofs.zero)]) ++ map (fun b0 => Some (Vptr b0 Ptrofs.zero)) bs)
        by (rewrite <- app_assoc; reflexivity).
      apply IH; [intros b' H; apply HB; right; exact H |].
      destruct (HB b (or_introl eq_refl)) as ((id & Hin & Hs) & TA).
      apply (Wff_blk G m gp SZ_SURFACE vs b Ptrofs.zero); [| exact TA | exact W].
      intros id' bp Hin' Hs' E. subst bp.
      assert (Hne : id' <> id) by (intros ->; exact (part_not_rg id Hin' (HXs id Hin))).
      exact (Genv.global_addresses_distinct G Hne Hs' Hs eq_refl).
  Qed.

  Lemma Wff_rgl : forall m gp vs,
    (forall b, rgb b -> tab_apart G m b) -> Wff G m gp SZ_SURFACE vs ->
    Wff G m gp SZ_SURFACE (vs ++ rgl).
  Proof.
    intros m gp vs TA W. apply Wff_blks; [| exact W].
    intros b H. apply rg_blocks_in in H. exact (conj H (TA b H)).
  Qed.

  (* ===================================================================== *)
  (* 1. The render footprint as a memory effect.                           *)
  (* ===================================================================== *)
  Section EFF.
    Variables (mb : block) (oi : ptrofs) (m0 : mem) (gp : meminj).
    Hypothesis Hoi : u oi + 16 <= Ptrofs.max_unsigned.
    Hypothesis HC0 : closed_by gp m0.
    Hypothesis Gmb : gp mb <> None.
    Hypothesis HS : forall id b, Genv.find_symbol G id = Some b -> gp b <> None.
    Hypothesis HRX : incl render_gvars Xs.

    Lemma rstore_loc : forall mm b z ch v ch' b' z',
      rstore G mb oi m0 mm b z ch v -> ~ rgb b' ->
      (b' <> mb \/ z' + size_chunk ch' <= u oi + 8 \/ u oi + 16 <= z') ->
      b' <> b \/ z' + size_chunk ch' <= z \/ z + size_chunk ch <= z'.
    Proof.
      intros mm b z ch v ch' b' z' ([(-> & Hl) | (id & Hin & Hs & ->)] & _) Nr Hz.
      - destruct Hz as [Hz | Hz]; [left; exact Hz |].
        right. rewrite !uadd in Hl by lia.
        destruct Hl as [(-> & ->) | [(-> & ->) | (-> & ->)]]; cbn [size_chunk];
          destruct Hz as [Hz | Hz]; [left | right | left | right | left | right]; lia.
      - left. intros ->. apply Nr. exists id. split; [ exact (HRX id Hin) | exact Hs ].
    Qed.

    Lemma flat_some : forall mm b, closed_by gp mm -> gp b <> None -> gp b = Some (b, 0).
    Proof.
      intros mm b HC Hb. destruct (gp b) as [[b' d] |] eqn:E; [| contradiction].
      destruct (closed_flat _ _ _ _ _ HC E) as (-> & ->). reflexivity.
    Qed.

    Lemma rstore_eff : forall mm mm', stores_by (rstore G mb oi m0) mm mm' -> closed_by gp mm ->
      Mem.nextblock mm' = Mem.nextblock mm
      /\ (forall b o k p, Mem.perm mm b o k p -> Mem.perm mm' b o k p)
      /\ (forall ch b z, ~ rgb b -> (b <> mb \/ z + size_chunk ch <= u oi + 8 \/ u oi + 16 <= z) ->
            Mem.load ch mm' b z = Mem.load ch mm b z)
      /\ closed_by gp mm'.
    Proof.
      intros mm mm' H. induction H as [mm | mm m1 m2 ch b z v HP Hst _ IH]; intros HC.
      - refine (conj eq_refl (conj (fun _ _ _ _ H => H) (conj (fun _ _ _ _ _ => eq_refl) HC))).
      - assert (HC1 : closed_by gp m1).
        { pose proof HP as (Hloc & Hval).
          assert (Gb : gp b = Some (b, 0)).
          { apply (flat_some mm b HC). destruct Hloc as [(-> & _) | (id & _ & Hs & _)];
              [exact Gmb | exact (HS id b Hs)]. }
          apply (store_mapped_closed gp mm ch b z v m1 HC Gb); [| exact Hst].
          destruct v as [| ? | ? | ? | ? | b1 i]; try (constructor; fail).
          destruct (Hval b1 i eq_refl) as (b0 & o0 & Hl & Hb0).
          assert (G0 : gp b0 <> None).
          { destruct Hb0 as [-> | (ot & Hc)]; [exact Gmb |].
            cbn [Mem.loadv] in Hc. exact (closed_load gp m0 Mptr mb _ _ HC0 Gmb Hc). }
          cbn [Mem.loadv] in Hl. pose proof (closed_load gp mm Mptr b0 _ _ HC G0 Hl) as G1.
          cbn beta iota in G1.
          econstructor; [exact (flat_some mm b1 HC G1) |]. symmetry. apply Ptrofs.add_zero. }
        destruct (IH HC1) as (N & P & L & C).
        split; [rewrite N; exact (Mem.nextblock_store _ _ _ _ _ _ Hst) |].
        split; [intros b' o k p Hp; apply P; exact (Mem.perm_store_1 _ _ _ _ _ _ Hst _ _ _ _ Hp) |].
        split; [| exact C].
        intros ch' b' z' Nr Hz. rewrite (L ch' b' z' Nr Hz).
        apply (Mem.load_store_other _ _ _ _ _ _ Hst). exact (rstore_loc _ _ _ _ _ _ _ _ HP Nr Hz).
    Qed.
  End EFF.

  (* ===================================================================== *)
  (* 2. A memory change off a flank's footprint keeps PhiW's conjuncts.    *)
  (*    The footprint: the globals Xs, Mario's animation cells (object +   *)
  (*    64 .. 72) and Mario's x / z cells (gMarioStates outside bmw).      *)
  (*    New blocks may appear (a call's locals) as long as the old ones    *)
  (*    keep their permissions, and closedness may need a larger meminj.   *)
  (* ===================================================================== *)
  Section KEEP.
    Variables (m m' : mem) (mb : block) (mo : ptrofs).
    Hypothesis Lmo : Mem.load Mint32 m bm 136 = Some (Vptr mb mo).
    Hypothesis NB : Ple (Mem.nextblock m) (Mem.nextblock m').
    Hypothesis PM : forall b o k p, Plt b (Mem.nextblock m) -> Mem.perm m b o k p -> Mem.perm m' b o k p.
    Hypothesis LD : forall ch b z, ~ rgb b -> b <> bm ->
      (b <> mb \/ z + size_chunk ch <= u mo + 64 \/ u mo + 72 <= z) ->
      Mem.load ch m' b z = Mem.load ch m b z.
    Hypothesis LM : forall ch z, bmk ch z -> Mem.load ch m' bm z = Mem.load ch m bm z.
    Hypothesis Sbm : Genv.find_symbol G level_update._gMarioStates = Some bm.
    Hypothesis Nbm : ~ rgb bm.
    Hypothesis Bmb : bm <> mb.
    Hypothesis RGa : forall b, rgb b -> b <> mb /\ tab_apart G m b.
    Hypothesis CL : forall gp, closed_by gp m -> gp mb <> None ->
      (forall id b, Genv.find_symbol G id = Some b -> gp b <> None) ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m'.
    Hypothesis FR : forall bt ot k, In k hs_ids ->
      Mem.load Mint32 m mb (u mo + 60) = Some (Vptr bt ot) ->
      Mem.load Mint32 m mb (u mo + 72) = Some (Vint Int.zero) ->
      (exists f, -1 <= f <= hs_le k /\ Mem.load Mint16signed m mb (u mo + 64) = Some (Vint (Int.repr f))) ->
      buf_ok m bt ot k -> u ot + BUFSZ < Ptrofs.modulus ->
      exists f, -1 <= f <= hs_le k /\ Mem.load Mint16signed m' mb (u mo + 64) = Some (Vint (Int.repr f)).

    Lemma Nmb : ~ rgb mb.
    Proof. intros H. exact (proj1 (RGa mb H) eq_refl). Qed.

    Lemma LHm : forall ch z, bmk ch z -> Mem.load ch m' bm z = Mem.load ch m bm z.
    Proof. exact LM. Qed.

    Lemma LHo : forall ch z, z + size_chunk ch <= u mo + 64 \/ u mo + 72 <= z ->
      Mem.load ch m' mb z = Mem.load ch m mb z.
    Proof. intros ch z H. exact (LD ch mb z Nmb (fun E => Bmb (eq_sym E)) (or_intror H)). Qed.

    Lemma LHb : forall ch b z, b <> mb -> b <> bm -> ~ rgb b -> Mem.load ch m' b z = Mem.load ch m b z.
    Proof. intros ch b z H1 H0 H2. exact (LD ch b z H2 H0 (or_introl H1)). Qed.

    (* gMarioAnimsBuf is not gMarioStates *)
    Lemma ab_bm : forall ab, Genv.find_symbol G mario._gMarioAnimsBuf = Some ab -> ab <> bm.
    Proof. intros ab Hs. exact (AnimKeep.symne_ids G _ _ _ _ Hs Sbm eq_refl). Qed.

    (* an object of Mario's block that is Mario's own or a whole Object away *)
    Lemma far_keep : forall co ch o', (co = mo \/ u co + 608 <= u mo \/ u mo + 608 <= u co) ->
      72 <= o' -> o' + size_chunk ch <= 608 ->
      Mem.load ch m' mb (u co + o') = Mem.load ch m mb (u co + o').
    Proof.
      intros co ch o' H H1 H2. apply LHo. destruct H as [-> | [H | H]]; [right | left | right]; lia.
    Qed.

    Lemma obj_eq : forall bo oo, Mem.load Mint32 m bm 136 = Some (Vptr bo oo) -> bo = mb /\ oo = mo.
    Proof. intros bo oo H. rewrite Lmo in H. injection H as <- <-. auto. Qed.

    (* ---- the height cells ---- *)
    Lemma k_cells : forall c, read_cells bm m c -> read_cells bm m' c.
    Proof.
      intros c (H1 & H2 & H3 & H4 & H5 & H6 & bo & oo & H7 & H8).
      destruct (obj_eq bo oo H7) as (-> & ->).
      split; [rewrite LHm by bmk_t; exact H1 |]. split; [rewrite LHm by bmk_t; exact H2 |].
      split; [rewrite LHm by bmk_t; exact H3 |]. split; [rewrite LHm by bmk_t; exact H4 |].
      split; [rewrite LHm by bmk_t; exact H5 |]. split; [rewrite LHm by bmk_t; exact H6 |].
      exists mb, mo. split; [rewrite LHm by bmk_t; exact H7 |].
      rewrite LHo by (unfold OFS_GFXY; cbn [size_chunk]; lia). exact H8.
    Qed.

    Lemma k_hi : height_invariant bm R_noA m -> height_invariant bm R_noA m'.
    Proof.
      intros (Hs & c & Hc & Hb). split.
      - intros v Hl. apply Hs. rewrite LHm in Hl by bmk_t. exact Hl.
      - exists c. split; [exact (k_cells c Hc) | exact Hb].
    Qed.

    (* ---- the world ---- *)
    Lemma coll_keep : forall co, (mb <> mb \/ co = mo \/ u co + OBJ_SIZE <= u mo \/ u mo + OBJ_SIZE <= u co) ->
      coll_obj_ok m (Vptr mb co) -> coll_obj_ok m' (Vptr mb co).
    Proof.
      intros co Hap (b & o & t & E & Lt & Hin & Hp & Hc).
      injection E as <- <-.
      assert (F : co = mo \/ u co + 608 <= u mo \/ u mo + 608 <= u co)
        by (unfold OBJ_SIZE in Hap; destruct Hap as [N | H]; [exfalso; exact (N eq_refl) | exact H]).
      exists mb, co, t. split; [reflexivity |].
      split; [rewrite (far_keep co) by (first [exact F | unfold O_INTERACT_TYPE, RAW_OFF; cbn [size_chunk]; lia]);
              exact Lt |].
      split; [exact Hin |]. split.
      - intros Ht. destruct (Hp Ht) as (base & top & Hi & P1 & P2 & P3).
        exists base, top. split; [exact Hi |].
        rewrite !(far_keep co) by (first [exact F | unfold O_POSY, HITBOX_DOWN_OFF, HITBOX_H_OFF, RAW_OFF;
                                                   cbn [size_chunk]; lia]).
        auto.
      - intros Ht. destruct (Hc Ht) as (y & Hi & P1). exists y. split; [exact Hi |].
        rewrite (far_keep co) by (first [exact F | unfold O_POSY, RAW_OFF; cbn [size_chunk]; lia]).
        exact P1.
    Qed.

    Lemma k_world : wmotr_world bm m -> mobj_apart bm m -> surf_apart lp bm Xs m ->
      (forall off sb so, (off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF) ->
         Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> bm) ->
      (forall i cb co, 0 <= i < 4 ->
         Mem.load Mint32 m mb (u mo + FFW_COLL + 4 * i) = Some (Vptr cb co) -> cb = mb) ->
      wmotr_world bm m'.
    Proof.
      intros (Hw & Hc & Hfl & Hh & Hr & Hq & Ho) Hmo RSA SNB Co.
      destruct (Hmo mb mo Lmo) as (_ & P2 & P3).
      assert (Sk : forall off sb so, off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF ->
                Mem.load Mint32 m bm off = Some (Vptr sb so) ->
                forall ch z, Mem.load ch m' sb z = Mem.load ch m sb z).
      { intros off sb so Hoff Hl ch z.
        apply LHb; [exact (P2 off sb so Hoff Hl) | exact (SNB off sb so Hoff Hl) |].
        intros (id & Hin & Hs). exact (RSA id sb off sb so Hin Hs Hoff Hl eq_refl). }
      split; [| split; [| split; [| split; [| split; [| split]]]]].
      - intros v Hl. rewrite LHm in Hl by bmk_t. destruct (Hw v Hl) as [-> | (b & o & t & -> & Lt & Hin)];
          [left; reflexivity |].
        right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        rewrite (Sk WALL_OFF b o (or_introl eq_refl) Hl). exact Lt.
      - intros v Hl. rewrite LHm in Hl by bmk_t. destruct (Hc v Hl) as [-> | (b & o & t & -> & Lt & Hin)];
          [left; reflexivity |].
        right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        rewrite (Sk CEIL_OFF b o (or_intror (or_introl eq_refl)) Hl). exact Lt.
      - intros v Hl. rewrite LHm in Hl by bmk_t. destruct (Hfl v Hl) as (b & o & t & -> & Lt & Hin).
        exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        rewrite (Sk FLOOR_OFF b o (or_intror (or_intror eq_refl)) Hl). exact Lt.
      - rewrite LHm by bmk_t. exact Hh.
      - rewrite LHm by bmk_t. exact Hr.
      - rewrite LHm by bmk_t. exact Hq.
      - destruct Ho as (mb' & mo' & s & n & Hl & Ls & Hs & Ln & Hn & Hall).
        destruct (obj_eq mb' mo' Hl) as (-> & ->).
        exists mb, mo, s, n. split; [rewrite LHm by bmk_t; exact Hl |].
        split; [rewrite LHo by (unfold O_INTERACT_STATUS, RAW_OFF; cbn [size_chunk]; lia); exact Ls |].
        split; [exact Hs |].
        split; [rewrite LHo by (unfold NUMCOLL_OFF; cbn [size_chunk]; lia); exact Ln |].
        split; [exact Hn |].
        intros i v Hi Hl2. rewrite LHo in Hl2 by (unfold COLL_OFF; cbn [size_chunk]; lia).
        pose proof (Hall i v Hi Hl2) as Hok.
        pose proof Hok as (cb & co & t & -> & _).
        assert (Hi4 : 0 <= i < 4) by lia.
        assert (Ecb : cb = mb) by exact (Co i cb co Hi4 Hl2). subst cb.
        exact (coll_keep co (P3 i mb co Hi4 Hl2) Hok).
    Qed.

    (* ---- Mario's object's apartness facts ---- *)
    Lemma k_mobj : mobj_apart bm m -> mobj_apart bm m'.
    Proof.
      intros Hmo mb' mo' Hl. rewrite LHm in Hl by bmk_t. destruct (obj_eq mb' mo' Hl) as (-> & ->).
      destruct (Hmo mb mo Hl) as (P1 & P2 & P3).
      split; [exact P1 |]. split.
      - intros off sb so Hoff Hl'. rewrite LHm in Hl' by bmk_t. exact (P2 off sb so Hoff Hl').
      - intros i cb co Hi Hl'. rewrite LHo in Hl' by (unfold COLL_OFF; cbn [size_chunk]; lia).
        exact (P3 i cb co Hi Hl').
    Qed.

    Lemma ffw_ne : ffw G bm m -> forall b,
      Genv.find_symbol G mario._gMarioAnimsBuf = Some b \/ lvl_sym G b -> b <> mb.
    Proof.
      intros (_ & EX & _) b Hb.
      ffw_unpack EX.
      destruct (obj_eq bo oo Lo) as (-> & ->).
      destruct Hb as [Hb | Hb].
      - assert (b = ab) by congruence. subst b.
        refine (proj1 (D4 ab (or_introl _))); cbn [In]; auto 10.
      - exact (proj1 (D4 b (or_intror (or_intror Hb)))).
    Qed.

    Lemma k_anim_apart : ffw G bm m -> anim_apart lp bm m -> anim_apart lp bm m'.
    Proof.
      intros Hf Han ab bt ot Hs Hl.
      assert (Nab : ab <> mb) by exact (ffw_ne Hf ab (or_introl Hs)).
      assert (Rab : ~ rgb ab) by exact (rgb_not _ ab Hs ltac:(vm_compute; reflexivity)).
      rewrite (LHb Mptr ab 8 Nab (ab_bm ab Hs) Rab) in Hl.
      destruct (Han ab bt ot Hs Hl) as (A1 & A2). split.
      - intros off sb so Hoff Hl'. rewrite LHm in Hl' by bmk_t. exact (A1 off sb so Hoff Hl').
      - intros mb' mo' i cb co Hl' Hi Hl2. rewrite LHm in Hl' by bmk_t. destruct (obj_eq mb' mo' Hl') as (-> & ->).
        rewrite LHo in Hl2 by (unfold COLL_OFF; cbn [size_chunk]; lia). exact (A2 mb mo i cb co Hl' Hi Hl2).
    Qed.

    (* ---- usedObj ---- *)
    Lemma k_used : used_ok bm m -> used_ok bm m'.
    Proof.
      intros U a La. rewrite LHm in La by bmk_t. destruct (U a La) as (U1 & U2).
      assert (K136 : Mem.load Mint32 m' bm MARIOOBJ_OFF = Mem.load Mint32 m bm MARIOOBJ_OFF)
        by (apply LHm; bmk_t).
      assert (Ap : forall ub uo, used_apart bm m ub uo -> used_apart bm m' ub uo).
      { intros ub uo A. split; [exact (proj1 A) |]. intros mb' mo' Hl. rewrite K136 in Hl. exact (proj2 A mb' mo' Hl). }
      assert (Far : forall uo, used_apart bm m mb uo -> uo = mo \/ u uo + 608 <= u mo \/ u mo + 608 <= u uo).
      { intros uo (_ & A). destruct (A mb mo Lmo) as [N | F]; [exfalso; exact (N eq_refl) |].
        unfold OBJ_SPAN in F. right. exact F. }
      split.
      - intros Hp. destruct (U1 Hp) as (ub & uo & Lu & (base & top & Hin & Ht & P1 & P2 & P3) & A & (S & PP) & V).
        destruct (PP mb mo Lmo) as (Eu & p & Lp & Fp & Rp). subst ub.
        pose proof (Far uo A) as F.
        exists mb, uo. split; [rewrite LHm by bmk_t; exact Lu |].
        split; [| split; [exact (Ap _ _ A) | split]].
        + exists base, top. split; [exact Hin |]. split; [exact Ht |].
          rewrite !(far_keep uo) by (first [exact F | unfold O_POSY, HITBOX_DOWN_OFF, HITBOX_H_OFF, RAW_OFF;
                                                     cbn [size_chunk]; lia]).
          auto.
        + split; [exact S |]. intros mb' mo' Hl. rewrite K136 in Hl. destruct (obj_eq mb' mo' Hl) as (-> & ->).
          split; [reflexivity |]. exists p.
          rewrite LHo by (unfold POLEPOS_OFF, RAW_OFF; cbn [size_chunk]; lia). exact (conj Lp (conj Fp Rp)).
        + intros w Lv. rewrite LHm in Lv by bmk_t. exact (V w Lv).
      - intros Hcn. destruct (U2 Hcn) as (ub & uo & Lu & (y & Hin & P1) & A & (S & CP)).
        destruct (CP mb mo Lmo) as (Eu & CC). subst ub.
        pose proof (Far uo A) as F.
        exists mb, uo. split; [rewrite LHm by bmk_t; exact Lu |]. split; [| split; [exact (Ap _ _ A) |]].
        + exists y. split; [exact Hin |].
          rewrite (far_keep uo) by (first [exact F | unfold O_POSY, RAW_OFF; cbn [size_chunk]; lia]). exact P1.
        + split; [exact S |]. intros mb' mo' Hl. rewrite K136 in Hl. destruct (obj_eq mb' mo' Hl) as (-> & ->).
          split; [reflexivity |]. intros i cb co Hi Hl2.
          rewrite LHo in Hl2 by (unfold COLL_OFF; cbn [size_chunk]; lia). exact (CC i cb co Hi Hl2).
    Qed.

    (* ---- the frame's world fact, closedness, the floor data ---- *)
    Lemma k_ffw : ffw G bm m -> ffw G bm m'.
    Proof.
      intros (Hgn & EX & FD).
      ffw_unpack EX.
      destruct (obj_eq bo oo Lo) as (-> & ->).
      match type of W with Wff _ _ _ _ ?rl0 => set (rl := rl0) in * end.
      assert (Gmb : gp mb <> None) by exact (closed_load gp m Mint32 bm 136 _ HC HM Lmo).
      assert (Nab : ab <> mb)
        by (refine (proj1 (D4 ab (or_introl _))); cbn [In]; auto 10).
      assert (Rab : ~ rgb ab) by exact (rgb_not _ ab S5 ltac:(vm_compute; reflexivity)).
      assert (Hnb : Ple (Mem.nextblock m) (Mem.nextblock m')) by exact NB.
      assert (Hperm : forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
        by (intros b ofs k p Hb Hp; exact (PM b ofs k p Hb Hp)).
      assert (Hld : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (rl ++ rgl) b ->
                Mem.load ch m' b z = Mem.load ch m b z).
      { intros ch b z _ Nr. apply LHb.
        - intros ->. apply Nr. apply rblk_app_l. exists mo. unfold rl, ff_rl. cbn. auto 25.
        - intros ->. apply Nr. apply rblk_app_l. exists Ptrofs.zero. unfold rl, ff_rl. cbn. auto 25.
        - intros Hr. apply Nr. apply rblk_app_r. exact (rgl_rblk b Hr). }
      assert (W1 : Wff G m gp SZ_SURFACE (rl ++ rgl))
        by (apply Wff_rgl; [intros b Hb; exact (proj2 (RGa b Hb)) | exact W]).
      destruct (CL gp HC Gmb HS) as (gp' & Hg & HC').
      assert (W2 : Wff G m' gp' SZ_SURFACE (rl ++ rgl))
        by exact (Wff_keep2 G m m' (rl ++ rgl) Hnb Hperm Hld gp gp' Hg W1).
      apply (ffw_rebuild G bm m m' _ gp' FWF (Ple_trans _ _ _ Hgn NB) Hnb Hg HC').
      - exact (Wff_mono G m' gp' SZ_SURFACE (rl ++ rgl) rl (fun b H => rblk_app_l _ _ b H) W2).
      - exact (floor_data_keep2 G m m' (rl ++ rgl) Hnb Hperm Hld gp W1 FD).
      - intros ch b z Hr. ffw_read_split Hr;
          first [ solve [apply LHm; bmk_t] | solve [exact (LHb Mint32 ab 8 Nab (ab_bm ab S5) Rab)]
                | solve [apply LHo; unfold FFW_COLL; cbn [size_chunk]; lia]
                  (* throwMatrix (+80) lies outside the render footprint (+64..72) *)
                | solve [apply LHo; unfold FFW_THROW; cbn [size_chunk]; lia]
                | solve [apply LHo; unfold FFW_HH, FFW_HD; cbn [size_chunk]; lia] ].
      - split.
        + exists fl. split; [rewrite LHm by bmk_t; exact Lf | exact Wf].
        + split.
          * intros off sb so Hoff Hl. rewrite LHm in Hl by bmk_t. exact (Wc0 off sb so Hoff Hl).
          * intros off sb so Hoff Hl. rewrite LHm in Hl by bmk_t. exact (Spl off sb so Hoff Hl).
    Qed.

    (* ---- the animation world ---- *)
    Lemma k_anim_w : ffw G bm m -> AnimWorld.anim_w G bm m -> AnimWorld.anim_w G bm m'.
    Proof.
      intros (Hgn & EX & FD) AW.
      ffw_unpack EX.
      destruct (obj_eq bo oo Lo) as (-> & ->).
      destruct AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb' & mo' & B & ST).
      pose proof B as (Sab & Sga & Sau & L0 & L8 & Lm & Sy & E1 & E2 & E3 & E4 & (E5 & RG) & Z1 & Z2 & Z3
                       & P & T & GA & TA & AC & Hbm).
      assert (ab' = ab) by congruence. subst ab'.
      rewrite Lb in L8. injection L8 as <- <-.
      destruct (obj_eq mb' mo' Lm) as (-> & ->).
      match type of W with Wff _ _ _ _ ?rl0 => set (rl := rl0) in * end.
      assert (Nab : ab <> mb)
        by (refine (proj1 (D4 ab (or_introl _))); cbn [In]; auto 10).
      assert (Rab : ~ rgb ab) by exact (rgb_not _ ab S5 ltac:(vm_compute; reflexivity)).
      assert (Hnb : Ple (Mem.nextblock m) (Mem.nextblock m')) by exact NB.
      assert (Hperm : forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
        by (intros b ofs k p Hb Hp; exact (PM b ofs k p Hb Hp)).
      assert (Hld : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (rl ++ rgl) b ->
                Mem.load ch m' b z = Mem.load ch m b z).
      { intros ch b z _ Nr. apply LHb.
        - intros ->. apply Nr. apply rblk_app_l. exists mo. unfold rl, ff_rl. cbn. auto 25.
        - intros ->. apply Nr. apply rblk_app_l. exists Ptrofs.zero. unfold rl, ff_rl. cbn. auto 25.
        - intros Hr. apply Nr. apply rblk_app_r. exact (rgl_rblk b Hr). }
      assert (W1 : Wff G m gp SZ_SURFACE (rl ++ rgl))
        by (apply Wff_rgl; [intros b Hb; exact (proj2 (RGa b Hb)) | exact W]).
      assert (NT : forall id b, Genv.find_symbol G id = Some b -> b <> btab)
        by (intros id b H; exact (proj1 (Sy id b H))).
      assert (Ntab : ~ rblk (rl ++ rgl) btab).
      { intros Hr. destruct (rblk_app_or _ _ _ Hr) as [Hr1 | Hr1].
        - revert Hr1.
          refine (ffw_rl_not G bm m _ btab FWF _ _ _ _); cbn [fw_bo fw_bt];
            first [exact (not_eq_sym (NT _ _ Hbm)) | congruence | exact (fun id _ Hs => NT id btab Hs eq_refl)].
        - destruct (rblk_rgl _ Hr1) as (id & _ & Hs). exact (NT id btab Hs eq_refl). }
      assert (Nga : ~ rblk (rl ++ rgl) bga).
      { pose proof (proj2 (Sy _ _ Sga)) as Gbt.
        intros Hr. destruct (rblk_app_or _ _ _ Hr) as [Hr1 | Hr1].
        - revert Hr1.
          refine (ffw_rl_not_sym G bm m _ _ bga FWF Sga ltac:(vm_compute; reflexivity) _ _ _);
            cbn [fw_bo fw_bt];
            first [ congruence | exact (AnimKeep.symne_ids G _ _ _ _ Sga Hbm eq_refl) | exact (not_eq_sym (AnimKeep.symne_ids G _ _ _ _ Hbm Sga eq_refl)) ].
        - exact (rgb_not _ bga Sga ltac:(vm_compute; reflexivity) (rblk_rgl _ Hr1)). }
      pose proof (anim_base_keep G bm m m' gp (rl ++ rgl) ab bga bauc btab otab bt ot mb mo B W1 Ntab Nga
                    Hnb Hperm Hld (LHm Mint32 136 ltac:(bmk_t)) (LHb Mint32 ab 0 Nab (ab_bm ab S5) Rab)
                    (LHb Mint32 ab 8 Nab (ab_bm ab S5) Rab)
                    (LHm Mint32 144 ltac:(bmk_t)) (LHm Mint32 156 ltac:(bmk_t))) as B'.
      exists ab, bga, bauc, btab, otab, bt, ot, mb, mo. split; [exact B' |].
      intros a La0 Ia. rewrite LHm in La0 by bmk_t. pose proof (ST a La0 Ia) as Sa.
      assert (Rbt : ~ rgb bt) by (intros (id & _ & Hs); exact (proj2 (Sy id bt Hs) eq_refl)).
      destruct Sa as [((i & Li0 & Ni) & C) | (k & Hk & (A1 & A2 & A3 & A4 & Fr & A6))].
      - left. split.
        + exists i. rewrite LHo by (cbn [size_chunk]; lia). split; assumption.
        + rewrite (LHb Mint32 ab 4 Nab (ab_bm ab S5) Rab). exact C.
      - right. exists k. split; [exact Hk |].
        split; [rewrite (LHb Mint32 ab 4 Nab (ab_bm ab S5) Rab); exact A1 |].
        split; [rewrite LHo by (cbn [size_chunk]; lia); exact A2 |].
        split; [rewrite LHo by (cbn [size_chunk]; lia); exact A3 |].
        split; [rewrite LHo by (cbn [size_chunk]; lia); exact A4 |].
        split; [exact (FR bt ot k Hk A3 A4 Fr A6 Z2) |].
        intros rel ch v Hin. rewrite (LHb ch bt _ E3 D2 Rbt). exact (A6 rel ch v Hin).
    Qed.

    (* ---- the level cells ---- *)
    Lemma k_lvl : ffw G bm m -> lvl_w G m -> lvl_w G m'.
    Proof.
      intros Hf Hl.
      apply (AnimKeep.lvl_w_keep_ne G m m' (fun b => b <> mb /\ b <> bm /\ ~ rgb b)); [| | exact Hl].
      - intros b Hs. split; [exact (ffw_ne Hf b (or_intror Hs)) |].
        lvl_cases Hs; (split;
          [ exact (AnimKeep.symne_ids G _ _ _ _ Hs Sbm eq_refl)
          | first [ exact (rgb_not _ b Hs ltac:(vm_compute; reflexivity))
                  | exact (rgb_not_w _ b Hs ltac:(unfold LevelGvars.warp_gvars; simpl; auto 6)) ] ]).
      - intros ch b z (A & B & C). exact (LHb ch b z A B C).
    Qed.

    Lemma k_all : phiw lp bm m -> surf_apart lp bm Xs m -> phiw lp bm m'.
    Proof using HXs HXw Lmo NB PM LD LM Sbm Nbm Bmb RGa CL FR.
      intros (Hh & Hw & Han & Hmo & Hf & Hu & Haw & Hl) RSA.
      assert (Co : forall i cb co, 0 <= i < 4 ->
                Mem.load Mint32 m mb (u mo + FFW_COLL + 4 * i) = Some (Vptr cb co) -> cb = mb).
      { destruct Hf as (_ & EX & _).
        ffw_unpack EX.
        destruct (obj_eq bo oo Lo) as (-> & ->). exact Co. }
      (* Mario's surfaces are not in his own block (the ffw partition) *)
      assert (SNB : forall off sb so, (off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF) ->
                Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> bm).
      { destruct Hf as (_ & EX & _).
        ffw_unpack EX.
        intros off sb so Hoff Hl0 Esb. subst sb.
        destruct Hoff as [-> | [-> | ->]].
        - apply (Wc0 WALL_OFF bm so (or_introl eq_refl) Hl0).
          exists Ptrofs.zero. unfold ff_rl. cbn. auto.
        - apply (Wc0 CEIL_OFF bm so (or_intror eq_refl) Hl0).
          exists Ptrofs.zero. unfold ff_rl. cbn. auto.
        - change FFW_FLOOR with FLOOR_OFF in Lf. rewrite Hl0 in Lf. injection Lf as <-.
          destruct Wf as (b & o & E & _ & _ & _ & Nr). injection E as <- _.
          apply Nr. exists Ptrofs.zero. unfold ff_rl. cbn. auto. }
      split; [exact (k_hi Hh) |]. split; [exact (k_world Hw Hmo RSA SNB Co) |].
      split; [exact (k_anim_apart Hf Han) |]. split; [exact (k_mobj Hmo) |].
      split; [exact (k_ffw Hf) |]. split; [exact (k_used Hu) |].
      split; [exact (k_anim_w Hf Haw) |]. exact (k_lvl Hf Hl).
    Qed.

    (* the same, for a step that writes level cells lvl_w pins and
       re-establishes lvl_w itself (LevelKeep's POST tail) *)
    Lemma k_all_lvl : phiw lp bm m -> surf_apart lp bm Xs m -> lvl_w G m' -> phiw lp bm m'.
    Proof using HXs Lmo NB PM LD LM Sbm Nbm Bmb RGa CL FR.
      intros (Hh & Hw & Han & Hmo & Hf & Hu & Haw & _) RSA Hl'.
      assert (Co : forall i cb co, 0 <= i < 4 ->
                Mem.load Mint32 m mb (u mo + FFW_COLL + 4 * i) = Some (Vptr cb co) -> cb = mb).
      { destruct Hf as (_ & EX & _).
        ffw_unpack EX.
        destruct (obj_eq bo oo Lo) as (-> & ->). exact Co. }
      (* Mario's surfaces are not in his own block (the ffw partition) *)
      assert (SNB : forall off sb so, (off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF) ->
                Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> bm).
      { destruct Hf as (_ & EX & _).
        ffw_unpack EX.
        intros off sb so Hoff Hl0 Esb. subst sb.
        destruct Hoff as [-> | [-> | ->]].
        - apply (Wc0 WALL_OFF bm so (or_introl eq_refl) Hl0).
          exists Ptrofs.zero. unfold ff_rl. cbn. auto.
        - apply (Wc0 CEIL_OFF bm so (or_intror eq_refl) Hl0).
          exists Ptrofs.zero. unfold ff_rl. cbn. auto.
        - change FFW_FLOOR with FLOOR_OFF in Lf. rewrite Hl0 in Lf. injection Lf as <-.
          destruct Wf as (b & o & E & _ & _ & _ & Nr). injection E as <- _.
          apply Nr. exists Ptrofs.zero. unfold ff_rl. cbn. auto. }
      split; [exact (k_hi Hh) |]. split; [exact (k_world Hw Hmo RSA SNB Co) |].
      split; [exact (k_anim_apart Hf Han) |]. split; [exact (k_mobj Hmo) |].
      split; [exact (k_ffw Hf) |]. split; [exact (k_used Hu) |].
      split; [exact (k_anim_w Hf Haw) |]. exact Hl'.
    Qed.
  End KEEP.
  End XG.

  (* ===================================================================== *)
  (* 3. THE RENDER FLANK'S PhiW CARRY.                                     *)
  (* ===================================================================== *)
  Theorem render_keeps_phiw : forall m m',
    phiw lp bm m -> RenderFlank.render_call lp bm m m' -> render_surf_apart lp bm m -> phiw lp bm m'.
  Proof.
    intros m m' Hphi (mb & mo & vh & t & vres & Lmo & Hev) RSA.
    pose proof Hphi as (_ & _ & _ & Hmo & Hf & _ & Haw & _).
    destruct (Hmo mb mo Lmo) as (Smo & _ & _). unfold OBJ_SIZE in Smo.
    pose proof Haw as (ab & bga & bauc & btab & otab & bt & ot & mb' & mo' & B & _).
    pose proof B as (_ & _ & _ & _ & _ & Lm & _ & _ & _ & _ & _ & (_ & RG) & _ & _ & _ & _ & _ & _ & _ & _ & Hbm).
    rewrite Lmo in Lm. injection Lm as <- <-.
    assert (HXR : incl render_gvars flank_gvars) by exact (incl_appl _ (incl_refl _)).
    assert (RGa : forall b, rgb render_gvars b -> b <> mb /\ tab_apart G m b)
      by (intros b (id & Hin & Hs); exact (RG id b (in_or_app _ _ _ (or_introl Hin)) Hs)).
    assert (Nbm : ~ rgb render_gvars bm)
      by exact (rgb_not render_gvars HXR _ bm Hbm ltac:(vm_compute; reflexivity)).
    pose proof Hf as (_ & EX & _).
    destruct EX as (dw & FWF).
    pose proof (ff_HC _ _ _ _ FWF) as HC. pose proof (ff_HS _ _ _ _ FWF) as HS. pose proof (ff_HM _ _ _ _ FWF) as HM.
    pose proof (ff_Lo _ _ _ _ FWF) as Lo. pose proof (ff_D1 _ _ _ _ FWF) as D1.
    set (gp := fw_gp dw) in *.
    change FFW_OBJ with 136 in Lo. rewrite Lmo in Lo.
    assert (Eb : mb = fw_bo dw) by congruence. rewrite <- Eb in D1. clear Lo Eb.
    assert (Bmb : bm <> mb) by (intros E; exact (D1 (eq_sym E))).
    assert (Gmb : gp mb <> None) by exact (closed_load gp m Mint32 bm 136 _ HC HM Lmo).
    pose proof max_mod as Hmax.
    set (oi := Ptrofs.add mo (Ptrofs.repr RENDER_ANIM_OFF)) in *.
    assert (Uoi : u oi = u mo + 56) by (unfold oi, RENDER_ANIM_OFF; apply uadd; lia).
    assert (Hoi : u oi + 16 <= Ptrofs.max_unsigned) by lia.
    pose proof (gsag_footprint G (render_cenv lp H12) (render_guaf lp H12) (render_stv lp H12)
                  m mb oi vh t m' vres Hev) as Fp.
    destruct (rstore_eff render_gvars mb oi m gp Hoi HC Gmb HS (incl_refl _) m m' Fp HC)
      as (NB & PM & LD0 & _).
    assert (LD : forall ch b z, ~ rgb render_gvars b -> b <> bm ->
              (b <> mb \/ z + size_chunk ch <= u mo + 64 \/ u mo + 72 <= z) ->
              Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z Nr _ Hz. apply LD0; [exact Nr |].
      destruct Hz as [Hz | Hz]; [left; exact Hz | right; lia]. }
    assert (LM : forall ch z, bmk ch z -> Mem.load ch m' bm z = Mem.load ch m bm z)
      by (intros ch z _; apply LD0; [exact Nbm | left; exact Bmb]).
    assert (NB' : Ple (Mem.nextblock m) (Mem.nextblock m')) by (rewrite NB; apply Ple_refl).
    assert (PM' : forall b o k p, Plt b (Mem.nextblock m) -> Mem.perm m b o k p -> Mem.perm m' b o k p)
      by (intros b o k p _ Hp; exact (PM b o k p Hp)).
    assert (CL : forall gp', closed_by gp' m -> gp' mb <> None ->
              (forall id b, Genv.find_symbol G id = Some b -> gp' b <> None) ->
              exists gp'', (forall b, gp' b <> None -> gp'' b <> None) /\ closed_by gp'' m').
    { intros gp' HC' G' HS'. exists gp'. split; [exact (fun b H => H) |].
      exact (proj2 (proj2 (proj2
               (rstore_eff render_gvars mb oi m gp' Hoi HC' G' HS' (incl_refl _) m m' Fp HC')))). }
    (* the animFrame the render advance leaves, in a loaded handstand animation *)
    assert (FR : forall bt0 ot0 k, In k hs_ids ->
              Mem.load Mint32 m mb (u mo + 60) = Some (Vptr bt0 ot0) ->
              Mem.load Mint32 m mb (u mo + 72) = Some (Vint Int.zero) ->
              (exists f, -1 <= f <= hs_le k /\ Mem.load Mint16signed m mb (u mo + 64) = Some (Vint (Int.repr f))) ->
              buf_ok m bt0 ot0 k -> u ot0 + BUFSZ < Ptrofs.modulus ->
              exists f, -1 <= f <= hs_le k
                /\ Mem.load Mint16signed m' mb (u mo + 64) = Some (Vint (Int.repr f))).
    { intros bt0 ot0 k Hk L60 L72 (f & Rf & L64) Bk Zb. unfold BUFSZ in Zb.
      assert (Bc : In (6, Mint16signed, BI 0) (buf_cells k) /\ In (8, Mint16signed, BI (hs_le k)) (buf_cells k)
                   /\ (hs_le k = 52 \/ hs_le k = 17)).
      { destruct Hk as [<- | [<- | [<- | []]]]; (split; [| split]);
          first [ right; right; left; reflexivity | right; right; right; left; reflexivity
                | left; reflexivity | right; reflexivity ]. }
      destruct Bc as (B6 & B8 & Hle).
      pose proof (Bk _ _ _ B6) as L6. pose proof (Bk _ _ _ B8) as L8. cbn [bval] in L6, L8.
      assert (U4 : u (Ptrofs.add oi (Ptrofs.repr 4)) = u mo + 60) by (rewrite uadd by lia; lia).
      assert (U8 : u (Ptrofs.add oi (Ptrofs.repr 8)) = u mo + 64) by (rewrite uadd by lia; lia).
      assert (U16 : u (Ptrofs.add oi (Ptrofs.repr 16)) = u mo + 72) by (rewrite uadd by lia; lia).
      assert (V6 : u (Ptrofs.add ot0 (Ptrofs.repr 6)) = u ot0 + 6) by (apply uadd; lia).
      assert (V8 : u (Ptrofs.add ot0 (Ptrofs.repr 8)) = u ot0 + 8) by (apply uadd; lia).
      assert (Hnw : u oi + 20 <= Ptrofs.max_unsigned) by lia.
      assert (Hrg : forall id b, In id render_gvars -> Genv.find_symbol G id = Some b -> b <> mb)
        by (intros id b Hin Hs; exact (proj1 (RG id b (in_or_app _ _ _ (or_introl Hin)) Hs))).
      assert (Pcur : Mem.loadv Mptr m (Vptr mb (Ptrofs.add oi (Ptrofs.repr 4))) = Some (Vptr bt0 ot0))
        by (cbn [Mem.loadv]; rewrite U4; exact L60).
      assert (Pfr : Mem.loadv Mint16signed m (Vptr mb (Ptrofs.add oi (Ptrofs.repr 8))) = Some (Vint (Int.repr f)))
        by (cbn [Mem.loadv]; rewrite U8; exact L64).
      assert (Pacc : Mem.loadv Mint32 m (Vptr mb (Ptrofs.add oi (Ptrofs.repr 16))) = Some (Vint Int.zero))
        by (cbn [Mem.loadv]; rewrite U16; exact L72).
      assert (Pls : Mem.loadv Mint16signed m (Vptr bt0 (Ptrofs.add ot0 (Ptrofs.repr 6))) = Some (Vint (Int.repr 0)))
        by (cbn [Mem.loadv]; rewrite V6; exact L6).
      assert (Plend : Mem.loadv Mint16signed m (Vptr bt0 (Ptrofs.add ot0 (Ptrofs.repr 8)))
                    = Some (Vint (Int.repr (hs_le k))))
        by (cbn [Mem.loadv]; rewrite V8; exact L8).
      assert (Rl : -1 <= Int.signed (Int.repr 0) < Int.signed (Int.repr (hs_le k)))
        by (rewrite !signed_small by lia; lia).
      assert (Rle : Int.signed (Int.repr (hs_le k)) <= 32766) by (rewrite signed_small by lia; lia).
      assert (Rfr : -1 <= Int.signed (Int.repr f) <= Int.signed (Int.repr (hs_le k)))
        by (rewrite !signed_small by lia; lia).
      destruct (gsag_frame G (render_cenv lp H12) (render_guaf lp H12) (render_stv lp H12)
                  m mb oi vh t m' vres bt0 ot0 (Int.repr f) (Int.repr 0) (Int.repr (hs_le k))
                  Hev Hnw Hrg Pcur Pfr Pacc Pls Plend Rl Rle Rfr) as (r & Lr & Rr).
      exists (Int.signed r). split.
      - rewrite signed_small in Rr by lia. exact Rr.
      - rewrite Int.repr_signed. cbn [Mem.loadv] in Lr. rewrite U8 in Lr. exact Lr. }
    clear Fp Hev.
    exact (k_all render_gvars HXR ltac:(intros id Hi Hw; unfold render_gvars in Hi; simpl in Hi; repeat (destruct Hi as [<- | Hi]; [ vm_compute in Hw; intuition discriminate | ]); destruct Hi) m m' mb mo Lmo NB' PM' LD LM Hbm Nbm Bmb RGa CL FR Hphi RSA).
  Qed.
End RK.
