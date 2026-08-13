(** User-authorized default SSL Area-1 start boundary.

    The linked gameplay proof is scoped to begin immediately after the stock
    node-0x0A spin-airborne spawn has established the ordinary Area-1 memory
    postcondition.  Reaching this state from the OS, castle, painting, or
    level-select execution is deliberately outside the capstone scope.

    This module does not prove that the boundary exists.  It packages the
    exact selected program, symbol bindings, stock spawn coordinates,
    synchronized entry memory, controller history, no-A edge, and a null
    global [gMarioPlatform] as explicit assumptions on a scope-declared
    run start.  Nullness is required for JP as well as US: JP spawning retains
    the prior global pointer, so omitting this field would silently allow a
    castle-installed stale-platform lineage escape.

    Object-pool/list ownership, linked writer and non-alias coverage, external
    frames, retail-MIPS refinement, and every post-boundary lifecycle fact
    remain separate obligations. *)

From Coq Require Import ZArith.
From compcert Require Import
  AST Clight Ctypes Floats Globalenvs Integers Memory Values.
From LessThanOneAPress.Generated Require Import jp_area us_area.
From LessThanOneAPress.Proofs Require Import
  EntryMemory GameTypes InputSemantics OrdinaryArea1EntryMemory
  SelectedClightTarget.

Local Open Scope Z_scope.

Definition default_area1_spawn_x : float32 :=
  Float32.of_int (Int.repr 653).

Definition default_area1_spawn_y : float32 :=
  Float32.of_int (Int.repr 1038).

Definition default_area1_spawn_z : float32 :=
  Float32.of_int (Int.repr 6566).

Definition DefaultArea1EntrySymbolBindings
    (version : GameVersion) (program : Clight.program)
    (addresses : Area1EntryAddresses) : Prop :=
  match version with
  | VersionUS =>
      USArea1EntrySymbolBindings (Clight.globalenv program) addresses
  | VersionJP =>
      JPArea1EntrySymbolBindings (Clight.globalenv program) addresses
  end.

(** Addresses not already carried by [Area1EntryAddresses], but needed to
    distinguish the default SSL Area-1 exterior entry from a fabricated state
    in some other level or area.  Its engine value is [AREA(1)]. *)
Record DefaultArea1WorldAddresses := {
  default_area1_entry_addresses : Area1EntryAddresses;
  default_area1_current_level_block : block;
  default_area1_current_area_block : block;
  default_area1_current_area_pointer_cell_block : block;
  default_area1_area_data_block : block
}.

Definition default_area1_current_level_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_area._gCurrLevelNum
  | VersionJP => jp_area._gCurrLevelNum
  end.

Definition default_area1_current_area_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_area._gCurrAreaIndex
  | VersionJP => jp_area._gCurrAreaIndex
  end.

Definition default_area1_current_area_pointer_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_area._gCurrentArea
  | VersionJP => jp_area._gCurrentArea
  end.

Definition default_area1_area_data_ident
    (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_area._gAreaData
  | VersionJP => jp_area._gAreaData
  end.

(** The pointer loaded into [gCurrentArea] is [and gAreaData[1]].  Compute its
    byte stride from each version's generated [struct Area], rather than
    inserting an unexplained numeral into the memory contract. *)
Definition default_area1_area_struct_size
    (version : GameVersion) : Z :=
  match version with
  | VersionUS =>
      sizeof (prog_comp_env us_area.prog) (Tstruct us_area._Area noattr)
  | VersionJP =>
      sizeof (prog_comp_env jp_area.prog) (Tstruct jp_area._Area noattr)
  end.

Theorem default_area1_area_struct_size_is_60 :
  forall version, default_area1_area_struct_size version = 60.
Proof. intros []; vm_compute; reflexivity. Qed.

Record DefaultArea1WorldSymbolBindings
    (version : GameVersion) (program : Clight.program)
    (world : DefaultArea1WorldAddresses) : Prop := {
  default_area1_world_entry_symbols :
    DefaultArea1EntrySymbolBindings version program
      (default_area1_entry_addresses world);
  default_area1_world_level_symbol :
    Genv.find_symbol (Clight.globalenv program)
      (default_area1_current_level_ident version) =
      Some (default_area1_current_level_block world);
  default_area1_world_area_symbol :
    Genv.find_symbol (Clight.globalenv program)
      (default_area1_current_area_ident version) =
      Some (default_area1_current_area_block world);
  default_area1_world_current_area_pointer_symbol :
    Genv.find_symbol (Clight.globalenv program)
      (default_area1_current_area_pointer_ident version) =
      Some (default_area1_current_area_pointer_cell_block world);
  default_area1_world_area_data_symbol :
    Genv.find_symbol (Clight.globalenv program)
      (default_area1_area_data_ident version) =
      Some (default_area1_area_data_block world)
}.

(** This record is a proof boundary, not a reachability witness.  In
    particular, no constructor theorem below claims that either selected
    program reaches it. *)
Record DefaultArea1StartBoundary
    (version : GameVersion) (program : Clight.program)
    (memory : mem) (world : DefaultArea1WorldAddresses)
    (previous_down current_down : int) : Prop := {
  default_area1_start_selected_program :
    program = selected_clight_target version;
  default_area1_start_symbol_bindings :
    DefaultArea1WorldSymbolBindings version program world;
  default_area1_start_level_is_ssl :
    load_at Mint16signed memory
      (default_area1_current_level_block world) 0 0 =
      Some (Vint ssl_level_id);
  default_area1_start_engine_area_is_one :
    load_at Mint16signed memory
      (default_area1_current_area_block world) 0 0 =
      Some (Vint (Int.repr 1));
  default_area1_start_current_area_is_area_data_one :
    load_at Mptr memory
      (default_area1_current_area_pointer_cell_block world) 0 0 =
      Some (Vptr (default_area1_area_data_block world)
        (Ptrofs.repr (default_area1_area_struct_size version)));
  default_area1_start_entry_memory :
    OrdinaryArea1EntryMemoryPostcondition memory
      (default_area1_entry_addresses world)
      default_area1_spawn_x default_area1_spawn_y default_area1_spawn_z
      (entry_sample_from_history previous_down current_down);
  default_area1_start_global_platform_null :
    load_at Mptr memory
      (area1_platform_pointer_cell_block
        (default_area1_entry_addresses world)) 0 0 =
      Some (Vint Int.zero);
  default_area1_start_no_a_edge :
    frame_has_no_a_press
      {| frame_previous_down := previous_down;
         frame_current_down := current_down |}
}.

(** The postcondition's controller bytes are the exact sample generated from
    the record's predecessor/current input pair; they are not an unrelated
    existential sample. *)
Theorem default_area1_start_supplies_controller_history :
  forall version program memory world previous_down current_down,
    DefaultArea1StartBoundary version program memory world
      previous_down current_down ->
    OrdinaryArea1ControllerHistoryMemory memory
      (default_area1_entry_addresses world)
      previous_down current_down.
Proof.
  intros version program memory world previous_down current_down Hstart.
  destruct Hstart as [_ _ _ _ _ Hentry _ _].
  constructor.
  - exact (ordinary_area1_controller_down _ _ _ _ _ _ Hentry).
  - exact (ordinary_area1_controller_pressed _ _ _ _ _ _ Hentry).
Qed.

Theorem default_area1_start_fixes_clean_zero_a_baseline :
  forall version program memory world previous_down current_down,
    DefaultArea1StartBoundary version program memory world
      previous_down current_down ->
    program = selected_clight_target version /\
    DefaultArea1WorldSymbolBindings version program world /\
    load_at Mint16signed memory
      (default_area1_current_level_block world) 0 0 =
      Some (Vint ssl_level_id) /\
    load_at Mint16signed memory
      (default_area1_current_area_block world) 0 0 =
      Some (Vint (Int.repr 1)) /\
    load_at Mptr memory
      (default_area1_current_area_pointer_cell_block world) 0 0 =
      Some (Vptr (default_area1_area_data_block world)
        (Ptrofs.repr (default_area1_area_struct_size version))) /\
    OrdinaryArea1EntryMemoryPostcondition memory
      (default_area1_entry_addresses world)
      default_area1_spawn_x default_area1_spawn_y default_area1_spawn_z
      (entry_sample_from_history previous_down current_down) /\
    load_at Mptr memory
      (area1_platform_pointer_cell_block
        (default_area1_entry_addresses world)) 0 0 =
      Some (Vint Int.zero) /\
    OrdinaryArea1ControllerHistoryMemory memory
      (default_area1_entry_addresses world)
      previous_down current_down /\
    entry_sample_has_no_a_edge
      (entry_sample_from_history previous_down current_down).
Proof.
  intros version program memory world previous_down current_down Hstart.
  destruct Hstart as
    [Hprogram Hsymbols Hlevel Harea Hcurrent_area Hentry Hplatform Hno_a].
  split; [exact Hprogram |].
  split; [exact Hsymbols |].
  split; [exact Hlevel |].
  split; [exact Harea |].
  split; [exact Hcurrent_area |].
  split; [exact Hentry |].
  split; [exact Hplatform |].
  split.
  - constructor.
    + exact (ordinary_area1_controller_down _ _ _ _ _ _ Hentry).
    + exact (ordinary_area1_controller_pressed _ _ _ _ _ _ Hentry).
  - now apply no_a_frame_yields_no_a_entry_sample.
Qed.
