From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import us_object_list_processor jp_object_list_processor.
From Pedro.Proofs Require Import GameTypes TTCCogExecution CogActionExecution
  DustSpawnParticleExecution DustSpawnParticleExecutionJP SegmentedPointerBoundary.
Import ListNotations.
Open Scope Z_scope.
Module PA := us_object_list_processor.

Definition cog_spawn_function version :=
  match version with VersionUS => PA.f_spawn_particle
                   | VersionJP => jp_object_list_processor.f_spawn_particle end.
Definition cog_spawn_raw version :=
  match version with VersionUS => PA.__764 | VersionJP => jp_object_list_processor.__727 end.

Ltac particle_operation :=
  first [solve [match goal with
    | H : Int.and ?flags Int.one = Int.one |- _ = ?result =>
        change (Some (Vint (Int.and flags Int.one)) = result); rewrite H; reflexivity
    end] | cbn; reflexivity].
Ltac particle_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ => eapply eval_Etempvar; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [particle_expr | particle_expr | particle_operation]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [particle_expr | particle_operation]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [particle_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; cog_memory_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with particle_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; particle_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      first [eapply eval_Efield_struct; [particle_expr | reflexivity | eassumption | eassumption] |
        eapply eval_Efield_union; [particle_expr | reflexivity | eassumption | eassumption]]
  end.
Ltac particle_skip_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [particle_skip_stmt | particle_skip_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; particle_expr
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [particle_expr | cbn; reflexivity | cog_reduce_statement; particle_skip_stmt]
  end.

Definition cog_occupied_dust_claim version : Prop :=
  forall (ge : Clight.genv) memory current object behavior flags object_co raw_co,
    Genv.find_symbol ge PA._gCurrentObject = Some current ->
    Mem.load Mptr memory current 0 = Some (Vptr object Ptrofs.zero) ->
    Mem.load Mint32 memory object 224 = Some (Vint flags) ->
    Int.and flags Int.one = Int.one ->
    (genv_cenv ge) ! PA._Object = Some object_co ->
    field_offset (genv_cenv ge) PA._rawData (co_members object_co) = OK (136, Full) ->
    (genv_cenv ge) ! (cog_spawn_raw version) = Some raw_co ->
    union_field_offset (genv_cenv ge) PA._asU32 (co_members raw_co) = OK (0, Full) ->
    eval_funcall function_entry2 ge memory (Internal (cog_spawn_function version))
      [Vint Int.one; Vint (Int.repr 142); Vptr behavior Ptrofs.zero] E0 memory Vundef.

(** An already active dust bit rejects this request before allocation and
    position-copy calls. The complete original function executes with identical
    memory, with no callee execution premise. *)
Theorem generated_occupied_dust_request_skips_us_jp :
  forall version, cog_occupied_dust_claim version.
Proof.
  intros version ge memory current object behavior flags object_co raw_co
    Hcurrent Hobject Hflags Hbit Hco Hraw_offset Hraw HasU32.
  destruct version; cbn [cog_spawn_function cog_spawn_raw] in *.
  all: eapply eval_funcall_internal;
    [action_entry | simpl fn_body; timeout 10 particle_skip_stmt | cbn; reflexivity | cbn; reflexivity].
Qed.

(** Clear-bit acceptance still needs the allocator/address and copy executions
    documented by the existing positive-branch proof. This frontier keeps both
    that boundary and the fully executed occupied-bit rejection explicit. *)
Definition cog_particle_acceptance_frontier_claim : Prop :=
  (forall version, cog_occupied_dust_claim version) /\
  DustSpawnParticleExecution.us_spawn_particle_execution_claim /\
  DustSpawnParticleExecutionJP.jp_spawn_particle_execution_claim /\
  segmented_pointer_boundary_claim.

Theorem checked_cog_particle_acceptance_frontier_us_jp : cog_particle_acceptance_frontier_claim.
Proof.
  exact (conj generated_occupied_dust_request_skips_us_jp
    (conj us_generated_spawn_particle_accepts_clear_dust_in_any_genv
      (conj jp_generated_spawn_particle_accepts_clear_dust_in_any_genv
        checked_segmented_pointer_boundary_us_jp))).
Qed.
