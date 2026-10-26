(* ====================================================================== *)
(* PollFlank (GOAL 2): the per-frame CONTROLLER POLL, from the real code  *)
(* down to the SI/PIF hardware floor (2026-10-23).                         *)
(*                                                                        *)
(* The real poll (game_main.c's loop, game_init.c, libultra):             *)
(*                                                                        *)
(*   if (gControllerBits) osContStartReadData(&gSIEventMesgQueue);        *)
(*   ... ; read_controller_inputs();                                       *)
(*                                                                        *)
(* osContStartReadData (lib/src/osContStartReadData.c, linked here) packs  *)
(* the read request into the PIF RAM image __osContPifRam, and runs the   *)
(* two SI DMAs (__osSiRawStartDma: write the request, read the reply):    *)
(* the reply bytes are what the HARDWARE delivers.  read_controller_inputs *)
(* (game_init.c) waits for the SI event (osRecvMesg), copies the reply     *)
(* into gControllerPads (osContGetReadData: per port, button / stick when *)
(* the reply's error bits are clear), masks the demo bits                  *)
(* (run_demo_inputs), and fills gControllers[0..1] from the pads           *)
(* (buttonPressed = button & (button ^ buttonDown), buttonDown = button,  *)
(* adjust_analog_stick), copying player 1 into player 3.                   *)
(*                                                                        *)
(* All of it is walked here over the generated Clight.  The only things   *)
(* not walked are the existing OS/hardware floor calls (OsDmaFloor, TRUST *)
(* 3.5): __osSiRawStartDma (the SI registers / PIF: it changes only the   *)
(* 64-byte PIF image, each byte to itself or to data), osRecvMesg /        *)
(* osSendMesg (thread queues), and sqrtf (FpuFloor).  NO new floor row.   *)
(*                                                                        *)
(* THE PREMISE (pif_a_real): the no-A premise is now a statement about    *)
(* the bytes the hardware delivered -- the PIF reply image after          *)
(* osContStartReadData: no port's reply has A_BUTTON set in its button    *)
(* word while its error bits (rxLen & 0xC0) are clear.  A port whose      *)
(* error bits are set (no controller plugged in) is ignored, exactly as   *)
(* osContGetReadData ignores it: its button bytes still hold the 0xFFFF   *)
(* that __osPackReadData's request template put there, so a premise that *)
(* also constrained those ports would be FALSE on real hardware with      *)
(* fewer than four controllers (the capstone would be vacuous).           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Memdata Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario memory save_file game_init interaction
  libultra_osContStartReadData libultra_osContInit libultra_osSiCreateAccessQueue math_util.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve OsDmaFloor
  CensusV2 MWFReal AGates SpawnInit ActionValueFrame Taint MathBodies.
From SM64.Proofs Require SaveDoSaveBody LptBody MtxfBody RealFrameValue.
From SM64.Proofs.WMotRRequiresA Require Import FpuFloor FfWorld.
Import ListNotations.
Local Open Scope Z_scope.

Module GI := game_init.
Module CR := libultra_osContStartReadData.
Module CI := libultra_osContInit.
Module SQ := libultra_osSiCreateAccessQueue.

(* cbn does not reduce Cop's sem_binarith / sem_cast on concrete types by
   itself (its refolding stops at them); unfold them first *)
Local Transparent Archi.ptr64.
Ltac vcbn H := cbn in H;
  repeat (progress (unfold sem_binarith, sem_shift, sem_cast in H); cbn in H).

(* ---------------------------------------------------------------------- *)
(* 0. The premise and the two calls.                                       *)
(* ---------------------------------------------------------------------- *)

(* port k's reply record in the PIF image (struct __869, 8 bytes: rxLen @2,
   button @4; pinned below by resp_offsets): A_BUTTON (0x8000) set in the
   button word AND the error bits (rxLen & 0xC0) clear.  A record whose
   bytes do not read as integers delivers no button (osContGetReadData
   cannot copy it: the walk below gets stuck on it). *)
Definition port_a (m : mem) (bp : block) (k : Z) : bool :=
  match Mem.load Mint16unsigned m bp (8 * k + 4), Mem.load Mint8unsigned m bp (8 * k + 2) with
  | Some (Vint n), Some (Vint r) =>
      negb (Int.eq (Int.and n (Int.repr 32768)) Int.zero)
      && Int.eq (Int.and r (Int.repr 192)) Int.zero
  | _, _ => false
  end.

(* THE NO-A PREMISE: the hardware reply shows A on no live port. *)
Definition pif_a_real (G : genv) (m : mem) : bool :=
  match Genv.find_symbol G CI.___osContPifRam with
  | Some bp => port_a m bp 0 || port_a m bp 1 || port_a m bp 2 || port_a m bp 3
  | None => true
  end.

(* osContStartReadData(&gSIEventMesgQueue), the real body *)
Definition srd_call (lp : Clight.program) (m i : mem) : Prop :=
  exists bq t vres, Genv.find_symbol (lp_ge lp) save_file._gSIEventMesgQueue = Some bq
    /\ eval_funcall function_entry2 (lp_ge lp) m (Internal CR.f_osContStartReadData)
         [Vptr bq Ptrofs.zero] t i vres.

(* read_controller_inputs(), the real body *)
Definition rci_call (lp : Clight.program) (i m0 : mem) : Prop :=
  exists t vres,
    eval_funcall function_entry2 (lp_ge lp) i (Internal GI.f_read_controller_inputs) [] t m0 vres.

(* the gate-A conjunct of the frame: what Mario's controller holds after the
   poll is A-free (both the press and the hold) *)

(* ---------------------------------------------------------------------- *)
(* 1. Layout facts, read off the TUs' composite environments.              *)
(* ---------------------------------------------------------------------- *)

Definition fo_q (env : composite_env) (sid f : ident) : option (Z * bitfield) :=
  match env ! sid with
  | Some co =>
      if complete_members env (co_members co) then
        match field_offset env f (co_members co) with
        | Errors.OK d => Some d | Errors.Error _ => None end
      else None
  | None => None
  end.

Notation gi_fo := (fo_q (prog_comp_env GI.prog)).
Notation cr_fo := (fo_q (prog_comp_env CR.prog)).

Lemma ctl_offsets :
  gi_fo GI._Controller GI._rawStickX = Some (0, Full)
  /\ gi_fo GI._Controller GI._rawStickY = Some (2, Full)
  /\ gi_fo GI._Controller GI._stickX = Some (4, Full)
  /\ gi_fo GI._Controller GI._stickY = Some (8, Full)
  /\ gi_fo GI._Controller GI._stickMag = Some (12, Full)
  /\ gi_fo GI._Controller GI._buttonDown = Some (16, Full)
  /\ gi_fo GI._Controller GI._buttonPressed = Some (18, Full)
  /\ gi_fo GI._Controller GI._controllerData = Some (24, Full)
  /\ gi_fo GI.__319 GI._button = Some (0, Full)
  /\ gi_fo GI.__319 GI._stick_x = Some (2, Full)
  /\ gi_fo GI.__319 GI._stick_y = Some (3, Full).
Proof. vm_compute. repeat split. Qed.

Lemma resp_offsets :
  cr_fo CR.__869 CR._rxLen = Some (2, Full)
  /\ cr_fo CR.__869 CR._button = Some (4, Full)
  /\ cr_fo CR.__869 CR._rawStickX = Some (6, Full)
  /\ cr_fo CR.__869 CR._rawStickY = Some (7, Full)
  /\ cr_fo CR.__319 CR._button = Some (0, Full)
  /\ cr_fo CR.__319 CR._stick_x = Some (2, Full)
  /\ cr_fo CR.__319 CR._stick_y = Some (3, Full)
  /\ cr_fo CR.__319 CR._errnum = Some (4, Full).
Proof. vm_compute. repeat split. Qed.

Lemma sizes :
  sizeof (prog_comp_env CR.prog) (Tstruct CR.__869 noattr) = 8
  /\ sizeof (prog_comp_env CR.prog) (Tstruct CR.__319 noattr) = 6
  /\ sizeof (prog_comp_env GI.prog) (Tstruct GI._Controller noattr) = 28.
Proof. vm_compute. repeat split. Qed.

Section LAYOUT.
  Variable lp : Clight.program.
  Local Notation G := (lp_ge lp).

  Lemma fo_lp : forall q, linkorder q lp -> forall sid f d, fo_q (prog_comp_env q) sid f = Some d ->
      forall co, (genv_cenv G) ! sid = Some co -> field_offset (genv_cenv G) f (co_members co) = Errors.OK d.
  Proof.
    intros q LO sid f d Hm co Hco. unfold fo_q in Hm.
    destruct ((prog_comp_env q) ! sid) as [co0|] eqn:E; [| discriminate Hm].
    destruct (complete_members (prog_comp_env q) (co_members co0)) eqn:Ec; [| discriminate Hm].
    destruct (field_offset (prog_comp_env q) f (co_members co0)) eqn:Ef; [| discriminate Hm].
    injection Hm as <-.
    pose proof (linkorder_comp_env_extends lp q sid co0 LO E) as E'.
    change (genv_cenv G) with (prog_comp_env lp) in Hco |- *.
    rewrite E' in Hco. injection Hco as <-.
    rewrite (field_offset_stable (prog_comp_env q) (prog_comp_env lp)
               (fun id c H => linkorder_comp_env_extends lp q id c LO H) f _ Ec).
    exact Ef.
  Qed.

  Lemma sizeof_lp : forall q, linkorder q lp -> forall sid a n,
      sizeof (prog_comp_env q) (Tstruct sid a) = n -> n <> 0 ->
      sizeof (genv_cenv G) (Tstruct sid a) = n.
  Proof.
    intros q LO sid a n H Hn. cbn [sizeof] in *.
    destruct ((prog_comp_env q) ! sid) as [co|] eqn:E; [| congruence].
    change (genv_cenv G) with (prog_comp_env lp).
    rewrite (linkorder_comp_env_extends lp q sid co LO E). exact H.
  Qed.
End LAYOUT.

(* ---------------------------------------------------------------------- *)
(* 2. Generic Clight inversions.                                           *)
(* ---------------------------------------------------------------------- *)

Section INV.
  Variable ge : genv.

  Lemma ev_tmp : forall e le m x ty v, eval_expr ge e le m (Etempvar x ty) v -> le ! x = Some v.
  Proof. intros e le m x ty v H. inv H; [ assumption | inv H0 ]. Qed.

  Lemma ev_const : forall e le m n ty v, eval_expr ge e le m (Econst_int n ty) v -> v = Vint n.
  Proof. intros e le m n ty v H. inv H; [ reflexivity | inv H0 ]. Qed.

  (* the base of a field access through a struct pointer *)
  Lemma ev_deref_struct : forall e le m a sid att loc ofs,
      eval_expr ge e le m (Ederef a (Tstruct sid att)) (Vptr loc ofs) ->
      eval_expr ge e le m a (Vptr loc ofs).
  Proof.
    intros e le m a sid att loc ofs H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _, Hd : deref_loc _ _ _ _ _ _ |- _ =>
      apply RealFrameValue.deref_loc_aggregate_eq in Hd as [-> ->]; [ inv Hl; assumption | right; reflexivity ]
    end.
  Qed.

  Lemma fld_lv : forall e le m a sid att f ty loc ofs bf,
      eval_lvalue ge e le m (Efield (Ederef a (Tstruct sid att)) f ty) loc ofs bf ->
      exists o0 co delta, eval_expr ge e le m a (Vptr loc o0)
        /\ (genv_cenv ge) ! sid = Some co
        /\ field_offset (genv_cenv ge) f (co_members co) = Errors.OK (delta, bf)
        /\ ofs = Ptrofs.add o0 (Ptrofs.repr delta).
  Proof.
    intros e le m a sid att f ty loc ofs bf H.
    apply RealFrameValue.eval_lvalue_Efield_inv in H as (o0 & id & att' & co & delta & Ha & Hco & Hofs & Hcase).
    cbn [typeof] in Hcase. destruct Hcase as [(Ht & Hfo) | (Ht & _)]; [ | discriminate Ht ].
    injection Ht as <- <-.
    exists o0, co, delta. split; [ exact (ev_deref_struct _ _ _ _ _ _ _ _ Ha) | auto ].
  Qed.

  (* a by-value field read *)
  Lemma fld_load : forall e le m a sid att f ty v ch delta,
      (forall co, (genv_cenv ge) ! sid = Some co ->
         field_offset (genv_cenv ge) f (co_members co) = Errors.OK (delta, Full)) ->
      access_mode ty = By_value ch -> type_is_volatile ty = false ->
      eval_expr ge e le m (Efield (Ederef a (Tstruct sid att)) f ty) v ->
      exists loc o0, eval_expr ge e le m a (Vptr loc o0)
        /\ Mem.load ch m loc (Ptrofs.unsigned (Ptrofs.add o0 (Ptrofs.repr delta))) = Some v.
  Proof.
    intros e le m a sid att f ty v ch delta Hfo Ham Hvol H.
    apply RealFrameValue.eval_expr_Efield_load in H as (loc & ofs & bf & Hl & Hd).
    apply fld_lv in Hl as (o0 & co & delta' & Ha & Hco & Hf & ->).
    rewrite (Hfo co Hco) in Hf. injection Hf as <- <-.
    exists loc, o0. split; [ exact Ha | ].
    inv Hd; try congruence.
    match goal with Ha' : access_mode _ = By_value ?c, Hl : Mem.loadv ?c _ _ = Some _ |- _ =>
      rewrite Ham in Ha'; injection Ha' as <-; exact Hl end.
  Qed.

  Lemma fld_load' : forall e le m a sid att f ty v ch delta,
      (forall co, (genv_cenv ge) ! sid = Some co ->
         field_offset (genv_cenv ge) f (co_members co) = Errors.OK (delta, Full)) ->
      eval_expr ge e le m (Efield (Ederef a (Tstruct sid att)) f ty) v ->
      access_mode ty = By_value ch -> type_is_volatile ty = false ->
      exists loc o0, eval_expr ge e le m a (Vptr loc o0)
        /\ Mem.load ch m loc (Ptrofs.unsigned (Ptrofs.add o0 (Ptrofs.repr delta))) = Some v.
  Proof. intros e le m a sid att f ty v ch delta Hfo H Ham Hvol. exact (fld_load _ _ _ _ _ _ _ _ _ _ _ Hfo Ham Hvol H). Qed.


  (* a by-value field store *)
  Lemma fld_store : forall e le m a sid att f ty rhs t le' m' out ch delta,
      (forall co, (genv_cenv ge) ! sid = Some co ->
         field_offset (genv_cenv ge) f (co_members co) = Errors.OK (delta, Full)) ->
      access_mode ty = By_value ch -> type_is_volatile ty = false ->
      exec_stmt function_entry2 ge e le m (Sassign (Efield (Ederef a (Tstruct sid att)) f ty) rhs)
        t le' m' out ->
      le' = le /\ out = Out_normal /\ t = E0
      /\ exists loc o0 v v', eval_expr ge e le m a (Vptr loc o0)
           /\ eval_expr ge e le m rhs v /\ sem_cast v (typeof rhs) ty m = Some v'
           /\ Mem.store ch m loc (Ptrofs.unsigned (Ptrofs.add o0 (Ptrofs.repr delta))) v' = Some m'.
  Proof.
    intros e le m a sid att f ty rhs t le' m' out ch delta Hfo Ham Hvol H.
    inv H. split; [ reflexivity | split; [ reflexivity | split; [ reflexivity | ] ] ].
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      apply fld_lv in Hl as (o0 & co & delta' & Ha & Hco & Hf & ->) end.
    rewrite (Hfo co Hco) in Hf. injection Hf as <- <-.
    match goal with Hs : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Hs end; cbn [typeof] in *; try congruence.
    match goal with Ha' : access_mode _ = By_value ?c, Hs : Mem.storev ?c _ _ _ = Some _ |- _ =>
      rewrite Ham in Ha'; injection Ha' as <- end.
    do 4 eexists. split; [ exact Ha | split; [ eassumption | split; [ eassumption | eassumption ] ] ].
  Qed.

  Lemma fld_store' : forall e le m a sid att f ty rhs t le' m' out ch delta,
      (forall co, (genv_cenv ge) ! sid = Some co ->
         field_offset (genv_cenv ge) f (co_members co) = Errors.OK (delta, Full)) ->
      exec_stmt function_entry2 ge e le m (Sassign (Efield (Ederef a (Tstruct sid att)) f ty) rhs)
        t le' m' out ->
      access_mode ty = By_value ch -> type_is_volatile ty = false ->
      le' = le /\ out = Out_normal /\ t = E0
      /\ exists loc o0 v v', eval_expr ge e le m a (Vptr loc o0)
           /\ eval_expr ge e le m rhs v /\ sem_cast v (typeof rhs) ty m = Some v'
           /\ Mem.store ch m loc (Ptrofs.unsigned (Ptrofs.add o0 (Ptrofs.repr delta))) v' = Some m'.
  Proof. intros e le m a sid att f ty rhs t le' m' out ch delta Hfo H Ham Hvol. exact (fld_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hfo Ham Hvol H). Qed.


  (* a scalar global read *)
  Lemma ev_gvar : forall e le m g ty v ch,
      e ! g = None -> access_mode ty = By_value ch -> type_is_volatile ty = false ->
      eval_expr ge e le m (Evar g ty) v ->
      exists b, Genv.find_symbol ge g = Some b /\ Mem.load ch m b 0 = Some v.
  Proof.
    intros e le m g ty v ch He Ham Hvol H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _, Hd : deref_loc _ _ _ _ _ _ |- _ =>
      inv Hl; [ congruence | ]; inv Hd; cbn [typeof] in *; try congruence end.
    match goal with Hs : Genv.find_symbol _ _ = Some ?b |- _ => exists b; split; [ exact Hs | ] end.
    match goal with Hl : Mem.loadv ?c _ _ = Some _ |- _ =>
      assert (Ec : c = ch) by congruence; rewrite Ec in Hl; exact Hl end.
  Qed.

  Lemma ev_gvar' : forall e le m g ty v ch,
      e ! g = None -> eval_expr ge e le m (Evar g ty) v ->
      access_mode ty = By_value ch -> type_is_volatile ty = false ->
      exists b, Genv.find_symbol ge g = Some b /\ Mem.load ch m b 0 = Some v.
  Proof. intros e le m g ty v ch He H Ham Hvol. exact (ev_gvar _ _ _ _ _ _ _ He Ham Hvol H). Qed.


  Lemma seq_inv2 : forall e le m s1 s2 t le' m' out,
      exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out ->
      (exists t1 le1 m1 t2, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 Out_normal
          /\ exec_stmt function_entry2 ge e le1 m1 s2 t2 le' m' out)
      \/ (exec_stmt function_entry2 ge e le m s1 t le' m' out /\ out <> Out_normal).
  Proof.
    intros e le m s1 s2 t le' m' out H. inv H.
    - left. do 4 eexists. split; eassumption.
    - right. split; assumption.
  Qed.
End INV.

(* the two A-bit facts the values need *)
Lemma and_A_zext16 : forall x,
    Int.and (Int.zero_ext 16 x) (Int.repr 32768) = Int.and x (Int.repr 32768).
Proof.
  intros x. rewrite Int.zero_ext_and by lia.
  rewrite Int.and_assoc. f_equal.
Qed.

Lemma and_A_and : forall x y,
    Int.and x (Int.repr 32768) = Int.zero -> Int.and (Int.and x y) (Int.repr 32768) = Int.zero.
Proof.
  intros x y H. rewrite Int.and_assoc, (Int.and_commut y), <- Int.and_assoc, H.
  apply Int.and_zero_l.
Qed.

(* errnum == 0 means the error bits are clear: (u8)((r & 0xC0) >> 4) == 0
   for a byte r forces r & 0xC0 == 0 *)
Lemma errnum_zero : forall r,
    Int.unsigned r < 256 ->
    Int.eq (Int.zero_ext 8 (Int.zero_ext 8 (Int.shr (Int.and r (Int.repr 192)) (Int.repr 4)))) Int.zero
      = true ->
    Int.eq (Int.and r (Int.repr 192)) Int.zero = true.
Proof.
  intros r Hr.
  assert (K : forall z, 0 <= z < 256 ->
            implb (Int.eq (Int.zero_ext 8 (Int.zero_ext 8 (Int.shr (Int.and (Int.repr z) (Int.repr 192))
                                                                     (Int.repr 4)))) Int.zero)
                  (Int.eq (Int.and (Int.repr z) (Int.repr 192)) Int.zero) = true).
  { assert (A : forallb (fun n => let z := Z.of_nat n in
                  implb (Int.eq (Int.zero_ext 8 (Int.zero_ext 8 (Int.shr (Int.and (Int.repr z) (Int.repr 192))
                                                                           (Int.repr 4)))) Int.zero)
                        (Int.eq (Int.and (Int.repr z) (Int.repr 192)) Int.zero)) (seq 0 256) = true)
      by (vm_compute; reflexivity).
    intros z Hz. rewrite forallb_forall in A.
    specialize (A (Z.to_nat z) ltac:(apply in_seq; lia)). cbv beta zeta in A.
    rewrite Z2Nat.id in A by lia. exact A. }
  pose proof (Int.unsigned_range r) as R.
  rewrite <- (Int.repr_unsigned r). intros H.
  specialize (K (Int.unsigned r) ltac:(lia)). rewrite H in K. exact K.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. osContStartReadData keeps GOAL 1's facts: every byte its tree        *)
(*    writes lies in a harm block (SaveDoSaveBody's walk): the PIF image   *)
(*    __osContPifRam, __osContLastCmd, the SI access queue, the SI event   *)
(*    queue, the request local.                                            *)
(* ---------------------------------------------------------------------- *)

Section SRD.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Hypothesis Hfloor : os_dma_floor.

  Lemma fp_prd : SaveDoSaveBody.fpres lp bm bc oc0 SafeB CR.f___osPackReadData [] [].
  Proof.
    apply (SaveDoSaveBody.body_fpres lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor _ _ _ []);
      [ vm_compute; reflexivity | intros ? ? ? ? H; discriminate H ].
  Qed.

  Definition fl_srd : list ident := [CR._ret; CR._t'1; CR._t'2].
  Definition qa_srd : list ident := [CR._mesg].
  Definition ct_srd : SaveDoSaveBody.ctab :=
    [(CR.___osSiGetAccess, (SQ.f___osSiGetAccess, ([SQ._t'1], [])));
     (CR.___osPackReadData, (CR.f___osPackReadData, ([], [])));
     (CR.___osSiRelAccess, (SQ.f___osSiRelAccess, ([], [])))].

  Lemma fp_srd : SaveDoSaveBody.fpres lp bm bc oc0 SafeB CR.f_osContStartReadData fl_srd qa_srd.
  Proof.
    apply (SaveDoSaveBody.body_fpres lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor _ _ _ ct_srd);
      [ vm_compute; reflexivity | ].
    intros fid f fl' qa' H. unfold ct_srd in H. cbn [SaveDoSaveBody.find_ct] in H.
    repeat match type of H with
    | (if Pos.eqb fid ?g then Some _ else _) = _ =>
        let E := fresh "E" in
        destruct (Pos.eqb fid g) eqn:E; cbv beta iota in H;
        [ apply Pos.eqb_eq in E; subst fid; injection H as <- <- <- | ]
    end; [ | | | discriminate H ].
    - split; [ apply (linkorder_resolves_funct lp SQ.prog _ _ (linked12_LO_ultra_si lp H12));
               vm_compute; reflexivity
             | exact (SaveDoSaveBody.fp_ga lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor) ].
    - split; [ apply (linkorder_resolves_funct lp CR.prog _ _
                        (linked12_LO_libultra_osContStartReadData lp H12));
               vm_compute; reflexivity
             | exact fp_prd ].
    - split; [ apply (linkorder_resolves_funct lp SQ.prog _ _ (linked12_LO_ultra_si lp H12));
               vm_compute; reflexivity
             | exact (SaveDoSaveBody.fp_ra lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor) ].
  Qed.

  (* THE SRD ROW: the real osContStartReadData(&gSIEventMesgQueue) keeps
     GOAL 1's carried facts *)
  Lemma srd_ok : forall m i,
      ow_facts bm (MWF_real lp bm bc oc0 SafeB) m -> srd_call lp m i ->
      ow_facts bm (MWF_real lp bm bc oc0 SafeB) i.
  Proof.
    intros m i Hof (bq & t & vres & Hq & Hev).
    apply (fp_srd m _ t i vres Hev); [ | exact Hof ].
    intros le Hb t0 v Hg.
    cbn [CR.f_osContStartReadData fn_params fn_temps bind_parameter_temps] in Hb.
    injection Hb as <-.
    destruct (Pos.eq_dec t0 CR._mesg) as [-> | Ne].
    - rewrite PTree.gss in Hg. injection Hg as <-.
      split.
      + intros _ b o E. injection E as <- _.
        exact (SaveDoSaveBody.harm_sglob lp bm bc oc0 SafeB HSafeB_syms Hspawn
                 save_file._gSIEventMesgQueue bq ltac:(vm_compute; reflexivity) Hq).
      + intros _ b o E. injection E as <- _.
        exists save_file._gSIEventMesgQueue, []. split; [ vm_compute; reflexivity | exact Hq ].
    - rewrite PTree.gso in Hg by exact Ne.
      assert (Ev : v = Vundef).
      { revert Hg.
        repeat (rewrite PTree.gsspec; destruct (peq _ _); [ intro E; injection E as <-; reflexivity | ]).
        rewrite PTree.gempty. intro E; discriminate E. }
      subst v.
      split; [ intros _ b o E; discriminate E | ].
      intros Hm. exfalso. apply Ne. unfold qa_srd, mem_id in Hm. cbn [existsb] in Hm.
      rewrite orb_false_r in Hm. apply Pos.eqb_eq in Hm. exact Hm.
  Qed.
End SRD.

(* ---------------------------------------------------------------------- *)
(* 4. Generic tools for the walks: expression equality, frees, byte copies *)
(* ---------------------------------------------------------------------- *)

Definition expr_eq_dec : forall a b : expr, {a = b} + {a <> b}.
Proof.
  assert (UO : forall x y : unary_operation, {x = y} + {x <> y}) by decide equality.
  assert (BO : forall x y : binary_operation, {x = y} + {x <> y}) by decide equality.
  decide equality;
    first [ apply type_eq | apply Int.eq_dec | apply Int64.eq_dec | apply Float.eq_dec
          | apply Float32.eq_dec | apply Pos.eq_dec | apply UO | apply BO ].
Defined.

Definition expr_eqb (a b : expr) : bool := if expr_eq_dec a b then true else false.

Lemma expr_eqb_eq : forall a b, expr_eqb a b = true -> a = b.
Proof. intros a b H. unfold expr_eqb in H. destruct (expr_eq_dec a b); [ exact e | discriminate H ]. Qed.

Lemma free_list_unch : forall l m m' (P : block -> Z -> Prop),
    Mem.free_list m l = Some m' ->
    (forall b lo hi, In (b, lo, hi) l -> forall z, ~ P b z) -> Mem.unchanged_on P m m'.
Proof.
  induction l as [| [[b lo] hi] l IH]; intros m m' P H K; vcbn H.
  - injection H as <-. apply Mem.unchanged_on_refl.
  - destruct (Mem.free m b lo hi) as [m1|] eqn:F; [ | discriminate H ].
    eapply Mem.unchanged_on_trans.
    + eapply Mem.free_unchanged_on; [ exact F | intros z _; exact (K b lo hi (or_introl eq_refl) z) ].
    + apply (IH m1 m' P H). intros b' lo' hi' Hin. exact (K b' lo' hi' (or_intror Hin)).
Qed.

Lemma free_env_unch : forall (ge : genv) e m m' (P : block -> Z -> Prop),
    Mem.free_list m (blocks_of_env ge e) = Some m' ->
    (forall id b ty, e ! id = Some (b, ty) -> forall z, ~ P b z) -> Mem.unchanged_on P m m'.
Proof.
  intros ge e m m' P H K. apply (free_list_unch _ _ _ P H).
  intros b lo hi Hin z. unfold blocks_of_env in Hin. apply in_map_iff in Hin as ([id [b' ty]] & E & Hin).
  unfold block_of_binding in E. injection E as -> _ _.
  exact (K id b ty (PTree.elements_complete e id (b, ty) Hin) z).
Qed.

(* a sub-range of a byte read *)
Lemma lb_sub : forall m b o n l d k,
    Mem.loadbytes m b o n = Some l -> 0 <= d -> 0 <= k -> d + k <= n ->
    Mem.loadbytes m b (o + d) k = Some (firstn (Z.to_nat k) (skipn (Z.to_nat d) l)).
Proof.
  intros m b o n l d k H Hd Hk Hn.
  replace n with (d + (n - d)) in H by lia.
  destruct (Mem.loadbytes_split _ _ _ _ _ _ H ltac:(lia) ltac:(lia)) as (l1 & l2 & H1 & H2 & ->).
  replace (n - d) with (k + (n - d - k)) in H2 by lia.
  destruct (Mem.loadbytes_split _ _ _ _ _ _ H2 ltac:(lia) ltac:(lia)) as (l3 & l4 & H3 & H4 & ->).
  rewrite H3. f_equal.
  apply Mem.loadbytes_length in H1. apply Mem.loadbytes_length in H3.
  rewrite skipn_app, <- H1, skipn_all, Nat.sub_diag. cbn [app skipn].
  rewrite firstn_app, <- H3, firstn_all, Nat.sub_diag. cbn [firstn]. rewrite app_nil_r. reflexivity.
Qed.

(* a field of a block copy reads as the source's *)
Lemma copy_load : forall mm bs os bytes bd mm' ch d v,
    Mem.loadbytes mm bs os 8 = Some bytes ->
    Mem.storebytes mm bd 0 bytes = Some mm' ->
    0 <= d -> d + size_chunk ch <= 8 -> (align_chunk ch | os + d) ->
    Mem.load ch mm' bd d = Some v -> Mem.load ch mm bs (os + d) = Some v.
Proof.
  intros mm bs os bytes bd mm' ch d v Hl Hs Hd Hdn Ha Hld.
  pose proof (Mem.loadbytes_length _ _ _ _ _ Hl) as Len.
  pose proof (Mem.loadbytes_storebytes_same _ _ _ _ _ Hs) as Lb.
  rewrite Len in Lb. change (Z.of_nat (Z.to_nat 8)) with 8 in Lb.
  destruct (Mem.load_loadbytes _ _ _ _ _ Hld) as (bs1 & Hb1 & ->).
  pose proof (size_chunk_pos ch) as Pc.
  pose proof (lb_sub _ _ _ _ _ d (size_chunk ch) Lb Hd ltac:(lia) Hdn) as S1.
  rewrite Z.add_0_l in S1. rewrite Hb1 in S1. injection S1 as ->.
  apply Mem.loadbytes_load; [ | exact Ha ].
  exact (lb_sub _ _ _ _ _ d (size_chunk ch) Hl Hd ltac:(lia) Hdn).
Qed.

(* a pointer cast keeps the pointer *)
Lemma cast_ptr : forall v t1 t2 m b o, sem_cast v t1 t2 m = Some (Vptr b o) ->
    (exists o', v = Vptr b o') .
Proof.
  intros v t1 t2 m b o H. unfold sem_cast in H.
  destruct (classify_cast t1 t2); destruct v; try discriminate H;
    repeat match type of H with
    | context [ if ?c then _ else _ ] => destruct c
    | context [ match ?x with _ => _ end ] => destruct x
    end; try discriminate H; inv H; eauto.
Qed.

Lemma ld16_cls : forall m b z v, Mem.load Mint16unsigned m b z = Some v ->
    v = Vundef \/ exists n, v = Vint n.
Proof.
  intros m b z v H. apply Mem.load_result in H. subst v.
  unfold decode_val. destruct (proj_bytes _); cbn; [ right; eauto | left; reflexivity ].
Qed.

Lemma fo_c_rsx : gi_fo GI._Controller GI._rawStickX = Some (0, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_c_rsy : gi_fo GI._Controller GI._rawStickY = Some (2, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_c_sx : gi_fo GI._Controller GI._stickX = Some (4, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_c_sy : gi_fo GI._Controller GI._stickY = Some (8, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_c_sm : gi_fo GI._Controller GI._stickMag = Some (12, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_c_bd : gi_fo GI._Controller GI._buttonDown = Some (16, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_c_bp : gi_fo GI._Controller GI._buttonPressed = Some (18, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_c_cd : gi_fo GI._Controller GI._controllerData = Some (24, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_p_btn : gi_fo GI.__319 GI._button = Some (0, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_r_rx : cr_fo CR.__869 CR._rxLen = Some (2, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_r_btn : cr_fo CR.__869 CR._button = Some (4, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_r_sx : cr_fo CR.__869 CR._rawStickX = Some (6, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_r_sy : cr_fo CR.__869 CR._rawStickY = Some (7, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_q_btn : cr_fo CR.__319 CR._button = Some (0, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_q_sx : cr_fo CR.__319 CR._stick_x = Some (2, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_q_sy : cr_fo CR.__319 CR._stick_y = Some (3, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_q_err : cr_fo CR.__319 CR._errnum = Some (4, Full). Proof. vm_compute. reflexivity. Qed.
Lemma fo_pif_ram : cr_fo CR.__1332 CR._ramarray = Some (0, Full). Proof. vm_compute. reflexivity. Qed.

Lemma max_u : Ptrofs.max_unsigned = 4294967295.
Proof. reflexivity. Qed.

Lemma ofs_small : forall a d, 0 <= a -> 0 <= d -> a + d <= Ptrofs.max_unsigned ->
    Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr a) (Ptrofs.repr d)) = a + d.
Proof.
  intros a d Ha Hd H. unfold Ptrofs.add.
  rewrite (Ptrofs.unsigned_repr a), (Ptrofs.unsigned_repr d) by lia.
  apply Ptrofs.unsigned_repr. lia.
Qed.

(* ---------------------------------------------------------------------- *)
(* 5. read_controller_inputs: the section.                                 *)
(* ---------------------------------------------------------------------- *)

Definition Aclr (n : int) : Prop := Int.and n (Int.repr 32768) = Int.zero.

Section RCI.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Hypothesis Hsq : sqrtf_spec.
  Local Notation G := (lp_ge lp).

  Variables bc bpads bq brm bpif bmx bp1 bp3 bdm : block.
  Hypothesis Hbc : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hpads : Genv.find_symbol G GI._gControllerPads = Some bpads.
  Hypothesis Hq : Genv.find_symbol G save_file._gSIEventMesgQueue = Some bq.
  Hypothesis Hrm : Genv.find_symbol G memory._gMainReceivedMesg = Some brm.
  Hypothesis Hpif : Genv.find_symbol G CI.___osContPifRam = Some bpif.
  Hypothesis Hmx : Genv.find_symbol G CI.___osMaxControllers = Some bmx.
  Hypothesis Hp1 : Genv.find_symbol G GI._gPlayer1Controller = Some bp1.
  Hypothesis Hp3 : Genv.find_symbol G GI._gPlayer3Controller = Some bp3.
  Hypothesis Hdm : Genv.find_symbol G GI._gCurrDemoInput = Some bdm.

  Lemma sne : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 ->
      Genv.find_symbol G id2 = Some b2 -> Pos.eqb id1 id2 = false -> b1 <> b2.
  Proof.
    intros id1 id2 b1 b2 H1 H2 N. apply Pos.eqb_neq in N.
    exact (Genv.global_addresses_distinct G N H1 H2).
  Qed.
  Ltac ne H1 H2 := exact (sne _ _ _ _ H1 H2 ltac:(vm_compute; reflexivity)).

  Lemma LO_gi : linkorder GI.prog lp.
  Proof.
    exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_cons _ _ _ (in_eq _ _))))))))))))))) H12).
  Qed.
  Lemma LO_cr : linkorder CR.prog lp.
  Proof. exact (linked12_LO_libultra_osContStartReadData lp H12). Qed.

  Lemma fc : forall f d, gi_fo GI._Controller f = Some d -> forall co,
      (genv_cenv G) ! GI._Controller = Some co -> field_offset (genv_cenv G) f (co_members co) = Errors.OK d.
  Proof. intros f d H. exact (fo_lp lp GI.prog LO_gi _ _ _ H). Qed.
  Lemma fp : forall f d, gi_fo GI.__319 f = Some d -> forall co,
      (genv_cenv G) ! GI.__319 = Some co -> field_offset (genv_cenv G) f (co_members co) = Errors.OK d.
  Proof. intros f d H. exact (fo_lp lp GI.prog LO_gi _ _ _ H). Qed.
  Lemma fr : forall f d, cr_fo CR.__869 f = Some d -> forall co,
      (genv_cenv G) ! CR.__869 = Some co -> field_offset (genv_cenv G) f (co_members co) = Errors.OK d.
  Proof. intros f d H. exact (fo_lp lp CR.prog LO_cr _ _ _ H). Qed.
  Lemma fq : forall f d, cr_fo CR.__319 f = Some d -> forall co,
      (genv_cenv G) ! CR.__319 = Some co -> field_offset (genv_cenv G) f (co_members co) = Errors.OK d.
  Proof. intros f d H. exact (fo_lp lp CR.prog LO_cr _ _ _ H). Qed.

  Definition pads_ac (m : mem) : Prop := forall k n, 0 <= k < 4 ->
      Mem.load Mint16unsigned m bpads (6 * k) = Some (Vint n) -> Aclr n.
  Definition btn_ok (m : mem) : Prop := forall z, z = 16 \/ z = 18 ->
      exists v, Mem.load Mint16unsigned m bc z = Some (Vint v) /\ Aclr v.

  (* ---- osRecvMesg(&gSIEventMesgQueue, &gMainReceivedMesg, 1) ---- *)
  Lemma recv_step : forall le m t le' m' out q tq tq' r tr tr' n tn fty,
      exec_stmt function_entry2 G empty_env le m
        (Scall None (Evar memory._osRecvMesg fty)
           [Eaddrof (Evar q tq) tq'; Eaddrof (Evar r tr) tr'; Econst_int n tn]) t le' m' out ->
      q = save_file._gSIEventMesgQueue -> r = memory._gMainReceivedMesg ->
      access_mode fty = By_reference ->
      le' = le /\ Mem.unchanged_on (fun b z => b <> bq /\ b <> brm) m m'.
  Proof.
    intros le m t le' m' out q tq tq' r tr tr' n tn fty H -> -> Hfty.
    destruct (LptBody.scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ H (PTree.gempty _ _) Hfty)
      as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hf & Hcl & Hel & Hev & -> & ->).
    destruct (LptBody.os_resolve lp H12 memory._osRecvMesg "osRecvMesg" _ _ ltac:(vm_compute; reflexivity)
                ltac:(vm_compute; reflexivity) Hs Hf) as (sg & targs & tres & cc' & ->).
    split; [ reflexivity | ].
    inv Hev.
    destruct Hfloor as (_ & _ & Hrecv & _).
    match goal with Hx : external_call _ _ _ _ _ _ _ |- _ =>
      destruct (Hrecv _ _ _ _ _ _ _ Hx) as (bq' & oq & cell & fl & Ev & _ & _ & UO) end.
    subst vargs.
    inv Hel. match goal with Hl : eval_exprlist _ _ _ _ _ _ (_ :: _) |- _ => inv Hl end.
    match goal with
    | H1 : eval_expr _ _ _ _ (Eaddrof (Evar save_file._gSIEventMesgQueue _) _) ?v1,
      C1 : sem_cast ?v1 _ _ _ = Some (Vptr bq' oq),
      H2 : eval_expr _ _ _ _ (Eaddrof (Evar memory._gMainReceivedMesg _) _) ?v2,
      C2 : sem_cast ?v2 _ _ _ = Some cell |- _ =>
        destruct (LptBody.addrof_glob_val lp _ _ _ _ _ _ H1) as (b1 & S1 & E1v);
        destruct (LptBody.addrof_glob_val lp _ _ _ _ _ _ H2) as (b2 & S2 & E2v);
        rewrite E1v in C1; rewrite E2v in C2;
        destruct (cast_ptr _ _ _ _ _ _ C1) as (o1 & E1); injection E1 as E1b _;
        assert (Eq1 : bq' = bq) by congruence;
        assert (Eq2 : b2 = brm) by congruence;
        rewrite Eq1 in UO;
        assert (Cc : forall b' z, b' <> brm -> cell_out cell b' z)
          by (intros b' z Nb; destruct cell; cbn; auto;
              destruct (cast_ptr _ _ _ _ _ _ C2) as (o2 & E2); injection E2 as E2b _;
              left; congruence)
    end.
    eapply Mem.unchanged_on_implies; [ exact (UO save_file._gSIEventMesgQueue [] eq_refl Hq) | ].
    intros b' z (N1 & N2) _. split; [ left; exact N1 | split; [ exact (Cc b' z N2) | ] ].
    intros s [].
  Qed.

  (* ---- adjust_analog_stick(controller): writes stickX/stickY/stickMag ---- *)
  Definition ctl_lv (p : ident) (f : ident) (ty : type) : expr :=
    Efield (Ederef (Etempvar p (tptr (Tstruct GI._Controller noattr))) (Tstruct GI._Controller noattr)) f ty.

  Definition adj_set (id : ident) (a : expr) : bool := negb (Pos.eqb id GI._controller).
  Definition adj_store (lv rhs : expr) : bool :=
    expr_eqb lv (ctl_lv GI._controller GI._stickX tfloat)
    || expr_eqb lv (ctl_lv GI._controller GI._stickY tfloat)
    || expr_eqb lv (ctl_lv GI._controller GI._stickMag tfloat).
  Definition adj_call (o : option ident) (a : expr) (al : list expr) : bool :=
    match o, a with
    | Some x, Evar fid (Tfunction _ _ _) => negb (Pos.eqb x GI._controller) && Pos.eqb fid GI._sqrtf
    | _, _ => false
    end.

  Lemma adj_chk : LptBody.cw_chk adj_set adj_store adj_call (fn_body GI.f_adjust_analog_stick) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma adj_ok : forall m b o t m' vres,
      eval_funcall function_entry2 G m (Internal GI.f_adjust_analog_stick) [Vptr b o] t m' vres ->
      Ptrofs.unsigned o + 16 <= Ptrofs.max_unsigned ->
      Mem.unchanged_on (fun b' z => Mem.valid_block m b'
                          /\ (b' <> b \/ z < Ptrofs.unsigned o + 4 \/ Ptrofs.unsigned o + 16 <= z)) m m'.
  Proof.
    intros m b o t m' vres Hev Ho.
    set (Q := fun b' z => Mem.valid_block m b'
                 /\ (b' <> b \/ z < Ptrofs.unsigned o + 4 \/ Ptrofs.unsigned o + 16 <= z)).
    inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      cbn [GI.f_adjust_analog_stick fn_vars] in Ha; inv Ha end.
    match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn [GI.f_adjust_analog_stick fn_params fn_temps bind_parameter_temps create_undef_temps] in Hb;
      injection Hb as <- end.
    lazymatch goal with Hal : Mem.alloc m 0 _ = (?m1, ?bf),
                    Hx : exec_stmt _ _ ?e ?le ?m1 _ _ _ ?m2 _,
                    Hfr : Mem.free_list ?m2 _ = Some m' |- _ =>
      set (env := e) in *;
      assert (U1 : Mem.unchanged_on Q m m1) by exact (Mem.alloc_unchanged_on _ _ _ _ _ _ Hal);
      assert (Nbf : ~ Mem.valid_block m bf)
        by (rewrite (Mem.alloc_result _ _ _ _ _ Hal); apply Plt_strict);
      assert (Ee : e ! GI._sqrtf = None) by reflexivity;
      assert (Gle : le ! GI._controller = Some (Vptr b o)) by reflexivity;
      assert (U2 : Mem.unchanged_on Q m m2);
      [ refine (proj1 (LptBody.cw_walk G e (fun mm => Mem.unchanged_on Q m mm)
                  (fun le0 => le0 ! GI._controller = Some (Vptr b o))
                  adj_set adj_store adj_call ?[Hs] ?[Hst] ?[Hc] e le m1 _ _ _ m2 _ Hx eq_refl adj_chk
                  Gle U1))
      | eapply Mem.unchanged_on_trans; [ exact U2 | ];
        apply (free_env_unch G e m2 m' Q Hfr);
        intros id bb ty Hid z (Hv & _);
        cbn in Hid; destruct (Pos.eq_dec id GI._filler) as [-> | Nid];
        [ rewrite PTree.gss in Hid; injection Hid as <- _; exact (Nbf Hv)
        | rewrite PTree.gso, PTree.gempty in Hid by exact Nid; discriminate Hid ] ]
    end.
    - (* sets *)
      intros id a le0 m0 v Hok Hg _ _. unfold adj_set in Hok.
      rewrite PTree.gso; [ exact Hg | ].
      intros E. subst id. rewrite Pos.eqb_refl in Hok. discriminate Hok.
    - (* stores *)
      intros lv rhs le0 m0 t0 le0' m0' out0 Hok Hg Hx Hf.
      unfold adj_store in Hok.
      assert (K : forall f d ty, gi_fo GI._Controller f = Some (d, Full) -> 4 <= d -> d + 4 <= 16 ->
                access_mode ty = By_value Mfloat32 -> type_is_volatile ty = false ->
                exec_stmt function_entry2 G env le0 m0 (Sassign (ctl_lv GI._controller f ty) rhs) t0 le0' m0' out0 ->
                Mem.unchanged_on Q m m0').
      { intros f d ty Hfo D1 D2 Ham Hvol Hs.
        destruct (fld_store G _ _ _ _ _ _ _ _ _ _ _ _ _ Mfloat32 d (fc f (d, Full) Hfo) Ham Hvol Hs)
          as (_ & _ & _ & loc & o0 & v & v' & Ha & _ & _ & St).
        apply ev_tmp in Ha. rewrite Hg in Ha. injection Ha as <- <-.
        eapply Mem.unchanged_on_trans; [ exact Hf | ].
        eapply Mem.store_unchanged_on; [ exact St | ].
        pose proof (Ptrofs.unsigned_range o) as Ro.
        rewrite (Ptrofs.add_unsigned o (Ptrofs.repr d)), (Ptrofs.unsigned_repr d) by (rewrite max_u; lia).
        rewrite Ptrofs.unsigned_repr by lia. cbn [size_chunk].
        intros i Hi (_ & [N | [N | N]]); [ exact (N eq_refl) | lia | lia ]. }
      repeat (apply orb_true_iff in Hok as [Hok | Hok]); apply expr_eqb_eq in Hok; subst lv.
      + exact (K _ 4 tfloat fo_c_sx ltac:(lia) ltac:(lia) eq_refl eq_refl Hx).
      + exact (K _ 8 tfloat fo_c_sy ltac:(lia) ltac:(lia) eq_refl eq_refl Hx).
      + exact (K _ 12 tfloat fo_c_sm ltac:(lia) ltac:(lia) eq_refl eq_refl Hx).
    - (* calls: sqrtf *)
      intros oo a al le0 m0 t0 le0' m0' out0 Hok Hg Hx Hf.
      destruct oo as [x0|]; [ | discriminate Hok ].
      destruct a; try discriminate Hok.
      match type of Hok with adj_call _ (Evar _ ?ty) _ = true => destruct ty; try discriminate Hok end.
      unfold adj_call in Hok.
      apply andb_prop in Hok as [Ht Hi]. apply negb_true_iff in Ht. apply Pos.eqb_eq in Hi. subst i.
      destruct (LptBody.scall_evar_inv_opt _ _ _ _ _ _ _ _ _ _ _ _ Hx Ee eq_refl)
        as (bs & fd & tyargs & tyres & cc & vargs & vres' & Hs & Hfd & _ & _ & Hev & -> & _).
      rewrite (MtxfBody.sqrtf_memid lp H12 Hsq bs fd m0 vargs t0 m0' vres' Hs Hfd Hev).
      split; [ exact Hf | ]. cbn [set_opttemp].
      rewrite PTree.gso; [ exact Hg | ]. intros E. subst x0. rewrite Pos.eqb_refl in Ht. discriminate Ht.
  Qed.

  (* ---- statement-shape tools ---- *)
  Fixpoint simple (s : statement) : bool :=
    match s with
    | Sskip | Sset _ _ | Sassign _ _ | Scall None _ _ => true
    | Ssequence a b => simple a && simple b
    | Sifthenelse _ a b => simple a && simple b
    | _ => false
    end.

  Lemma simple_normal : forall e s le m t le' m' o,
      simple s = true -> exec_stmt function_entry2 G e le m s t le' m' o -> o = Out_normal.
  Proof.
    intros e s. induction s; intros le m t le' m' oo Hs H; cbn in Hs; try discriminate Hs.
    - inv H; reflexivity.
    - inv H; reflexivity.
    - inv H; reflexivity.
    - destruct o; [ discriminate Hs | inv H; reflexivity ].
    - apply andb_prop in Hs as [H1 H2]. inv H; [ eapply IHs2; eassumption | ].
      match goal with Hx : exec_stmt _ _ _ _ _ s1 _ _ _ ?o', Hn : ?o' <> Out_normal |- _ =>
        exfalso; exact (Hn (IHs1 _ _ _ _ _ _ H1 Hx)) end.
    - apply andb_prop in Hs as [H1 H2]. inv H.
      match goal with Hx : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
        destruct b; [ eapply IHs1 | eapply IHs2 ]; eassumption end.
  Qed.
  Lemma simple_normal' : forall e s le m t le' m' o,
      exec_stmt function_entry2 G e le m s t le' m' o -> simple s = true -> o = Out_normal.
  Proof. intros; eapply simple_normal; eassumption. Qed.


  Lemma seq_inv : forall e le m s1 s2 t le' m' out,
      simple s1 = true ->
      exec_stmt function_entry2 G e le m (Ssequence s1 s2) t le' m' out ->
      exists t1 le1 m1 t2, exec_stmt function_entry2 G e le m s1 t1 le1 m1 Out_normal
        /\ exec_stmt function_entry2 G e le1 m1 s2 t2 le' m' out.
  Proof.
    intros e le m s1 s2 t le' m' out Hs H. inv H.
    - do 4 eexists. split; eassumption.
    - match goal with Hx : exec_stmt _ _ _ _ _ s1 _ _ _ ?o, Hn : ?o <> Out_normal |- _ =>
        exfalso; exact (Hn (simple_normal _ _ _ _ _ _ _ _ Hs Hx)) end.
  Qed.

  Ltac inv_ev :=
    repeat match goal with
    | H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv H
    | H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H
    | H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv H
    | H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ => inv H
    | H : eval_expr _ _ _ _ (Esizeof _ _) _ |- _ => inv H
    | H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H
    | H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H
    | H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H
    | H : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv H
    | H : eval_lvalue _ _ _ _ (Esizeof _ _) _ _ _ |- _ => inv H
    end.
  Ltac tgetH H := repeat (rewrite PTree.gss in H || (rewrite PTree.gso in H by (cbv; congruence))).
  Ltac tget := repeat (rewrite PTree.gss || (rewrite PTree.gso by (cbv; congruence))).
  Ltac rtemp :=
    repeat match goal with
    | H : ?l ! ?x = Some ?v, E : ?l ! ?x = Some ?w |- _ =>
        rewrite E in H; injection H as H; subst v
    end.

  (* ---- value tools ---- *)
  Lemma bool_of_bool : forall x m, bool_val (Val.of_bool x) tint m = Some x.
  Proof. intros [|] m; reflexivity. Qed.

  Lemma lt_uc : forall ce k v6 v mm,
      sem_binary_operation ce Olt (Vint k) tint v6 tuchar mm = Some v ->
      exists x, v6 = Vint x /\ v = Val.of_bool (Int.lt k x).
  Proof.
    intros ce k v6 v mm H. destruct v6; vcbn H; try discriminate H.
    injection H as <-. exists i. split; reflexivity.
  Qed.

  Lemma eq_uc : forall ce v1 v mm,
      sem_binary_operation ce Oeq v1 tuchar (Vint (Int.repr 0)) tint mm = Some v ->
      exists x, v1 = Vint x /\ v = Val.of_bool (Int.eq x (Int.repr 0)).
  Proof.
    intros ce v1 v mm H. destruct v1; vcbn H; try discriminate H.
    injection H as <-. exists i. split; reflexivity.
  Qed.

  Lemma and_uc : forall ce v c va mm,
      sem_binary_operation ce Oand v tuchar (Vint c) tint mm = Some va ->
      exists r, v = Vint r /\ va = Vint (Int.and r c).
  Proof.
    intros ce v c va mm H. destruct v; vcbn H; try discriminate H.
    injection H as <-. exists i. split; reflexivity.
  Qed.

  Lemma shr_ii : forall ce a vs mm,
      sem_binary_operation ce Oshr (Vint a) tint (Vint (Int.repr 4)) tint mm = Some vs ->
      vs = Vint (Int.shr a (Int.repr 4)).
  Proof. intros ce a vs mm H. vcbn H. injection H as <-. reflexivity. Qed.

  Lemma cast_i_uc : forall w v mm, sem_cast (Vint w) tint tuchar mm = Some v -> v = Vint (Int.zero_ext 8 w).
  Proof. intros w v mm H. vcbn H. injection H as <-. reflexivity. Qed.

  Lemma cast_us_us : forall v v' mm, sem_cast v tushort tushort mm = Some v' ->
      exists n, v = Vint n /\ v' = Vint (Int.zero_ext 16 n).
  Proof.
    intros v v' mm H. destruct v; vcbn H; try discriminate H.
    injection H as <-. exists i. split; reflexivity.
  Qed.

  Lemma cast_struct_same : forall b o sid a mm v,
      sem_cast (Vptr b o) (Tstruct sid a) (Tstruct sid a) mm = Some v -> v = Vptr b o.
  Proof.
    intros b o sid a mm v H. vcbn H. destruct (ident_eq sid sid); [ | congruence ].
    injection H as <-. reflexivity.
  Qed.

  Lemma cast_pp : forall b o t1 t2 mm v,
      sem_cast (Vptr b o) (tptr t1) (tptr t2) mm = Some v -> v = Vptr b o.
  Proof. intros b o t1 t2 mm v H. vcbn H. injection H as <-. reflexivity. Qed.

  (* a variable of aggregate type evaluates to its address *)
  Lemma ev_var_ptr : forall e le m x ty loc o,
      (access_mode ty = By_reference \/ access_mode ty = By_copy) ->
      eval_expr G e le m (Evar x ty) (Vptr loc o) ->
      o = Ptrofs.zero /\ (e ! x = Some (loc, ty) \/ (e ! x = None /\ Genv.find_symbol G x = Some loc)).
  Proof.
    intros e le m x ty loc o Ham H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _, Hd : deref_loc _ _ _ _ _ _ |- _ =>
      apply RealFrameValue.deref_loc_aggregate_eq in Hd as [-> ->]; [ inv Hl | exact Ham ] end.
    - split; [ reflexivity | left; assumption ].
    - split; [ reflexivity | right; split; assumption ].
  Qed.

  (* a by-value field of a local struct *)
  Lemma fld_load_loc : forall e le m x sid att f ty v ch delta bx,
      e ! x = Some (bx, Tstruct sid att) ->
      (forall co, (genv_cenv G) ! sid = Some co ->
         field_offset (genv_cenv G) f (co_members co) = Errors.OK (delta, Full)) ->
      access_mode ty = By_value ch -> type_is_volatile ty = false ->
      eval_expr G e le m (Efield (Evar x (Tstruct sid att)) f ty) v ->
      Mem.load ch m bx (Ptrofs.unsigned (Ptrofs.repr delta)) = Some v.
  Proof.
    intros e le m x sid att f ty v ch delta bx Hx Hfo Ham Hvol H.
    apply RealFrameValue.eval_expr_Efield_load in H as (loc & ofs & bf & Hl & Hd).
    apply RealFrameValue.eval_lvalue_Efield_inv in Hl as (o0 & id & att' & co & delta' & Ha & Hco & -> & Hcase).
    cbn [typeof] in Hcase. destruct Hcase as [(Ht & Hf) | (Ht & _)]; [ | discriminate Ht ].
    injection Ht as <- <-.
    rewrite (Hfo co Hco) in Hf. injection Hf as <- <-.
    destruct (ev_var_ptr _ _ _ _ (Tstruct sid att) _ _ (or_intror eq_refl) Ha) as (-> & [E | (E & _)]);
      rewrite Hx in E; [ injection E as -> | discriminate E ].
    rewrite Ptrofs.add_zero_l in Hd.
    inv Hd; try congruence.
    match goal with Ha' : access_mode _ = By_value ?c, Hl : Mem.loadv ?c _ _ = Some _ |- _ =>
      rewrite Ham in Ha'; injection Ha' as <-; exact Hl end.
  Qed.

  Lemma fld_load_loc' : forall e le m x sid att f ty v ch delta bx,
      e ! x = Some (bx, Tstruct sid att) ->
      (forall co, (genv_cenv G) ! sid = Some co ->
         field_offset (genv_cenv G) f (co_members co) = Errors.OK (delta, Full)) ->
      eval_expr G e le m (Efield (Evar x (Tstruct sid att)) f ty) v ->
      access_mode ty = By_value ch -> type_is_volatile ty = false ->
      Mem.load ch m bx (Ptrofs.unsigned (Ptrofs.repr delta)) = Some v.
  Proof. intros e le m x sid att f ty v ch delta bx Hx Hfo H Ham Hvol. exact (fld_load_loc _ _ _ _ _ _ _ _ _ _ _ _ Hx Hfo Ham Hvol H). Qed.


  (* an array field of a global struct evaluates to its address *)
  Lemma ev_glob_arr : forall e le m g sid att f t n v delta bg,
      e ! g = None -> Genv.find_symbol G g = Some bg ->
      (forall co, (genv_cenv G) ! sid = Some co ->
         field_offset (genv_cenv G) f (co_members co) = Errors.OK (delta, Full)) ->
      eval_expr G e le m (Efield (Evar g (Tstruct sid att)) f (Tarray t n noattr)) v ->
      v = Vptr bg (Ptrofs.repr delta).
  Proof.
    intros e le m g sid att f t n v delta bg Hg Hs Hfo H.
    apply RealFrameValue.eval_expr_Efield_load in H as (loc & ofs & bf & Hl & Hd).
    apply RealFrameValue.eval_lvalue_Efield_inv in Hl as (o0 & id & att' & co & delta' & Ha & Hco & -> & Hcase).
    cbn [typeof] in Hcase. destruct Hcase as [(Ht & Hf) | (Ht & _)]; [ | discriminate Ht ].
    injection Ht as <- <-.
    rewrite (Hfo co Hco) in Hf. injection Hf as <- <-.
    destruct (ev_var_ptr _ _ _ _ (Tstruct sid att) _ _ (or_intror eq_refl) Ha) as (-> & [E | (_ & E)]);
      [ rewrite Hg in E; discriminate E | rewrite Hs in E; injection E as -> ].
    rewrite Ptrofs.add_zero_l in Hd.
    inv Hd; try reflexivity.
    match goal with Hm : access_mode _ = By_value _ |- _ => discriminate Hm end.
  Qed.

  Lemma u_ofs : forall a d, 0 <= a -> 0 <= d -> a + d <= 1000 ->
      Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr a) (Ptrofs.repr d)) = a + d.
  Proof. intros a d Ha Hd H. apply ofs_small; [ exact Ha | exact Hd | rewrite max_u; lia ]. Qed.

  Lemma u_rep : forall a, 0 <= a <= 1000 -> Ptrofs.unsigned (Ptrofs.repr a) = a.
  Proof. intros a H. apply Ptrofs.unsigned_repr. rewrite max_u. lia. Qed.

  Lemma u8_range : forall m b z r, Mem.load Mint8unsigned m b z = Some (Vint r) -> Int.unsigned r < 256.
  Proof.
    intros m b z r H. apply Mem.load_cast in H. vcbn H. injection H as E.
    rewrite E. pose proof (Int.zero_ext_range 8 r ltac:(split; [ lia | reflexivity ])) as R. change (two_p 8) with 256 in R. lia.
  Qed.

  (* ---- osContGetReadData(&gControllerPads[0]) ---- *)
  Definition grd_loop : statement :=
    match fn_body CR.f_osContGetReadData with Ssequence _ (Ssequence _ l) => l | _ => Sskip end.
  Definition grd_s1 : statement := match grd_loop with Sloop a _ => a | _ => Sskip end.
  Definition grd_s2 : statement := match grd_loop with Sloop _ b => b | _ => Sskip end.
  Definition grd_h1 : statement :=
    match fn_body CR.f_osContGetReadData with Ssequence a _ => a | _ => Sskip end.
  Definition grd_h2 : statement :=
    match fn_body CR.f_osContGetReadData with Ssequence _ (Ssequence a _) => a | _ => Sskip end.
  Lemma grd_shape : fn_body CR.f_osContGetReadData
                    = Ssequence grd_h1 (Ssequence grd_h2 (Sloop grd_s1 grd_s2)).
  Proof. reflexivity. Qed.

  Lemma E_mx : CR.___osMaxControllers = CI.___osMaxControllers. Proof. reflexivity. Qed.
  Lemma E_pif : CR.___osContPifRam = CI.___osContPifRam. Proof. reflexivity. Qed.

  Lemma pads_store : forall mm mm' ch z v, Mem.store ch mm bpads z v = Some mm' ->
      (forall k, 0 <= k < 4 -> z + size_chunk ch <= 6 * k \/ 6 * k + 2 <= z) ->
      pads_ac mm -> pads_ac mm'.
  Proof.
    intros mm mm' ch z v Hs D P k n Hk Hl. apply (P k n Hk). rewrite <- Hl. symmetry.
    apply (Mem.load_store_other _ _ _ _ _ _ Hs). right. cbn [size_chunk].
    destruct (D k Hk); [ right | left ]; lia.
  Qed.

  Lemma pads_store_btn : forall mm mm' k0 n, 0 <= k0 < 4 ->
      Mem.store Mint16unsigned mm bpads (6 * k0) (Vint (Int.zero_ext 16 n)) = Some mm' ->
      Aclr n -> pads_ac mm -> pads_ac mm'.
  Proof.
    intros mm mm' k0 n Hk0 Hs A P k n' Hk Hl. destruct (Z.eq_dec k k0) as [-> | Nk].
    - rewrite (Mem.load_store_same _ _ _ _ _ _ Hs) in Hl. cbn [Val.load_result] in Hl.
      injection Hl as <-. unfold Aclr. rewrite !and_A_zext16. exact A.
    - apply (P k n' Hk). rewrite <- Hl. symmetry.
      apply (Mem.load_store_other _ _ _ _ _ _ Hs). right. cbn [size_chunk]. lia.
  Qed.

  (* injection reduces the arithmetic in offsets (8 * k becomes a match on k):
     these congruence-based forms keep the terms as written *)
  Ltac injp H :=
    lazymatch type of H with
    | Vptr ?b1 ?o1 = Vptr ?b2 ?o2 =>
        let E1 := fresh "Eb" in let E2 := fresh "Eo" in
        assert (E1 : b1 = b2) by congruence; assert (E2 : o1 = o2) by congruence; clear H;
        first [ subst b1 | subst b2 ]; first [ subst o1 | subst o2 ]
    end.
  Ltac injv H :=
    lazymatch type of H with
    | Some (Vptr ?b1 ?o1) = Some (Vptr ?b2 ?o2) =>
        let E := fresh "Ev" in assert (E : Vptr b1 o1 = Vptr b2 o2) by congruence; clear H; injp E
    end.
  Ltac injs H :=
    lazymatch type of H with
    | Some ?a = Some ?b =>
        let E := fresh "Es" in assert (E : a = b) by congruence; clear H;
        first [ subst b | subst a | injp E ]
    end.
  Ltac rtemp' :=
    repeat match goal with
    | H : ?l ! ?x = Some ?v, E : ?l ! ?x = Some ?w |- _ =>
        is_var v; tryif constr_eq v w then fail else
        (let Hq := fresh "Hq" in assert (Hq : v = w) by congruence; clear H; subst v)
    end.

  Section GRD.
    Variables (m : mem) (br : block).
    Hypothesis Nbr : ~ Mem.valid_block m br.
    Hypothesis Vpads : Mem.valid_block m bpads.
    Hypothesis Vpif : Mem.valid_block m bpif.
    Hypothesis Vmx : Mem.valid_block m bmx.
    Hypothesis Hport : forall k, 0 <= k < 4 -> port_a m bpif k = false.
    Hypothesis Hmax : forall x, Mem.load Mint8unsigned m bmx 0 = Some (Vint x) -> Int.unsigned x <= 4.
    Hypothesis Hpac : pads_ac m.
    Definition grd_e : env := PTree.set CR._response (br, Tstruct CR.__869 noattr) empty_env.

    Definition UO (mm : mem) : Prop := Mem.unchanged_on (fun b z => Mem.valid_block m b /\ b <> bpads) m mm.

    Lemma U_load : forall mm ch b z v, UO mm -> Mem.valid_block m b -> b <> bpads ->
        Mem.load ch mm b z = Some v -> Mem.load ch m b z = Some v.
    Proof.
      intros mm ch b z v U Vb Nb H. rewrite <- H. symmetry.
      eapply Mem.load_unchanged_on_1; [ exact U | exact Vb | intros i _; split; assumption ].
    Qed.

    Lemma U_store_pads : forall mm mm' ch z v, UO mm -> Mem.store ch mm bpads z v = Some mm' -> UO mm'.
    Proof.
      intros mm mm' ch z v U Hs. eapply Mem.unchanged_on_trans; [ exact U | ].
      eapply Mem.store_unchanged_on; [ exact Hs | intros i _ (_ & N); exact (N eq_refl) ].
    Qed.

    Lemma pad_side : forall mm mm' ch k d v, 0 <= k < 4 -> 2 <= d <= 4 -> size_chunk ch = 1 ->
        Mem.store ch mm bpads (6 * k + d) v = Some mm' -> UO mm -> pads_ac mm -> UO mm' /\ pads_ac mm'.
    Proof.
      intros mm mm' ch k d v Hk Hd Hc Hs U P. split; [ exact (U_store_pads _ _ _ _ _ U Hs) | ].
      apply (pads_store _ _ _ _ _ Hs); [ | exact P ]. intros k' Hk'. rewrite Hc.
      destruct (Z_lt_le_dec k' (k + 1)); [ right | left ]; lia.
    Qed.

    Definition grd_inv (k : Z) (le : temp_env) (mm : mem) : Prop :=
      0 <= k <= 4
      /\ le ! CR._i = Some (Vint (Int.repr k))
      /\ le ! CR._cmdBufPtr = Some (Vptr bpif (Ptrofs.repr (8 * k)))
      /\ le ! CR._pad = Some (Vptr bpads (Ptrofs.repr (6 * k)))
      /\ UO mm /\ pads_ac mm.

    Lemma Ee_mx : grd_e ! CR.___osMaxControllers = None. Proof. vm_compute. reflexivity. Qed.
    Lemma Ee_resp : grd_e ! CR._response = Some (br, Tstruct CR.__869 noattr).
    Proof. unfold grd_e. apply PTree.gss. Qed.
    Lemma Ee_pif : grd_e ! CR.___osContPifRam = None. Proof. vm_compute. reflexivity. Qed.

    Lemma br_pads : br <> bpads. Proof. intros ->. exact (Nbr Vpads). Qed.
    Lemma br_pif : br <> bpif. Proof. intros ->. exact (Nbr Vpif). Qed.
    Lemma pads_pif : bpads <> bpif. Proof. ne Hpads Hpif. Qed.

    Lemma sz869 : sizeof (genv_cenv G) (Tstruct CR.__869 noattr) = 8.
    Proof. exact (sizeof_lp lp CR.prog LO_cr _ _ _ (proj1 sizes) ltac:(discriminate)). Qed.
    Lemma sz319 : sizeof (genv_cenv G) (Tstruct CR.__319 noattr) = 6.
    Proof. exact (sizeof_lp lp CR.prog LO_cr _ _ _ (proj1 (proj2 sizes)) ltac:(discriminate)). Qed.

    (* the body of one iteration, after the bound check passed *)
    Lemma grd_body : forall k le mm t le1 m1 out1 s,
        0 <= k < 4 -> grd_inv k le mm ->
        s = match grd_s1 with Ssequence _ b => b | _ => Sskip end ->
        exec_stmt function_entry2 G grd_e le mm s t le1 m1 out1 ->
        grd_inv k le1 m1 /\ out1 = Out_normal.
    Proof.
      intros k le mm t le1 m1 out1 s Hk I -> H.
      destruct I as (Rk & Ei & Ec & Ep & U & P).
      cbn [grd_s1 grd_loop CR.f_osContGetReadData fn_body] in H.
      split; [ | exact (simple_normal' _ _ _ _ _ _ _ _ H eq_refl) ].
      apply seq_inv in H as (t1 & le2 & m2 & t2 & Hcp & H); [ | reflexivity ].
      (* response = *(struct __869 * )cmdBufPtr : the 8-byte copy *)
      inv Hcp.
      match goal with Hl : eval_lvalue _ _ _ _ (Evar CR._response _) _ _ _ |- _ =>
        inv Hl; [ | match goal with He : grd_e ! CR._response = None |- _ =>
                      rewrite Ee_resp in He; discriminate He end ] end.
      match goal with Hg : grd_e ! CR._response = Some _ |- _ => rewrite Ee_resp in Hg; injection Hg as <- end.
      match goal with Hr : eval_expr _ _ _ _ (Ederef _ _) _ |- _ =>
        inv Hr; match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _,
                                Hd : deref_loc _ _ _ _ _ _ |- _ =>
                  inv Hl; inv Hd; try match goal with Hm : access_mode _ = _ |- _ => discriminate Hm | Hv : type_is_volatile _ = true |- _ => discriminate Hv end end end.
      inv_ev. rtemp'.
      cbn [typeof] in *.
      match goal with Hc : sem_cast (Vptr _ _) (tptr _) (tptr _) _ = Some _ |- _ =>
        apply cast_pp in Hc; injp Hc end.
      match goal with Hc : sem_cast (Vptr _ _) (Tstruct _ _) (Tstruct _ _) _ = Some _ |- _ =>
        apply cast_struct_same in Hc; subst end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha; try match goal with Hm : access_mode _ = _ |- _ => discriminate Hm | Hv : type_is_volatile _ = true |- _ => discriminate Hv end end.
      match goal with Hlb : Mem.loadbytes _ _ _ _ = Some _, Hsb : Mem.storebytes _ _ _ _ = Some _ |- _ =>
        cbn [typeof] in Hlb, Hsb; rewrite sz869 in Hlb; rename Hlb into LB; rename Hsb into SB end.
      change (Mem.loadbytes mm bpif (Ptrofs.unsigned (Ptrofs.repr (8 * k))) 8 = Some bytes) in LB.
      rewrite u_rep in LB by lia. change (Ptrofs.unsigned Ptrofs.zero) with 0 in SB.
      assert (U2 : UO m2).
      { eapply Mem.unchanged_on_trans; [ exact U | ].
        eapply Mem.storebytes_unchanged_on; [ exact SB | intros i _ (Vb & _); exact (Nbr Vb) ]. }
      assert (P2 : pads_ac m2).
      { intros k' n Hk' Hl. apply (P k' n Hk'). rewrite <- Hl. symmetry.
        eapply Mem.load_storebytes_other; [ exact SB | left; exact (not_eq_sym br_pads) ]. }
      (* reads of the copy are reads of the PIF image *)
      assert (RD : forall ch d v, 0 <= d -> d + size_chunk ch <= 8 -> (align_chunk ch | 8 * k + d) ->
                 Mem.load ch m2 br d = Some v -> Mem.load ch m bpif (8 * k + d) = Some v).
      { intros ch d v D1 D2 Da Hl.
        apply (U_load mm _ _ _ _ U Vpif (not_eq_sym pads_pif)).
        exact (copy_load _ _ _ _ _ _ _ _ _ LB SB D1 D2 Da Hl). }
      (* errnum = (response.rxLen & 0xC0) >> 4 *)
      apply seq_inv in H as (t3 & le3 & m3 & t4 & Herr & H); [ | reflexivity ].
      apply seq_inv in Herr as (t5 & le4 & m4 & t6 & Hs5 & Herr); [ | reflexivity ].
      inv Hs5.
      lazymatch goal with Hv : eval_expr _ _ _ _ (Efield (Evar CR._response _) CR._rxLen _) ?v5 |- _ =>
        pose proof (fld_load_loc' _ _ _ _ _ _ _ _ _ Mint8unsigned 2 _ Ee_resp
                      (fr _ _ fo_r_rx) Hv eq_refl eq_refl) as L5 end.
      change (Ptrofs.unsigned (Ptrofs.repr 2)) with 2 in L5.
      apply (RD Mint8unsigned 2 _ ltac:(lia) ltac:(cbn; lia) ltac:(apply Z.divide_1_l)) in L5.
      destruct (fld_store' G _ _ _ _ _ _ _ _ _ _ _ _ _ Mint8unsigned 4 (fq _ _ fo_q_err) Herr eq_refl eq_refl)
        as (-> & _ & _ & loc & o0 & vx & v' & Ha & Hrhs & Hc & St).
      apply ev_tmp in Ha. tgetH Ha. rewrite Ep in Ha. injv Ha.
      inv_ev.
      repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ => tgetH Hx end.
      match goal with Hx : Some ?a = Some ?b |- _ =>
        is_var b; let Hab := fresh "Hab" in assert (Hab : b = a) by congruence; clear Hx; subst b end.
      match goal with Hb : sem_binary_operation _ Oand _ _ _ _ _ = Some _ |- _ =>
        destruct (and_uc _ _ _ _ _ Hb) as (r & -> & ->) end.
      match goal with Hb : sem_binary_operation _ Oshr _ _ _ _ _ = Some _ |- _ => apply shr_ii in Hb; subst end.
      cbn [typeof] in Hc. apply cast_i_uc in Hc. subst v'.
      rewrite u_ofs in St by lia.
      destruct (pad_side _ _ Mint8unsigned k 4 _ Hk ltac:(lia) eq_refl St U2 P2) as (U3 & P3).
      (* t'1 = pad->errnum; if (t'1 == 0) ... *)
      apply seq_inv in H as (t7 & le5 & m5 & t8 & Hs1 & Hif); [ | reflexivity ].
      inv Hs1.
      lazymatch goal with Hv : eval_expr _ _ _ _ (Efield (Ederef _ _) CR._errnum _) ?v1 |- _ =>
        destruct (fld_load' G _ _ _ _ _ _ _ _ _ Mint8unsigned 4 (fq _ _ fo_q_err) Hv eq_refl eq_refl)
          as (loc1 & o1 & Ha1 & L1) end.
      apply ev_tmp in Ha1. tgetH Ha1. rewrite Ep in Ha1. injv Ha1.
      rewrite u_ofs in L1 by lia. rewrite (Mem.load_store_same _ _ _ _ _ _ St) in L1.
      cbn [Val.load_result] in L1. injection L1 as <-.
      inv Hif. inv_ev.
      repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ => tgetH Hx end.
      rtemp'.
      repeat match goal with Hx : Some ?a = Some ?b |- _ =>
        is_var b; let Hab := fresh "Hab" in assert (Hab : b = a) by congruence; clear Hx; subst b end.
      match goal with Hb : sem_binary_operation _ Oeq _ _ _ _ _ = Some _ |- _ =>
        destruct (eq_uc _ _ _ _ Hb) as (x & Ex & ->) end.
      injection Ex as <-.
      match goal with Hb : bool_val _ _ _ = Some ?bb |- _ =>
        cbn [typeof] in Hb; rewrite bool_of_bool in Hb; injection Hb as <- end.
      assert (R8 : Int.unsigned r < 256) by exact (u8_range _ _ _ _ L5).
      match goal with Hx : exec_stmt _ _ _ _ _ (if ?c then _ else _) _ _ _ _ |- _ => revert Hx; destruct c eqn:Z0; intro Hx end.
      - (* errnum == 0: copy button and stick *)
        pose proof (errnum_zero r R8 Z0) as Zr.
        lazymatch goal with Hx : exec_stmt _ _ _ (PTree.set CR._t'1 _ _) _ _ _ _ _ _ |- _ =>
          cbv beta iota in Hx; rename Hx into H end.
        apply seq_inv in H as (t9 & le6 & m6 & t10 & Hb & H); [ | reflexivity ].
        apply seq_inv in Hb as (t11 & le7 & m7 & t12 & Hs4 & Hb); [ | reflexivity ].
        inv Hs4.
        lazymatch goal with Hv : eval_expr _ _ _ _ (Efield (Evar CR._response _) CR._button _) ?v4 |- _ =>
          pose proof (fld_load_loc' _ _ _ _ _ _ _ _ _ Mint16unsigned 4 _ Ee_resp
                        (fr _ _ fo_r_btn) Hv eq_refl eq_refl) as L4 end.
        change (Ptrofs.unsigned (Ptrofs.repr 4)) with 4 in L4.
        rewrite (Mem.load_store_other _ _ _ _ _ _ St) in L4 by (left; exact br_pads).
        apply (RD Mint16unsigned 4 _ ltac:(lia) ltac:(cbn; lia)
                 ltac:(cbn [align_chunk]; exists (4 * k + 2); lia)) in L4.
        destruct (fld_store' G _ _ _ _ _ _ _ _ _ _ _ _ _ Mint16unsigned 0 (fq _ _ fo_q_btn) Hb eq_refl eq_refl)
          as (-> & _ & _ & loc2 & o2 & w & w' & Ha2 & Hrhs2 & Hc2 & St2).
        apply ev_tmp in Ha2. tgetH Ha2. rewrite Ep in Ha2. injv Ha2.
        apply ev_tmp in Hrhs2. tgetH Hrhs2. injection Hrhs2 as ->.
        cbn [typeof] in Hc2. destruct (cast_us_us _ _ _ Hc2) as (n & -> & ->).
        rewrite u_ofs in St2 by lia. rewrite Z.add_0_r in St2.
        assert (An : Aclr n).
        { pose proof (Hport k Hk) as Pk. unfold port_a in Pk.
          rewrite L4, L5 in Pk. cbv beta iota in Pk. rewrite Zr, andb_true_r in Pk.
          apply negb_false_iff in Pk. unfold Aclr. exact (Int.same_if_eq _ _ Pk). }
        pose proof (pads_store_btn _ _ _ _ Hk St2 An P3) as P4.
        pose proof (U_store_pads _ _ _ _ _ U3 St2) as U4.
        (* stick_x, stick_y: the pad's other bytes *)
        apply seq_inv in H as (t13 & le8 & m8 & t14 & Hx1 & Hx2); [ | reflexivity ].
        apply seq_inv in Hx1 as (t15 & le9 & m9 & t16 & Hs3 & Hsx); [ | reflexivity ].
        apply seq_inv in Hx2 as (t17 & le10 & m10 & t18 & Hs2 & Hsy); [ | reflexivity ].
        inv Hs3. inv Hs2.
        destruct (fld_store' G _ _ _ _ _ _ _ _ _ _ _ _ _ Mint8signed 2 (fq _ _ fo_q_sx) Hsx eq_refl eq_refl)
          as (-> & _ & _ & loc3 & o3 & y & y' & Ha3 & _ & _ & St3).
        apply ev_tmp in Ha3. tgetH Ha3. rewrite Ep in Ha3. injv Ha3.
        rewrite u_ofs in St3 by lia.
        destruct (pad_side _ _ Mint8signed k 2 _ Hk ltac:(lia) eq_refl St3 U4 P4) as (U5 & P5).
        destruct (fld_store' G _ _ _ _ _ _ _ _ _ _ _ _ _ Mint8signed 3 (fq _ _ fo_q_sy) Hsy eq_refl eq_refl)
          as (-> & _ & _ & loc4 & o4 & y2 & y2' & Ha4 & _ & _ & St4).
        apply ev_tmp in Ha4. tgetH Ha4. rewrite Ep in Ha4. injv Ha4.
        rewrite u_ofs in St4 by lia.
        destruct (pad_side _ _ Mint8signed k 3 _ Hk ltac:(lia) eq_refl St4 U5 P5) as (U6 & P6).
        split; [ exact Rk | ].
        split; [ tget; exact Ei | ].
        split; [ tget; exact Ec | ].
        split; [ tget; exact Ep | ].
        split; [ exact U6 | exact P6 ].
      - lazymatch goal with Hx : exec_stmt _ _ _ (PTree.set CR._t'1 _ _) _ _ _ _ _ _ |- _ =>
          cbv beta iota in Hx; inv Hx end.
        split; [ exact Rk | ].
        split; [ tget; exact Ei | ].
        split; [ tget; exact Ec | ].
        split; [ tget; exact Ep | ].
        split; [ exact U3 | exact P3 ].
    Qed.

    Definition grd_s1h : statement := match grd_s1 with Ssequence a _ => a | _ => Sskip end.
    Definition grd_s1b : statement := match grd_s1 with Ssequence _ b => b | _ => Sskip end.

    (* the bound check: i < __osMaxControllers (<= 4) *)
    Lemma grd_s1_ok : forall k le mm t le1 m1 out1,
        grd_inv k le mm ->
        exec_stmt function_entry2 G grd_e le mm grd_s1 t le1 m1 out1 ->
        grd_inv k le1 m1 /\ (out1 = Out_break \/ (out1 = Out_normal /\ k < 4)).
    Proof.
      intros k le mm t le1 m1 out1 I H.
      assert (HEAD : forall t' le' mm' o',
                 exec_stmt function_entry2 G grd_e le mm
                   (match grd_s1 with Ssequence a _ => a | _ => Sskip end) t' le' mm' o' ->
                 mm' = mm /\ grd_inv k le' mm /\ ((o' = Out_normal /\ k < 4) \/ o' = Out_break)).
      { intros t' le' mm' o' Hh.
        destruct I as (Rk & Ei & Ec & Ep & U & P).
        cbn [grd_s1 grd_loop CR.f_osContGetReadData fn_body] in Hh.
        apply seq_inv in Hh as (ta & lea & ma & tb & Hs6 & Hif); [ | reflexivity ].
        inv Hs6.
        match goal with Hv : eval_expr _ _ _ _ (Evar CR.___osMaxControllers _) _ |- _ =>
          destruct (ev_gvar' G _ _ _ _ _ _ Mint8unsigned Ee_mx Hv eq_refl eq_refl) as (bx & Sx & L6) end.
        rewrite E_mx, Hmx in Sx. injection Sx as <-.
        inv Hif. inv_ev.
        repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ => tgetH Hx end.
        rtemp.
        match goal with Hx : Some ?a = Some ?b |- _ => injection Hx as Hx; subst b end.
        match goal with Hb : sem_binary_operation _ Olt _ _ _ _ _ = Some _ |- _ =>
          destruct (lt_uc _ _ _ _ _ Hb) as (x & -> & ->) end.
        match goal with Hb : bool_val _ _ _ = Some ?bb |- _ =>
          cbn [typeof] in Hb; rewrite bool_of_bool in Hb; injection Hb as <- end.
        assert (Ix : Int.unsigned x <= 4).
        { apply Hmax. apply (U_load _ _ _ _ _ U Vmx); [ ne Hmx Hpads | exact L6 ]. }
        match goal with U' : UO ?M, Ei' : ?L ! CR._i = Some _ |- _ =>
          assert (G6 : forall v, grd_inv k (PTree.set CR._t'6 v L) M) end.
        { intros v. split; [ exact Rk | ].
          split; [ tget; exact Ei | ]. split; [ tget; exact Ec | ]. split; [ tget; exact Ep | ].
          split; [ exact U | exact P ]. }
        match goal with Hx : exec_stmt _ _ _ _ _ (if ?c then _ else _) _ _ _ _ |- _ =>
          revert Hx; destruct c eqn:Lt; intro Hx; inv Hx end.
        - split; [ reflexivity | split; [ apply G6 | left; split; [ reflexivity | ] ] ].
          unfold Int.lt in Lt.
          rewrite Int.signed_repr in Lt by (cbn; lia).
          rewrite Int.signed_eq_unsigned in Lt by (cbn; lia).
          destruct (zlt k (Int.unsigned x)); [ lia | discriminate Lt ].
        - split; [ reflexivity | split; [ apply G6 | right; reflexivity ] ]. }
      assert (Es : grd_s1 = Ssequence grd_s1h
                                      grd_s1b)
        by reflexivity.
      rewrite Es in H. inv H.
      - match goal with Hh : exec_stmt _ _ _ _ _ grd_s1h _ _ _ _ |- _ =>
          destruct (HEAD _ _ _ _ Hh) as (-> & I1 & [(_ & Hk) | E]); [ | discriminate E ] end.
        match goal with Hb : exec_stmt _ _ _ _ _ grd_s1b _ _ _ _ |- _ =>
          destruct (grd_body k _ _ _ _ _ _ _ ltac:(destruct I; lia) I1 eq_refl Hb) as (I2 & ->) end.
        split; [ exact I2 | right; split; [ reflexivity | exact Hk ] ].
      - match goal with Hh : exec_stmt _ _ _ _ _ grd_s1h _ _ _ _ |- _ =>
          destruct (HEAD _ _ _ _ Hh) as (-> & I1 & [(-> & _) | ->]) end.
        + congruence.
        + split; [ exact I1 | left; reflexivity ].
    Qed.

    Lemma add_int_k : forall ce k mm v, 0 <= k < 4 ->
        sem_binary_operation ce Oadd (Vint (Int.repr k)) tint (Vint (Int.repr 1)) tint mm = Some v ->
        v = Vint (Int.repr (k + 1)).
    Proof.
      intros ce k mm v Hk H. vcbn H. injection H as <-. f_equal.
      rewrite Int.add_unsigned, !Int.unsigned_repr by (cbn; lia). reflexivity.
    Qed.

    Lemma add_ptr_int : forall ce b o ty n c mm v, sizeof ce ty = n ->
        sem_binary_operation ce Oadd (Vptr b o) (tptr ty) (Vint c) tint mm = Some v ->
        v = Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr n) (Ptrofs.of_ints c))).
    Proof. intros ce b o ty n c mm v Hn H. cbn -[sizeof] in H. rewrite Hn in H. injection H as <-. reflexivity. Qed.

    Lemma add_uc_ofs : forall ce b o x mm v,
        sem_binary_operation ce Oadd (Vptr b o) (tptr tuchar) (Vptrofs x) tuint mm = Some v ->
        v = Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 1) (Ptrofs.of_intu (Ptrofs.to_int x)))).
    Proof. intros ce b o x mm v H. vcbn H. injection H as <-. reflexivity. Qed.

    Lemma grd_s2_ok : forall k le mm t le' m' out, 0 <= k < 4 -> grd_inv k le mm ->
        exec_stmt function_entry2 G grd_e le mm grd_s2 t le' m' out ->
        out = Out_normal /\ grd_inv (k + 1) le' m'.
    Proof.
      intros k le mm t le' m' out Hk I H.
      split; [ exact (simple_normal' _ _ _ _ _ _ _ _ H eq_refl) | ].
      destruct I as (Rk & Ei & Ec & Ep & U & P).
      cbn [grd_s2 grd_loop CR.f_osContGetReadData fn_body] in H.
      apply seq_inv in H as (t1 & le1 & m1 & t2 & H1 & Hp); [ | reflexivity ].
      apply seq_inv in H1 as (t3 & le2 & m2 & t4 & Hi & Hc); [ | reflexivity ].
      inv Hi. inv Hc. inv Hp. inv_ev. cbn [typeof] in *.
      repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ => tgetH Hx end.
      rtemp.
      repeat match goal with Hx : sem_binary_operation _ Oadd (Vint _) _ _ _ _ = Some _ |- _ =>
        apply (add_int_k _ _ _ _ Hk) in Hx; subst end.
      repeat match goal with Hx : sem_binary_operation _ Oadd _ (tptr tuchar) _ _ _ = Some _ |- _ =>
        rewrite sz869 in Hx; apply add_uc_ofs in Hx; subst end.
      repeat match goal with Hx : sem_binary_operation _ Oadd _ (tptr (Tstruct _ _)) _ _ _ = Some _ |- _ =>
        apply (add_ptr_int _ _ _ _ 6 _ _ _ sz319) in Hx; subst end.
      assert (Kc : k = 0 \/ k = 1 \/ k = 2 \/ k = 3) by lia.
      split; [ lia | ].
      split; [ tget; reflexivity | ].
      split; [ tget; destruct Kc as [-> | [-> | [-> | ->]]]; reflexivity | ].
      split; [ tget; destruct Kc as [-> | [-> | [-> | ->]]]; reflexivity | ].
      split; [ exact U | exact P ].
    Qed.

    Lemma grd_loop_ok : forall e le mm S t le' m' out,
        exec_stmt function_entry2 G e le mm S t le' m' out ->
        e = grd_e -> S = Sloop grd_s1 grd_s2 ->
        forall k, grd_inv k le mm -> out = Out_normal /\ exists k', grd_inv k' le' m'.
    Proof.
      intros e le mm S t le' m' out H.
      induction H; intros Ee ES; try discriminate ES; injection ES as -> ->; subst e; intros k I.
      - match goal with Hx : exec_stmt _ _ _ _ _ grd_s1 _ _ _ _ |- _ =>
          destruct (grd_s1_ok _ _ _ _ _ _ _ I Hx) as (I1 & [-> | (-> & _)]) end;
        match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end.
        split; [ reflexivity | exists k; exact I1 ].
      - match goal with Hx : exec_stmt _ _ _ _ _ grd_s2 _ _ _ ?o2, Hb : out_break_or_return ?o2 _ |- _ =>
          rewrite (simple_normal' _ _ _ _ _ _ _ _ Hx eq_refl) in Hb; inv Hb end.
      - match goal with Hx : exec_stmt _ _ _ _ _ grd_s1 _ _ _ _ |- _ =>
          destruct (grd_s1_ok _ _ _ _ _ _ _ I Hx) as (I1 & [-> | (-> & Hk)]) end.
        + match goal with Hb : out_normal_or_continue _ |- _ => inv Hb end.
        + match goal with Hx : exec_stmt _ _ _ _ _ grd_s2 _ _ _ _ |- _ =>
            destruct (grd_s2_ok k _ _ _ _ _ _ ltac:(destruct I; lia) I1 Hx) as (_ & I2) end.
          match goal with IH : grd_e = grd_e -> _ |- _ => exact (IH eq_refl eq_refl _ I2) end.
    Qed.

    Lemma grd_body_run : forall m1 le0 t le' m2 out,
        Mem.alloc m 0 (sizeof (genv_cenv G) (Tstruct CR.__869 noattr)) = (m1, br) ->
        le0 ! CR._pad = Some (Vptr bpads Ptrofs.zero) ->
        exec_stmt function_entry2 G grd_e le0 m1 (fn_body CR.f_osContGetReadData) t le' m2 out ->
        UO m2 /\ pads_ac m2.
    Proof.
      intros m1 le0 t le' m2 out Hal Hp H. rewrite grd_shape in H.
      apply seq_inv in H as (t1 & le1 & ma & t2 & Hh1 & H); [ | reflexivity ].
      apply seq_inv in H as (t3 & le2 & mb & t4 & Hh2 & H); [ | reflexivity ].
      cbn [grd_h1 grd_h2 CR.f_osContGetReadData fn_body] in Hh1, Hh2.
      inv Hh1. inv Hh2.
      match goal with Hv : eval_expr _ _ _ _ (Ecast _ _) _ |- _ => inv Hv; try solve [ inv_ev ] end.
      match goal with Hv : eval_expr _ _ _ _ (Efield (Evar _ _) _ _) _ |- _ =>
        pose proof (ev_glob_arr _ _ _ _ _ _ _ _ _ _ 0 bpif Ee_pif Hpif
                      (fo_lp lp CR.prog LO_cr _ _ _ fo_pif_ram) Hv) as Ev end.
      subst.
      match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => vcbn Hc; injection Hc as <- end.
      inv_ev.
      lazymatch goal with Hal' : Mem.alloc m 0 _ = (?M, br),
                          Hp' : ?L ! CR._pad = Some (Vptr bpads Ptrofs.zero) |- _ =>
        assert (I0 : grd_inv 0
                       (PTree.set CR._i (Vint (Int.repr 0))
                          (PTree.set CR._cmdBufPtr (Vptr bpif (Ptrofs.repr 0)) L)) M) end.
      { split; [ lia | ]. split; [ tget; reflexivity | ]. split; [ tget; reflexivity | ].
        split; [ tget; exact Hp | ].
        split.
        - exact (Mem.alloc_unchanged_on _ _ _ _ _ _ Hal).
        - intros k n Hk Hl. apply (Hpac k n Hk). rewrite <- Hl. symmetry.
          exact (Mem.load_alloc_unchanged _ _ _ _ _ Hal _ _ _ Vpads). }
      destruct (grd_loop_ok _ _ _ _ _ _ _ _ H eq_refl eq_refl 0 I0) as (_ & k' & (_ & _ & _ & _ & U & P)).
      split; [ exact U | exact P ].
    Qed.
  End GRD.

  (* osContGetReadData: only gControllerPads changes, and its button words
     stay A-free when the PIF reply shows A on no live port. *)
  Lemma grd_ok : forall m t m' vres,
      eval_funcall function_entry2 G m (Internal CR.f_osContGetReadData)
        [Vptr bpads Ptrofs.zero] t m' vres ->
      Mem.valid_block m bpads -> Mem.valid_block m bpif -> Mem.valid_block m bmx ->
      (forall k, 0 <= k < 4 -> port_a m bpif k = false) ->
      (forall x, Mem.load Mint8unsigned m bmx 0 = Some (Vint x) -> Int.unsigned x <= 4) ->
      pads_ac m ->
      Mem.unchanged_on (fun b z => Mem.valid_block m b /\ b <> bpads) m m' /\ pads_ac m'.
  Proof.
    intros m t m' vres Hev Vp Vf Vx Hport Hmax P.
    inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      cbn [CR.f_osContGetReadData fn_vars] in Ha; inv Ha end.
    match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn [CR.f_osContGetReadData fn_params fn_temps bind_parameter_temps] in Hb;
      injection Hb as <- end.
    lazymatch goal with Hal : Mem.alloc m 0 _ = (?m1, ?b1),
                    Hx : exec_stmt _ _ _ ?le0 ?m1 _ _ _ ?m2 _,
                    Hfr : Mem.free_list ?m2 _ = Some m' |- _ =>
      pose proof (Mem.fresh_block_alloc _ _ _ _ _ Hal) as Nb;
      destruct (grd_body_run m b1 Nb Vp Vf Vx Hport Hmax P _ le0 _ _ _ _ Hal
                  ltac:(apply PTree.gss) Hx) as (U2 & P2);
      assert (Nb1 : b1 <> bpads) by (intros E; subst b1; exact (Nb Vp));
      assert (Uf : Mem.unchanged_on (fun b z => Mem.valid_block m b /\ b <> bpads) m2 m')
        by (apply (free_env_unch G _ m2 m' _ Hfr);
            intros id bb ty Hid z (Hv & _);
            destruct (Pos.eq_dec id CR._response) as [-> | Nid];
            [ rewrite PTree.gss in Hid; injection Hid as <- _; exact (Nb Hv)
            | rewrite PTree.gso, PTree.gempty in Hid by exact Nid; discriminate Hid ]);
      assert (Uf2 : Mem.unchanged_on (fun b _ => b = bpads) m2 m')
        by (apply (free_env_unch G _ m2 m' _ Hfr);
            intros id bb ty Hid z E; subst bb;
            destruct (Pos.eq_dec id CR._response) as [-> | Nid];
            [ rewrite PTree.gss in Hid; injection Hid as E' _; exact (Nb1 E')
            | rewrite PTree.gso, PTree.gempty in Hid by exact Nid; discriminate Hid ])
    end.
    split; [ eapply Mem.unchanged_on_trans; [ exact U2 | exact Uf ] | ].
    intros k n Hk Hl. apply (P2 k n Hk). rewrite <- Hl. symmetry.
    eapply Mem.load_unchanged_on_1; [ exact Uf2 | | intros; reflexivity ].
    eapply Mem.valid_block_unchanged_on; [ exact U2 | exact Vp ].
  Qed.

  (* ---- calls through a TU-defined name ---- *)
  Lemma resolve : forall q id f b fd, linkorder q lp ->
      (prog_defmap q) ! id = Some (Gfun (Internal f)) ->
      Genv.find_symbol G id = Some b -> Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd ->
      fd = Internal f.
  Proof.
    intros q id f b fd LO Hd Hs Hf.
    destruct (linkorder_resolves_funct lp q id f LO Hd) as (b' & S & F).
    change (Genv.find_symbol G id = Some b') in S. rewrite Hs in S. injection S as <-.
    change (Genv.find_funct G (Vptr b Ptrofs.zero) = Some (Internal f)) in F. congruence.
  Qed.

  Lemma dm_grd : (prog_defmap CR.prog) ! CR._osContGetReadData
                 = Some (Gfun (Internal CR.f_osContGetReadData)).
  Proof. reflexivity. Qed.
  Lemma dm_rd : (prog_defmap GI.prog) ! GI._run_demo_inputs = Some (Gfun (Internal GI.f_run_demo_inputs)).
  Proof. reflexivity. Qed.
  Lemma dm_adj : (prog_defmap GI.prog) ! GI._adjust_analog_stick
                 = Some (Gfun (Internal GI.f_adjust_analog_stick)).
  Proof. reflexivity. Qed.

  Lemma sz_ctl : sizeof (genv_cenv G) (Tstruct GI._Controller noattr) = 28.
  Proof. exact (sizeof_lp lp GI.prog LO_gi _ _ _ (proj2 (proj2 sizes)) ltac:(discriminate)). Qed.

  Lemma add_arr_int : forall ce b o ty n sz a c mm v, sizeof ce ty = n ->
      sem_binary_operation ce Oadd (Vptr b o) (Tarray ty sz a) (Vint c) tint mm = Some v ->
      v = Vptr b (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr n) (Ptrofs.of_ints c))).
  Proof. intros ce b o ty n sz a c mm v Hn H. cbn -[sizeof] in H. rewrite Hn in H. injection H as <-. reflexivity. Qed.

  Lemma ev_var_ref : forall e le mm x ty v, access_mode ty = By_reference -> e ! x = None ->
      eval_expr G e le mm (Evar x ty) v -> exists b, Genv.find_symbol G x = Some b /\ v = Vptr b Ptrofs.zero.
  Proof.
    intros e le mm x ty v Ham Hx H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _, Hd : deref_loc _ _ _ _ _ _ |- _ =>
      inv Hl; [ congruence | ]; inv Hd; cbn [typeof] in *; try congruence end.
    eexists; split; [ eassumption | reflexivity ].
  Qed.

  Lemma ev_var_ref' : forall e le mm x ty v, eval_expr G e le mm (Evar x ty) v ->
      access_mode ty = By_reference -> e ! x = None ->
      exists b, Genv.find_symbol G x = Some b /\ v = Vptr b Ptrofs.zero.
  Proof. intros e le mm x ty v H Ham Hx. exact (ev_var_ref _ _ _ _ _ _ Ham Hx H). Qed.


  (* &gControllers[j] *)
  Lemma ev_ctl : forall le mm a j v,
      (forall v', eval_expr G empty_env le mm a v' -> v' = Vint (Int.repr j)) ->
      0 <= j <= 2 ->
      eval_expr G empty_env le mm
        (Ebinop Oadd (Evar GI._gControllers (tarray (Tstruct GI._Controller noattr) 3)) a
           (tptr (Tstruct GI._Controller noattr))) v ->
      typeof a = tint ->
      v = Vptr bc (Ptrofs.repr (28 * j)).
  Proof.
    intros le mm a j v Ha Hj H Hty. inv H; [ | solve [ inv_ev ] ].
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (ev_var_ref' _ _ _ _ _ _ Hv eq_refl (PTree.gempty _ _)) as (b & Sb & ->) end.
    change GI._gControllers with mario._gControllers in Sb. rewrite Hbc in Sb. injection Sb as <-.
    match goal with Hv : eval_expr _ _ _ _ a _ |- _ => rewrite (Ha _ Hv) in * end.
    match goal with Hb : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
      cbn [typeof] in Hb; rewrite Hty in Hb; rewrite (add_arr_int _ _ _ _ 28 _ _ _ _ _ sz_ctl Hb) end.
    assert (Kj : j = 0 \/ j = 1 \/ j = 2) by lia.
    destruct Kj as [-> | [-> | ->]]; reflexivity.
  Qed.

  Lemma ev_const_det : forall le mm n ty v', eval_expr G empty_env le mm (Econst_int n ty) v' -> v' = Vint n.
  Proof. intros. exact (ev_const _ _ _ _ _ _ _ H). Qed.

  Lemma ev_tmp_det : forall le mm x ty v, le ! x = Some v ->
      forall v', eval_expr G empty_env le mm (Etempvar x ty) v' -> v' = v.
  Proof. intros le mm x ty v Hx v' H. apply ev_tmp in H. congruence. Qed.

  (* ---- the frame of the poll: what read_controller_inputs leaves ---- *)
  Section WALK.
    Variable mi : mem.
    Hypothesis Hgn : Ple (Genv.genv_next G) (Mem.nextblock mi).

    Definition Fr (b : block) (z : Z) : Prop :=
      b <> bq /\ b <> brm /\ b <> bpads /\ (b <> bc \/ 24 <= z < 28 \/ 52 <= z < 56).
    Definition Uc (m : mem) : Prop := Mem.unchanged_on (fun b z => Mem.valid_block mi b /\ Fr b z) mi m.
    Definition Inv (m : mem) : Prop := Uc m /\ pads_ac m /\ btn_ok m.

    Lemma vsym : forall id b, Genv.find_symbol G id = Some b -> Mem.valid_block mi b.
    Proof.
      intros id b H. unfold Mem.valid_block. eapply Plt_Ple_trans; [ | exact Hgn ].
      exact (Genv.genv_symb_range _ _ H).
    Qed.

    Lemma Uc_load : forall m ch b z, Uc m -> Mem.valid_block mi b ->
        (forall i, z <= i < z + size_chunk ch -> Fr b i) ->
        Mem.load ch m b z = Mem.load ch mi b z.
    Proof.
      intros m ch b z U V F. eapply Mem.load_unchanged_on_1; [ exact U | exact V | ].
      intros i Hi. split; [ exact V | exact (F i Hi) ].
    Qed.

    Lemma Fr_far : forall b z, b <> bq -> b <> brm -> b <> bpads -> b <> bc -> Fr b z.
    Proof. intros. split; [ assumption | split; [ assumption | split; [ assumption | left; assumption ] ] ]. Qed.

    Lemma Uc_valid : forall m b, Uc m -> Mem.valid_block mi b -> Mem.valid_block m b.
    Proof. intros m b U V. exact (Mem.valid_block_unchanged_on _ _ _ _ U V). Qed.

    (* a store into gControllers[j] (j = 0, 1: the loop; j = 2: the player-3 copy),
       below the controllerData word *)
    Lemma ctl_store_inv : forall m m' j d ch v, (j = 0 \/ j = 1 \/ j = 2) -> 0 <= d -> d + size_chunk ch <= 20 ->
        (d + size_chunk ch <= 16 \/ ((d = 16 \/ d = 18) /\ ch = Mint16unsigned)) ->
        (j = 0 -> 16 < d + size_chunk ch -> exists w, v = Vint w /\ Aclr w) ->
        Mem.store ch m bc (28 * j + d) v = Some m' -> Inv m -> Inv m'.
    Proof.
      intros m m' j d ch v Hj Hd Hd2 Hdc Hv Hs (U & P & B).
      pose proof (size_chunk_pos ch) as Pc.
      assert (Nbp : bc <> bpads) by ne Hbc Hpads.
      split; [ | split ].
      - eapply Mem.unchanged_on_trans; [ exact U | ].
        eapply Mem.store_unchanged_on; [ exact Hs | ].
        intros i Hi (_ & _ & _ & _ & [N | [N | N]]); [ exact (N eq_refl) | lia | lia ].
      - intros k n Hk Hl. apply (P k n Hk). rewrite <- Hl. symmetry.
        apply (Mem.load_store_other _ _ _ _ _ _ Hs). left. exact (not_eq_sym Nbp).
      - intros z Hz.
        destruct (Z.eq_dec j 0) as [-> | Nj]; [ destruct (Z.eq_dec d z) as [<- | Nd] | ].
        + destruct Hdc as [Hdc | (_ & ->)]; [ destruct Hz; lia | ].
          destruct (Hv eq_refl ltac:(cbn [size_chunk]; destruct Hz; lia)) as (w & -> & Aw).
          rewrite Z.mul_0_r, Z.add_0_l in Hs.
          rewrite (Mem.load_store_same _ _ _ _ _ _ Hs). cbn [Val.load_result].
          exists (Int.zero_ext 16 w). split; [ reflexivity | unfold Aclr; rewrite and_A_zext16; exact Aw ].
        + destruct (B z Hz) as (w & Lw & Aw). exists w. split; [ | exact Aw ].
          rewrite <- Lw. apply (Mem.load_store_other _ _ _ _ _ _ Hs). right. cbn [size_chunk].
          destruct Hdc as [Hdc | (Hd16 & ->)]; cbn [size_chunk] in *; destruct Hz; lia.
        + destruct (B z Hz) as (w & Lw & Aw). exists w. split; [ | exact Aw ].
          rewrite <- Lw. apply (Mem.load_store_other _ _ _ _ _ _ Hs). right. cbn [size_chunk].
          destruct Hz; lia.
    Qed.

    (* the controller fields the walks write *)
    Definition ctl_fields : list (ident * type) :=
      [(GI._rawStickX, tshort); (GI._rawStickY, tshort); (GI._stickX, tfloat); (GI._stickY, tfloat);
       (GI._stickMag, tfloat); (GI._buttonDown, tushort); (GI._buttonPressed, tushort)].

    Lemma fld_spec : forall f ty, In (f, ty) ctl_fields ->
        exists d ch, gi_fo GI._Controller f = Some (d, Full) /\ access_mode ty = By_value ch
          /\ type_is_volatile ty = false /\ 0 <= d /\ d + size_chunk ch <= 20
          /\ (d + size_chunk ch <= 16 \/ ((d = 16 \/ d = 18) /\ ch = Mint16unsigned))
          /\ (16 < d + size_chunk ch -> (f = GI._buttonDown /\ d = 16) \/ (f = GI._buttonPressed /\ d = 18)).
    Proof.
      intros f ty H. unfold ctl_fields in H.
      destruct H as [E | [E | [E | [E | [E | [E | [E | []]]]]]]]; injection E as <- <-;
      (* per field (one block per goal); the offset is read off the composite
         environment by vm_compute (plain unification would reduce it) *)
      ( lazymatch goal with
        | |- @ex Z (fun _ => @ex memory_chunk (fun _ => gi_fo ?C ?f = _ /\ _)) =>
            let r := eval vm_compute in (gi_fo C f) in
            lazymatch r with Some (?d0, _) => exists d0 end
        end;
        eexists; (split; [ vm_compute; reflexivity | ]);
        (split; [ reflexivity | ]); (split; [ reflexivity | ]); cbn [size_chunk];
        (split; [ lia | ]); (split; [ lia | ]);
        (split; [ first [ left; lia | right; split; [ lia | reflexivity ] ] | ]);
        intros; first [ lia | left; split; [ reflexivity | lia ] | right; split; [ reflexivity | lia ] ] ).
    Qed.

    Lemma ctl_assign : forall le m t le' m' out p f ty rhs,
        In (f, ty) ctl_fields ->
        (forall v, le ! p = Some v -> v = Vundef \/ exists j, (j = 0 \/ j = 1 \/ j = 2)
           /\ v = Vptr bc (Ptrofs.repr (28 * j))
           /\ (j = 0 -> (f = GI._buttonDown \/ f = GI._buttonPressed) -> forall v1 v1',
                 eval_expr G empty_env le m rhs v1 -> sem_cast v1 (typeof rhs) ty m = Some v1' ->
                 exists w, v1' = Vint w /\ Aclr w)) ->
        exec_stmt function_entry2 G empty_env le m (Sassign (ctl_lv p f ty) rhs) t le' m' out ->
        Inv m -> Inv m'.
    Proof.
      intros le m t le' m' out p f ty rhs Hf Hp Hx I.
      destruct (fld_spec f ty Hf) as (d & ch & Hfo & Ham & Hvol & D0 & D20 & Dc & Dbt).
      destruct (fld_store G _ _ _ _ _ _ _ _ _ _ _ _ _ ch d (fc _ _ Hfo) Ham Hvol Hx)
        as (_ & _ & _ & loc & o0 & v & v' & Ha & Hr & Hc & St).
      apply ev_tmp in Ha. destruct (Hp _ Ha) as [E | (j & Hj & E & Hv)]; [ discriminate E | ].
      injp E. pose proof (size_chunk_pos ch) as Pch.
      rewrite u_ofs in St by lia.
      apply (ctl_store_inv m m' j d ch v' Hj D0 D20 Dc); [ | exact St | exact I ].
      intros J0 H16. destruct (Dbt H16) as [(-> & _) | (-> & _)].
      - exact (Hv J0 (or_introl eq_refl) _ _ Hr Hc).
      - exact (Hv J0 (or_intror eq_refl) _ _ Hr Hc).
    Qed.

    (* adjust_analog_stick(&gControllers[j]) *)
    Lemma adj_step : forall le m t le' m' out j,
        (j = 0 \/ j = 1) ->
        exec_stmt function_entry2 G empty_env le m
          (Scall None (Evar GI._adjust_analog_stick
                         (Tfunction [tptr (Tstruct GI._Controller noattr)] tvoid cc_default))
             [Etempvar GI._controller (tptr (Tstruct GI._Controller noattr))]) t le' m' out ->
        le ! GI._controller = Some (Vptr bc (Ptrofs.repr (28 * j))) ->
        Inv m -> Inv m' /\ le' = le.
    Proof.
      intros le m t le' m' out j Hj Hx Hc (U & P & B).
      destruct (LptBody.scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ Hx (PTree.gempty _ _) eq_refl)
        as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hfd & Hcl & Hel & Hev & -> & ->).
      rewrite (resolve _ _ _ _ _ LO_gi dm_adj Hs Hfd) in Hev.
      cbn in Hcl. injection Hcl as <- <- <-.
      inv Hel. match goal with Hl : eval_exprlist _ _ _ _ [] _ _ |- _ => inv Hl end.
      match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_tmp in Hv; rewrite Hc in Hv; injs Hv end.
      match goal with Hcs : sem_cast _ _ _ _ = Some _ |- _ => apply cast_pp in Hcs; subst end.
      assert (Uo : Ptrofs.unsigned (Ptrofs.repr (28 * j)) = 28 * j) by (apply u_rep; lia).
      pose proof (adj_ok _ _ _ _ _ _ Hev ltac:(rewrite Uo, max_u; lia)) as UA.
      rewrite Uo in UA.
      assert (Nbp : bc <> bpads) by ne Hbc Hpads.
      assert (Vbc : Mem.valid_block m bc) by exact (Uc_valid m bc U (vsym _ _ Hbc)).
      assert (Vbp : Mem.valid_block m bpads) by exact (Uc_valid m bpads U (vsym _ _ Hpads)).
      split; [ | reflexivity ].
      split; [ | split ].
      - eapply Mem.unchanged_on_trans; [ exact U | ].
        eapply Mem.unchanged_on_implies; [ exact UA | ].
        intros b' z (Vi & (_ & _ & _ & F)) Vm. split; [ exact Vm | ].
        destruct F as [N | [Z1 | Z1]]; [ left; exact N | right; destruct Hj; subst j; lia | right; destruct Hj; subst j; lia ].
      - intros k n Hk Hl. apply (P k n Hk). rewrite <- Hl. symmetry.
        eapply Mem.load_unchanged_on_1; [ exact UA | exact Vbp | ].
        intros i _. split; [ exact Vbp | left; exact (not_eq_sym Nbp) ].
      - intros z Hz. destruct (B z Hz) as (w & Lw & Aw). exists w. split; [ | exact Aw ].
        rewrite <- Lw. eapply Mem.load_unchanged_on_1; [ exact UA | exact Vbc | ].
        intros i Hi. split; [ exact Vbc | right ]. cbn [size_chunk] in Hi.
        destruct Hj; subst j; destruct Hz; subst z; lia.
    Qed.

    (* ---- the controller loop's temps ---- *)
    Hypothesis Hcd : forall j, j = 0 \/ j = 1 ->
        Mem.load Mint32 mi bc (28 * j + 24) = Some (Vint Int.zero)
        \/ exists k, 0 <= k < 4 /\ Mem.load Mint32 mi bc (28 * j + 24) = Some (Vptr bpads (Ptrofs.repr (6 * k))).
    Hypothesis Hp3v : Mem.load Mint32 mi bp3 0 = Some (Vptr bc (Ptrofs.repr 56)).

    Definition cd_cls (v : val) : Prop :=
      v = Vundef \/ v = Vint Int.zero \/ exists k, 0 <= k < 4 /\ v = Vptr bpads (Ptrofs.repr (6 * k)).
    Definition btn_cls (v : val) : Prop := v = Vundef \/ exists n, v = Vint n /\ Aclr n.
    Definition ctl_cls (v : val) : Prop :=
      v = Vundef \/ v = Vptr bc (Ptrofs.repr 0) \/ v = Vptr bc (Ptrofs.repr 28).
    Definition T_cd : list ident := [GI._t'22; GI._t'32; GI._t'30; GI._t'25; GI._t'27; GI._t'23].
    Definition T_btn : list ident := [GI._t'26; GI._t'24].

    (* the player-3 pointer temps of the final copy *)
    Definition T3 : list ident := [GI._t'19; GI._t'16; GI._t'13; GI._t'10; GI._t'7; GI._t'4; GI._t'1].
    Definition p3_cls (v : val) : Prop := v = Vundef \/ v = Vptr bc (Ptrofs.repr 56).
    Definition G3 (le : temp_env) : Prop := forall x v, In x T3 -> le ! x = Some v -> p3_cls v.

    Definition Gt (le : temp_env) : Prop :=
      (forall v, le ! GI._controller = Some v -> ctl_cls v)
      /\ (forall x v, In x T_cd -> le ! x = Some v -> cd_cls v)
      /\ (forall x v, In x T_btn -> le ! x = Some v -> btn_cls v)
      /\ G3 le.
    Definition Gj (j : Z) (le : temp_env) : Prop := le ! GI._i = Some (Vint (Int.repr j)) /\ Gt le.

    Lemma in_ex : forall x l, In x l -> existsb (Pos.eqb x) l = true.
    Proof. intros x l H. apply existsb_exists. exists x. split; [ exact H | apply Pos.eqb_refl ]. Qed.
    Lemma ex_in : forall x l, existsb (Pos.eqb x) l = true -> In x l.
    Proof. intros x l H. apply existsb_exists in H as (y & Hy & E). apply Pos.eqb_eq in E. subst. exact Hy. Qed.

    Lemma Gt_set : forall le id v, Gt le -> (In id T3 -> p3_cls v) ->
        (id = GI._controller -> ctl_cls v) -> (In id T_cd -> cd_cls v) -> (In id T_btn -> btn_cls v) ->
        Gt (PTree.set id v le).
    Proof.
      intros le id v (C & D & B & T) Ht Hc Hd Hb.
      split; [ | split; [ | split ] ].
      - intros w Hw. destruct (peq GI._controller id) as [E | N].
        + rewrite E, PTree.gss in Hw. injection Hw as <-. exact (Hc (eq_sym E)).
        + rewrite PTree.gso in Hw by exact N. exact (C w Hw).
      - intros x w Hx Hw. destruct (peq x id) as [-> | N].
        + rewrite PTree.gss in Hw. injection Hw as <-. exact (Hd Hx).
        + rewrite PTree.gso in Hw by exact N. exact (D x w Hx Hw).
      - intros x w Hx Hw. destruct (peq x id) as [-> | N].
        + rewrite PTree.gss in Hw. injection Hw as <-. exact (Hb Hx).
        + rewrite PTree.gso in Hw by exact N. exact (B x w Hx Hw).
      - intros x w Hx Hw. destruct (peq x id) as [-> | N].
        + rewrite PTree.gss in Hw. injection Hw as <-. exact (Ht Hx).
        + rewrite PTree.gso in Hw by exact N. exact (T x w Hx Hw).
    Qed.

    Definition pad_btn (p : ident) : expr :=
      Efield (Ederef (Etempvar p (tptr (Tstruct GI.__319 noattr))) (Tstruct GI.__319 noattr)) GI._button tushort.
    Definition ctl_ptr_e : expr :=
      Ebinop Oadd (Evar GI._gControllers (tarray (Tstruct GI._Controller noattr) 3))
        (Etempvar GI._i tint) (tptr (Tstruct GI._Controller noattr)).

    Definition set_l (id : ident) (a : expr) : bool :=
      if Pos.eqb id GI._i || existsb (Pos.eqb id) T3 then false
      else if Pos.eqb id GI._controller then expr_eqb a ctl_ptr_e
      else if existsb (Pos.eqb id) T_cd then
        expr_eqb a (ctl_lv GI._controller GI._controllerData (tptr (Tstruct GI.__319 noattr)))
      else if Pos.eqb id GI._t'26 then expr_eqb a (pad_btn GI._t'25)
      else if Pos.eqb id GI._t'24 then expr_eqb a (pad_btn GI._t'23)
      else true.

    Lemma ctl_not_cd : ~ In GI._controller T_cd.
    Proof. intros H. apply in_ex in H. vm_compute in H. discriminate H. Qed.
    Lemma ctl_not_btn : ~ In GI._controller T_btn.
    Proof. intros H. apply in_ex in H. vm_compute in H. discriminate H. Qed.
    Lemma cd_not_btn : forall x, In x T_cd -> ~ In x T_btn.
    Proof. intros x H1 H2. unfold T_cd in H1. unfold T_btn in H2.
      repeat (destruct H1 as [<- | H1]; [ repeat (destruct H2 as [E | H2]; [ vm_compute in E; discriminate E | ]); exact H2 | ]).
      exact H1. Qed.

    (* the controllerData word of the current controller *)
    Lemma cd_load : forall le m v, Gt le -> Inv m ->
        eval_expr G empty_env le m (ctl_lv GI._controller GI._controllerData (tptr (Tstruct GI.__319 noattr))) v ->
        cd_cls v.
    Proof.
      intros le m v (C & _) (U & _) H.
      destruct (fld_load' G _ _ _ _ _ _ _ _ _ Mint32 24 (fc _ _ fo_c_cd) H eq_refl eq_refl) as (loc & o0 & Ha & L).
      apply ev_tmp in Ha. destruct (C _ Ha) as [E | [E | E]]; [ discriminate E | | ]; injp E.
      - rewrite u_ofs in L by lia. cbn [Z.add] in L.
        rewrite (Uc_load m Mint32 bc 24 U (vsym _ _ Hbc)) in L.
        + destruct (Hcd 0 (or_introl eq_refl)) as [L0 | (k & Hk & L0)]; change (28 * 0 + 24) with 24 in L0;
            rewrite L0 in L; injs L; [ right; left; reflexivity | right; right; exists k; split; [ exact Hk | reflexivity ] ].
        + intros i Hi. cbn [size_chunk] in Hi.
          split; [ ne Hbc Hq | split; [ ne Hbc Hrm | split; [ ne Hbc Hpads | right; left; lia ] ] ].
      - rewrite u_ofs in L by lia. change (28 + 24) with 52 in L.
        rewrite (Uc_load m Mint32 bc 52 U (vsym _ _ Hbc)) in L.
        + destruct (Hcd 1 (or_intror eq_refl)) as [L0 | (k & Hk & L0)]; change (28 * 1 + 24) with 52 in L0;
            rewrite L0 in L; injs L; [ right; left; reflexivity | right; right; exists k; split; [ exact Hk | reflexivity ] ].
        + intros i Hi. cbn [size_chunk] in Hi.
          split; [ ne Hbc Hq | split; [ ne Hbc Hrm | split; [ ne Hbc Hpads | right; right; lia ] ] ].
    Qed.

    (* a pad's button word *)
    Lemma btn_load : forall le m p v w, le ! p = Some w -> cd_cls w -> Inv m ->
        eval_expr G empty_env le m (pad_btn p) v -> btn_cls v.
    Proof.
      intros le m p v w Hp Hw (_ & P & _) H.
      destruct (fld_load' G _ _ _ _ _ _ _ _ _ Mint16unsigned 0 (fp _ _ fo_p_btn) H eq_refl eq_refl)
        as (loc & o0 & Ha & L).
      apply ev_tmp in Ha. rewrite Hp in Ha. injection Ha as ->.
      destruct Hw as [E | [E | (k & Hk & E)]]; try discriminate E. injp E.
      rewrite u_ofs in L by lia. rewrite Z.add_0_r in L.
      destruct (ld16_cls _ _ _ _ L) as [-> | (n & ->)]; [ left; reflexivity | ].
      right. exists n. split; [ reflexivity | exact (P k n Hk L) ].
    Qed.

    Lemma set_l_ok : forall j, (j = 0 \/ j = 1) -> forall id a le m v,
        set_l id a = true -> Gj j le -> Inv m ->
        eval_expr G empty_env le m a v -> Gj j (PTree.set id v le).
    Proof.
      intros j Hj id a le m v Hok (Ei & Gl) I Hv. unfold set_l in Hok.
      destruct (Pos.eqb id GI._i || existsb (Pos.eqb id) T3) eqn:E1; [ discriminate Hok | ].
      apply orb_false_iff in E1 as (E1 & E1').
      assert (N3' : ~ In id T3) by (intros H; rewrite (in_ex _ _ H) in E1'; discriminate E1').
      apply Pos.eqb_neq in E1.
      split; [ rewrite PTree.gso by (intros E; exact (E1 (eq_sym E))); exact Ei | ].
      destruct (Pos.eqb id GI._controller) eqn:E2.
      { apply Pos.eqb_eq in E2. subst id. apply expr_eqb_eq in Hok. subst a.
        apply (Gt_set _ _ _ Gl (fun H => False_ind _ (N3' H))); [ | intros H; exfalso; exact (ctl_not_cd H) | intros H; exfalso; exact (ctl_not_btn H) ].
        intros _. unfold ctl_ptr_e in Hv.
        rewrite (ev_ctl _ _ _ j _ (ev_tmp_det _ _ _ _ _ Ei) ltac:(lia) Hv eq_refl).
        destruct Hj as [-> | ->]; [ right; left | right; right ]; reflexivity. }
      apply Pos.eqb_neq in E2.
      destruct (existsb (Pos.eqb id) T_cd) eqn:E3.
      { apply expr_eqb_eq in Hok. subst a. apply ex_in in E3.
        apply (Gt_set _ _ _ Gl (fun H => False_ind _ (N3' H))); [ intros E; exfalso; exact (E2 E) | | intros H; exfalso; exact (cd_not_btn _ E3 H) ].
        intros _. exact (cd_load _ _ _ Gl I Hv). }
      assert (N3 : ~ In id T_cd) by (intros H; rewrite (in_ex _ _ H) in E3; discriminate E3).
      destruct (Pos.eqb id GI._t'26) eqn:E4.
      { apply Pos.eqb_eq in E4. subst id. apply expr_eqb_eq in Hok. subst a.
        apply (Gt_set _ _ _ Gl (fun H => False_ind _ (N3' H))); [ intros E; exfalso; exact (E2 E) | intros H; exfalso; exact (N3 H) | ].
        intros _. destruct Gl as (_ & D & _).
        destruct (le ! GI._t'25) as [w|] eqn:Ew.
        - exact (btn_load _ _ _ _ _ Ew (D GI._t'25 _ ltac:(cbn; tauto) Ew) I Hv).
        - exfalso. unfold pad_btn in Hv.
          apply RealFrameValue.eval_expr_Efield_load in Hv as (loc & ofs & bf & Hl & _).
          apply RealFrameValue.eval_lvalue_Efield_inv in Hl as (o0 & _ & _ & _ & _ & Ha & _).
          apply ev_deref_struct in Ha. apply ev_tmp in Ha. congruence. }
      destruct (Pos.eqb id GI._t'24) eqn:E5.
      { apply Pos.eqb_eq in E5. subst id. apply expr_eqb_eq in Hok. subst a.
        apply (Gt_set _ _ _ Gl (fun H => False_ind _ (N3' H))); [ intros E; exfalso; exact (E2 E) | intros H; exfalso; exact (N3 H) | ].
        intros _. destruct Gl as (_ & D & _).
        destruct (le ! GI._t'23) as [w|] eqn:Ew.
        - exact (btn_load _ _ _ _ _ Ew (D GI._t'23 _ ltac:(cbn; tauto) Ew) I Hv).
        - exfalso. unfold pad_btn in Hv.
          apply RealFrameValue.eval_expr_Efield_load in Hv as (loc & ofs & bf & Hl & _).
          apply RealFrameValue.eval_lvalue_Efield_inv in Hl as (o0 & _ & _ & _ & _ & Ha & _).
          apply ev_deref_struct in Ha. apply ev_tmp in Ha. congruence. }
      apply Pos.eqb_neq in E4. apply Pos.eqb_neq in E5.
      apply (Gt_set _ _ _ Gl (fun H => False_ind _ (N3' H))); [ intros E; exfalso; exact (E2 E) | intros H; exfalso; exact (N3 H) | ].
      intros H. exfalso. destruct H as [E | [E | []]]; [ exact (E4 (eq_sym E)) | exact (E5 (eq_sym E)) ].
    Qed.

    (* ---- values stored into buttonPressed / buttonDown ---- *)
    Lemma and_us : forall ce w v2 v mm, sem_binary_operation ce Oand w tushort v2 tint mm = Some v ->
        exists n c, w = Vint n /\ v = Vint (Int.and n c).
    Proof.
      intros ce w v2 v mm H. destruct w; vcbn H; try discriminate H.
      all: destruct v2; vcbn H; try discriminate H. all: injection H as <-; exists i, i0; split; reflexivity.
    Qed.

    Lemma cast_i_us : forall w v mm, sem_cast (Vint w) tint tushort mm = Some v -> v = Vint (Int.zero_ext 16 w).
    Proof. intros w v mm H. vcbn H. injection H as <-. reflexivity. Qed.

    Definition bp_rhs (rhs : expr) : bool :=
      match rhs with
      | Ebinop Oand a b ty =>
          expr_eqb a (Etempvar GI._t'26 tushort)
          && (if type_eq (typeof b) tint then true else false) && (if type_eq ty tint then true else false)
      | _ => false
      end.
    Definition rhs_ok (f : ident) (rhs : expr) : bool :=
      if Pos.eqb f GI._buttonPressed then bp_rhs rhs || expr_eqb rhs (Econst_int (Int.repr 0) tint)
      else if Pos.eqb f GI._buttonDown then
        expr_eqb rhs (Etempvar GI._t'24 tushort) || expr_eqb rhs (Econst_int (Int.repr 0) tint)
      else true.

    Lemma fty_us : forall f ty, In (f, ty) ctl_fields -> (f = GI._buttonDown \/ f = GI._buttonPressed) ->
        ty = tushort.
    Proof.
      intros f ty H1 H2. unfold ctl_fields in H1.
      destruct H1 as [E | [E | [E | [E | [E | [E | [E | []]]]]]]]; inversion E; subst; try reflexivity;
        vm_compute in H2; destruct H2 as [H2 | H2]; discriminate H2.
    Qed.

    Lemma bp_rhs_spec : forall rhs, bp_rhs rhs = true ->
        exists b, rhs = Ebinop Oand (Etempvar GI._t'26 tushort) b tint /\ typeof b = tint.
    Proof.
      intros rhs H. destruct rhs; cbn [bp_rhs] in H; try discriminate H.
      lazymatch goal with |- exists _, Ebinop ?op ?a ?b ?ty = _ /\ _ =>
        destruct op; try discriminate H; exists b end.
      apply andb_prop in H as (H & Et). apply andb_prop in H as (H & Eb).
      apply expr_eqb_eq in H. subst.
      lazymatch goal with |- Ebinop _ _ _ ?ty = _ /\ _ =>
        revert Et; destruct (type_eq ty tint) as [-> | ]; intro Et; [ | discriminate Et ] end.
      lazymatch goal with |- _ /\ typeof ?b = _ =>
        revert Eb; destruct (type_eq (typeof b) tint) as [Eb' | ]; intro Eb; [ | discriminate Eb ] end.
      split; [ reflexivity | exact Eb' ].
    Qed.

    Lemma rhs_val : forall le m f ty rhs v1 v1', Gt le -> In (f, ty) ctl_fields -> rhs_ok f rhs = true ->
        (f = GI._buttonDown \/ f = GI._buttonPressed) ->
        eval_expr G empty_env le m rhs v1 -> sem_cast v1 (typeof rhs) ty m = Some v1' ->
        exists w, v1' = Vint w /\ Aclr w.
    Proof.
      intros le m f ty rhs v1 v1' (_ & _ & B & _) Hf Hok Hbd Hv Hc.
      rewrite (fty_us _ _ Hf Hbd) in Hc.
      assert (C0 : expr_eqb rhs (Econst_int (Int.repr 0) tint) = true -> exists w, v1' = Vint w /\ Aclr w).
      { intros E. apply expr_eqb_eq in E. subst rhs. apply ev_const in Hv. subst v1.
        cbn [typeof] in Hc. apply cast_i_us in Hc. subst v1'. eexists. split; reflexivity. }
      unfold rhs_ok in Hok. destruct Hbd as [-> | ->].
      - change (Pos.eqb GI._buttonDown GI._buttonPressed) with false in Hok.
        rewrite Pos.eqb_refl in Hok. apply orb_true_iff in Hok as [E | E]; [ | exact (C0 E) ].
        apply expr_eqb_eq in E. subst rhs. apply ev_tmp in Hv.
        lazymatch type of Hv with _ ! ?xid = Some _ =>
          destruct (B xid _ ltac:(cbn; tauto) Hv) as [-> | (n & -> & An)] end.
        + vcbn Hc. discriminate Hc.
        + cbn [typeof] in Hc. destruct (cast_us_us _ _ _ Hc) as (n' & E & ->). injection E as <-.
          eexists. split; [ reflexivity | unfold Aclr; rewrite and_A_zext16; exact An ].
      - rewrite Pos.eqb_refl in Hok. apply orb_true_iff in Hok as [E | E]; [ | exact (C0 E) ].
        destruct (bp_rhs_spec rhs E) as (b & -> & Eb').
        inv Hv; try solve [ inv_ev ].
        match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_tmp in Ht end.
        match goal with Hb : sem_binary_operation _ Oand _ _ _ _ _ = Some _ |- _ =>
          cbn [typeof] in Hb; rewrite Eb' in Hb; destruct (and_us _ _ _ _ _ Hb) as (n & c & -> & ->) end.
        lazymatch goal with Ht : _ ! GI._t'26 = Some _ |- _ =>
          destruct (B GI._t'26 _ ltac:(cbn; tauto) Ht) as [E2 | (n' & E2 & An)]; [ discriminate E2 | injection E2 as <- ] end.
        cbn [typeof] in Hc. apply cast_i_us in Hc. subst v1'.
        eexists. split; [ reflexivity | ]. unfold Aclr. rewrite and_A_zext16. exact (and_A_and _ _ An).
    Qed.

    Definition store_l (lv rhs : expr) : bool :=
      existsb (fun ft => expr_eqb lv (ctl_lv GI._controller (fst ft) (snd ft)) && rhs_ok (fst ft) rhs) ctl_fields.

    Lemma store_l_ok : forall j a1 a2 le m t le' m' out,
        store_l a1 a2 = true -> Gj j le ->
        exec_stmt function_entry2 G empty_env le m (Sassign a1 a2) t le' m' out -> Inv m -> Inv m'.
    Proof.
      intros j a1 a2 le m t le' m' out Hok (_ & Gl) Hx I.
      unfold store_l in Hok. apply existsb_exists in Hok as ([f ty] & Hf & E).
      apply andb_prop in E as (E & Er). apply expr_eqb_eq in E. cbn [fst snd] in E, Er. subst a1.
      eapply (ctl_assign _ _ _ _ _ _ _ _ _ _ Hf); [ | exact Hx | exact I ].
      intros v Hv. destruct Gl as (C & D & B).
      destruct (C v Hv) as [-> | [-> | ->]]; [ left; reflexivity | right; exists 0 | right; exists 1 ];
        (split; [ lia | split; [ reflexivity | ] ]).
      - intros _ Hbd v1 v1' Hv1 Hc. exact (rhs_val _ _ _ _ _ _ _ (conj C (conj D B)) Hf Er Hbd Hv1 Hc).
      - intros E. discriminate E.
    Qed.

    Definition adj_e : expr :=
      Evar GI._adjust_analog_stick (Tfunction [tptr (Tstruct GI._Controller noattr)] tvoid cc_default).
    Definition call_l (o : option ident) (a : expr) (al : list expr) : bool :=
      match o, al with
      | None, [x] => expr_eqb a adj_e && expr_eqb x (Etempvar GI._controller (tptr (Tstruct GI._Controller noattr)))
      | _, _ => false
      end.

    Lemma call_l_ok : forall j o a al le m t le' m' out,
        call_l o a al = true -> Gj j le ->
        exec_stmt function_entry2 G empty_env le m (Scall o a al) t le' m' out ->
        Inv m -> Inv m' /\ Gj j le'.
    Proof.
      intros j o a al le m t le' m' out Hok Gl Hx I.
      destruct o; [ discriminate Hok | ]. destruct al as [| x [| y al]]; try discriminate Hok.
      apply andb_prop in Hok as (E1 & E2). apply expr_eqb_eq in E1. apply expr_eqb_eq in E2. subst a x.
      destruct Gl as (Ei & C & D & B).
      destruct (le ! GI._controller) as [cv|] eqn:Ec.
      - destruct (C cv eq_refl) as [-> | [-> | ->]].
        + exfalso.
          destruct (LptBody.scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ Hx (PTree.gempty _ _) eq_refl)
            as (b & fd & tyargs & tyres & cc & vargs & vres & _ & _ & Hcl & Hel & _ & _ & _).
          cbn in Hcl. injection Hcl as <- <- <-. rename Hel into Hel0.
          inv Hel0.
          match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_tmp in Ht; rewrite Ec in Ht; injection Ht as <- end.
          match goal with Hcs : sem_cast Vundef _ _ _ = Some _ |- _ => vcbn Hcs; discriminate Hcs end.
        + destruct (adj_step _ _ _ _ _ _ 0 (or_introl eq_refl) Hx Ec I) as (I' & ->).
          split; [ exact I' | split; [ exact Ei | exact (conj (fun v Hv => C v (eq_trans (eq_sym Ec) Hv)) (conj D B)) ] ].
        + destruct (adj_step _ _ _ _ _ _ 1 (or_intror eq_refl) Hx Ec I) as (I' & ->).
          split; [ exact I' | split; [ exact Ei | exact (conj (fun v Hv => C v (eq_trans (eq_sym Ec) Hv)) (conj D B)) ] ].
      - exfalso.
          destruct (LptBody.scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ Hx (PTree.gempty _ _) eq_refl)
            as (b & fd & tyargs & tyres & cc & vargs & vres & _ & _ & Hcl & Hel & _ & _ & _).
          cbn in Hcl. injection Hcl as <- <- <-. rename Hel into Hel0.
        inv Hel0.
        match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_tmp in Ht; rewrite Ec in Ht; discriminate Ht end.
    Qed.

    Definition rci_body : statement := fn_body GI.f_read_controller_inputs.
    Definition rci_loopblk : statement :=
      match rci_body with Ssequence _ (Ssequence _ (Ssequence l _)) => l | _ => Sskip end.
    Definition rci_p3 : statement :=
      match rci_body with Ssequence _ (Ssequence _ (Ssequence _ p)) => p | _ => Sskip end.
    Definition rci_head : statement := match rci_body with Ssequence h _ => h | _ => Sskip end.
    Definition rci_demo : statement :=
      match rci_body with Ssequence _ (Ssequence d _) => d | _ => Sskip end.
    Definition rci_loop : statement := match rci_loopblk with Ssequence _ l => l | _ => Sskip end.
    Definition rci_i0 : statement := match rci_loopblk with Ssequence i _ => i | _ => Sskip end.
    Definition rci_s1 : statement := match rci_loop with Sloop a _ => a | _ => Sskip end.
    Definition rci_s2 : statement := match rci_loop with Sloop _ b => b | _ => Sskip end.
    Definition rci_bodyc : statement := match rci_s1 with Ssequence _ b => b | _ => Sskip end.
    Definition rci_cond : statement := match rci_s1 with Ssequence a _ => a | _ => Sskip end.

    Lemma rci_shape : rci_body = Ssequence rci_head (Ssequence rci_demo
                                   (Ssequence (Ssequence rci_i0 (Sloop rci_s1 rci_s2)) rci_p3)).
    Proof. reflexivity. Qed.
    Lemma s1_shape : rci_s1 = Ssequence rci_cond rci_bodyc.
    Proof. reflexivity. Qed.

    Lemma bodyc_chk : LptBody.cw_chk set_l store_l call_l rci_bodyc = true.
    Proof. vm_compute. reflexivity. Qed.

    Lemma bodyc_walk : forall j, (j = 0 \/ j = 1) -> forall le m t le' m' out,
        exec_stmt function_entry2 G empty_env le m rci_bodyc t le' m' out ->
        Gj j le -> Inv m -> Inv m' /\ Gj j le'.
    Proof.
      intros j Hj le m t le' m' out Hx Gl I.
      exact (LptBody.cw_walk G empty_env Inv (Gj j) set_l store_l call_l
               (fun id a le0 m0 v Hok Hg Hf Hv => set_l_ok j Hj id a le0 m0 v Hok Hg Hf Hv)
               (fun a1 a2 le0 m0 t0 le0' m0' out0 Hok Hg Hx0 Hf => store_l_ok j a1 a2 le0 m0 t0 le0' m0' out0 Hok Hg Hx0 Hf)
               (fun o a al le0 m0 t0 le0' m0' out0 Hok Hg Hx0 Hf => call_l_ok j o a al le0 m0 t0 le0' m0' out0 Hok Hg Hx0 Hf)
               _ _ _ _ _ _ _ _ Hx eq_refl bodyc_chk Gl I).
    Qed.

    (* ---- the loop over gControllers[0..1] ---- *)
    Definition LI (j : Z) (le : temp_env) (m : mem) : Prop := 0 <= j <= 2 /\ Gj j le /\ Inv m.

    Lemma lt2 : forall ce j mm v b, 0 <= j <= 2 ->
        sem_binary_operation ce Olt (Vint (Int.repr j)) tint (Vint (Int.repr 2)) tint mm = Some v ->
        bool_val v tint mm = Some b -> b = (j <? 2).
    Proof.
      intros ce j mm v b Hj H Hb.
      assert (K : j = 0 \/ j = 1 \/ j = 2) by lia.
      destruct K as [-> | [-> | ->]]; vcbn H; injection H as <-; vcbn Hb; injection Hb as <-; reflexivity.
    Qed.

    Lemma tracked_ne : forall x, (x = GI._controller \/ In x T_cd \/ In x T_btn \/ In x T3) ->
        x <> GI._i /\ x <> GI._t'34.
    Proof.
      intros x H.
      destruct H as [-> | [H | [H | H]]];
        [ split; intros E; vm_compute in E; discriminate E
        | unfold T_cd in H | unfold T_btn in H | unfold T3 in H ];
        repeat (destruct H as [<- | H]; [ split; intros E; vm_compute in E; discriminate E | ]);
        destruct H.
    Qed.

    Lemma Gt_set_untracked : forall le id v, Gt le ->
        ~ (id = GI._controller \/ In id T_cd \/ In id T_btn \/ In id T3) -> Gt (PTree.set id v le).
    Proof.
      intros le id v Gl N. apply (Gt_set _ _ _ Gl); intros H; exfalso; apply N; tauto.
    Qed.

    Lemma s1_ok : forall j le m t le1 m1 out1, LI j le m ->
        exec_stmt function_entry2 G empty_env le m rci_s1 t le1 m1 out1 ->
        LI j le1 m1 /\ (out1 = Out_break \/ (out1 = Out_normal /\ j < 2)).
    Proof.
      intros j le m t le1 m1 out1 (Rj & (Ei & Gl) & I) H.
      assert (COND : forall t' le' m' o',
                 exec_stmt function_entry2 G empty_env le m rci_cond t' le' m' o' ->
                 le' = le /\ m' = m /\ ((o' = Out_normal /\ j < 2) \/ o' = Out_break)).
      { intros t' le' m' o' Hc.
        cbn [rci_cond rci_s1 rci_loop rci_loopblk rci_body GI.f_read_controller_inputs fn_body] in Hc.
        inv Hc. inv_ev. rtemp.
        match goal with Hb : sem_binary_operation _ Olt _ _ _ _ _ = Some ?v, Hv : bool_val ?v _ _ = Some ?b |- _ =>
          pose proof (lt2 _ _ _ _ _ Rj Hb Hv) as Eb; subst b end.
        match goal with Hx : exec_stmt _ _ _ _ _ (if ?c then _ else _) _ _ _ _ |- _ =>
          revert Hx; destruct c eqn:L; intro Hx; cbv beta iota in Hx; inv Hx end.
        - apply Z.ltb_lt in L. split; [ reflexivity | split; [ reflexivity | left; split; [ reflexivity | exact L ] ] ].
        - split; [ reflexivity | split; [ reflexivity | right; reflexivity ] ]. }
      rewrite s1_shape in H. inv H.
      - match goal with Hc : exec_stmt _ _ _ _ _ rci_cond _ _ _ _ |- _ =>
          destruct (COND _ _ _ _ Hc) as (-> & -> & [(_ & Lj) | E]); [ | discriminate E ] end.
        match goal with Hb : exec_stmt _ _ _ _ _ rci_bodyc _ _ _ _ |- _ =>
          pose proof (simple_normal' _ _ _ _ _ _ _ _ Hb eq_refl) as En;
          destruct (bodyc_walk j ltac:(lia) _ _ _ _ _ _ Hb (conj Ei Gl) I) as (I' & G') end.
        split; [ split; [ exact Rj | split; [ exact G' | exact I' ] ] | right; split; [ exact En | exact Lj ] ].
      - match goal with Hc : exec_stmt _ _ _ _ _ rci_cond _ _ _ _ |- _ =>
          destruct (COND _ _ _ _ Hc) as (-> & -> & [(-> & _) | ->]) end.
        + congruence.
        + split; [ split; [ exact Rj | split; [ exact (conj Ei Gl) | exact I ] ] | left; reflexivity ].
    Qed.

    Lemma s2_ok : forall j le m t le' m' out, j < 2 -> LI j le m ->
        exec_stmt function_entry2 G empty_env le m rci_s2 t le' m' out ->
        out = Out_normal /\ LI (j + 1) le' m'.
    Proof.
      intros j le m t le' m' out Lj (Rj & (Ei & Gl) & I) H.
      cbn [rci_s2 rci_loop rci_loopblk rci_body GI.f_read_controller_inputs fn_body] in H.
      inv H. inv_ev. rtemp.
      match goal with Hb : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
        apply (add_int_k _ j _ _ ltac:(lia)) in Hb; subst end.
      split; [ reflexivity | ].
      split; [ lia | split; [ split; [ apply PTree.gss | ] | exact I ] ].
      apply (Gt_set_untracked _ _ _ Gl). intros Ht. exact (proj1 (tracked_ne _ Ht) eq_refl).
    Qed.

    Lemma loop_ok : forall e le m S t le' m' out,
        exec_stmt function_entry2 G e le m S t le' m' out ->
        e = empty_env -> S = Sloop rci_s1 rci_s2 ->
        forall j, LI j le m -> out = Out_normal /\ exists j', LI j' le' m'.
    Proof.
      intros e le m S t le' m' out H.
      induction H; intros Ee ES; try discriminate ES; injection ES as -> ->; subst e; intros j I.
      - match goal with Hx : exec_stmt _ _ _ _ _ rci_s1 _ _ _ _ |- _ =>
          destruct (s1_ok _ _ _ _ _ _ _ I Hx) as (I1 & [-> | (-> & _)]) end;
        match goal with Hb : out_break_or_return _ _ |- _ => inv Hb end.
        split; [ reflexivity | exists j; exact I1 ].
      - match goal with Hx : exec_stmt _ _ _ _ _ rci_s2 _ _ _ ?o2, Hb : out_break_or_return ?o2 _ |- _ =>
          rewrite (simple_normal' _ _ _ _ _ _ _ _ Hx eq_refl) in Hb; inv Hb end.
      - match goal with Hx : exec_stmt _ _ _ _ _ rci_s1 _ _ _ _ |- _ =>
          destruct (s1_ok _ _ _ _ _ _ _ I Hx) as (I1 & [-> | (-> & Lj)]) end.
        + match goal with Hb : out_normal_or_continue _ |- _ => inv Hb end.
        + match goal with Hx : exec_stmt _ _ _ _ _ rci_s2 _ _ _ _ |- _ =>
            destruct (s2_ok j _ _ _ _ _ _ Lj I1 Hx) as (_ & I2) end.
          match goal with IH : empty_env = empty_env -> _ |- _ => exact (IH eq_refl eq_refl _ I2) end.
    Qed.

    (* ---- the player-3 copy: gPlayer3Controller (= &gControllers[2]) := player 1 ---- *)
    Definition p3_e : expr := Evar GI._gPlayer3Controller (tptr (Tstruct GI._Controller noattr)).
    Definition set_3 (id : ident) (a : expr) : bool :=
      if existsb (Pos.eqb id) T3 then expr_eqb a p3_e else true.
    Definition store_3 (lv rhs : expr) : bool :=
      existsb (fun p => existsb (fun ft => expr_eqb lv (ctl_lv p (fst ft) (snd ft))) ctl_fields) T3.
    Definition call_3 (o : option ident) (a : expr) (al : list expr) : bool := false.

    Lemma p3_chk : LptBody.cw_chk set_3 store_3 call_3 rci_p3 = true.
    Proof. vm_compute. reflexivity. Qed.

    Lemma set_3_ok : forall id a le m v, set_3 id a = true -> G3 le -> Inv m ->
        eval_expr G empty_env le m a v -> G3 (PTree.set id v le).
    Proof.
      intros id a le m v Hok Gl (U & _) Hv x w Hx Hw.
      destruct (peq x id) as [-> | N].
      - rewrite PTree.gss in Hw. injection Hw as <-.
        unfold set_3 in Hok. rewrite (in_ex _ _ Hx) in Hok. apply expr_eqb_eq in Hok. subst a.
        destruct (ev_gvar' G _ _ _ _ _ _ Mint32 (PTree.gempty _ _) Hv eq_refl eq_refl) as (b & Sb & L).
        rewrite Hp3 in Sb. injection Sb as <-.
        rewrite (Uc_load m Mint32 bp3 0 U (vsym _ _ Hp3)) in L.
        + rewrite Hp3v in L. injection L as <-. right. reflexivity.
        + intros i _. apply Fr_far; [ ne Hp3 Hq | ne Hp3 Hrm | ne Hp3 Hpads | ne Hp3 Hbc ].
      - rewrite PTree.gso in Hw by exact N. exact (Gl x w Hx Hw).
    Qed.

    Lemma store_3_ok : forall a1 a2 le m t le' m' out,
        store_3 a1 a2 = true -> G3 le ->
        exec_stmt function_entry2 G empty_env le m (Sassign a1 a2) t le' m' out -> Inv m -> Inv m'.
    Proof.
      intros a1 a2 le m t le' m' out Hok Gl Hx I.
      unfold store_3 in Hok. apply existsb_exists in Hok as (p & Hp & Hok).
      apply existsb_exists in Hok as ([f ty] & Hf & E). apply expr_eqb_eq in E. cbn [fst snd] in E. subst a1.
      eapply (ctl_assign _ _ _ _ _ _ _ _ _ _ Hf); [ | exact Hx | exact I ].
      intros v Hv. destruct (Gl p v Hp Hv) as [-> | ->]; [ left; reflexivity | right; exists 2 ].
      split; [ lia | split; [ reflexivity | intros E; discriminate E ] ].
    Qed.

    Lemma p3_walk : forall le m t le' m' out,
        exec_stmt function_entry2 G empty_env le m rci_p3 t le' m' out -> G3 le -> Inv m -> Inv m'.
    Proof.
      intros le m t le' m' out Hx Gl I.
      exact (proj1 (LptBody.cw_walk G empty_env Inv G3 set_3 store_3 call_3 set_3_ok store_3_ok
                      (fun o a al le0 m0 t0 le0' m0' out0 Hok => ltac:(discriminate Hok))
                      _ _ _ _ _ _ _ _ Hx eq_refl p3_chk Gl I)).
    Qed.

    (* ---- run_demo_inputs: masks gControllers[0]'s pad buttons; the demo
       pointer is NULL (gCurrDemoInput, ctl_w), so nothing else ---- *)
    Hypothesis Hdmv : Mem.load Mint32 mi bdm 0 = Some (Vint Int.zero).

    Lemma ne_null : forall ce t1 t2 mm v b,
        sem_binary_operation ce One (Vint Int.zero) (tptr t1) (Vint (Int.repr 0)) (tptr t2) mm = Some v ->
        bool_val v tint mm = Some b -> b = false.
    Proof. intros ce t1 t2 mm v b H Hb. vcbn H. injection H as <-. vcbn Hb. injection Hb as <-. reflexivity. Qed.

    Lemma cd0_load : forall le m v, Inv m ->
        eval_expr G empty_env le m
          (Efield (Ederef (Ebinop Oadd (Evar GI._gControllers (tarray (Tstruct GI._Controller noattr) 3))
                                     (Econst_int (Int.repr 0) tint) (tptr (Tstruct GI._Controller noattr)))
                          (Tstruct GI._Controller noattr)) GI._controllerData (tptr (Tstruct GI.__319 noattr))) v ->
        Mem.load Mint32 m bc 24 = Some v.
    Proof.
      intros le m v I H.
      destruct (fld_load' G _ _ _ _ _ _ _ _ _ Mint32 24 (fc _ _ fo_c_cd) H eq_refl eq_refl) as (loc & o0 & Ha & L).
      pose proof (ev_ctl _ _ _ 0 _ (fun v' Hc => ev_const G _ _ _ _ _ _ Hc) ltac:(lia) Ha eq_refl) as E.
      injp E. rewrite u_ofs in L by lia. exact L.
    Qed.

    Lemma cd_class0 : forall m v, Inv m -> Mem.load Mint32 m bc 24 = Some v ->
        v = Vint Int.zero \/ exists k, 0 <= k < 4 /\ v = Vptr bpads (Ptrofs.repr (6 * k)).
    Proof.
      intros m v (U & _) L.
      rewrite (Uc_load m Mint32 bc 24 U (vsym _ _ Hbc)) in L.
      - destruct (Hcd 0 (or_introl eq_refl)) as [L0 | (k & Hk & L0)]; change (28 * 0 + 24) with 24 in L0;
          rewrite L0 in L; injs L; [ left; reflexivity | right; exists k; split; [ exact Hk | reflexivity ] ].
      - intros i Hi. cbn [size_chunk] in Hi.
        split; [ ne Hbc Hq | split; [ ne Hbc Hrm | split; [ ne Hbc Hpads | right; left; lia ] ] ].
    Qed.

    Lemma rd_ok : forall m t m' vres,
        eval_funcall function_entry2 G m (Internal GI.f_run_demo_inputs) [] t m' vres ->
        Inv m -> Inv m'.
    Proof.
      intros m t m' vres Hev I.
      inv Hev.
      match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
      match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars GI.f_run_demo_inputs) with (@nil (ident * type)) in Ha; inv Ha end.
      match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
        cbn [GI.f_run_demo_inputs fn_params bind_parameter_temps] in Hb; injection Hb as <- end.
      match goal with Hfr : Mem.free_list _ _ = Some _ |- _ =>
        change (blocks_of_env G empty_env) with (@nil (block * Z * Z)) in Hfr;
        cbn [Mem.free_list] in Hfr; injection Hfr as Hfr; subst end.
      repeat match goal with Hn : list_norepet _ |- _ => clear Hn | Hd : list_disjoint _ _ |- _ => clear Hd end.
      match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into H end.
      try rename m1 into m00. try rename m2 into m02. try rename le2 into le02. try rename m3 into m03.
      cbn [GI.f_run_demo_inputs fn_body] in H.
      apply seq_inv in H as (t1 & le1 & m1 & t2 & Hm & H); [ | reflexivity ].
      apply seq_inv in Hm as (t3 & le3 & m3 & t4 & Hs32 & Hm); [ | reflexivity ].
      apply seq_inv in Hm as (t5 & le5 & m5 & t6 & Hs33 & Hm); [ | reflexivity ].
      apply seq_inv in Hm as (t7 & le7 & m7 & t8 & Hs34 & Hasg); [ | reflexivity ].
      inv Hs32. inv Hs33. inv Hs34.
      match goal with H1 : eval_expr _ _ ?l1 _ (Efield _ GI._controllerData _) ?v1,
                      H2 : eval_expr _ _ (PTree.set _ ?v1 ?l1) _ (Efield _ GI._controllerData _) ?v2 |- _ =>
        pose proof (cd0_load _ _ _ I H1) as L1; pose proof (cd0_load _ _ _ I H2) as L2 end.
      rewrite L1 in L2. injection L2 as <-.
      destruct (cd_class0 _ _ I L1) as [-> | (k & Hk & ->)].
      - (* a NULL pad pointer: the read gets stuck *)
        exfalso.
        match goal with Hv : eval_expr _ _ _ _ (Efield (Ederef (Etempvar _ _) _) GI._button _) _ |- _ =>
          destruct (fld_load' G _ _ _ _ _ _ _ _ _ Mint16unsigned 0 (fp _ _ fo_p_btn) Hv eq_refl eq_refl)
            as (loc & o0 & Ha & _) end.
        apply ev_tmp in Ha. tgetH Ha. discriminate Ha.
      - match goal with Hv : eval_expr _ _ _ _ (Efield (Ederef (Etempvar _ _) _) GI._button _) _ |- _ =>
          destruct (fld_load' G _ _ _ _ _ _ _ _ _ Mint16unsigned 0 (fp _ _ fo_p_btn) Hv eq_refl eq_refl)
            as (loc & o0 & Ha & L34) end.
        apply ev_tmp in Ha. tgetH Ha. injv Ha.
        rewrite u_ofs in L34 by lia. rewrite Z.add_0_r in L34.
        destruct (fld_store' G _ _ _ _ _ _ _ _ _ _ _ _ _ Mint16unsigned 0 (fp _ _ fo_p_btn) Hasg eq_refl eq_refl)
          as (-> & _ & _ & loc2 & o2 & w & w' & Ha2 & Hr & Hc & St).
        apply ev_tmp in Ha2. tgetH Ha2. injv Ha2.
        rewrite u_ofs in St by lia. rewrite Z.add_0_r in St.
        (* one inversion only: the mask is a 15-deep constant OR tree, whose
           value we do not need (and_us) *)
        inv Hr; try (match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
                       solve [ inv Hl ] end).
        match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_tmp in Ht; tgetH Ht; injection Ht as <- end.
        match goal with Hb : sem_binary_operation _ Oand _ _ _ _ _ = Some _ |- _ =>
          cbn [typeof] in Hb; destruct (and_us _ _ _ _ _ Hb) as (n & c & -> & ->) end.
        repeat match goal with Ht : eval_expr _ _ _ _ (Ebinop Oor _ _ _) _ |- _ => clear Ht end.
        cbn [typeof] in Hc. apply cast_i_us in Hc. subst w'.
        destruct I as (U & P & B).
        assert (An : Aclr (Int.and n c)) by exact (and_A_and _ _ (P k n Hk L34)).
        assert (Nbp : bc <> bpads) by ne Hbc Hpads.
        assert (I7 : Inv m1).
        { split; [ | split ].
          - eapply Mem.unchanged_on_trans; [ exact U | ].
            eapply Mem.store_unchanged_on; [ exact St | intros i _ (_ & _ & _ & N & _); exact (N eq_refl) ].
          - exact (pads_store_btn _ _ _ _ Hk St An P).
          - intros z Hz. destruct (B z Hz) as (x & Lx & Ax). exists x. split; [ | exact Ax ].
            rewrite <- Lx. apply (Mem.load_store_other _ _ _ _ _ _ St). left. exact Nbp. }
        (* if (gCurrDemoInput != NULL) ... : it is NULL *)
        apply seq_inv in H as (t9 & le9 & m9 & t10 & Hs2 & Hif); [ | reflexivity ].
        inv Hs2.
        match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
          destruct (ev_gvar' G _ _ _ _ _ _ Mint32 (PTree.gempty _ _) Hv eq_refl eq_refl) as (b & Sb & L2) end.
        rewrite Hdm in Sb. injection Sb as <-.
        rewrite (Uc_load _ Mint32 bdm 0 (proj1 I7) (vsym _ _ Hdm)) in L2
          by (intros i _; apply Fr_far; [ ne Hdm Hq | ne Hdm Hrm | ne Hdm Hpads | ne Hdm Hbc ]).
        rewrite Hdmv in L2. injection L2 as <-.
        inv Hif. inv_ev.
        repeat match goal with Hx : (PTree.set _ _ _) ! _ = Some _ |- _ => tgetH Hx end.
        match goal with Hx : Some ?a = Some ?b |- _ => injection Hx as Hx; subst b end.
        match goal with Hcs : sem_cast _ _ _ _ = Some _ |- _ => vcbn Hcs; injection Hcs as <- end.
        match goal with Hb : sem_binary_operation _ One _ _ _ _ _ = Some ?v, Hv : bool_val ?v _ _ = Some ?bb |- _ =>
          pose proof (ne_null _ _ _ _ _ _ Hb Hv) as Eb; subst bb end.
        repeat match goal with
          | Hx : exec_stmt _ _ _ _ _ (if _ then _ else _) _ _ _ _ |- _ => progress (cbv beta iota in Hx)
          | Hx : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hx
          end.
        exact I7.
    Qed.

    (* ---- the head: if (gControllerBits) { osRecvMesg(...); osContGetReadData(gControllerPads); } ---- *)
    Hypothesis Hportmi : forall k, 0 <= k < 4 -> port_a mi bpif k = false.
    Hypothesis Hmaxmi : forall x, Mem.load Mint8unsigned mi bmx 0 = Some (Vint x) -> Int.unsigned x <= 4.
    Hypothesis Hpacmi : pads_ac mi.
    Hypothesis Hbtnmi : btn_ok mi.

    Lemma Fr_pif : forall z, Fr bpif z.
    Proof. intros z. apply Fr_far; [ ne Hpif Hq | ne Hpif Hrm | ne Hpif Hpads | ne Hpif Hbc ]. Qed.
    Lemma Fr_mx : forall z, Fr bmx z.
    Proof. intros z. apply Fr_far; [ ne Hmx Hq | ne Hmx Hrm | ne Hmx Hpads | ne Hmx Hbc ]. Qed.

    Lemma port_keep : forall m k, Uc m -> port_a m bpif k = port_a mi bpif k.
    Proof.
      intros m k U. unfold port_a.
      rewrite (Uc_load m Mint16unsigned bpif _ U (vsym _ _ Hpif)) by (intros; apply Fr_pif).
      rewrite (Uc_load m Mint8unsigned bpif _ U (vsym _ _ Hpif)) by (intros; apply Fr_pif).
      reflexivity.
    Qed.

    Lemma recv_inv : forall m m', Mem.unchanged_on (fun b z => b <> bq /\ b <> brm) m m' -> Inv m -> Inv m'.
    Proof.
      intros m m' Ur (U & P & B).
      assert (Vbp : Mem.valid_block m bpads) by exact (Uc_valid m bpads U (vsym _ _ Hpads)).
      assert (Vbc : Mem.valid_block m bc) by exact (Uc_valid m bc U (vsym _ _ Hbc)).
      split; [ | split ].
      - eapply Mem.unchanged_on_trans; [ exact U | ].
        eapply Mem.unchanged_on_implies; [ exact Ur | ].
        intros b z (_ & N1 & N2 & _) _. split; assumption.
      - intros k n Hk Hl. apply (P k n Hk). rewrite <- Hl. symmetry.
        eapply Mem.load_unchanged_on_1; [ exact Ur | exact Vbp | ].
        intros i _. split; [ ne Hpads Hq | ne Hpads Hrm ].
      - intros z Hz. destruct (B z Hz) as (w & Lw & Aw). exists w. split; [ | exact Aw ].
        rewrite <- Lw. eapply Mem.load_unchanged_on_1; [ exact Ur | exact Vbc | ].
        intros i _. split; [ ne Hbc Hq | ne Hbc Hrm ].
    Qed.

    Lemma grd_inv2 : forall m m', Mem.unchanged_on (fun b z => Mem.valid_block m b /\ b <> bpads) m m' ->
        pads_ac m' -> Inv m -> Inv m'.
    Proof.
      intros m m' Ug Pg (U & P & B).
      assert (Vbc : Mem.valid_block m bc) by exact (Uc_valid m bc U (vsym _ _ Hbc)).
      assert (Nbp : bc <> bpads) by ne Hbc Hpads.
      split; [ | split; [ exact Pg | ] ].
      - eapply Mem.unchanged_on_trans; [ exact U | ].
        eapply Mem.unchanged_on_implies; [ exact Ug | ].
        intros b z (Vi & _ & _ & N3 & _) _. split; [ exact (Uc_valid m b U Vi) | exact N3 ].
      - intros z Hz. destruct (B z Hz) as (w & Lw & Aw). exists w. split; [ | exact Aw ].
        rewrite <- Lw. eapply Mem.load_unchanged_on_1; [ exact Ug | exact Vbc | ].
        intros i _. split; [ exact Vbc | exact Nbp ].
    Qed.

    Lemma head_ok : forall le m t le' m' out,
        exec_stmt function_entry2 G empty_env le m rci_head t le' m' out -> Inv m ->
        Inv m' /\ exists v, le' = PTree.set GI._t'34 v le.
    Proof.
      intros le m t le' m' out H I.
      cbn [rci_head rci_body GI.f_read_controller_inputs fn_body] in H.
      apply seq_inv in H as (t1 & le1 & m1 & t2 & Hs & Hif); [ | reflexivity ].
      inv Hs. inv Hif.
      match goal with Hx : exec_stmt _ _ _ _ _ (if ?c then _ else _) _ _ _ _ |- _ =>
        revert Hx; destruct c; intro Hx; cbv beta iota in Hx;
        [ rename Hx into H | inv Hx; split; [ exact I | eexists; reflexivity ] ] end.
      apply seq_inv in H as (t3 & le3 & m3 & t4 & Hr & Hg); [ | reflexivity ].
      destruct (recv_step _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hr eq_refl eq_refl eq_refl) as (-> & Ur).
      pose proof (recv_inv _ _ Ur I) as I3.
      destruct (LptBody.scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ Hg (PTree.gempty _ _) eq_refl)
        as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hfd & Hcl & Hel & Hev & -> & ->).
      rewrite (resolve _ _ _ _ _ LO_cr dm_grd Hs Hfd) in Hev.
      cbn in Hcl. injection Hcl as <- <- <-.
      inv Hel. match goal with Hl : eval_exprlist _ _ _ _ [] _ _ |- _ => inv Hl end.
      match goal with Hv : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hv; try solve [ inv_ev ] end.
      match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        destruct (ev_var_ref' _ _ _ _ _ _ Hv eq_refl (PTree.gempty _ _)) as (bp & Sp & ->) end.
      rewrite Hpads in Sp. injection Sp as <-.
      inv_ev.
      match goal with Hb : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
        cbn [typeof] in Hb; apply (add_arr_int _ _ _ _ 6 _ _ _ _ _ sz319) in Hb; subst end.
      match goal with Hcs : sem_cast _ _ _ _ = Some _ |- _ => apply cast_pp in Hcs; subst end.
      change (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr 6) (Ptrofs.of_ints (Int.repr 0))))
        with Ptrofs.zero in Hev.
      destruct I3 as (U3 & P3 & B3).
      destruct (grd_ok _ _ _ _ Hev (Uc_valid _ _ U3 (vsym _ _ Hpads)) (Uc_valid _ _ U3 (vsym _ _ Hpif))
                  (Uc_valid _ _ U3 (vsym _ _ Hmx))
                  (fun k Hk => eq_trans (port_keep _ k U3) (Hportmi k Hk))
                  (fun x Hl => Hmaxmi x (eq_trans (eq_sym (Uc_load _ _ _ _ U3 (vsym _ _ Hmx)
                                                             (fun i _ => Fr_mx i))) Hl))
                  P3) as (Ug & Pg).
      split; [ exact (grd_inv2 _ _ Ug Pg (conj U3 (conj P3 B3))) | eexists; reflexivity ].
    Qed.

    Lemma gt_undef : forall le,
        (forall x v, (x = GI._controller \/ In x T_cd \/ In x T_btn \/ In x T3) -> le ! x = Some v -> v = Vundef) ->
        Gt le.
    Proof.
      intros le K.
      split; [ intros v H; left; exact (K _ _ (or_introl eq_refl) H) | ].
      split; [ intros x v Hx H; left; exact (K x v (or_intror (or_introl Hx)) H) | ].
      split; [ intros x v Hx H; left; exact (K x v (or_intror (or_intror (or_introl Hx))) H) | ].
      intros x v Hx H; left; exact (K x v (or_intror (or_intror (or_intror Hx))) H).
    Qed.

    Lemma lb_ok : forall le0 v34 m3 t5 le5 m5 out5,
        (forall x v, le0 ! x = Some v -> v = Vundef) -> Inv m3 ->
        exec_stmt function_entry2 G empty_env (PTree.set GI._t'34 v34 le0) m3
          (Ssequence rci_i0 (Sloop rci_s1 rci_s2)) t5 le5 m5 out5 ->
        out5 = Out_normal /\ exists j, LI j le5 m5.
    Proof.
      intros le0 v34 m3 t5 le5 m5 out5 K I3 Hlb.
      apply seq_inv in Hlb as (t6 & le6 & m6 & t7 & Hi0 & Hloop); [ | reflexivity ].
      cbn [rci_i0 rci_loopblk rci_body GI.f_read_controller_inputs fn_body] in Hi0.
      inv Hi0. inv_ev.
      match type of I3 with Inv ?mm =>
        assert (L0 : LI 0 (PTree.set GI._i (Vint (Int.repr 0)) (PTree.set GI._t'34 v34 le0)) mm) end.
      { split; [ lia | split; [ split; [ apply PTree.gss | ] | exact I3 ] ].
        apply gt_undef. intros x v Hx Hl. destruct (tracked_ne x Hx) as (N1 & N2).
        rewrite PTree.gso in Hl by exact N1. rewrite PTree.gso in Hl by exact N2.
        exact (K _ _ Hl). }
      exact (loop_ok _ _ _ _ _ _ _ _ Hloop eq_refl eq_refl 0 L0).
    Qed.

    (* read_controller_inputs keeps the frame, the pads' and Mario's
       controller's A-freedom *)
    Lemma rci_ok : forall t m0 vres,
        eval_funcall function_entry2 G mi (Internal GI.f_read_controller_inputs) [] t m0 vres -> Inv m0.
    Proof.
      intros t m0 vres Hev.
      assert (I0 : Inv mi) by (split; [ apply Mem.unchanged_on_refl | split; [ exact Hpacmi | exact Hbtnmi ] ]).
      inv Hev.
      match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
      match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars GI.f_read_controller_inputs) with (@nil (ident * type)) in Ha; inv Ha end.
      match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
        cbn [GI.f_read_controller_inputs fn_params bind_parameter_temps] in Hb; injection Hb as <- end.
      match goal with Hfr : Mem.free_list _ _ = Some _ |- _ =>
        change (blocks_of_env G empty_env) with (@nil (block * Z * Z)) in Hfr;
        cbn [Mem.free_list] in Hfr; injection Hfr as Hfr; subst end.
      repeat match goal with Hn : list_norepet _ |- _ => clear Hn | Hd : list_disjoint _ _ |- _ => clear Hd end.
      match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into H end.
      try rename m1 into m00. try rename m2 into m02. try rename le2 into le02. try rename m3 into m03.
      change (fn_body GI.f_read_controller_inputs) with rci_body in H. rewrite rci_shape in H.
      apply seq_inv in H as (t1 & le1 & m1 & t2 & Hh & H); [ | reflexivity ].
      destruct (head_ok _ _ _ _ _ _ Hh I0) as (I1 & v34 & ->).
      apply seq_inv in H as (t3 & le3 & m3 & t4 & Hd & H); [ | reflexivity ].
      cbn [rci_demo rci_body GI.f_read_controller_inputs fn_body] in Hd.
      destruct (LptBody.scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ Hd (PTree.gempty _ _) eq_refl)
        as (b & fd & tyargs & tyres & cc & vargs & vres' & Hs & Hfd & Hcl & Hel & Hrd & -> & _).
      rewrite (resolve _ _ _ _ _ LO_gi dm_rd Hs Hfd) in Hrd.
      inv Hel.
      pose proof (rd_ok _ _ _ _ Hrd I1) as I3.
      assert (LB : forall t5 le5 m5 out5,
                 exec_stmt function_entry2 G empty_env
                   (PTree.set GI._t'34 v34 (create_undef_temps (fn_temps GI.f_read_controller_inputs))) m3
                   (Ssequence rci_i0 (Sloop rci_s1 rci_s2)) t5 le5 m5 out5 ->
                 out5 = Out_normal /\ exists j, LI j le5 m5)
        by (intros; eapply lb_ok; [ | exact I3 | eassumption ]; intros x v Hl; exact (LptBody.undef_temps_get _ _ _ Hl)).
      inv H.
      - match goal with Hlb : exec_stmt _ _ _ _ _ (Ssequence rci_i0 _) _ _ _ _ |- _ =>
          destruct (LB _ _ _ _ Hlb) as (_ & j & (_ & (_ & (_ & _ & _ & T3')) & I5)) end.
        match goal with Hp : exec_stmt _ _ _ _ _ rci_p3 _ _ _ _ |- _ => exact (p3_walk _ _ _ _ _ _ Hp T3' I5) end.
      - match goal with Hlb : exec_stmt _ _ _ _ _ (Ssequence rci_i0 _) _ _ _ _ |- _ =>
          destruct (LB _ _ _ _ Hlb) as (-> & _) end.
        congruence.
    Qed.

    (* ---- what the poll exports: the controller cells after it (ctl_w) ---- *)
    Hypothesis Hp1v : Mem.load Mint32 mi bp1 0 = Some (Vptr bc Ptrofs.zero).

    Lemma poll_core : forall t m0 vres,
        eval_funcall function_entry2 G mi (Internal GI.f_read_controller_inputs) [] t m0 vres ->
        Uc m0 /\ btn_ok m0 /\ ctl_w G m0.
    Proof.
      intros t m0 vres Hev.
      destruct (rci_ok t m0 vres Hev) as (U & P & B).
      split; [ exact U | split; [ exact B | ] ].
      intros bc' bp' Sc Sp.
      rewrite Hbc in Sc. injection Sc as <-.
      rewrite Hpads in Sp. injection Sp as <-.
      split; [ | split; [ exact B | split; [ exact P | split; [ | split; [ | split ] ] ] ] ].
      - intros j Hj.
        assert (Ej : forall i, 28 * j + 24 <= i < 28 * j + 24 + size_chunk Mint32 -> Fr bc i).
        { intros i Hi. cbn [size_chunk] in Hi.
          split; [ ne Hbc Hq | split; [ ne Hbc Hrm | split; [ ne Hbc Hpads | right ] ] ].
          destruct Hj as [-> | ->]; lia. }
        rewrite (Uc_load m0 Mint32 bc _ U (vsym _ _ Hbc) Ej). exact (Hcd j Hj).
      - intros b1 S1. rewrite Hp1 in S1. injection S1 as <-.
        rewrite (Uc_load m0 Mint32 bp1 0 U (vsym _ _ Hp1))
          by (intros; apply Fr_far; [ ne Hp1 Hq | ne Hp1 Hrm | ne Hp1 Hpads | ne Hp1 Hbc ]).
        exact Hp1v.
      - intros b3 S3. rewrite Hp3 in S3. injection S3 as <-.
        rewrite (Uc_load m0 Mint32 bp3 0 U (vsym _ _ Hp3))
          by (intros; apply Fr_far; [ ne Hp3 Hq | ne Hp3 Hrm | ne Hp3 Hpads | ne Hp3 Hbc ]).
        exact Hp3v.
      - intros bd Sd. rewrite Hdm in Sd. injection Sd as <-.
        rewrite (Uc_load m0 Mint32 bdm 0 U (vsym _ _ Hdm))
          by (intros; apply Fr_far; [ ne Hdm Hq | ne Hdm Hrm | ne Hdm Hpads | ne Hdm Hbc ]).
        exact Hdmv.
      - intros bx Sx x Lx. rewrite Hmx in Sx. injection Sx as <-.
        apply Hmaxmi. rewrite <- Lx. symmetry.
        apply (Uc_load m0 Mint8unsigned bmx 0 U (vsym _ _ Hmx)). intros; apply Fr_mx.
    Qed.
  End WALK.

End RCI.

(* ---------------------------------------------------------------------- *)
(* 4. THE POLL ROW, on the link: read_controller_inputs from a memory      *)
(*    whose PIF reply shows A on no live port keeps GOAL 1's carried       *)
(*    facts, leaves Mario's controller A-free (pressed and held), and      *)
(*    re-establishes the controller cells (ctl_w) the next poll reads.     *)
(* ---------------------------------------------------------------------- *)

Lemma dm_pads : (prog_defmap GI.prog) ! GI._gControllerPads = Some (Gvar GI.v_gControllerPads).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_q : (prog_defmap GI.prog) ! save_file._gSIEventMesgQueue = Some (Gvar GI.v_gSIEventMesgQueue).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_rm : (prog_defmap GI.prog) ! memory._gMainReceivedMesg = Some (Gvar GI.v_gMainReceivedMesg).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_p1 : (prog_defmap GI.prog) ! GI._gPlayer1Controller = Some (Gvar GI.v_gPlayer1Controller).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_p3 : (prog_defmap GI.prog) ! GI._gPlayer3Controller = Some (Gvar GI.v_gPlayer3Controller).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_dm : (prog_defmap GI.prog) ! GI._gCurrDemoInput = Some (Gvar GI.v_gCurrDemoInput).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_pif : (prog_defmap CR.prog) ! CI.___osContPifRam = Some (Gvar CR.v___osContPifRam).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_mx : (prog_defmap CR.prog) ! CI.___osMaxControllers = Some (Gvar CR.v___osMaxControllers).
Proof. vm_compute. reflexivity. Qed.

Section POLL.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Hypothesis Hsq : sqrtf_spec.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Local Notation G := (lp_ge lp).
  Local Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  Lemma sym_of : forall q id gd, linkorder q lp -> (prog_defmap q) ! id = Some gd ->
      exists b, Genv.find_symbol G id = Some b.
  Proof. intros q id gd LO Hd. exact (SymbolicLinking.linkorder_resolves_symbol lp q id gd LO Hd). Qed.

  (* ffw pins the nextblock bound and Mario's controller pointer *)
  Lemma ffw_ctl : forall m, ffw G bm m ->
      Ple (Genv.genv_next G) (Mem.nextblock m)
      /\ exists b o, Mem.load Mint32 m bm FFW_CTL = Some (Vptr b o).
  Proof.
    intros m (Hp & (d & F) & _).
    split; [ exact Hp | ].
    destruct (ff_Wc _ _ _ _ F) as (b & o & E & _).
    pose proof (ff_Lc _ _ _ _ F) as Lc. rewrite E in Lc. exists b, o. exact Lc.
  Qed.

  (* a stored global the poll writes is apart from everything MWF_real reads *)
  Lemma harm_ch : forall id b, mem_id id stored_globals = true -> Genv.find_symbol G id = Some b ->
      b <> bm /\ ~ SafeB b
      /\ ~ Genv.find_symbol G mario._gMarioState = Some b
      /\ ~ Genv.find_symbol G interaction._gGlobalTimer = Some b
      /\ ~ Genv.find_symbol G interaction._sInteractionHandlers = Some b
      /\ ~ (exists gid, mem_id gid knockback_table_ids = true /\ Genv.find_symbol G gid = Some b)
      /\ ~ Genv.find_symbol G mario._gMarioAnimsBuf = Some b.
  Proof.
    intros id b Hg Hs.
    destruct (SaveDoSaveBody.harm_sglob lp bm bc oc0 SafeB HSafeB_syms Hspawn id b Hg Hs)
      as (B1 & _ & B3 & W).
    split; [ exact B1 | split; [ exact B3 | ] ].
    split; [ intro F; apply W; left; exact F | ].
    split; [ intro F; apply W; right; left; exact F | ].
    split; [ intro F; apply W; right; right; left; exact F | ].
    split; [ intro F; apply W; right; right; right; left; exact F | ].
    intro F; apply W; right; right; right; right; exact F.
  Qed.

  (* the globals read_controller_inputs writes (its footprint, from the
     walk: poll_core's Uc) *)
  Definition rci_gvars : list ident :=
    [save_file._gSIEventMesgQueue; memory._gMainReceivedMesg; game_init._gControllerPads; mario._gControllers].

  Definition rci_blk (b : block) : Prop :=
    exists id, In id rci_gvars /\ Genv.find_symbol G id = Some b.

  Theorem poll_ok_foot : forall i m0,
      ow_facts bm MWF i -> ffw G bm i -> ctl_w G i -> pif_a_real G i = false -> rci_call lp i m0 ->
      (ow_facts bm MWF m0 /\ a_used_real bm m0 = false /\ ctl_w G m0)
      /\ Mem.unchanged_on (fun b _ => ~ rci_blk b) i m0.
  Proof.
    intros i m0 (Vi & Ai & Mi) Fi CWi PA (t & vres & Hev).
    pose proof Hspawn as (init & Hsp).
    pose proof Hsp as (_ & Sbm & Sbc & Eoc).
    pose proof (spawn_Hbc_bm lp init bm bc oc0 Hsp) as Nbcbm.
    pose proof (LO_gi lp H12) as LOg. pose proof (LO_cr lp H12) as LOc.
    destruct (ffw_ctl i Fi) as (Hgn & bk & ok & Lk).
    destruct (sym_of _ _ _ LOg dm_pads) as (bpads & Hpads).
    destruct (sym_of _ _ _ LOg dm_q) as (bq & Hq).
    destruct (sym_of _ _ _ LOg dm_rm) as (brm & Hrm).
    destruct (sym_of _ _ _ LOg dm_p1) as (bp1 & Hp1).
    destruct (sym_of _ _ _ LOg dm_p3) as (bp3 & Hp3).
    destruct (sym_of _ _ _ LOg dm_dm) as (bdm & Hdm).
    destruct (sym_of _ _ _ LOc dm_pif) as (bpif & Hpif).
    destruct (sym_of _ _ _ LOc dm_mx) as (bmx & Hmx).
    destruct (CWi bc bpads Sbc Hpads) as (Ccd & Cb & Cp & C1 & C3 & Cd & Cx).
    pose proof (C1 _ Hp1) as P1. pose proof (C3 _ Hp3) as P3.
    pose proof (Cd _ Hdm) as PD. pose proof (Cx _ Hmx) as PX.
    assert (Ppac : pads_ac bpads i) by exact Cp.
    assert (Pbtn : btn_ok bc i) by exact Cb.
    assert (Pport : forall k, 0 <= k < 4 -> port_a i bpif k = false).
    { unfold pif_a_real in PA. rewrite Hpif in PA. cbv beta iota in PA.
      apply orb_false_iff in PA as (PA & P3').
      apply orb_false_iff in PA as (PA & P2').
      apply orb_false_iff in PA as (P0' & P1').
      intros k Hk. assert (k = 0 \/ k = 1 \/ k = 2 \/ k = 3) as [-> | [-> | [-> | ->]]] by lia; assumption. }
    (* Mario's controller pointer is &gControllers[0] *)
    pose proof Mi as (_ & _ & R2 & _).
    destruct (R2 bk ok Lk) as (-> & ->).
    (* the walk *)
    eapply poll_core in Hev; try eassumption.
    destruct Hev as (U & B & CW0).
    unfold Uc, Fr in U.
    assert (Hfoot : Mem.unchanged_on (fun b _ => ~ rci_blk b) i m0).
    { eapply Mem.unchanged_on_implies; [ exact U | ].
      intros b z Nr V. split; [ exact V | ].
      split; [ intros ->; apply Nr; exists save_file._gSIEventMesgQueue; split; [ unfold rci_gvars; cbn [In]; auto 6 | exact Hq ] | ].
      split; [ intros ->; apply Nr; exists memory._gMainReceivedMesg; split; [ unfold rci_gvars; cbn [In]; auto 6 | exact Hrm ] | ].
      split; [ intros ->; apply Nr; exists game_init._gControllerPads; split; [ unfold rci_gvars; cbn [In]; auto 6 | exact Hpads ] | ].
      left. intros ->. apply Nr. exists mario._gControllers. split; [ unfold rci_gvars; cbn [In]; auto 6 | exact Sbc ]. }
    split; [ | exact Hfoot ].
    assert (Lfar : forall ch b z, b <> bq -> b <> brm -> b <> bpads -> b <> bc -> Mem.valid_block i b ->
                   Mem.load ch m0 b z = Mem.load ch i b z).
    { intros ch b z N1 N2 N3 N4 V. eapply Mem.load_unchanged_on_1; [ exact U | exact V | ].
      intros k _. split; [ exact V | split; [ exact N1 | split; [ exact N2 | split; [ exact N3 | left; exact N4 ] ] ] ]. }
    destruct (harm_ch save_file._gSIEventMesgQueue bq ltac:(vm_compute; reflexivity) Hq) as (Q1 & HQ).
    destruct (harm_ch memory._gMainReceivedMesg brm ltac:(vm_compute; reflexivity) Hrm) as (Q2 & HR).
    destruct (harm_ch game_init._gControllerPads bpads ltac:(vm_compute; reflexivity) Hpads) as (Q3 & HP).
    assert (Lbm : forall ch z, Mem.load ch m0 bm z = Mem.load ch i bm z).
    { intros ch z. apply Lfar; [ exact (not_eq_sym Q1) | exact (not_eq_sym Q2) | exact (not_eq_sym Q3)
                               | exact (not_eq_sym Nbcbm) | exact Vi ]. }
    assert (B18 := B 18 (or_intror eq_refl)). destruct B18 as (w18 & L18 & A18).
    assert (B16 := B 16 (or_introl eq_refl)). destruct B16 as (w16 & L16 & A16).
    assert (M0 : MWF m0).
    { pose proof (linked12_LO_mario lp H12) as LOm.
      pose proof (safeb_not_bm lp init bm bc oc0 SafeB Hsp HSafeB_syms) as D2.
      pose proof (safeb_not_bc lp init bm bc oc0 SafeB Hsp HSafeB_syms) as D2'.
      pose proof (gms_blk lp init bm bc oc0 SafeB Hsp HSafeB_syms) as D3.
      pose proof (gtimer_blk lp init bm bc oc0 SafeB Hsp HSafeB_syms) as D4.
      pose proof (table_blk lp init bm bc oc0 SafeB Hsp HSafeB_syms) as D5.
      pose proof (ktab_blk lp init bm bc oc0 SafeB Hsp HSafeB_syms) as D6.
      pose proof (glob_blk lp init bm bc oc0 SafeB Hsp HSafeB_syms) as D7.
      eapply (mwf_real_bc_frame lp) with (Ch := fun b => b = bq \/ b = brm \/ b = bpads) (m := i);
        try eassumption.
      - intros b Hc. cbv beta in Hc. destruct Hc as [-> | [-> | ->]].
        + exact (conj Q1 HQ).
        + exact (conj Q2 HR).
        + exact (conj Q3 HP).
      - intros b V. exact (Mem.valid_block_unchanged_on _ _ _ _ U V).
      - intros ch b z N4 NC V. cbv beta in NC.
        apply Lfar; [ intro E; apply NC; left; exact E | intro E; apply NC; right; left; exact E
                    | intro E; apply NC; right; right; exact E | exact N4 | exact V ].
      - intros v Lv. rewrite Eoc in Lv.
        change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 18))) with 18 in Lv.
        rewrite L18 in Lv. injection Lv as <-. exact A18. }
    split; [ split; [ exact (Mem.valid_block_unchanged_on _ _ _ _ U Vi) | split; [ | exact M0 ] ] | split ].
    - intros v Hl. apply Ai. rewrite <- Hl. symmetry. apply Lbm.
    - unfold a_used_real, a_pressed_real, a_down_real.
      assert (Lb : Mem.load Mptr m0 bm 156 = Some (Vptr bc Ptrofs.zero)).
      { rewrite Lbm. rewrite <- Eoc. exact Lk. }
      rewrite Lb. cbv beta iota.
      change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 18))) with 18.
      change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 16))) with 16.
      rewrite L18, L16. cbv beta iota. unfold Aclr in A18, A16. rewrite A18, A16. reflexivity.
    - exact CW0.
  Qed.

  Theorem poll_ok : forall i m0,
      ow_facts bm MWF i -> ffw G bm i -> ctl_w G i -> pif_a_real G i = false -> rci_call lp i m0 ->
      ow_facts bm MWF m0 /\ a_used_real bm m0 = false /\ ctl_w G m0.
  Proof.
    intros i m0 Hof Hf Hcw HP Hr. exact (proj1 (poll_ok_foot i m0 Hof Hf Hcw HP Hr)).
  Qed.
End POLL.
