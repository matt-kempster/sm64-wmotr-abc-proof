(** The accepted JP level-select entry prefix for the timer-131 Ink route.

    Level select is the agreed start boundary for this route.  The certificate
    therefore starts at the last Area-1 [clear_objects] call observed by the
    authenticated retail trace; it does not add an unrelated task-start or
    castle-entry obligation.  [load_mario_area] follows later, and the retail
    receipt contains two distinct [spawn_objects_from_info] entries: the first
    is nested under [load_area] for Area-1 objects, while the second creates
    Mario.  [init_mario] then connects the new Object to MarioState, and the
    first object/behavior update executes [bhvMario]'s safe [OR_INT] before the
    recorded endpoint.

    [InkTimer131CellClassifiedReach] is a small-step execution certificate:
    every constructor contains one actual [Clight.step2] and classifies that
    step's effect on the two watched cells.  The endpoint record is deliberately
    more concrete than the old ordinary-entry premise: it names observed slot
    67, [bhvMario], both Mario pointers, the player-list one-node ring,
    [oFlags = 0x100], and the zero graphical offset as exact CompCert loads.
    Those loads directly establish the live invariant; no claim that slot 67
    was already safe before Mario's allocation is needed.

    The machine constants below transcribe the SHA-256-pinned read-only receipt
    exactly and mechanically check its arithmetic.  Project policy now accepts
    that authenticated 19-write receipt as the Timer-131 entry theorem.  This
    does not silently turn the IDO-produced retail binary into a CompCert
    execution: the [Clight.step2] certificate below remains an optional stronger
    bridge.  The required next obligation begins at the accepted machine
    endpoint and classifies every later step through timer 131.  Invalid
    pointers, OOB execution, ACE, and asynchronous DMA remain outside CompCert
    Clight. *)

From Coq Require Import List String ZArith.
From compcert Require Import AST Clight Ctypes Events Floats Globalenvs
  Integers Memory Smallstep Values export.Ctypesdefs.
From LessThanOneAPress.Generated Require Import
  jp_area jp_behavior_data jp_debug jp_level_script jp_level_update jp_mario
  jp_object_collision jp_object_helpers jp_object_list_processor
  jp_spawn_object jp_surface_load.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ActionDepthAliasCensus CleanedClightPrograms EntryMemory
  InkTimer131ClightTraceBridge
  InkTimer131EntryExecutionClosure InkTimer131IndirectAliasClosure
  InkTimer131LiveIdentityClosure
  InkTimer131MarioTailClosure
  OrdinaryArea1EntryMemory SelectedClightTarget.

Import ListNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.

Module IT131P_Script := jp_level_script.
Module IT131P_Update := jp_level_update.
Module IT131P_Area := jp_area.
Module IT131P_Data := jp_behavior_data.
Module IT131P_Debug := jp_debug.
Module IT131P_Objects := jp_object_list_processor.
Module IT131P_Spawn := jp_spawn_object.
Module IT131P_Mario := jp_mario.
Module IT131P_Collision := jp_object_collision.
Module IT131P_Helpers := jp_object_helpers.
Module IT131P_Surface := jp_surface_load.

(** * Exact generated phase order *)

Definition ink_timer131_real_prefix_source_claim : Prop :=
  straightline_callees_s (fn_body IT131P_Script.f_level_cmd_init_level) =
    [IT131P_Script._init_graph_node_start;
     IT131P_Script._clear_objects;
     IT131P_Script._clear_areas;
     IT131P_Script._main_pool_push_state] /\
  ident_subsequenceb
    [IT131P_Update._load_mario_area; IT131P_Update._init_mario]
    (direct_callees_s (fn_body IT131P_Update.f_init_level)) = true /\
  ident_subsequenceb
    [IT131P_Area._load_area; IT131P_Area._spawn_objects_from_info]
    (direct_callees_s (fn_body IT131P_Area.f_load_mario_area)) = true /\
  calls_ident_s IT131P_Area._spawn_objects_from_info
    (fn_body IT131P_Area.f_load_area) = true /\
  calls_ident_s IT131P_Objects._create_object
    (fn_body IT131P_Objects.f_spawn_objects_from_info) = true /\
  calls_ident_s IT131P_Spawn._allocate_object
    (fn_body IT131P_Spawn.f_create_object) = true /\
  calls_ident_s IT131P_Objects._clear_object_lists
    (fn_body IT131P_Objects.f_clear_objects) = true.

Theorem ink_timer131_real_prefix_source_checked :
  ink_timer131_real_prefix_source_claim.
Proof.
  unfold ink_timer131_real_prefix_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The accepted pre-update entry family itself has three roots.  The separate
    broader closure below includes the now-observed first object update. *)
Definition jp_timer131_entry_direct_roots : list ident :=
  [IT131P_Objects._clear_objects;
   IT131P_Area._load_mario_area;
   IT131P_Mario._init_mario].

Definition jp_timer131_entry_direct_closure : list ident :=
  ink_direct_call_closure 20 ink_jp_definitions
    jp_timer131_entry_direct_roots [].

Definition jp_timer131_entry_direct_writer_claim : Prop :=
  List.length jp_timer131_entry_direct_closure = 85%nat /\
  ink_call_closure_closedb ink_jp_definitions
    jp_timer131_entry_direct_closure = true /\
  ink_writer_intersection jp_timer131_entry_direct_closure
    ink_jp_flag_writers = [] /\
  ink_writer_intersection jp_timer131_entry_direct_closure
    ink_jp_offset_writers = [].

Theorem jp_timer131_entry_direct_writer_checked :
  jp_timer131_entry_direct_writer_claim.
Proof.
  unfold jp_timer131_entry_direct_writer_claim,
    jp_timer131_entry_direct_closure, jp_timer131_entry_direct_roots.
  vm_compute. repeat split; reflexivity.
Qed.

(** This second closure adds the first [update_objects] root which the exact
    flag-write receipt proves occurs before the observed endpoint.  Indirect behavior-table
    dispatch and unresolved externals are not inferred from either result;
    they retain their separate checked interfaces. *)
Definition jp_timer131_level_select_direct_roots : list ident :=
  [IT131P_Objects._clear_objects;
   IT131P_Area._load_mario_area;
   IT131P_Mario._init_mario;
   IT131P_Objects._update_objects].

Definition jp_timer131_level_select_direct_closure : list ident :=
  ink_direct_call_closure 20 ink_jp_definitions
    jp_timer131_level_select_direct_roots [].

Definition jp_timer131_level_select_direct_writer_claim : Prop :=
  List.length jp_timer131_level_select_direct_closure = 150%nat /\
  ink_call_closure_closedb ink_jp_definitions
    jp_timer131_level_select_direct_closure = true /\
  ink_writer_intersection jp_timer131_level_select_direct_closure
    ink_jp_flag_writers = [] /\
  ink_writer_intersection jp_timer131_level_select_direct_closure
    ink_jp_offset_writers = [].

Theorem jp_timer131_level_select_direct_writer_checked :
  jp_timer131_level_select_direct_writer_claim.
Proof.
  unfold jp_timer131_level_select_direct_writer_claim,
    jp_timer131_level_select_direct_closure,
    jp_timer131_level_select_direct_roots.
  vm_compute. repeat split; reflexivity.
Qed.

(** The unresolved direct callees of the narrower accepted entry family. *)
Definition jp_timer131_entry_unresolved_direct_callees : list ident :=
  filter
    (fun id => negb (identifier_occurs id
      (internal_function_identifiers ink_jp_definitions)))
    jp_timer131_entry_direct_closure.

Definition jp_timer131_expected_entry_unresolved_direct_callees : list ident :=
  [IT131P_Area._stop_sounds_in_continuous_banks;
   IT131P_Mario._sqrtf;
   IT131P_Spawn._stop_sounds_from_source].

Definition jp_timer131_entry_external_inventory_claim : Prop :=
  jp_timer131_entry_unresolved_direct_callees =
    jp_timer131_expected_entry_unresolved_direct_callees /\
  List.length jp_timer131_expected_entry_unresolved_direct_callees = 3%nat.

Theorem jp_timer131_entry_external_inventory_checked :
  jp_timer131_entry_external_inventory_claim.
Proof.
  unfold jp_timer131_entry_external_inventory_claim,
    jp_timer131_entry_unresolved_direct_callees,
    jp_timer131_expected_entry_unresolved_direct_callees,
    jp_timer131_entry_direct_closure, jp_timer131_entry_direct_roots.
  vm_compute. split; reflexivity.
Qed.

(** The only direct callees in that finite closure which have no internal body
    in the complete generated JP corpus.  They are all emitted as
    [EF_external] declarations.  CompCert does not infer a protected-memory
    frame from their prototypes, so reachable instances of these five names
    remain the exact external-call obligations. *)
Definition jp_timer131_level_select_unresolved_direct_callees : list ident :=
  filter
    (fun id => negb (identifier_occurs id
      (internal_function_identifiers ink_jp_definitions)))
    jp_timer131_level_select_direct_closure.

Definition jp_timer131_expected_unresolved_direct_callees : list ident :=
  [IT131P_Area._stop_sounds_in_continuous_banks;
   IT131P_Spawn._stop_sounds_from_source;
   IT131P_Debug._print_text;
   IT131P_Debug._print_text_fmt_int;
   IT131P_Mario._sqrtf].

Definition jp_timer131_level_select_external_inventory_claim : Prop :=
  jp_timer131_level_select_unresolved_direct_callees =
    jp_timer131_expected_unresolved_direct_callees /\
  List.length jp_timer131_expected_unresolved_direct_callees = 5%nat.

Theorem jp_timer131_level_select_external_inventory_checked :
  jp_timer131_level_select_external_inventory_claim.
Proof.
  unfold jp_timer131_level_select_external_inventory_claim,
    jp_timer131_level_select_unresolved_direct_callees,
    jp_timer131_expected_unresolved_direct_callees,
    jp_timer131_level_select_direct_closure,
    jp_timer131_level_select_direct_roots.
  vm_compute. split; reflexivity.
Qed.

Fixpoint jp_timer131_unresolved_direct_callsites
    (definitions : list (ident * globdef (fundef function) type))
    (closure unresolved : list ident) : list (ident * ident) :=
  match definitions with
  | [] => []
  | (caller, Gfun (Internal body)) :: rest =>
      (if ink_ident_in caller closure
       then map (fun callee => (caller, callee))
         (filter (fun callee => ink_ident_in callee unresolved)
           (direct_callees_s (fn_body body)))
       else []) ++
      jp_timer131_unresolved_direct_callsites rest closure unresolved
  | _ :: rest =>
      jp_timer131_unresolved_direct_callsites rest closure unresolved
  end.

Definition jp_timer131_level_select_unresolved_direct_callsites :
    list (ident * ident) :=
  jp_timer131_unresolved_direct_callsites ink_jp_definitions
    jp_timer131_level_select_direct_closure
    jp_timer131_level_select_unresolved_direct_callees.

Definition jp_timer131_expected_unresolved_direct_callsites :
    list (ident * ident) :=
  [(IT131P_Collision._detect_object_hitbox_overlap, IT131P_Mario._sqrtf);
   (IT131P_Collision._detect_object_hurtbox_overlap, IT131P_Mario._sqrtf);
   (IT131P_Spawn._unload_object, IT131P_Spawn._stop_sounds_from_source);
   (IT131P_Helpers._dist_between_objects, IT131P_Mario._sqrtf);
   (IT131P_Debug._print_text_array_info, IT131P_Debug._print_text);
   (IT131P_Debug._print_text_array_info, IT131P_Debug._print_text_fmt_int);
   (IT131P_Area._load_mario_area,
      IT131P_Area._stop_sounds_in_continuous_banks);
   (IT131P_Surface._read_surface_data, IT131P_Mario._sqrtf)].

Definition jp_timer131_entry_unresolved_direct_callsites :
    list (ident * ident) :=
  jp_timer131_unresolved_direct_callsites ink_jp_definitions
    jp_timer131_entry_direct_closure
    jp_timer131_entry_unresolved_direct_callees.

Definition jp_timer131_expected_entry_unresolved_direct_callsites :
    list (ident * ident) :=
  [(IT131P_Spawn._unload_object, IT131P_Spawn._stop_sounds_from_source);
   (IT131P_Area._load_mario_area,
      IT131P_Area._stop_sounds_in_continuous_banks);
   (IT131P_Surface._read_surface_data, IT131P_Mario._sqrtf)].

Definition jp_timer131_entry_external_callsite_claim : Prop :=
  jp_timer131_entry_unresolved_direct_callsites =
    jp_timer131_expected_entry_unresolved_direct_callsites /\
  List.length jp_timer131_expected_entry_unresolved_direct_callsites = 3%nat.

Theorem jp_timer131_entry_external_callsites_checked :
  jp_timer131_entry_external_callsite_claim.
Proof.
  unfold jp_timer131_entry_external_callsite_claim,
    jp_timer131_entry_unresolved_direct_callsites,
    jp_timer131_expected_entry_unresolved_direct_callsites,
    jp_timer131_entry_unresolved_direct_callees,
    jp_timer131_entry_direct_closure, jp_timer131_entry_direct_roots.
  vm_compute. split; reflexivity.
Qed.

Definition jp_timer131_level_select_external_callsite_claim : Prop :=
  jp_timer131_level_select_unresolved_direct_callsites =
    jp_timer131_expected_unresolved_direct_callsites /\
  List.length jp_timer131_expected_unresolved_direct_callsites = 8%nat.

Theorem jp_timer131_level_select_external_callsites_checked :
  jp_timer131_level_select_external_callsite_claim.
Proof.
  unfold jp_timer131_level_select_external_callsite_claim,
    jp_timer131_level_select_unresolved_direct_callsites,
    jp_timer131_expected_unresolved_direct_callsites,
    jp_timer131_level_select_unresolved_direct_callees,
    jp_timer131_level_select_direct_closure,
    jp_timer131_level_select_direct_roots.
  vm_compute. split; reflexivity.
Qed.

(** * Authenticated pre-entry callsite reachability

    The static closure above is deliberately conservative: a callee appears
    there whenever its call expression occurs in a reachable function body.
    That does not mean the callsite executes on this particular entry.  The
    hash-gated debugger run therefore arms execute breakpoints at the allocator,
    its exhaustion-only [unload_object] call instruction, [unload_object]
    itself, and the two sound callees.  Counters are reset by each
    [clear_objects], so this record is exactly epoch 8 from the accepted clear
    through the timer-348 endpoint.

    The 73 successful allocator entries and zero hits at its fallback
    instruction prove that pool exhaustion never selects [unload_object].
    Independent zero counts at [unload_object] and
    [stop_sounds_from_source] also exclude any other dynamic route to that
    callee in the observed prefix.  Conversely, the continuous-bank sound
    routine has one hit, so it may not be erased by control-flow analysis.
    This receipt does not instrument [sqrtf], which remains not excluded by
    this result. *)

Record JPInkTimer131MachineCallReachability : Type := {
  jp_machine_call_epoch : Z;
  jp_machine_call_timer : Z;
  jp_machine_allocate_object_hits : Z;
  jp_machine_allocator_fallback_hits : Z;
  jp_machine_unload_object_hits : Z;
  jp_machine_stop_sounds_from_source_hits : Z;
  jp_machine_stop_sounds_from_source_entry_sp : Z;
  jp_machine_stop_sounds_continuous_hits : Z;
  jp_machine_stop_sounds_continuous_entry_sp : Z
}.

(** Exact breakpoint PCs from the receipt's arm line.  The three JAL words and
    the allocator's positive [bnez] word were independently read from the same
    SHA-256-pinned ROM. *)
Definition jp_timer131_call_reachability_breakpoint_pcs : list Z :=
  [2150222432; 2150083084; 2150221872; 2149927100;
   2150404384; 2150404468; 2150404232; 2150762232; 2150762640].

Definition jp_mips_jump_target (pc instruction : Z) : Z :=
  Z.lor (Z.land (pc + 4) 4026531840)
    (Z.shiftl (Z.land instruction 67108863) 2).

Definition jp_mips_positive_branch_target (pc instruction : Z) : Z :=
  pc + 4 + 4 * Z.land instruction 65535.

Definition jp_timer131_callsite_machine_code_claim : Prop :=
  jp_mips_positive_branch_target 2150404420 364904471 = 2150404516 /\
  jp_mips_jump_target 2150404468 202056738 = 2150404232 /\
  jp_mips_jump_target 2150404272 202146238 = 2150762232 /\
  jp_mips_jump_target 2150083092 202146340 = 2150762640.

Theorem jp_timer131_callsite_machine_code_checked :
  jp_timer131_callsite_machine_code_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition jp_timer131_machine_call_reachability :
    JPInkTimer131MachineCallReachability :=
  {| jp_machine_call_epoch := 8;
     jp_machine_call_timer := 348;
     jp_machine_allocate_object_hits := 73;
     jp_machine_allocator_fallback_hits := 0;
     jp_machine_unload_object_hits := 0;
     jp_machine_stop_sounds_from_source_hits := 0;
     jp_machine_stop_sounds_from_source_entry_sp := 0;
     jp_machine_stop_sounds_continuous_hits := 1;
     jp_machine_stop_sounds_continuous_entry_sp := 2149609768 |}.

Definition jp_timer131_prefix_call_reach_trace_sha256 : string :=
  "CFB33E9CBE6AE0493897222BEEB1FBA8880A3E8BEC995DF6716AC7B07D48BDC1".

Definition JPInkTimer131AuthenticatedCallReachabilityReceipt : Prop :=
  jp_machine_call_epoch jp_timer131_machine_call_reachability = 8 /\
  jp_machine_call_timer jp_timer131_machine_call_reachability = 348 /\
  jp_machine_allocate_object_hits jp_timer131_machine_call_reachability = 73 /\
  jp_machine_allocator_fallback_hits jp_timer131_machine_call_reachability = 0 /\
  jp_machine_unload_object_hits jp_timer131_machine_call_reachability = 0 /\
  jp_machine_stop_sounds_from_source_hits
    jp_timer131_machine_call_reachability = 0 /\
  jp_machine_stop_sounds_from_source_entry_sp
    jp_timer131_machine_call_reachability = 0 /\
  jp_machine_stop_sounds_continuous_hits
    jp_timer131_machine_call_reachability = 1 /\
  jp_machine_stop_sounds_continuous_entry_sp
    jp_timer131_machine_call_reachability = 2149609768.

Theorem jp_timer131_authenticated_call_reachability_decodes :
  JPInkTimer131AuthenticatedCallReachabilityReceipt.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition jp_timer131_machine_callsite_reached (hits : Z) : Prop :=
  hits <> 0.

Corollary jp_timer131_allocator_exhaustion_callsite_not_reached :
  ~ jp_timer131_machine_callsite_reached
      (jp_machine_allocator_fallback_hits
        jp_timer131_machine_call_reachability).
Proof. unfold jp_timer131_machine_callsite_reached; vm_compute; tauto. Qed.

Corollary jp_timer131_unload_object_not_reached :
  ~ jp_timer131_machine_callsite_reached
      (jp_machine_unload_object_hits
        jp_timer131_machine_call_reachability).
Proof. unfold jp_timer131_machine_callsite_reached; vm_compute; tauto. Qed.

Corollary jp_timer131_stop_sounds_from_source_callsite_not_reached :
  ~ jp_timer131_machine_callsite_reached
      (jp_machine_stop_sounds_from_source_hits
        jp_timer131_machine_call_reachability).
Proof. unfold jp_timer131_machine_callsite_reached; vm_compute; tauto. Qed.

Corollary jp_timer131_stop_sounds_continuous_callsite_is_reached :
  jp_timer131_machine_callsite_reached
    (jp_machine_stop_sounds_continuous_hits
      jp_timer131_machine_call_reachability).
Proof. unfold jp_timer131_machine_callsite_reached; vm_compute; discriminate. Qed.

(** An effect specification is only an obligation after the corresponding
    callsite is reached.  This generic formulation makes the zero-hit result
    useful without asserting any semantics for the unresolved declaration. *)
Definition JPInkTimer131CallsiteEffectObligation
    (hits : Z) (effect_specification : Prop) : Prop :=
  jp_timer131_machine_callsite_reached hits -> effect_specification.

Theorem jp_timer131_unreached_source_sound_needs_no_effect_specification :
  forall effect_specification,
    JPInkTimer131CallsiteEffectObligation
      (jp_machine_stop_sounds_from_source_hits
        jp_timer131_machine_call_reachability)
      effect_specification.
Proof.
  intros effect_specification Hreached.
  exfalso. apply Hreached. reflexivity.
Qed.

Inductive JPInkTimer131ExternalReachabilityDisposition : Type :=
| JPTimer131ProvedUnreached
| JPTimer131ProvedReached
| JPTimer131NotExcludedByThisReceipt.

Definition jp_timer131_entry_external_reachability_dispositions :
    list (ident * JPInkTimer131ExternalReachabilityDisposition) :=
  [(IT131P_Spawn._stop_sounds_from_source, JPTimer131ProvedUnreached);
   (IT131P_Area._stop_sounds_in_continuous_banks, JPTimer131ProvedReached);
   (IT131P_Mario._sqrtf, JPTimer131NotExcludedByThisReceipt)].

Definition jp_timer131_entry_external_reachability_reduction_claim : Prop :=
  jp_timer131_entry_external_reachability_dispositions =
    [(IT131P_Spawn._stop_sounds_from_source, JPTimer131ProvedUnreached);
     (IT131P_Area._stop_sounds_in_continuous_banks, JPTimer131ProvedReached);
     (IT131P_Mario._sqrtf, JPTimer131NotExcludedByThisReceipt)] /\
  ~ jp_timer131_machine_callsite_reached
      (jp_machine_stop_sounds_from_source_hits
        jp_timer131_machine_call_reachability) /\
  jp_timer131_machine_callsite_reached
      (jp_machine_stop_sounds_continuous_hits
        jp_timer131_machine_call_reachability).

Theorem jp_timer131_entry_external_reachability_reduction_checked :
  jp_timer131_entry_external_reachability_reduction_claim.
Proof.
  split; [reflexivity |].
  split.
  - exact jp_timer131_stop_sounds_from_source_callsite_not_reached.
  - exact jp_timer131_stop_sounds_continuous_callsite_is_reached.
Qed.

(** * Exact transcription of the authenticated retail receipt *)

Inductive JPInkTimer131MachineStage : Type :=
| JPTimer131ClearObjects
| JPTimer131LoadMarioArea
| JPTimer131SpawnAreaObjects
| JPTimer131SpawnMario
| JPTimer131InitMario.

Record JPInkTimer131MachineCheckpoint : Type := {
  jp_machine_checkpoint_stage : JPInkTimer131MachineStage;
  jp_machine_checkpoint_pc : Z;
  jp_machine_checkpoint_return_pc : Z;
  jp_machine_checkpoint_a0 : Z;
  jp_machine_checkpoint_a1 : Z;
  jp_machine_checkpoint_timer : Z;
  jp_machine_checkpoint_area : Z;
  jp_machine_checkpoint_mario_object : Z;
  jp_machine_checkpoint_state_mario_object : Z
}.

Definition jp_timer131_clear_checkpoint : JPInkTimer131MachineCheckpoint :=
  {| jp_machine_checkpoint_stage := JPTimer131ClearObjects;
     jp_machine_checkpoint_pc := 2150222432;
     jp_machine_checkpoint_return_pc := 2151149160;
     jp_machine_checkpoint_a0 := 2151202184;
     jp_machine_checkpoint_a1 := 10;
     jp_machine_checkpoint_timer := 347;
     jp_machine_checkpoint_area := 1;
     jp_machine_checkpoint_mario_object := 0;
     jp_machine_checkpoint_state_mario_object := 0 |}.

Definition jp_timer131_load_checkpoint : JPInkTimer131MachineCheckpoint :=
  {| jp_machine_checkpoint_stage := JPTimer131LoadMarioArea;
     jp_machine_checkpoint_pc := 2150083084;
     jp_machine_checkpoint_return_pc := 2149890472;
     jp_machine_checkpoint_a0 := 0;
     jp_machine_checkpoint_a1 := 8;
     jp_machine_checkpoint_timer := 347;
     jp_machine_checkpoint_area := 1;
     jp_machine_checkpoint_mario_object := 0;
     jp_machine_checkpoint_state_mario_object := 0 |}.

Definition jp_timer131_area_spawn_checkpoint :
    JPInkTimer131MachineCheckpoint :=
  {| jp_machine_checkpoint_stage := JPTimer131SpawnAreaObjects;
     jp_machine_checkpoint_pc := 2150221872;
     jp_machine_checkpoint_return_pc := 2150082916;
     jp_machine_checkpoint_a0 := 0;
     jp_machine_checkpoint_a1 := 2149065272;
     jp_machine_checkpoint_timer := 347;
     jp_machine_checkpoint_area := 1;
     jp_machine_checkpoint_mario_object := 0;
     jp_machine_checkpoint_state_mario_object := 0 |}.

Definition jp_timer131_mario_spawn_checkpoint :
    JPInkTimer131MachineCheckpoint :=
  {| jp_machine_checkpoint_stage := JPTimer131SpawnMario;
     jp_machine_checkpoint_pc := 2150221872;
     jp_machine_checkpoint_return_pc := 2150083184;
     jp_machine_checkpoint_a0 := 0;
     jp_machine_checkpoint_a1 := 2150867264;
     jp_machine_checkpoint_timer := 347;
     jp_machine_checkpoint_area := 1;
     jp_machine_checkpoint_mario_object := 0;
     jp_machine_checkpoint_state_mario_object := 0 |}.

Definition jp_timer131_init_checkpoint : JPInkTimer131MachineCheckpoint :=
  {| jp_machine_checkpoint_stage := JPTimer131InitMario;
     jp_machine_checkpoint_pc := 2149927100;
     jp_machine_checkpoint_return_pc := 2149890480;
     jp_machine_checkpoint_a0 := 2150916178;
     jp_machine_checkpoint_a1 := 2150867270;
     jp_machine_checkpoint_timer := 347;
     jp_machine_checkpoint_area := 1;
     jp_machine_checkpoint_mario_object := 2150916152;
     jp_machine_checkpoint_state_mario_object := 0 |}.

Definition jp_timer131_machine_checkpoints :
    list JPInkTimer131MachineCheckpoint :=
  [jp_timer131_clear_checkpoint;
   jp_timer131_load_checkpoint;
   jp_timer131_area_spawn_checkpoint;
   jp_timer131_mario_spawn_checkpoint;
   jp_timer131_init_checkpoint].

Record JPInkTimer131MachineEndpoint : Type := {
  jp_machine_endpoint_timer : Z;
  jp_machine_endpoint_object_pool : Z;
  jp_machine_endpoint_mario_object : Z;
  jp_machine_endpoint_slot : Z;
  jp_machine_endpoint_state_mario_object : Z;
  jp_machine_endpoint_active_flags : Z;
  jp_machine_endpoint_behavior : Z;
  jp_machine_endpoint_flags : Z;
  jp_machine_endpoint_graph_y_offset_bits : Z;
  jp_machine_endpoint_next : Z;
  jp_machine_endpoint_previous : Z;
  jp_machine_endpoint_sentinel_next : Z;
  jp_machine_endpoint_sentinel_previous : Z
}.

Definition jp_timer131_machine_endpoint : JPInkTimer131MachineEndpoint :=
  {| jp_machine_endpoint_timer := 348;
     jp_machine_endpoint_object_pool := 2150875416;
     jp_machine_endpoint_mario_object := 2150916152;
     jp_machine_endpoint_slot := 67;
     jp_machine_endpoint_state_mario_object := 2150916152;
     jp_machine_endpoint_active_flags := 257;
     jp_machine_endpoint_behavior := 2148446656;
     jp_machine_endpoint_flags := 256;
     jp_machine_endpoint_graph_y_offset_bits := 0;
     jp_machine_endpoint_next := 2150873200;
     jp_machine_endpoint_previous := 2150873200;
     jp_machine_endpoint_sentinel_next := 2150916152;
     jp_machine_endpoint_sentinel_previous := 2150916152 |}.

Definition jp_timer131_retail_rom_sha256 : string :=
  "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317".

Definition jp_timer131_filtered_trace_sha256 : string :=
  "8341AA389D255ABA50BA534A1E95F1A80215E479903C8CC11E8E5450FCE4CE7E".

(** The later write-watch receipt is deliberately separate from the original
    five-checkpoint hash above.  Mupen's debugger uses physical addresses for
    memory watchpoints; the probe converts the ten authenticated virtual
    ranges before arming them.  Every store below is therefore an observed
    retail instruction, not a source-level writer guess. *)
Definition jp_timer131_prefix_write_trace_sha256 : string :=
  "BDDEF78B337F090B21A904760F8871E95F2F8D861DD80756709C0F6ECA5BF295".

Inductive JPInkTimer131MachineWritePhase : Type :=
| JPTimer131WriteClear
| JPTimer131WriteMarioSpawn
| JPTimer131WriteInitMario
| JPTimer131WriteFirstObjectUpdate
| JPTimer131WriteFirstMarioBehavior.

Record JPInkTimer131MachineWrite : Type := {
  jp_machine_write_phase : JPInkTimer131MachineWritePhase;
  jp_machine_write_pc : Z;
  jp_machine_write_instruction : Z;
  jp_machine_write_target : Z;
  jp_machine_write_width : Z;
  jp_machine_write_value : Z
}.

Definition jp_timer131_machine_write
    (phase : JPInkTimer131MachineWritePhase) (pc instruction target width value : Z)
    : JPInkTimer131MachineWrite :=
  {| jp_machine_write_phase := phase;
     jp_machine_write_pc := pc;
     jp_machine_write_instruction := instruction;
     jp_machine_write_target := target;
     jp_machine_write_width := width;
     jp_machine_write_value := value |}.

(** The complete epoch-8 write receipt from the accepted timer-347 clear to
    the timer-348 endpoint.  The watched ranges are both Mario pointers,
    slot-67's two list links, active word, behavior pointer and protected tail,
    plus both list-0 sentinel links.  The two half-word stores at [+0x76] are
    retained because Mupen reports word-aligned watchpoint overlap; their exact
    targets make their disjointness from [+0x74] explicit. *)
Definition jp_timer131_machine_writes : list JPInkTimer131MachineWrite :=
  [jp_timer131_machine_write JPTimer131WriteClear
     2150222460 2887843304 2151022056 4 0;
   jp_timer131_machine_write JPTimer131WriteClear
     2150403864 2905210976 2150916248 4 2150916760;
   jp_timer131_machine_write JPTimer131WriteClear
     2150403992 2904031328 2150873296 4 2150873200;
   jp_timer131_machine_write JPTimer131WriteClear
     2150404048 2913665124 2150873300 4 2150873200;
   jp_timer131_machine_write JPTimer131WriteClear
     2150222616 2753610124 2150916268 2 0;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150403584 2909405284 2150916252 4 2150873200;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150403596 2913730656 2150916248 4 2150873200;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150403612 2936930400 2150873296 4 2150916152;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150403628 2904096868 2150873300 4 2150916152;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150404524 2770862196 2150916268 2 257;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150404556 2778726518 2150916270 2 0;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150404580 2938110088 2150916292 4 0;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150404580 2938110088 2150916372 4 0;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150405304 2907243020 2150916676 4 2148446656;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150222096 2918056460 2150916676 4 2148446656;
   jp_timer131_machine_write JPTimer131WriteMarioSpawn
     2150222164 2888826344 2151022056 4 2150916152;
   jp_timer131_machine_write JPTimer131WriteInitMario
     2149927448 2911568008 2150866568 4 2150916152;
   jp_timer131_machine_write JPTimer131WriteFirstObjectUpdate
     2150402244 2801795190 2150916270 2 0;
   jp_timer131_machine_write JPTimer131WriteFirstMarioBehavior
     2151173588 2903179400 2150916292 4 256].

Record JPInkTimer131WatchedState : Type := {
  jp_watched_global_mario_object : Z;
  jp_watched_state_mario_object : Z;
  jp_watched_slot_next : Z;
  jp_watched_slot_previous : Z;
  jp_watched_slot_active_flags : Z;
  jp_watched_slot_flags : Z;
  jp_watched_slot_graph_y_offset_bits : Z;
  jp_watched_slot_behavior : Z;
  jp_watched_list_next : Z;
  jp_watched_list_previous : Z
}.

Definition jp_timer131_apply_machine_write
    (state : JPInkTimer131WatchedState)
    (write : JPInkTimer131MachineWrite) : JPInkTimer131WatchedState :=
  let target := jp_machine_write_target write in
  let value := jp_machine_write_value write in
  {| jp_watched_global_mario_object :=
       if Z.eqb target 2151022056 then value
       else jp_watched_global_mario_object state;
     jp_watched_state_mario_object :=
       if Z.eqb target 2150866568 then value
       else jp_watched_state_mario_object state;
     jp_watched_slot_next :=
       if Z.eqb target 2150916248 then value else jp_watched_slot_next state;
     jp_watched_slot_previous :=
       if Z.eqb target 2150916252 then value
       else jp_watched_slot_previous state;
     jp_watched_slot_active_flags :=
       if Z.eqb target 2150916268 then value
       else jp_watched_slot_active_flags state;
     jp_watched_slot_flags :=
       if Z.eqb target 2150916292 then value else jp_watched_slot_flags state;
     jp_watched_slot_graph_y_offset_bits :=
       if Z.eqb target 2150916372 then value
       else jp_watched_slot_graph_y_offset_bits state;
     jp_watched_slot_behavior :=
       if Z.eqb target 2150916676 then value
       else jp_watched_slot_behavior state;
     jp_watched_list_next :=
       if Z.eqb target 2150873296 then value else jp_watched_list_next state;
     jp_watched_list_previous :=
       if Z.eqb target 2150873300 then value
       else jp_watched_list_previous state |}.

Definition jp_timer131_replay_machine_writes
    (initial : JPInkTimer131WatchedState) : JPInkTimer131WatchedState :=
  fold_left jp_timer131_apply_machine_write jp_timer131_machine_writes initial.

Definition jp_timer131_expected_watched_endpoint : JPInkTimer131WatchedState :=
  {| jp_watched_global_mario_object := 2150916152;
     jp_watched_state_mario_object := 2150916152;
     jp_watched_slot_next := 2150873200;
     jp_watched_slot_previous := 2150873200;
     jp_watched_slot_active_flags := 257;
     jp_watched_slot_flags := 256;
     jp_watched_slot_graph_y_offset_bits := 0;
     jp_watched_slot_behavior := 2148446656;
     jp_watched_list_next := 2150916152;
     jp_watched_list_previous := 2150916152 |}.

Definition jp_timer131_machine_intervals_overlap
    (left left_width right right_width : Z) : bool :=
  Z.ltb left (right + right_width) && Z.ltb right (left + left_width).

(** A store is harmless for Timer-131 if it is disjoint from both protected
    words, writes a full flag word whose low bit is clear, or writes exact
    binary32 zero to the graphical-offset word. *)
Definition jp_timer131_machine_write_safe
    (write : JPInkTimer131MachineWrite) : bool :=
  let target := jp_machine_write_target write in
  let width := jp_machine_write_width write in
  let value := jp_machine_write_value write in
  if jp_timer131_machine_intervals_overlap target width 2150916292 4
  then (Z.eqb target 2150916292 && Z.eqb width 4)
         && negb (Z.testbit value 0)
  else if jp_timer131_machine_intervals_overlap target width 2150916372 4
       then (Z.eqb target 2150916372 && Z.eqb width 4)
              && Z.eqb value 0
       else true.

Definition JPInkTimer131AuthenticatedMachineWriteReceipt : Prop :=
  List.length jp_timer131_machine_writes = 19%nat /\
  forallb jp_timer131_machine_write_safe jp_timer131_machine_writes = true /\
  forall initial,
    jp_timer131_replay_machine_writes initial =
      jp_timer131_expected_watched_endpoint.

Theorem jp_timer131_authenticated_machine_writes_decode :
  JPInkTimer131AuthenticatedMachineWriteReceipt.
Proof.
  split; [reflexivity |].
  split; [vm_compute; reflexivity |].
  intros [global_mario state_mario slot_next slot_previous active_flags
    flags graph_offset behavior list_next list_previous].
  vm_compute. reflexivity.
Qed.

Corollary every_authenticated_machine_write_is_timer131_safe :
  forall write,
    In write jp_timer131_machine_writes ->
    jp_timer131_machine_write_safe write = true.
Proof.
  intros write Hin.
  pose proof (proj1 (proj2
    jp_timer131_authenticated_machine_writes_decode)) as Hall.
  rewrite forallb_forall in Hall.
  exact (Hall write Hin).
Qed.

Theorem jp_timer131_replayed_endpoint_matches_authenticated_snapshot :
  jp_watched_global_mario_object jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_mario_object jp_timer131_machine_endpoint /\
  jp_watched_state_mario_object jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_state_mario_object jp_timer131_machine_endpoint /\
  jp_watched_slot_active_flags jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_active_flags jp_timer131_machine_endpoint /\
  jp_watched_slot_behavior jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_behavior jp_timer131_machine_endpoint /\
  jp_watched_slot_flags jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_flags jp_timer131_machine_endpoint /\
  jp_watched_slot_graph_y_offset_bits jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_graph_y_offset_bits jp_timer131_machine_endpoint /\
  jp_watched_slot_next jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_next jp_timer131_machine_endpoint /\
  jp_watched_slot_previous jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_previous jp_timer131_machine_endpoint /\
  jp_watched_list_next jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_sentinel_next jp_timer131_machine_endpoint /\
  jp_watched_list_previous jp_timer131_expected_watched_endpoint =
    jp_machine_endpoint_sentinel_previous jp_timer131_machine_endpoint.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * The accepted machine-level entry theorem *)

Definition jp_timer131_machine_tail_safe
    (state : JPInkTimer131WatchedState) : Prop :=
  Z.testbit (jp_watched_slot_flags state) 0 = false /\
  jp_watched_slot_graph_y_offset_bits state = 0.

Definition jp_timer131_machine_tail_dangerous
    (state : JPInkTimer131WatchedState) : Prop :=
  Z.testbit (jp_watched_slot_flags state) 0 = true /\
  jp_watched_slot_graph_y_offset_bits state <> 0.

(** This record is deliberately independent of CompCert blocks.  It is the
    exact retail-machine boundary which the project has chosen to accept:
    one checkpoint sequence, both distinct spawn callsites, the slot-67
    identity/list facts, and the two safe tail values. *)
Record JPInkTimer131AcceptedEntryState
    (state : JPInkTimer131WatchedState) : Prop := {
  jp_accepted_entry_checkpoint_order :
    map jp_machine_checkpoint_stage jp_timer131_machine_checkpoints =
      [JPTimer131ClearObjects; JPTimer131LoadMarioArea;
       JPTimer131SpawnAreaObjects; JPTimer131SpawnMario;
       JPTimer131InitMario];
  jp_accepted_entry_area_spawn_return :
    jp_machine_checkpoint_return_pc jp_timer131_area_spawn_checkpoint =
      2150082916;
  jp_accepted_entry_mario_spawn_return :
    jp_machine_checkpoint_return_pc jp_timer131_mario_spawn_checkpoint =
      2150083184;
  jp_accepted_entry_slot_exact :
    jp_machine_endpoint_slot jp_timer131_machine_endpoint = 67;
  jp_accepted_entry_slot_address :
    jp_machine_endpoint_mario_object jp_timer131_machine_endpoint =
      jp_machine_endpoint_object_pool jp_timer131_machine_endpoint +
        object_size * jp_machine_endpoint_slot jp_timer131_machine_endpoint;
  jp_accepted_entry_global_mario :
    jp_watched_global_mario_object state = 2150916152;
  jp_accepted_entry_state_mario :
    jp_watched_state_mario_object state = 2150916152;
  jp_accepted_entry_active :
    jp_watched_slot_active_flags state = 257;
  jp_accepted_entry_behavior :
    jp_watched_slot_behavior state = 2148446656;
  jp_accepted_entry_slot_next :
    jp_watched_slot_next state = 2150873200;
  jp_accepted_entry_slot_previous :
    jp_watched_slot_previous state = 2150873200;
  jp_accepted_entry_list_next :
    jp_watched_list_next state = 2150916152;
  jp_accepted_entry_list_previous :
    jp_watched_list_previous state = 2150916152;
  jp_accepted_entry_flag_word :
    jp_watched_slot_flags state = 256;
  jp_accepted_entry_graphical_offset :
    jp_watched_slot_graph_y_offset_bits state = 0;
  jp_accepted_entry_safe_tail :
    jp_timer131_machine_tail_safe state
}.

Definition JPInkTimer131AcceptedEntryTheorem : Prop :=
  JPInkTimer131AuthenticatedMachineWriteReceipt /\
  forall initial,
    JPInkTimer131AcceptedEntryState
      (jp_timer131_replay_machine_writes initial).

Theorem jp_timer131_authenticated_receipt_is_accepted_entry :
  JPInkTimer131AcceptedEntryTheorem.
Proof.
  split; [exact jp_timer131_authenticated_machine_writes_decode |].
  intro initial.
  rewrite (proj2 (proj2 jp_timer131_authenticated_machine_writes_decode)
    initial).
  constructor; vm_compute; repeat split; reflexivity.
Qed.

(** The strengthened accepted boundary keeps the safe endpoint and the
    independently authenticated callsite receipt together.  In particular,
    the static [unload_object -> stop_sounds_from_source] edge is now removed
    from the dynamic entry obligations, while the observed continuous-bank
    call still requires either the already accepted watched-memory receipt or
    a concrete effect specification in an optional Clight reconstruction. *)
Definition JPInkTimer131AcceptedEntryWithCallsiteBoundary : Prop :=
  JPInkTimer131AcceptedEntryTheorem /\
  jp_timer131_callsite_machine_code_claim /\
  JPInkTimer131AuthenticatedCallReachabilityReceipt /\
  jp_timer131_entry_external_reachability_reduction_claim.

Theorem jp_timer131_authenticated_entry_and_callsite_boundary :
  JPInkTimer131AcceptedEntryWithCallsiteBoundary.
Proof.
  split; [exact jp_timer131_authenticated_receipt_is_accepted_entry |].
  split; [exact jp_timer131_callsite_machine_code_checked |].
  split; [exact jp_timer131_authenticated_call_reachability_decodes |].
  exact jp_timer131_entry_external_reachability_reduction_checked.
Qed.

Lemma jp_timer131_machine_safe_tail_is_not_dangerous :
  forall state,
    jp_timer131_machine_tail_safe state ->
    ~ jp_timer131_machine_tail_dangerous state.
Proof.
  intros state [Hsafe_flag Hsafe_offset]
    [Hdanger_flag Hdanger_offset].
  rewrite Hsafe_flag in Hdanger_flag. discriminate.
Qed.

Corollary jp_timer131_accepted_entry_has_safe_tail :
  forall initial,
    jp_timer131_machine_tail_safe
      (jp_timer131_replay_machine_writes initial) /\
    ~ jp_timer131_machine_tail_dangerous
        (jp_timer131_replay_machine_writes initial).
Proof.
  intro initial.
  pose proof (proj2 jp_timer131_authenticated_receipt_is_accepted_entry
    initial) as Hentry.
  pose proof (jp_accepted_entry_safe_tail _ Hentry) as Hsafe.
  split; [exact Hsafe |].
  exact (jp_timer131_machine_safe_tail_is_not_dangerous _ Hsafe).
Qed.

(** This theorem checks the translation-relevant facts in the recorded bytes:
    five ordered calls (including both spawns), exact slot arithmetic, matching
    Mario pointers, a safe flag word, zero graphical offset, and the one-node
    player-list ring.  The shell harness separately authenticates the ROM and
    trace hashes named above. *)
Theorem jp_timer131_authenticated_machine_receipt_decodes :
  map jp_machine_checkpoint_stage jp_timer131_machine_checkpoints =
    [JPTimer131ClearObjects; JPTimer131LoadMarioArea;
     JPTimer131SpawnAreaObjects; JPTimer131SpawnMario;
     JPTimer131InitMario] /\
  List.length jp_timer131_machine_checkpoints = 5%nat /\
  jp_machine_checkpoint_return_pc jp_timer131_area_spawn_checkpoint =
    2150082916 /\
  jp_machine_checkpoint_return_pc jp_timer131_mario_spawn_checkpoint =
    2150083184 /\
  jp_machine_endpoint_mario_object jp_timer131_machine_endpoint =
    jp_machine_endpoint_object_pool jp_timer131_machine_endpoint +
      object_size * jp_machine_endpoint_slot jp_timer131_machine_endpoint /\
  jp_machine_endpoint_slot jp_timer131_machine_endpoint = 67 /\
  jp_machine_endpoint_state_mario_object jp_timer131_machine_endpoint =
    jp_machine_endpoint_mario_object jp_timer131_machine_endpoint /\
  jp_machine_endpoint_active_flags jp_timer131_machine_endpoint = 257 /\
  Z.testbit (jp_machine_endpoint_flags jp_timer131_machine_endpoint) 0 =
    false /\
  jp_machine_endpoint_graph_y_offset_bits jp_timer131_machine_endpoint = 0 /\
  jp_machine_endpoint_next jp_timer131_machine_endpoint =
    jp_machine_endpoint_previous jp_timer131_machine_endpoint /\
  jp_machine_endpoint_sentinel_next jp_timer131_machine_endpoint =
    jp_machine_endpoint_mario_object jp_timer131_machine_endpoint /\
  jp_machine_endpoint_sentinel_previous jp_timer131_machine_endpoint =
    jp_machine_endpoint_mario_object jp_timer131_machine_endpoint.
Proof.
  vm_compute. repeat split; reflexivity.
Qed.

(** * An actual step-by-step cell classifier *)

Inductive InkTimer131CellClassifiedReach
    (program : Clight.program) (addresses : Area1EntryAddresses) :
    Clight.state -> Clight.state -> Prop :=
| InkPrefixReachRefl :
    forall state,
      InkTimer131CellClassifiedReach program addresses state state
| InkPrefixReachStep :
    forall before step_trace middle final,
      Clight.step2 (Clight.globalenv program)
        before step_trace middle ->
      InkTimer131CellEffect
        (ink_timer131_clight_state_memory before)
        (ink_timer131_clight_state_memory middle) addresses ->
      InkTimer131CellClassifiedReach program addresses middle final ->
      InkTimer131CellClassifiedReach program addresses before final.

Lemma ink_timer131_cell_effect_preserves_safety :
  forall before after addresses,
    InkTimer131CellEffect before after addresses ->
    ink_timer131_cells_safe before (area1_object_pool_block addresses)
      (area1_mario_slot addresses) ->
    ink_timer131_cells_safe after (area1_object_pool_block addresses)
      (area1_mario_slot addresses).
Proof.
  intros before after addresses Heffect Hsafe.
  destruct Heffect as [Hstore | Hframe].
  - eapply ink_clean_store_step_preserves_timer131_cell_safety; eauto.
  - eapply ink_timer131_protected_cell_frame_preserves_safety; eauto.
Qed.

Theorem classified_reach_is_an_actual_clight_star :
  forall program addresses start final,
    InkTimer131CellClassifiedReach program addresses start final ->
    exists trace,
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        start trace final.
Proof.
  intros program addresses start final Hreach.
  induction Hreach.
  - exists E0. constructor.
  - destruct IHHreach as [tail Htail].
    exists (step_trace ** tail).
    eapply Smallstep.star_step; eauto.
Qed.

Theorem classified_reach_preserves_timer131_cells :
  forall program addresses start final,
    InkTimer131CellClassifiedReach program addresses start final ->
    ink_timer131_cells_safe (ink_timer131_clight_state_memory start)
      (area1_object_pool_block addresses) (area1_mario_slot addresses) ->
    ink_timer131_cells_safe (ink_timer131_clight_state_memory final)
      (area1_object_pool_block addresses) (area1_mario_slot addresses).
Proof.
  intros program addresses start final Hreach.
  induction Hreach; intro Hsafe.
  - exact Hsafe.
  - apply IHHreach.
    eapply ink_timer131_cell_effect_preserves_safety; eauto.
Qed.

Lemma classified_reach_trans :
  forall program addresses first middle final,
    InkTimer131CellClassifiedReach program addresses first middle ->
    InkTimer131CellClassifiedReach program addresses middle final ->
    InkTimer131CellClassifiedReach program addresses first final.
Proof.
  intros program addresses first middle final Hfirst Hsecond.
  induction Hfirst.
  - exact Hsecond.
  - econstructor; eauto.
Qed.

(** A finite execution can be translated into the inductive certificate once
    every step reachable from its accepted start has a checked cell effect.
    This is the precise star-to-certificate direction that the earlier file
    lacked. *)
Definition InkTimer131PrefixStepCoverage
    (program : Clight.program) (start : Clight.state)
    (addresses : Area1EntryAddresses) : Prop :=
  forall before,
    InkTimer131ClightReachable program start before ->
    forall step_trace after,
      Clight.step2 (Clight.globalenv program) before step_trace after ->
      InkTimer131CellEffect
        (ink_timer131_clight_state_memory before)
        (ink_timer131_clight_state_memory after) addresses.

Lemma clight_star_tail_under_timer131_cell_coverage_is_classified :
  forall program addresses origin current trace final,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      current trace final ->
    InkTimer131PrefixStepCoverage program origin addresses ->
    InkTimer131ClightReachable program origin current ->
    InkTimer131CellClassifiedReach program addresses current final.
Proof.
  intros program addresses origin current trace final Hstar.
  induction Hstar; intros Hcoverage Hreachable.
  - constructor.
  - econstructor.
    + exact H.
    + eapply Hcoverage; eauto.
    + apply IHHstar.
      * exact Hcoverage.
      * destruct Hreachable as [prefix Hprefix].
        unfold InkTimer131ClightReachable.
        eexists.
        eapply Smallstep.star_trans.
        -- exact Hprefix.
        -- eapply Smallstep.star_step.
           ++ exact H.
           ++ constructor.
           ++ reflexivity.
        -- reflexivity.
Qed.

Theorem clight_star_under_timer131_cell_coverage_is_classified :
  forall program addresses start trace final,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      start trace final ->
    InkTimer131PrefixStepCoverage program start addresses ->
    InkTimer131CellClassifiedReach program addresses start final.
Proof.
  intros program addresses start trace final Hstar Hcoverage.
  eapply clight_star_tail_under_timer131_cell_coverage_is_classified; eauto.
  exists E0. constructor.
Qed.

Definition clight_calls_internal
    (body : function) (state : Clight.state) : Prop :=
  exists arguments continuation memory,
    state = Clight.Callstate (Internal body)
      arguments continuation memory.

(** [Kcall] retains the exact internal caller.  This is the Clight analogue of
    the distinct retail return PCs and prevents the two spawn checkpoints from
    being exchanged. *)
Definition clight_calls_internal_from
    (body caller : function) (state : Clight.state) : Prop :=
  exists arguments result caller_environment caller_temporaries
      rest_continuation memory,
    state = Clight.Callstate (Internal body) arguments
      (Clight.Kcall result caller caller_environment caller_temporaries
        rest_continuation) memory.

Lemma ink_timer131_reachable_follow_star :
  forall program origin current trace final,
    InkTimer131ClightReachable program origin current ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      current trace final ->
    InkTimer131ClightReachable program origin final.
Proof.
  intros program origin current trace final [prefix Hprefix] Hstar.
  exists (prefix ** trace).
  eapply Smallstep.star_trans; eauto.
Qed.

(** The raw semantic object needed to translate the authenticated checkpoint
    shape.  It contains only actual stars, exact caller-sensitive checkpoints,
    and one coverage theorem from the accepted start.  The theorem below turns
    it into the per-step inductive certificate automatically. *)
Record JPInkTimer131LevelSelectExecutionSkeleton
    (addresses : Area1EntryAddresses) : Type := {
  jp_ink_skeleton_start : Clight.state;
  jp_ink_skeleton_load : Clight.state;
  jp_ink_skeleton_area_spawn : Clight.state;
  jp_ink_skeleton_mario_spawn : Clight.state;
  jp_ink_skeleton_init : Clight.state;
  jp_ink_skeleton_final : Clight.state;

  jp_ink_skeleton_clear_to_load_trace : trace;
  jp_ink_skeleton_load_to_area_spawn_trace : trace;
  jp_ink_skeleton_area_to_mario_spawn_trace : trace;
  jp_ink_skeleton_mario_spawn_to_init_trace : trace;
  jp_ink_skeleton_init_to_final_trace : trace;

  jp_ink_skeleton_start_is_clear :
    clight_calls_internal_from IT131P_Objects.f_clear_objects
      IT131P_Script.f_level_cmd_init_level jp_ink_skeleton_start;
  jp_ink_skeleton_load_is_real :
    clight_calls_internal_from IT131P_Area.f_load_mario_area
      IT131P_Update.f_init_level jp_ink_skeleton_load;
  jp_ink_skeleton_area_spawn_is_real :
    clight_calls_internal_from IT131P_Objects.f_spawn_objects_from_info
      IT131P_Area.f_load_area jp_ink_skeleton_area_spawn;
  jp_ink_skeleton_mario_spawn_is_real :
    clight_calls_internal_from IT131P_Objects.f_spawn_objects_from_info
      IT131P_Area.f_load_mario_area jp_ink_skeleton_mario_spawn;
  jp_ink_skeleton_init_is_real :
    clight_calls_internal_from IT131P_Mario.f_init_mario
      IT131P_Update.f_init_level jp_ink_skeleton_init;

  jp_ink_skeleton_clear_to_load_star :
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      jp_ink_skeleton_start jp_ink_skeleton_clear_to_load_trace
      jp_ink_skeleton_load;
  jp_ink_skeleton_load_to_area_spawn_star :
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      jp_ink_skeleton_load jp_ink_skeleton_load_to_area_spawn_trace
      jp_ink_skeleton_area_spawn;
  jp_ink_skeleton_area_to_mario_spawn_star :
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      jp_ink_skeleton_area_spawn
      jp_ink_skeleton_area_to_mario_spawn_trace
      jp_ink_skeleton_mario_spawn;
  jp_ink_skeleton_mario_spawn_to_init_star :
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      jp_ink_skeleton_mario_spawn
      jp_ink_skeleton_mario_spawn_to_init_trace jp_ink_skeleton_init;
  jp_ink_skeleton_init_to_final_star :
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      jp_ink_skeleton_init jp_ink_skeleton_init_to_final_trace
      jp_ink_skeleton_final;

  jp_ink_skeleton_step_coverage :
    InkTimer131PrefixStepCoverage jp_official_cleaned_slice
      jp_ink_skeleton_start addresses
}.

(** The five certificate segments deliberately cross subsystem boundaries.
    The accepted start is the selected Area-1 [clear_objects] call itself.
    Both observed spawn calls are represented; the final init-to-end segment
    includes the first object/behavior update.  All intermediate states are
    shared, so the segments cannot be assembled from different runs. *)
Record JPInkTimer131RealEntryPrefix
    (addresses : Area1EntryAddresses) : Type := {
  jp_ink_prefix_level_select_start : Clight.state;
  jp_ink_prefix_load_call : Clight.state;
  jp_ink_prefix_area_spawn_call : Clight.state;
  jp_ink_prefix_mario_spawn_call : Clight.state;
  jp_ink_prefix_init_call : Clight.state;
  jp_ink_prefix_final : Clight.state;

  jp_ink_prefix_level_select_start_is_clear :
    clight_calls_internal_from IT131P_Objects.f_clear_objects
      IT131P_Script.f_level_cmd_init_level
      jp_ink_prefix_level_select_start;
  jp_ink_prefix_load_is_real :
    clight_calls_internal_from IT131P_Area.f_load_mario_area
      IT131P_Update.f_init_level
      jp_ink_prefix_load_call;
  jp_ink_prefix_area_spawn_is_real :
    clight_calls_internal_from IT131P_Objects.f_spawn_objects_from_info
      IT131P_Area.f_load_area
      jp_ink_prefix_area_spawn_call;
  jp_ink_prefix_mario_spawn_is_real :
    clight_calls_internal_from IT131P_Objects.f_spawn_objects_from_info
      IT131P_Area.f_load_mario_area
      jp_ink_prefix_mario_spawn_call;
  jp_ink_prefix_init_is_real :
    clight_calls_internal_from IT131P_Mario.f_init_mario
      IT131P_Update.f_init_level
      jp_ink_prefix_init_call;

  jp_ink_prefix_clear_to_load :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_level_select_start jp_ink_prefix_load_call;
  jp_ink_prefix_load_to_area_spawn :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_load_call jp_ink_prefix_area_spawn_call;
  jp_ink_prefix_area_spawn_to_mario_spawn :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_area_spawn_call jp_ink_prefix_mario_spawn_call;
  jp_ink_prefix_mario_spawn_to_init :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_mario_spawn_call jp_ink_prefix_init_call;
  jp_ink_prefix_init_to_final :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      jp_ink_prefix_init_call jp_ink_prefix_final
}.

Theorem level_select_execution_skeleton_builds_classified_prefix :
  forall addresses
      (skeleton : JPInkTimer131LevelSelectExecutionSkeleton addresses),
    JPInkTimer131RealEntryPrefix addresses.
Proof.
  intros addresses skeleton.
  assert (Hstart_reachable :
    InkTimer131ClightReachable jp_official_cleaned_slice
      (jp_ink_skeleton_start _ skeleton)
      (jp_ink_skeleton_start _ skeleton)).
  { exists E0. constructor. }
  assert (Hload_reachable :
    InkTimer131ClightReachable jp_official_cleaned_slice
      (jp_ink_skeleton_start _ skeleton)
      (jp_ink_skeleton_load _ skeleton)).
  {
    eapply ink_timer131_reachable_follow_star.
    - exact Hstart_reachable.
    - exact (jp_ink_skeleton_clear_to_load_star _ skeleton).
  }
  assert (Harea_reachable :
    InkTimer131ClightReachable jp_official_cleaned_slice
      (jp_ink_skeleton_start _ skeleton)
      (jp_ink_skeleton_area_spawn _ skeleton)).
  {
    eapply ink_timer131_reachable_follow_star.
    - exact Hload_reachable.
    - exact (jp_ink_skeleton_load_to_area_spawn_star _ skeleton).
  }
  assert (Hmario_reachable :
    InkTimer131ClightReachable jp_official_cleaned_slice
      (jp_ink_skeleton_start _ skeleton)
      (jp_ink_skeleton_mario_spawn _ skeleton)).
  {
    eapply ink_timer131_reachable_follow_star.
    - exact Harea_reachable.
    - exact (jp_ink_skeleton_area_to_mario_spawn_star _ skeleton).
  }
  assert (Hinit_reachable :
    InkTimer131ClightReachable jp_official_cleaned_slice
      (jp_ink_skeleton_start _ skeleton)
      (jp_ink_skeleton_init _ skeleton)).
  {
    eapply ink_timer131_reachable_follow_star.
    - exact Hmario_reachable.
    - exact (jp_ink_skeleton_mario_spawn_to_init_star _ skeleton).
  }
  refine
    {| jp_ink_prefix_level_select_start := jp_ink_skeleton_start _ skeleton;
       jp_ink_prefix_load_call := jp_ink_skeleton_load _ skeleton;
       jp_ink_prefix_area_spawn_call := jp_ink_skeleton_area_spawn _ skeleton;
       jp_ink_prefix_mario_spawn_call :=
         jp_ink_skeleton_mario_spawn _ skeleton;
       jp_ink_prefix_init_call := jp_ink_skeleton_init _ skeleton;
       jp_ink_prefix_final := jp_ink_skeleton_final _ skeleton;
       jp_ink_prefix_level_select_start_is_clear :=
         jp_ink_skeleton_start_is_clear _ skeleton;
       jp_ink_prefix_load_is_real := jp_ink_skeleton_load_is_real _ skeleton;
       jp_ink_prefix_area_spawn_is_real :=
         jp_ink_skeleton_area_spawn_is_real _ skeleton;
       jp_ink_prefix_mario_spawn_is_real :=
         jp_ink_skeleton_mario_spawn_is_real _ skeleton;
       jp_ink_prefix_init_is_real := jp_ink_skeleton_init_is_real _ skeleton;
       jp_ink_prefix_clear_to_load := _;
       jp_ink_prefix_load_to_area_spawn := _;
       jp_ink_prefix_area_spawn_to_mario_spawn := _;
       jp_ink_prefix_mario_spawn_to_init := _;
       jp_ink_prefix_init_to_final := _ |}.
  - eapply clight_star_tail_under_timer131_cell_coverage_is_classified.
    + exact (jp_ink_skeleton_clear_to_load_star _ skeleton).
    + exact (jp_ink_skeleton_step_coverage _ skeleton).
    + exact Hstart_reachable.
  - eapply clight_star_tail_under_timer131_cell_coverage_is_classified.
    + exact (jp_ink_skeleton_load_to_area_spawn_star _ skeleton).
    + exact (jp_ink_skeleton_step_coverage _ skeleton).
    + exact Hload_reachable.
  - eapply clight_star_tail_under_timer131_cell_coverage_is_classified.
    + exact (jp_ink_skeleton_area_to_mario_spawn_star _ skeleton).
    + exact (jp_ink_skeleton_step_coverage _ skeleton).
    + exact Harea_reachable.
  - eapply clight_star_tail_under_timer131_cell_coverage_is_classified.
    + exact (jp_ink_skeleton_mario_spawn_to_init_star _ skeleton).
    + exact (jp_ink_skeleton_step_coverage _ skeleton).
    + exact Hmario_reachable.
  - eapply clight_star_tail_under_timer131_cell_coverage_is_classified.
    + exact (jp_ink_skeleton_init_to_final_star _ skeleton).
    + exact (jp_ink_skeleton_step_coverage _ skeleton).
    + exact Hinit_reachable.
Qed.

Definition jp_ink_timer131_whole_prefix
    {addresses} (prefix : JPInkTimer131RealEntryPrefix addresses) :
    InkTimer131CellClassifiedReach jp_official_cleaned_slice addresses
      (jp_ink_prefix_level_select_start _ prefix)
      (jp_ink_prefix_final _ prefix) :=
  classified_reach_trans _ _ _ _ _ (jp_ink_prefix_clear_to_load _ prefix)
    (classified_reach_trans _ _ _ _ _
      (jp_ink_prefix_load_to_area_spawn _ prefix)
      (classified_reach_trans _ _ _ _ _
        (jp_ink_prefix_area_spawn_to_mario_spawn _ prefix)
        (classified_reach_trans _ _ _ _ _
          (jp_ink_prefix_mario_spawn_to_init _ prefix)
          (jp_ink_prefix_init_to_final _ prefix)))).

Theorem jp_ink_timer131_real_prefix_is_one_actual_execution :
  forall addresses (prefix : JPInkTimer131RealEntryPrefix addresses),
    exists trace,
      @Smallstep.star _ _ Clight.step2
        (Clight.globalenv jp_official_cleaned_slice)
        (jp_ink_prefix_level_select_start _ prefix) trace
        (jp_ink_prefix_final _ prefix).
Proof.
  intros addresses prefix.
  apply (classified_reach_is_an_actual_clight_star
    jp_official_cleaned_slice addresses).
  exact (jp_ink_timer131_whole_prefix prefix).
Qed.

(** * Exact endpoint consequence of a completed certificate *)

Record JPInkTimer131RealEntryResult
    (addresses : Area1EntryAddresses)
    (prefix : JPInkTimer131RealEntryPrefix addresses)
    (behavior_block : block)
    (loads : list InkTimer131ProtectedLoad) : Prop := {
  jp_ink_prefix_symbols :
    JPArea1EntrySymbolBindings
      (Clight.globalenv jp_official_cleaned_slice) addresses;
  jp_ink_prefix_mario_slot_exact :
    area1_mario_slot addresses = 67%nat;
  jp_ink_prefix_bhv_mario_symbol :
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      IT131P_Data._bhvMario = Some behavior_block;
  jp_ink_prefix_global_mario_pointer :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_mario_object_pointer_cell_block addresses) 0 0 =
      Some (object_slot_pointer addresses (area1_mario_slot addresses));
  jp_ink_prefix_state_mario_pointer :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_state_storage_block addresses) 0
      mario_state_object_pointer_offset =
      Some (object_slot_pointer addresses (area1_mario_slot addresses));
  jp_ink_prefix_global_lists_pointer :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_lists_pointer_cell_block addresses) 0 0 =
      Some (Vptr (area1_object_lists_storage_block addresses) Ptrofs.zero);
  jp_ink_prefix_mario_active :
    load_at Mint16signed
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_pool_block addresses) (mario_object_base addresses)
      object_active_flags_offset = Some (Vint active_object_flags);
  jp_ink_prefix_behavior_load :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_pool_block addresses) (mario_object_base addresses)
      object_behavior_offset = Some (Vptr behavior_block Ptrofs.zero);
  jp_ink_prefix_list_head_next :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_lists_storage_block addresses) 0 object_next_offset =
      Some (object_slot_pointer addresses (area1_mario_slot addresses));
  jp_ink_prefix_list_head_previous :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_lists_storage_block addresses) 0 object_previous_offset =
      Some (object_slot_pointer addresses (area1_mario_slot addresses));
  jp_ink_prefix_mario_next :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_pool_block addresses) (mario_object_base addresses)
      object_next_offset = Some (ink_timer131_list_zero_head addresses);
  jp_ink_prefix_mario_previous :
    load_at Mptr
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_pool_block addresses) (mario_object_base addresses)
      object_previous_offset = Some (ink_timer131_list_zero_head addresses);
  jp_ink_prefix_flag_word_exact :
    ink_object_cell_load Mint32 ink_object_flag_cell_offset
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_pool_block addresses) (mario_object_base addresses) =
      Some (Vint (Int.repr 256));
  jp_ink_prefix_graphical_offset_exact :
    ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      (area1_object_pool_block addresses) (mario_object_base addresses) =
      Some (Vsingle positive_f32_zero);
  jp_ink_prefix_protected_loads :
    InkTimer131ProtectedLoadsHold
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix)) loads
}.

Theorem completed_real_prefix_supplies_live_timer131_invariant :
  forall addresses (prefix : JPInkTimer131RealEntryPrefix addresses)
      behavior_block loads,
    JPInkTimer131RealEntryResult addresses prefix behavior_block loads ->
    InkTimer131LiveInvariant
      (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
      addresses behavior_block loads.
Proof.
  intros addresses prefix behavior_block loads Hresult.
  destruct Hresult as
    [Hsymbols Hslot Hbehavior_symbol Hglobal_mario Hstate_mario Hlists
     Hactive Hbehavior Hhead_next Hhead_previous Hmario_next Hmario_previous
     Hflags Hgraph Hloads].
  constructor.
  - exists (Int.repr 256).
    split; [exact Hflags |].
    split.
    + vm_compute. reflexivity.
    + exact Hgraph.
  - constructor.
    + exact Hglobal_mario.
    + exact Hstate_mario.
    + exact Hlists.
    + exact Hactive.
    + exact Hbehavior.
    + eapply list_zero_head_next_is_mario_supplies_membership; eauto.
  - exact Hloads.
Qed.

(** The exact endpoint and the classified prefix now compose without an
    ordinary-castle premise. *)
Theorem completed_level_select_bridge_is_one_safe_execution :
  forall addresses (prefix : JPInkTimer131RealEntryPrefix addresses)
      behavior_block loads,
    JPInkTimer131RealEntryResult addresses prefix behavior_block loads ->
    exists trace,
      @Smallstep.star _ _ Clight.step2
        (Clight.globalenv jp_official_cleaned_slice)
        (jp_ink_prefix_level_select_start _ prefix) trace
        (jp_ink_prefix_final _ prefix) /\
      InkTimer131LiveInvariant
        (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
        addresses behavior_block loads.
Proof.
  intros addresses prefix behavior_block loads Hresult.
  destruct (jp_ink_timer131_real_prefix_is_one_actual_execution
    addresses prefix) as [trace Htrace].
  exists trace. split; [exact Htrace |].
  eapply completed_real_prefix_supplies_live_timer131_invariant; eauto.
Qed.

Theorem completed_level_select_bridge_and_post_entry_coverage_exclude_tail :
  forall addresses (prefix : JPInkTimer131RealEntryPrefix addresses)
      behavior_block loads trace final,
    JPInkTimer131RealEntryResult addresses prefix behavior_block loads ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv jp_official_cleaned_slice)
      (jp_ink_prefix_final _ prefix) trace final ->
    InkTimer131ReachableStepCoverage jp_official_cleaned_slice
      (jp_ink_prefix_final _ prefix) addresses loads ->
    ~ ink_timer131_tail_cells_dangerous
        (ink_timer131_clight_state_memory final)
        (area1_object_pool_block addresses) (area1_mario_slot addresses).
Proof.
  intros addresses prefix behavior_block loads trace final Hresult Htrace
    Hcoverage.
  eapply linked_clight_trace_cannot_install_timer131_tail_cells; eauto.
  eapply completed_real_prefix_supplies_live_timer131_invariant; eauto.
Qed.

Definition InkTimer131RealEntryPrefixCheckedBoundary : Prop :=
  ink_timer131_real_prefix_source_claim /\
  JPInkTimer131AcceptedEntryTheorem /\
  jp_timer131_callsite_machine_code_claim /\
  JPInkTimer131AuthenticatedCallReachabilityReceipt /\
  jp_timer131_entry_external_reachability_reduction_claim /\
  jp_timer131_entry_direct_writer_claim /\
  jp_timer131_entry_external_inventory_claim /\
  jp_timer131_entry_external_callsite_claim /\
  jp_timer131_level_select_direct_writer_claim /\
  jp_timer131_level_select_external_inventory_claim /\
  jp_timer131_level_select_external_callsite_claim /\
  map jp_machine_checkpoint_stage jp_timer131_machine_checkpoints =
    [JPTimer131ClearObjects; JPTimer131LoadMarioArea;
     JPTimer131SpawnAreaObjects; JPTimer131SpawnMario;
     JPTimer131InitMario] /\
  (forall program addresses start final,
    InkTimer131CellClassifiedReach program addresses start final ->
    exists trace,
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
        start trace final) /\
  (forall addresses (prefix : JPInkTimer131RealEntryPrefix addresses)
      behavior_block loads,
    JPInkTimer131RealEntryResult addresses prefix behavior_block loads ->
    exists trace,
      @Smallstep.star _ _ Clight.step2
        (Clight.globalenv jp_official_cleaned_slice)
        (jp_ink_prefix_level_select_start _ prefix) trace
        (jp_ink_prefix_final _ prefix) /\
      InkTimer131LiveInvariant
        (ink_timer131_clight_state_memory (jp_ink_prefix_final _ prefix))
        addresses behavior_block loads).

Theorem ink_timer131_real_entry_prefix_checked_boundary_holds :
  InkTimer131RealEntryPrefixCheckedBoundary.
Proof.
  split; [exact ink_timer131_real_prefix_source_checked |].
  split; [exact jp_timer131_authenticated_receipt_is_accepted_entry |].
  split; [exact jp_timer131_callsite_machine_code_checked |].
  split; [exact jp_timer131_authenticated_call_reachability_decodes |].
  split; [exact jp_timer131_entry_external_reachability_reduction_checked |].
  split; [exact jp_timer131_entry_direct_writer_checked |].
  split; [exact jp_timer131_entry_external_inventory_checked |].
  split; [exact jp_timer131_entry_external_callsites_checked |].
  split; [exact jp_timer131_level_select_direct_writer_checked |].
  split; [exact jp_timer131_level_select_external_inventory_checked |].
  split; [exact jp_timer131_level_select_external_callsites_checked |].
  split.
  - exact (proj1 jp_timer131_authenticated_machine_receipt_decodes).
  - split; [exact classified_reach_is_an_actual_clight_star |].
    exact completed_level_select_bridge_is_one_safe_execution.
Qed.
