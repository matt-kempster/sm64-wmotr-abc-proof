(** The accepted JP level-select entry prefix for the timer-131 Ink route.

    Level select is the agreed start boundary for this route.  The certificate
    therefore starts at the last Area-1 [clear_objects] call observed by the
    authenticated retail trace; it does not add an unrelated task-start or
    castle-entry obligation.  [load_mario_area] follows later, and the retail
    receipt contains two distinct [spawn_objects_from_info] entries: the first
    is nested under [load_area] for Area-1 objects, while the second creates
    Mario.  [init_mario] then connects the new Object to MarioState.

    [InkTimer131CellClassifiedReach] is a small-step execution certificate:
    every constructor contains one actual [Clight.step2] and classifies that
    step's effect on the two watched cells.  The endpoint record is deliberately
    more concrete than the old ordinary-entry premise: it names observed slot
    67, [bhvMario], both Mario pointers, the player-list one-node ring,
    [oFlags = 0x100], and the zero graphical offset as exact CompCert loads.
    Those loads directly establish the live invariant; no claim that slot 67
    was already safe before Mario's allocation is needed.

    The machine constants below transcribe the SHA-256-pinned read-only receipt
    exactly and mechanically check its arithmetic.  They do not silently turn
    the IDO-produced retail binary into a CompCert execution.  Completing the
    bridge still means constructing the continuous [Clight.step2] certificate
    and deriving the endpoint loads from it.  Every reached unresolved
    OS/audio/graphics external must have a protected frame or checked writer
    effect.  Invalid pointers, OOB execution, ACE, and asynchronous DMA are
    outside CompCert Clight. *)

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

(** The accepted entry prefix itself has three roots.  This first closure does
    not add an object update which the checkpoint receipt has not established
    before the endpoint. *)
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

(** This second closure deliberately adds one conservative first
    [update_objects] root.  It covers the internal direct callees which can
    surround the observed endpoint even if a later refinement places the
    controller-poll observation after that update.  Indirect behavior-table
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
  "6D681DB5AA3A9F21F3D176BFCFC3507BD5C8CD840D980B1D01F7DA89666E5F20".

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
    Both observed spawn calls are represented, and the intermediate states are
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
