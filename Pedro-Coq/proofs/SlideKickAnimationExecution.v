From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import us_memory jp_memory us_mario jp_mario.
From Pedro.Proofs Require Import GameTypes TTCCogExecution SlideKickDustExecution.
Import ListNotations.
Open Scope Z_scope.
Module AM := us_mario.
Module DM := us_memory.

Definition animation_cache_function version : function :=
  match version with VersionUS => DM.f_load_patchable_table
                   | VersionJP => jp_memory.f_load_patchable_table end.

Record animation_cache_layout (ge : Clight.genv) : Type := {
  cache_list_co : composite;
  cache_table_co : composite;
  cache_pair_co : composite;
  cache_list_lookup : (genv_cenv ge) ! DM._DmaHandlerList = Some cache_list_co;
  cache_table_pointer_offset : field_offset (genv_cenv ge) DM._dmaTable
    (co_members cache_list_co) = OK (0, Full);
  cache_current_offset : field_offset (genv_cenv ge) DM._currentAddr
    (co_members cache_list_co) = OK (4, Full);
  cache_buffer_offset : field_offset (genv_cenv ge) DM._bufTarget
    (co_members cache_list_co) = OK (8, Full);
  cache_table_lookup : (genv_cenv ge) ! DM._DmaTable = Some cache_table_co;
  cache_count_offset : field_offset (genv_cenv ge) DM._count
    (co_members cache_table_co) = OK (0, Full);
  cache_source_offset : field_offset (genv_cenv ge) DM._srcAddr
    (co_members cache_table_co) = OK (4, Full);
  cache_entries_offset : field_offset (genv_cenv ge) DM._anim
    (co_members cache_table_co) = OK (8, Full);
  cache_pair_lookup : (genv_cenv ge) ! DM._OffsetSizePair = Some cache_pair_co;
  cache_pair_size : co_sizeof cache_pair_co = 8;
  cache_entry_offset : field_offset (genv_cenv ge) DM._offset
    (co_members cache_pair_co) = OK (0, Full);
  cache_entry_size_offset : field_offset (genv_cenv ge) DM._size
    (co_members cache_pair_co) = OK (4, Full)
}.

Definition cache_target_offset (base : ptrofs) (entry_offset : int) : ptrofs :=
  Ptrofs.add base (Ptrofs.mul (Ptrofs.repr 1) (Ptrofs.of_int entry_offset)).

(** The live table has a readable entry 140, its advertised count includes it,
    and currentAddr already equals its source address. These are cache-hit
    entry facts, not a claim that a controller trace has established them. *)
Definition slide_animation_cache_image memory list table source base entries entry_offset size : Prop :=
  Mem.load Mptr memory list 0 = Some (Vptr table Ptrofs.zero) /\
  Mem.load Mint32 memory table 0 = Some (Vint entries) /\
  Int.ltu (Int.repr 140) entries = true /\
  Mem.load Mptr memory table 4 = Some (Vptr source base) /\
  Mem.load Mint32 memory table 1128 = Some (Vint entry_offset) /\
  Mem.load Mint32 memory table 1132 = Some (Vint size) /\
  Mem.load Mptr memory list 4 = Some (Vptr source (cache_target_offset base entry_offset)) /\
  Mem.weak_valid_pointer memory source
    (Ptrofs.unsigned (cache_target_offset base entry_offset)) = true.

Lemma animation_cached_pointer_comparison :
  forall ge memory b offset,
    Mem.weak_valid_pointer memory b (Ptrofs.unsigned offset) = true ->
    sem_binary_operation ge One (Vptr b offset) (tptr tuchar)
      (Vptr b offset) (tptr tvoid) memory = Some (Vint Int.zero).
Proof.
  intros ge memory b offset Hvalid.
  cbn. unfold cmp_ptr. cbn [Val.cmpu_bool].
  unfold eq_block. rewrite Coqlib.peq_true.
  change ((Mem.valid_pointer memory b (Ptrofs.unsigned offset) ||
    Mem.valid_pointer memory b (Ptrofs.unsigned offset - 1))%bool = true) in Hvalid.
  rewrite Hvalid. cbn. rewrite Ptrofs.eq_true. reflexivity.
Qed.

Ltac animation_reduce :=
  cbn -[Ptrofs.repr Ptrofs.add Ptrofs.mul Ptrofs.of_int Ptrofs.of_ints
    Int.ltu Int.eq Val.of_bool].

Lemma animation_entry_address : forall ce memory b base co,
  ce ! DM._OffsetSizePair = Some co -> co_sizeof co = 8 ->
  sem_binary_operation ce Oadd (Vptr b base)
    (tarray (Tstruct DM._OffsetSizePair noattr) 1)
    (Vint (Int.repr 140)) tint memory =
    Some (Vptr b (Ptrofs.add base (Ptrofs.repr 1120))).
Proof.
  intros ce memory b base co Hco Hsize.
  change (Some (Vptr b (Ptrofs.add base
    (Ptrofs.mul (Ptrofs.repr (sizeof ce (Tstruct DM._OffsetSizePair noattr)))
      (Ptrofs.of_ints (Int.repr 140))))) =
    Some (Vptr b (Ptrofs.add base (Ptrofs.repr 1120)))).
  cbn [sizeof]. rewrite Hco, Hsize. reflexivity.
Qed.

Ltac animation_normalize :=
  first [solve [eapply animation_entry_address; eassumption] |
    solve [match goal with
    | H : Int.ltu ?x ?y = true |- _ = ?result =>
        change (Some (Val.of_bool (Int.ltu x y)) = result); rewrite H; reflexivity
    | H : Int.eq ?x ?y = false |- _ = ?result =>
        change (Some (Val.of_bool (Int.eq x y)) = result); rewrite H; reflexivity
    end] |
    solve [eapply animation_cached_pointer_comparison; eassumption] |
    animation_reduce;
    repeat match goal with
    | H : (genv_cenv _) ! _ = Some _ |- _ => progress rewrite H; animation_reduce
    | H : co_sizeof _ = _ |- _ => progress rewrite H; animation_reduce
    | H : Int.ltu _ _ = true |- _ => progress rewrite H; animation_reduce
    | H : Int.eq _ _ = false |- _ => progress rewrite H; animation_reduce
    end;
    first [reflexivity | eassumption |
      match goal with |- ?G => idtac "ANIMATION NORMALIZE" G end; fail 100]].

Ltac animation_load :=
  animation_reduce;
  repeat match goal with
  | H : (genv_cenv _) ! _ = Some _ |- _ => progress rewrite H; animation_reduce
  | H : co_sizeof _ = _ |- _ => progress rewrite H; animation_reduce
  end;
  first [cog_memory_load |
    match goal with |- ?G => idtac "ANIMATION LOAD" G end; fail 100].

Ltac animation_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ => eapply eval_Etempvar; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [animation_expr | animation_expr | animation_normalize]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [animation_expr | animation_normalize]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [animation_lvalue |
       first [eapply deref_loc_value; [reflexivity | animation_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with animation_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; animation_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct; [animation_expr | reflexivity | eassumption | eassumption]
  end.

Ltac animation_arguments :=
  first [apply eval_Enil |
    eapply eval_Econs; [animation_expr | cbn; reflexivity | animation_arguments]].

Ltac animation_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [animation_stmt | animation_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; animation_expr
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [animation_expr |
       first [cbn; reflexivity | match goal with |- ?G => idtac "ANIMATION BOOL" G end; fail 100] |
       cog_reduce_statement; animation_stmt]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; animation_expr
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | animation_expr | animation_arguments |
       eapply cog_find_funct_zero; eassumption | reflexivity | eassumption]
  end.

Theorem generated_slide_animation_cache_hit_us_jp :
  forall version (ge : Clight.genv) memory list table source base entries entry_offset size,
    animation_cache_layout ge ->
    slide_animation_cache_image memory list table source base entries entry_offset size ->
    eval_funcall function_entry2 ge memory (Internal (animation_cache_function version))
      [Vptr list Ptrofs.zero; Vint (Int.repr 140)] E0 memory (Vint Int.zero).
Proof.
  intros version ge memory list table source base entries entry_offset size Hlayout Himage.
  destruct Hlayout. unfold slide_animation_cache_image in Himage.
  destruct Himage as [Htable [Hcount [Hbound [Hsource [Hoffset [Hsize [Hcurrent Hvalid]]]]]]].
  assert (Hfunction : animation_cache_function version = DM.f_load_patchable_table)
    by (destruct version; reflexivity).
  rewrite Hfunction. eapply eval_funcall_internal.
  - eapply function_entry2_intro;
    [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
     vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
     cbn; apply alloc_variables_nil | cbn; reflexivity].
  - timeout 10 (simpl fn_body; animation_stmt).
  - cbn; split; [discriminate | reflexivity].
  - cbn; reflexivity.
Qed.

Record slide_animation_layout (ge : Clight.genv) (caller : slide_caller_layout ge) : Type := {
  animation_info_co : composite;
  animation_data_co : composite;
  animation_list_offset : field_offset (genv_cenv ge) AM._animList
    (co_members (slide_mario_co ge caller)) = OK (160, Full);
  animation_info_offset : field_offset (genv_cenv ge) AM._animInfo
    (co_members (slide_gfx_co ge caller)) = OK (56, Full);
  animation_info_lookup : (genv_cenv ge) ! AM._AnimInfo = Some animation_info_co;
  animation_id_offset : field_offset (genv_cenv ge) AM._animID
    (co_members animation_info_co) = OK (0, Full);
  animation_frame_offset : field_offset (genv_cenv ge) AM._animFrame
    (co_members animation_info_co) = OK (8, Full);
  animation_current_offset : field_offset (genv_cenv ge) AM._curAnim
    (co_members animation_info_co) = OK (4, Full);
  animation_data_lookup : (genv_cenv ge) ! AM._Animation = Some animation_data_co;
  animation_end_offset : field_offset (genv_cenv ge) AM._loopEnd
    (co_members animation_data_co) = OK (8, Full)
}.

Definition slide_animation_state_image memory mario object list target frame loop_end : Prop :=
  Mem.load Mptr memory mario 136 = Some (Vptr object Ptrofs.zero) /\
  Mem.load Mptr memory mario 160 = Some (Vptr list Ptrofs.zero) /\
  Mem.load Mptr memory list 8 = Some (Vptr target Ptrofs.zero) /\
  Mem.load Mint16signed memory object 56 = Some (Vint (Int.repr 140)) /\
  Mem.load Mint16signed memory object 64 = Some (Vint frame) /\
  Mem.load Mptr memory object 60 = Some (Vptr target Ptrofs.zero) /\
  Mem.load Mint16signed memory target 8 = Some (Vint loop_end) /\
  Int.eq (Int.add frame Int.one) loop_end = false.

Theorem generated_slide_animation_not_at_end_us_jp :
  forall version (ge : Clight.genv) memory mario object list target frame loop_end
    (caller : slide_caller_layout ge),
    slide_animation_layout ge caller ->
    slide_animation_state_image memory mario object list target frame loop_end ->
    eval_funcall function_entry2 ge memory (Internal (slide_animation_end_function version))
      [Vptr mario Ptrofs.zero] E0 memory (Vint Int.zero).
Proof.
  intros version ge memory mario object list target frame loop_end caller Hlayout Himage.
  destruct Hlayout. destruct caller.
  destruct Himage as [Hobject [Hlist [Hbuffer [Hid [Hframe [Hcurrent [Hend Hnotend]]]]]]].
  assert (Hfunction : slide_animation_end_function version = AM.f_is_anim_at_end)
    by (destruct version; reflexivity).
  rewrite Hfunction. eapply eval_funcall_internal.
  - eapply function_entry2_intro;
    [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
     vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
     cbn; apply alloc_variables_nil | cbn; reflexivity].
  - timeout 10 (simpl fn_body; animation_stmt).
  - cbn; split; [discriminate | reflexivity].
  - cbn; reflexivity.
Qed.

(** The setter executes the actual table helper and its cache-hit branch.
    Animation ID 140 is already selected, so all animation fields and the
    entire memory are unchanged. No relocation/DMA execution is assumed. *)
Theorem generated_slide_animation_setter_cache_hit_us_jp :
  forall version (ge : Clight.genv) memory mario object list target frame loop_end
    table source base entries entry_offset size code (caller : slide_caller_layout ge),
    slide_animation_layout ge caller ->
    animation_cache_layout ge ->
    Genv.find_symbol ge AM._load_patchable_table = Some code ->
    Genv.find_funct_ptr ge code = Some (Internal (animation_cache_function version)) ->
    slide_animation_state_image memory mario object list target frame loop_end ->
    slide_animation_cache_image memory list table source base entries entry_offset size ->
    eval_funcall function_entry2 ge memory (Internal (slide_animation_function version))
      [Vptr mario Ptrofs.zero; Vint (Int.repr 140)] E0 memory
      (Vint (Int.sign_ext 16 frame)).
Proof.
  intros version ge memory mario object list target frame loop_end table source base entries
    entry_offset size code caller Hlayout Hcache_layout Hsymbol Hcode Himage Hcache_image.
  pose proof (generated_slide_animation_cache_hit_us_jp version ge memory list table source
    base entries entry_offset size Hcache_layout Hcache_image) as Hcache.
  assert (Hcache_function : animation_cache_function version = DM.f_load_patchable_table)
    by (destruct version; reflexivity).
  rewrite Hcache_function in Hcode, Hcache.
  destruct Hlayout. destruct caller. destruct Hcache_layout.
  destruct Himage as [Hobject [Hlist [Hbuffer [Hid [Hframe [Hcurrent [Hend Hnotend]]]]]]].
  assert (Hfunction : slide_animation_function version = AM.f_set_mario_animation)
    by (destruct version; reflexivity).
  rewrite Hfunction. eapply eval_funcall_internal.
  - eapply function_entry2_intro;
    [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
     vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
     cbn; apply alloc_variables_nil | cbn; reflexivity].
  - timeout 10 (simpl fn_body; animation_stmt).
  - cbn; split; [discriminate | reflexivity].
  - cbn; reflexivity.
Qed.

Definition animation_layout_offsets version : list (res (Z * bitfield)) :=
  let ce := prog_comp_env (match version with VersionUS => AM.prog
                        | VersionJP => jp_mario.prog end) in
  map (fun item => field_offset ce (snd item)
    (match ce ! (fst item) with Some co => co_members co | None => [] end))
    [(AM._MarioState, AM._animList); (AM._GraphNodeObject, AM._animInfo);
     (AM._AnimInfo, AM._animID); (AM._AnimInfo, AM._animFrame);
     (AM._AnimInfo, AM._curAnim); (AM._Animation, AM._loopEnd)].

Definition animation_cache_layout_offsets version : list (res (Z * bitfield)) :=
  let ce := prog_comp_env (match version with VersionUS => DM.prog
                        | VersionJP => jp_memory.prog end) in
  map (fun item => field_offset ce (snd item)
    (match ce ! (fst item) with Some co => co_members co | None => [] end))
    [(DM._DmaHandlerList, DM._dmaTable); (DM._DmaHandlerList, DM._currentAddr);
     (DM._DmaHandlerList, DM._bufTarget); (DM._DmaTable, DM._count);
     (DM._DmaTable, DM._srcAddr); (DM._DmaTable, DM._anim);
     (DM._OffsetSizePair, DM._offset); (DM._OffsetSizePair, DM._size)].

Definition animation_layout_receipt : Prop :=
  forall version,
    animation_layout_offsets version =
      map (fun offset => OK (offset, Full)) [160;56;0;8;4;8] /\
    animation_cache_layout_offsets version =
      map (fun offset => OK (offset, Full)) [0;4;8;0;4;8;0;4] /\
    sizeof (prog_comp_env (match version with VersionUS => DM.prog
                         | VersionJP => jp_memory.prog end))
      (Tstruct DM._OffsetSizePair noattr) = 8.

Theorem animation_layout_generated_us_jp : animation_layout_receipt.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.
