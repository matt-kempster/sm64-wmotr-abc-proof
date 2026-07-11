From Coq Require Import Lia ZArith.
From DemoWarp.Generated Require Import reachability_facts.
From DemoWarp.Proofs Require Import ASTReachabilityFacts.

Local Open Scope Z_scope.

Record physical_pool_state : Type := {
  pool_left_head : Z;
  pool_right_head : Z;
  pool_free_space : Z
}.

Definition pool_state_well_formed (state : physical_pool_state) : Prop :=
  us_main_pool_start <= pool_left_head state /\
  pool_left_head state + 16 <= pool_right_head state /\
  pool_right_head state <= us_main_pool_end - 16 /\
  pool_free_space state =
    pool_right_head state - pool_left_head state - 16.

Definition initial_main_pool_state : physical_pool_state :=
  {| pool_left_head := us_main_pool_start;
     pool_right_head := us_main_pool_end - 16;
     pool_free_space := us_main_pool_end - us_main_pool_start - 32 |}.

Theorem generated_pool_initial_state_is_well_formed :
  pool_state_well_formed initial_main_pool_state.
Proof.
  unfold pool_state_well_formed, initial_main_pool_state.
  simpl.
  unfold us_main_pool_start, us_main_pool_end.
  repeat split; lia.
Qed.

Definition demo_allocation_size_with_header : Z := 2064.

Definition successful_demo_left_allocation
    (before after : physical_pool_state) (buffer_base : Z) : Prop :=
  demo_allocation_size_with_header <= pool_free_space before /\
  buffer_base = pool_left_head before + 16 /\
  pool_left_head after =
    pool_left_head before + demo_allocation_size_with_header /\
  pool_right_head after = pool_right_head before /\
  pool_free_space after =
    pool_free_space before - demo_allocation_size_with_header.

Theorem successful_demo_left_allocation_preserves_pool_and_bounds_buffer :
  forall before after buffer_base,
    pool_state_well_formed before ->
    successful_demo_left_allocation before after buffer_base ->
    pool_state_well_formed after /\
    us_main_pool_start <= buffer_base /\
    buffer_base + us_demo_buffer_size <= us_main_pool_end.
Proof.
  intros [before_left before_right before_free]
    [after_left after_right after_free] buffer_base Hwell Halloc.
  unfold pool_state_well_formed in *.
  unfold successful_demo_left_allocation in Halloc.
  unfold demo_allocation_size_with_header in Halloc.
  unfold us_demo_buffer_size.
  simpl in *.
  destruct Hwell as (Hstart & Hheads & Hend & Hfree).
  destruct Halloc as (Hspace & Hbuffer & Hleft & Hright & Hafter_free).
  subst buffer_base after_left after_right after_free.
  unfold us_main_pool_start, us_main_pool_end in *.
  repeat split; lia.
Qed.

Definition authentic_us_demo_pointer
    (buffer_base current_pointer : Z) : Prop :=
  exists offset,
    4 <= offset <= max_us_demo_pointer_offset /\
    offset mod 4 = 0 /\
    current_pointer = buffer_base + offset.

Definition linker_placed_mario_y_address (mario_y_address : Z) : Prop :=
  us_main_pool_end <= mario_y_address.

Record normal_initialized_demo_state : Type := {
  normal_pool_before : physical_pool_state;
  normal_pool_after : physical_pool_state;
  normal_demo_buffer_base : Z;
  normal_current_demo_pointer : Z;
  normal_mario_y_address : Z;
  normal_pool_before_well_formed :
    pool_state_well_formed normal_pool_before;
  normal_demo_allocation_succeeded :
    successful_demo_left_allocation
      normal_pool_before normal_pool_after normal_demo_buffer_base;
  normal_current_pointer_from_authentic_stream :
    authentic_us_demo_pointer
      normal_demo_buffer_base normal_current_demo_pointer;
  normal_mario_y_linked_after_pool :
    linker_placed_mario_y_address normal_mario_y_address
}.

Definition witness_pool_after_demo : physical_pool_state :=
  {| pool_left_head :=
       us_main_pool_start + demo_allocation_size_with_header;
     pool_right_head := us_main_pool_end - 16;
     pool_free_space :=
       us_main_pool_end - us_main_pool_start - 32 -
       demo_allocation_size_with_header |}.

Theorem normal_initialized_demo_state_is_inhabited :
  exists state : normal_initialized_demo_state, True.
Proof.
  refine (ex_intro _
    {| normal_pool_before := initial_main_pool_state;
       normal_pool_after := witness_pool_after_demo;
       normal_demo_buffer_base := us_main_pool_start + 16;
       normal_current_demo_pointer := us_main_pool_start + 20;
       normal_mario_y_address := us_main_pool_end;
       normal_pool_before_well_formed :=
         generated_pool_initial_state_is_well_formed;
       normal_demo_allocation_succeeded := _;
       normal_current_pointer_from_authentic_stream := _;
       normal_mario_y_linked_after_pool := _ |} I).
  - unfold successful_demo_left_allocation,
      initial_main_pool_state, witness_pool_after_demo,
      demo_allocation_size_with_header.
    simpl.
    unfold us_main_pool_start, us_main_pool_end.
    repeat split; lia.
  - unfold authentic_us_demo_pointer.
    exists 4.
    unfold max_us_demo_pointer_offset.
    repeat split; lia.
  - unfold linker_placed_mario_y_address.
    lia.
Qed.

Theorem normal_initialized_demo_pointer_below_pool_end :
  forall state,
    normal_current_demo_pointer state < us_main_pool_end.
Proof.
  intros state.
  destruct state as
    [before after buffer_base current_pointer mario_y
     Hwell Halloc Hcurrent Hmario].
  simpl in *.
  pose proof
    (successful_demo_left_allocation_preserves_pool_and_bounds_buffer
      before after buffer_base Hwell Halloc) as (_ & _ & Hbuffer_end).
  destruct Hcurrent as (offset & Hoffset & _ & Hpointer).
  pose proof max_us_demo_pointer_stays_in_buffer as Hterminal_bound.
  unfold max_us_demo_pointer_offset in Hoffset, Hterminal_bound.
  unfold us_demo_buffer_size in Hbuffer_end, Hterminal_bound.
  subst current_pointer.
  lia.
Qed.

Theorem normal_initialized_demo_pointer_cannot_alias_mario_y :
  forall state,
    normal_current_demo_pointer state <>
    normal_mario_y_address state.
Proof.
  intros state Halias.
  pose proof (normal_initialized_demo_pointer_below_pool_end state) as Hbelow.
  destruct state as
    [before after buffer_base current_pointer mario_y
     Hwell Halloc Hcurrent Hmario].
  simpl in *.
  unfold linker_placed_mario_y_address in Hmario.
  subst mario_y.
  lia.
Qed.

Definition normal_initialization_reachability_claim : Prop :=
  generated_reachability_ast_claim /\
  generated_us_demo_stream_audit = true /\
  generated_linker_order_audit = true /\
  generated_demo_buffer_link_region <>
    generated_mario_states_link_region /\
  (exists state : normal_initialized_demo_state, True) /\
  forall state,
    normal_current_demo_pointer state <>
    normal_mario_y_address state.

Theorem normal_initialization_forbids_demo_pointer_mario_y_alias :
  normal_initialization_reachability_claim.
Proof.
  unfold normal_initialization_reachability_claim.
  split; [apply generated_reachability_ast_certificate |].
  split; [apply generated_us_demo_stream_audit_holds |].
  split; [apply generated_linker_order_audit_holds |].
  split; [apply generated_demo_and_mario_link_regions_distinct |].
  split; [apply normal_initialized_demo_state_is_inhabited |].
  apply normal_initialized_demo_pointer_cannot_alias_mario_y.
Qed.

Corollary normal_initialization_refutes_alias_reachability :
  ~ exists state,
      normal_current_demo_pointer state =
      normal_mario_y_address state.
Proof.
  intros (state & Halias).
  exact (normal_initialized_demo_pointer_cannot_alias_mario_y state Halias).
Qed.
