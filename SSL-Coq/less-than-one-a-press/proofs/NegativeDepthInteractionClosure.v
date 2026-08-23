(** Stock interaction dispatch cannot install the long-jump state needed by
    the negative-quicksand writer.

    [ActionDepthAliasCensus] leaves one unguarded indirect [MarioState *]
    call: [mario_process_interactions] indexes the writable
    [sInteractionHandlers] table.  This file follows every stock entry of that
    table.  Every action-setter argument in the 29 distinct handlers is either
    a non-target literal, one of four locally chosen action temporaries, or the
    result of one of two checked dynamic helpers.  The local temporaries and
    Bully helper are assigned only non-target literals.  Snufit's knockback
    helper selects a 3-by-3 entry from one of two fully checked tables using
    indices restricted to 0, 1, or 2; all eighteen initialized entries are
    non-target actions.

    The three tables are writable, so this is deliberately an initialized-
    table source boundary rather than a linked writable-memory invariant.  A
    surviving interaction installer must first change a handler/knockback
    table, retarget a call, forge an argument or pointer, or use an unframed
    outside effect. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Cop Ctypes Integers.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ActionDepthAliasCensus Area1WarpTopCloneCensus
  LongJumpProvenanceBoundary.

Import ListNotations.
Local Open Scope Z_scope.

Module NDI_US := us_interaction.
Module NDI_JP := jp_interaction.

Definition ndi_target_literal (value : int) : bool :=
  Int.eq value (Int.repr act_long_jump) ||
  Int.eq value (Int.repr act_long_jump_land).

Definition ndi_safe_action_argument
    (allowed_temporaries : list ident) (argument : expr) : bool :=
  match argument with
  | Econst_int value _ => negb (ndi_target_literal value)
  | Etempvar temporary _ => existsb (Pos.eqb temporary) allowed_temporaries
  | _ => false
  end.

Definition ndi_is_action_setter (set_action drop_and_set_action : ident)
    (callee : ident) : bool :=
  Pos.eqb callee set_action || Pos.eqb callee drop_and_set_action.

Fixpoint ndi_action_setter_arguments_checked_s
    (set_action drop_and_set_action : ident)
    (allowed_temporaries : list ident) (body : statement) : bool :=
  match body with
  | Scall _ (Evar callee _) arguments =>
      if ndi_is_action_setter set_action drop_and_set_action callee
      then
        match arguments with
        | _ :: action :: _ =>
            ndi_safe_action_argument allowed_temporaries action
        | _ => false
        end
      else true
  | Scall _ _ _ => true
  | Ssequence first rest | Sloop first rest =>
      ndi_action_setter_arguments_checked_s set_action drop_and_set_action
        allowed_temporaries first &&
      ndi_action_setter_arguments_checked_s set_action drop_and_set_action
        allowed_temporaries rest
  | Sifthenelse _ yes no =>
      ndi_action_setter_arguments_checked_s set_action drop_and_set_action
        allowed_temporaries yes &&
      ndi_action_setter_arguments_checked_s set_action drop_and_set_action
        allowed_temporaries no
  | Sswitch _ cases =>
      ndi_action_setter_arguments_checked_ls set_action drop_and_set_action
        allowed_temporaries cases
  | Slabel _ nested =>
      ndi_action_setter_arguments_checked_s set_action drop_and_set_action
        allowed_temporaries nested
  | _ => true
  end
with ndi_action_setter_arguments_checked_ls
    (set_action drop_and_set_action : ident)
    (allowed_temporaries : list ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      ndi_action_setter_arguments_checked_s set_action drop_and_set_action
        allowed_temporaries body &&
      ndi_action_setter_arguments_checked_ls set_action drop_and_set_action
        allowed_temporaries rest
  end.

Definition ndi_us_handler_specs : list (statement * list ident) :=
  [(fn_body NDI_US.f_interact_coin, []);
   (fn_body NDI_US.f_interact_water_ring, []);
   (fn_body NDI_US.f_interact_star_or_key, [NDI_US._starGrabAction]);
   (fn_body NDI_US.f_interact_bbh_entrance, []);
   (fn_body NDI_US.f_interact_warp, []);
   (fn_body NDI_US.f_interact_warp_door, [NDI_US._doorAction]);
   (fn_body NDI_US.f_interact_door, [NDI_US._enterDoorAction]);
   (fn_body NDI_US.f_interact_cannon_base, []);
   (fn_body NDI_US.f_interact_igloo_barrier, []);
   (fn_body NDI_US.f_interact_tornado, []);
   (fn_body NDI_US.f_interact_whirlpool, []);
   (fn_body NDI_US.f_interact_strong_wind, []);
   (fn_body NDI_US.f_interact_flame, [NDI_US._burningAction]);
   (fn_body NDI_US.f_interact_snufit_bullet, [NDI_US._t'1]);
   (fn_body NDI_US.f_interact_clam_or_bubba, []);
   (fn_body NDI_US.f_interact_bully, [NDI_US._t'2]);
   (fn_body NDI_US.f_interact_shock, []);
   (fn_body NDI_US.f_interact_bounce_top, []);
   (fn_body NDI_US.f_interact_mr_blizzard, []);
   (fn_body NDI_US.f_interact_hit_from_below, []);
   (fn_body NDI_US.f_interact_damage, []);
   (fn_body NDI_US.f_interact_pole, []);
   (fn_body NDI_US.f_interact_hoot, []);
   (fn_body NDI_US.f_interact_breakable, []);
   (fn_body NDI_US.f_interact_koopa_shell, []);
   (fn_body NDI_US.f_interact_unknown_08, []);
   (fn_body NDI_US.f_interact_cap, []);
   (fn_body NDI_US.f_interact_grabbable, []);
   (fn_body NDI_US.f_interact_text, [])].

Definition ndi_jp_handler_specs : list (statement * list ident) :=
  [(fn_body NDI_JP.f_interact_coin, []);
   (fn_body NDI_JP.f_interact_water_ring, []);
   (fn_body NDI_JP.f_interact_star_or_key, [NDI_JP._starGrabAction]);
   (fn_body NDI_JP.f_interact_bbh_entrance, []);
   (fn_body NDI_JP.f_interact_warp, []);
   (fn_body NDI_JP.f_interact_warp_door, [NDI_JP._doorAction]);
   (fn_body NDI_JP.f_interact_door, [NDI_JP._enterDoorAction]);
   (fn_body NDI_JP.f_interact_cannon_base, []);
   (fn_body NDI_JP.f_interact_igloo_barrier, []);
   (fn_body NDI_JP.f_interact_tornado, []);
   (fn_body NDI_JP.f_interact_whirlpool, []);
   (fn_body NDI_JP.f_interact_strong_wind, []);
   (fn_body NDI_JP.f_interact_flame, [NDI_JP._burningAction]);
   (fn_body NDI_JP.f_interact_snufit_bullet, [NDI_JP._t'1]);
   (fn_body NDI_JP.f_interact_clam_or_bubba, []);
   (fn_body NDI_JP.f_interact_bully, [NDI_JP._t'2]);
   (fn_body NDI_JP.f_interact_shock, []);
   (fn_body NDI_JP.f_interact_bounce_top, []);
   (fn_body NDI_JP.f_interact_mr_blizzard, []);
   (fn_body NDI_JP.f_interact_hit_from_below, []);
   (fn_body NDI_JP.f_interact_damage, []);
   (fn_body NDI_JP.f_interact_pole, []);
   (fn_body NDI_JP.f_interact_hoot, []);
   (fn_body NDI_JP.f_interact_breakable, []);
   (fn_body NDI_JP.f_interact_koopa_shell, []);
   (fn_body NDI_JP.f_interact_unknown_08, []);
   (fn_body NDI_JP.f_interact_cap, []);
   (fn_body NDI_JP.f_interact_grabbable, []);
   (fn_body NDI_JP.f_interact_text, [])].

Fixpoint ndi_addrof_initializers (data : list init_data) : list ident :=
  match data with
  | [] => []
  | Init_addrof id _ :: rest => id :: ndi_addrof_initializers rest
  | _ :: rest => ndi_addrof_initializers rest
  end.

Definition ndi_us_expected_interaction_handlers : list ident :=
  [NDI_US._interact_coin; NDI_US._interact_water_ring;
   NDI_US._interact_star_or_key; NDI_US._interact_bbh_entrance;
   NDI_US._interact_warp; NDI_US._interact_warp_door;
   NDI_US._interact_door; NDI_US._interact_cannon_base;
   NDI_US._interact_igloo_barrier; NDI_US._interact_tornado;
   NDI_US._interact_whirlpool; NDI_US._interact_strong_wind;
   NDI_US._interact_flame; NDI_US._interact_snufit_bullet;
   NDI_US._interact_clam_or_bubba; NDI_US._interact_bully;
   NDI_US._interact_shock; NDI_US._interact_bounce_top;
   NDI_US._interact_mr_blizzard; NDI_US._interact_hit_from_below;
   NDI_US._interact_bounce_top; NDI_US._interact_damage;
   NDI_US._interact_pole; NDI_US._interact_hoot;
   NDI_US._interact_breakable; NDI_US._interact_bounce_top;
   NDI_US._interact_koopa_shell; NDI_US._interact_unknown_08;
   NDI_US._interact_cap; NDI_US._interact_grabbable;
   NDI_US._interact_text].

Definition ndi_jp_expected_interaction_handlers : list ident :=
  [NDI_JP._interact_coin; NDI_JP._interact_water_ring;
   NDI_JP._interact_star_or_key; NDI_JP._interact_bbh_entrance;
   NDI_JP._interact_warp; NDI_JP._interact_warp_door;
   NDI_JP._interact_door; NDI_JP._interact_cannon_base;
   NDI_JP._interact_igloo_barrier; NDI_JP._interact_tornado;
   NDI_JP._interact_whirlpool; NDI_JP._interact_strong_wind;
   NDI_JP._interact_flame; NDI_JP._interact_snufit_bullet;
   NDI_JP._interact_clam_or_bubba; NDI_JP._interact_bully;
   NDI_JP._interact_shock; NDI_JP._interact_bounce_top;
   NDI_JP._interact_mr_blizzard; NDI_JP._interact_hit_from_below;
   NDI_JP._interact_bounce_top; NDI_JP._interact_damage;
   NDI_JP._interact_pole; NDI_JP._interact_hoot;
   NDI_JP._interact_breakable; NDI_JP._interact_bounce_top;
   NDI_JP._interact_koopa_shell; NDI_JP._interact_unknown_08;
   NDI_JP._interact_cap; NDI_JP._interact_grabbable;
   NDI_JP._interact_text].

Definition ndi_interaction_handler_initializer_claim : Prop :=
  ndi_addrof_initializers (gvar_init NDI_US.v_sInteractionHandlers) =
    ndi_us_expected_interaction_handlers /\
  ndi_addrof_initializers (gvar_init NDI_JP.v_sInteractionHandlers) =
    ndi_jp_expected_interaction_handlers /\
  gvar_readonly NDI_US.v_sInteractionHandlers = false /\
  gvar_readonly NDI_JP.v_sInteractionHandlers = false /\
  internal_function_assignment_sites NDI_US._sInteractionHandlers
      us_generated_definitions = [] /\
  internal_function_assignment_sites NDI_JP._sInteractionHandlers
      jp_generated_definitions_for_alias = [].

Theorem stock_interaction_handler_initializers_are_exact :
  ndi_interaction_handler_initializer_claim.
Proof.
  unfold ndi_interaction_handler_initializer_claim,
    ndi_us_expected_interaction_handlers,
    ndi_jp_expected_interaction_handlers,
    us_generated_definitions, jp_generated_definitions_for_alias.
  vm_compute. repeat split; reflexivity.
Qed.

Definition ndi_handler_spec_checked
    (set_action drop_and_set_action : ident)
    (spec : statement * list ident) : bool :=
  ndi_action_setter_arguments_checked_s set_action drop_and_set_action
    (snd spec) (fst spec).

Theorem all_stock_interaction_setter_arguments_are_recognized :
  forallb
    (ndi_handler_spec_checked
      NDI_US._set_mario_action NDI_US._drop_and_set_mario_action)
    ndi_us_handler_specs = true /\
  forallb
    (ndi_handler_spec_checked
      NDI_JP._set_mario_action NDI_JP._drop_and_set_mario_action)
    ndi_jp_handler_specs = true.
Proof. vm_compute. split; reflexivity. Qed.

Fixpoint ndi_safe_literal_expression (expression : expr) : bool :=
  match expression with
  | Econst_int value _ => negb (ndi_target_literal value)
  | Ecast nested _ => ndi_safe_literal_expression nested
  | _ => false
  end.

Fixpoint ndi_all_temp_sets_are_safe_literals_s
    (target : ident) (body : statement) : bool :=
  match body with
  | Sset found rhs =>
      if Pos.eqb found target then ndi_safe_literal_expression rhs else true
  | Ssequence first rest | Sloop first rest =>
      ndi_all_temp_sets_are_safe_literals_s target first &&
      ndi_all_temp_sets_are_safe_literals_s target rest
  | Sifthenelse _ yes no =>
      ndi_all_temp_sets_are_safe_literals_s target yes &&
      ndi_all_temp_sets_are_safe_literals_s target no
  | Sswitch _ cases => ndi_all_temp_sets_are_safe_literals_ls target cases
  | Slabel _ nested => ndi_all_temp_sets_are_safe_literals_s target nested
  | _ => true
  end
with ndi_all_temp_sets_are_safe_literals_ls
    (target : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      ndi_all_temp_sets_are_safe_literals_s target body &&
      ndi_all_temp_sets_are_safe_literals_ls target rest
  end.

Fixpoint ndi_temp_set_count_s (target : ident) (body : statement) : nat :=
  match body with
  | Sset found _ => if Pos.eqb found target then 1%nat else 0%nat
  | Ssequence first rest | Sloop first rest =>
      (ndi_temp_set_count_s target first + ndi_temp_set_count_s target rest)%nat
  | Sifthenelse _ yes no =>
      (ndi_temp_set_count_s target yes + ndi_temp_set_count_s target no)%nat
  | Sswitch _ cases => ndi_temp_set_count_ls target cases
  | Slabel _ nested => ndi_temp_set_count_s target nested
  | _ => 0%nat
  end
with ndi_temp_set_count_ls (target : ident)
    (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (ndi_temp_set_count_s target body + ndi_temp_set_count_ls target rest)%nat
  end.

Definition ndi_local_action_temporary_claim : Prop :=
  ndi_all_temp_sets_are_safe_literals_s NDI_US._starGrabAction
    (fn_body NDI_US.f_interact_star_or_key) = true /\
  ndi_temp_set_count_s NDI_US._starGrabAction
    (fn_body NDI_US.f_interact_star_or_key) = 5%nat /\
  ndi_all_temp_sets_are_safe_literals_s NDI_US._doorAction
    (fn_body NDI_US.f_interact_warp_door) = true /\
  ndi_temp_set_count_s NDI_US._doorAction
    (fn_body NDI_US.f_interact_warp_door) = 5%nat /\
  ndi_all_temp_sets_are_safe_literals_s NDI_US._enterDoorAction
    (fn_body NDI_US.f_interact_door) = true /\
  ndi_temp_set_count_s NDI_US._enterDoorAction
    (fn_body NDI_US.f_interact_door) = 4%nat /\
  ndi_all_temp_sets_are_safe_literals_s NDI_US._burningAction
    (fn_body NDI_US.f_interact_flame) = true /\
  ndi_temp_set_count_s NDI_US._burningAction
    (fn_body NDI_US.f_interact_flame) = 2%nat /\
  ndi_all_temp_sets_are_safe_literals_s NDI_JP._starGrabAction
    (fn_body NDI_JP.f_interact_star_or_key) = true /\
  ndi_temp_set_count_s NDI_JP._starGrabAction
    (fn_body NDI_JP.f_interact_star_or_key) = 5%nat /\
  ndi_all_temp_sets_are_safe_literals_s NDI_JP._doorAction
    (fn_body NDI_JP.f_interact_warp_door) = true /\
  ndi_temp_set_count_s NDI_JP._doorAction
    (fn_body NDI_JP.f_interact_warp_door) = 5%nat /\
  ndi_all_temp_sets_are_safe_literals_s NDI_JP._enterDoorAction
    (fn_body NDI_JP.f_interact_door) = true /\
  ndi_temp_set_count_s NDI_JP._enterDoorAction
    (fn_body NDI_JP.f_interact_door) = 4%nat /\
  ndi_all_temp_sets_are_safe_literals_s NDI_JP._burningAction
    (fn_body NDI_JP.f_interact_flame) = true /\
  ndi_temp_set_count_s NDI_JP._burningAction
    (fn_body NDI_JP.f_interact_flame) = 2%nat.

Theorem all_local_interaction_action_temporaries_are_target_free :
  ndi_local_action_temporary_claim.
Proof.
  unfold ndi_local_action_temporary_claim.
  vm_compute. repeat split; reflexivity.
Qed.

Fixpoint ndi_temp_is_only_call_result_s
    (target expected_callee : ident) (body : statement) : bool :=
  match body with
  | Sset found _ => negb (Pos.eqb found target)
  | Scall result function _ =>
      match result with
      | Some found =>
          if Pos.eqb found target
          then
            match function with
            | Evar callee _ => Pos.eqb callee expected_callee
            | _ => false
            end
          else true
      | None => true
      end
  | Ssequence first rest | Sloop first rest =>
      ndi_temp_is_only_call_result_s target expected_callee first &&
      ndi_temp_is_only_call_result_s target expected_callee rest
  | Sifthenelse _ yes no =>
      ndi_temp_is_only_call_result_s target expected_callee yes &&
      ndi_temp_is_only_call_result_s target expected_callee no
  | Sswitch _ cases =>
      ndi_temp_is_only_call_result_ls target expected_callee cases
  | Slabel _ nested =>
      ndi_temp_is_only_call_result_s target expected_callee nested
  | _ => true
  end
with ndi_temp_is_only_call_result_ls
    (target expected_callee : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      ndi_temp_is_only_call_result_s target expected_callee body &&
      ndi_temp_is_only_call_result_ls target expected_callee rest
  end.

Fixpoint ndi_call_result_count_s
    (target expected_callee : ident) (body : statement) : nat :=
  match body with
  | Scall (Some found) (Evar callee _) _ =>
      if Pos.eqb found target && Pos.eqb callee expected_callee
      then 1%nat else 0%nat
  | Ssequence first rest | Sloop first rest =>
      (ndi_call_result_count_s target expected_callee first +
       ndi_call_result_count_s target expected_callee rest)%nat
  | Sifthenelse _ yes no =>
      (ndi_call_result_count_s target expected_callee yes +
       ndi_call_result_count_s target expected_callee no)%nat
  | Sswitch _ cases => ndi_call_result_count_ls target expected_callee cases
  | Slabel _ nested => ndi_call_result_count_s target expected_callee nested
  | _ => 0%nat
  end
with ndi_call_result_count_ls
    (target expected_callee : ident)
    (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (ndi_call_result_count_s target expected_callee body +
       ndi_call_result_count_ls target expected_callee rest)%nat
  end.

Definition ndi_dynamic_action_source_claim : Prop :=
  ndi_temp_is_only_call_result_s NDI_US._t'1
    NDI_US._determine_knockback_action
    (fn_body NDI_US.f_interact_snufit_bullet) = true /\
  ndi_call_result_count_s NDI_US._t'1 NDI_US._determine_knockback_action
    (fn_body NDI_US.f_interact_snufit_bullet) = 1%nat /\
  ndi_temp_is_only_call_result_s NDI_US._t'2
    NDI_US._bully_knock_back_mario
    (fn_body NDI_US.f_interact_bully) = true /\
  ndi_call_result_count_s NDI_US._t'2 NDI_US._bully_knock_back_mario
    (fn_body NDI_US.f_interact_bully) = 1%nat /\
  ndi_temp_is_only_call_result_s NDI_JP._t'1
    NDI_JP._determine_knockback_action
    (fn_body NDI_JP.f_interact_snufit_bullet) = true /\
  ndi_call_result_count_s NDI_JP._t'1 NDI_JP._determine_knockback_action
    (fn_body NDI_JP.f_interact_snufit_bullet) = 1%nat /\
  ndi_temp_is_only_call_result_s NDI_JP._t'2
    NDI_JP._bully_knock_back_mario
    (fn_body NDI_JP.f_interact_bully) = true /\
  ndi_call_result_count_s NDI_JP._t'2 NDI_JP._bully_knock_back_mario
    (fn_body NDI_JP.f_interact_bully) = 1%nat.

Theorem dynamic_action_arguments_have_one_internal_source :
  ndi_dynamic_action_source_claim.
Proof.
  unfold ndi_dynamic_action_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

Definition ndi_safe_index_expression (expression : expr) : bool :=
  match expression with
  | Econst_int value _ =>
      Int.eq value (Int.repr 0) || Int.eq value (Int.repr 1) ||
      Int.eq value (Int.repr 2)
  | Ecast (Econst_int value _) _ =>
      Int.eq value (Int.repr 0) || Int.eq value (Int.repr 1) ||
      Int.eq value (Int.repr 2)
  | _ => false
  end.

Fixpoint ndi_all_temp_sets_are_safe_indices_s
    (target : ident) (body : statement) : bool :=
  match body with
  | Sset found rhs =>
      if Pos.eqb found target then ndi_safe_index_expression rhs else true
  | Ssequence first rest | Sloop first rest =>
      ndi_all_temp_sets_are_safe_indices_s target first &&
      ndi_all_temp_sets_are_safe_indices_s target rest
  | Sifthenelse _ yes no =>
      ndi_all_temp_sets_are_safe_indices_s target yes &&
      ndi_all_temp_sets_are_safe_indices_s target no
  | Sswitch _ cases => ndi_all_temp_sets_are_safe_indices_ls target cases
  | Slabel _ nested => ndi_all_temp_sets_are_safe_indices_s target nested
  | _ => true
  end
with ndi_all_temp_sets_are_safe_indices_ls
    (target : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      ndi_all_temp_sets_are_safe_indices_s target body &&
      ndi_all_temp_sets_are_safe_indices_ls target rest
  end.

Definition ndi_is_knockback_table_read
    (forward backward terrain strength : ident) (expression : expr) : bool :=
  match expression with
  | Ederef
      (Ebinop Oadd
        (Ederef
          (Ebinop Oadd (Evar table _) (Etempvar terrain_index _) _)
          _)
        (Etempvar strength_index _) _)
      _ =>
      (Pos.eqb table forward || Pos.eqb table backward) &&
      Pos.eqb terrain_index terrain && Pos.eqb strength_index strength
  | _ => false
  end.

Fixpoint ndi_all_temp_sets_are_knockback_reads_s
    (target forward backward terrain strength : ident)
    (body : statement) : bool :=
  match body with
  | Sset found rhs =>
      if Pos.eqb found target
      then ndi_is_knockback_table_read forward backward terrain strength rhs
      else true
  | Ssequence first rest | Sloop first rest =>
      ndi_all_temp_sets_are_knockback_reads_s
        target forward backward terrain strength first &&
      ndi_all_temp_sets_are_knockback_reads_s
        target forward backward terrain strength rest
  | Sifthenelse _ yes no =>
      ndi_all_temp_sets_are_knockback_reads_s
        target forward backward terrain strength yes &&
      ndi_all_temp_sets_are_knockback_reads_s
        target forward backward terrain strength no
  | Sswitch _ cases =>
      ndi_all_temp_sets_are_knockback_reads_ls
        target forward backward terrain strength cases
  | Slabel _ nested =>
      ndi_all_temp_sets_are_knockback_reads_s
        target forward backward terrain strength nested
  | _ => true
  end
with ndi_all_temp_sets_are_knockback_reads_ls
    (target forward backward terrain strength : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      ndi_all_temp_sets_are_knockback_reads_s
        target forward backward terrain strength body &&
      ndi_all_temp_sets_are_knockback_reads_ls
        target forward backward terrain strength rest
  end.

Fixpoint ndi_all_returns_are_temp_s
    (target : ident) (body : statement) : bool :=
  match body with
  | Sreturn (Some (Etempvar found _)) => Pos.eqb found target
  | Sreturn _ => false
  | Ssequence first rest | Sloop first rest =>
      ndi_all_returns_are_temp_s target first &&
      ndi_all_returns_are_temp_s target rest
  | Sifthenelse _ yes no =>
      ndi_all_returns_are_temp_s target yes &&
      ndi_all_returns_are_temp_s target no
  | Sswitch _ cases => ndi_all_returns_are_temp_ls target cases
  | Slabel _ nested => ndi_all_returns_are_temp_s target nested
  | _ => true
  end
with ndi_all_returns_are_temp_ls
    (target : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      ndi_all_returns_are_temp_s target body &&
      ndi_all_returns_are_temp_ls target rest
  end.

Definition ndi_bully_action_helper_claim : Prop :=
  ndi_all_temp_sets_are_safe_literals_s NDI_US._bonkAction
    (fn_body NDI_US.f_bully_knock_back_mario) = true /\
  ndi_temp_set_count_s NDI_US._bonkAction
    (fn_body NDI_US.f_bully_knock_back_mario) = 5%nat /\
  ndi_all_returns_are_temp_s NDI_US._bonkAction
    (fn_body NDI_US.f_bully_knock_back_mario) = true /\
  ndi_all_temp_sets_are_safe_literals_s NDI_JP._bonkAction
    (fn_body NDI_JP.f_bully_knock_back_mario) = true /\
  ndi_temp_set_count_s NDI_JP._bonkAction
    (fn_body NDI_JP.f_bully_knock_back_mario) = 5%nat /\
  ndi_all_returns_are_temp_s NDI_JP._bonkAction
    (fn_body NDI_JP.f_bully_knock_back_mario) = true.

Theorem bully_action_helper_returns_only_target_free_literals :
  ndi_bully_action_helper_claim.
Proof.
  unfold ndi_bully_action_helper_claim.
  vm_compute. repeat split; reflexivity.
Qed.

Definition ndi_forward_knockback_values : list Z :=
  [132197; 132195; 132193; 16910513; 16910513; 16910514;
   805446342; 805446342; 805446342].

Definition ndi_backward_knockback_values : list Z :=
  [132196; 132194; 132192; 16910512; 16910512; 16910515;
   805446341; 805446341; 805446341].

Definition ndi_int32_initializers (values : list Z) : list init_data :=
  map (fun value => Init_int32 (Int.repr value)) values.

Definition ndi_knockback_helper_claim : Prop :=
  gvar_init NDI_US.v_sForwardKnockbackActions =
    ndi_int32_initializers ndi_forward_knockback_values /\
  gvar_init NDI_US.v_sBackwardKnockbackActions =
    ndi_int32_initializers ndi_backward_knockback_values /\
  gvar_init NDI_JP.v_sForwardKnockbackActions =
    ndi_int32_initializers ndi_forward_knockback_values /\
  gvar_init NDI_JP.v_sBackwardKnockbackActions =
    ndi_int32_initializers ndi_backward_knockback_values /\
  gvar_readonly NDI_US.v_sForwardKnockbackActions = false /\
  gvar_readonly NDI_US.v_sBackwardKnockbackActions = false /\
  gvar_readonly NDI_JP.v_sForwardKnockbackActions = false /\
  gvar_readonly NDI_JP.v_sBackwardKnockbackActions = false /\
  ndi_all_temp_sets_are_safe_indices_s NDI_US._terrainIndex
    (fn_body NDI_US.f_determine_knockback_action) = true /\
  ndi_all_temp_sets_are_safe_indices_s NDI_US._strengthIndex
    (fn_body NDI_US.f_determine_knockback_action) = true /\
  ndi_all_temp_sets_are_knockback_reads_s NDI_US._bonkAction
    NDI_US._sForwardKnockbackActions NDI_US._sBackwardKnockbackActions
    NDI_US._terrainIndex NDI_US._strengthIndex
    (fn_body NDI_US.f_determine_knockback_action) = true /\
  ndi_temp_set_count_s NDI_US._bonkAction
    (fn_body NDI_US.f_determine_knockback_action) = 2%nat /\
  ndi_all_returns_are_temp_s NDI_US._bonkAction
    (fn_body NDI_US.f_determine_knockback_action) = true /\
  ndi_all_temp_sets_are_safe_indices_s NDI_JP._terrainIndex
    (fn_body NDI_JP.f_determine_knockback_action) = true /\
  ndi_all_temp_sets_are_safe_indices_s NDI_JP._strengthIndex
    (fn_body NDI_JP.f_determine_knockback_action) = true /\
  ndi_all_temp_sets_are_knockback_reads_s NDI_JP._bonkAction
    NDI_JP._sForwardKnockbackActions NDI_JP._sBackwardKnockbackActions
    NDI_JP._terrainIndex NDI_JP._strengthIndex
    (fn_body NDI_JP.f_determine_knockback_action) = true /\
  ndi_temp_set_count_s NDI_JP._bonkAction
    (fn_body NDI_JP.f_determine_knockback_action) = 2%nat /\
  ndi_all_returns_are_temp_s NDI_JP._bonkAction
    (fn_body NDI_JP.f_determine_knockback_action) = true.

Theorem stock_knockback_action_selection_is_exact :
  ndi_knockback_helper_claim.
Proof.
  unfold ndi_knockback_helper_claim, ndi_int32_initializers,
    ndi_forward_knockback_values, ndi_backward_knockback_values.
  vm_compute. repeat split; reflexivity.
Qed.

Definition ndi_knockback_table_named_source_claim : Prop :=
  internal_body_mentioning_ids NDI_US._sForwardKnockbackActions
      us_generated_definitions = [NDI_US._determine_knockback_action] /\
  internal_body_mentioning_ids NDI_US._sBackwardKnockbackActions
      us_generated_definitions = [NDI_US._determine_knockback_action] /\
  internal_function_assignment_sites NDI_US._sForwardKnockbackActions
      us_generated_definitions = [] /\
  internal_function_assignment_sites NDI_US._sBackwardKnockbackActions
      us_generated_definitions = [] /\
  internal_body_mentioning_ids NDI_JP._sForwardKnockbackActions
      jp_generated_definitions_for_alias = [NDI_JP._determine_knockback_action] /\
  internal_body_mentioning_ids NDI_JP._sBackwardKnockbackActions
      jp_generated_definitions_for_alias = [NDI_JP._determine_knockback_action] /\
  internal_function_assignment_sites NDI_JP._sForwardKnockbackActions
      jp_generated_definitions_for_alias = [] /\
  internal_function_assignment_sites NDI_JP._sBackwardKnockbackActions
      jp_generated_definitions_for_alias = [].

Theorem knockback_action_tables_have_no_named_source_writer :
  ndi_knockback_table_named_source_claim.
Proof.
  unfold ndi_knockback_table_named_source_claim.
  unfold us_generated_definitions, jp_generated_definitions_for_alias,
    internal_body_mentioning_ids, internal_body_mentions_ident.
  vm_compute. repeat split; reflexivity.
Qed.

Fixpoint ndi_literal_action_arguments_s
    (set_action drop_and_set_action : ident)
    (body : statement) : list Z :=
  match body with
  | Scall _ (Evar callee _) (_ :: Econst_int action _ :: _) =>
      if ndi_is_action_setter set_action drop_and_set_action callee
      then [Int.signed action] else []
  | Ssequence first rest | Sloop first rest =>
      ndi_literal_action_arguments_s set_action drop_and_set_action first ++
      ndi_literal_action_arguments_s set_action drop_and_set_action rest
  | Sifthenelse _ yes no =>
      ndi_literal_action_arguments_s set_action drop_and_set_action yes ++
      ndi_literal_action_arguments_s set_action drop_and_set_action no
  | Sswitch _ cases =>
      ndi_literal_action_arguments_ls set_action drop_and_set_action cases
  | Slabel _ nested =>
      ndi_literal_action_arguments_s set_action drop_and_set_action nested
  | _ => []
  end
with ndi_literal_action_arguments_ls
    (set_action drop_and_set_action : ident)
    (cases : labeled_statements) : list Z :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      ndi_literal_action_arguments_s set_action drop_and_set_action body ++
      ndi_literal_action_arguments_ls set_action drop_and_set_action rest
  end.

Definition ndi_handler_literal_actions
    (set_action drop_and_set_action : ident)
    (specs : list (statement * list ident)) : list Z :=
  flat_map
    (fun spec =>
       ndi_literal_action_arguments_s set_action drop_and_set_action
         (fst spec)) specs.

Definition ndi_expected_literal_action_values : list Z :=
  [6409; 5429; 6452; 4918; 4864; 536875781; 536875781;
   536875781; 4913; 4977; 268567410; 805446371; 16910520; 135959;
   805446344; 131896; 276826276; 276826276; 1049409; 1049410; 1192;
   545326150; 4925].

Definition ndi_literal_action_value_claim : Prop :=
  ndi_handler_literal_actions
      NDI_US._set_mario_action NDI_US._drop_and_set_mario_action
      ndi_us_handler_specs = ndi_expected_literal_action_values /\
  ndi_handler_literal_actions
      NDI_JP._set_mario_action NDI_JP._drop_and_set_mario_action
      ndi_jp_handler_specs = ndi_expected_literal_action_values.

Theorem stock_interaction_literal_action_values_are_exact :
  ndi_literal_action_value_claim.
Proof.
  unfold ndi_literal_action_value_claim.
  vm_compute. split; reflexivity.
Qed.

Definition ndi_stock_dynamic_action_values : list Z :=
  [4866; 4871; 4867; 6404; 0; 4910; 4896; 4897; 4913; 4911;
   16910516; 16910517] ++
  ndi_forward_knockback_values ++ ndi_backward_knockback_values.

Theorem every_stock_dynamic_interaction_action_is_non_target :
  forall action,
    In action ndi_stock_dynamic_action_values ->
    non_long_jump_target action.
Proof.
  intros action Haction.
  unfold ndi_stock_dynamic_action_values, ndi_forward_knockback_values,
    ndi_backward_knockback_values in Haction.
  simpl in Haction.
  repeat destruct Haction as [Haction | Haction]; try contradiction;
    subst action; unfold non_long_jump_target, long_jump_target,
      act_long_jump, act_long_jump_land; lia.
Qed.

Theorem every_stock_literal_interaction_action_is_non_target :
  forall action,
    In action ndi_expected_literal_action_values ->
    non_long_jump_target action.
Proof.
  intros action Haction.
  unfold ndi_expected_literal_action_values in Haction.
  simpl in Haction.
  repeat destruct Haction as [Haction | Haction]; try contradiction;
    subst action; unfold non_long_jump_target, long_jump_target,
      act_long_jump, act_long_jump_land; lia.
Qed.

Definition ndi_stock_interaction_action_values : list Z :=
  ndi_expected_literal_action_values ++ ndi_stock_dynamic_action_values.

Theorem every_stock_interaction_action_is_non_target :
  forall action,
    In action ndi_stock_interaction_action_values ->
    non_long_jump_target action.
Proof.
  intros action Haction.
  apply in_app_or in Haction.
  destruct Haction as [Hliteral | Hdynamic].
  - now apply every_stock_literal_interaction_action_is_non_target.
  - now apply every_stock_dynamic_interaction_action_is_non_target.
Qed.

Definition ndi_stock_interaction_installs
    (_ : retail_version) (action : Z) : Prop :=
  In action ndi_stock_interaction_action_values.

Theorem initialized_stock_interactions_discharge_action_closure :
  InteractionActionClosureObligation ndi_stock_interaction_installs.
Proof.
  intros version action Haction.
  exact (every_stock_interaction_action_is_non_target action Haction).
Qed.

Definition NegativeDepthInitializedInteractionSourceBoundary : Prop :=
  (forallb
    (ndi_handler_spec_checked
      NDI_US._set_mario_action NDI_US._drop_and_set_mario_action)
    ndi_us_handler_specs = true) /\
  (forallb
    (ndi_handler_spec_checked
      NDI_JP._set_mario_action NDI_JP._drop_and_set_mario_action)
    ndi_jp_handler_specs = true) /\
  ndi_interaction_handler_initializer_claim /\
  ndi_dynamic_action_source_claim /\
  ndi_literal_action_value_claim /\
  ndi_local_action_temporary_claim /\
  ndi_bully_action_helper_claim /\
  ndi_knockback_helper_claim /\
  ndi_knockback_table_named_source_claim /\
  (forall action,
    In action ndi_stock_interaction_action_values ->
    non_long_jump_target action).

Theorem negative_depth_initialized_interaction_source_boundary_holds :
  NegativeDepthInitializedInteractionSourceBoundary.
Proof.
  unfold NegativeDepthInitializedInteractionSourceBoundary.
  destruct all_stock_interaction_setter_arguments_are_recognized as [Hus Hjp].
  split; [exact Hus |].
  split; [exact Hjp |].
  split; [exact stock_interaction_handler_initializers_are_exact |].
  split; [exact dynamic_action_arguments_have_one_internal_source |].
  split; [exact stock_interaction_literal_action_values_are_exact |].
  split; [exact all_local_interaction_action_temporaries_are_target_free |].
  split; [exact bully_action_helper_returns_only_target_free_literals |].
  split; [exact stock_knockback_action_selection_is_exact |].
  split; [exact knockback_action_tables_have_no_named_source_writer |].
  exact every_stock_interaction_action_is_non_target.
Qed.

(** This is the narrowed linked obligation after the source closure above.
    It names table mutation separately from a forged handler/call target so a
    future counterexample must identify the first concrete producer. *)
Definition NegativeDepthInteractionLinkedResidual
    {State : Type}
    (clean_zero_edge_reachable : State -> Prop)
    (handler_table_changed knockback_table_changed : State -> Prop)
    (interaction_call_retargeted : State -> Prop)
    (interaction_pointer_or_argument_forged : State -> Prop)
    (interaction_external_unframed : State -> Prop) : Prop :=
  forall state,
    clean_zero_edge_reachable state ->
    ~ handler_table_changed state /\
    ~ knockback_table_changed state /\
    ~ interaction_call_retargeted state /\
    ~ interaction_pointer_or_argument_forged state /\
    ~ interaction_external_unframed state.
