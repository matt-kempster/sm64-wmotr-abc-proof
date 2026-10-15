From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs Coqlib Ctypes Events Floats
 Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init us_memory jp_memory.
From Demo.Proofs Require Import DemoExecutionHistory DemoPlaybackExecution
 DemoPlaybackAdvanceExecution DemoControllerInputExecution DemoAnalogInputExecution
 DemoConsumedInputExecution.
Import ListNotations.
Local Open Scope Z_scope.

(** Specification receipts over the original execution, not a replacement
    execution relation. No loaded-scene identity or level equality occurs here.
    Existence/coverage from permitted starts remains a separate obligation. *)
Definition origin_reader (us : bool) : function :=
 if us then us_game_init.f_read_controller_inputs else jp_game_init.f_read_controller_inputs.
Definition origin_player (us : bool) : function :=
 if us then us_game_init.f_run_demo_inputs else jp_game_init.f_run_demo_inputs.
Definition origin_loader (us : bool) : function :=
 if us then us_memory.f_load_patchable_table else jp_memory.f_load_patchable_table.
Definition origin_dma (us : bool) : function :=
 if us then us_memory.f_dma_read else jp_memory.f_dma_read.

Definition origin_state_memory (state : Clight.state) : Mem.mem :=
 match state with
 | State _ _ _ _ _ memory | Callstate _ _ _ memory | Returnstate _ _ memory => memory
 end.
Definition origin_history_memory {prog} (history : demo_execution_history prog) index : Mem.mem :=
 origin_state_memory (history_state history index).

(** Same continuation plus the first matching return prevents borrowing a
    later loop iteration's return at an identical call continuation. *)
Definition origin_call_interval {prog} (history : demo_execution_history prog)
    (first past : nat) (callee : Clight.fundef) (args : list val) (result : val) (k : cont) : Prop :=
 (first < past <= history_length history)%nat /\
 history_state history first = Callstate callee args k (origin_history_memory history first) /\
 history_state history past = Returnstate result k (origin_history_memory history past) /\
 (forall index value memory, (first < index < past)%nat ->
   history_state history index <> Returnstate value k memory).

Definition origin_region_history {prog} (history : demo_execution_history prog)
    (first past : nat) (region : block -> Z -> Prop) : Prop :=
 history_interval history first past /\
 forall index, (first <= index < past)%nat ->
  Mem.unchanged_on region (origin_history_memory history index)
    (origin_history_memory history (S index)).

Record demo_sequence_selection : Type := {
 selection_call_index : nat;
 selection_return_index : nat;
 selection_table_index : int;
 selection_return_value : int;
 selection_handler : block;
 selection_table : block;
 selection_count : int;
 selection_source : block;
 selection_source_base : ptrofs;
 selection_rom_offset : int;
 selection_payload_size : int;
 selection_buffer : block;
 selection_header : int
}.

Definition selection_source_begin (selection : demo_sequence_selection) : ptrofs :=
 Ptrofs.add (selection_source_base selection) (Ptrofs.of_intu (selection_rom_offset selection)).
Definition selection_source_end (selection : demo_sequence_selection) : ptrofs :=
 Ptrofs.add (selection_source_begin selection) (Ptrofs.of_ints (selection_payload_size selection)).

(** A table selection is not yet an authenticated ROM identity. The full
    specification must authenticate this table entry and the DMA bytes.
    Successful cache hits and actual DMA occurrences are kept distinct. *)
Definition demo_selection_receipt {prog} (history : demo_execution_history prog)
    (us : bool) (selection : demo_sequence_selection) : Prop :=
 exists loader_code k,
 Genv.find_symbol (Clight.globalenv prog) us_game_init._gDemoInputsBuf =
   Some (selection_handler selection) /\
 Genv.find_symbol (Clight.globalenv prog) us_memory._load_patchable_table = Some loader_code /\
 Genv.find_funct (Clight.globalenv prog) (Vptr loader_code Ptrofs.zero) =
   Some (Internal (origin_loader us)) /\
 origin_call_interval history (selection_call_index selection) (selection_return_index selection)
   (Internal (origin_loader us))
   [Vptr (selection_handler selection) Ptrofs.zero; Vint (selection_table_index selection)]
   (Vint (selection_return_value selection)) k /\
 Mem.load Mptr (origin_history_memory history (selection_call_index selection))
   (selection_handler selection) 0 = Some (Vptr (selection_table selection) Ptrofs.zero) /\
 Mem.load Mint32 (origin_history_memory history (selection_call_index selection))
   (selection_table selection) 0 = Some (Vint (selection_count selection)) /\
 0 <= Int.signed (selection_table_index selection) /\
 Int.ltu (selection_table_index selection) (selection_count selection) = true /\
 Mem.load Mptr (origin_history_memory history (selection_call_index selection))
   (selection_table selection) 4 =
   Some (Vptr (selection_source selection) (selection_source_base selection)) /\
 Mem.load Mint32 (origin_history_memory history (selection_call_index selection))
   (selection_table selection) (8 + 8 * Int.signed (selection_table_index selection)) =
   Some (Vint (selection_rom_offset selection)) /\
 Mem.load Mint32 (origin_history_memory history (selection_call_index selection))
   (selection_table selection) (12 + 8 * Int.signed (selection_table_index selection)) =
   Some (Vint (selection_payload_size selection)) /\
 4 <= Int.signed (selection_payload_size selection) /\
 Mem.load Mptr (origin_history_memory history (selection_return_index selection))
   (selection_handler selection) 8 = Some (Vptr (selection_buffer selection) Ptrofs.zero) /\
 Mem.load Mptr (origin_history_memory history (selection_return_index selection))
   (selection_handler selection) 4 =
   Some (Vptr (selection_source selection) (selection_source_begin selection)).

Record demo_backing_load : Type := {
 backing_call_index : nat;
 backing_return_index : nat
}.

Definition demo_backing_load_receipt {prog} (history : demo_execution_history prog)
    (us : bool) (selection : demo_sequence_selection) (backing : demo_backing_load) : Prop :=
 exists dma_code k,
 Genv.find_symbol (Clight.globalenv prog) us_memory._dma_read = Some dma_code /\
 Genv.find_funct (Clight.globalenv prog) (Vptr dma_code Ptrofs.zero) = Some (Internal (origin_dma us)) /\
 origin_call_interval history (backing_call_index backing) (backing_return_index backing)
   (Internal (origin_dma us))
   [Vptr (selection_buffer selection) Ptrofs.zero;
    Vptr (selection_source selection) (selection_source_begin selection);
    Vptr (selection_source selection) (selection_source_end selection)] Vundef k /\
 Mem.load Mint8signed (origin_history_memory history (backing_return_index backing))
   (selection_buffer selection) 0 = Some (Vint (selection_header selection)) /\
 ((selection_return_value selection = Int.one /\
   (selection_call_index selection <= backing_call_index backing /\
    backing_return_index backing <= selection_return_index selection)%nat) \/
  (selection_return_value selection = Int.zero /\
   (backing_return_index backing <= selection_call_index selection)%nat /\
   Mem.load Mptr (origin_history_memory history (selection_call_index selection))
     (selection_handler selection) 4 =
     Some (Vptr (selection_source selection) (selection_source_begin selection)))).

Definition origin_payload_non_timer_bytes (selection : demo_sequence_selection) (b : block) (byte : Z) : Prop :=
 b = selection_buffer selection /\ 0 <= byte < Int.signed (selection_payload_size selection) /\
 (byte < 4 \/ byte mod 4 <> 0).

Inductive demo_controller_input_field : Type :=
 | OriginRawX | OriginRawY | OriginStickX | OriginStickY | OriginStickMagnitude
 | OriginButtonDown | OriginButtonPressed.

Definition origin_field_chunk (field : demo_controller_input_field) : memory_chunk :=
 match field with
 | OriginRawX | OriginRawY => Mint16signed
 | OriginButtonDown | OriginButtonPressed => Mint16unsigned
 | _ => Mfloat32
 end.
Definition origin_field_offset (field : demo_controller_input_field) : Z :=
 match field with
 | OriginRawX => 0 | OriginRawY => 2 | OriginStickX => 4 | OriginStickY => 8
 | OriginStickMagnitude => 12 | OriginButtonDown => 16 | OriginButtonPressed => 18
 end.

Record demo_input_emission : Type := {
 emission_reader_entry : nat;
 emission_run_callsite : nat;
 emission_run_entry : nat;
 emission_run_return : nat;
 emission_reader_return : nat;
 emission_controllers : block;
 emission_current_global : block;
 emission_pads : block;
 emission_pad_base : Z;
 emission_record : ptrofs;
 emission_timer : int;
 emission_raw_x : int;
 emission_raw_y : int;
 emission_mask : int;
 emission_physical_buttons : int;
 emission_previous_buttons : int;
 emission_sqrt_result : float32
}.

Definition origin_field_value (emission : demo_input_emission) (field : demo_controller_input_field) : val :=
 let x := playback_next_stick (emission_timer emission) (emission_raw_x emission) in
 let y := playback_next_stick (emission_timer emission) (emission_raw_y emission) in
 let buttons := playback_next_buttons (emission_timer emission)
   (emission_physical_buttons emission) (emission_mask emission) in
 match field with
 | OriginRawX => Vint x | OriginRawY => Vint y
 | OriginStickX => Vsingle (arbitrary_analog_final_axis x (emission_sqrt_result emission))
 | OriginStickY => Vsingle (arbitrary_analog_final_axis y (emission_sqrt_result emission))
 | OriginStickMagnitude => Vsingle (arbitrary_analog_final_magnitude (emission_sqrt_result emission))
 | OriginButtonDown => Vint buttons
 | OriginButtonPressed => Vint (controller_pressed_value buttons (emission_previous_buttons emission))
 end.

Definition origin_after_demo (reader : function) : statement :=
 match controller_actual_post_poll_body (fn_body reader) with
 | Ssequence _ remaining => remaining | _ => Sskip
 end.

Definition demo_reader_completion_at {prog} (history : demo_execution_history prog) (us : bool) index : Prop :=
 exists first k, origin_call_interval history first index (Internal (origin_reader us)) [] Vundef k.

(** Common actual-call and output boundary. Raw record loads belong only to
    the positive receipt below: EOF is not counted as playing another record. *)
Definition demo_input_emission_common {prog} (history : demo_execution_history prog)
    (us : bool) (selection : demo_sequence_selection) (backing : demo_backing_load)
    (emission : demo_input_emission) : Prop :=
 demo_selection_receipt history us selection /\
 demo_backing_load_receipt history us selection backing /\
 (selection_return_index selection <= emission_reader_entry emission <= emission_run_callsite emission)%nat /\
 emission_run_entry emission = S (emission_run_callsite emission) /\
 (emission_run_entry emission < emission_run_return emission /\
  emission_run_return emission < emission_reader_return emission /\ emission_reader_return emission <=
   history_length history)%nat /\
 origin_region_history history (backing_return_index backing) (emission_run_entry emission)
   (origin_payload_non_timer_bytes selection) /\
 (forall index k memory args, (backing_return_index backing <= index < emission_run_entry emission)%nat ->
   history_state history index <>
     Callstate (Internal (origin_dma us)) (Vptr (selection_buffer selection) Ptrofs.zero :: args) k memory) /\
 (forall index k memory selected, (selection_return_index selection < index < emission_run_entry emission)%nat ->
   history_state history index <> Callstate (Internal (origin_loader us))
     [Vptr (selection_handler selection) Ptrofs.zero; Vint selected] k memory) /\
 exists reader_code player_code reader_k run_k reader_le,
 Genv.find_symbol (Clight.globalenv prog) us_game_init._read_controller_inputs = Some reader_code /\
 Genv.find_funct (Clight.globalenv prog) (Vptr reader_code Ptrofs.zero) = Some (Internal (origin_reader us)) /\
 Genv.find_symbol (Clight.globalenv prog) us_game_init._run_demo_inputs = Some player_code /\
 Genv.find_funct (Clight.globalenv prog) (Vptr player_code Ptrofs.zero) = Some (Internal (origin_player us)) /\
 Genv.find_symbol (Clight.globalenv prog) us_game_init._gControllers = Some (emission_controllers emission) /\
 Genv.find_symbol (Clight.globalenv prog) us_game_init._gCurrDemoInput = Some (emission_current_global emission) /\
 origin_call_interval history (emission_reader_entry emission) (emission_reader_return emission)
   (Internal (origin_reader us)) [] Vundef reader_k /\
 run_k = Kcall None (origin_reader us) empty_env reader_le (Kseq (origin_after_demo (origin_reader us)) reader_k) /\
 history_state history (emission_run_callsite emission) =
   State (origin_reader us) (controller_actual_demo_call (fn_body (origin_reader us)))
     (Kseq (origin_after_demo (origin_reader us)) reader_k) empty_env reader_le
     (origin_history_memory history (emission_run_entry emission)) /\
 origin_call_interval history (emission_run_entry emission) (emission_run_return emission)
   (Internal (origin_player us)) [] Vundef run_k /\
 Mem.load Mptr (origin_history_memory history (emission_run_entry emission))
   (emission_current_global emission) 0 = Some (Vptr (selection_buffer selection) (emission_record emission)) /\
 Mem.load Mptr (origin_history_memory history (emission_run_entry emission))
   (emission_controllers emission) 24 = Some (Vptr (emission_pads emission) (Ptrofs.repr (emission_pad_base emission))) /\
 Mem.load Mint16unsigned (origin_history_memory history (emission_run_entry emission))
   (emission_pads emission) (emission_pad_base emission) = Some (Vint (emission_physical_buttons emission)) /\
 Mem.load Mint16unsigned (origin_history_memory history (emission_run_entry emission))
   (emission_controllers emission) 16 = Some (Vint (emission_previous_buttons emission)) /\
 Mem.load Mint8unsigned (origin_history_memory history (emission_run_entry emission))
   (selection_buffer selection) (Ptrofs.unsigned (emission_record emission)) = Some (Vint (emission_timer emission)) /\
 4 <= Ptrofs.unsigned (emission_record emission) /\
 Ptrofs.unsigned (emission_record emission) mod 4 = 0 /\
 Ptrofs.unsigned (emission_record emission) + 4 <= Int.signed (selection_payload_size selection) /\
 (forall field, Mem.load (origin_field_chunk field)
   (origin_history_memory history (emission_reader_return emission))
   (emission_controllers emission) (origin_field_offset field) = Some (origin_field_value emission field)).

Definition demo_positive_input_emission_receipt {prog} (history : demo_execution_history prog)
    us selection backing emission : Prop :=
 demo_input_emission_common history us selection backing emission /\
 Int.eq (emission_timer emission) Int.zero = false /\
 Mem.load Mint8signed (origin_history_memory history (emission_run_entry emission))
   (selection_buffer selection) (playback_field_offset (emission_record emission) 1) = Some (Vint (emission_raw_x emission)) /\
 Mem.load Mint8signed (origin_history_memory history (emission_run_entry emission))
   (selection_buffer selection) (playback_field_offset (emission_record emission) 2) = Some (Vint (emission_raw_y emission)) /\
 Mem.load Mint8unsigned (origin_history_memory history (emission_run_entry emission))
   (selection_buffer selection) (playback_field_offset (emission_record emission) 3) = Some (Vint (emission_mask emission)).

Definition demo_eof_emission_receipt {prog} (history : demo_execution_history prog)
    us selection backing emission : Prop :=
 demo_input_emission_common history us selection backing emission /\
 emission_timer emission = Int.zero.

Definition origin_field_bytes (emission : demo_input_emission)
    (field : demo_controller_input_field) (b : block) (byte : Z) : Prop :=
 b = emission_controllers emission /\
 origin_field_offset field <= byte < origin_field_offset field + size_chunk (origin_field_chunk field).

(** Endpoint API for the independently defined concrete gameplay-load
    observation. The field's address, chunk and value are explicit. Coverage
    must prove this receipt for every allowed gameplay read, not assume it. *)
Definition demo_input_origin_at {prog} (history : demo_execution_history prog)
    us selection backing emission observation field : Prop :=
 demo_positive_input_emission_receipt history us selection backing emission /\
 history_interval history (emission_reader_return emission) observation /\
 (forall index, (emission_reader_return emission < index <= observation)%nat ->
   ~ demo_reader_completion_at history us index) /\
 origin_region_history history (emission_reader_return emission) observation (origin_field_bytes emission field).

Definition demo_eof_origin_at {prog} (history : demo_execution_history prog)
    us selection backing emission observation field : Prop :=
 demo_eof_emission_receipt history us selection backing emission /\
 history_interval history (emission_reader_return emission) observation /\
 (forall index, (emission_reader_return emission < index <= observation)%nat ->
   ~ demo_reader_completion_at history us index) /\
 origin_region_history history (emission_reader_return emission) observation (origin_field_bytes emission field).

Lemma origin_region_history_preserves_load :
 forall prog (history : demo_execution_history prog) first past chunk b offset value,
 origin_region_history history first past
   (fun block byte => block = b /\ offset <= byte < offset + size_chunk chunk) ->
 Mem.load chunk (origin_history_memory history first) b offset = Some value ->
 Mem.load chunk (origin_history_memory history past) b offset = Some value.
Proof.
 intros prog history first past chunk b offset value [Hbounds Hframe] Hload.
 assert (Htransport : forall distance, (first + distance <= past)%nat ->
   Mem.load chunk (origin_history_memory history (first + distance)%nat) b offset = Some value).
 { induction distance as [|distance IH]; intros Hdistance.
   - rewrite Nat.add_0_r. exact Hload.
   - rewrite Nat.add_succ_r. eapply Mem.load_unchanged_on.
     + apply Hframe. lia.
     + intros byte Hbyte. split; [reflexivity | exact Hbyte].
     + apply IH. lia. }
 replace past with (first + (past - first))%nat by (unfold history_interval in Hbounds; lia).
 apply Htransport. unfold history_interval in Hbounds. lia.
Qed.

Lemma origin_emission_common_has_final_fields :
 forall prog (history : demo_execution_history prog) us selection backing emission,
 demo_input_emission_common history us selection backing emission ->
 forall field, Mem.load (origin_field_chunk field)
   (origin_history_memory history (emission_reader_return emission))
   (emission_controllers emission) (origin_field_offset field) = Some (origin_field_value emission field).
Proof.
 intros prog history us selection backing emission Hcommon.
 unfold demo_input_emission_common in Hcommon.
 repeat match type of Hcommon with
 | _ /\ _ => destruct Hcommon as [_ Hcommon]
 | ex _ => destruct Hcommon as [? Hcommon]
 end. exact Hcommon.
Qed.

Theorem demo_input_origin_at_supplies_typed_gameplay_load :
 forall prog (history : demo_execution_history prog) us selection backing emission observation field,
 demo_input_origin_at history us selection backing emission observation field ->
 Mem.load (origin_field_chunk field) (origin_history_memory history observation)
   (emission_controllers emission) (origin_field_offset field) = Some (origin_field_value emission field).
Proof.
 intros prog history us selection backing emission observation field [[Hcommon Hpositive] [Hbounds [Hrecent Hframe]]].
 eapply origin_region_history_preserves_load; [exact Hframe |].
 eapply origin_emission_common_has_final_fields. exact Hcommon.
Qed.

Theorem demo_eof_origin_at_supplies_typed_terminal_load :
 forall prog (history : demo_execution_history prog) us selection backing emission observation field,
 demo_eof_origin_at history us selection backing emission observation field ->
 Mem.load (origin_field_chunk field) (origin_history_memory history observation)
   (emission_controllers emission) (origin_field_offset field) = Some (origin_field_value emission field).
Proof.
 intros prog history us selection backing emission observation field [[Hcommon Hzero] [Hbounds [Hrecent Hframe]]].
 eapply origin_region_history_preserves_load; [exact Hframe |].
 eapply origin_emission_common_has_final_fields. exact Hcommon.
Qed.
