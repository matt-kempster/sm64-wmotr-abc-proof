(* ====================================================================== *)
(* LptBody.v -- set_mario_animation, set_mario_anim_with_accel and the   *)
(* load_patchable_table / dma_read they call keep GOAL 1's facts          *)
(*                                                                        *)
(* Proved from the generated bodies (mario.c, memory.c) and the libultra  *)
(* floor (OsDmaFloor.os_dma_floor), with no row about any of them:        *)
(*   sma_row_linked12   : call_pres  ... set_mario_animation              *)
(*   smawa_row_linked12 : call_pres_np3 ... set_mario_anim_with_accel     *)
(*                                                                        *)
(* Why it holds (2026-10-19 layout): m->animList is PINNED to             *)
(* &gMarioAnimsBuf (MWF R11), a block kept OUT of SafeB.  Every pointer   *)
(* loaded through the list (dmaTable, currentAddr, bufTarget) is SafeB    *)
(* (R12); load_patchable_table's one store, list->currentAddr = addr,     *)
(* keeps R12 (addr is SafeB arithmetic) and leaves bufTarget, so R13 (the *)
(* DMA buffer is not Mario's object) survives.  The DMA lands in the      *)
(* SafeB buffer as data bytes; the libultra calls otherwise write only    *)
(* gDmaIoMesg / gDmaMesgQueue / gMainReceivedMesg.  The animation bodies' *)
(* other stores are chase stores into SafeB o = m->marioObj / targetAnim. *)
(* (Before 2026-10-19 animList was a SafeB chase root; that made MWF      *)
(* false of real memories -- &gMarioAnimsBuf is a symbol -- and let the   *)
(* offset-free GOAL-1 SafeB stores reach the list's cells.)               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Classical_Prop String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Memdata Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_actions_stationary mario_actions_moving
  mario_actions_airborne mario_actions_submerged mario_actions_cutscene
  mario_actions_automatic mario_actions_object interaction behavior_actions
  level_update mario_step surface_collision math_util memory game_init
  object_list_processor audio_data graph_node save_file buffers object_helpers area
  libultra_osEepromLongWrite libultra_osEepromWrite libultra_osSiCreateAccessQueue
  libultra_osCreateMesgQueue libultra_osContInit libultra_osInitialize
  behavior_data spawn_object surface_load macro_special_objects wmotr_level_data
  camera rendering_graph_node ingame_menu debug_course mario_anim_data
  audio_external sound_init print behavior_script obj_behaviors
  platform_displacement libultra_osContStartReadData hud.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame AGates Taint
  RealFrameLinked RealFrameValue CensusV2 MWFReal OsDmaFloor ActWriterSurface LinkedTwelve.
From SM64.Proofs Require OutParamSurface RestSurface.
From SM64.Proofs Require Import SpawnInit DispatchKit.

Import ListNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.

(* ---------------------------------------------------------------------- *)
(* A pointer never decodes from bytes that include a data byte            *)
(* ---------------------------------------------------------------------- *)

Lemma check_value_fragments : forall n v q vl x,
  check_value n v q vl = true -> In x vl -> ~ is_data x.
Proof.
  induction n as [| n IH]; intros v q vl x H I.
  - destruct vl; [ destruct I | discriminate ].
  - destruct vl as [| mv vl]; [ discriminate | ].
    destruct mv as [| byte | v' q' k]; try discriminate.
    cbn in H. rewrite !andb_true_iff in H. destruct H as [_ H].
    destruct I as [<- | I].
    + intros [b E]. discriminate.
    + exact (IH _ _ _ _ H I).
Qed.

Lemma decode_ptr_no_data : forall ch vl b o,
  decode_val ch vl = Vptr b o -> forall x, In x vl -> ~ is_data x.
Proof.
  intros ch vl b o H x I.
  unfold decode_val in H.
  destruct (proj_bytes vl) as [bl|] eqn:PB.
  - destruct ch; try discriminate.
    unfold Val.norm_bool in H.
    match type of H with (if ?c then _ else _) = _ => destruct c end; discriminate.
  - assert (PV : exists q b1 o1, proj_value q vl = Vptr b1 o1).
    { destruct ch; cbn in H; try discriminate H;
        match type of H with context [proj_value ?q vl] =>
          exists q; destruct (proj_value q vl); cbn in H; try discriminate H; eauto end. }
    destruct PV as (q & b1 & o1 & PV). unfold proj_value in PV.
    destruct vl as [| mv vl']; [ discriminate | ].
    destruct mv as [| byte | v' q' k]; try discriminate.
    destruct (check_value _ v' q (Fragment v' q' k :: vl')) eqn:CV; [ | discriminate ].
    exact (check_value_fragments _ _ _ _ _ CV I).
Qed.

(* a pointer load after a change that left each byte old or data is the
   same load before it *)
Lemma load_ptr_old : forall m m' ch b z b' o',
  same_perms m m' ->
  (forall i, z <= i < z + size_chunk ch ->
     ZMap.get i (Mem.mem_contents m') !! b = ZMap.get i (Mem.mem_contents m) !! b
     \/ is_data (ZMap.get i (Mem.mem_contents m') !! b)) ->
  Mem.load ch m' b z = Some (Vptr b' o') ->
  Mem.load ch m b z = Some (Vptr b' o').
Proof.
  intros m m' ch b z b' o' (NB & PP) OLD L.
  pose proof (Mem.load_valid_access _ _ _ _ _ L) as VA'.
  assert (VA : Mem.valid_access m ch b z Readable).
  { destruct VA' as [RP AL]. split; [ | exact AL ].
    intros i Hi. apply PP. apply RP. exact Hi. }
  pose proof (Mem.load_result _ _ _ _ _ L) as R'.
  assert (G : Mem.getN (size_chunk_nat ch) z (Mem.mem_contents m') !! b
            = Mem.getN (size_chunk_nat ch) z (Mem.mem_contents m) !! b).
  { apply Mem.getN_exten. intros i Hi.
    rewrite <- size_chunk_conv in Hi.
    destruct (OLD i Hi) as [E | D]; [ exact E | ].
    exfalso. refine (decode_ptr_no_data ch _ b' o' (eq_sym R') (ZMap.get i (Mem.mem_contents m') !! b) _ D).
    apply Mem.getN_in. rewrite <- size_chunk_conv. exact Hi. }
  destruct (Mem.valid_access_load _ _ _ _ VA) as [v L0].
  rewrite L0. pose proof (Mem.load_result _ _ _ _ _ L0) as R0.
  rewrite R0, <- G, <- R'. reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* A small walker: facts F on memory, and a temp-env invariant G (for the *)
(* chase walks: every chase temp, when it holds a pointer, holds a SafeB   *)
(* one; for the anim-list walks also: the list temps hold &gMarioAnimsBuf) *)
(* ---------------------------------------------------------------------- *)

Section CW.
  Variable ge : genv.
  Variable e : env.
  Variable F : mem -> Prop.
  Variable G : temp_env -> Prop.
  Variable set_ok : ident -> expr -> bool.
  Variable store_ok : expr -> expr -> bool.
  Variable call_ok : option ident -> expr -> list expr -> bool.

  Hypothesis Hset : forall id a le m v,
      set_ok id a = true -> G le -> F m ->
      eval_expr ge e le m a v -> G (PTree.set id v le).
  Hypothesis Hstore : forall a1 a2 le m t le' m' out,
      store_ok a1 a2 = true -> G le ->
      exec_stmt function_entry2 ge e le m (Sassign a1 a2) t le' m' out ->
      F m -> F m'.
  Hypothesis Hcall : forall o a al le m t le' m' out,
      call_ok o a al = true -> G le ->
      exec_stmt function_entry2 ge e le m (Scall o a al) t le' m' out ->
      F m -> F m' /\ G le'.

  Fixpoint cw_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue | Sreturn _ => true
    | Sset id a => set_ok id a
    | Sassign a1 a2 => store_ok a1 a2
    | Scall o a al => call_ok o a al
    | Ssequence s1 s2 => cw_chk s1 && cw_chk s2
    | Sifthenelse _ s1 s2 => cw_chk s1 && cw_chk s2
    | Sloop s1 s2 => cw_chk s1 && cw_chk s2
    | _ => false
    end.

  Lemma cw_walk : forall e0 le m s t le' m' out,
      exec_stmt function_entry2 ge e0 le m s t le' m' out -> e0 = e ->
      cw_chk s = true -> G le -> F m ->
      F m' /\ G le'.
  Proof.
    intros e0 le m s t le' m' out Hexec.
    induction Hexec; intros He Hchk Hg Hf; subst; cbn [cw_chk] in Hchk;
      try discriminate Hchk.
    - split; assumption.
    - split; [ | exact Hg ].
      lazymatch goal with Hl : eval_lvalue ?gg ?ee ?ll ?mm a1 _ _ _ |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Sassign a1 a2) E0 ll m' Out_normal)
          by (eapply exec_Sassign; eassumption) end.
      exact (Hstore _ _ _ _ _ _ _ _ Hchk Hg Hx Hf).
    - split; [ exact Hf | ]. eapply Hset; eassumption.
    - lazymatch goal with Hee : eval_expr ?gg ?ee ?ll ?mm a _,
                          Hfc : eval_funcall _ _ _ _ _ ?tt ?mm' ?vr |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Scall optid a al) tt
                       (set_opttemp optid vr ll) mm' Out_normal)
          by (eapply exec_Scall; eassumption) end.
      exact (Hcall _ _ _ _ _ _ _ _ _ Hchk Hg Hx Hf).
    - apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hg Hf) as [Hf1 Hg1].
      exact (IHHexec2 eq_refl H2 Hg1 Hf1).
    - apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hg Hf).
    - apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; [ reflexivity | destruct b; assumption | exact Hg | exact Hf ].
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hg Hf).
    - apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hg Hf) as [Hf1 Hg1].
      exact (IHHexec2 eq_refl H2 Hg1 Hf1).
    - pose proof Hchk as Hchk0.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hg Hf) as [Hf1 Hg1].
      destruct (IHHexec2 eq_refl H2 Hg1 Hf1) as [Hf2 Hg2].
      exact (IHHexec3 eq_refl Hchk0 Hg2 Hf2).
  Qed.
End CW.

(* the parameter binding: a bound temp holds its argument, or what it held *)
Lemma scall_none_le : forall ge e le m a al t le' m' out,
    exec_stmt function_entry2 ge e le m (Scall None a al) t le' m' out -> le' = le.
Proof. intros ge e le m a al t le' m' out H. inv H. reflexivity. Qed.

Lemma bind_get : forall params vargs le0 le,
  bind_parameter_temps params vargs le0 = Some le ->
  forall t x, le ! t = Some x ->
    le0 ! t = Some x \/
    exists n, nth_error (map fst params) n = Some t /\ nth_error vargs n = Some x.
Proof.
  induction params as [| [id ty] params IH]; intros vargs le0 le H t x G.
  - destruct vargs; [ | discriminate ]. injection H as <-. left. exact G.
  - destruct vargs as [| v vl]; [ discriminate | ]. cbn in H.
    destruct (IH _ _ _ H t x G) as [G0 | (n & N1 & N2)].
    + destruct (peq t id) as [-> | NE].
      * rewrite PTree.gss in G0. injection G0 as <-. right. exists O. auto.
      * rewrite PTree.gso in G0 by exact NE. left. exact G0.
    + right. exists (S n). auto.
Qed.

Lemma undef_temps_get : forall l t x, (create_undef_temps l) ! t = Some x -> x = Vundef.
Proof.
  induction l as [| [id ty] l IH]; intros t x G; cbn in G.
  - rewrite PTree.gempty in G. discriminate.
  - destruct (peq t id) as [-> | NE].
    + rewrite PTree.gss in G. congruence.
    + rewrite PTree.gso in G by exact NE. exact (IH _ _ G).
Qed.

(* the shape of a call through a global function name *)
Lemma scall_evar_inv : forall ge e le m fid fty al t le' m' out,
  exec_stmt function_entry2 ge e le m (Scall None (Evar fid fty) al) t le' m' out ->
  e ! fid = None -> access_mode fty = By_reference ->
  exists b fd tyargs tyres cc vargs vres,
    Genv.find_symbol ge fid = Some b
    /\ Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd
    /\ classify_fun fty = fun_case_f tyargs tyres cc
    /\ eval_exprlist ge e le m al tyargs vargs
    /\ eval_funcall function_entry2 ge m fd vargs t m' vres
    /\ le' = le /\ out = Out_normal.
Proof.
  intros ge e le m fid fty al t le' m' out H En Am.
  inv H.
  match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hv end;
    try (cbn in *; discriminate).
  match goal with Hx : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hx end.
  - congruence.
  - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try congruence.
    do 7 eexists. split; [ eassumption | split; [ eassumption | ] ].
    split; [ eassumption | split; [ eassumption | split; [ eassumption | auto ] ] ].
Qed.

Lemma scall_evar_inv_opt : forall ge e le m optid fid fty al t le' m' out,
  exec_stmt function_entry2 ge e le m (Scall optid (Evar fid fty) al) t le' m' out ->
  e ! fid = None -> access_mode fty = By_reference ->
  exists b fd tyargs tyres cc vargs vres,
    Genv.find_symbol ge fid = Some b
    /\ Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd
    /\ classify_fun fty = fun_case_f tyargs tyres cc
    /\ eval_exprlist ge e le m al tyargs vargs
    /\ eval_funcall function_entry2 ge m fd vargs t m' vres
    /\ le' = set_opttemp optid vres le /\ out = Out_normal.
Proof.
  intros ge e le m optid fid fty al t le' m' out H En Am.
  inv H.
  match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hv end;
    try (cbn in *; discriminate).
  match goal with Hx : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hx end.
  - congruence.
  - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try congruence.
    do 7 eexists. split; [ eassumption | split; [ eassumption | ] ].
    split; [ eassumption | split; [ eassumption | split; [ eassumption | auto ] ] ].
Qed.

(* ---------------------------------------------------------------------- *)
(* The libultra symbols: External in memory.c, Internal in no linked TU   *)
(* ---------------------------------------------------------------------- *)

Definition os_ids : list ident :=
  [memory._osInvalDCache; memory._osPiStartDma; memory._osRecvMesg].

Lemma os_ni_mario : no_internal_ids mario.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_sta : no_internal_ids mario_actions_stationary.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_mov : no_internal_ids mario_actions_moving.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_air : no_internal_ids mario_actions_airborne.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_sub : no_internal_ids mario_actions_submerged.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_cut : no_internal_ids mario_actions_cutscene.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_aut : no_internal_ids mario_actions_automatic.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_obj : no_internal_ids mario_actions_object.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_int : no_internal_ids interaction.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_beh : no_internal_ids behavior_actions.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_lvl : no_internal_ids level_update.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_stp : no_internal_ids mario_step.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_surf : no_internal_ids surface_collision.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_math : no_internal_ids math_util.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_memory : no_internal_ids memory.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_game_init : no_internal_ids game_init.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_olp : no_internal_ids object_list_processor.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_audio_data : no_internal_ids audio_data.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_graph_node : no_internal_ids graph_node.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_save_file : no_internal_ids save_file.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_buffers : no_internal_ids buffers.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_object_helpers : no_internal_ids object_helpers.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_area : no_internal_ids area.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_ultra_elw : no_internal_ids libultra_osEepromLongWrite.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_ultra_ew : no_internal_ids libultra_osEepromWrite.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_ultra_si : no_internal_ids libultra_osSiCreateAccessQueue.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_ultra_cmq : no_internal_ids libultra_osCreateMesgQueue.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_ultra_ci : no_internal_ids libultra_osContInit.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_ultra_init : no_internal_ids libultra_osInitialize.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_behavior_data : no_internal_ids behavior_data.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_spawn_object : no_internal_ids spawn_object.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_surface_load : no_internal_ids surface_load.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_macro_special_objects : no_internal_ids macro_special_objects.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_wmotr_level_data : no_internal_ids wmotr_level_data.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_camera : no_internal_ids camera.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_rendering_graph_node : no_internal_ids rendering_graph_node.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_ingame_menu : no_internal_ids ingame_menu.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_debug_course : no_internal_ids debug_course.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_mario_anim_data : no_internal_ids mario_anim_data.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_audio_external : no_internal_ids audio_external.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_sound_init : no_internal_ids sound_init.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_print : no_internal_ids print.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_behavior_script : no_internal_ids behavior_script.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_obj_behaviors : no_internal_ids obj_behaviors.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_platform_displacement : no_internal_ids platform_displacement.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_libultra_osContStartReadData :
  no_internal_ids libultra_osContStartReadData.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_ni_hud : no_internal_ids hud.prog os_ids = true.
Proof. vm_compute. reflexivity. Qed.

Definition ext_named (o : option (globdef Clight.fundef type)) (n : String.string) : bool :=
  match o with
  | Some (Gfun (External (EF_external n' _) _ _ _)) => String.eqb n' n
  | _ => false
  end.

Lemma ext_named_ok : forall o n, ext_named o n = true ->
  exists sg targs tres cc, o = Some (Gfun (External (EF_external n sg) targs tres cc)).
Proof.
  intros o n H. destruct o as [[[f | ef targs tres cc] | v] |]; try discriminate.
  destruct ef; try discriminate. cbn in H. apply String.eqb_eq in H. subst. eauto.
Qed.

Lemma os_inval_named :
  ext_named ((prog_defmap memory.prog) ! memory._osInvalDCache) "osInvalDCache" = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_pidma_named :
  ext_named ((prog_defmap memory.prog) ! memory._osPiStartDma) "osPiStartDma" = true.
Proof. vm_compute. reflexivity. Qed.
Lemma os_recv_named :
  ext_named ((prog_defmap memory.prog) ! memory._osRecvMesg) "osRecvMesg" = true.
Proof. vm_compute. reflexivity. Qed.

Section LptFrame.
  Variable lp : Clight.program.
  Variable bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis Hbc_bm : bc <> bm.
  Hypothesis HSafeB_not_bm : forall b, SafeB b -> b <> bm.
  Hypothesis HSafeB_not_bc : ~ SafeB bc.
  Hypothesis Hgms_blk : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Hypothesis Hglob_blk : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
  Hypothesis Hgtimer_blk : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
  Hypothesis Htable_blk : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
  Hypothesis Hktab_blk : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.

  Definition MWF := MWF_real lp bm bc oc0 SafeB.
  Definition lfacts (m : mem) : Prop :=
    Mem.valid_block m bm /\ action_sat not_tainted m bm /\ MWF m.

  Definition is_sglob (b : block) : Prop :=
    exists gid, mem_id gid stored_globals = true /\ Genv.find_symbol (lp_ge lp) gid = Some b.

  (* a change confined to W, where each W byte is a SafeB byte left old or
     data, or a byte of a stored global, keeps the facts *)
  Lemma os_change_facts : forall (W : block -> Z -> Prop) m m',
      lfacts m ->
      Mem.unchanged_on (fun b z => ~ W b z) m m' ->
      same_perms m m' ->
      (forall b z, W b z ->
         (SafeB b /\ (ZMap.get z (Mem.mem_contents m') !! b = ZMap.get z (Mem.mem_contents m) !! b
                      \/ is_data (ZMap.get z (Mem.mem_contents m') !! b)))
         \/ is_sglob b) ->
      lfacts m'.
  Proof.
    intros W m m' (Vb & AS & M) UO SP CL.
    assert (Wb : forall b z, W b z -> b <> bm /\ b <> bc
                  /\ (Genv.find_symbol (lp_ge lp) mario._gMarioState = Some b -> False)
                  /\ (Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some b -> False)
                  /\ (Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some b -> False)
                  /\ (forall gid, mem_id gid knockback_table_ids = true ->
                        Genv.find_symbol (lp_ge lp) gid = Some b -> False)
                  /\ (Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some b -> False)).
    { intros b z Hw. destruct (CL b z Hw) as [[S _] | (gid & Hg & Hfs)].
      - split; [ exact (HSafeB_not_bm _ S) | split; [ intro E; subst; exact (HSafeB_not_bc S) | ] ].
        split; [ intro F; exact (proj2 (proj2 (Hgms_blk _ F)) S) | ].
        split; [ intro F; exact (proj2 (proj2 (Hgtimer_blk _ F)) S) | ].
        split; [ intro F; exact (proj2 (proj2 (Htable_blk _ F)) S) | ].
        split; [ intros gid Hg F; exact (proj2 (proj2 (Hktab_blk _ _ Hg F)) S) | ].
        intro F. exact (proj1 (proj2 (proj2 (mwf_real_anim_blk lp bm bc oc0 SafeB m b M F))) S).
      - destruct (Hglob_blk _ _ Hg Hfs) as (B1 & B2 & _).
        split; [ exact B1 | split; [ exact B2 | ] ].
        split; [ intro F; eapply Genv.global_addresses_distinct; [ | exact Hfs | exact F | reflexivity ];
                 intro E; subst gid; rewrite stored_globals_not_gms in Hg; discriminate | ].
        split; [ intro F; eapply Genv.global_addresses_distinct; [ | exact Hfs | exact F | reflexivity ];
                 intro E; subst gid; rewrite stored_globals_not_gtimer in Hg; discriminate | ].
        split; [ intro F; eapply Genv.global_addresses_distinct; [ | exact Hfs | exact F | reflexivity ];
                 intro E; subst gid; rewrite stored_globals_not_itab in Hg; discriminate | ].
        split; [ intros gid2 Hg2 F; eapply Genv.global_addresses_distinct; [ | exact Hfs | exact F | reflexivity ];
                 intro E; subst gid2; rewrite (stored_globals_not_ktab _ Hg2) in Hg; discriminate | ].
        intro F. eapply Genv.global_addresses_distinct; [ | exact Hfs | exact F | reflexivity ].
        intro E; subst gid; rewrite stored_globals_not_anim in Hg; discriminate. }
    pose proof SP as (NB & PP).
    assert (Hval : forall b, Mem.valid_block m b -> Mem.valid_block m' b).
    { intros b H. unfold Mem.valid_block in *. rewrite NB. exact H. }
    assert (Lsame : forall ch b z, (forall i, z <= i < z + size_chunk ch -> ~ W b i) ->
              Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z Hnw.
      destruct (plt b (Mem.nextblock m)) as [Vm | NVm].
      - eapply Mem.load_unchanged_on_1; [ exact UO | exact Vm | exact Hnw ].
      - destruct (Mem.load ch m' b z) as [v|] eqn:L'.
        + exfalso. apply NVm. pose proof (Mem.load_valid_access _ _ _ _ _ L') as VA.
          unfold Mem.valid_block. rewrite <- NB. eapply Mem.valid_access_valid_block.
          eapply Mem.valid_access_implies; [ exact VA | constructor ].
        + destruct (Mem.load ch m b z) as [v|] eqn:L; [ | reflexivity ].
          exfalso. apply NVm. pose proof (Mem.load_valid_access _ _ _ _ _ L) as VA.
          eapply Mem.valid_access_valid_block.
          eapply Mem.valid_access_implies; [ exact VA | constructor ]. }
    split; [ exact (Hval _ Vb) | split ].
    - eapply action_sat_unchanged_on; [ | exact Vb | exact AS ].
      eapply Mem.unchanged_on_implies; [ exact UO | ].
      intros b z [Eb _] _ Hw. exact (proj1 (Wb b z Hw) Eb).
    - apply (MWF_real_transfer lp bm bc oc0 SafeB Hbc_bm m m'); [ exact Hval | | | | exact M ].
      + intros v Hld. pose proof M as (_ & R1 & _). apply R1.
        rewrite <- Hld. symmetry. apply Lsame. intros i _ Hw. exact (proj1 (Wb _ _ Hw) eq_refl).
      + intros ch b ofs v Hrow Hld. rewrite <- Hld. symmetry. apply Lsame.
        intros i _ Hw. destruct (Wb _ _ Hw) as (B1 & B2 & B3 & B4 & B5 & B6 & B7).
        destruct Hrow as [ [Eb _] | [ Eb | [ F | [ F | [ F | [ (gid & Hg & F) | F ] ] ] ] ] ].
        * exact (B1 Eb).
        * exact (B2 Eb).
        * exact (B3 F).
        * exact (B4 F).
        * exact (B5 F).
        * exact (B6 _ Hg F).
        * exact (B7 F).
      + intros b ofs b' o' Hs Hld.
        pose proof M as (_ & _ & _ & _ & _ & _ & _ & R7 & _).
        apply (R7 b ofs b' o' Hs). cbn in Hld |- *.
        eapply load_ptr_old; [ exact SP | | exact Hld ].
        intros i Hi.
        destruct (classic (W b i)) as [Hw | Hnw].
        * destruct (CL b i Hw) as [[_ OD] | (gid & Hg & Hfs)]; [ exact OD | ].
          exfalso. exact (proj2 (proj2 (Hglob_blk _ _ Hg Hfs)) Hs).
        * left. eapply Mem.unchanged_on_contents; [ exact UO | exact Hnw | ].
          apply PP. pose proof (Mem.load_valid_access _ _ _ _ _ Hld) as [RP _].
          eapply Mem.perm_implies; [ apply RP; exact Hi | constructor ].
  Qed.

  Hypothesis Hlink : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.

  Let LO_memory : linkorder memory.prog lp := linked12_LO_memory lp Hlink.

  (* a libultra symbol resolves to its memory.c External declaration *)
  Lemma os_resolve : forall fid n b fd,
      mem_id fid os_ids = true ->
      ext_named ((prog_defmap memory.prog) ! fid) n = true ->
      Genv.find_symbol (lp_ge lp) fid = Some b ->
      Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd ->
      exists sg targs tres cc, fd = External (EF_external n sg) targs tres cc.
  Proof.
    intros fid n b fd Hid Hn Hs Hf.
    destruct (ext_named_ok _ _ Hn) as (sg & targs & tres & cc & Hdm).
    assert (Hdm' : (prog_defmap lp) ! fid = Some (Gfun fd)).
    { apply resolves_defmap. exists b. split; assumption. }
    pose proof LO_memory as LOq.
    Local Transparent Linker_program.
    unfold linkorder, Linker_program, linkorder_program in LOq.
    destruct LOq as [LOast _].
    destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm) as (gd' & Hgd' & Hlo).
    change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
    rewrite Hdm' in Hgd'. injection Hgd' as <-.
    inv Hlo.
    match goal with H : linkorder _ _ |- _ => inv H end.
    - do 4 eexists. reflexivity.
    - exfalso.
      destruct (link_chain_internal_origin _ _ _ _ _ Hlink Hdm')
        as [Hbase | (q & Hq & Hqdm)].
      + exact (no_internal_ids_correct _ _ _ _ os_ni_mario Hid Hbase).
      + destruct Hq as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]].
        * exact (no_internal_ids_correct _ _ _ _ os_ni_sta Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_mov Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_air Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_sub Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_cut Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_aut Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_obj Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_int Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_beh Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_lvl Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_stp Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_surf Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_math Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_memory Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_game_init Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_olp Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_audio_data Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_graph_node Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_save_file Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_buffers Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_object_helpers Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_area Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_ultra_elw Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_ultra_ew Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_ultra_si Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_ultra_cmq Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_ultra_ci Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_ultra_init Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_behavior_data Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_spawn_object Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_surface_load Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_macro_special_objects Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_wmotr_level_data Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_camera Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_rendering_graph_node Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_ingame_menu Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_debug_course Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_mario_anim_data Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_audio_external Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_sound_init Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_print Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_behavior_script Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_obj_behaviors Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_platform_displacement Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_libultra_osContStartReadData Hid Hqdm).
        * exact (no_internal_ids_correct _ _ _ _ os_ni_hud Hid Hqdm).
  Qed.

  (* the external call a libultra Scall makes *)
  Lemma os_call_ext : forall fid n le m fty al t le' m' out,
      mem_id fid os_ids = true ->
      ext_named ((prog_defmap memory.prog) ! fid) n = true ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall None (Evar fid fty) al) t le' m' out ->
      access_mode fty = By_reference ->
      exists sg tyargs vargs vres,
        eval_exprlist (lp_ge lp) empty_env le m al tyargs vargs
        /\ external_functions_sem n sg (lp_ge lp) vargs m t vres m'.
  Proof.
    intros fid n le m fty al t le' m' out Hid Hn H Am.
    destruct (scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ H (PTree.gempty _ _) Am)
      as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hf & _ & Hel & Hev & _ & _).
    destruct (os_resolve _ _ _ _ Hid Hn Hs Hf) as (sg & targs & tres & cc' & ->).
    inv Hev. exists sg, tyargs, vargs, vres. split; [ exact Hel | ].
    match goal with Hx : external_call _ _ _ _ _ _ _ |- _ => exact Hx end.
  Qed.

  Lemma not_outside : forall b0 o0 n b z, ~ outside b0 o0 n b z ->
      b = b0 /\ Ptrofs.unsigned o0 <= z < Ptrofs.unsigned o0 + n.
  Proof.
    intros b0 o0 n b z H. unfold outside in H.
    destruct (peq b b0) as [-> | NE]; [ | exfalso; apply H; left; exact NE ].
    split; [ reflexivity | ].
    destruct (Z_lt_le_dec z (Ptrofs.unsigned o0)) as [L | L];
      [ exfalso; apply H; right; left; exact L | ].
    destruct (Z_lt_le_dec z (Ptrofs.unsigned o0 + n)) as [L' | L'];
      [ lia | exfalso; apply H; right; right; exact L' ].
  Qed.

  Lemma tempvar_val : forall le m x ty v,
      eval_expr (lp_ge lp) empty_env le m (Etempvar x ty) v -> le ! x = Some v.
  Proof.
    intros le m x ty v H. inv H; [ assumption | ].
    match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end.
  Qed.

  Lemma addrof_glob_val : forall le m g ty ty' v,
      eval_expr (lp_ge lp) empty_env le m (Eaddrof (Evar g ty) ty') v ->
      exists bg, Genv.find_symbol (lp_ge lp) g = Some bg /\ v = Vptr bg Ptrofs.zero.
  Proof.
    intros le m g ty ty' v H. inv H.
    - match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
      + rewrite PTree.gempty in *. discriminate.
      + eauto.
    - match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end.
  Qed.

  (* an argument value after the parameter cast *)
  Lemma arg_ptr_safe : forall le m d ty ty' v b o,
      (forall b0 o0, le ! d = Some (Vptr b0 o0) -> SafeB b0) ->
      eval_expr (lp_ge lp) empty_env le m (Etempvar d ty) v ->
      sem_cast v ty ty' m = Some (Vptr b o) -> SafeB b.
  Proof.
    intros le m d ty ty' v b o Hs Hv Hc.
    apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst v.
    exact (Hs _ _ (tempvar_val _ _ _ _ _ Hv)).
  Qed.

  Lemma arg_glob : forall le m g ty ty0 ty' v b o,
      mem_id g stored_globals = true ->
      eval_expr (lp_ge lp) empty_env le m (Eaddrof (Evar g ty) ty0) v ->
      sem_cast v ty0 ty' m = Some (Vptr b o) -> is_sglob b.
  Proof.
    intros le m g ty ty0 ty' v b o Hg Hv Hc.
    apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst v.
    destruct (addrof_glob_val _ _ _ _ _ _ Hv) as (bg & Hs & E). injection E as <- _.
    exists g. auto.
  Qed.

  Lemma unch_nn : forall (P : block -> Z -> Prop) m m',
      Mem.unchanged_on P m m' -> Mem.unchanged_on (fun b z => ~ ~ P b z) m m'.
  Proof.
    intros P m m' U. eapply Mem.unchanged_on_implies; [ exact U | ].
    intros b z H _. apply NNPP. exact H.
  Qed.

  Lemma call_inval_facts : forall le m t le' m' out tl tr cc ty0 x1,
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall None (Evar memory._osInvalDCache (Tfunction tl tr cc))
           [Etempvar memory._dest ty0; x1]) t le' m' out ->
      (forall b o, le ! memory._dest = Some (Vptr b o) -> SafeB b) ->
      lfacts m -> lfacts m'.
  Proof.
    intros le m t le' m' out tl tr cc ty0 x1 H Hs Hf.
    destruct (os_call_ext memory._osInvalDCache "osInvalDCache" _ _ _ _ _ _ _ _ eq_refl os_inval_named H eq_refl)
      as (sg & tyargs & vargs & vres & Hel & Hx).
    destruct Hfloor as (Hinv & _ & _).
    destruct (Hinv _ _ _ _ _ _ _ Hx) as (bp & op & n & -> & UO & SP & DATA & _).
    inv Hel.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _,
                    Hc : sem_cast _ _ _ _ = Some (Vptr bp op) |- _ =>
      pose proof (arg_ptr_safe _ _ _ _ _ _ _ _ Hs Hv Hc) as Sbp end.
    apply (os_change_facts (fun b z => ~ outside bp op (Int.unsigned n) b z) m m' Hf);
      [ exact (unch_nn _ _ _ UO) | exact SP | ].
    intros b z Hw. left. destruct (not_outside _ _ _ _ _ Hw) as [-> R].
    split; [ exact Sbp | exact (DATA z R) ].
  Qed.

  Lemma call_pidma_facts : forall le m t le' m' out tl tr cc g1t g1t' x1 x2 x3 ty0 x5 g2t g2t',
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall None (Evar memory._osPiStartDma (Tfunction tl tr cc))
           [Eaddrof (Evar memory._gDmaIoMesg g1t) g1t'; x1; x2; x3;
            Etempvar memory._dest ty0; x5;
            Eaddrof (Evar memory._gDmaMesgQueue g2t) g2t']) t le' m' out ->
      (forall b o, le ! memory._dest = Some (Vptr b o) -> SafeB b) ->
      lfacts m -> lfacts m'.
  Proof.
    intros le m t le' m' out tl tr cc g1t g1t' x1 x2 x3 ty0 x5 g2t g2t' H Hs Hf.
    destruct (os_call_ext memory._osPiStartDma "osPiStartDma" _ _ _ _ _ _ _ _ eq_refl os_pidma_named H eq_refl)
      as (sg & tyargs & vargs & vres & Hel & Hx).
    destruct Hfloor as (_ & Hpi & _).
    destruct (Hpi _ _ _ _ _ _ _ Hx)
      as (bmb & omb & pri & dir & dev & bd & od & n & bq & oq & -> & UO & SP & DATA & _).
    inv Hel.
    match goal with Hv : eval_expr _ _ _ _ (Eaddrof (Evar memory._gDmaIoMesg _) _) _,
                    Hc : sem_cast _ _ _ _ = Some (Vptr bmb omb) |- _ =>
      pose proof (arg_glob _ _ memory._gDmaIoMesg _ _ _ _ _ _ eq_refl Hv Hc) as Gmb end.
    repeat match goal with H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _,
                    Hc : sem_cast _ _ _ _ = Some (Vptr bd od) |- _ =>
      pose proof (arg_ptr_safe _ _ _ _ _ _ _ _ Hs Hv Hc) as Sbd end.
    match goal with Hv : eval_expr _ _ _ _ (Eaddrof (Evar memory._gDmaMesgQueue _) _) _,
                    Hc : sem_cast _ _ _ _ = Some (Vptr bq oq) |- _ =>
      pose proof (arg_glob _ _ memory._gDmaMesgQueue _ _ _ _ _ _ eq_refl Hv Hc) as Gq end.
    apply (os_change_facts (fun b z => ~ (outside bd od (Int.unsigned n) b z
                                          /\ outside bmb omb SZ_IOMESG b z
                                          /\ outside bq oq SZ_MESGQ b z)) m m' Hf);
      [ exact (unch_nn _ _ _ UO) | exact SP | ].
    intros b z Hw.
    destruct (classic (outside bd od (Int.unsigned n) b z)) as [O1 | O1].
    - destruct (classic (outside bmb omb SZ_IOMESG b z)) as [O2 | O2].
      + destruct (classic (outside bq oq SZ_MESGQ b z)) as [O3 | O3];
          [ exfalso; exact (Hw (conj O1 (conj O2 O3))) | ].
        right. destruct (not_outside _ _ _ _ _ O3) as [-> _]. exact Gq.
      + right. destruct (not_outside _ _ _ _ _ O2) as [-> _]. exact Gmb.
    - left. destruct (not_outside _ _ _ _ _ O1) as [-> R].
      split; [ exact Sbd | right; exact (DATA z R) ].
  Qed.

  Lemma call_recv_facts : forall le m t le' m' out tl tr cc g1t g1t' g2t g2t' x2,
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall None (Evar memory._osRecvMesg (Tfunction tl tr cc))
           [Eaddrof (Evar memory._gDmaMesgQueue g1t) g1t';
            Eaddrof (Evar memory._gMainReceivedMesg g2t) g2t'; x2]) t le' m' out ->
      lfacts m -> lfacts m'.
  Proof.
    intros le m t le' m' out tl tr cc g1t g1t' g2t g2t' x2 H Hf.
    destruct (os_call_ext memory._osRecvMesg "osRecvMesg" _ _ _ _ _ _ _ _ eq_refl os_recv_named H eq_refl)
      as (sg & tyargs & vargs & vres & Hel & Hx).
    destruct Hfloor as (_ & _ & Hrv & _).
    destruct (Hrv _ _ _ _ _ _ _ Hx) as (bq & oq & cell & fl & -> & _ & SP & UOq).
    inv Hel.
    match goal with Hv : eval_expr _ _ _ _ (Eaddrof (Evar memory._gDmaMesgQueue _) _) _,
                    Hc : sem_cast _ _ _ _ = Some (Vptr bq oq) |- _ =>
      pose proof (arg_glob _ _ memory._gDmaMesgQueue _ _ _ _ _ _ eq_refl Hv Hc) as Gq;
      apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc; subst;
      destruct (addrof_glob_val _ _ _ _ _ _ Hv) as (bq' & Hsq & Eq);
      injection Eq as <- _ end.
    (* the DMA queue's row of q_side: nothing besides the queue and the cell *)
    pose proof (UOq memory._gDmaMesgQueue [] eq_refl Hsq) as UO.
    repeat match goal with H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H end.
    assert (Gm : forall bk ok, cell = Vptr bk ok -> is_sglob bk).
    { intros bk ok ->.
      match goal with Hv : eval_expr _ _ _ _ (Eaddrof (Evar memory._gMainReceivedMesg _) _) _,
                      Hc : sem_cast _ _ _ _ = Some (Vptr bk ok) |- _ =>
        exact (arg_glob _ _ memory._gMainReceivedMesg _ _ _ _ _ _ eq_refl Hv Hc) end. }
    apply (os_change_facts (fun b z => ~ (outside bq oq SZ_MESGQ b z
                                          /\ cell_out cell b z
                                          /\ not_side (Genv.to_senv (lp_ge lp)) [] b)) m m' Hf);
      [ exact (unch_nn _ _ _ UO) | exact SP | ].
    intros b z Hw. right.
    destruct (classic (outside bq oq SZ_MESGQ b z)) as [O1 | O1].
    - destruct cell as [ | | | | | bk ok ];
        try (exfalso; apply Hw; split; [ exact O1 | split; [ exact I | intros s [] ] ]).
      destruct (classic (outside bk ok 4 b z)) as [O2 | O2];
        [ exfalso; apply Hw; split; [ exact O1 | split; [ exact O2 | intros s [] ] ] | ].
      destruct (not_outside _ _ _ _ _ O2) as [-> _]. exact (Gm _ _ eq_refl).
    - destruct (not_outside _ _ _ _ _ O1) as [-> _]. exact Gq.
  Qed.

  (* ---------------- the walker's oracles ---------------- *)

  Definition chase_set_ok (cact : list ident) (id : ident) (a : expr) : bool :=
    negb (mem_id id cact) || chase_step_chk cact a || ptr_arith_e cact a.

  Lemma chase_set_sound : forall cact id a le m v,
      chase_set_ok cact id a = true -> chase_inv SafeB cact le -> lfacts m ->
      eval_expr (lp_ge lp) empty_env le m a v -> chase_inv SafeB cact (PTree.set id v le).
  Proof.
    intros cact id a le m v Hok Hci (_ & _ & M) Hev t Ht b o Hg.
    destruct (peq t id) as [-> | NE].
    - rewrite PTree.gss in Hg. injection Hg as Ev. subst v.
      unfold chase_set_ok in Hok. rewrite Ht in Hok. cbn [negb orb] in Hok.
      apply orb_true_iff in Hok as [Hc | Hp].
      + exact (chase_step_set_sound lp MWF SafeB (mwf_real_chase_step lp bm bc oc0 SafeB)
                 cact a empty_env le m _ Hc Hci M Hev b o eq_refl).
      + exact (ptr_arith_safe SafeB cact _ empty_env le m a _ Hci Hp Hev b o eq_refl).
    - rewrite PTree.gso in Hg by exact NE. exact (Hci t Ht b o Hg).
  Qed.

  Definition is_inval_call (a : expr) (al : list expr) : bool :=
    match a, al with
    | Evar f (Tfunction _ _ _), Etempvar d _ :: _ :: nil =>
        Pos.eqb f memory._osInvalDCache && Pos.eqb d memory._dest
    | _, _ => false
    end.
  Definition is_pidma_call (a : expr) (al : list expr) : bool :=
    match a, al with
    | Evar f (Tfunction _ _ _),
      Eaddrof (Evar g1 _) _ :: _ :: _ :: _ :: Etempvar d _ :: _ :: Eaddrof (Evar g2 _) _ :: nil =>
        Pos.eqb f memory._osPiStartDma && Pos.eqb g1 memory._gDmaIoMesg
        && Pos.eqb d memory._dest && Pos.eqb g2 memory._gDmaMesgQueue
    | _, _ => false
    end.
  Definition is_recv_call (a : expr) (al : list expr) : bool :=
    match a, al with
    | Evar f (Tfunction _ _ _), Eaddrof (Evar g1 _) _ :: Eaddrof (Evar g2 _) _ :: _ :: nil =>
        Pos.eqb f memory._osRecvMesg && Pos.eqb g1 memory._gDmaMesgQueue
        && Pos.eqb g2 memory._gMainReceivedMesg
    | _, _ => false
    end.

  Ltac crush_match H :=
    repeat match type of H with
           | context [ match ?x with _ => _ end ] => destruct x; try discriminate H
           end;
    repeat match goal with
           | E : (_ && _)%bool = true |- _ => apply andb_prop in E as [? ?]
           end;
    repeat match goal with
           | E : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in E; subst
           end.

  Definition dma_cact : list ident := [memory._dest].
  Definition dma_call_ok (o : option ident) (a : expr) (al : list expr) : bool :=
    match o with
    | None => is_inval_call a al || is_pidma_call a al || is_recv_call a al
    | Some _ => false
    end.

  Lemma dma_call_sound : forall o a al le m t le' m' out,
      dma_call_ok o a al = true -> chase_inv SafeB dma_cact le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall o a al) t le' m' out ->
      lfacts m -> lfacts m' /\ chase_inv SafeB dma_cact le'.
  Proof.
    intros o a al le m t le' m' out Hok Hci H Hf.
    destruct o as [i|]; [ discriminate Hok | ].
    rewrite (scall_none_le _ _ _ _ _ _ _ _ _ _ H). split; [ | exact Hci ].
    assert (Hs : forall b o, le ! memory._dest = Some (Vptr b o) -> SafeB b)
      by (intros b o; apply (Hci memory._dest eq_refl)).
    unfold dma_call_ok in Hok. apply orb_true_iff in Hok as [Hok | Hok];
      [ apply orb_true_iff in Hok as [Hok | Hok] | ].
    - unfold is_inval_call in Hok. crush_match Hok.
      eapply call_inval_facts; eassumption.
    - unfold is_pidma_call in Hok. crush_match Hok.
      eapply call_pidma_facts; eassumption.
    - unfold is_recv_call in Hok. crush_match Hok.
      eapply call_recv_facts; eassumption.
  Qed.

  Lemma dma_read_chk :
    cw_chk (chase_set_ok dma_cact) (fun _ _ => false) dma_call_ok
      (fn_body memory.f_dma_read) = true.
  Proof. vm_compute. reflexivity. Qed.

  (* ---------------- dma_read: its real body ---------------- *)

  Lemma dma_read_facts : forall m vargs t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m (Internal memory.f_dma_read) vargs t m' vres ->
      (forall b o, hd_error vargs = Some (Vptr b o) -> SafeB b) ->
      lfacts m -> lfacts m'.
  Proof.
    intros m vargs t m' vres Hevf Hhd Hf.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars memory.f_dma_read) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ => rename Hb into Hbind; set (le := L) in * end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
    assert (Hci : chase_inv SafeB dma_cact le).
    { intros tv Ht b o Hg.
      destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
        [ apply undef_temps_get in G0; discriminate G0 | ].
      destruct n as [| [| [| n]]]; cbv [memory.f_dma_read fn_params map fst nth_error] in N1; try (destruct n; discriminate N1); try discriminate N1;
        injection N1 as Et; subst tv; try discriminate Ht.
      destruct vargs as [| v0 vl]; [ discriminate N2 | ].
      cbn in N2. injection N2 as ->. apply (Hhd b o). reflexivity. }
    destruct (cw_walk (lp_ge lp) empty_env lfacts (chase_inv SafeB dma_cact)
                (chase_set_ok dma_cact) (fun _ _ => false) dma_call_ok
                (chase_set_sound dma_cact)
                (fun _ _ _ _ _ _ _ _ Hno => ltac:(discriminate Hno))
                dma_call_sound
                _ _ _ _ _ _ _ _ Hbody eq_refl dma_read_chk Hci Hf)
      as [Hf' _].
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    inv Hfree. exact Hf'.
  Qed.

  (* ---------------- load_patchable_table: its real body ----------------
     Its list argument is m->animList, which MWF R11 pins to
     &gMarioAnimsBuf (offset 0) -- a block kept OUT of SafeB.  The walk
     threads: the chase temps are SafeB-if-pointer, and the list temp, if
     a pointer, is (ab, 0).  Loads through the list are SafeB by R12; the
     one store (list->currentAddr = addr) is mwf_real_anim_cur_store. *)

  Variable ab : block.
  Hypothesis Hab : Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab.

  Definition alist_ok (al : list ident) (le : temp_env) : Prop :=
    forall t, mem_id t al = true ->
      forall b o, le ! t = Some (Vptr b o) -> b = ab /\ o = Ptrofs.zero.

  (* a pointer field loaded through an anim-list temp *)
  Definition alist_load_chk (al : list ident) (a : expr) : bool :=
    match a with
    | Efield (Ederef (Etempvar t (Tpointer _ _)) (Tstruct _ _)) _ (Tpointer _ _) =>
        mem_id t al
    | _ => false
    end.

  Lemma alist_load_sound : forall al a e le m v,
      alist_load_chk al a = true -> alist_ok al le -> MWF m ->
      eval_expr (lp_ge lp) e le m a v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof.
    intros al a e le m v Hck Hal HM Hev b o ->.
    unfold alist_load_chk in Hck.
    destruct a as [ | | | | | | | | | | | af fld fty | | ];
      try discriminate Hck.
    destruct af as [ | | | | | | ad ady | | | | | | | ];
      try discriminate Hck.
    destruct ad as [ | | | | | t1 t1ty | | | | | | | | ];
      try discriminate Hck.
    destruct t1ty; try discriminate Hck.
    destruct ady; try discriminate Hck.
    destruct fty; try discriminate Hck.
    destruct (eval_expr_Efield_load _ _ _ _ _ _ _ _ Hev)
      as (loc & ofs & bf & Hlv & Hd).
    destruct (eval_lvalue_Efield_inv _ _ _ _ _ _ _ _ _ _ Hlv)
      as (o0 & sid2 & att2 & co & delta & Hbase & _ & _ & _).
    destruct (eval_expr_Ederef_load _ _ _ _ _ _ _ Hbase)
      as (l2 & o2 & bf2 & Hlv2 & Hd2).
    apply eval_lvalue_Ederef_base in Hlv2.
    apply eval_expr_Etempvar_val in Hlv2.
    destruct (Hal _ Hck _ _ Hlv2) as [-> ->].
    assert (Eloc : loc = ab).
    { cbn [typeof] in Hd2.
      refine (proj1 (deref_loc_aggregate_eq _ _ _ _ _ _ _ _ Hd2)).
      right; reflexivity. }
    subst loc.
    cbn [typeof] in Hd. inv Hd.
    - match goal with
      | Hac : access_mode _ = By_value _ |- _ =>
          cbn [access_mode] in Hac; injection Hac as <-
      end.
      match goal with
      | Hld : Mem.loadv Mptr _ _ = Some (Vptr _ _) |- _ =>
          exact (mwf_real_anim_step lp bm bc oc0 SafeB _ ab _ _ _ HM Hab Hld)
      end.
    - match goal with
      | Hac : access_mode _ = By_reference |- _ =>
          cbn [access_mode] in Hac; discriminate Hac
      end.
    - match goal with
      | Hac : access_mode _ = By_copy |- _ =>
          cbn [access_mode] in Hac; discriminate Hac
      end.
    - match goal with
      | Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb
      end.
  Qed.

  Lemma alist_ok_set : forall al id v le,
      mem_id id al = false -> alist_ok al le -> alist_ok al (PTree.set id v le).
  Proof.
    intros al id v le Hn Hal t Ht b o Hg.
    rewrite PTree.gso in Hg by (intro E; subst; rewrite Ht in Hn; discriminate Hn).
    exact (Hal t Ht b o Hg).
  Qed.

  Definition lpt_cact : list ident :=
    [memory._table; memory._t'4; memory._addr; memory._t'2; memory._t'3].
  Definition lpt_al : list ident := [memory._list].

  Definition lpt_G (le : temp_env) : Prop :=
    chase_inv SafeB lpt_cact le /\ alist_ok lpt_al le.

  Definition lpt_set_ok (id : ident) (a : expr) : bool :=
    negb (mem_id id lpt_al)
    && (chase_set_ok lpt_cact id a || alist_load_chk lpt_al a).

  Lemma lpt_set_sound : forall id a le m v,
      lpt_set_ok id a = true -> lpt_G le -> lfacts m ->
      eval_expr (lp_ge lp) empty_env le m a v -> lpt_G (PTree.set id v le).
  Proof.
    intros id a le m v Hok (Hci & Hal) Hf Hev.
    apply andb_prop in Hok as [Hnl Hok]. apply negb_true_iff in Hnl.
    split; [ | exact (alist_ok_set _ _ _ _ Hnl Hal) ].
    apply orb_true_iff in Hok as [Hc | Ha].
    - exact (chase_set_sound lpt_cact id a le m v Hc Hci Hf Hev).
    - intros t Ht b o Hg. destruct (peq t id) as [-> | NE].
      + rewrite PTree.gss in Hg. injection Hg as Ev.
        destruct Hf as (_ & _ & M).
        exact (alist_load_sound _ _ _ _ _ _ Ha Hal M Hev b o Ev).
      + rewrite PTree.gso in Hg by exact NE. exact (Hci t Ht b o Hg).
  Qed.

  (* the DmaHandlerList layout, from memory.c's generated composite env *)
  Definition dhl_members : members :=
    match (prog_comp_env memory.prog) ! memory._DmaHandlerList with
    | Some co => co_members co
    | None => nil
    end.

  Lemma memory_defines_dhl :
    exists co, (prog_comp_env memory.prog) ! memory._DmaHandlerList = Some co.
  Proof.
    assert (H : match (prog_comp_env memory.prog) ! memory._DmaHandlerList with
                | Some _ => true | None => false end = true)
      by (vm_compute; reflexivity).
    destruct ((prog_comp_env memory.prog) ! memory._DmaHandlerList) as [co|];
      [ exists co; reflexivity | discriminate H ].
  Qed.

  Lemma dhl_complete :
    complete_members (prog_comp_env memory.prog) dhl_members = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma dhl_cur_off :
    field_offset (prog_comp_env memory.prog) memory._currentAddr dhl_members
      = OK (4, Full).
  Proof. vm_compute. reflexivity. Qed.

  (* the one store: list->currentAddr = <a SafeB-if-pointer chase temp> *)
  Definition lpt_store_ok (a1 a2 : expr) : bool :=
    match a1, a2 with
    | Efield (Ederef (Etempvar l (Tpointer _ _)) (Tstruct sid _)) f (Tpointer _ _),
      Etempvar q (Tpointer _ _) =>
        Pos.eqb l memory._list && Pos.eqb sid memory._DmaHandlerList
        && Pos.eqb f memory._currentAddr && mem_id q lpt_cact
    | _, _ => false
    end.

  Lemma lpt_store_sound : forall a1 a2 le m t le' m' out,
      lpt_store_ok a1 a2 = true -> lpt_G le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign a1 a2) t le' m' out ->
      lfacts m -> lfacts m'.
  Proof.
    intros a1 a2 le m t le' m' out Hok (Hci & Hal) H (Hv & Hs & M).
    unfold lpt_store_ok in Hok. crush_match Hok.
    inv H.
    match goal with
    | H1 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _,
      H2 : eval_expr _ _ _ _ (Etempvar _ _) _,
      H3 : sem_cast _ _ _ _ = Some _,
      H4 : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        pose proof H1 as Hlv; pose proof H2 as Hev2; pose proof H3 as Hc;
        pose proof H4 as Has; clear H1 H2 H3 H4
    end.
    apply eval_lvalue_Efield_inv in Hlv
      as (o0 & id & att & co & delta & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ].
    subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    destruct (Hal memory._list eq_refl _ _ Hlvb) as [-> ->].
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; cbn in Hty; inv Hty.
    change (genv_cenv (lp_ge lp)) with (prog_comp_env lp) in Hco, Hfo2.
    destruct memory_defines_dhl as (co0 & Hmem).
    pose proof (linkorder_comp_env_extends lp memory.prog memory._DmaHandlerList
                  co0 LO_memory Hmem) as Hext.
    assert (co = co0) by congruence. subst co0.
    assert (Hmm : dhl_members = co_members co)
      by (unfold dhl_members; rewrite Hmem; reflexivity).
    rewrite (linkorder_field_offset_agree lp memory.prog _ (co_members co)
               LO_memory) in Hfo2; [ | rewrite <- Hmm; exact dhl_complete ].
    rewrite <- Hmm, dhl_cur_off in Hfo2. inv Hfo2.
    inv Has; [ | match goal with Hac : access_mode _ = By_copy |- _ =>
                   cbn in Hac; discriminate Hac end ].
    match goal with Hac : access_mode _ = By_value _ |- _ =>
      cbn [access_mode] in Hac; injection Hac as <- end.
    match goal with H5 : Mem.storev Mptr _ _ _ = Some _ |- _ => pose proof H5 as Hst; clear H5 end.
    change (Mem.storev Mptr m (Vptr ab (Ptrofs.add Ptrofs.zero (Ptrofs.repr 4))) v
            = Some m') with (Mem.store Mptr m ab 4 v = Some m') in Hst.
    apply eval_expr_Etempvar_val in Hev2.
    destruct (mwf_real_anim_blk lp bm bc oc0 SafeB m ab M Hab) as (Abm & _).
    split; [ eapply Mem.store_valid_block_1; eauto | split ].
    - eapply action_sat_unchanged_on; [ | exact Hv | exact Hs ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Eb _]. exact (Abm Eb).
    - eapply (mwf_real_anim_cur_store lp bm bc oc0 SafeB Hbc_bm); [ exact M | exact Hab | | exact Hst ].
      intros b o ->.
      apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc. subst.
      match goal with Hm : mem_id _ lpt_cact = true |- _ =>
        exact (Hci _ Hm b o Hev2) end.
  Qed.

  Definition lpt_call_ok (o : option ident) (a : expr) (al : list expr) : bool :=
    match o, a, al with
    | None, Evar f (Tfunction _ _ _), Etempvar t0 _ :: _ =>
        Pos.eqb f memory._dma_read && mem_id t0 lpt_cact
    | _, _, _ => false
    end.

  Lemma memory_defmap_dma_read :
    (prog_defmap memory.prog) ! memory._dma_read = Some (Gfun (Internal memory.f_dma_read)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma memory_defmap_lpt :
    (prog_defmap memory.prog) ! mario._load_patchable_table
      = Some (Gfun (Internal memory.f_load_patchable_table)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma lpt_call_sound : forall o a al le m t le' m' out,
      lpt_call_ok o a al = true -> lpt_G le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall o a al) t le' m' out ->
      lfacts m -> lfacts m' /\ lpt_G le'.
  Proof.
    intros o a al le m t le' m' out Hok HG H Hf.
    destruct o as [i|]; [ discriminate Hok | ].
    rewrite (scall_none_le _ _ _ _ _ _ _ _ _ _ H). split; [ | exact HG ].
    destruct HG as (Hci & _).
    unfold lpt_call_ok in Hok. crush_match Hok.
    destruct (scall_evar_inv _ _ _ _ _ _ _ _ _ _ _ H (PTree.gempty _ _) eq_refl)
      as (b & fd & tyargs & tyres & cc & vargs & vres & Hs & Hfd & _ & Hel & Hev & _ & _).
    assert (Efd : fd = Internal memory.f_dma_read).
    { eapply RestSurface.resolves_pin_fd;
        [ exact LO_memory | exact memory_defmap_dma_read | exists b; split; eassumption ]. }
    subst fd. eapply dma_read_facts; [ exact Hev | | exact Hf ].
    intros b0 o0 Hhd. inv Hel. cbn in Hhd. injection Hhd as ->.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _,
                    Hc : sem_cast _ _ _ _ = Some (Vptr b0 o0) |- _ =>
      apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc; subst;
      match goal with Hm : mem_id _ lpt_cact = true |- _ =>
        exact (Hci _ Hm b0 o0 (tempvar_val _ _ _ _ _ Hv)) end end.
  Qed.

  Lemma lpt_chk :
    cw_chk lpt_set_ok lpt_store_ok lpt_call_ok
      (fn_body memory.f_load_patchable_table) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma lpt_facts : forall m vargs t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m
        (Internal memory.f_load_patchable_table) vargs t m' vres ->
      (forall b o, hd_error vargs = Some (Vptr b o) -> b = ab /\ o = Ptrofs.zero) ->
      lfacts m -> lfacts m'.
  Proof.
    intros m vargs t m' vres Hevf Hhd Hf.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars memory.f_load_patchable_table) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ => rename Hb into Hbind; set (le := L) in * end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
    assert (HG : lpt_G le).
    { split.
      - intros tv Ht b o Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; discriminate G0 | ].
        destruct n as [| [| n]]; cbv [memory.f_load_patchable_table fn_params map fst nth_error] in N1; try (destruct n; discriminate N1); try discriminate N1;
          injection N1 as Et; subst tv; discriminate Ht.
      - intros tv Ht b o Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; discriminate G0 | ].
        destruct n as [| [| n]]; cbv [memory.f_load_patchable_table fn_params map fst nth_error] in N1; try (destruct n; discriminate N1); try discriminate N1;
          injection N1 as Et; subst tv; try discriminate Ht.
        destruct vargs as [| v0 vl]; [ discriminate N2 | ].
        cbn in N2. injection N2 as ->. apply (Hhd b o). reflexivity. }
    destruct (cw_walk (lp_ge lp) empty_env lfacts lpt_G
                lpt_set_ok lpt_store_ok lpt_call_ok
                lpt_set_sound lpt_store_sound lpt_call_sound
                _ _ _ _ _ _ _ _ Hbody eq_refl lpt_chk HG Hf)
      as [Hf' _].
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    inv Hfree. exact Hf'.
  Qed.

  (* ---------------- THE ROW, PROVED ----------------
     A call of load_patchable_table whose list argument, if a pointer, is
     &gMarioAnimsBuf keeps Mario's block valid, the action taint fact and
     MWF.  (set_mario_animation's m->animList; AnimBody consumes it.) *)
  Theorem lpt_call_facts : forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      OutParamSurface.resolves_lp lp mario._load_patchable_table fd ->
      (forall b o, hd_error vargs0 = Some (Vptr b o) -> b = ab /\ o = Ptrofs.zero) ->
      lfacts m0 -> lfacts m1.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hev Hres Harg Hf.
    assert (Efd : fd = Internal memory.f_load_patchable_table).
    { eapply RestSurface.resolves_pin_fd;
        [ exact LO_memory | exact memory_defmap_lpt | exact Hres ]. }
    subst fd. exact (lpt_facts _ _ _ _ _ Hev Harg Hf).
  Qed.

  (* ================================================================
     set_mario_animation / set_mario_anim_with_accel: their real bodies.
     o = m->marioObj is a chase root (R6, SafeB); m->animList is the
     pinned list (R11: (ab, 0)); targetAnim = list->bufTarget is SafeB
     (R12); the call load_patchable_table(m->animList, id) is
     lpt_call_facts; every store is a chase store into SafeB o or
     targetAnim.  The walk threads: chase temps SafeB-if-pointer, list
     temps (ab, 0)-if-pointer, the Mario param (bm, 0)-if-pointer, and
     (smawa) the accel param non-pointer.
     ================================================================ *)

  Let LO_mario : linkorder mario.prog lp := linked12_LO_mario lp Hlink.

  Let Hchase := mwf_real_chase lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm HSafeB_not_bc
                  Hgms_blk Hgtimer_blk Htable_blk Hktab_blk.
  Let Hchase_ptr := mwf_real_chase_ptr lp bm bc oc0 SafeB Hbc_bm HSafeB_not_bm HSafeB_not_bc
                  Hgms_blk Hgtimer_blk Htable_blk Hktab_blk.

  Definition m_ok (le : temp_env) : Prop :=
    forall b o, le ! mario._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero.

  Definition anim_G (cact al nids : list ident) (le : temp_env) : Prop :=
    chase_inv SafeB cact le /\ alist_ok al le /\ m_ok le /\ nptr_inv nids le.

  Lemma anim_G_set : forall cact al nids id v le,
      mem_id id cact = false -> mem_id id al = false -> id <> mario._m ->
      mem_id id nids = false ->
      anim_G cact al nids le -> anim_G cact al nids (PTree.set id v le).
  Proof.
    intros cact al nids id v le H1 H2 H3 H4 (Hci & Hal & Hmo & Hnp).
    split; [ | split; [ exact (alist_ok_set _ _ _ _ H2 Hal) | split ] ].
    - intros t Ht b o Hg.
      rewrite PTree.gso in Hg by (intro E; subst; rewrite Ht in H1; discriminate H1).
      exact (Hci t Ht b o Hg).
    - intros b o Hg. rewrite PTree.gso in Hg by congruence. exact (Hmo b o Hg).
    - intros t Ht x Hg.
      rewrite PTree.gso in Hg by (intro E; subst; rewrite Ht in H4; discriminate H4).
      exact (Hnp t Ht x Hg).
  Qed.

  (* a pointer field of *m: the load is through (bm, delta) *)
  Lemma mfield_ptr_load : forall e le m fld pt pa delta v,
      m_ok le ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members = OK (delta, Full) ->
      eval_expr (lp_ge lp) e le m
        (Efield (Ederef (Etempvar mario._m (tptr tyMS)) tyMS) fld (Tpointer pt pa)) v ->
      Mem.loadv Mptr m (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta))) = Some v.
  Proof.
    intros e le m fld pt pa delta v Hmo Hfo Hev.
    destruct (eval_expr_Efield_load _ _ _ _ _ _ _ _ Hev) as (loc & ofs & bf & Hlv & Hd).
    pose proof Hlv as Hlv0.
    apply eval_lvalue_Efield_inv in Hlv0 as (o0 & id & att & co & delta' & Hbase & _ & _ & _).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    destruct (Hmo _ _ Hlvb) as [E1 E2]. subst lb ob.
    destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _ loc ofs bf _ _ _ Hlvb Hfo Hlv)
      as (E3 & E4 & E5).
    subst loc ofs bf.
    inv Hd.
    - match goal with Hac : access_mode _ = By_value _ |- _ =>
        cbn [access_mode] in Hac; injection Hac as <- end.
      assumption.
    - match goal with Hac : access_mode _ = By_reference |- _ =>
        cbn [access_mode] in Hac; discriminate Hac end.
    - match goal with Hac : access_mode _ = By_copy |- _ =>
        cbn [access_mode] in Hac; discriminate Hac end.
  Qed.

  (* m->animList *)
  Definition alist_root_chk (a : expr) : bool :=
    match a with
    | Efield (Ederef (Etempvar p pty) sty) fld (Tpointer _ _) =>
        Pos.eqb p mario._m && proj_sumbool (type_eq pty (tptr tyMS))
        && proj_sumbool (type_eq sty tyMS) && Pos.eqb fld mario._animList
    | _ => false
    end.

  (* m->marioObj and the other chase roots *)
  Definition mroot_chk (a : expr) : bool :=
    match a with
    | Efield (Ederef (Etempvar p pty) sty) fld (Tpointer _ _) =>
        Pos.eqb p mario._m && proj_sumbool (type_eq pty (tptr tyMS))
        && proj_sumbool (type_eq sty tyMS) && mem_id fld chase_root_fields
    | _ => false
    end.

  Lemma alist_root_sound : forall a e le m v,
      alist_root_chk a = true -> m_ok le -> MWF m ->
      eval_expr (lp_ge lp) e le m a v ->
      forall b o, v = Vptr b o -> b = ab /\ o = Ptrofs.zero.
  Proof.
    intros a e le m v Hck Hmo HM Hev b o ->.
    unfold alist_root_chk in Hck.
    destruct a as [ | | | | | | | | | | | af fld fty | | ]; try discriminate Hck.
    destruct af as [ | | | | | | ad sty | | | | | | | ]; try discriminate Hck.
    destruct ad as [ | | | | | p pty | | | | | | | | ]; try discriminate Hck.
    destruct fty; try discriminate Hck.
    apply andb_prop in Hck as [Hck Hfld]. apply andb_prop in Hck as [Hck Hsty].
    apply andb_prop in Hck as [Hp Hpty].
    apply Pos.eqb_eq in Hp. apply Pos.eqb_eq in Hfld. subst p fld.
    destruct (type_eq pty (tptr tyMS)); [ subst pty | discriminate Hpty ].
    destruct (type_eq sty tyMS); [ subst sty | discriminate Hsty ].
    assert (Hfo : field_offset (prog_comp_env mario.prog) mario._animList
                    mario_state_members = OK (160, Full))
      by (vm_compute; reflexivity).
    pose proof (mfield_ptr_load _ _ _ _ _ _ _ _ Hmo Hfo Hev) as Hld.
    change (Mem.loadv Mptr m (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr 160))))
      with (Mem.load Mptr m bm 160) in Hld.
    exact (mwf_real_anim_root lp bm bc oc0 SafeB m ab b o HM Hab Hld).
  Qed.

  Lemma mroot_sound : forall a e le m v,
      mroot_chk a = true -> m_ok le -> MWF m ->
      eval_expr (lp_ge lp) e le m a v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof.
    intros a e le m v Hck Hmo HM Hev b o ->.
    unfold mroot_chk in Hck.
    destruct a as [ | | | | | | | | | | | af fld fty | | ]; try discriminate Hck.
    destruct af as [ | | | | | | ad sty | | | | | | | ]; try discriminate Hck.
    destruct ad as [ | | | | | p pty | | | | | | | | ]; try discriminate Hck.
    destruct fty; try discriminate Hck.
    apply andb_prop in Hck as [Hck Hfld]. apply andb_prop in Hck as [Hck Hsty].
    apply andb_prop in Hck as [Hp Hpty].
    apply Pos.eqb_eq in Hp. subst p.
    destruct (type_eq pty (tptr tyMS)); [ subst pty | discriminate Hpty ].
    destruct (type_eq sty tyMS); [ subst sty | discriminate Hsty ].
    destruct (chase_root_field_offset _ Hfld) as (delta & Hfo).
    pose proof (mfield_ptr_load _ _ _ _ _ _ _ _ Hmo Hfo Hev) as Hld.
    exact (mwf_real_chase_root lp bm bc oc0 SafeB fld delta m b o Hfld Hfo HM Hld).
  Qed.

  Definition anim_set_ok (cact al nids : list ident) (id : ident) (a : expr) : bool :=
    negb (Pos.eqb id mario._m) && negb (mem_id id nids)
    && (if mem_id id al then negb (mem_id id cact) && alist_root_chk a
        else chase_set_ok cact id a
             || (mem_id id cact && (alist_load_chk al a || mroot_chk a))).

  Lemma anim_set_sound : forall cact al nids id a le m v,
      anim_set_ok cact al nids id a = true -> anim_G cact al nids le -> lfacts m ->
      eval_expr (lp_ge lp) empty_env le m a v -> anim_G cact al nids (PTree.set id v le).
  Proof.
    intros cact al nids id a le m v Hok HG Hf Hev.
    pose proof HG as (Hci & Hal & Hmo & Hnp).
    pose proof Hf as (_ & _ & M).
    apply andb_prop in Hok as [Hok Hrest]. apply andb_prop in Hok as [Hnm Hnn].
    apply negb_true_iff in Hnm. apply negb_true_iff in Hnn. apply Pos.eqb_neq in Hnm.
    assert (Hm' : m_ok (PTree.set id v le)).
    { intros b o Hg. rewrite PTree.gso in Hg by congruence. exact (Hmo b o Hg). }
    assert (Hnp' : nptr_inv nids (PTree.set id v le)).
    { intros t Ht x Hg.
      rewrite PTree.gso in Hg by (intro E; subst; rewrite Ht in Hnn; discriminate Hnn).
      exact (Hnp t Ht x Hg). }
    destruct (mem_id id al) eqn:Hia.
    - apply andb_prop in Hrest as [Hnc Hroot]. apply negb_true_iff in Hnc.
      split; [ | split; [ | exact (conj Hm' Hnp') ] ].
      + intros t Ht b o Hg.
        rewrite PTree.gso in Hg by (intro E; subst; rewrite Ht in Hnc; discriminate Hnc).
        exact (Hci t Ht b o Hg).
      + intros t Ht b o Hg. destruct (peq t id) as [-> | NE].
        * rewrite PTree.gss in Hg. injection Hg as Ev.
          exact (alist_root_sound _ _ _ _ _ Hroot Hmo M Hev b o Ev).
        * rewrite PTree.gso in Hg by exact NE. exact (Hal t Ht b o Hg).
    - split; [ | split; [ exact (alist_ok_set _ _ _ _ Hia Hal) | exact (conj Hm' Hnp') ] ].
      apply orb_true_iff in Hrest as [Hc | Hx].
      + exact (chase_set_sound cact id a le m v Hc Hci Hf Hev).
      + apply andb_prop in Hx as [_ Hx].
        intros t Ht b o Hg. destruct (peq t id) as [-> | NE].
        * rewrite PTree.gss in Hg. injection Hg as Ev.
          apply orb_true_iff in Hx as [Ha | Hr].
          -- exact (alist_load_sound _ _ _ _ _ _ Ha Hal M Hev b o Ev).
          -- exact (mroot_sound _ _ _ _ _ Hr Hmo M Hev b o Ev).
        * rewrite PTree.gso in Hg by exact NE. exact (Hci t Ht b o Hg).
  Qed.

  Definition anim_store_ok (cact nids : list ident) (a1 a2 : expr) : bool :=
    chase_store_chk nil cact a1 a2 || chase_ptr_store_chk cact a1 a2
    || chase_arith_store_chk cact a1 a2 || nptr_store_chk nids cact a1 a2.

  Lemma anim_store_sound : forall cact al nids a1 a2 le m t le' m' out,
      anim_store_ok cact nids a1 a2 = true -> anim_G cact al nids le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign a1 a2) t le' m' out ->
      lfacts m -> lfacts m'.
  Proof.
    intros cact al nids a1 a2 le m t le' m' out Hok (Hci & _ & _ & Hnp) H (Hv & Hs & M).
    unfold anim_store_ok in Hok.
    apply orb_true_iff in Hok as [Hok | Hnpc];
      [ apply orb_true_iff in Hok as [Hok | Har];
        [ apply orb_true_iff in Hok as [Hcs | Hpt] | ] | ].
    - assert (Hact : act_inv nil le) by (intros t0 Ht0; discriminate Ht0).
      destruct (chase_assign_pres lp bm MWF SafeB HSafeB_not_bm Hchase nil cact a1 a2
                  _ _ _ _ _ _ _ Hcs Hact Hci H M Hv Hs) as (Hv' & Hs' & M' & _).
      exact (conj Hv' (conj Hs' M')).
    - destruct (chase_ptr_assign_pres lp bm MWF SafeB HSafeB_not_bm Hchase Hchase_ptr
                  cact a1 a2 _ _ _ _ _ _ _ Hpt Hci H M Hv Hs) as (Hv' & Hs' & M' & _).
      exact (conj Hv' (conj Hs' M')).
    - destruct (chase_arith_assign_pres lp bm MWF SafeB HSafeB_not_bm Hchase Hchase_ptr
                  cact a1 a2 _ _ _ _ _ _ _ Har Hci H M Hv Hs) as (Hv' & Hs' & M' & _).
      exact (conj Hv' (conj Hs' M')).
    - unfold nptr_store_chk in Hnpc.
      destruct (chain_root_l a1) as [ct|] eqn:Hcr; [ | discriminate Hnpc ].
      destruct a2 as [ | | | | | q qty | | | | | | | | ]; try discriminate Hnpc.
      apply andb_prop in Hnpc as [Hctm Hq].
      assert (Hck2 : (match chain_root_l a1 with
                      | Some ct0 => mem_id ct0 cact
                      | None => false end) = true)
        by (rewrite Hcr; exact Hctm).
      pose proof H as Hcopy. inversion Hcopy; subst.
      match goal with
      | Hev2 : eval_expr _ _ _ _ (Etempvar q qty) _ |- _ =>
          pose proof Hev2 as Hleq; apply eval_expr_Etempvar_val in Hleq
      end.
      destruct (chase_assign_value_pres lp bm MWF SafeB HSafeB_not_bm Hchase cact a1 q qty
                  _ _ _ _ _ _ _ _ Hck2 Hci Hleq (Hnp _ Hq _ Hleq) H M Hv Hs)
        as (Hv' & Hs' & M' & _).
      exact (conj Hv' (conj Hs' M')).
  Qed.

  Definition anim_call_ok (cact al nids : list ident) (o : option ident) (a : expr)
      (args : list expr) : bool :=
    match o, a, args with
    | Some r, Evar f (Tfunction _ _ _), Etempvar t _ :: _ =>
        Pos.eqb f mario._load_patchable_table && mem_id t al
        && negb (mem_id r cact) && negb (mem_id r al)
        && negb (Pos.eqb r mario._m) && negb (mem_id r nids)
    | _, _, _ => false
    end.

  Lemma anim_call_sound : forall cact al nids o a args le m t le' m' out,
      anim_call_ok cact al nids o a args = true -> anim_G cact al nids le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall o a args) t le' m' out ->
      lfacts m -> lfacts m' /\ anim_G cact al nids le'.
  Proof.
    intros cact al nids o a args le m t le' m' out Hok HG H Hf.
    unfold anim_call_ok in Hok. crush_match Hok.
    destruct (scall_evar_inv_opt _ _ _ _ _ _ _ _ _ _ _ _ H (PTree.gempty _ _) eq_refl)
      as (b & fd & tyargs & tyres & cc & vargs & vres & Hsb & Hfd & _ & Hel & Hev & -> & _).
    split.
    - eapply lpt_call_facts; [ exact Hev | exists b; split; eassumption | | exact Hf ].
      destruct HG as (_ & Hal & _).
      intros b0 o0 Hhd. inv Hel. cbn in Hhd. injection Hhd as ->.
      match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _,
                      Hc : sem_cast _ _ _ _ = Some (Vptr b0 o0) |- _ =>
        apply (sem_cast_vptr_inv _ _ _ _ _ _) in Hc; subst;
        match goal with Hmm : mem_id _ al = true |- _ =>
          exact (Hal _ Hmm b0 o0 (tempvar_val _ _ _ _ _ Hv)) end end.
    - cbn [set_opttemp].
      repeat match goal with Hn : negb _ = true |- _ => apply negb_true_iff in Hn end.
      apply anim_G_set; try assumption.
      match goal with Hn : Pos.eqb _ mario._m = false |- _ => apply Pos.eqb_neq in Hn; exact Hn end.
  Qed.

  Lemma anim_body_facts : forall cact al nids f vargs m t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
      fn_vars f = nil ->
      cw_chk (anim_set_ok cact al nids) (anim_store_ok cact nids)
        (anim_call_ok cact al nids) (fn_body f) = true ->
      (forall le, bind_parameter_temps (fn_params f) vargs
                    (create_undef_temps (fn_temps f)) = Some le -> anim_G cact al nids le) ->
      lfacts m -> lfacts m'.
  Proof.
    intros cact al nids f vargs m t m' vres Hevf Hvars Hchk Hent Hf.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rewrite Hvars in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => pose proof (Hent _ Hb) as HG end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
    destruct (cw_walk (lp_ge lp) empty_env lfacts (anim_G cact al nids)
                (anim_set_ok cact al nids) (anim_store_ok cact nids) (anim_call_ok cact al nids)
                (anim_set_sound cact al nids) (anim_store_sound cact al nids)
                (anim_call_sound cact al nids)
                _ _ _ _ _ _ _ _ Hbody eq_refl Hchk HG Hf)
      as [Hf' _].
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    inv Hfree. exact Hf'.
  Qed.

  (* ---- set_mario_animation ---- *)
  Definition sma_cact : list ident := [mario._o; mario._targetAnim].
  Definition sma_al : list ident := [mario._t'13; mario._t'12].

  Lemma sma_pin :
    (prog_defmap mario.prog) ! mario._set_mario_animation
      = Some (Gfun (Internal mario.f_set_mario_animation)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma sma_chk :
    cw_chk (anim_set_ok sma_cact sma_al nil) (anim_store_ok sma_cact nil)
      (anim_call_ok sma_cact sma_al nil) (fn_body mario.f_set_mario_animation) = true.
  Proof. vm_compute. reflexivity. Qed.

  Theorem sma_row_proved :
    call_pres lp bm (fun m => ctl_a_clear m bm) MWF mario._set_mario_animation.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hev Hres Hmarg _ HM Hv Hs.
    assert (Efd : fd = Internal mario.f_set_mario_animation).
    { eapply RestSurface.resolves_pin_fd; [ exact LO_mario | exact sma_pin | exact Hres ]. }
    subst fd.
    assert (Hf' : lfacts m1).
    { refine (anim_body_facts sma_cact sma_al nil _ _ _ _ _ _ Hev eq_refl sma_chk _
                (conj Hv (conj Hs HM))).
      intros le Hbind. split; [ | split; [ | split ] ].
      - intros tv Ht b o Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; discriminate G0 | ].
        destruct n as [| [| n]]; cbv [mario.f_set_mario_animation fn_params map fst nth_error] in N1;
          try (destruct n; discriminate N1); try discriminate N1;
          injection N1 as Et; subst tv; discriminate Ht.
      - intros tv Ht b o Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; discriminate G0 | ].
        destruct n as [| [| n]]; cbv [mario.f_set_mario_animation fn_params map fst nth_error] in N1;
          try (destruct n; discriminate N1); try discriminate N1;
          injection N1 as Et; subst tv; discriminate Ht.
      - intros b o Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; discriminate G0 | ].
        destruct n as [| [| n]]; cbv [mario.f_set_mario_animation fn_params map fst nth_error] in N1;
          try (destruct n; discriminate N1); try discriminate N1.
        destruct vargs0 as [| v0 vl]; [ discriminate N2 | ].
        cbn in N2. injection N2 as ->. exact Hmarg.
      - intros tv Ht. discriminate Ht. }
    destruct Hf' as (Hv' & Hs' & M').
    exact (conj Hv' (conj Hs' (conj M' (mwf_real_ctl lp bm bc oc0 SafeB m1 M')))).
  Qed.

  (* ---- set_mario_anim_with_accel ---- *)
  Definition smawa_cact : list ident := [mario._o; mario._targetAnim].
  Definition smawa_al : list ident := [mario._t'14; mario._t'13].
  Definition smawa_nids : list ident := [mario._accel].

  Lemma smawa_pin :
    (prog_defmap mario.prog) ! mario._set_mario_anim_with_accel
      = Some (Gfun (Internal mario.f_set_mario_anim_with_accel)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma smawa_chk :
    cw_chk (anim_set_ok smawa_cact smawa_al smawa_nids) (anim_store_ok smawa_cact smawa_nids)
      (anim_call_ok smawa_cact smawa_al smawa_nids)
      (fn_body mario.f_set_mario_anim_with_accel) = true.
  Proof. vm_compute. reflexivity. Qed.

  Theorem smawa_row_proved :
    call_pres_np3 lp bm (fun m => ctl_a_clear m bm) MWF mario._set_mario_anim_with_accel.
  Proof.
    intros fd m0 v0 v1 v2 rest t0 m1 vres0 Hev Hres Hmarg Hv2 _ HM Hv Hs.
    assert (Efd : fd = Internal mario.f_set_mario_anim_with_accel).
    { eapply RestSurface.resolves_pin_fd; [ exact LO_mario | exact smawa_pin | exact Hres ]. }
    subst fd.
    assert (Hf' : lfacts m1).
    { refine (anim_body_facts smawa_cact smawa_al smawa_nids _ _ _ _ _ _ Hev eq_refl smawa_chk _
                (conj Hv (conj Hs HM))).
      intros le Hbind. split; [ | split; [ | split ] ].
      - intros tv Ht b o Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; discriminate G0 | ].
        destruct n as [| [| [| n]]]; cbv [mario.f_set_mario_anim_with_accel fn_params map fst nth_error] in N1;
          try (destruct n; discriminate N1); try discriminate N1;
          injection N1 as Et; subst tv; discriminate Ht.
      - intros tv Ht b o Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; discriminate G0 | ].
        destruct n as [| [| [| n]]]; cbv [mario.f_set_mario_anim_with_accel fn_params map fst nth_error] in N1;
          try (destruct n; discriminate N1); try discriminate N1;
          injection N1 as Et; subst tv; discriminate Ht.
      - intros b o Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; discriminate G0 | ].
        destruct n as [| [| [| n]]]; cbv [mario.f_set_mario_anim_with_accel fn_params map fst nth_error] in N1;
          try (destruct n; discriminate N1); try discriminate N1.
        cbn in N2. injection N2 as ->. exact Hmarg.
      - intros tv Ht x Hg.
        destruct (bind_get _ _ _ _ Hbind _ _ Hg) as [G0 | (n & N1 & N2)];
          [ apply undef_temps_get in G0; subst x; discriminate | ].
        destruct n as [| [| [| n]]]; cbv [mario.f_set_mario_anim_with_accel fn_params map fst nth_error] in N1;
          try (destruct n; discriminate N1); try discriminate N1;
          injection N1 as Et; subst tv; try discriminate Ht.
        cbn in N2. injection N2 as <-. exact Hv2. }
    destruct Hf' as (Hv' & Hs' & M').
    exact (conj Hv' (conj Hs' (conj M' (mwf_real_ctl lp bm bc oc0 SafeB m1 M')))).
  Qed.

End LptFrame.

(* gMarioAnimsBuf is a symbol of the linked program (mario.c declares it) *)
Lemma anims_buf_resolves : forall lp, linked12 lp ->
    exists ab, Genv.find_symbol (lp_ge lp) mario._gMarioAnimsBuf = Some ab.
Proof.
  intros lp H12.
  assert (Hdm : exists gd, (prog_defmap mario.prog) ! mario._gMarioAnimsBuf = Some gd).
  { destruct ((prog_defmap mario.prog) ! mario._gMarioAnimsBuf) as [gd|] eqn:E;
      [ eauto | vm_compute in E; discriminate E ]. }
  destruct Hdm as (gd & Hdm).
  exact (linkorder_resolves_symbol lp mario.prog _ gd (linked12_LO_mario lp H12) Hdm).
Qed.

(* the rows in the capstones' shape: their spawn condition and SafeB
   boundary give LptFrame's block facts (SpawnInit) *)
Theorem sma_row_linked12 : forall lp bm bc oc0 SafeB,
    linked12 lp ->
    SafeB_syms_ok lp SafeB ->
    (exists init, spawn_ok lp init bm bc oc0) ->
    os_dma_floor ->
    call_pres lp bm (fun m => ctl_a_clear m bm)
      (MWF_real lp bm bc oc0 SafeB) mario._set_mario_animation.
Proof.
  intros lp bm bc oc0 SafeB H12 Hiff (init & Hs) Hfl.
  destruct (anims_buf_resolves lp H12) as (ab & Hab).
  exact (sma_row_proved lp bm bc oc0 SafeB
           (spawn_Hbc_bm lp init bm bc oc0 Hs)
           (safeb_not_bm lp init bm bc oc0 SafeB Hs Hiff)
           (safeb_not_bc lp init bm bc oc0 SafeB Hs Hiff)
           (gms_blk lp init bm bc oc0 SafeB Hs Hiff)
           (glob_blk lp init bm bc oc0 SafeB Hs Hiff)
           (gtimer_blk lp init bm bc oc0 SafeB Hs Hiff)
           (table_blk lp init bm bc oc0 SafeB Hs Hiff)
           (ktab_blk lp init bm bc oc0 SafeB Hs Hiff)
           H12 Hfl ab Hab).
Qed.

Theorem smawa_row_linked12 : forall lp bm bc oc0 SafeB,
    linked12 lp ->
    SafeB_syms_ok lp SafeB ->
    (exists init, spawn_ok lp init bm bc oc0) ->
    os_dma_floor ->
    call_pres_np3 lp bm (fun m => ctl_a_clear m bm)
      (MWF_real lp bm bc oc0 SafeB) mario._set_mario_anim_with_accel.
Proof.
  intros lp bm bc oc0 SafeB H12 Hiff (init & Hs) Hfl.
  destruct (anims_buf_resolves lp H12) as (ab & Hab).
  exact (smawa_row_proved lp bm bc oc0 SafeB
           (spawn_Hbc_bm lp init bm bc oc0 Hs)
           (safeb_not_bm lp init bm bc oc0 SafeB Hs Hiff)
           (safeb_not_bc lp init bm bc oc0 SafeB Hs Hiff)
           (gms_blk lp init bm bc oc0 SafeB Hs Hiff)
           (glob_blk lp init bm bc oc0 SafeB Hs Hiff)
           (gtimer_blk lp init bm bc oc0 SafeB Hs Hiff)
           (table_blk lp init bm bc oc0 SafeB Hs Hiff)
           (ktab_blk lp init bm bc oc0 SafeB Hs Hiff)
           H12 Hfl ab Hab).
Qed.
