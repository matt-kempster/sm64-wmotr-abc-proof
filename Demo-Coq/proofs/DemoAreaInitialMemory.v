From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Ctypes Errors Events
  Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_area jp_area.
From Demo.Proofs Require Import DemoAreaInitialization.
Import ListNotations.
Local Open Scope Z_scope.
Module AM := us_area.

Definition initial_area_program (us : bool) : Clight.program :=
 if us then AM.prog else jp_area.prog.

Lemma area_mkprogram_definitions : forall types defs public main
    (WF : wf_composites types),
 AST.prog_defs (Ctypes.program_of_program (mkprogram types defs public main WF)) = defs.
Proof.
 intros. change (Ctypes.prog_defs (mkprogram types defs public main WF) = defs).
 unfold mkprogram. destruct (build_composite_env' types WF). reflexivity.
Qed.

Lemma generated_area_definitions : forall us,
 AST.prog_defs (initial_area_program us) =
 if us then AM.global_definitions else jp_area.global_definitions.
Proof.
 intros [].
 - change (AST.prog_defs (Ctypes.program_of_program AM.prog) = AM.global_definitions).
   unfold AM.prog. apply area_mkprogram_definitions.
 - change (AST.prog_defs (Ctypes.program_of_program jp_area.prog) = jp_area.global_definitions).
   unfold jp_area.prog. apply area_mkprogram_definitions.
Qed.

Definition area_global_names (us : bool) : list ident :=
 map fst (if us then AM.global_definitions else jp_area.global_definitions).

Definition area_names_distinctb (us : bool) : bool :=
 if @list_norepet_dec ident peq (area_global_names us) then true else false.

Lemma checked_area_global_names_distinct : forall us,
 area_names_distinctb us = true.
Proof.
 intros []; cbn [area_names_distinctb area_global_names
   AM.global_definitions jp_area.global_definitions map fst]; vm_compute; reflexivity.
Qed.

Lemma generated_area_global_names_norepet : forall us,
 list_norepet (prog_defs_names (initial_area_program us)).
Proof.
 intros us. unfold prog_defs_names. rewrite generated_area_definitions.
 change (list_norepet (area_global_names us)).
 pose proof (checked_area_global_names_distinct us) as Hchecked.
 unfold area_names_distinctb in Hchecked.
 destruct (@list_norepet_dec ident peq (area_global_names us)); [assumption | discriminate].
Qed.

Ltac area_source_member index :=
 let us := fresh "us" in intro us;
 eapply nth_error_In with (n := index);
 rewrite generated_area_definitions; destruct us; reflexivity.

Lemma generated_area_data_definition : forall us,
 In (AM._gAreaData, Gvar AM.v_gAreaData) (AST.prog_defs (initial_area_program us)).
Proof. area_source_member 144%nat. Qed.

Lemma generated_current_area_definition : forall us,
 In (AM._gCurrentArea, Gvar AM.v_gCurrentArea) (AST.prog_defs (initial_area_program us)).
Proof. area_source_member 155%nat. Qed.

Lemma generated_warp_transition_definition : forall us,
 In (AM._gWarpTransition, Gvar AM.v_gWarpTransition) (AST.prog_defs (initial_area_program us)).
Proof. area_source_member 145%nat. Qed.

Lemma generated_spawn_pointer_definition : forall us,
 In (AM._gMarioSpawnInfo, Gvar AM.v_gMarioSpawnInfo) (AST.prog_defs (initial_area_program us)).
Proof. area_source_member 152%nat. Qed.

Lemma generated_spawn_object_definition : forall us,
 In (AM._gPlayerSpawnInfos, Gvar AM.v_gPlayerSpawnInfos) (AST.prog_defs (initial_area_program us)).
Proof. area_source_member 142%nat. Qed.

Lemma area_global_variable_resource : forall us id variable,
 In (id, Gvar variable) (AST.prog_defs (initial_area_program us)) ->
 exists b,
  Genv.find_symbol (Clight.globalenv (initial_area_program us)) id = Some b /\
  Genv.find_var_info (Clight.globalenv (initial_area_program us)) b = Some variable.
Proof.
 intros us id variable Hin.
 pose proof (prog_defmap_norepet (initial_area_program us) id (Gvar variable)
   (generated_area_global_names_norepet us) Hin) as Hmap.
 apply Genv.find_def_symbol in Hmap.
 destruct Hmap as (b & Hsymbol & Hdefinition).
 exists b; split; [exact Hsymbol |].
 apply Genv.find_var_info_iff; exact Hdefinition.
Qed.

Lemma area_distinct_symbol_blocks : forall (ge : Genv.t Clight.fundef type)
    id1 id2 b1 b2,
 Genv.find_symbol ge id1 = Some b1 -> Genv.find_symbol ge id2 = Some b2 ->
 id1 <> id2 -> b1 <> b2.
Proof.
 intros ge id1 id2 b1 b2 Hfirst Hsecond Hdistinct Hequal.
 subst b2. apply Hdistinct. eapply Genv.genv_vars_inj; eassumption.
Qed.

Lemma area_initial_range_access : forall m b upper chunk offset,
 Mem.range_perm m b 0 upper Cur Writable ->
 0 <= offset -> offset + size_chunk chunk <= upper ->
 (align_chunk chunk | offset) -> Mem.valid_access m chunk b offset Writable.
Proof.
 unfold Mem.valid_access, Mem.range_perm. intros m b upper chunk offset Hrange Hlo Hhi Halign.
 split; [intros byte Hbyte; apply Hrange; lia | exact Halign].
Qed.

Record actual_area_initial_resources (us : bool) (m : mem) : Type := {
 initial_area_array : block;
 initial_current_area : block;
 initial_transition : block;
 initial_spawn_pointer : block;
 initial_spawn_object : block;
 initial_area_array_symbol : Genv.find_symbol (Clight.globalenv (initial_area_program us))
   AM._gAreaData = Some initial_area_array;
 initial_current_area_symbol : Genv.find_symbol (Clight.globalenv (initial_area_program us))
   AM._gCurrentArea = Some initial_current_area;
 initial_transition_symbol : Genv.find_symbol (Clight.globalenv (initial_area_program us))
   AM._gWarpTransition = Some initial_transition;
 initial_spawn_pointer_symbol : Genv.find_symbol (Clight.globalenv (initial_area_program us))
   AM._gMarioSpawnInfo = Some initial_spawn_pointer;
 initial_spawn_object_symbol : Genv.find_symbol (Clight.globalenv (initial_area_program us))
   AM._gPlayerSpawnInfos = Some initial_spawn_object;
 initial_current_transition_separate : initial_current_area <> initial_transition;
 initial_current_spawn_pointer_separate : initial_current_area <> initial_spawn_pointer;
 initial_transition_spawn_pointer_separate : initial_transition <> initial_spawn_pointer;
 initial_array_current_separate : initial_area_array <> initial_current_area;
 initial_array_transition_separate : initial_area_array <> initial_transition;
 initial_array_spawn_separate : initial_area_array <> initial_spawn_object;
 initial_current_spawn_separate : initial_current_area <> initial_spawn_object;
 initial_transition_spawn_separate : initial_transition <> initial_spawn_object;
 initial_spawn_read : Mem.load Mptr m initial_spawn_pointer 0 =
   Some (Vptr initial_spawn_object Ptrofs.zero);
 initial_current_writable : Mem.valid_access m Mptr initial_current_area 0 Writable;
 initial_transition_active_writable : Mem.valid_access m Mint8unsigned initial_transition 0 Writable;
 initial_transition_pause_writable : Mem.valid_access m Mint8unsigned initial_transition 3 Writable;
 initial_spawn_writable : Mem.valid_access m Mint8signed initial_spawn_object 12 Writable;
 initial_array_writable : Mem.range_perm m initial_area_array 0 480 Cur Writable
}.

Theorem generated_area_initial_resources : forall us m,
 Genv.init_mem (initial_area_program us) = Some m ->
 exists resources : actual_area_initial_resources us m, True.
Proof.
 intros us m Hinit.
 destruct (area_global_variable_resource us _ _ (generated_area_data_definition us))
   as (areas & Hareas & Hareas_var).
 destruct (area_global_variable_resource us _ _ (generated_current_area_definition us))
   as (current & Hcurrent & Hcurrent_var).
 destruct (area_global_variable_resource us _ _ (generated_warp_transition_definition us))
   as (transition & Htransition & Htransition_var).
 destruct (area_global_variable_resource us _ _ (generated_spawn_pointer_definition us))
   as (spawn_global & Hspawn_global & Hspawn_global_var).
 destruct (area_global_variable_resource us _ _ (generated_spawn_object_definition us))
   as (spawn & Hspawn & Hspawn_var).
 destruct (Genv.init_mem_characterization _ _ Hareas_var Hinit)
   as (Harea_range & Harea_bounds & Harea_data & Harea_bytes).
 destruct (Genv.init_mem_characterization _ _ Hcurrent_var Hinit)
   as (Hcurrent_range & Hcurrent_bounds & Hcurrent_data & Hcurrent_bytes).
 destruct (Genv.init_mem_characterization _ _ Htransition_var Hinit)
   as (Htransition_range & Htransition_bounds & Htransition_data & Htransition_bytes).
 destruct (Genv.init_mem_characterization _ _ Hspawn_var Hinit)
   as (Hspawn_range & Hspawn_bounds & Hspawn_data & Hspawn_bytes).
 destruct (Genv.init_mem_characterization _ _ Hspawn_global_var Hinit)
   as (Hspawn_pointer_range & Hspawn_pointer_bounds & Hspawn_pointer_data & Hspawn_pointer_bytes).
 cbn [AM.v_gAreaData AM.v_gCurrentArea AM.v_gWarpTransition AM.v_gPlayerSpawnInfos
   gvar_init init_data_list_size init_data_size Genv.perm_globvar gvar_volatile gvar_readonly]
   in Harea_range, Hcurrent_range, Htransition_range, Hspawn_range.
 specialize (Hspawn_pointer_data eq_refl).
 cbn [AM.v_gMarioSpawnInfo gvar_init Genv.load_store_init_data] in Hspawn_pointer_data.
 destruct Hspawn_pointer_data as [(spawn' & Hspawn' & Hspawn_read) _].
 change (Genv.find_symbol (Clight.globalenv (initial_area_program us))
   AM._gPlayerSpawnInfos = Some spawn') in Hspawn'.
 rewrite Hspawn in Hspawn'. inversion Hspawn'; subst spawn'.
 assert (Hptr : Mptr = Mint32) by (vm_compute; reflexivity).
 refine (ex_intro _ {| initial_area_array := areas; initial_current_area := current;
   initial_transition := transition; initial_spawn_pointer := spawn_global;
   initial_spawn_object := spawn; initial_area_array_symbol := Hareas;
   initial_current_area_symbol := Hcurrent; initial_transition_symbol := Htransition;
   initial_spawn_pointer_symbol := Hspawn_global; initial_spawn_object_symbol := Hspawn;
   initial_current_transition_separate := _; initial_current_spawn_pointer_separate := _;
   initial_transition_spawn_pointer_separate := _; initial_array_current_separate := _;
   initial_array_transition_separate := _; initial_array_spawn_separate := _;
   initial_current_spawn_separate := _; initial_transition_spawn_separate := _;
   initial_spawn_read := Hspawn_read; initial_current_writable := _;
   initial_transition_active_writable := _; initial_transition_pause_writable := _;
   initial_spawn_writable := _; initial_array_writable := Harea_range |} I).
 all: first
 [eapply area_distinct_symbol_blocks; [eassumption | eassumption | vm_compute; discriminate]
 |rewrite Hptr; eapply area_initial_range_access;
    [exact Hcurrent_range | lia | cbn; lia | cbn; exists 0; reflexivity]
 |eapply area_initial_range_access;
    [eassumption | lia | cbn; lia | cbn; exists 0; reflexivity]
 |eapply area_initial_range_access;
    [eassumption | lia | cbn; lia | cbn; exists 3; reflexivity]
 |eapply area_initial_range_access;
    [eassumption | lia | cbn; lia | cbn; exists 12; reflexivity]].
Qed.

(** Check only the actual initializer metadata, never compute init_mem or
    reduce generated function bodies to construct the initial memory. *)
Definition area_initialization_descriptors
    (defs : list (ident * globdef Clight.fundef type)) : list (ident * list init_data) :=
 fold_right (fun entry rest =>
   match snd entry with
   | Gfun _ => rest
   | Gvar variable => (fst entry, gvar_init variable) :: rest
   end) [] defs.

Fixpoint area_initialization_alignedb (offset : Z) (data : list init_data) : bool :=
 match data with
 | [] => true
 | datum :: rest =>
   Z.eqb (offset mod Genv.init_data_alignment datum) 0 &&
   area_initialization_alignedb (offset + init_data_size datum) rest
 end.

Definition area_initialization_relocationsb (names : list ident) (data : list init_data) : bool :=
 forallb (fun datum => match datum with
 | Init_addrof target _ => existsb (Pos.eqb target) names
 | _ => true
 end) data.

Definition area_initialization_check (us : bool) : bool :=
 forallb (fun descriptor =>
   area_initialization_alignedb 0 (snd descriptor) &&
   area_initialization_relocationsb (area_global_names us) (snd descriptor))
 (area_initialization_descriptors
   (if us then AM.global_definitions else jp_area.global_definitions)).

Lemma checked_area_initialization_metadata : forall us,
 area_initialization_check us = true.
Proof.
 intros []; cbn [area_initialization_check area_initialization_descriptors
   area_global_names AM.global_definitions jp_area.global_definitions fold_right fst snd];
   vm_compute; reflexivity.
Qed.

Lemma area_descriptor_member : forall defs id variable,
 In (id, Gvar variable) defs ->
 In (id, gvar_init variable) (area_initialization_descriptors defs).
Proof.
 induction defs as [|[head_name head_definition] rest IH]; intros id variable Hin.
 - inversion Hin.
 - destruct Hin as [Hequal | Hin].
   + inversion Hequal; subst. cbn [area_initialization_descriptors]. left; reflexivity.
   + destruct head_definition; cbn [area_initialization_descriptors];
       first [apply IH; exact Hin | right; apply IH; exact Hin].
Qed.

Lemma area_initializer_alignment_positive : forall datum,
 0 < Genv.init_data_alignment datum.
Proof.
 intros []; cbn [Genv.init_data_alignment]; try lia.
 destruct Archi.ptr64; lia.
Qed.

Lemma area_initialization_alignment_sound : forall data offset,
 area_initialization_alignedb offset data = true ->
 Genv.init_data_list_aligned offset data.
Proof.
 induction data as [|datum rest IH]; intros offset Hchecked.
 - exact I.
 - cbn [area_initialization_alignedb] in Hchecked.
   apply andb_true_iff in Hchecked as [Hthis Hrest].
   cbn [Genv.init_data_list_aligned]. split.
   + apply Z.eqb_eq in Hthis.
     apply (proj1 (Z.mod_divide offset (Genv.init_data_alignment datum)
       ltac:(pose proof (area_initializer_alignment_positive datum); lia))).
     exact Hthis.
   + apply IH; exact Hrest.
Qed.

Lemma area_initialization_relocations_sound : forall names data,
 area_initialization_relocationsb names data = true ->
 forall target offset, In (Init_addrof target offset) data -> In target names.
Proof.
 intros names data Hchecked target offset Hin.
 unfold area_initialization_relocationsb in Hchecked.
 rewrite forallb_forall in Hchecked.
 specialize (Hchecked (Init_addrof target offset) Hin).
 cbn in Hchecked. apply existsb_exists in Hchecked.
 destruct Hchecked as (name & Hinname & Hequal).
 apply Pos.eqb_eq in Hequal. subst name. exact Hinname.
Qed.

Theorem generated_area_initial_memory_exists : forall us,
 exists memory, Genv.init_mem (initial_area_program us) = Some memory.
Proof.
 intro us. apply Genv.init_mem_exists.
 intros id variable Hin.
 pose proof (area_descriptor_member _ _ _ Hin) as Hdescriptor.
 rewrite generated_area_definitions in Hdescriptor.
 pose proof (checked_area_initialization_metadata us) as Hchecked.
 unfold area_initialization_check in Hchecked.
 rewrite forallb_forall in Hchecked.
 specialize (Hchecked (id, gvar_init variable) Hdescriptor).
 cbn in Hchecked. apply andb_true_iff in Hchecked as [Haligned Hrelocations].
 split.
 - apply area_initialization_alignment_sound; exact Haligned.
 - intros target offset Htarget.
   pose proof (area_initialization_relocations_sound _ _ Hrelocations _ _ Htarget) as Hname.
   change (In target (map fst
     (if us then AM.global_definitions else jp_area.global_definitions))) in Hname.
   rewrite <- generated_area_definitions in Hname.
   apply in_map_iff in Hname.
   destruct Hname as ([name definition] & Hequal & Hentry).
   cbn in Hequal. subst name. eapply Genv.find_symbol_exists; exact Hentry.
Qed.

Lemma generated_clear_area_function_definition : forall us : bool,
 In (AM._clear_areas, Gfun (Internal
   (if us then AM.f_clear_areas else jp_area.f_clear_areas)))
   (AST.prog_defs (initial_area_program us)).
Proof. area_source_member 177%nat. Qed.

Lemma generated_clear_area_function_resource : forall us : bool,
 exists function_block,
 Genv.find_symbol (Clight.globalenv (initial_area_program us)) AM._clear_areas =
   Some function_block /\
 Genv.find_funct_ptr (Clight.globalenv (initial_area_program us)) function_block =
   Some (Internal (if us then AM.f_clear_areas else jp_area.f_clear_areas)).
Proof.
 intro us.
 pose proof (prog_defmap_norepet (initial_area_program us) AM._clear_areas
   (Gfun (Internal (if us then AM.f_clear_areas else jp_area.f_clear_areas)))
   (generated_area_global_names_norepet us) (generated_clear_area_function_definition us))
   as Hmap.
 apply Genv.find_def_symbol in Hmap.
 destruct Hmap as (function_block & Hsymbol & Hdefinition).
 exists function_block; split; [exact Hsymbol |].
 apply Genv.find_funct_ptr_iff; exact Hdefinition.
Qed.

Definition demo_area_initial_memory_execution_claim : Prop :=
 forall us : bool, exists before after areas current transition spawn_global spawn function_block,
 Genv.init_mem (initial_area_program us) = Some before /\
 Genv.find_symbol (Clight.globalenv (initial_area_program us)) AM._gAreaData = Some areas /\
 Genv.find_symbol (Clight.globalenv (initial_area_program us)) AM._gCurrentArea = Some current /\
 Genv.find_symbol (Clight.globalenv (initial_area_program us)) AM._gWarpTransition = Some transition /\
 Genv.find_symbol (Clight.globalenv (initial_area_program us)) AM._gMarioSpawnInfo = Some spawn_global /\
 Genv.find_symbol (Clight.globalenv (initial_area_program us)) AM._gPlayerSpawnInfos = Some spawn /\
 Genv.find_symbol (Clight.globalenv (initial_area_program us)) AM._clear_areas = Some function_block /\
 Genv.find_funct_ptr (Clight.globalenv (initial_area_program us)) function_block =
   Some (Internal (if us then AM.f_clear_areas else jp_area.f_clear_areas)) /\
 eval_funcall function_entry2 (Clight.globalenv (initial_area_program us)) before
   (Internal (if us then AM.f_clear_areas else jp_area.f_clear_areas)) [] E0 after Vundef /\
 Mem.load Mptr after current 0 = Some Vzero /\
 (forall i, 0 <= i < 8 ->
   Mem.load Mptr after areas (60*i+24) = Some Vzero /\
   Mem.load Mptr after areas (60*i+28) = Some Vzero) /\
 (forall chunk b ofs, b <> areas -> b <> current -> b <> transition -> b <> spawn ->
   Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_area_initial_memory_executes_clear_areas_us_jp :
 demo_area_initial_memory_execution_claim.
Proof.
 intro us.
 destruct (generated_area_initial_memory_exists us) as (before & Hinit).
 destruct (generated_area_initial_resources us before Hinit) as (resources & Hresources).
 destruct resources as [areas current transition spawn_global spawn
   Hareas Hcurrent Htransition Hspawn_global Hspawn Hct Hcg Htg Hac Hat Has Hcs Hts
   Hspawn_read Hwc Hwt0 Hwt3 Hws Hrange].
 destruct (generated_clear_area_function_resource us) as (function_block & Hfunction & Hbody).
 destruct (generated_clear_areas_executes_with_checked_layout us
   (Clight.globalenv (initial_area_program us)) before areas current transition spawn_global spawn
   eq_refl Hareas Hcurrent Htransition Hspawn_global Hct Hcg Htg Hac Hat Has Hcs Hts
   Hspawn_read Hwc Hwt0 Hwt3 Hws Hrange)
   as (after & Hexecute & Hcurrent_null & Htables & Hframe).
 exists before, after, areas, current, transition, spawn_global, spawn, function_block.
 repeat first [assumption | split].
Qed.
