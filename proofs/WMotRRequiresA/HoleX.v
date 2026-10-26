(* ======================================================================= *)
(* HoleX (GOAL 2, 2026-10-25): ProRows' hole, generalised to a set of     *)
(* global blocks and two more windows of Mario's object.                  *)
(*                                                                         *)
(* ProRows.HOLE keeps the frame world (FrameSplit.fworld) and the height  *)
(* cells across a call that changes only two region globals (xsym), the   *)
(* hole of Mario's state block (hz: m->flags, bytes 174..183) and one     *)
(* window of Mario's object between bytes 36 and 56.  HOLEX allows, on   *)
(* top of that:                                                           *)
(*   - any number of region globals (ProRows.xsym) and any globals of a   *)
(*     list XG none of whose ids is a world global (safe_ids: the blocks  *)
(*     a world fact reads or pins: gMarioStates, gObjectPool, the         *)
(*     animation list and data, gAreaData, the controller, the level     *)
(*     cells and the collision partition's arrays);                       *)
(*   - Mario's object's gfx.node.flags (bytes 2..3) and hitboxHeight      *)
(*     (bytes 508..511).                                                  *)
(* The changed globals are kept off the world by the frame world's own   *)
(* facts (FfWorld, 2026-10-25): the surfaces and the DMA buffer are       *)
(* dynamic blocks (ff_Spl, ff_Dbt), Mario's object is a gObjectPool slot  *)
(* (ff_Spool), m->controller is gControllers (ff_Sctl), a collided object *)
(* is a slot apart from Mario's (ff_Cd).  The world fact over the walk's  *)
(* regions extends over the changed globals (AnimWorld.Wff_global: a      *)
(* global is off every partition list).                                   *)
(* Consumer: HitboxRow (mario_update_hitbox_and_cap_model: the cap music  *)
(* globals, gBodyStates, the blink and hitboxHeight).                     *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Globalenvs Ctypes Clight.
From SM64.Generated Require mario level_update object_list_processor area game_init camera
  audio_external mario_actions_moving.
From SM64.Proofs Require Import AGates SymbolicLinking RealFrameValue RealFrameLinked.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec FfWorld ProRows.
From SM64.Proofs.WMotRRequiresA Require AnimWorld AnimKeep.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
Import ListNotations.

Section HX.
  Variable lp : Clight.program.
  Variable bm : block.
  Notation ge := (lp_ge lp).

  (* the globals a world fact reads or pins *)
  Definition safe_ids : list ident :=
    [level_update._gMarioStates; mario._gMarioState; object_list_processor._gObjectPool;
     mario._gMarioAnimsBuf; game_init._gMarioAnims; area._gAreaData; mario._gControllers]
    ++ lvl_ids ++ part_ids.

  (* the changed globals besides the regions *)
  Variable XG : list ident.
  Hypothesis XGok : forallb (fun id => negb (existsb (Pos.eqb id) safe_ids)) XG = true.

  Definition xg (b : block) : Prop := exists id, In id XG /\ Genv.find_symbol ge id = Some b.
  Definition chg (b : block) : Prop := xsym lp b \/ xg b.

  Lemma xg_not_safe : forall id b, Genv.find_symbol ge id = Some b ->
    existsb (Pos.eqb id) safe_ids = true -> ~ xg b.
  Proof.
    intros id b Hs T (id' & Hin & Hs').
    assert (E : id' = id) by (eapply Genv.genv_vars_inj; [exact Hs' | exact Hs]). subst id'.
    pose proof (proj1 (forallb_forall _ _) XGok id Hin) as N. cbn beta in N.
    rewrite T in N. discriminate N.
  Qed.

  Lemma xg_dyn : forall b, Ple (Genv.genv_next ge) b -> ~ xg b.
  Proof.
    intros b P (id & _ & Hs). pose proof (Genv.genv_symb_range _ _ Hs) as L.
    unfold Plt, Ple in *. lia.
  Qed.

  Lemma nchg_safe : forall id b, Genv.find_symbol ge id = Some b ->
    existsb (Pos.eqb id) XIDS = false -> existsb (Pos.eqb id) safe_ids = true -> ~ chg b.
  Proof.
    intros id b Hs N T [X | X].
    - exact (xsym_ne lp b id b X Hs N eq_refl).
    - exact (xg_not_safe id b Hs T X).
  Qed.

  Lemma nchg_lvl : forall b, lvl_sym ge b -> ~ chg b.
  Proof.
    intros b (id & Hin & Hs). apply (nchg_safe id b Hs).
    - unfold lvl_ids in Hin. cbn [In] in Hin.
      repeat (destruct Hin as [<- | Hin]; [vm_compute; reflexivity |]). destruct Hin.
    - apply existsb_exists. exists id. split; [| apply Pos.eqb_refl].
      unfold safe_ids. apply in_or_app. right. apply in_or_app. left. exact Hin.
  Qed.

  (* the changed globals as a region list *)
  Fixpoint xgl_of (L : list ident) : list (option val) :=
    match L with
    | [] => []
    | id :: L' => match Genv.find_symbol ge id with
                  | Some b => Some (Vptr b Ptrofs.zero) :: xgl_of L'
                  | None => xgl_of L'
                  end
    end.

  Lemma rblk_xgl_of : forall L b, rblk (xgl_of L) b ->
    exists id, In id L /\ Genv.find_symbol ge id = Some b.
  Proof.
    induction L as [| id L IH]; intros b (o & Hin); [destruct Hin |].
    cbn [xgl_of] in Hin. destruct (Genv.find_symbol ge id) as [b'|] eqn:Hs.
    - destruct Hin as [E | Hin].
      + injection E as -> _. exists id. split; [left; reflexivity | exact Hs].
      + destruct (IH b (ex_intro _ o Hin)) as (id' & H1 & H2). exists id'. split; [right; exact H1 | exact H2].
    - destruct (IH b (ex_intro _ o Hin)) as (id' & H1 & H2). exists id'. split; [right; exact H1 | exact H2].
  Qed.

  Lemma xgl_of_rblk : forall L id b, In id L -> Genv.find_symbol ge id = Some b -> rblk (xgl_of L) b.
  Proof.
    induction L as [| id0 L IH]; intros id b Hin Hs; [destruct Hin |].
    cbn [xgl_of]. destruct Hin as [<- | Hin].
    - rewrite Hs. exists Ptrofs.zero. left. reflexivity.
    - destruct (IH id b Hin Hs) as (o & Ho). exists o.
      destruct (Genv.find_symbol ge id0); [right; exact Ho | exact Ho].
  Qed.

  Definition xgl : list (option val) := xgl_of XG.

  Lemma rblk_xgl : forall b, rblk xgl b -> xg b.
  Proof. intros b H. exact (rblk_xgl_of XG b H). Qed.

  Lemma xgl_rblk : forall b, xg b -> rblk xgl b.
  Proof. intros b (id & Hin & Hs). exact (xgl_of_rblk XG id b Hin Hs). Qed.

  Lemma hx_app_or : forall a c b, rblk (a ++ c) b -> rblk a b \/ rblk c b.
  Proof.
    intros a c b (o & Hin). apply in_app_or in Hin as [H | H]; [left | right]; exists o; exact H.
  Qed.

  Lemma hx_app_l : forall a c b, rblk a b -> rblk (a ++ c) b.
  Proof. intros a c b (o & Hin). exists o. apply in_or_app. left. exact Hin. Qed.

  Lemma hx_app_r : forall a c b, rblk c b -> rblk (a ++ c) b.
  Proof. intros a c b (o & Hin). exists o. apply in_or_app. right. exact Hin. Qed.

  (* the world fact extends over the changed globals: none is a partition
     array, and a global is off every partition list *)
  Lemma Wff_xgl_of : forall L m gp vs, incl L XG ->
    Wff ge m gp SZ_SURFACE vs -> Wff ge m gp SZ_SURFACE (vs ++ xgl_of L).
  Proof.
    induction L as [| id L IH]; intros m gp vs Hi W.
    - cbn [xgl_of]. rewrite app_nil_r. exact W.
    - cbn [xgl_of]. destruct (Genv.find_symbol ge id) as [b|] eqn:Hs.
      + replace (vs ++ Some (Vptr b Ptrofs.zero) :: xgl_of L)
          with ((vs ++ [Some (Vptr b Ptrofs.zero)]) ++ xgl_of L) by (rewrite <- app_assoc; reflexivity).
        apply IH; [intros x Hx; apply Hi; right; exact Hx |].
        apply (AnimWorld.Wff_global ge m gp SZ_SURFACE vs id b Ptrofs.zero Hs); [| exact W].
        intros Hp.
        assert (T : existsb (Pos.eqb id) safe_ids = true).
        { apply existsb_exists. exists id. split; [| apply Pos.eqb_refl].
          unfold safe_ids. apply in_or_app. right. apply in_or_app. right. exact Hp. }
        pose proof (proj1 (forallb_forall _ _) XGok id (Hi id (or_introl eq_refl))) as N. cbn beta in N.
        rewrite T in N. discriminate N.
      + apply IH; [intros x Hx; apply Hi; right; exact Hx | exact W].
  Qed.

  Lemma Wff_xgl : forall m gp vs, Wff ge m gp SZ_SURFACE vs -> Wff ge m gp SZ_SURFACE (vs ++ xgl).
  Proof. intros m gp vs W. exact (Wff_xgl_of XG m gp vs (incl_refl _) W). Qed.

  Section HOLEX.
    Variables (m m' : mem) (ob : block) (oo0 : ptrofs) (ow wl : Z).
    Hypothesis Hbm : Genv.find_symbol ge level_update._gMarioStates = Some bm.
    (* Mario's object, and the optional third window of it (ProRows.HOLE's;
       wl = 0 for none) *)
    Hypothesis OBJ : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr ob oo0).
    Hypothesis NBO : bm <> ob.
    Hypothesis OWL : 36 <= ow /\ 0 <= wl /\ ow + wl <= 56.
    Hypothesis NB : Ple (Mem.nextblock m) (Mem.nextblock m').
    Hypothesis PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p.

    (* a span of Mario's object (relative offset k, size s) off the windows *)
    Definition ohz (k s : Z) : Prop :=
      (k + s <= 2 \/ 4 <= k) /\ (k + s <= ow \/ ow + wl <= k) /\ (k + s <= 508 \/ 512 <= k).
    Definition ozx (b : block) (z s : Z) : Prop := b <> ob \/ ohz (z - Ptrofs.unsigned oo0) s.

    Hypothesis LD : forall ch b z, ~ chg b -> (b <> bm \/ hz z (size_chunk ch)) ->
      ozx b z (size_chunk ch) -> Mem.load ch m' b z = Mem.load ch m b z.
    Hypothesis CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp'.

    Lemma NCbm : ~ chg bm.
    Proof.
      apply (nchg_safe _ _ Hbm); [vm_compute; reflexivity |].
      apply existsb_exists. exists level_update._gMarioStates. split; [left; reflexivity | apply Pos.eqb_refl].
    Qed.

    Lemma LXz : forall ch b z, b <> bm -> ~ chg b -> ozx b z (size_chunk ch) ->
      Mem.load ch m' b z = Mem.load ch m b z.
    Proof. intros ch b z H1 H2 H3. exact (LD ch b z H2 (or_introl H1) H3). Qed.

    Lemma LXm : forall ch z, hz z (size_chunk ch) -> Mem.load ch m' bm z = Mem.load ch m bm z.
    Proof. intros ch z H. exact (LD ch bm z NCbm (or_intror H) (or_introl NBO)). Qed.

    Lemma ozx_ne : forall b z s, b <> ob -> ozx b z s.
    Proof. intros b z s H. left. exact H. Qed.

    Lemma ozx_k : forall k s, ohz k s -> ozx ob (Ptrofs.unsigned oo0 + k) s.
    Proof. intros k s H. right. replace (Ptrofs.unsigned oo0 + k - Ptrofs.unsigned oo0) with k by lia. exact H. Qed.

    Lemma ozx_span : forall co k s, Ptrofs.unsigned co + 608 <= Ptrofs.unsigned oo0
        \/ Ptrofs.unsigned oo0 + 608 <= Ptrofs.unsigned co ->
      0 <= k -> 0 <= s -> k + s <= 608 -> ozx ob (Ptrofs.unsigned co + k) s.
    Proof. intros co k s H K1 K0 K2. right. unfold ohz. pose proof OWL. destruct H; lia. Qed.

    Ltac hxm := rewrite LXm by hside.
    Ltac hxm_in H := rewrite LXm in H by hside.
    Ltac ok_t := unfold ohz, O_INTERACT_STATUS, NUMCOLL_OFF, COLL_OFF, RAW_OFF, POLEPOS_OFF,
                   FFW_COLL, FFW_THROW, OFS_GFXY, RAW_OFF; cbn [size_chunk]; pose proof OWL; lia.

    (* the world's pointers are off the changes *)
    Lemma hx_facts : ffw ge bm m ->
      ob <> bm /\ ~ chg ob
      /\ (forall off sb so, off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF ->
            Mem.load Mint32 m bm off = Some (Vptr sb so) -> sb <> bm /\ ~ chg sb /\ sb <> ob)
      /\ (forall bc oc, Mem.load Mint32 m bm FFW_CTL = Some (Vptr bc oc) -> bc <> bm /\ ~ chg bc /\ bc <> ob).
    Proof.
      intros (_ & EX & _). ffw_unpack EX.
      assert (Lo' : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
      rewrite OBJ in Lo'. injection Lo' as E1 E2. subst bo oo.
      match type of W with Wff _ _ _ _ ?rl0 => set (rl := rl0) in * end.
      assert (NR : forall b, ~ rblk rl b -> b <> bm /\ ~ xsym lp b /\ b <> ob).
      { intros b Hn. split; [| split].
        - intros ->. apply Hn. exists Ptrofs.zero. unfold rl, ff_rl. cbn. auto 20.
        - intros X. apply Hn. pose proof (xsym_ffw lp bm b m _ X FWF) as (R & _). ffw_simpl_in R. exact R.
        - intros ->. apply Hn. exists oo0. unfold rl, ff_rl. cbn. auto 20. }
      assert (Sf : forall sb, Ple (Genv.genv_next ge) sb -> ~ rblk rl sb ->
                sb <> bm /\ ~ chg sb /\ sb <> ob).
      { intros sb P Hn. destruct (NR sb Hn) as (A & B & C). split; [exact A |]. split; [| exact C].
        intros [X | X]; [exact (B X) | exact (xg_dyn sb P X)]. }
      split; [exact D1 |]. split; [| split].
      - intros [X | X].
        + pose proof (xsym_ffw lp bm ob m _ X FWF) as (_ & N & _). ffw_simpl_in N. exact (N eq_refl).
        + refine (xg_not_safe _ _ Spool _ X). vm_compute. reflexivity.
      - intros off sb so Hoff Hl. apply (Sf sb).
        + apply (Spl off sb so); [| exact Hl].
          destruct Hoff as [-> | [-> | ->]]; [left | right; left | right; right]; reflexivity.
        + destruct Hoff as [-> | [-> | ->]].
          * exact (Wc0 FFW_WALL sb so (or_introl eq_refl) Hl).
          * exact (Wc0 FFW_CEIL sb so (or_intror eq_refl) Hl).
          * change FLOOR_OFF with FFW_FLOOR in Hl. rewrite Lf in Hl. injection Hl as ->.
            destruct Wf as (b' & o' & E & _ & _ & _ & Nr). injection E as <- _. exact Nr.
      - intros bc oc Hl. rewrite Lc in Hl. injection Hl as ->.
        destruct Wc as (b' & o' & E & _ & _ & _ & Nr). injection E as <- _.
        destruct (NR bc Nr) as (A & B & C). split; [exact A |]. split; [| exact C].
        intros [X | X]; [exact (B X) |].
        refine (xg_not_safe _ _ (Sctl bc oc eq_refl) _ X). vm_compute. reflexivity.
    Qed.

    (* the height cells *)
    Lemma hx_cells : forall c, 40 <= ow \/ ow + wl <= 36 ->
      ffw ge bm m -> read_cells bm m c -> read_cells bm m' c.
    Proof.
      intros c HG Hf (H1 & H2 & H3 & H4 & H5 & H6 & bo & oo & H7 & H8).
      destruct (hx_facts Hf) as (O1 & O2 & _).
      split; [hxm; exact H1 |]. split; [hxm; exact H2 |]. split; [hxm; exact H3 |].
      split; [hxm; exact H4 |]. split; [hxm; exact H5 |]. split; [hxm; exact H6 |].
      exists bo, oo. split; [hxm; exact H7 |].
      assert (H7' : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact H7.
      rewrite OBJ in H7'. injection H7' as <- <-.
      rewrite LXz; [exact H8 | exact O1 | exact O2 |].
      apply ozx_k. unfold ohz, OFS_GFXY. cbn [size_chunk]. pose proof OWL. lia.
    Qed.

    Lemma hx_fresh_at : fresh_at bm m -> fresh_at bm m'.
    Proof.
      intros (H & I). split.
      - intros a La Hg. hxm_in La. intros y fh Ly Lf. hxm_in Ly. hxm_in Lf.
        destruct (H a La Hg y fh Ly Lf) as (A & [B | B]); (split; [exact A |]);
          [left; hxm; exact B | right; exact B].
      - apply (inputs_ok_keep bm m m'); [hxm; reflexivity | hxm; reflexivity | exact I].
    Qed.

    (* the frame world's own fact *)
    Lemma hx_ffw : ffw ge bm m -> ffw ge bm m'.
    Proof.
      intros Hf. pose proof Hf as (Hgn & EX & FD).
      destruct (hx_facts Hf) as (O1 & O2 & _).
      ffw_unpack EX.
      assert (Lo' : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
      rewrite OBJ in Lo'. injection Lo' as E1 E2. subst bo oo.
      match type of W with Wff _ _ _ _ ?rl0 => set (rl := rl0) in * end.
      assert (NR : forall b, ~ rblk (rl ++ xgl) b -> b <> bm /\ ~ chg b /\ b <> ob).
      { intros b Hn. split; [| split].
        - intros ->. apply Hn. apply hx_app_l. exists Ptrofs.zero. unfold rl, ff_rl. cbn. auto 20.
        - intros [X | X].
          + apply Hn. apply hx_app_l. pose proof (xsym_ffw lp bm b m _ X FWF) as (R & _). ffw_simpl_in R. exact R.
          + apply Hn. apply hx_app_r. exact (xgl_rblk b X).
        - intros ->. apply Hn. apply hx_app_l. exists oo0. unfold rl, ff_rl. cbn. auto 20. }
      assert (Hperm : forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
        by (intros b ofs k p _ Hp; exact (PM b ofs k p Hp)).
      assert (Hld : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (rl ++ xgl) b ->
                Mem.load ch m' b z = Mem.load ch m b z).
      { intros ch b z _ Nr. destruct (NR b Nr) as (A & B & C). exact (LXz ch b z A B (ozx_ne _ _ _ C)). }
      assert (W1 : Wff ge m gp SZ_SURFACE (rl ++ xgl)) by exact (Wff_xgl m gp rl W).
      destruct (CLK gp HC HS HM) as (gp' & Hinc & HC' & HS').
      assert (W2 : Wff ge m' gp' SZ_SURFACE (rl ++ xgl))
        by exact (Wff_keep2 ge m m' (rl ++ xgl) NB Hperm Hld gp gp' Hinc W1).
      assert (Nab : ab <> bm) by exact (AnimKeep.symne_ids ge _ _ _ _ S5 Hbm eq_refl).
      assert (Cab : ~ chg ab) by (apply (nchg_safe _ _ S5); vm_compute; reflexivity).
      assert (Nabo : ab <> ob) by exact (proj1 (D4 ab ltac:(left; cbn; auto 10))).
      apply (ffw_rebuild ge bm m m' _ gp' FWF (Ple_trans _ _ _ Hgn NB) NB Hinc HC').
      - exact (AnimWorld.Wff_mono ge m' gp' SZ_SURFACE (rl ++ xgl) rl (fun b H => hx_app_l _ _ b H) W2).
      - exact (floor_data_keep2 ge m m' (rl ++ xgl) NB Hperm Hld gp W1 FD).
      - intros ch b z Hr. ffw_read_split Hr;
          first [ solve [apply LXm; hside]
                | solve [exact (LXz Mint32 ab 8 Nab Cab (ozx_ne _ _ _ Nabo))]
                | solve [rewrite <- Z.add_assoc; apply LXz; [exact O1 | exact O2 |]; apply ozx_k; ok_t]
                | solve [apply LXz; [exact O1 | exact O2 |]; apply ozx_k; ok_t] ].
      - apply (ffw_surf_ok_kept ge bm m m' _ FWF). intros z ch Hin. apply LXm.
        unfold ffw_surf_cells in Hin. cbn [In] in Hin.
        destruct Hin as [E | [E | [E | []]]]; injection E as <- <-; hside.
    Qed.

    (* a collided object a whole Object away from Mario's *)
    Lemma hx_coll : forall co, ob <> bm -> ~ chg ob ->
      Ptrofs.unsigned co + 608 <= Ptrofs.unsigned oo0 \/ Ptrofs.unsigned oo0 + 608 <= Ptrofs.unsigned co ->
      coll_obj_ok m (Vptr ob co) -> coll_obj_ok m' (Vptr ob co).
    Proof.
      intros co N1 N2 Sp (b & o & t & E & Lt & Hin & Hp & Hc). injection E as <- <-.
      assert (K : forall ch k, size_chunk ch = 4 ->
                  k = O_POSY \/ k = O_INTERACT_TYPE \/ k = HITBOX_H_OFF \/ k = HITBOX_DOWN_OFF ->
                  Mem.load ch m' ob (Ptrofs.unsigned co + k) = Mem.load ch m ob (Ptrofs.unsigned co + k)).
      { intros ch k Hs Hk. apply LXz; [exact N1 | exact N2 |]. rewrite Hs.
        apply ozx_span; [exact Sp | | lia |];
          unfold O_POSY, O_INTERACT_TYPE, HITBOX_H_OFF, HITBOX_DOWN_OFF, RAW_OFF in Hk; lia. }
      exists ob, co, t. split; [reflexivity |].
      split; [rewrite K; [exact Lt | reflexivity | right; left; reflexivity] |].
      split; [exact Hin |]. split.
      - intros Ht. destruct (Hp Ht) as (base & top & Hi & P1 & P2 & P3).
        exists base, top. split; [exact Hi |]. rewrite !K by (reflexivity || tauto). tauto.
      - intros Ht. destruct (Hc Ht) as (y & Hi & P1).
        exists y. split; [exact Hi |]. rewrite K by (reflexivity || tauto). exact P1.
    Qed.

    Lemma hx_world : ffw ge bm m -> wmotr_world bm m -> wmotr_world bm m'.
    Proof.
      intros Hf (Hw & Hc & Hfl & Hh & Hr & Hq & Ho).
      pose proof Hf as (_ & EX & _).
      destruct (hx_facts Hf) as (O1 & O2 & As & _).
      ffw_unpack EX.
      assert (Lo' : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
      rewrite OBJ in Lo'. injection Lo' as E1 E2. subst bo oo.
      split; [| split; [| split; [| split; [| split; [| split]]]]].
      - intros v Hl. hxm_in Hl. destruct (Hw v Hl) as [-> | (b & o & t & -> & Lt & Hin)]; [left; reflexivity |].
        right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        destruct (As WALL_OFF b o (or_introl eq_refl) Hl) as (N1 & N2 & N3).
        rewrite LXz by (first [assumption | apply ozx_ne; exact N3]). exact Lt.
      - intros v Hl. hxm_in Hl. destruct (Hc v Hl) as [-> | (b & o & t & -> & Lt & Hin)]; [left; reflexivity |].
        right. exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        destruct (As CEIL_OFF b o (or_intror (or_introl eq_refl)) Hl) as (N1 & N2 & N3).
        rewrite LXz by (first [assumption | apply ozx_ne; exact N3]). exact Lt.
      - intros v Hl. hxm_in Hl. destruct (Hfl v Hl) as (b & o & t & -> & Lt & Hin).
        exists b, o, t. split; [reflexivity |]. split; [| exact Hin].
        destruct (As FLOOR_OFF b o (or_intror (or_intror eq_refl)) Hl) as (N1 & N2 & N3).
        rewrite LXz by (first [assumption | apply ozx_ne; exact N3]). exact Lt.
      - hxm. exact Hh.
      - hxm. exact Hr.
      - hxm. exact Hq.
      - destruct Ho as (mb & mo & s & n & Hl & Ls & Hs & Ln & Hn & Hall).
        rewrite OBJ in Hl. injection Hl as <- <-.
        exists ob, oo0, s, n. split; [hxm; exact OBJ |].
        split; [rewrite LXz; [exact Ls | exact O1 | exact O2 |]; apply ozx_k; ok_t |].
        split; [exact Hs |].
        split; [rewrite LXz; [exact Ln | exact O1 | exact O2 |]; apply ozx_k; ok_t |].
        split; [exact Hn |].
        intros i v Hi Hl2. assert (Hi4 : 0 <= i < 4) by lia.
        rewrite LXz in Hl2; [| exact O1 | exact O2 | rewrite <- Z.add_assoc; apply ozx_k; ok_t].
        pose proof (Hall i v Hi Hl2) as Hok. pose proof Hok as (cb & co & t & -> & _).
        change COLL_OFF with FFW_COLL in Hl2.
        pose proof (Co i cb co Hi4 Hl2) as Ecb. subst cb.
        exact (hx_coll co O1 O2 (Cd i ob co Hi4 Hl2) Hok).
    Qed.

    Lemma hx_anim : ffw ge bm m -> anim_apart lp bm m -> anim_apart lp bm m'.
    Proof.
      intros Hf Han ab bt ot Hs Hl.
      pose proof Hf as (_ & EX & _).
      destruct (hx_facts Hf) as (O1 & O2 & _).
      ffw_unpack EX.
      assert (Eab : ab0 = ab) by congruence. subst ab0.
      assert (Lo' : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
      rewrite OBJ in Lo'. injection Lo' as E1 E2. subst bo oo.
      assert (Nab : ab <> bm) by exact (AnimKeep.symne_ids ge _ _ _ _ Hs Hbm eq_refl).
      assert (Cab : ~ chg ab) by (apply (nchg_safe _ _ Hs); vm_compute; reflexivity).
      assert (Nabo : ab <> ob) by exact (proj1 (D4 ab ltac:(left; cbn; auto 10))).
      rewrite (LXz Mptr ab 8 Nab Cab (ozx_ne _ _ _ Nabo)) in Hl.
      destruct (Han ab bt ot Hs Hl) as (A1 & A2). split.
      - intros off sb so Hoff Hl'.
        destruct Hoff as [-> | [-> | ->]]; hxm_in Hl';
          [exact (A1 WALL_OFF sb so (or_introl eq_refl) Hl')
          | exact (A1 CEIL_OFF sb so (or_intror (or_introl eq_refl)) Hl')
          | exact (A1 FLOOR_OFF sb so (or_intror (or_intror eq_refl)) Hl')].
      - intros mb mo i cb co Hl' Hi Hl2. hxm_in Hl'.
        assert (Hl0 := Hl'). rewrite OBJ in Hl0. injection Hl0 as <- <-.
        rewrite LXz in Hl2; [| exact O1 | exact O2 | rewrite <- Z.add_assoc; apply ozx_k; ok_t].
        exact (A2 ob oo0 i cb co Hl' Hi Hl2).
    Qed.

    Lemma hx_mobj : ffw ge bm m -> mobj_apart bm m -> mobj_apart bm m'.
    Proof.
      intros Hf Hmo mb mo Hl.
      destruct (hx_facts Hf) as (O1 & O2 & _).
      hxm_in Hl.
      assert (Hl0 := Hl). rewrite OBJ in Hl0. injection Hl0 as <- <-.
      destruct (Hmo ob oo0 Hl) as (P1 & P2 & P3).
      split; [exact P1 |]. split.
      - intros off sb so Hoff Hl'.
        destruct Hoff as [-> | [-> | ->]]; hxm_in Hl';
          [exact (P2 WALL_OFF sb so (or_introl eq_refl) Hl')
          | exact (P2 CEIL_OFF sb so (or_intror (or_introl eq_refl)) Hl')
          | exact (P2 FLOOR_OFF sb so (or_intror (or_intror eq_refl)) Hl')].
      - intros i cb co Hi Hl'.
        rewrite LXz in Hl'; [| exact O1 | exact O2 | rewrite <- Z.add_assoc; apply ozx_k; ok_t].
        exact (P3 i cb co Hi Hl').
    Qed.

    Lemma hx_adown : ffw ge bm m -> a_down_real bm m' = a_down_real bm m.
    Proof.
      intros Hf. destruct (hx_facts Hf) as (_ & _ & _ & Ac).
      unfold a_down_real. hxm.
      destruct (Mem.load Mptr m bm 156) as [[] |] eqn:E; try reflexivity.
      destruct (Ac _ _ E) as (N1 & N2 & N3).
      rewrite LXz by (first [assumption | apply ozx_ne; exact N3]). reflexivity.
    Qed.

    Lemma hx_used : ffw ge bm m -> used_ok bm m -> used_ok bm m'.
    Proof.
      intros Hf U a La. hxm_in La. destruct (U a La) as (U1 & U2).
      destruct (hx_facts Hf) as (N1 & N2 & _).
      assert (K136 : Mem.load Mint32 m' bm MARIOOBJ_OFF = Mem.load Mint32 m bm MARIOOBJ_OFF) by (hxm; reflexivity).
      assert (Ap : forall ub uo, used_apart bm m ub uo -> used_apart bm m' ub uo).
      { intros ub uo A. split; [exact (proj1 A) |]. intros mb mo Hl. rewrite K136 in Hl. exact (proj2 A mb mo Hl). }
      (* a field of the used object, a whole Object away from Mario's *)
      assert (KU : forall uo ch k, used_apart bm m ob uo -> 0 <= k -> k + size_chunk ch <= 608 ->
                 Mem.load ch m' ob (Ptrofs.unsigned uo + k) = Mem.load ch m ob (Ptrofs.unsigned uo + k)).
      { intros uo ch k A K1 K2. apply LXz; [exact N1 | exact N2 |].
        destruct (proj2 A ob oo0 OBJ) as [E | E]; [exfalso; exact (E eq_refl) |].
        apply ozx_span; [unfold OBJ_SPAN in E; exact E | exact K1 | pose proof (size_chunk_pos ch); lia | exact K2]. }
      split.
      - intros Hp. destruct (U1 Hp) as (ub & uo & Lu & (base & top & Hin & Ht & P1 & P2 & P3) & A & (S & PP) & V).
        destruct (PP ob oo0 OBJ) as (Eu & p & Lp & Fp & Rp). subst ub.
        exists ob, uo. split; [hxm; exact Lu |].
        split; [| split; [exact (Ap _ _ A) | split]].
        + exists base, top. split; [exact Hin |]. split; [exact Ht |].
          rewrite !KU by (first [exact A | unfold O_POSY, HITBOX_DOWN_OFF, HITBOX_H_OFF, RAW_OFF; cbn [size_chunk]; lia]).
          auto.
        + split; [exact S |]. intros mb mo Hl. rewrite K136, OBJ in Hl. injection Hl as <- <-.
          split; [reflexivity |]. exists p.
          rewrite LXz; [exact (conj Lp (conj Fp Rp)) | exact N1 | exact N2 |].
          apply ozx_k. ok_t.
        + intros w Lv. hxm_in Lv. exact (V w Lv).
      - intros Hcn. destruct (U2 Hcn) as (ub & uo & Lu & (y & Hin & P1) & A & (S & CP)).
        destruct (CP ob oo0 OBJ) as (Eu & CC). subst ub.
        exists ob, uo. split; [hxm; exact Lu |]. split; [| split; [exact (Ap _ _ A) |]].
        + exists y. split; [exact Hin |].
          rewrite KU by (first [exact A | unfold O_POSY, RAW_OFF; cbn [size_chunk]; lia]). exact P1.
        + split; [exact S |]. intros mb mo Hl. rewrite K136, OBJ in Hl. injection Hl as <- <-.
          split; [reflexivity |]. intros i cb co Hi Hl2.
          rewrite LXz in Hl2; [| exact N1 | exact N2 | rewrite <- Z.add_assoc; apply ozx_k; ok_t].
          exact (CC i cb co Hi Hl2).
    Qed.

    (* the animation world: the base over the regions and the changed
       globals (AnimWorld.anim_base_keep), the state's cells kept *)
    Lemma hx_anim_w : ffw ge bm m -> AnimWorld.anim_w ge bm m -> AnimWorld.anim_w ge bm m'.
    Proof.
      intros Hf AW. pose proof Hf as (Hgn & EX & FD).
      destruct (hx_facts Hf) as (O1 & O2 & _).
      ffw_unpack EX.
      assert (Lo' : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
      rewrite OBJ in Lo'. injection Lo' as E1 E2. subst bo oo.
      destruct AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb' & mo' & B & ST).
      pose proof B as (Sab & Sga & Sau & L0 & L8 & Lm & Sy & Q1 & Q2 & Q3 & Q4 & _ & _ & _ & _ & _ & _ & _ & _ & _ & _).
      assert (ab' = ab) by congruence. subst ab'.
      rewrite Lb in L8. injection L8 as <- <-.
      change 136 with MARIOOBJ_OFF in Lm. rewrite OBJ in Lm. injection Lm as <- <-.
      match type of W with Wff _ _ _ _ ?rl0 => set (rl := rl0) in * end.
      assert (NR : forall b, ~ rblk (rl ++ xgl) b -> b <> bm /\ ~ chg b /\ b <> ob).
      { intros b Hn. split; [| split].
        - intros ->. apply Hn. apply hx_app_l. exists Ptrofs.zero. unfold rl, ff_rl. cbn. auto 20.
        - intros [X | X].
          + apply Hn. apply hx_app_l. pose proof (xsym_ffw lp bm b m _ X FWF) as (R & _). ffw_simpl_in R. exact R.
          + apply Hn. apply hx_app_r. exact (xgl_rblk b X).
        - intros ->. apply Hn. apply hx_app_l. exists oo0. unfold rl, ff_rl. cbn. auto 20. }
      assert (Hperm : forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
        by (intros b ofs k p _ Hp; exact (PM b ofs k p Hp)).
      assert (Hld : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (rl ++ xgl) b ->
                Mem.load ch m' b z = Mem.load ch m b z).
      { intros ch b z _ Nr. destruct (NR b Nr) as (A & Bc & C). exact (LXz ch b z A Bc (ozx_ne _ _ _ C)). }
      assert (W1 : Wff ge m gp SZ_SURFACE (rl ++ xgl)) by exact (Wff_xgl m gp rl W).
      assert (NT : forall id b, Genv.find_symbol ge id = Some b -> b <> btab)
        by (intros id b H; exact (proj1 (Sy id b H))).
      assert (Ntab : ~ rblk (rl ++ xgl) btab).
      { intros Hr. destruct (hx_app_or _ _ _ Hr) as [Hr1 | Hr1].
        - revert Hr1.
          refine (ffw_rl_not ge bm m _ btab FWF _ _ _ _); cbn [fw_bo fw_bt];
            first [exact (not_eq_sym (NT _ _ Hbm)) | congruence | exact (fun id _ Hs => NT id btab Hs eq_refl)].
        - destruct (rblk_xgl _ Hr1) as (id & _ & Hs). exact (NT id btab Hs eq_refl). }
      assert (Nga : ~ rblk (rl ++ xgl) bga).
      { pose proof (proj2 (Sy _ _ Sga)) as Gbt.
        intros Hr. destruct (hx_app_or _ _ _ Hr) as [Hr1 | Hr1].
        - revert Hr1.
          refine (ffw_rl_not_sym ge bm m _ _ bga FWF Sga ltac:(vm_compute; reflexivity) _ _ _);
            cbn [fw_bo fw_bt];
            first [ congruence | exact (AnimKeep.symne_ids ge _ _ _ _ Sga Hbm eq_refl)
                  | exact (not_eq_sym (AnimKeep.symne_ids ge _ _ _ _ Hbm Sga eq_refl)) ].
        - refine (xg_not_safe _ _ Sga _ (rblk_xgl _ Hr1)). vm_compute. reflexivity. }
      assert (Nab : ab <> bm) by exact (AnimKeep.symne_ids ge _ _ _ _ S5 Hbm eq_refl).
      assert (Cab : ~ chg ab) by (apply (nchg_safe _ _ S5); vm_compute; reflexivity).
      assert (Nabo : ab <> ob) by exact (proj1 (D4 ab ltac:(left; cbn; auto 10))).
      assert (KA : forall z, Mem.load Mint32 m' ab z = Mem.load Mint32 m ab z)
        by (intros z; exact (LXz Mint32 ab z Nab Cab (ozx_ne _ _ _ Nabo))).
      pose proof (AnimWorld.anim_base_keep ge bm m m' gp (rl ++ xgl) ab bga bauc btab otab bt ot ob oo0 B W1 Ntab Nga
                    NB Hperm Hld (LXm Mint32 136 ltac:(hside)) (KA 0) (KA 8)
                    (LXm Mint32 144 ltac:(hside)) (LXm Mint32 156 ltac:(hside))) as B'.
      exists ab, bga, bauc, btab, otab, bt, ot, ob, oo0. split; [exact B' |].
      intros a La0 Ia. hxm_in La0. pose proof (ST a La0 Ia) as Sa.
      assert (Cbt : ~ chg bt).
      { intros [X | X].
        - pose proof (xsym_ffw lp bm bt m _ X FWF) as (_ & _ & N). ffw_simpl_in N. exact (N eq_refl).
        - exact (xg_dyn bt Dbt X). }
      apply (AnimWorld.anim_st_keep m m' ab bga bt ot ob oo0 Sa (KA 4)).
      - intros o ch Hin. apply LXz; [exact O1 | exact O2 |]. apply ozx_k.
        destruct Hin as [E | [E | [E | [E | []]]]]; injection E as <- <-; ok_t.
      - intros k rel ch v0 _ _. apply LXz; [exact D2 | exact Cbt | apply ozx_ne; exact D3].
    Qed.

    Lemma hx_lvl : ffw ge bm m -> AnimWorld.anim_w ge bm m -> lvl_w ge m -> lvl_w ge m'.
    Proof.
      intros Hf AW Hl.
      pose proof Hf as (_ & EX & _).
      destruct (hx_facts Hf) as (O1 & O2 & _).
      ffw_unpack EX.
      assert (Lo' : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
      rewrite OBJ in Lo'. injection Lo' as E1 E2. subst bo oo.
      apply (AnimKeep.lvl_w_keep_ne ge m m' (fun b => b <> bm /\ ~ chg b /\ b <> ob)); [| | exact Hl].
      - intros b Hs. split; [exact (AnimKeep.lvl_ne_bm ge bm m AW b Hs) |].
        split; [exact (nchg_lvl b Hs) |].
        exact (proj1 (D4 b (or_intror (or_intror Hs)))).
      - intros ch b z (A & Bc & C). exact (LXz ch b z A Bc (ozx_ne _ _ _ C)).
    Qed.

    Theorem hx_fworld : fworld lp bm m -> fworld lp bm m'.
    Proof.
      intros (Ha & Hw & Han & Hmo & Hd & Hf & Hu & Haw & Hl).
      split; [intros v Hl'; apply Ha; hxm_in Hl'; exact Hl' |].
      split; [exact (hx_world Hf Hw) |]. split; [exact (hx_anim Hf Han) |].
      split; [exact (hx_mobj Hf Hmo) |]. split; [rewrite (hx_adown Hf); exact Hd |].
      split; [exact (hx_ffw Hf) |]. split; [exact (hx_used Hf Hu) |].
      split; [exact (hx_anim_w Hf Haw) |]. exact (hx_lvl Hf Haw Hl).
    Qed.
  End HOLEX.
End HX.
