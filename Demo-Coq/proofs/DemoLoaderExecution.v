From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_memory jp_memory.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution.
Import ListNotations.
Open Scope Z_scope.
Module M := us_memory.

(** Exact layouts used by load_patchable_table, characterized independently of
    any particular linked environment or retail initialization. *)
Record demo_loader_layout (ge : Clight.genv) : Type := {
  loader_handler_co : composite;
  loader_table_co : composite;
  loader_pair_co : composite;
  loader_handler_lookup : (genv_cenv ge) ! M._DmaHandlerList = Some loader_handler_co;
  loader_table_lookup : (genv_cenv ge) ! M._DmaTable = Some loader_table_co;
  loader_pair_lookup : (genv_cenv ge) ! M._OffsetSizePair = Some loader_pair_co;
  loader_handler_table_offset : field_offset (genv_cenv ge) M._dmaTable
    (co_members loader_handler_co) = OK (0, Full);
  loader_handler_current_offset : field_offset (genv_cenv ge) M._currentAddr
    (co_members loader_handler_co) = OK (4, Full);
  loader_handler_target_offset : field_offset (genv_cenv ge) M._bufTarget
    (co_members loader_handler_co) = OK (8, Full);
  loader_table_count_offset : field_offset (genv_cenv ge) M._count
    (co_members loader_table_co) = OK (0, Full);
  loader_table_source_offset : field_offset (genv_cenv ge) M._srcAddr
    (co_members loader_table_co) = OK (4, Full);
  loader_table_anim_offset : field_offset (genv_cenv ge) M._anim
    (co_members loader_table_co) = OK (8, Full);
  loader_pair_offset_offset : field_offset (genv_cenv ge) M._offset
    (co_members loader_pair_co) = OK (0, Full);
  loader_pair_size_offset : field_offset (genv_cenv ge) M._size
    (co_members loader_pair_co) = OK (4, Full);
  loader_pair_size : co_sizeof loader_pair_co = 8
}.

Definition demo_loader_handler_members : members :=
  [Member_plain M._dmaTable (tptr (Tstruct M._DmaTable noattr));
   Member_plain M._currentAddr (tptr tvoid);
   Member_plain M._bufTarget (tptr tvoid)].

Definition demo_loader_pair_members : members :=
  [Member_plain M._offset tuint; Member_plain M._size tuint].

Definition demo_loader_table_members : members :=
  [Member_plain M._count tuint; Member_plain M._srcAddr (tptr tuchar);
   Member_plain M._anim (tarray (Tstruct M._OffsetSizePair noattr) 1)].

Lemma generated_demo_loader_handler_definition :
  In (Composite M._DmaHandlerList Struct demo_loader_handler_members noattr)
    (prog_types M.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Lemma generated_demo_loader_pair_definition :
  In (Composite M._OffsetSizePair Struct demo_loader_pair_members noattr)
    (prog_types M.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Lemma generated_demo_loader_table_definition :
  In (Composite M._DmaTable Struct demo_loader_table_members noattr)
    (prog_types M.prog).
Proof. vm_compute. repeat first [left; reflexivity | right]. Qed.

Theorem generated_demo_loader_layout_exists : forall ge,
  genv_cenv ge = prog_comp_env M.prog ->
  exists layout : demo_loader_layout ge, True.
Proof.
  intros ge Hce.
  destruct (build_composite_env_charact M._DmaHandlerList Struct
    demo_loader_handler_members noattr (prog_types M.prog) (prog_comp_env M.prog)
    (prog_comp_env_eq M.prog) generated_demo_loader_handler_definition)
    as (handler_co & Hhandler & Hhm & Hha & Hhs).
  destruct (build_composite_env_charact M._OffsetSizePair Struct
    demo_loader_pair_members noattr (prog_types M.prog) (prog_comp_env M.prog)
    (prog_comp_env_eq M.prog) generated_demo_loader_pair_definition)
    as (pair_co & Hpair & Hpm & Hpa & Hps).
  destruct (build_composite_env_charact M._DmaTable Struct
    demo_loader_table_members noattr (prog_types M.prog) (prog_comp_env M.prog)
    (prog_comp_env_eq M.prog) generated_demo_loader_table_definition)
    as (table_co & Htable & Htm & Hta & Hts).
  pose proof (build_composite_env_consistent _ _ (prog_comp_env_eq M.prog)
    _ _ Hpair) as Hconsistent.
  destruct Hconsistent as [Hcomplete Halign Hsize Hrank].
  assert (Hsizeof : co_sizeof pair_co = 8).
  { rewrite Hsize, Halign, Hpm, Hpa, Hps. reflexivity. }
  assert (Hpairalign : co_alignof pair_co = 4).
  { rewrite Halign, Hpm, Hpa. reflexivity. }
  assert (Hpair_ge : (genv_cenv ge) ! M._OffsetSizePair = Some pair_co).
  { rewrite Hce. exact Hpair. }
  refine (ex_intro _ {| loader_handler_co := handler_co;
    loader_table_co := table_co; loader_pair_co := pair_co;
    loader_handler_lookup := _; loader_table_lookup := _;
    loader_pair_lookup := _; loader_handler_table_offset := _;
    loader_handler_current_offset := _; loader_handler_target_offset := _;
    loader_table_count_offset := _; loader_table_source_offset := _;
    loader_table_anim_offset := _; loader_pair_offset_offset := _;
    loader_pair_size_offset := _; loader_pair_size := Hsizeof |} I).
  - rewrite Hce. exact Hhandler.
  - rewrite Hce. exact Htable.
  - rewrite Hce. exact Hpair.
  - rewrite Hhm. reflexivity.
  - rewrite Hhm. reflexivity.
  - rewrite Hhm. reflexivity.
  - rewrite Htm. reflexivity.
  - rewrite Htm. reflexivity.
  - rewrite Htm.
    change (OK (Coqlib.align 64
      ((match (genv_cenv ge) ! M._OffsetSizePair with
        | Some co => co_alignof co | None => 1 end) * 8) / 8, Full) = OK (8, Full)).
    rewrite Hpair_ge. cbn. rewrite Hpairalign. reflexivity.
  - rewrite Hpm. reflexivity.
  - rewrite Hpm. reflexivity.
Qed.

Definition demo_loader_source_offset (offset : int) : ptrofs :=
  Ptrofs.add Ptrofs.zero
    (Ptrofs.mul (Ptrofs.repr 1) (Ptrofs.of_intu offset)).

Definition demo_loader_source_end (offset size : int) : ptrofs :=
  Ptrofs.add (demo_loader_source_offset offset)
    (Ptrofs.mul (Ptrofs.repr 1) (Ptrofs.of_ints size)).

Definition demo_loader_initial_temps (f : function) (handler : block) : temp_env :=
  PTree.set M._index (Vint Int.zero)
    (PTree.set M._list (Vptr handler Ptrofs.zero)
      (create_undef_temps (fn_temps f))).

Lemma generated_demo_loader_function_entry : forall ge before handler,
  function_entry2 ge M.f_load_patchable_table
    [Vptr handler Ptrofs.zero; Vint Int.zero] before (PTree.empty _)
    (demo_loader_initial_temps M.f_load_patchable_table handler) before.
Proof.
  intros ge before handler. apply function_entry2_intro.
  - apply Coqlib.list_norepet_nil.
  - apply Coqlib.list_norepet_cons; [vm_compute; intuition congruence |].
    apply Coqlib.list_norepet_cons;
      [vm_compute; intuition congruence | apply Coqlib.list_norepet_nil].
  - vm_compute. intuition congruence.
  - apply alloc_variables_nil.
  - reflexivity.
Qed.

Ltac loader_normalize :=
  first [match goal with
    | H : Int.ltu ?x ?y = true |- _ = ?out =>
        change (Some (Val.of_bool (Int.ltu x y)) = out);
        rewrite H; reflexivity
    end |
    demo_reduce;
    first [reflexivity | eassumption |
      eapply demo_valid_nonnull_pointer_comparison; eassumption]].

Ltac loader_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn [set_opttemp demo_loader_initial_temps];
      repeat rewrite PTree.gsspec; cbn; first [eassumption | reflexivity]
  | |- eval_expr _ _ _ _ (Esizeof _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [loader_expr | loader_expr | loader_normalize]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [loader_expr | loader_normalize]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [loader_lvalue |
        first [eapply deref_loc_value; [reflexivity | cbn; dls_load]
              |eapply deref_loc_reference; reflexivity
              |eapply deref_loc_copy; reflexivity]]
  end
with loader_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ =>
      eapply eval_Ederef; loader_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [loader_expr | reflexivity | eassumption | eassumption]
  end.

Ltac loader_arguments :=
  first [apply eval_Enil |
    eapply eval_Econs; [loader_expr | loader_normalize | loader_arguments]].

Ltac loader_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [loader_stmt | loader_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; loader_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [loader_lvalue | loader_expr | loader_normalize |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse; [loader_expr | reflexivity |
       lazymatch goal with
       | |- exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ =>
           let value := eval vm_compute in b in change b with value
       end; cbn; loader_stmt]
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | loader_expr | loader_arguments |
       cbn; eassumption | reflexivity | eassumption]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; loader_expr
  end.

(** First table entry and initially empty cache.  Every statement of the
    generated loader is executed.  Only the actual named dma_read call and
    post-DMA cache-cell writability remain explicit.  DMA byte transfer,
    metadata preservation and initialized-game reachability are not claimed. *)
Definition demo_first_loader_miss_execution_claim (f : function) : Prop :=
  forall ge (layout : demo_loader_layout ge) before dmaed
      handler table source buffer code count offset size,
    Genv.find_symbol ge M._dma_read = Some code ->
    Genv.find_funct_ptr ge code = Some (Internal M.f_dma_read) ->
    Mem.load Mptr before handler 0 = Some (Vptr table Ptrofs.zero) ->
    Mem.load Mint32 before table 0 = Some (Vint count) ->
    Int.ltu Int.zero count = true ->
    Mem.load Mptr before table 4 = Some (Vptr source Ptrofs.zero) ->
    Mem.load Mint32 before table 8 = Some (Vint offset) ->
    Mem.load Mint32 before table 12 = Some (Vint size) ->
    Mem.load Mptr before handler 4 = Some (Vint Int.zero) ->
    Mem.load Mptr before handler 8 = Some (Vptr buffer Ptrofs.zero) ->
    Mem.valid_pointer before source
      (Ptrofs.unsigned (demo_loader_source_offset offset)) = true ->
    eval_funcall function_entry2 ge before (Internal M.f_dma_read)
      [Vptr buffer Ptrofs.zero;
       Vptr source (demo_loader_source_offset offset);
       Vptr source (demo_loader_source_end offset size)] E0 dmaed Vundef ->
    Mem.valid_access dmaed Mptr handler 4 Writable ->
    exists after,
      eval_funcall function_entry2 ge before (Internal f)
        [Vptr handler Ptrofs.zero; Vint Int.zero] E0 after (Vint Int.one) /\
      Mem.store Mptr dmaed handler 4
        (Vptr source (demo_loader_source_offset offset)) = Some after /\
      Mem.load Mptr after handler 4 =
        Some (Vptr source (demo_loader_source_offset offset)).

Theorem generated_first_demo_loader_cache_miss_executes :
  demo_first_loader_miss_execution_claim M.f_load_patchable_table.
Proof.
  intros ge layout before dmaed handler table source buffer code count offset size
    Hcode Hfd Htable Hcount Hpositive Hsource Hoffset Hsize Hempty Hbuffer
    Hvalid Hdma Hwcache.
  destruct layout as [handler_co table_co pair_co Hhandler_co Htable_co Hpair_co
    Hhandler_table Hhandler_current Hhandler_target Htable_count Htable_source
    Htable_anim Hpair_offset Hpair_size Hpair_sizeof].
  destruct (Mem.valid_access_store dmaed Mptr handler 4
    (Vptr source (demo_loader_source_offset offset)) Hwcache) as (after & Hstore).
  exists after. split.
  - eapply eval_funcall_internal.
    + exact (generated_demo_loader_function_entry ge before handler).
    + cbn [M.f_load_patchable_table fn_body]. loader_stmt.
    + split; [discriminate | reflexivity].
    + reflexivity.
  - split; [exact Hstore |]. dls_load.
Qed.

Definition demo_first_loader_miss_execution_claim_us_jp : Prop :=
  M.f_load_patchable_table = jp_memory.f_load_patchable_table /\
  M.f_dma_read = jp_memory.f_dma_read /\
  demo_first_loader_miss_execution_claim M.f_load_patchable_table /\
  demo_first_loader_miss_execution_claim jp_memory.f_load_patchable_table.

Theorem generated_first_demo_loader_cache_miss_us_jp :
  demo_first_loader_miss_execution_claim_us_jp.
Proof.
  split; [reflexivity |]. split; [reflexivity |]. split;
    exact generated_first_demo_loader_cache_miss_executes.
Qed.

(** The final cache-pointer store is disjoint from the handler's table/target
    fields.  These are precisely the post-loader reads used by title startup.
    The DMA call must supply the stated reads beforehand; this lemma does not
    pretend that dma_read changes only its destination buffer. *)
Definition demo_loader_title_metadata_preserved_claim : Prop :=
  forall dmaed loaded handler table buffer index source source_offset
      count header index_value,
    Mem.store Mptr dmaed handler 4 (Vptr source source_offset) = Some loaded ->
    handler <> table -> handler <> buffer -> handler <> index ->
    Mem.load Mptr dmaed handler 0 = Some (Vptr table Ptrofs.zero) ->
    Mem.load Mptr dmaed handler 8 = Some (Vptr buffer Ptrofs.zero) ->
    Mem.load Mint32 dmaed table 0 = Some (Vint count) ->
    Mem.load Mint8unsigned dmaed buffer 0 = Some (Vint header) ->
    Mem.load Mint16unsigned dmaed index 0 = Some (Vint index_value) ->
    Mem.load Mptr loaded handler 0 = Some (Vptr table Ptrofs.zero) /\
    Mem.load Mptr loaded handler 8 = Some (Vptr buffer Ptrofs.zero) /\
    Mem.load Mint32 loaded table 0 = Some (Vint count) /\
    Mem.load Mint8unsigned loaded buffer 0 = Some (Vint header) /\
    Mem.load Mint16unsigned loaded index 0 = Some (Vint index_value).

Theorem generated_demo_loader_cache_store_preserves_title_reads :
  demo_loader_title_metadata_preserved_claim.
Proof.
  intros dmaed loaded handler table buffer index source source_offset
    count header index_value Hstore Hht Hhb Hhi Htable Htarget Hcount Hheader Hindex.
  repeat split.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore).
    + exact Htable.
    + right. left. change (0 + 4 <= 4). lia.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore).
    + exact Htarget.
    + right. right. change (4 + 4 <= 8). lia.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore).
    + exact Hcount.
    + left. congruence.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore).
    + exact Hheader.
    + left. congruence.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore).
    + exact Hindex.
    + left. congruence.
Qed.

Definition demo_loader_execution_boundary_claim_us_jp : Prop :=
  demo_first_loader_miss_execution_claim_us_jp /\
  (forall ge, genv_cenv ge = prog_comp_env M.prog ->
    exists layout : demo_loader_layout ge, True) /\
  demo_loader_title_metadata_preserved_claim.

Theorem generated_demo_loader_execution_boundary_us_jp :
  demo_loader_execution_boundary_claim_us_jp.
Proof.
  exact (conj generated_first_demo_loader_cache_miss_us_jp
    (conj generated_demo_loader_layout_exists
      generated_demo_loader_cache_store_preserves_title_reads)).
Qed.
