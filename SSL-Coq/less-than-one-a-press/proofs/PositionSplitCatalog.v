(** Source checks for the whole-game position-split catalog.
    This is a finite census of the actual generated US/JP corpus and stock
    SSL selectors. It is NOT an assertion that every live write has been
    classified, or that these source facts alone exclude every history. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import
  us_obj_behaviors_2 us_behavior_actions us_platform_displacement
  us_behavior_data us_macro_special_objects us_ssl_script
  jp_obj_behaviors_2 jp_behavior_actions jp_platform_displacement
  jp_behavior_data jp_macro_special_objects jp_ssl_script.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightRefinement JPGeneratedWriterCensus
  Area1EntryDepthClosure Area1ButterflyStaticOriginClosure
  InkTimer131ProducerClosure.
Import ListNotations.

(** All direct callers of the State-only XYZ setter, across all 39 generated
    units per version. This supplements, rather than repeats, the existing
    Chuckya/King-Bob-omb anchor and direct raw-Object writer inventories. *)
Definition psc_state_setter_callers : Prop :=
  direct_call_sites us_platform_displacement._set_mario_pos
    (generated_definitions_of us_translation_units) =
    [us_obj_behaviors_2._dorrie_raise_head;
     us_behavior_actions._bhv_tilting_inverted_pyramid_loop;
     us_platform_displacement._apply_platform_displacement] /\
  direct_call_sites jp_platform_displacement._set_mario_pos
    (generated_definitions_of jp_translation_units) =
    [jp_obj_behaviors_2._dorrie_raise_head;
     jp_behavior_actions._bhv_tilting_inverted_pyramid_loop;
     jp_platform_displacement._apply_platform_displacement].

Theorem psc_state_setter_callers_checked : psc_state_setter_callers.
Proof.
  unfold psc_state_setter_callers, generated_definitions_of, direct_call_sites.
  vm_compute. split; reflexivity.
Qed.

(** These are mechanisms requiring actors absent from the stock SSL
    selectors. Including a name here is not a claim that every such actor
    supplies a useful Ink gap. In particular, Heave-Ho sets launch state,
    whereas the Chuckya anchor actually copies displayed coordinates. *)
Definition psc_absent_actor_targets : list ident :=
  [us_behavior_data._bhvDorrie;
   us_behavior_data._bhvLLLTiltingInvertedPyramid;
   us_behavior_data._bhvBitFSTiltingInvertedPyramid;
   us_behavior_data._bhvHoot;
   us_behavior_data._bhvHeaveHo;
   us_behavior_data._bhvWhirlpool;
   us_behavior_data._bhvSmallBully;
   us_behavior_data._bhvBigBully;
   us_behavior_data._bhvBigBullyWithMinions;
   us_behavior_data._bhvSmallChillBully;
   us_behavior_data._bhvBigChillBully;
   us_behavior_data._bhvBowserShockWave].

Lemma psc_version_actor_names_agree : psc_absent_actor_targets =
  [jp_behavior_data._bhvDorrie;
   jp_behavior_data._bhvLLLTiltingInvertedPyramid;
   jp_behavior_data._bhvBitFSTiltingInvertedPyramid;
   jp_behavior_data._bhvHoot;
   jp_behavior_data._bhvHeaveHo;
   jp_behavior_data._bhvWhirlpool;
   jp_behavior_data._bhvSmallBully;
   jp_behavior_data._bhvBigBully;
   jp_behavior_data._bhvBigBullyWithMinions;
   jp_behavior_data._bhvSmallChillBully;
   jp_behavior_data._bhvBigChillBully;
   jp_behavior_data._bhvBowserShockWave].
Proof. reflexivity. Qed.

Definition psc_us_actor_selected (target : ident) : bool :=
  us_area1_macro_mentions_behavior target ||
  program_initializers_mention_addrof target us_ssl_script.prog ||
  selected_area1_special_source target
    (gvar_init us_macro_special_objects.v_sSpecialObjectPresets).
Definition psc_jp_actor_selected (target : ident) : bool :=
  jp_area1_macro_mentions_behavior target ||
  program_initializers_mention_addrof target jp_ssl_script.prog ||
  selected_area1_special_source target
    (gvar_init jp_macro_special_objects.v_sSpecialObjectPresets).

Definition psc_absent_actor_selectors : Prop :=
  map psc_us_actor_selected psc_absent_actor_targets = repeat false 12 /\
  map psc_jp_actor_selected psc_absent_actor_targets = repeat false 12.

Theorem psc_absent_actor_selectors_checked : psc_absent_actor_selectors.
Proof.
  unfold psc_absent_actor_selectors, psc_absent_actor_targets,
    psc_us_actor_selected, psc_jp_actor_selected,
    us_area1_macro_mentions_behavior, jp_area1_macro_mentions_behavior,
    macro_list_mentions_behavior, program_initializers_mention_addrof,
    selected_area1_special_source, area1_selected_special_preset_ids,
    special_preset_table_selects_behavior, special_preset_record_selects_behavior.
  vm_compute. split; reflexivity.
Qed.

(** Positive controls: the selectors are not identically false. These
    stock Area-1 actors must stay in the catalog rather than being excluded
    by a missing-actor argument. Tree comes from the special-object stream. *)
Definition psc_present_actor_selectors : Prop :=
  map psc_us_actor_selected
    [us_behavior_data._bhvTree; us_behavior_data._bhvTweester;
     us_behavior_data._bhvToxBox; us_behavior_data._bhvCannonClosed] =
    repeat true 4 /\
  map psc_jp_actor_selected
    [jp_behavior_data._bhvTree; jp_behavior_data._bhvTweester;
     jp_behavior_data._bhvToxBox; jp_behavior_data._bhvCannonClosed] =
    repeat true 4.
Theorem psc_present_actor_selectors_checked : psc_present_actor_selectors.
Proof.
  unfold psc_present_actor_selectors,
    psc_us_actor_selected, psc_jp_actor_selected,
    us_area1_macro_mentions_behavior, jp_area1_macro_mentions_behavior,
    macro_list_mentions_behavior, program_initializers_mention_addrof,
    selected_area1_special_source, area1_selected_special_preset_ids,
    special_preset_table_selects_behavior, special_preset_record_selects_behavior.
  vm_compute. split; reflexivity.
Qed.

Theorem psc_named_actor_has_no_stock_selector : forall target,
  In target psc_absent_actor_targets ->
  psc_us_actor_selected target = false /\ psc_jp_actor_selected target = false.
Proof.
  intros target Hin.
  destruct psc_absent_actor_selectors_checked as [Hus Hjp].
  split.
  - assert (In (psc_us_actor_selected target)
        (map psc_us_actor_selected psc_absent_actor_targets)) as H
      by (apply in_map; exact Hin).
    rewrite Hus in H. apply repeat_spec in H. exact H.
  - assert (In (psc_jp_actor_selected target)
        (map psc_jp_actor_selected psc_absent_actor_targets)) as H
      by (apply in_map; exact Hin).
    rewrite Hjp in H. apply repeat_spec in H. exact H.
Qed.

Definition PositionSplitCatalogSourceBoundary : Prop :=
  psc_state_setter_callers /\ psc_absent_actor_selectors /\ psc_present_actor_selectors.
Theorem psc_catalog_source_boundary_checked : PositionSplitCatalogSourceBoundary.
Proof.
  split; [exact psc_state_setter_callers_checked |].
  split; [exact psc_absent_actor_selectors_checked | exact psc_present_actor_selectors_checked].
Qed.
