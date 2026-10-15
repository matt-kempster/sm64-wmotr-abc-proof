From Coq Require Import Bool List ZArith Lia FunctionalExtensionality.
From compcert Require Import AST Clight Coqlib Ctypes Events Globalenvs Linking Maps
  Memdata Memory Values.
From Demo.Proofs Require Import DemoPrivateGlobalLinkReceipt.
Import ListNotations.
Open Scope Z_scope.

(** Only global-variable type metadata changes. Initializers, flags, global
    ordering, names, functions and the composite environment are unchanged. *)
Definition demo_update_global_metadata (update : ident -> globvar type -> type)
    (entry : ident * globdef Clight.fundef type) :=
  let '(name, definition) := entry in
  (name, match definition with
   | Gfun function_ => Gfun function_
   | Gvar variable => Gvar
       {| gvar_info := update name variable;
          gvar_init := gvar_init variable;
          gvar_readonly := gvar_readonly variable;
          gvar_volatile := gvar_volatile variable |}
   end).

Definition demo_update_program_metadata update (p : Clight.program) : Clight.program :=
  {| Ctypes.prog_defs := map (demo_update_global_metadata update) (Ctypes.prog_defs p);
     Ctypes.prog_public := Ctypes.prog_public p;
     Ctypes.prog_main := Ctypes.prog_main p;
     Ctypes.prog_types := Ctypes.prog_types p;
     Ctypes.prog_comp_env := Ctypes.prog_comp_env p;
     Ctypes.prog_comp_env_eq := Ctypes.prog_comp_env_eq p |}.

Definition demo_metadata_match (p q : Clight.program) : Prop :=
  Linking.match_program_gen
    (fun (_ : unit) (f g : Clight.fundef) => f = g)
    (fun (_ _ : type) => True) tt
    (Ctypes.program_of_program p) (Ctypes.program_of_program q).

Lemma demo_metadata_update_matches : forall update p,
  demo_metadata_match p (demo_update_program_metadata update p).
Proof.
  intros update p. unfold demo_metadata_match, Linking.match_program_gen.
  cbn [demo_update_program_metadata Ctypes.program_of_program].
  split; [| split; reflexivity].
  change (list_forall2
    (match_ident_globdef (fun (_ : unit) (f g : Clight.fundef) => f = g)
      (fun (_ _ : type) => True) tt)
    (Ctypes.prog_defs p) (map (demo_update_global_metadata update) (Ctypes.prog_defs p))).
  induction (Ctypes.prog_defs p) as [|[name definition] rest IH]; constructor; auto.
  split; [reflexivity |]. destruct definition as [function_ | [info init readonly volatile]];
    cbn [demo_update_global_metadata].
  - apply match_globdef_fun with (ctx' := tt); [apply linkorder_refl | reflexivity].
  - constructor. constructor. exact I.
Qed.

Lemma demo_metadata_update_matches_backwards : forall update p,
  demo_metadata_match (demo_update_program_metadata update p) p.
Proof.
  intros update p. unfold demo_metadata_match, Linking.match_program_gen.
  cbn [demo_update_program_metadata Ctypes.program_of_program].
  split; [| split; reflexivity].
  change (list_forall2
    (match_ident_globdef (fun (_ : unit) (f g : Clight.fundef) => f = g)
      (fun (_ _ : type) => True) tt)
    (map (demo_update_global_metadata update) (Ctypes.prog_defs p)) (Ctypes.prog_defs p)).
  induction (Ctypes.prog_defs p) as [|[name definition] rest IH]; constructor; auto.
  split; [reflexivity |]. destruct definition as [function_ | [info init readonly volatile]];
    cbn [demo_update_global_metadata].
  - apply match_globdef_fun with (ctx' := tt); [apply linkorder_refl | reflexivity].
  - constructor. constructor. exact I.
Qed.

Theorem demo_metadata_completion_preserves_initial_memory : forall update (p : Clight.program) memory,
  Genv.init_mem p = Some memory <->
  Genv.init_mem (demo_update_program_metadata update p) = Some memory.
Proof.
  intros update p memory. split; intro Hmemory.
  - exact (Genv.init_mem_match (demo_metadata_update_matches update p) Hmemory).
  - exact (Genv.init_mem_match (demo_metadata_update_matches_backwards update p) Hmemory).
Qed.

Record demo_metadata_environment_agreement (ge target : Clight.genv) : Prop := {
  demo_metadata_composites_agree : genv_cenv target = genv_cenv ge;
  demo_metadata_symbols_agree : forall name, Genv.find_symbol target name = Genv.find_symbol ge name;
  demo_metadata_functions_agree : forall value, Genv.find_funct target value = Genv.find_funct ge value;
  demo_metadata_function_pointers_agree : forall block,
    Genv.find_funct_ptr target block = Genv.find_funct_ptr ge block;
  demo_metadata_senv_agrees : Senv.equiv ge target
}.

Theorem demo_metadata_completion_environment_agrees : forall update p,
  demo_metadata_environment_agreement (Clight.globalenv p)
    (Clight.globalenv (demo_update_program_metadata update p)).
Proof.
  intros update p. constructor.
  - reflexivity.
  - intro name. exact (Genv.find_symbol_match (demo_metadata_update_matches update p) name).
  - intro value.
    destruct (Genv.find_funct (Clight.globalenv p) value) as [function_ |] eqn:Hsource.
    + destruct (Genv.find_funct_match (demo_metadata_update_matches update p) value Hsource)
        as (context & target & Htarget & Hequal & Hcontext).
      subst target. exact Htarget.
    + destruct (Genv.find_funct (Clight.globalenv (demo_update_program_metadata update p)) value)
        as [function_ |] eqn:Htarget; [| reflexivity].
      destruct (Genv.find_funct_match (demo_metadata_update_matches_backwards update p) value Htarget)
        as (context & source & Hfound & Hequal & Hcontext).
      change (Genv.find_funct (Clight.globalenv p) value = Some source) in Hfound.
      rewrite Hsource in Hfound. discriminate.
  - intro block.
    destruct (Genv.find_funct_ptr (Clight.globalenv p) block) as [function_ |] eqn:Hsource.
    + destruct (Genv.find_funct_ptr_match (demo_metadata_update_matches update p) block Hsource)
        as (context & target & Htarget & Hequal & Hcontext).
      subst target. exact Htarget.
    + destruct (Genv.find_funct_ptr (Clight.globalenv (demo_update_program_metadata update p)) block)
        as [function_ |] eqn:Htarget; [| reflexivity].
      destruct (Genv.find_funct_ptr_match (demo_metadata_update_matches_backwards update p) block Htarget)
        as (context & source & Hfound & Hequal & Hcontext).
      change (Genv.find_funct_ptr (Clight.globalenv p) block = Some source) in Hfound.
      rewrite Hsource in Hfound. discriminate.
  - exact (Genv.senv_match (demo_metadata_update_matches update p)).
Qed.

Lemma demo_metadata_expressions_preserved : forall ge target,
  demo_metadata_environment_agreement ge target -> forall environment locals memory,
  (forall expression value, eval_expr ge environment locals memory expression value ->
    eval_expr target environment locals memory expression value) /\
  (forall expression block offset field, eval_lvalue ge environment locals memory expression block offset field ->
    eval_lvalue target environment locals memory expression block offset field).
Proof.
  intros [globals composites] [target_globals target_composites]
    [Hcomposites Hsymbols Hfunctions Hpointers Hsenv] environment locals memory.
  cbn in Hcomposites. subst target_composites.
  apply eval_expr_lvalue_ind; intros; try solve [econstructor; eauto].
  - exact (@eval_Esizeof {| genv_genv := target_globals; genv_cenv := composites |}
      environment locals memory ty1 ty).
  - exact (@eval_Ealignof {| genv_genv := target_globals; genv_cenv := composites |}
      environment locals memory ty1 ty).
  - eapply eval_Evar_global; [eassumption |]. rewrite Hsymbols. eassumption.
Qed.

Lemma demo_metadata_expression_preserved : forall ge target,
  demo_metadata_environment_agreement ge target ->
  forall environment locals memory expression value,
    eval_expr ge environment locals memory expression value ->
    eval_expr target environment locals memory expression value.
Proof.
  intros ge target Hagree environment locals memory.
  exact (proj1 (demo_metadata_expressions_preserved ge target Hagree environment locals memory)).
Qed.

Lemma demo_metadata_lvalue_preserved : forall ge target,
  demo_metadata_environment_agreement ge target ->
  forall environment locals memory expression block offset field,
    eval_lvalue ge environment locals memory expression block offset field ->
    eval_lvalue target environment locals memory expression block offset field.
Proof.
  intros ge target Hagree environment locals memory.
  exact (proj2 (demo_metadata_expressions_preserved ge target Hagree environment locals memory)).
Qed.

Lemma demo_metadata_expression_list_preserved : forall ge target,
  demo_metadata_environment_agreement ge target ->
  forall environment locals memory expressions types values,
    eval_exprlist ge environment locals memory expressions types values ->
    eval_exprlist target environment locals memory expressions types values.
Proof.
  intros ge target Hagree environment locals memory expressions types values Hlist.
  induction Hlist; econstructor; eauto using demo_metadata_expression_preserved.
Qed.

Lemma demo_metadata_assignment_preserved : forall ge target,
  demo_metadata_environment_agreement ge target ->
  forall ty memory block offset field value after,
    assign_loc ge ty memory block offset field value after ->
    assign_loc target ty memory block offset field value after.
Proof.
  intros ge target [Hcomposites Hsymbols Hfunctions Hpointers Hsenv]
    ty memory block offset field value after Hassign.
  change (assign_loc (genv_cenv target) ty memory block offset field value after).
  rewrite Hcomposites. exact Hassign.
Qed.

Lemma demo_metadata_allocations_preserved : forall ge target,
  demo_metadata_environment_agreement ge target ->
  forall environment memory variables after_environment after,
    alloc_variables ge environment memory variables after_environment after ->
    alloc_variables target environment memory variables after_environment after.
Proof.
  intros [globals composites] [target_globals target_composites]
    [Hcomposites Hsymbols Hfunctions Hpointers Hsenv]
    environment memory variables after_environment after Halloc.
  cbn in Hcomposites. subst target_composites.
  induction Halloc; econstructor; eauto.
Qed.

Lemma demo_metadata_function_entry_preserved : forall ge target,
  demo_metadata_environment_agreement ge target ->
  forall function_ arguments memory environment locals after,
    function_entry2 ge function_ arguments memory environment locals after ->
    function_entry2 target function_ arguments memory environment locals after.
Proof.
  intros ge target Hagree function_ arguments memory environment locals after Hentry.
  inversion Hentry; subst. econstructor; eauto using demo_metadata_allocations_preserved.
Qed.

Lemma demo_metadata_stack_blocks_agree : forall ge target,
  demo_metadata_environment_agreement ge target -> forall environment,
    blocks_of_env target environment = blocks_of_env ge environment.
Proof.
  intros [globals composites] [target_globals target_composites]
    [Hcomposites Hsymbols Hfunctions Hpointers Hsenv] environment.
  cbn in Hcomposites. subst target_composites. reflexivity.
Qed.

Lemma demo_metadata_external_call_preserved : forall ge target,
  demo_metadata_environment_agreement ge target ->
  forall external arguments memory trace result after,
    external_call external ge arguments memory trace result after ->
    external_call external target arguments memory trace result after.
Proof.
  intros ge target [Hcomposites Hsymbols Hfunctions Hpointers Hsenv]
    external arguments memory trace result after Hcall.
  eapply external_call_symbols_preserved; eassumption.
Qed.

Theorem demo_metadata_small_step_preserved : forall ge target,
  demo_metadata_environment_agreement ge target -> forall state trace after,
    Clight.step2 ge state trace after -> Clight.step2 target state trace after.
Proof.
  intros ge target Hagree state trace after Hstep.
  pose proof (@demo_metadata_functions_agree ge target Hagree) as Hfunctions.
  unfold Clight.step2 in *. inversion Hstep; subst;
    econstructor; eauto using demo_metadata_expression_preserved,
      demo_metadata_lvalue_preserved, demo_metadata_expression_list_preserved,
      demo_metadata_assignment_preserved, demo_metadata_function_entry_preserved,
      demo_metadata_external_call_preserved.
  - rewrite Hfunctions. eassumption.
  - rewrite (demo_metadata_stack_blocks_agree ge target Hagree). eassumption.
  - rewrite (demo_metadata_stack_blocks_agree ge target Hagree). eassumption.
  - rewrite (demo_metadata_stack_blocks_agree ge target Hagree). eassumption.
Qed.

Lemma demo_metadata_environment_agreement_symmetric : forall ge target,
  demo_metadata_environment_agreement ge target ->
  demo_metadata_environment_agreement target ge.
Proof.
  intros ge target [Hcomposites Hsymbols Hfunctions Hpointers [Hfind [Hpublic Hvolatile]]].
  constructor; try (intros; symmetry; auto).
  repeat split; intros; symmetry; auto.
Qed.

Theorem demo_metadata_completion_preserves_small_steps : forall update p state trace after,
  Clight.step2 (Clight.globalenv p) state trace after <->
  Clight.step2 (Clight.globalenv (demo_update_program_metadata update p)) state trace after.
Proof.
  intros update p state trace after. split; apply demo_metadata_small_step_preserved.
  - apply demo_metadata_completion_environment_agrees.
  - apply demo_metadata_environment_agreement_symmetric.
    apply demo_metadata_completion_environment_agrees.
Qed.

Lemma demo_metadata_initial_states_preserved : forall (p q : Clight.program),
  demo_metadata_match p q -> forall state,
  Clight.initial_state p state -> Clight.initial_state q state.
Proof.
  intros p q Hmatch state Hinitial.
  pose proof Hmatch as Hmain.
  unfold demo_metadata_match, Linking.match_program_gen in Hmain.
  destruct Hmain as [_ [Hmain Hpublic]].
  change (Ctypes.prog_main q = Ctypes.prog_main p) in Hmain.
  inversion Hinitial as [block function_ memory globals Hmemory Hsymbol Hfunction Htype]; subst.
  eapply Clight.initial_state_intro with (b := block) (f := function_) (m0 := memory).
  - exact (Genv.init_mem_match Hmatch Hmemory).
  - change (Genv.find_symbol (Genv.globalenv q) (Ctypes.prog_main q) = Some block).
    rewrite Hmain, (Genv.find_symbol_match Hmatch). exact Hsymbol.
  - destruct (Genv.find_funct_ptr_match Hmatch block Hfunction)
      as (context & target & Htarget & Hequal & Hcontext).
    subst target. exact Htarget.
  - exact Htype.
Qed.

Theorem demo_metadata_completion_preserves_initial_states : forall update p state,
  Clight.initial_state p state <->
  Clight.initial_state (demo_update_program_metadata update p) state.
Proof.
  intros update p state. split; apply demo_metadata_initial_states_preserved.
  - apply demo_metadata_update_matches.
  - apply demo_metadata_update_matches_backwards.
Qed.

(** A completion is selected only from an actual initialized array definition,
    with identical element/attribute metadata and readonly/volatile flags. *)
Fixpoint demo_find_complete_array_metadata
    (definitions : list (ident * globdef Clight.fundef type))
    (name : ident) (zero_type : type) (readonly volatile : bool) : option type :=
  match definitions with
  | [] => None
  | (candidate, Gvar variable) :: rest =>
      match gvar_info variable, gvar_init variable with
      | Tarray element extent attributes, _ :: _ =>
          if Pos.eqb name candidate && Z.ltb 0 extent &&
             (if Ctypes.type_eq (Tarray element 0 attributes) zero_type then true else false) &&
             Bool.eqb readonly (gvar_readonly variable) &&
             Bool.eqb volatile (gvar_volatile variable)
          then Some (gvar_info variable)
          else demo_find_complete_array_metadata rest name zero_type readonly volatile
      | _, _ => demo_find_complete_array_metadata rest name zero_type readonly volatile
      end
  | _ :: rest => demo_find_complete_array_metadata rest name zero_type readonly volatile
  end.

Definition demo_complete_array_metadata definitions name (variable : globvar type) : type :=
  match gvar_info variable, gvar_init variable with
  | Tarray element extent attributes, [] =>
      if Z.eqb extent 0 then
        match demo_find_complete_array_metadata definitions name
          (Tarray element 0 attributes) (gvar_readonly variable) (gvar_volatile variable) with
        | Some complete => complete
        | None => gvar_info variable
        end
      else gvar_info variable
  | _, _ => gvar_info variable
  end.

Definition demo_array_extent_completion_checked old complete : bool :=
  if Ctypes.type_eq old complete then true else
    match old, complete with
    | Tarray element extent attributes, Tarray complete_element complete_extent complete_attributes =>
        Z.eqb extent 0 && Z.ltb 0 complete_extent &&
        (if Ctypes.type_eq (Tarray element 0 attributes)
              (Tarray complete_element 0 complete_attributes) then true else false)
    | _, _ => false
    end.

Definition demo_complete_public_array_metadata definitions public name variable :=
  if existsb (Pos.eqb name) public
  then demo_complete_array_metadata definitions name variable
  else gvar_info variable.

Definition demo_us_array_completion_units : list Clight.program :=
  us_level_scripts.prog :: us_bbh_level_script.prog :: demo_us_other_level_script_units.
Definition demo_jp_array_completion_units : list Clight.program :=
  jp_level_scripts.prog :: jp_bbh_level_script.prog :: demo_jp_other_level_script_units.
Definition demo_script_array_definitions (units : list Clight.program) :=
  concat (map (fun unit => Ctypes.prog_defs unit) units).
Definition demo_us_array_definitions := demo_script_array_definitions demo_us_array_completion_units.
Definition demo_jp_array_definitions := demo_script_array_definitions demo_jp_array_completion_units.

(** Separate refinement for readonly metadata on empty-init externs. A zero
    allocation drops permissions on an empty interval, independent of p. *)
Lemma demo_empty_drop_permissions_independent : forall memory block lo first second,
  Mem.drop_perm memory block lo lo first = Mem.drop_perm memory block lo lo second.
Proof.
  intros memory block lo first second. unfold Mem.drop_perm.
  destruct (Mem.range_perm_dec memory block lo lo Cur Freeable); [| reflexivity].
  f_equal. apply Mem.mkmem_ext; try reflexivity.
  f_equal. apply functional_extensionality; intro offset.
  apply functional_extensionality; intro kind.
  destruct (zle lo offset), (zlt offset lo); cbn; try reflexivity; lia.
Qed.

Definition demo_normalize_empty_readonly_global
    (choose : ident -> globvar type -> bool)
    (entry : ident * globdef Clight.fundef type) :=
  let '(name, definition) := entry in
  (name, match definition with
   | Gfun function_ => Gfun function_
   | Gvar variable => Gvar
       {| gvar_info := gvar_info variable;
          gvar_init := gvar_init variable;
          gvar_readonly := match gvar_init variable with
            | [] => choose name variable | _ => gvar_readonly variable end;
          gvar_volatile := gvar_volatile variable |}
   end).

Definition demo_normalize_empty_readonly_program choose (p : Clight.program) : Clight.program :=
  {| Ctypes.prog_defs := map (demo_normalize_empty_readonly_global choose) (Ctypes.prog_defs p);
     Ctypes.prog_public := Ctypes.prog_public p;
     Ctypes.prog_main := Ctypes.prog_main p;
     Ctypes.prog_types := Ctypes.prog_types p;
     Ctypes.prog_comp_env := Ctypes.prog_comp_env p;
     Ctypes.prog_comp_env_eq := Ctypes.prog_comp_env_eq p |}.

Inductive demo_observable_global_definition_match :
    globdef Clight.fundef type -> globdef Clight.fundef type -> Prop :=
| demo_observable_function_match : forall function_,
    demo_observable_global_definition_match (Gfun function_) (Gfun function_)
| demo_observable_variable_match : forall first second,
    gvar_volatile first = gvar_volatile second ->
    demo_observable_global_definition_match (Gvar first) (Gvar second).

Lemma demo_empty_readonly_globalenvs_match : forall choose (p : Clight.program),
  Genv.match_genvs demo_observable_global_definition_match
    (Genv.globalenv p) (Genv.globalenv (demo_normalize_empty_readonly_program choose p)).
Proof.
  intros choose p. unfold Genv.globalenv.
  apply Genv.add_globals_match.
  - change (list_forall2
      (fun first second => fst first = fst second /\
        demo_observable_global_definition_match (snd first) (snd second))
      (Ctypes.prog_defs p)
      (map (demo_normalize_empty_readonly_global choose) (Ctypes.prog_defs p))).
    induction (Ctypes.prog_defs p) as [|[name definition] rest IH]; constructor; auto.
    split; [reflexivity |]. destruct definition as [function_ | variable];
      cbn [demo_normalize_empty_readonly_global]; constructor; reflexivity.
  - constructor; cbn; intros; try reflexivity.
    rewrite ! PTree.gempty. constructor.
Qed.

Lemma demo_observable_function_pointers_agree : forall globals target,
  Genv.match_genvs demo_observable_global_definition_match globals target -> forall block,
  Genv.find_funct_ptr target block = Genv.find_funct_ptr globals block.
Proof.
  intros globals target [Hnext Hsymbols Hdefinitions] block.
  unfold Genv.find_funct_ptr, Genv.find_def.
  specialize (Hdefinitions block). destruct Hdefinitions as [| first second Hdefinition].
  - reflexivity.
  - destruct Hdefinition; reflexivity.
Qed.

Lemma demo_observable_volatility_agrees : forall globals target,
  Genv.match_genvs demo_observable_global_definition_match globals target -> forall block,
  Genv.block_is_volatile target block = Genv.block_is_volatile globals block.
Proof.
  intros globals target [Hnext Hsymbols Hdefinitions] block.
  unfold Genv.block_is_volatile, Genv.find_var_info, Genv.find_def.
  specialize (Hdefinitions block). destruct Hdefinitions as [| first second Hdefinition].
  - reflexivity.
  - destruct Hdefinition; cbn; congruence.
Qed.

Theorem demo_empty_readonly_environment_agrees : forall choose p,
  demo_metadata_environment_agreement (Clight.globalenv p)
    (Clight.globalenv (demo_normalize_empty_readonly_program choose p)).
Proof.
  intros choose p.
  pose proof (demo_empty_readonly_globalenvs_match choose p) as Hmatch.
  destruct Hmatch as [Hnext Hsymbols Hdefinitions] eqn:Hreceipt.
  assert (Hpointer : forall block,
    Genv.find_funct_ptr (Clight.globalenv (demo_normalize_empty_readonly_program choose p)) block =
    Genv.find_funct_ptr (Clight.globalenv p) block).
  { apply demo_observable_function_pointers_agree. exact (demo_empty_readonly_globalenvs_match choose p). }
  constructor.
  - reflexivity.
  - exact Hsymbols.
  - intro value. unfold Genv.find_funct. destruct value; try reflexivity.
    rewrite Hpointer. reflexivity.
  - exact Hpointer.
  - change ((forall name,
      Genv.find_symbol (Genv.globalenv (demo_normalize_empty_readonly_program choose p)) name =
      Genv.find_symbol (Genv.globalenv p) name) /\
      (forall name,
      Genv.public_symbol (Genv.globalenv (demo_normalize_empty_readonly_program choose p)) name =
      Genv.public_symbol (Genv.globalenv p) name) /\
      (forall block,
      Genv.block_is_volatile (Genv.globalenv (demo_normalize_empty_readonly_program choose p)) block =
      Genv.block_is_volatile (Genv.globalenv p) block)).
    split; [exact Hsymbols |]. split.
    + intro name. unfold Genv.public_symbol.
      rewrite ! Genv.globalenv_public. unfold Genv.find_symbol. rewrite Hsymbols. reflexivity.
    + apply demo_observable_volatility_agrees. exact (demo_empty_readonly_globalenvs_match choose p).
Qed.

Theorem demo_empty_readonly_small_steps_preserved : forall choose p state trace after,
  Clight.step2 (Clight.globalenv p) state trace after <->
  Clight.step2 (Clight.globalenv (demo_normalize_empty_readonly_program choose p)) state trace after.
Proof.
  intros choose p state trace after. split; apply demo_metadata_small_step_preserved.
  - apply demo_empty_readonly_environment_agrees.
  - apply demo_metadata_environment_agreement_symmetric. apply demo_empty_readonly_environment_agrees.
Qed.

Lemma demo_equal_symbols_initial_datum : forall (globals target : Genv.t Clight.fundef type),
  (forall name, Genv.find_symbol target name = Genv.find_symbol globals name) ->
  forall datum memory block offset,
    Genv.store_init_data target memory block offset datum =
    Genv.store_init_data globals memory block offset datum.
Proof.
  intros globals target Hsymbols datum memory block offset.
  destruct datum; cbn [Genv.store_init_data]; try reflexivity.
  rewrite Hsymbols. reflexivity.
Qed.

Lemma demo_equal_symbols_initial_data : forall (globals target : Genv.t Clight.fundef type),
  (forall name, Genv.find_symbol target name = Genv.find_symbol globals name) ->
  forall data memory block offset,
    Genv.store_init_data_list target memory block offset data =
    Genv.store_init_data_list globals memory block offset data.
Proof.
  intros globals target Hsymbols data. induction data as [|datum rest IH];
    intros memory block offset; cbn [Genv.store_init_data_list]; [reflexivity |].
  rewrite (demo_equal_symbols_initial_datum globals target Hsymbols).
  destruct (Genv.store_init_data globals memory block offset datum); [apply IH | reflexivity].
Qed.

Lemma demo_empty_readonly_allocation_preserved : forall choose
    (globals target : Genv.t Clight.fundef type),
  (forall name, Genv.find_symbol target name = Genv.find_symbol globals name) ->
  forall memory entry,
    Genv.alloc_global target memory (demo_normalize_empty_readonly_global choose entry) =
    Genv.alloc_global globals memory entry.
Proof.
  intros choose globals target Hsymbols memory [name definition].
  destruct definition as [function_ | [info init readonly volatile]];
    cbn [demo_normalize_empty_readonly_global Genv.alloc_global
      gvar_info gvar_init gvar_readonly gvar_volatile]; [reflexivity |].
  destruct (Mem.alloc memory 0 (init_data_list_size init)) as [allocated block].
  destruct (store_zeros allocated block 0 (init_data_list_size init)) as [zeroed |];
    [| reflexivity].
  rewrite (demo_equal_symbols_initial_data globals target Hsymbols).
  destruct (Genv.store_init_data_list globals zeroed block 0 init) as [initialized |];
    [| reflexivity].
  destruct init; [apply demo_empty_drop_permissions_independent | reflexivity].
Qed.

Lemma demo_empty_readonly_allocations_preserved : forall choose
    (globals target : Genv.t Clight.fundef type),
  (forall name, Genv.find_symbol target name = Genv.find_symbol globals name) ->
  forall entries memory,
    Genv.alloc_globals target memory (map (demo_normalize_empty_readonly_global choose) entries) =
    Genv.alloc_globals globals memory entries.
Proof.
  intros choose globals target Hsymbols entries.
  induction entries as [|entry rest IH]; intro memory; cbn [Genv.alloc_globals map]; [reflexivity |].
  rewrite (demo_empty_readonly_allocation_preserved choose globals target Hsymbols).
  destruct (Genv.alloc_global globals memory entry); [apply IH | reflexivity].
Qed.

Theorem demo_empty_readonly_initial_memory_preserved : forall choose (p : Clight.program),
  Genv.init_mem (demo_normalize_empty_readonly_program choose p) = Genv.init_mem p.
Proof.
  intros choose p. unfold Genv.init_mem.
  change (Genv.alloc_globals (Genv.globalenv (demo_normalize_empty_readonly_program choose p))
    Mem.empty (map (demo_normalize_empty_readonly_global choose) (Ctypes.prog_defs p)) =
    Genv.alloc_globals (Genv.globalenv p) Mem.empty (Ctypes.prog_defs p)).
  apply demo_empty_readonly_allocations_preserved.
  exact (@demo_metadata_symbols_agree _ _ (demo_empty_readonly_environment_agrees choose p)).
Qed.

Fixpoint demo_find_initialized_array_definition
    (definitions : list (ident * globdef Clight.fundef type))
    (name : ident) (zero_type : type) (volatile : bool) : option (globvar type) :=
  match definitions with
  | [] => None
  | (candidate, Gvar variable) :: rest =>
      match gvar_info variable, gvar_init variable with
      | Tarray element extent attributes, _ :: _ =>
          if Pos.eqb name candidate && Z.ltb 0 extent &&
             (if Ctypes.type_eq (Tarray element 0 attributes) zero_type then true else false) &&
             Bool.eqb volatile (gvar_volatile variable)
          then Some variable
          else demo_find_initialized_array_definition rest name zero_type volatile
      | _, _ => demo_find_initialized_array_definition rest name zero_type volatile
      end
  | _ :: rest => demo_find_initialized_array_definition rest name zero_type volatile
  end.

Definition demo_derive_external_array_readonly definitions public name (variable : globvar type) : bool :=
  if existsb (Pos.eqb name) public then
    match gvar_info variable, gvar_init variable with
    | Tarray element extent attributes, [] =>
        if Z.eqb extent 0 then
          match demo_find_initialized_array_definition definitions name
            (Tarray element 0 attributes) (gvar_volatile variable) with
          | Some defined => gvar_readonly defined
          | None => gvar_readonly variable
          end
        else gvar_readonly variable
    | _, _ => gvar_readonly variable
    end
  else gvar_readonly variable.

Definition demo_normalize_script_unit_declarations definitions (p : Clight.program) : Clight.program :=
  let readonly_normalized := demo_normalize_empty_readonly_program
    (demo_derive_external_array_readonly definitions (Ctypes.prog_public p)) p in
  demo_update_program_metadata
    (demo_complete_public_array_metadata definitions (Ctypes.prog_public p)) readonly_normalized.

Definition demo_normalize_script_declaration_units definitions units :=
  map (demo_normalize_script_unit_declarations definitions) units.

Definition demo_link_normalized_script_units definitions units :=
  match demo_normalize_script_declaration_units definitions units with
  | [] => None
  | first :: rest => demo_fold_official_ast_links (Ctypes.program_of_program first) rest
  end.

Definition demo_normalized_script_ast_link_claim_us_jp : Prop :=
  (exists linked,
    demo_link_normalized_script_units demo_us_array_definitions demo_us_array_completion_units = Some linked) /\
  (exists linked,
    demo_link_normalized_script_units demo_jp_array_definitions demo_jp_array_completion_units = Some linked).

Theorem demo_metadata_initial_memory_equal : forall update (p : Clight.program),
  Genv.init_mem (demo_update_program_metadata update p) = Genv.init_mem p.
Proof.
  intros update p. destruct (Genv.init_mem p) as [memory |] eqn:Hsource.
  - exact (proj1 (demo_metadata_completion_preserves_initial_memory update p memory) Hsource).
  - destruct (Genv.init_mem (demo_update_program_metadata update p)) as [memory |] eqn:Htarget;
      [| reflexivity].
    apply (proj2 (demo_metadata_completion_preserves_initial_memory update p memory)) in Htarget.
    congruence.
Qed.

Definition demo_script_declaration_refinement definitions (p : Clight.program) : Prop :=
  Genv.init_mem (demo_normalize_script_unit_declarations definitions p) = Genv.init_mem p /\
  (forall state trace after,
    Clight.step2 (Clight.globalenv p) state trace after <->
    Clight.step2 (Clight.globalenv (demo_normalize_script_unit_declarations definitions p)) state trace after).

Theorem demo_script_declaration_refinement_proved : forall definitions p,
  demo_script_declaration_refinement definitions p.
Proof.
  intros definitions p. unfold demo_script_declaration_refinement,
    demo_normalize_script_unit_declarations. split.
  - rewrite demo_metadata_initial_memory_equal, demo_empty_readonly_initial_memory_preserved.
    reflexivity.
  - intros state trace after.
    rewrite <- (demo_metadata_completion_preserves_small_steps
      (demo_complete_public_array_metadata definitions (Ctypes.prog_public p))
      (demo_normalize_empty_readonly_program
        (demo_derive_external_array_readonly definitions (Ctypes.prog_public p)) p)).
    apply demo_empty_readonly_small_steps_preserved.
Qed.

Definition demo_generated_script_declaration_refinement_claim_us_jp : Prop :=
  Forall (demo_script_declaration_refinement demo_us_array_definitions) demo_us_array_completion_units /\
  Forall (demo_script_declaration_refinement demo_jp_array_definitions) demo_jp_array_completion_units.

Theorem generated_demo_script_declaration_refinements_us_jp :
  demo_generated_script_declaration_refinement_claim_us_jp.
Proof.
  split; apply Forall_forall; intros unit Hunit; apply demo_script_declaration_refinement_proved.
Qed.

Lemma demo_official_clight_link_projects : forall (first second linked : Clight.program),
  Ctypes.link_program first second = Some linked ->
  link (Ctypes.program_of_program first) (Ctypes.program_of_program second) =
    Some (Ctypes.program_of_program linked) /\
  link (Ctypes.prog_types first) (Ctypes.prog_types second) = Some (Ctypes.prog_types linked).
Proof.
  intros first second linked Hlink. unfold Ctypes.link_program in Hlink.
  destruct (link (Ctypes.program_of_program first) (Ctypes.program_of_program second))
    as [ast |] eqn:Hast; [| discriminate].
  destruct (Ctypes.lift_option (link (Ctypes.prog_types first) (Ctypes.prog_types second)))
    as [[types Htypes] | Htypes]; [| discriminate].
  destruct (Ctypes.link_build_composite_env
    (Ctypes.prog_types first) (Ctypes.prog_types second) types
    (Ctypes.prog_comp_env first) (Ctypes.prog_comp_env second)
    (Ctypes.prog_comp_env_eq first) (Ctypes.prog_comp_env_eq second) Htypes)
    as (environment & Henvironment & Hextends).
  inversion Hlink; subst linked. split; [destruct ast; reflexivity | exact Htypes].
Qed.

Fixpoint demo_fold_official_composite_links (first : list composite_definition)
    (rest : list Clight.program) : option (list composite_definition) :=
  match rest with
  | [] => Some first
  | unit :: remaining =>
      match link first (Ctypes.prog_types unit) with
      | Some linked => demo_fold_official_composite_links linked remaining
      | None => None
      end
  end.

Fixpoint demo_fold_official_clight_links (first : Clight.program)
    (rest : list Clight.program) : option Clight.program :=
  match rest with
  | [] => Some first
  | unit :: remaining =>
      match Ctypes.link_program first unit with
      | Some linked => demo_fold_official_clight_links linked remaining
      | None => None
      end
  end.

Lemma demo_official_clight_fold_exists_from_components : forall rest (first : Clight.program),
  (exists ast, demo_fold_official_ast_links (Ctypes.program_of_program first) rest = Some ast) ->
  (exists types, demo_fold_official_composite_links (Ctypes.prog_types first) rest = Some types) ->
  exists linked, demo_fold_official_clight_links first rest = Some linked.
Proof.
  induction rest as [|unit rest IH]; intros first (ast_final & Hast_final) (types_final & Htypes_final).
  - exists first. reflexivity.
  - change ((match link (Ctypes.program_of_program first) (Ctypes.program_of_program unit) with
      | Some partial => demo_fold_official_ast_links partial rest | None => None end) =
      Some ast_final) in Hast_final.
    change ((match link (Ctypes.prog_types first) (Ctypes.prog_types unit) with
      | Some partial => demo_fold_official_composite_links partial rest | None => None end) =
      Some types_final) in Htypes_final.
    destruct (link (Ctypes.program_of_program first) (Ctypes.program_of_program unit))
      as [ast |] eqn:Hast; [| discriminate].
    destruct (link (Ctypes.prog_types first) (Ctypes.prog_types unit))
      as [types |] eqn:Htypes; [| discriminate].
    destruct (demo_official_clight_link_exists_from_components first unit
      (ex_intro _ ast Hast) (ex_intro _ types Htypes)) as (linked & Hlink).
    destruct (demo_official_clight_link_projects first unit linked Hlink)
      as [Hast_projection Htypes_projection].
    assert (Hast_equal : Ctypes.program_of_program linked = ast) by congruence.
    assert (Htypes_equal : Ctypes.prog_types linked = types) by congruence.
    edestruct (IH linked) as (result & Hresult).
    + exists ast_final. rewrite Hast_equal. exact Hast_final.
    + exists types_final. rewrite Htypes_equal. exact Htypes_final.
    + exists result. cbn [demo_fold_official_clight_links]. rewrite Hlink. exact Hresult.
Qed.

Definition demo_link_normalized_script_composites definitions units :=
  match demo_normalize_script_declaration_units definitions units with
  | [] => None
  | first :: rest => demo_fold_official_composite_links (Ctypes.prog_types first) rest
  end.

Definition demo_normalized_script_composite_link_claim_us_jp : Prop :=
  (exists types,
    demo_link_normalized_script_composites demo_us_array_definitions demo_us_array_completion_units = Some types) /\
  (exists types,
    demo_link_normalized_script_composites demo_jp_array_definitions demo_jp_array_completion_units = Some types).

Theorem generated_demo_normalized_script_composite_links_us_jp :
  demo_normalized_script_composite_link_claim_us_jp.
Proof.
  split; apply demo_option_some_sound; vm_compute; reflexivity.
Qed.

Theorem generated_demo_normalized_script_ast_links_us_jp :
  demo_normalized_script_ast_link_claim_us_jp.
Proof.
  split; apply demo_official_ast_link_accepted_sound; vm_compute; reflexivity.
Qed.

Definition demo_link_normalized_script_clight definitions units :=
  match demo_normalize_script_declaration_units definitions units with
  | [] => None
  | first :: rest => demo_fold_official_clight_links first rest
  end.

Lemma demo_normalized_clight_link_exists : forall definitions units,
  (exists ast, demo_link_normalized_script_units definitions units = Some ast) ->
  (exists types, demo_link_normalized_script_composites definitions units = Some types) ->
  exists linked, demo_link_normalized_script_clight definitions units = Some linked.
Proof.
  intros definitions units Hast Htypes.
  unfold demo_link_normalized_script_clight, demo_link_normalized_script_units,
    demo_link_normalized_script_composites in *.
  destruct (demo_normalize_script_declaration_units definitions units) as [|first rest].
  - destruct Hast as [ast Hast]. discriminate.
  - apply demo_official_clight_fold_exists_from_components; assumption.
Qed.

Definition demo_normalized_script_clight_link_claim_us_jp : Prop :=
  (exists linked,
    demo_link_normalized_script_clight demo_us_array_definitions demo_us_array_completion_units = Some linked) /\
  (exists linked,
    demo_link_normalized_script_clight demo_jp_array_definitions demo_jp_array_completion_units = Some linked).

Theorem generated_demo_normalized_script_clight_links_us_jp :
  demo_normalized_script_clight_link_claim_us_jp.
Proof.
  destruct generated_demo_normalized_script_ast_links_us_jp as [Hast_us Hast_jp].
  destruct generated_demo_normalized_script_composite_links_us_jp as [Htypes_us Htypes_jp].
  split; apply demo_normalized_clight_link_exists; assumption.
Qed.

Definition demo_normalize_script_declaration_entry definitions public entry :=
  demo_update_global_metadata (demo_complete_public_array_metadata definitions public)
    (demo_normalize_empty_readonly_global (demo_derive_external_array_readonly definitions public) entry).

Lemma demo_normalization_preserves_defined_variables : forall definitions public name variable,
  gvar_init variable <> [] ->
  demo_normalize_script_declaration_entry definitions public (name, Gvar variable) = (name, Gvar variable).
Proof.
  intros definitions public name [info init readonly volatile] Hinit.
  destruct init as [|datum rest]; [contradiction |].
  unfold demo_normalize_script_declaration_entry, demo_update_global_metadata,
    demo_normalize_empty_readonly_global, demo_complete_public_array_metadata.
  cbn [gvar_info gvar_init gvar_readonly gvar_volatile].
  destruct (existsb (Pos.eqb name) public); [destruct info |]; reflexivity.
Qed.

Definition demo_normalized_entry_completion_checked definitions public entry : bool :=
  match entry, snd (demo_normalize_script_declaration_entry definitions public entry) with
  | (name, Gvar original), Gvar normalized =>
      if (if Ctypes.type_eq (gvar_info original) (gvar_info normalized) then true else false) &&
         Bool.eqb (gvar_readonly original) (gvar_readonly normalized)
      then true else
        match gvar_init original with
        | [] => existsb (Pos.eqb name) public &&
            demo_array_extent_completion_checked (gvar_info original) (gvar_info normalized) &&
            Bool.eqb (gvar_volatile original) (gvar_volatile normalized) &&
            match demo_find_initialized_array_definition definitions name
              (gvar_info original) (gvar_volatile original) with
            | Some definition =>
                (if Ctypes.type_eq (gvar_info normalized) (gvar_info definition) then true else false) &&
                Bool.eqb (gvar_readonly normalized) (gvar_readonly definition)
            | None => false
            end
        | _ => false
        end
  | (_, Gfun _), Gfun _ => true
  | _, _ => false
  end.

Definition demo_normalized_array_completions_checked_claim_us_jp : Prop :=
  forallb (fun unit => forallb
    (demo_normalized_entry_completion_checked demo_us_array_definitions (Ctypes.prog_public unit))
    (Ctypes.prog_defs unit)) demo_us_array_completion_units = true /\
  forallb (fun unit => forallb
    (demo_normalized_entry_completion_checked demo_jp_array_definitions (Ctypes.prog_public unit))
    (Ctypes.prog_defs unit)) demo_jp_array_completion_units = true.

Theorem generated_demo_normalized_array_completions_checked_us_jp :
  demo_normalized_array_completions_checked_claim_us_jp.
Proof. split; vm_compute; reflexivity. Qed.

Definition demo_extern_array_completion_boundary_claim_us_jp : Prop :=
  demo_generated_script_declaration_refinement_claim_us_jp /\
  demo_normalized_array_completions_checked_claim_us_jp /\
  demo_normalized_script_clight_link_claim_us_jp.

Theorem generated_demo_extern_array_completion_boundary_us_jp :
  demo_extern_array_completion_boundary_claim_us_jp.
Proof.
  exact (conj generated_demo_script_declaration_refinements_us_jp
    (conj generated_demo_normalized_array_completions_checked_us_jp
      generated_demo_normalized_script_clight_links_us_jp)).
Qed.
