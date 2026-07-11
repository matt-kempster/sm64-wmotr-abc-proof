From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Values Globalenvs Ctypes
  Clight Linking.
From DemoWarp.Generated Require Import
  game_init title_screen memory os_cont_start_read_data os_si_raw_start_dma.

Module G := game_init.
Module T := title_screen.
Module M := memory.
Module O := os_cont_start_read_data.
Module SI := os_si_raw_start_dma.

Lemma target_linkorder_resolves_internal :
  forall (lp q : Clight.program) (id : ident) (f : Clight.function),
    linkorder q lp ->
    (prog_defmap q) ! id = Some (Gfun (Internal f)) ->
    exists b,
      Genv.find_symbol (globalenv lp) id = Some b /\
      Genv.find_funct (globalenv lp) (Vptr b Ptrofs.zero) =
        Some (Internal f).
Proof.
  intros lp q id f LOq Hdm.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm)
    as (gd' & Hgd' & Hlo).
  inv Hlo.
  match goal with H : linkorder _ _ |- _ => inv H end.
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hgd'.
  destruct Hgd' as (b & Hsym & Hdef).
  exists b. split; [exact Hsym |].
  unfold Genv.find_funct.
  destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero) as [_ | Hneq].
  - apply (proj2 (Genv.find_funct_ptr_iff _ _ _)). exact Hdef.
  - contradiction Hneq; reflexivity.
Qed.

Lemma game_defmap_setup_game_memory :
  (prog_defmap G.prog) ! G._setup_game_memory =
    Some (Gfun (Internal G.f_setup_game_memory)).
Proof. vm_compute. reflexivity. Qed.

Lemma game_defmap_run_demo_inputs :
  (prog_defmap G.prog) ! G._run_demo_inputs =
    Some (Gfun (Internal G.f_run_demo_inputs)).
Proof. vm_compute. reflexivity. Qed.

Lemma game_defmap_read_controller_inputs :
  (prog_defmap G.prog) ! G._read_controller_inputs =
    Some (Gfun (Internal G.f_read_controller_inputs)).
Proof. vm_compute. reflexivity. Qed.

Lemma title_defmap_run_level_id_or_demo :
  (prog_defmap T.prog) ! T._run_level_id_or_demo =
    Some (Gfun (Internal T.f_run_level_id_or_demo)).
Proof. vm_compute. reflexivity. Qed.

Lemma memory_defmap_setup_dma_table_list :
  (prog_defmap M.prog) ! M._setup_dma_table_list =
    Some (Gfun (Internal M.f_setup_dma_table_list)).
Proof. vm_compute. reflexivity. Qed.

Lemma memory_defmap_load_patchable_table :
  (prog_defmap M.prog) ! M._load_patchable_table =
    Some (Gfun (Internal M.f_load_patchable_table)).
Proof. vm_compute. reflexivity. Qed.

Lemma controller_defmap_get_read_data :
  (prog_defmap O.prog) ! O._osContGetReadData =
    Some (Gfun (Internal O.f_osContGetReadData)).
Proof. vm_compute. reflexivity. Qed.

Lemma controller_defmap_start_read_data :
  (prog_defmap O.prog) ! O._osContStartReadData =
    Some (Gfun (Internal O.f_osContStartReadData)).
Proof. vm_compute. reflexivity. Qed.

Lemma si_defmap_raw_start_dma :
  (prog_defmap SI.prog) ! SI.___osSiRawStartDma =
    Some (Gfun (Internal SI.f___osSiRawStartDma)).
Proof. vm_compute. reflexivity. Qed.

Definition target_dma_handler_members : members :=
  Member_plain T._dmaTable (Tpointer (Tstruct T._DmaTable noattr) noattr) ::
  Member_plain T._currentAddr (Tpointer Tvoid noattr) ::
  Member_plain T._bufTarget (Tpointer Tvoid noattr) :: nil.

Lemma title_dma_handler_definition_is_generated :
  In (Composite T._DmaHandlerList Struct target_dma_handler_members noattr)
    (prog_types T.prog).
Proof. vm_compute. do 5 right. left. reflexivity. Qed.

Lemma title_dma_handler_composite_is_generated :
  exists co,
    (prog_comp_env T.prog) ! T._DmaHandlerList = Some co /\
    co_members co = target_dma_handler_members.
Proof.
  destruct (build_composite_env_charact
    T._DmaHandlerList Struct target_dma_handler_members noattr
    (prog_types T.prog) (prog_comp_env T.prog)
    (prog_comp_env_eq T.prog) title_dma_handler_definition_is_generated)
    as (co & Hlookup & Hmembers & _).
  exists co. split; assumption.
Qed.

Lemma linkorder_preserves_title_dma_handler_layout :
  forall lp : Clight.program,
    linkorder T.prog lp ->
    exists co,
      (prog_comp_env lp) ! T._DmaHandlerList = Some co /\
      co_members co = target_dma_handler_members.
Proof.
  intros lp LO.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LO.
  destruct LO as [_ LOtypes].
  destruct title_dma_handler_composite_is_generated
    as (co & Hsource & Hmembers).
  exists co. split; [eapply LOtypes; exact Hsource | exact Hmembers].
Qed.

Section LinkedTargetProgram.
  Variable lp : Clight.program.
  Hypothesis LO_game : linkorder G.prog lp.
  Hypothesis LO_title : linkorder T.prog lp.
  Hypothesis LO_memory : linkorder M.prog lp.
  Hypothesis LO_controller : linkorder O.prog lp.
  Hypothesis LO_si : linkorder SI.prog lp.

  Definition resolves_internal
      (id : ident) (f : Clight.function) : Prop :=
    exists b,
      Genv.find_symbol (globalenv lp) id = Some b /\
      Genv.find_funct (globalenv lp) (Vptr b Ptrofs.zero) =
        Some (Internal f).

  Theorem linked_target_calls_resolve_to_internal_bodies :
    resolves_internal G._setup_game_memory G.f_setup_game_memory /\
    resolves_internal G._run_demo_inputs G.f_run_demo_inputs /\
    resolves_internal G._read_controller_inputs G.f_read_controller_inputs /\
    resolves_internal T._run_level_id_or_demo T.f_run_level_id_or_demo /\
    resolves_internal M._setup_dma_table_list M.f_setup_dma_table_list /\
    resolves_internal M._load_patchable_table M.f_load_patchable_table /\
    resolves_internal O._osContGetReadData O.f_osContGetReadData /\
    resolves_internal O._osContStartReadData O.f_osContStartReadData /\
    resolves_internal SI.___osSiRawStartDma SI.f___osSiRawStartDma.
  Proof.
    unfold resolves_internal.
    split.
    - eapply target_linkorder_resolves_internal; [exact LO_game | exact game_defmap_setup_game_memory].
    - split.
      + eapply target_linkorder_resolves_internal; [exact LO_game | exact game_defmap_run_demo_inputs].
      + split.
        * eapply target_linkorder_resolves_internal; [exact LO_game | exact game_defmap_read_controller_inputs].
        * split.
          { eapply target_linkorder_resolves_internal; [exact LO_title | exact title_defmap_run_level_id_or_demo]. }
          split.
          { eapply target_linkorder_resolves_internal; [exact LO_memory | exact memory_defmap_setup_dma_table_list]. }
          split.
          { eapply target_linkorder_resolves_internal; [exact LO_memory | exact memory_defmap_load_patchable_table]. }
          split.
          { eapply target_linkorder_resolves_internal; [exact LO_controller | exact controller_defmap_get_read_data]. }
          split.
          { eapply target_linkorder_resolves_internal; [exact LO_controller | exact controller_defmap_start_read_data]. }
          eapply target_linkorder_resolves_internal; [exact LO_si | exact si_defmap_raw_start_dma].
  Qed.

  Theorem linked_target_composite_layouts :
    exists co,
      (genv_cenv (globalenv lp)) ! T._DmaHandlerList = Some co /\
      co_members co = target_dma_handler_members.
  Proof.
    change (exists co,
      (prog_comp_env lp) ! T._DmaHandlerList = Some co /\
      co_members co = target_dma_handler_members).
    apply linkorder_preserves_title_dma_handler_layout.
    exact LO_title.
  Qed.
End LinkedTargetProgram.
