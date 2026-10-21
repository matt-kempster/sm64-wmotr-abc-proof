(* ====================================================================== *)
(* save_file_do_save, PROVED FROM ITS REAL BODY DOWN TO THE HARDWARE/OS   *)
(* FLOOR (SPINE: premise sweep, 2026-10-21).                              *)
(*                                                                        *)
(* save_file_do_save is an entry of NoAImpliesNoFlyTwelve.cut_ext_open2   *)
(* (both capstones), reachable without A (TRUST 4.1), so it cannot be     *)
(* gated away.  Its call tree, walked here over the generated Clight:     *)
(*   save_file.c  : save_file_do_save -> add_save_block_signature         *)
(*                  (-> calc_checksum), bcopy, write_eeprom_data,         *)
(*                  save_main_menu_data (the same three on menuData);     *)
(*                  write_eeprom_data -> osEepromLongWrite;               *)
(*   libultra C   : osEepromLongWrite -> osEepromWrite, osSetTimer,       *)
(*                  osRecvMesg;  osEepromWrite -> __osSiGetAccess,        *)
(*                  __osEepStatus, __osPackEepWriteData,                  *)
(*                  __osSiRawStartDma, osRecvMesg, __osSiRelAccess;       *)
(*                  __osSiGetAccess -> __osSiCreateAccessQueue            *)
(*                  (-> osCreateMesgQueue, osSendMesg), osRecvMesg;       *)
(*                  __osSiRelAccess -> osSendMesg.                        *)
(* The floor (OsDmaFloor, TRUST 3.5): bcopy (asm), __osSiRawStartDma      *)
(* (SI registers / PIF), osRecvMesg / osSendMesg (thread queues + yield,  *)
(* asm), osSetTimer (the OS timer list, osTimer.c + timer interrupt: a    *)
(* COARSER floor, see OsDmaFloor).                                        *)
(*                                                                        *)
(* The argument: every byte the tree writes lies in a HARM block -- one   *)
(* that MWF_real and action_sat never read: not Mario's block, not the    *)
(* controller block, not SafeB, not a watched symbol.  The stores land    *)
(* in stored globals (gSaveBuffer, gSaveFileModified,                     *)
(* gMainMenuDataModified, __osEepPifRam, __osContLastCmd,                 *)
(* gOsSiAccessQueueCreated, gOsSiMessageQueue), in fresh stack locals,    *)
(* or through pointers that came from those; the floor calls change the   *)
(* queue / cell / timer / PIF image / bcopy destination, all harm         *)
(* blocks.  A store into a harm block keeps the carried facts whatever    *)
(* the stored value (harm_change), so no claim about values is needed.    *)
(* The walk tracks two value classes in temps: harm-if-pointer (HPv), and *)
(* queue-if-pointer (AQ: the block of a q_side queue), checked by         *)
(* boolean recognizers that vm_compute accepts on the real bodies.        *)
(* FOR ANY ARGUMENT: fileIndex is untracked (it only offsets the          *)
(* gSaveBuffer pointer, which keeps the block).                           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool Classical_Prop.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario memory save_file interaction
  libultra_osEepromLongWrite libultra_osEepromWrite libultra_osSiCreateAccessQueue
  libultra_osCreateMesgQueue libultra_osContInit.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathBodies
  FloorsSurface LinkedTwelve OsDmaFloor.
From SM64.Proofs Require MtxfBody ActWriterSurface LocalVarsSurface RetSurface
  ObjExtBodies LptBody MathGeomBodies.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. The walk: sets / stores / calls, with loops.                         *)
(* ---------------------------------------------------------------------- *)

Section HW.
  Variable ge : genv.
  Variable e : env.
  Variable Inv : mem -> Prop.
  Variable P : temp_env -> Prop.
  Variable set_ok : ident -> expr -> bool.
  Variable store_ok : expr -> bool.
  Variable call_ok : option ident -> expr -> list expr -> bool.

  Hypothesis Hset : forall id a le m v,
      set_ok id a = true -> P le -> Inv m ->
      eval_expr ge e le m a v -> P (PTree.set id v le).
  Hypothesis Hstore : forall lv rhs le m t le' m' out,
      store_ok lv = true -> P le ->
      exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
      Inv m -> Inv m'.
  Hypothesis Hcall : forall optid a al le m t le' m' out,
      call_ok optid a al = true -> P le ->
      exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
      Inv m -> Inv m' /\ P le'.

  Fixpoint hw_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue | Sreturn _ => true
    | Sset id a => set_ok id a
    | Sassign lv _ => store_ok lv
    | Scall optid a al => call_ok optid a al
    | Ssequence s1 s2 => hw_chk s1 && hw_chk s2
    | Sifthenelse _ s1 s2 => hw_chk s1 && hw_chk s2
    | Sloop s1 s2 => hw_chk s1 && hw_chk s2
    | _ => false
    end.

  Lemma hw_walk : forall e1 le m s t le' m' out,
      exec_stmt function_entry2 ge e1 le m s t le' m' out -> e1 = e ->
      hw_chk s = true -> P le -> Inv m -> Inv m' /\ P le'.
  Proof.
    intros e1 le m s t le' m' out Hexec.
    induction Hexec; intros He Hchk Hp Hf; subst; cbn [hw_chk] in Hchk;
      try discriminate Hchk.
    - split; assumption.
    - split; [ | exact Hp ].
      lazymatch goal with Hl : eval_lvalue ?gg ?ee ?ll ?mm a1 _ _ _ |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Sassign a1 a2) E0 ll m' Out_normal)
          by (eapply exec_Sassign; eassumption) end.
      exact (Hstore _ _ _ _ _ _ _ _ Hchk Hp Hx Hf).
    - split; [ exact Hf | ]. eapply Hset; eassumption.
    - lazymatch goal with Hee : eval_expr ?gg ?ee ?ll ?mm a _,
                          Hfc : eval_funcall _ _ _ _ _ ?tt ?mm' ?vr |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Scall optid a al) tt
                       (set_opttemp optid vr ll) mm' Out_normal)
          by (eapply exec_Scall; eassumption) end.
      exact (Hcall _ _ _ _ _ _ _ _ _ Hchk Hp Hx Hf).
    - apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as [Hf1 Hp1].
      exact (IHHexec2 eq_refl H2 Hp1 Hf1).
    - apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hp Hf).
    - apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; [ reflexivity | destruct b; assumption | exact Hp | exact Hf ].
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hp Hf).
    - apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as [Hf1 Hp1].
      exact (IHHexec2 eq_refl H2 Hp1 Hf1).
    - pose proof Hchk as Hchk'. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as [Hf1 Hp1].
      destruct (IHHexec2 eq_refl H2 Hp1 Hf1) as [Hf2 Hp2].
      exact (IHHexec3 eq_refl Hchk' Hp2 Hf2).
  Qed.
End HW.

(* ---------------------------------------------------------------------- *)
(* 2. Value lemmas: which operations can mint which pointer.               *)
(* ---------------------------------------------------------------------- *)

Lemma sem_add_vptr_src : forall cenv v1 t1 v2 t2 m b o,
    sem_add cenv v1 t1 v2 t2 m = Some (Vptr b o) ->
    (exists o1, v1 = Vptr b o1) \/ (exists o2, v2 = Vptr b o2).
Proof.
  intros cenv v1 t1 v2 t2 m b o H.
  destruct (classify_add t1 t2) eqn:Hc.
  - unfold sem_add in H. rewrite Hc in H. unfold sem_add_ptr_int in H.
    destruct v1; destruct v2; try discriminate H;
      try (destruct Archi.ptr64; discriminate H); inv H; left; eauto.
  - unfold sem_add in H. rewrite Hc in H. unfold sem_add_ptr_long in H.
    destruct v1; destruct v2; try discriminate H;
      try (destruct Archi.ptr64; discriminate H); inv H; left; eauto.
  - unfold sem_add in H. rewrite Hc in H. unfold sem_add_ptr_int in H.
    destruct v1; destruct v2; try discriminate H;
      try (destruct Archi.ptr64; discriminate H); inv H; right; eauto.
  - unfold sem_add in H. rewrite Hc in H. unfold sem_add_ptr_long in H.
    destruct v1; destruct v2; try discriminate H;
      try (destruct Archi.ptr64; discriminate H); inv H; right; eauto.
  - exfalso. exact (ActWriterSurface.sem_add_default_nonptr _ _ _ _ _ _ _ Hc H b o eq_refl).
Qed.

Lemma sem_sub_vptr_src : forall cenv v1 t1 v2 t2 m b o,
    sem_sub cenv v1 t1 v2 t2 m = Some (Vptr b o) -> exists o1, v1 = Vptr b o1.
Proof.
  intros cenv v1 t1 v2 t2 m b o H.
  destruct (classify_sub t1 t2) eqn:Hc.
  - unfold sem_sub in H. rewrite Hc in H.
    destruct v1; destruct v2; try discriminate H;
      try (destruct Archi.ptr64; discriminate H); inv H; eauto.
  - unfold sem_sub in H. rewrite Hc in H.
    destruct v1; destruct v2; try discriminate H;
      try (destruct Archi.ptr64; discriminate H).
    destruct (eq_block b0 b1); [ | discriminate H ].
    destruct (zlt 0 (sizeof cenv ty) && zle (sizeof cenv ty) Ptrofs.max_signed);
      [ | discriminate H ].
    injection H as H. unfold Vptrofs in H. destruct Archi.ptr64; discriminate H.
  - unfold sem_sub in H. rewrite Hc in H.
    destruct v1; destruct v2; try discriminate H;
      try (destruct Archi.ptr64; discriminate H); inv H; eauto.
  - exfalso. exact (ActWriterSurface.sem_sub_default_nonptr _ _ _ _ _ _ _ Hc H b o eq_refl).
Qed.

Lemma deref_small_nonptr : forall ty m loc ofs bf v ch,
    deref_loc ty m loc ofs bf v ->
    access_mode ty = By_value ch -> ActWriterSurface.subword_chunk ch = true ->
    forall b o, v <> Vptr b o.
Proof.
  intros ty m loc ofs bf v ch Hd Ham Hsw b o ->.
  inv Hd.
  - match goal with Ha : access_mode _ = By_value ?c, Hl : Mem.loadv ?c _ _ = Some _ |- _ =>
      rewrite Ham in Ha; injection Ha as <-; cbn in Hl;
      exact (ActWriterSurface.load_subword_nonptr _ _ _ _ _ Hsw Hl b o eq_refl) end.
  - congruence.
  - congruence.
  - match goal with Hl : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hl end.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The recognizers (per function: its locals lv, its untracked temps    *)
(*    fl, its queue temps qa).                                             *)
(* ---------------------------------------------------------------------- *)

Definition hlv_var (lv : list ident) (x : ident) : bool :=
  mem_id x lv || mem_id x stored_globals.

Definition rv_chk (ty : type) (addr_ok : bool) : bool :=
  match access_mode ty with
  | By_value ch => ActWriterSurface.subword_chunk ch
  | By_nothing => true
  | By_reference | By_copy => addr_ok
  end.

Definition cmp_op (op : binary_operation) : bool :=
  match op with Oeq | One | Olt | Ogt | Ole | Oge => true | _ => false end.

(* the value, if a pointer, points into a harm block *)
Fixpoint hx (lv fl : list ident) (a : expr) : bool :=
  match a with
  | Econst_int _ _ | Econst_float _ _ | Econst_single _ _ | Econst_long _ _ => true
  | Esizeof _ _ | Ealignof _ _ => true
  | Etempvar t _ => negb (mem_id t fl)
  | Eunop _ _ _ => true
  | Ecast a1 _ => hx lv fl a1
  | Ebinop Oadd a1 a2 _ => hx lv fl a1 && hx lv fl a2
                           || ptrish (typeof a1) && hx lv fl a1
  | Ebinop Osub a1 _ _ => hx lv fl a1
  | Ebinop op _ _ _ => cmp_op op || ActWriterSurface.nonptr_binop_head a
  | Evar x ty => rv_chk ty (hlv_var lv x)
  | Ederef a1 ty => rv_chk ty (hx lv fl a1)
  | Efield a1 _ ty => rv_chk ty (hx lv fl a1)
  | Eaddrof a1 _ =>
      match a1 with
      | Evar x _ => hlv_var lv x
      | Ederef a2 _ | Efield a2 _ _ => hx lv fl a2
      | _ => false
      end
  end.

(* the lvalue's block is harm *)
Definition hlv (lv fl : list ident) (a : expr) : bool :=
  match a with
  | Evar x _ => hlv_var lv x
  | Ederef a1 _ | Efield a1 _ _ => hx lv fl a1
  | _ => false
  end.

Lemma hx_addrof : forall lv fl a ty, hx lv fl (Eaddrof a ty) = hlv lv fl a.
Proof. intros lv fl a ty. destruct a; reflexivity. Qed.

Definition is_q (q : ident) : bool :=
  match q_side q with Some _ => true | None => false end.

(* the value, if a pointer, is a q_side queue's block *)
Definition hq (lv qa : list ident) (a : expr) : bool :=
  match a with
  | Etempvar t _ => mem_id t qa
  | Eaddrof (Evar q _) _ => negb (mem_id q lv) && is_q q
  | _ => false
  end.

Definition set_ok (lv fl qa : list ident) (id : ident) (a : expr) : bool :=
  (mem_id id fl || hx lv fl a) && (negb (mem_id id qa) || hq lv qa a).

Definition store_ok (lv fl : list ident) (a : expr) : bool := hlv lv fl a.

Definition opt_ok (fl qa : list ident) (o : option ident) : bool :=
  match o with
  | None => true
  | Some id => mem_id id fl && negb (mem_id id qa)
  end.

Fixpoint args_ok (lv fl qa fl' qa' : list ident) (ps : list (ident * type))
    (al : list expr) : bool :=
  match ps, al with
  | [], [] => true
  | p :: ps', a :: al' =>
      (mem_id (fst p) fl' || hx lv fl a) && (negb (mem_id (fst p) qa') || hq lv qa a)
      && args_ok lv fl qa fl' qa' ps' al'
  | _, _ => false
  end.

(* the floor calls the tree makes, with the argument shapes the floor
   specs bound *)
Definition floor_ok (lv fl qa : list ident) (fid : ident) (al : list expr) : bool :=
  if Pos.eqb fid memory._osRecvMesg then
    match al with [aq; ac; _] => hq lv qa aq && hx lv fl ac | _ => false end
  else if Pos.eqb fid libultra_osSiCreateAccessQueue._osSendMesg then
    match al with [aq; _; _] => hq lv qa aq | _ => false end
  else if Pos.eqb fid libultra_osEepromLongWrite._osSetTimer then
    match al with
    | Eaddrof (Evar t _) _ :: _ =>
        Pos.eqb t libultra_osContInit.___osEepromTimer && negb (mem_id t lv)
    | _ => false
    end
  else if Pos.eqb fid libultra_osEepromWrite.___osSiRawStartDma then
    match al with [_; ap] => hx lv fl ap | _ => false end
  else if Pos.eqb fid save_file._bcopy then
    match al with [_; ad; _] => hx lv fl ad | _ => false end
  else false.

Definition ctab := list (ident * (Clight.function * (list ident * list ident))).

Fixpoint find_ct (fid : ident) (c : ctab) : option (Clight.function * (list ident * list ident)) :=
  match c with
  | [] => None
  | (g, x) :: c' => if Pos.eqb fid g then Some x else find_ct fid c'
  end.

Definition call_ok (lv fl qa : list ident) (c : ctab) (o : option ident) (a : expr)
    (al : list expr) : bool :=
  match a with
  | Evar fid (Tfunction _ _ _) =>
      negb (mem_id fid lv) && opt_ok fl qa o &&
      match find_ct fid c with
      | Some (f, (fl', qa')) => args_ok lv fl qa fl' qa' (fn_params f) al
      | None => floor_ok lv fl qa fid al
      end
  | _ => false
  end.

Definition body_chk (f : Clight.function) (fl qa : list ident) (c : ctab) : bool :=
  let lv := map fst (fn_vars f) in
  hw_chk (set_ok lv fl qa) (store_ok lv fl) (call_ok lv fl qa c) (fn_body f).

(* ---------------------------------------------------------------------- *)
(* 4. The q_side queues and their side buffers are stored globals.         *)
(* ---------------------------------------------------------------------- *)

Lemma q_side_sg : forall q side, q_side q = Some side ->
    mem_id q stored_globals = true /\
    (forall s, In s side -> mem_id s stored_globals = true).
Proof.
  intros q side H. unfold q_side in H.
  destruct (Pos.eqb q memory._gDmaMesgQueue) eqn:E1;
    [ apply Pos.eqb_eq in E1; subst; injection H as <-;
      split; [ vm_compute; reflexivity | intros s [] ] | ].
  destruct (Pos.eqb q save_file._gSIEventMesgQueue) eqn:E2;
    [ apply Pos.eqb_eq in E2; subst; injection H as <-;
      split; [ vm_compute; reflexivity | intros s [] ] | ].
  destruct (Pos.eqb q libultra_osSiCreateAccessQueue._gOsSiMessageQueue) eqn:E3;
    [ apply Pos.eqb_eq in E3; subst; injection H as <-;
      split; [ vm_compute; reflexivity | intros s [<- | []]; vm_compute; reflexivity ] | ].
  destruct (Pos.eqb q libultra_osContInit.___osEepromTimerQ) eqn:E4;
    [ apply Pos.eqb_eq in E4; subst; injection H as <-;
      split; [ vm_compute; reflexivity
             | intros s [<- | [<- | []]]; vm_compute; reflexivity ] | ].
  discriminate H.
Qed.

(* ---------------------------------------------------------------------- *)
(* 5. The section: harm blocks, and every step of the walk.                *)
(* ---------------------------------------------------------------------- *)

Section SDS.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Hypothesis Hfloor : os_dma_floor.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let OF := ow_facts bm MWF.

  Lemma sd_Hbc_bm : bc <> bm.
  Proof. destruct Hspawn as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.
  Lemma sd_glob : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol ge gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  Proof. destruct Hspawn as (init & Hs). exact (glob_blk lp init bm bc oc0 SafeB Hs HSafeB_syms). Qed.

  Definition watched (b : block) : Prop :=
    Genv.find_symbol ge mario._gMarioState = Some b
    \/ Genv.find_symbol ge interaction._gGlobalTimer = Some b
    \/ Genv.find_symbol ge interaction._sInteractionHandlers = Some b
    \/ (exists gid, mem_id gid knockback_table_ids = true
                    /\ Genv.find_symbol ge gid = Some b)
    \/ Genv.find_symbol ge mario._gMarioAnimsBuf = Some b.

  (* a block nothing the carried facts read *)
  Definition harm (b : block) : Prop :=
    b <> bm /\ b <> bc /\ ~ SafeB b /\ ~ watched b.

  Lemma harm_sglob : forall gid b,
      mem_id gid stored_globals = true -> Genv.find_symbol ge gid = Some b -> harm b.
  Proof.
    intros gid b Hg Hfs.
    destruct (sd_glob gid b Hg Hfs) as (B1 & B2 & B3).
    split; [ exact B1 | split; [ exact B2 | split; [ exact B3 | ] ] ].
    intros [F | [F | [F | [(g2 & Hg2 & F) | F]]]];
      (eapply Genv.global_addresses_distinct; [ | exact Hfs | exact F | reflexivity ]);
      intro E; subst.
    - rewrite stored_globals_not_gms in Hg; discriminate.
    - rewrite stored_globals_not_gtimer in Hg; discriminate.
    - rewrite stored_globals_not_itab in Hg; discriminate.
    - rewrite (stored_globals_not_ktab _ Hg2) in Hg; discriminate.
    - rewrite stored_globals_not_anim in Hg; discriminate.
  Qed.

  Lemma harm_fresh : forall m b, MWF m -> ~ Mem.valid_block m b -> harm b.
  Proof.
    intros m b M Hnv.
    pose proof M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb & Vkt & _) & _).
    split; [ intro E; subst; exact (Hnv Vbm) | ].
    split; [ intro E; subst; exact (Hnv Vbc) | ].
    split; [ intro S; exact (Hnv (Vsafe _ S)) | ].
    intros [F | [F | [F | [(g2 & Hg2 & F) | F]]]].
    - exact (Hnv (Vgms _ F)).
    - exact (Hnv (Vgt _ F)).
    - exact (Hnv (Vtb _ F)).
    - exact (Hnv (Vkt _ _ Hg2 F)).
    - exact (Hnv (proj2 (proj2 (proj2 (mwf_real_anim_blk lp bm bc oc0 SafeB m b M F))))).
  Qed.

  (* THE BRICK: a change confined to harm blocks keeps the carried facts *)
  Lemma harm_change : forall m m',
      OF m -> Mem.unchanged_on (fun b _ => ~ harm b) m m' -> OF m'.
  Proof.
    intros m m' (Vb & AS & M) UO.
    pose proof M as ((Vbm & Vbc & Vgms & Vsafe & Vgt & Vtb & Vkt & _) & _).
    assert (Lsame : forall ch b z, Mem.valid_block m b -> ~ harm b ->
              Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z Hv Hh. eapply Mem.load_unchanged_on_1; [ exact UO | exact Hv | ].
      intros; exact Hh. }
    assert (NHbm : ~ harm bm) by (intros (H & _); exact (H eq_refl)).
    split; [ eapply Mem.valid_block_unchanged_on; eauto | split ].
    - eapply action_sat_unchanged_on; [ | exact Vb | exact AS ].
      eapply Mem.unchanged_on_implies; [ exact UO | ].
      intros b z [-> _] _. exact NHbm.
    - apply (MWF_real_transfer lp bm bc oc0 SafeB sd_Hbc_bm m m'); [ | | | | exact M ].
      + intros b Hv. eapply Mem.valid_block_unchanged_on; eauto.
      + intros v Hld. pose proof M as (_ & R1 & _). apply R1.
        rewrite <- Hld. symmetry. exact (Lsame _ _ _ Vbm NHbm).
      + intros ch b ofs v Hrow Hld. rewrite <- Hld. symmetry.
        destruct Hrow as [ [Eb _] | [ Eb | [ F | [ F | [ F | [ (gid & Hg & F) | F ] ] ] ] ] ].
        * subst b. exact (Lsame _ _ _ Vbm NHbm).
        * subst b. apply Lsame; [ exact Vbc | intros (_ & H & _); exact (H eq_refl) ].
        * apply Lsame; [ exact (Vgms _ F) | intros (_ & _ & _ & W); apply W; left; exact F ].
        * apply Lsame; [ exact (Vgt _ F) | intros (_ & _ & _ & W); apply W; right; left; exact F ].
        * apply Lsame; [ exact (Vtb _ F)
                       | intros (_ & _ & _ & W); apply W; right; right; left; exact F ].
        * apply Lsame; [ exact (Vkt _ _ Hg F)
                       | intros (_ & _ & _ & W); apply W; right; right; right; left;
                         exists gid; split; [ exact Hg | exact F ] ].
        * apply Lsame;
            [ exact (proj2 (proj2 (proj2 (mwf_real_anim_blk lp bm bc oc0 SafeB m b M F))))
            | intros (_ & _ & _ & W); apply W; right; right; right; right; exact F ].
      + intros b ofs b' o' Hs Hld.
        pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
        apply (R7 b ofs b' o' Hs). cbn in Hld |- *.
        rewrite <- Hld. symmetry.
        apply Lsame; [ exact (Vsafe _ Hs) | intros (_ & _ & H & _); exact (H Hs) ].
  Qed.

  Lemma harm_change_blk : forall m m' (P : block -> Z -> Prop),
      OF m -> Mem.unchanged_on P m m' ->
      (forall b z, ~ harm b -> P b z) -> OF m'.
  Proof.
    intros m m' P Hf UO Himp. apply (harm_change m m' Hf).
    eapply Mem.unchanged_on_implies; [ exact UO | ]. intros b z H _. exact (Himp b z H).
  Qed.

  Lemma assign_harm : forall ty m loc ofs bf v m',
      assign_loc ge ty m loc ofs bf v m' -> harm loc -> OF m -> OF m'.
  Proof.
    intros ty m loc ofs bf v m' Ha Hh Hf.
    inv Ha.
    - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => cbn in Hs;
        apply (harm_change m m' Hf);
        eapply Mem.store_unchanged_on; [ exact Hs | ];
        intros i _ N; exact (N Hh) end.
    - match goal with Hs : Mem.storebytes _ _ _ _ = Some _ |- _ =>
        apply (harm_change m m' Hf);
        eapply Mem.storebytes_unchanged_on; [ exact Hs | ];
        intros i _ N; exact (N Hh) end.
    - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
      match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => cbn in Hs;
        apply (harm_change m m' Hf);
        eapply Mem.store_unchanged_on; [ exact Hs | ];
        intros i _ N; exact (N Hh) end.
  Qed.

  (* ---- value classes ---- *)
  Definition HPv (v : val) : Prop := forall b o, v = Vptr b o -> harm b.
  Definition AQ (v : val) : Prop := forall b o, v = Vptr b o ->
      exists q side, q_side q = Some side /\ Genv.find_symbol ge q = Some b.

  Lemma AQ_HPv : forall v, AQ v -> HPv v.
  Proof.
    intros v H b o E. destruct (H b o E) as (q & side & Hq & Hfs).
    exact (harm_sglob q b (proj1 (q_side_sg q side Hq)) Hfs).
  Qed.

  Definition Pt (fl qa : list ident) (le : temp_env) : Prop :=
    forall t v, le ! t = Some v ->
      (mem_id t fl = false -> HPv v) /\ (mem_id t qa = true -> AQ v).

  Definition Env (lv : list ident) (e : env) : Prop :=
    (forall x b ty, e ! x = Some (b, ty) -> harm b)
    /\ (forall x, mem_id x lv = false -> e ! x = None)
    /\ (forall x, mem_id x lv = true -> e ! x <> None).

  Section Expr.
    Variables (lv fl qa : list ident) (e : env) (le : temp_env) (m : mem).
    Hypothesis HE : Env lv e.
    Hypothesis HP : Pt fl qa le.

    Lemma hlv_var_sound : forall x ty loc ofs bf,
        eval_lvalue ge e le m (Evar x ty) loc ofs bf -> hlv_var lv x = true -> harm loc.
    Proof.
      intros x ty loc ofs bf Hl Hok. destruct HE as (Eh & En & Es).
      inv Hl.
      - match goal with H : e ! x = Some _ |- _ => exact (Eh _ _ _ H) end.
      - unfold hlv_var in Hok. apply orb_true_iff in Hok as [Hl | Hg].
        + exfalso. apply (Es x Hl). assumption.
        + match goal with H : Genv.find_symbol _ x = Some _ |- _ =>
            exact (harm_sglob x loc Hg H) end.
    Qed.

    Lemma hx_sound : forall a,
        (forall v, eval_expr ge e le m a v -> hx lv fl a = true -> HPv v)
        /\ (forall loc ofs bf, eval_lvalue ge e le m a loc ofs bf ->
              hlv lv fl a = true -> harm loc).
    Proof.
      induction a as [ i ty | f ty | f ty | i ty | x ty | t ty | a1 IH1 ty | a1 IH1 ty
                     | op a1 IH1 ty | op a1 IH1 a2 IH2 ty | a1 IH1 ty | a1 IH1 fld ty
                     | ty0 ty | ty0 ty ];
        (split; [ intros v Hev Hok | intros loc ofs bf Hev Hok ]); cbn [hx hlv] in Hok;
        try discriminate Hok.
      (* constants *)
      - intros b o ->. inv Hev; try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end).
      - intros b o ->. inv Hev; try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end).
      - intros b o ->. inv Hev; try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end).
      - intros b o ->. inv Hev; try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end).
      (* Evar *)
      - intros b o ->. inv Hev. cbn [typeof] in *.
        match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) ?l ?of ?bf,
                        Hd : deref_loc _ _ ?l ?of ?bf _ |- _ =>
          unfold rv_chk in Hok; destruct (access_mode ty) as [ch| | |] eqn:Am;
          [ exact (False_ind _ (deref_small_nonptr _ _ _ _ _ _ _ Hd Am Hok b o eq_refl))
          | | | ];
          inv Hd; try congruence;
          try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end);
          exact (hlv_var_sound _ _ _ _ _ Hl Hok) end.
      - exact (hlv_var_sound _ _ _ _ _ Hev Hok).
      (* Etempvar *)
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H end).
        apply negb_true_iff in Hok.
        match goal with H : le ! t = Some _ |- _ => exact (proj1 (HP _ _ H) Hok b o eq_refl) end.
      (* Ederef *)
      - intros b o ->. inv Hev. cbn [typeof] in *.
        match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) ?l ?of ?bf,
                        Hd : deref_loc _ _ ?l ?of ?bf _ |- _ =>
          unfold rv_chk in Hok; destruct (access_mode ty) as [ch| | |] eqn:Am;
          [ exact (False_ind _ (deref_small_nonptr _ _ _ _ _ _ _ Hd Am Hok b o eq_refl))
          | | | ];
          inv Hd; try congruence;
          try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end);
          inv Hl; exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl) end.
      - inv Hev. exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl).
      (* Eaddrof *)
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv H end).
        change (hlv lv fl a1 = true) in Hok.
        match goal with Hl : eval_lvalue _ _ _ _ a1 _ _ _ |- _ =>
          exact (proj2 IH1 _ _ _ Hl Hok) end.
      (* Eunop *)
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ (Eunop _ _ _) _ _ _ |- _ => inv H end).
        match goal with H : sem_unary_operation _ _ _ _ = Some _ |- _ =>
          exfalso; exact (ActWriterSurface.sem_unop_nonptr _ _ _ _ _ H b o eq_refl) end.
      (* Ebinop *)
      - intros b o ->.
        destruct op; cbn in Hok;
          first
            [ exfalso; refine (ActWriterSurface.eval_nonptr_binop_head _ _ _ _ _ _ _ _ _
                                _ Hev b o eq_refl); reflexivity
            | inv Hev;
              try (match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end);
              match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
                cbn [sem_binary_operation] in Hs end ].
        + (* Oadd *)
          apply orb_true_iff in Hok as [Hb | Hp].
          * apply andb_prop in Hb as [Ha1 Ha2].
            destruct (sem_add_vptr_src _ _ _ _ _ _ _ _ ltac:(eassumption)) as [(o1 & E1) | (o2 & E2)].
            -- subst. exact (proj1 IH1 _ ltac:(eassumption) Ha1 _ _ eq_refl).
            -- subst. exact (proj1 IH2 _ ltac:(eassumption) Ha2 _ _ eq_refl).
          * apply andb_prop in Hp as [Hpt Ha1].
            destruct (sem_add_ptrish_block _ _ _ _ _ _ _ _ Hpt ltac:(eassumption)) as (o1 & E1).
            subst. exact (proj1 IH1 _ ltac:(eassumption) Ha1 _ _ eq_refl).
        + (* Osub *)
          destruct (sem_sub_vptr_src _ _ _ _ _ _ _ _ ltac:(eassumption)) as (o1 & E1).
          subst. exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl).
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
        + exfalso; match goal with Hs : _ = Some (Vptr b o) |- _ => exact (RetSurface.sem_cmp_not_vptr _ _ _ _ _ _ _ Hs b o eq_refl) end.
      (* Ecast *)
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv H end).
        match goal with Hc : sem_cast _ _ _ _ = Some (Vptr b o) |- _ =>
          pose proof (sem_cast_vptr_inv _ _ _ _ _ _ Hc) as Ev; subst end.
        exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl).
      (* Efield *)
      - intros b o ->. inv Hev. cbn [typeof] in *.
        match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) ?l ?of ?bf,
                        Hd : deref_loc _ _ ?l ?of ?bf _ |- _ =>
          unfold rv_chk in Hok; destruct (access_mode ty) as [ch| | |] eqn:Am;
          [ exact (False_ind _ (deref_small_nonptr _ _ _ _ _ _ _ Hd Am Hok b o eq_refl))
          | | | ];
          inv Hd; try congruence;
          try (match goal with Hb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end);
          inv Hl; exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl) end.
      - inv Hev; exact (proj1 IH1 _ ltac:(eassumption) Hok _ _ eq_refl).
      (* Esizeof / Ealignof *)
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end);
          unfold Vptrofs in *; destruct Archi.ptr64; discriminate.
      - intros b o ->. inv Hev;
          try (match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end);
          unfold Vptrofs in *; destruct Archi.ptr64; discriminate.
    Qed.

    Lemma hq_sound : forall a v,
        eval_expr ge e le m a v -> hq lv qa a = true -> AQ v.
    Proof.
      intros a v Hev Hok. destruct HE as (Eh & En & Es).
      destruct a as [ | | | | | t ty | | a1 ty | | | | | | ]; try discriminate Hok.
      - cbn [hq] in Hok. inv Hev;
          [ | match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end ].
        match goal with H : le ! t = Some _ |- _ => exact (proj2 (HP _ _ H) Hok) end.
      - destruct a1 as [ | | | | q qty | | | | | | | | | ]; try discriminate Hok.
        cbn [hq] in Hok. apply andb_prop in Hok as [Hnl Hq].
        apply negb_true_iff in Hnl.
        unfold is_q in Hq. destruct (q_side q) as [side|] eqn:Hqs; [ | discriminate Hq ].
        inv Hev; [ | match goal with H : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv H end ].
        match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
        + match goal with H : e ! q = Some _ |- _ => rewrite (En q Hnl) in H; discriminate H end.
        + intros b o E. injection E as <- _. exists q, side. split; assumption.
    Qed.

    Lemma exprlist_cls : forall al tyl vl,
        eval_exprlist ge e le m al tyl vl ->
        Forall2 (fun a v => (hx lv fl a = true -> HPv v) /\ (hq lv qa a = true -> AQ v)) al vl.
    Proof.
      intros al tyl vl H. induction H as [ | a bl ty tyl v1 v2 vl Ha Hc Hbl IH ];
        constructor; [ | exact IH ].
      split.
      - intros Hok b o ->. apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst v1.
        exact (proj1 (hx_sound a) _ Ha Hok b o eq_refl).
      - intros Hok b o ->. apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst v1.
        exact (hq_sound a _ Ha Hok b o eq_refl).
    Qed.
  End Expr.

  (* ---- the parameter binding ---- *)
  Definition Cp (fl qa : list ident) (p : ident * type) (v : val) : Prop :=
    (mem_id (fst p) fl = false -> HPv v) /\ (mem_id (fst p) qa = true -> AQ v).

  Lemma bind_cls : forall fl qa ps vl te le,
      bind_parameter_temps ps vl te = Some le ->
      Forall2 (Cp fl qa) ps vl -> Pt fl qa te -> Pt fl qa le.
  Proof.
    intros fl qa ps. induction ps as [ | [id ty] ps IH ];
      intros vl te le Hb Hf Ht; destruct vl as [ | v0 vr ]; cbn in Hb; try discriminate Hb.
    - injection Hb as <-. exact Ht.
    - inv Hf. apply (IH vr _ _ Hb); [ assumption | ].
      intros t v Hg. destruct (peq t id) as [-> | Hne].
      + rewrite PTree.gss in Hg. injection Hg as <-. assumption.
      + rewrite PTree.gso in Hg by exact Hne. exact (Ht _ _ Hg).
  Qed.

  Lemma undef_Pt : forall fl qa l, Pt fl qa (create_undef_temps l).
  Proof.
    intros fl qa l t v Hg. apply MtxfBody.create_undef_temps_get in Hg. subst v.
    split; intros _ b o E; discriminate E.
  Qed.

  Lemma args_cls : forall lv fl qa fl' qa' e le m ps al tyl vl,
      Env lv e -> Pt fl qa le ->
      eval_exprlist ge e le m al tyl vl ->
      args_ok lv fl qa fl' qa' ps al = true -> Forall2 (Cp fl' qa') ps vl.
  Proof.
    intros lv fl qa fl' qa' e le m ps al tyl vl HE HP Hel Hok.
    pose proof (exprlist_cls lv fl qa e le m HE HP al tyl vl Hel) as Hc.
    clear Hel. revert al vl Hc Hok.
    induction ps as [ | p ps IH ]; intros al vl Hc Hok; destruct al as [ | a al ];
      cbn [args_ok] in Hok; try discriminate Hok.
    - inv Hc. constructor.
    - inv Hc. apply andb_prop in Hok as [Hok Hrest]. apply andb_prop in Hok as [Hh Hq].
      constructor; [ | exact (IH _ _ ltac:(eassumption) Hrest) ].
      match goal with H : (_ -> HPv ?v) /\ (_ -> AQ ?v) |- Cp _ _ _ ?v =>
        destruct H as [Hhv Hqv] end.
      split.
      + intros Hn. rewrite Hn in Hh. exact (Hhv Hh).
      + intros Hy. rewrite Hy in Hq. exact (Hqv Hq).
  Qed.

  (* ---- the function contract ---- *)
  Definition fpres (f : Clight.function) (fl qa : list ident) : Prop :=
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
      (forall le, bind_parameter_temps (fn_params f) vargs
                    (create_undef_temps (fn_temps f)) = Some le -> Pt fl qa le) ->
      OF m -> OF m'.

  Definition resolved (fid : ident) (f : Clight.function) : Prop :=
    exists b, Genv.find_symbol ge fid = Some b
      /\ Genv.find_funct ge (Vptr b Ptrofs.zero) = Some (Internal f).

  Definition ctab_ok (c : ctab) : Prop :=
    forall fid f fl' qa', find_ct fid c = Some (f, (fl', qa')) ->
      resolved fid f /\ fpres f fl' qa'.

  (* ---- the floor calls ---- *)
  Definition floor_ids : list ident :=
    [memory._osRecvMesg; libultra_osSiCreateAccessQueue._osSendMesg;
     libultra_osEepromLongWrite._osSetTimer; libultra_osEepromWrite.___osSiRawStartDma;
     save_file._bcopy].

  Lemma sg_timer : mem_id libultra_osContInit.___osEepromTimer stored_globals = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma floor_ni : MtxfBody.no_internal_all12 floor_ids = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma outside_harm : forall b0 o0 n b z, harm b0 -> ~ harm b -> outside b0 o0 n b z.
  Proof. intros b0 o0 n b z H N. left. intro E. subst. exact (N H). Qed.

  Lemma opt_Pt : forall fl qa optid v le,
      opt_ok fl qa optid = true -> Pt fl qa le -> Pt fl qa (set_opttemp optid v le).
  Proof.
    intros fl qa optid v le Hok HP. destruct optid as [id|]; cbn [set_opttemp]; [ | exact HP ].
    cbn [opt_ok] in Hok. apply andb_prop in Hok as [Hf Hq]. apply negb_true_iff in Hq.
    intros t w Hg. destruct (peq t id) as [-> | Hne].
    - split; intros H; congruence.
    - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
  Qed.

  (* the external call a floor Scall makes *)
  Lemma floor_ext : forall q fid n b fd m vargs t m' vres,
      linkorder q lp -> mem_id fid floor_ids = true ->
      MtxfBody.xnamed ((prog_defmap q) ! fid) n = true ->
      Genv.find_symbol ge fid = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      exists sg, external_functions_sem n sg (Genv.to_senv ge) vargs m t vres m'.
  Proof.
    intros q fid n b fd m vargs t m' vres LO Hid Hn Hs Hf Hev.
    destruct (MtxfBody.xresolve lp q fid floor_ids n b fd H12 LO Hid floor_ni Hn Hs Hf)
      as (sg & targs & tres & cc & ->).
    inv Hev. exists sg.
    match goal with Hx : external_call _ _ _ _ _ _ _ |- _ => exact Hx end.
  Qed.

  Lemma floor_call : forall lv fl qa e le m optid fid fty al t le' m' out,
      Env lv e -> Pt fl qa le ->
      floor_ok lv fl qa fid al = true -> opt_ok fl qa optid = true ->
      mem_id fid lv = false -> access_mode fty = By_reference ->
      exec_stmt function_entry2 ge e le m (Scall optid (Evar fid fty) al) t le' m' out ->
      OF m -> OF m' /\ Pt fl qa le'.
  Proof.
    intros lv fl qa e le m optid fid fty al t le' m' out HE HP Hok Hopt Hnl Am Hx Hof.
    pose proof HE as (Eh & En & Es).
    destruct (LptBody.scall_evar_inv_opt _ _ _ _ _ _ _ _ _ _ _ _ Hx (En fid Hnl) Am)
      as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hf & _ & Hel & Hev & -> & _).
    split; [ | exact (opt_Pt fl qa optid vres le Hopt HP) ].
    pose proof (exprlist_cls lv fl qa e le m HE HP _ _ _ Hel) as Hc.
    destruct Hfloor as (_ & _ & Hrv & Hsd & Hst & Hsi & Hbc).
    unfold floor_ok in Hok.
    destruct (Pos.eqb fid memory._osRecvMesg) eqn:E1.
    { (* osRecvMesg(q, cell, flags) *)
      apply Pos.eqb_eq in E1. subst fid.
      destruct (floor_ext memory.prog memory._osRecvMesg "osRecvMesg" _ _ _ _ _ _ _ (linked12_LO_memory lp H12)
                  eq_refl ltac:(vm_compute; reflexivity) Hs Hf Hev) as (sg & Hx').
      destruct (Hrv _ _ _ _ _ _ _ Hx') as (bq & oq & cell & f0 & -> & _ & _ & UOq).
      destruct al as [ | aq [ | ac [ | af [ | ] ] ] ]; try discriminate Hok.
      apply andb_prop in Hok as [Hq Hcx].
      inversion Hc as [ | ? ? ? ? (_ & Cq) Hc1 ]; subst.
      inversion Hc1 as [ | ? ? ? ? (Cc & _) _ ]; subst.
      destruct (Cq Hq bq oq eq_refl) as (q0 & side & Hqs & Hfs).
      apply (harm_change_blk m m' _ Hof (UOq q0 side Hqs Hfs)).
      intros b0 z Hnh.
      split; [ exact (outside_harm _ _ _ _ _ (harm_sglob q0 bq (proj1 (q_side_sg _ _ Hqs)) Hfs) Hnh) | ].
      split.
      - destruct cell as [ | | | | | bk ok ]; cbn [cell_out]; try exact I.
        exact (outside_harm _ _ _ _ _ (Cc Hcx bk ok eq_refl) Hnh).
      - intros s Hin E.
        exact (Hnh (harm_sglob s b0 (proj2 (q_side_sg _ _ Hqs) s Hin) E)). }
    destruct (Pos.eqb fid libultra_osSiCreateAccessQueue._osSendMesg) eqn:E2.
    { (* osSendMesg(q, msg, flags) *)
      apply Pos.eqb_eq in E2. subst fid.
      destruct (floor_ext libultra_osSiCreateAccessQueue.prog libultra_osSiCreateAccessQueue._osSendMesg "osSendMesg" _ _ _ _ _ _ _
                  (linked12_LO_ultra_si lp H12)
                  eq_refl ltac:(vm_compute; reflexivity) Hs Hf Hev) as (sg & Hx').
      destruct (Hsd _ _ _ _ _ _ _ Hx') as (bq & oq & msg & f0 & -> & _ & UOq).
      destruct al as [ | aq [ | am [ | af [ | ] ] ] ]; try discriminate Hok.
      inversion Hc as [ | ? ? ? ? (_ & Cq) _ ]; subst.
      destruct (Cq Hok bq oq eq_refl) as (q0 & side & Hqs & Hfs).
      apply (harm_change_blk m m' _ Hof (UOq q0 side Hqs Hfs)).
      intros b0 z Hnh.
      split; [ exact (outside_harm _ _ _ _ _ (harm_sglob q0 bq (proj1 (q_side_sg _ _ Hqs)) Hfs) Hnh) | ].
      intros s Hin E.
      exact (Hnh (harm_sglob s b0 (proj2 (q_side_sg _ _ Hqs) s Hin) E)). }
    destruct (Pos.eqb fid libultra_osEepromLongWrite._osSetTimer) eqn:E3.
    { (* osSetTimer(&__osEepromTimer, ...) *)
      apply Pos.eqb_eq in E3. subst fid.
      destruct (floor_ext libultra_osEepromLongWrite.prog libultra_osEepromLongWrite._osSetTimer "osSetTimer" _ _ _ _ _ _ _
                  (linked12_LO_ultra_elw lp H12)
                  eq_refl ltac:(vm_compute; reflexivity) Hs Hf Hev) as (sg & Hx').
      destruct (Hst _ _ _ _ _ _ _ Hx') as (bt & ot & rest & -> & _ & UOt).
      destruct al as [ | a0 al ]; try discriminate Hok.
      destruct a0 as [ | | | | | | | a1 aty | | | | | | ]; try discriminate Hok.
      destruct a1 as [ | | | | tid tty | | | | | | | | | ]; try discriminate Hok.
      apply andb_prop in Hok as [Ht Htl]. apply Pos.eqb_eq in Ht. subst tid.
      apply negb_true_iff in Htl.
      inversion Hel; subst.
      match goal with Hv : eval_expr _ _ _ _ (Eaddrof _ _) ?v1,
                      Hca : sem_cast ?v1 _ _ _ = Some (Vptr bt ot) |- _ =>
        apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hca; subst v1;
        inversion Hv; subst end;
        [ | match goal with H : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv H end ].
      match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
      + match goal with H : e ! _ = Some _ |- _ => rewrite (En _ Htl) in H; discriminate H end.
      + match goal with H : Genv.find_symbol _ _ = Some bt |- _ =>
          pose proof H as Hfs;
          apply (harm_change_blk m m' _ Hof (UOt H)) end.
        intros b0 z Hnh.
        exact (outside_harm _ _ _ _ _ (harm_sglob _ bt sg_timer Hfs) Hnh). }
    destruct (Pos.eqb fid libultra_osEepromWrite.___osSiRawStartDma) eqn:E4.
    { (* __osSiRawStartDma(dir, pifram) *)
      apply Pos.eqb_eq in E4. subst fid.
      destruct (floor_ext libultra_osEepromWrite.prog libultra_osEepromWrite.___osSiRawStartDma "__osSiRawStartDma" _ _ _ _ _ _ _
                  (linked12_LO_ultra_ew lp H12)
                  eq_refl ltac:(vm_compute; reflexivity) Hs Hf Hev) as (sg & Hx').
      destruct (Hsi _ _ _ _ _ _ _ Hx') as (dir & bp & op & -> & UOp & _ & _).
      destruct al as [ | ad [ | ap [ | ] ] ]; try discriminate Hok.
      inversion Hc as [ | ? ? ? ? _ Hc1 ]; subst.
      inversion Hc1 as [ | ? ? ? ? (Cp0 & _) _ ]; subst.
      apply (harm_change_blk m m' _ Hof UOp).
      intros b0 z Hnh. exact (outside_harm _ _ _ _ _ (Cp0 Hok bp op eq_refl) Hnh). }
    destruct (Pos.eqb fid save_file._bcopy) eqn:E5.
    { (* bcopy(src, dst, n) *)
      apply Pos.eqb_eq in E5. subst fid.
      destruct (floor_ext save_file.prog save_file._bcopy "bcopy" _ _ _ _ _ _ _ (linked12_LO_save lp H12)
                  eq_refl ltac:(vm_compute; reflexivity) Hs Hf Hev) as (sg & Hx').
      destruct (Hbc _ _ _ _ _ _ _ Hx') as (bs & os & bd & od & n & -> & UOd & _ & _).
      destruct al as [ | asrc [ | ad [ | an [ | ] ] ] ]; try discriminate Hok.
      inversion Hc as [ | ? ? ? ? _ Hc1 ]; subst.
      inversion Hc1 as [ | ? ? ? ? (Cd & _) _ ]; subst.
      apply (harm_change_blk m m' _ Hof UOd).
      intros b0 z Hnh. exact (outside_harm _ _ _ _ _ (Cd Hok bd od eq_refl) Hnh). }
    discriminate Hok.
  Qed.

  (* ---- a linked callee, by its contract ---- *)
  Lemma int_call : forall lv fl qa c e le m optid fid fty al t le' m' out f fl' qa',
      Env lv e -> Pt fl qa le -> ctab_ok c ->
      find_ct fid c = Some (f, (fl', qa')) ->
      args_ok lv fl qa fl' qa' (fn_params f) al = true -> opt_ok fl qa optid = true ->
      mem_id fid lv = false -> access_mode fty = By_reference ->
      exec_stmt function_entry2 ge e le m (Scall optid (Evar fid fty) al) t le' m' out ->
      OF m -> OF m' /\ Pt fl qa le'.
  Proof.
    intros lv fl qa c e le m optid fid fty al t le' m' out f fl' qa'
           HE HP Hct Hfind Hargs Hopt Hnl Am Hx Hof.
    pose proof HE as (Eh & En & Es).
    destruct (LptBody.scall_evar_inv_opt _ _ _ _ _ _ _ _ _ _ _ _ Hx (En fid Hnl) Am)
      as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hf & _ & Hel & Hev & -> & _).
    split; [ | exact (opt_Pt fl qa optid vres le Hopt HP) ].
    destruct (Hct _ _ _ _ Hfind) as ((b' & Hs' & Hf') & Hfp).
    rewrite Hs in Hs'. injection Hs' as <-. rewrite Hf in Hf'. injection Hf' as ->.
    apply (Hfp _ _ _ _ _ Hev); [ | exact Hof ].
    intros le0 Hb.
    exact (bind_cls fl' qa' _ _ _ _ Hb (args_cls lv fl qa fl' qa' e le m _ _ _ _ HE HP Hel Hargs)
             (undef_Pt fl' qa' _)).
  Qed.

  Lemma call_sound : forall lv fl qa c e le m optid a al t le' m' out,
      Env lv e -> Pt fl qa le -> ctab_ok c ->
      call_ok lv fl qa c optid a al = true ->
      exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
      OF m -> OF m' /\ Pt fl qa le'.
  Proof.
    intros lv fl qa c e le m optid a al t le' m' out HE HP Hct Hok Hx Hof.
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [call_ok] in Hok.
    apply andb_prop in Hok as [Hok Hd]. apply andb_prop in Hok as [Hnl Hopt].
    apply negb_true_iff in Hnl.
    destruct (find_ct fid c) as [[f [fl' qa']]|] eqn:Hfind.
    - exact (int_call lv fl qa c e le m optid fid (Tfunction targs tres tcc) al t le' m' out f fl' qa'
               HE HP Hct Hfind Hd Hopt Hnl eq_refl Hx Hof).
    - exact (floor_call lv fl qa e le m optid fid (Tfunction targs tres tcc) al t le' m' out HE HP Hd Hopt Hnl eq_refl Hx Hof).
  Qed.

  Lemma set_sound : forall lv fl qa e id a le m v,
      Env lv e -> set_ok lv fl qa id a = true -> Pt fl qa le ->
      eval_expr ge e le m a v -> Pt fl qa (PTree.set id v le).
  Proof.
    intros lv fl qa e id a le m v HE Hok HP Hev t w Hg.
    destruct (peq t id) as [-> | Hne].
    - rewrite PTree.gss in Hg. injection Hg as <-.
      apply andb_prop in Hok as [Hh Hq].
      split.
      + intros Hn. rewrite Hn in Hh. exact (proj1 (hx_sound lv fl qa e le m HE HP a) _ Hev Hh).
      + intros Hy. rewrite Hy in Hq. exact (hq_sound lv fl qa e le m HE HP a _ Hev Hq).
    - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
  Qed.

  Lemma store_sound : forall lv fl qa e lvx rhs le m t le' m' out,
      Env lv e -> store_ok lv fl lvx = true -> Pt fl qa le ->
      exec_stmt function_entry2 ge e le m (Sassign lvx rhs) t le' m' out ->
      OF m -> OF m'.
  Proof.
    intros lv fl qa e lvx rhs le m t le' m' out HE Hok HP Hx Hof.
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ lvx ?loc _ _ |- _ =>
      pose proof (proj2 (hx_sound lv fl qa e _ m HE HP lvx) _ _ _ Hl Hok) as Hh end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      exact (assign_harm _ _ _ _ _ _ _ Ha Hh Hof) end.
  Qed.

  (* ---- entry / exit ---- *)
  Lemma alloc_OF : forall e0 m vars e1 m1,
      alloc_variables ge e0 m vars e1 m1 -> OF m -> OF m1.
  Proof.
    intros e0 m vars e1 m1 Hav.
    induction Hav as [ | e0 m0 id ty vars0 m1 b1 m2 e2 Ha Hrest IH ]; intros Hf; [ exact Hf | ].
    apply IH. destruct Hf as (Hv & Hs & HM).
    split; [ exact (LocalVarsSurface.alloc_valid _ _ _ _ _ _ Ha Hv) | ].
    split; [ exact (LocalVarsSurface.alloc_action_sat _ _ _ _ _ _ _ Ha Hv Hs) | ].
    exact (mwf_real_alloc lp bm bc oc0 SafeB sd_Hbc_bm _ _ _ _ _ Ha HM).
  Qed.

  Lemma entry_env : forall m vars e m1,
      alloc_variables ge empty_env m vars e m1 -> MWF m ->
      Env (map fst vars) e.
  Proof.
    intros m vars e m1 Hav HM.
    split; [ | split ].
    - intros x b ty He.
      destruct (LocalVarsSurface.alloc_variables_not_valid _ _ _ _ _ _ Hav _ _ _ He)
        as [(ty0 & H0) | Hnv].
      + rewrite PTree.gempty in H0. discriminate H0.
      + exact (harm_fresh m b HM Hnv).
    - intros x Hx.
      rewrite (LocalVarsSurface.alloc_variables_unbound _ _ _ _ _ _ Hav x
                 (MtxfBody.mem_id_notin _ _ Hx)).
      apply PTree.gempty.
    - intros x Hx.
      destruct (LocalVarsSurface.alloc_variables_in_bound _ _ _ _ _ _ Hav x
                  (MtxfBody.mem_id_In _ _ Hx)) as (b & ty & H).
      congruence.
  Qed.

  Lemma body_fpres : forall f fl qa c,
      body_chk f fl qa c = true -> ctab_ok c -> fpres f fl qa.
  Proof.
    intros f fl qa c Hchk Hct m vargs t m' vres Hev Hb Hof.
    inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with
    | Hav : alloc_variables _ _ _ _ ?E ?M1,
      Hbd : bind_parameter_temps _ _ _ = Some ?LE,
      Hbody : exec_stmt _ _ ?E ?LE ?M1 _ _ _ ?M2 _,
      Hfree : Mem.free_list ?M2 _ = Some _ |- _ =>
      pose proof (entry_env _ _ _ _ Hav (proj2 (proj2 Hof))) as HE;
      pose proof (alloc_OF _ _ _ _ _ Hav Hof) as Hof1;
      destruct (hw_walk ge E OF (Pt fl qa) (set_ok (map fst (fn_vars f)) fl qa)
                  (store_ok (map fst (fn_vars f)) fl) (call_ok (map fst (fn_vars f)) fl qa c)
                  (fun id a le0 m0 v Hok HP _ Hv => set_sound _ fl qa E id a le0 m0 v HE Hok HP Hv)
                  (fun lvx rhs le0 m0 t0 le0' m0' out0 Hok HP Hx Hf0 =>
                     store_sound _ fl qa E lvx rhs le0 m0 t0 le0' m0' out0 HE Hok HP Hx Hf0)
                  (fun optid a al le0 m0 t0 le0' m0' out0 Hok HP Hx Hf0 =>
                     call_sound _ fl qa c E le0 m0 optid a al t0 le0' m0' out0 HE HP Hct Hok Hx Hf0)
                  _ _ _ _ _ _ _ _ Hbody eq_refl Hchk (Hb _ Hbd) Hof1) as (Hof2 & _);
      destruct Hof2 as (Hv2 & Hs2 & HM2);
      split; [ exact (LocalVarsSurface.free_list_valid_bm _ _ _ _ Hfree Hv2) | ];
      split; [ exact (LocalVarsSurface.free_list_action_sat _ _ _ _ _
                        (LocalVarsSurface.blocks_of_env_bm lp _ _ _ _ _ Hav (proj1 Hof))
                        Hfree Hs2) | ];
      exact (mwf_real_free lp bm bc oc0 SafeB sd_Hbc_bm _ _ _ Hfree HM2)
    end.
  Qed.

  (* ---------------------------------------------------------------- *)
  (* 6. The tree, bottom up.                                            *)
  (* ---------------------------------------------------------------- *)

  Ltac ct_ok c :=
    let fid := fresh "fid" in let f := fresh "f" in
    let fl' := fresh "fl'" in let qa' := fresh "qa'" in let H := fresh "H" in
    intros fid f fl' qa' H; unfold c in H; cbn [find_ct] in H;
    repeat match type of H with
    | (if Pos.eqb fid ?g then Some _ else _) = _ =>
        let E := fresh "E" in
        destruct (Pos.eqb fid g) eqn:E; cbv beta iota in H;
        [ apply Pos.eqb_eq in E; subst fid; injection H as <- <- <- | ]
    end;
    [ .. | discriminate H ].

  Ltac res q LO :=
    apply (linkorder_resolves_funct lp q _ _ (LO lp H12)); vm_compute; reflexivity.

  (* --- osCreateMesgQueue: six stores through its queue argument --- *)
  Lemma fp_cmq : fpres libultra_osCreateMesgQueue.f_osCreateMesgQueue [] [].
  Proof. apply (body_fpres _ _ _ []); [ vm_compute; reflexivity | intros ? ? ? ? H; discriminate H ]. Qed.

  (* --- __osSiCreateAccessQueue --- *)
  Definition ct_csq : ctab :=
    [(libultra_osSiCreateAccessQueue._osCreateMesgQueue,
      (libultra_osCreateMesgQueue.f_osCreateMesgQueue, ([], [])))].
  Lemma fp_csq : fpres libultra_osSiCreateAccessQueue.f___osSiCreateAccessQueue [] [].
  Proof.
    apply (body_fpres _ _ _ ct_csq); [ vm_compute; reflexivity | ].
    ct_ok ct_csq. split; [ res libultra_osCreateMesgQueue.prog linked12_LO_ultra_cmq | exact fp_cmq ].
  Qed.

  (* --- __osSiGetAccess / __osSiRelAccess --- *)
  Definition ct_ga : ctab :=
    [(libultra_osSiCreateAccessQueue.___osSiCreateAccessQueue,
      (libultra_osSiCreateAccessQueue.f___osSiCreateAccessQueue, ([], [])))].
  Lemma fp_ga : fpres libultra_osSiCreateAccessQueue.f___osSiGetAccess
                  [libultra_osSiCreateAccessQueue._t'1] [].
  Proof.
    apply (body_fpres _ _ _ ct_ga); [ vm_compute; reflexivity | ].
    ct_ok ct_ga. split; [ res libultra_osSiCreateAccessQueue.prog linked12_LO_ultra_si | exact fp_csq ].
  Qed.
  Lemma fp_ra : fpres libultra_osSiCreateAccessQueue.f___osSiRelAccess [] [].
  Proof. apply (body_fpres _ _ _ []); [ vm_compute; reflexivity | intros ? ? ? ? H; discriminate H ]. Qed.

  (* --- __osPackEepWriteData / __osEepStatus --- *)
  Lemma fp_pack : fpres libultra_osEepromWrite.f___osPackEepWriteData [] [].
  Proof. apply (body_fpres _ _ _ []); [ vm_compute; reflexivity | intros ? ? ? ? H; discriminate H ]. Qed.

  Definition fl_st : list ident :=
    [libultra_osEepromWrite._ret; libultra_osEepromWrite._t'2; libultra_osEepromWrite._t'3].
  Definition qa_mq : list ident := [libultra_osEepromWrite._mq].
  Lemma fp_st : fpres libultra_osEepromWrite.f___osEepStatus fl_st qa_mq.
  Proof. apply (body_fpres _ _ _ []); [ vm_compute; reflexivity | intros ? ? ? ? H; discriminate H ]. Qed.

  (* --- osEepromWrite --- *)
  Definition fl_ew : list ident :=
    [libultra_osEepromWrite._ret; libultra_osEepromWrite._t'1; libultra_osEepromWrite._t'3;
     libultra_osEepromWrite._t'4].
  Definition ct_ew : ctab :=
    [(libultra_osEepromWrite.___osSiGetAccess,
      (libultra_osSiCreateAccessQueue.f___osSiGetAccess, ([libultra_osSiCreateAccessQueue._t'1], [])));
     (libultra_osEepromWrite.___osEepStatus,
      (libultra_osEepromWrite.f___osEepStatus, (fl_st, qa_mq)));
     (libultra_osEepromWrite.___osPackEepWriteData,
      (libultra_osEepromWrite.f___osPackEepWriteData, ([], [])));
     (libultra_osEepromWrite.___osSiRelAccess,
      (libultra_osSiCreateAccessQueue.f___osSiRelAccess, ([], [])))].
  Lemma fp_ew : fpres libultra_osEepromWrite.f_osEepromWrite fl_ew qa_mq.
  Proof.
    apply (body_fpres _ _ _ ct_ew); [ vm_compute; reflexivity | ].
    ct_ok ct_ew.
    - split; [ res libultra_osSiCreateAccessQueue.prog linked12_LO_ultra_si | exact fp_ga ].
    - split; [ res libultra_osEepromWrite.prog linked12_LO_ultra_ew | exact fp_st ].
    - split; [ res libultra_osEepromWrite.prog linked12_LO_ultra_ew | exact fp_pack ].
    - split; [ res libultra_osSiCreateAccessQueue.prog linked12_LO_ultra_si | exact fp_ra ].
  Qed.

  (* --- osEepromLongWrite --- *)
  Definition fl_elw : list ident :=
    [libultra_osEepromLongWrite._result; libultra_osEepromLongWrite._t'1;
     libultra_osEepromLongWrite._t'2].
  Definition qa_elw : list ident := [libultra_osEepromLongWrite._mq].
  Definition ct_elw : ctab :=
    [(libultra_osEepromLongWrite._osEepromWrite,
      (libultra_osEepromWrite.f_osEepromWrite, (fl_ew, qa_mq)))].
  Lemma fp_elw : fpres libultra_osEepromLongWrite.f_osEepromLongWrite fl_elw qa_elw.
  Proof.
    apply (body_fpres _ _ _ ct_elw); [ vm_compute; reflexivity | ].
    ct_ok ct_elw. split; [ res libultra_osEepromWrite.prog linked12_LO_ultra_ew | exact fp_ew ].
  Qed.

  (* --- save_file.c --- *)
  Lemma fp_cs : fpres save_file.f_calc_checksum [] [].
  Proof. apply (body_fpres _ _ _ []); [ vm_compute; reflexivity | intros ? ? ? ? H; discriminate H ]. Qed.

  Definition ct_asig : ctab :=
    [(save_file._calc_checksum, (save_file.f_calc_checksum, ([], [])))].
  Lemma fp_asig : fpres save_file.f_add_save_block_signature [save_file._t'1] [].
  Proof.
    apply (body_fpres _ _ _ ct_asig); [ vm_compute; reflexivity | ].
    ct_ok ct_asig. split; [ res save_file.prog linked12_LO_save | exact fp_cs ].
  Qed.

  Definition fl_wed : list ident := [save_file._status; save_file._t'2].
  Definition ct_wed : ctab :=
    [(save_file._osEepromLongWrite,
      (libultra_osEepromLongWrite.f_osEepromLongWrite, (fl_elw, qa_elw)))].
  Lemma fp_wed : fpres save_file.f_write_eeprom_data fl_wed [].
  Proof.
    apply (body_fpres _ _ _ ct_wed); [ vm_compute; reflexivity | ].
    ct_ok ct_wed. split; [ res libultra_osEepromLongWrite.prog linked12_LO_ultra_elw | exact fp_elw ].
  Qed.

  Definition ct_mmd : ctab :=
    [(save_file._add_save_block_signature,
      (save_file.f_add_save_block_signature, ([save_file._t'1], [])));
     (save_file._write_eeprom_data, (save_file.f_write_eeprom_data, (fl_wed, [])))].
  Lemma fp_mmd : fpres save_file.f_save_main_menu_data [] [].
  Proof.
    apply (body_fpres _ _ _ ct_mmd); [ vm_compute; reflexivity | ].
    ct_ok ct_mmd.
    - split; [ res save_file.prog linked12_LO_save | exact fp_asig ].
    - split; [ res save_file.prog linked12_LO_save | exact fp_wed ].
  Qed.

  (* the argument fileIndex is untracked: ANY value *)
  Definition fl_sds : list ident := [save_file._fileIndex].
  Definition ct_sds : ctab :=
    [(save_file._save_main_menu_data, (save_file.f_save_main_menu_data, ([], [])));
     (save_file._add_save_block_signature,
      (save_file.f_add_save_block_signature, ([save_file._t'1], [])));
     (save_file._write_eeprom_data, (save_file.f_write_eeprom_data, (fl_wed, [])))].
  Lemma fp_sds : fpres save_file.f_save_file_do_save fl_sds [].
  Proof.
    apply (body_fpres _ _ _ ct_sds); [ vm_compute; reflexivity | ].
    ct_ok ct_sds.
    - split; [ res save_file.prog linked12_LO_save | exact fp_mmd ].
    - split; [ res save_file.prog linked12_LO_save | exact fp_asig ].
    - split; [ res save_file.prog linked12_LO_save | exact fp_wed ].
  Qed.

  Lemma dm_sds :
    (prog_defmap save_file.prog) ! save_file._save_file_do_save
      = Some (Gfun (Internal save_file.f_save_file_do_save)).
  Proof. vm_compute. reflexivity. Qed.

  (* any argument: the only parameter is untracked, every other temp starts
     undefined *)
  Lemma sp_sds : ObjExtBodies.sym_pres lp bm bc oc0 SafeB save_file._save_file_do_save.
  Proof.
    apply (ObjExtBodies.sym_pres_of_body lp bm bc oc0 SafeB save_file.prog _ _
             (linked12_LO_save lp H12) dm_sds).
    intros m vargs t m' vres Hev Hof.
    apply (fp_sds m vargs t m' vres Hev); [ | exact Hof ].
    intros le Hb t0 v Hg.
    split; [ | intros H; discriminate H ].
    intros Hn.
    rewrite (MathGeomBodies.bind_parameter_temps_gso _ _ _ _ t0 Hb) in Hg.
    - apply MtxfBody.create_undef_temps_get in Hg. subst v. intros b o E. discriminate E.
    - cbn [var_names map fst fn_params save_file.f_save_file_do_save].
      intros [E | []]. subst t0. vm_compute in Hn. discriminate Hn.
  Qed.

  (* THE ROW *)
  Lemma Hpx_sfds :
    call_pres_ext lp bm (fun m => ctl_a_clear m bm) MWF save_file._save_file_do_save.
  Proof. exact (ObjExtBodies.row_of_sym lp bm bc oc0 SafeB _ sp_sds). Qed.
End SDS.
