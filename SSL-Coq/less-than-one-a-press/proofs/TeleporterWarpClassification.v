(** Classification is decided before an ordinary warp is executed.

    This module extracts the real US/JP initiate_warp classifier and records
    the actual reached comparisons and reads in one execution.  In particular,
    its same-area case is a comparison with the current area at classification
    time.  It does not assert that later code cannot change areas. *)
From Coq Require Import List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_level_update jp_level_update.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  ObjectContactReadback InkBackwardExecution TeleporterSameAreaBoundary InkCopyCaller
  SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.

Definition twc_body version := fn_body (match version with
  | VersionUS => us_level_update.f_initiate_warp
  | VersionJP => jp_level_update.f_initiate_warp end).
Definition twc_classifier version := match twc_body version with
  | Ssequence classifier _ => classifier | _ => Sskip end.
Definition twc_metadata version := match twc_body version with
  | Ssequence _ metadata => metadata | _ => Sskip end.
Definition twc_type_target := Efield
  (Evar us_level_update._sWarpDest (Tstruct us_level_update._WarpDest noattr))
  us_level_update._type tuchar.
Definition twc_type_assignment code := Sassign twc_type_target
  (Econst_int (Int.repr code) tint).
Definition twc_node_guard := Ebinop Oge
  (Etempvar us_level_update._destWarpNode tshort)
  (Econst_int (Int.repr 248) tint) tint.
Definition twc_level_read := Evar us_level_update._gCurrLevelNum tshort.
Definition twc_level_guard := Ebinop One
  (Etempvar us_level_update._destLevel tshort)
  (Etempvar us_level_update._t'1 tshort) tint.
Definition twc_area_read := Evar us_level_update._gCurrentArea
  (tptr (Tstruct us_level_update._Area noattr)).
Definition twc_index_read := Efield
  (Ederef (Etempvar us_level_update._t'2
    (tptr (Tstruct us_level_update._Area noattr)))
    (Tstruct us_level_update._Area noattr)) us_level_update._index tschar.
Definition twc_area_guard := Ebinop One
  (Etempvar us_level_update._destArea tshort)
  (Etempvar us_level_update._t'3 tschar) tint.
Definition twc_after_level (le : temp_env) (level : val) :=
  PTree.set us_level_update._t'1 level le.
Definition twc_after_area (le : temp_env) (level area : val) :=
  PTree.set us_level_update._t'2 area (twc_after_level le level).
Definition twc_after_index (le : temp_env) (level area index : val) :=
  PTree.set us_level_update._t'3 index (twc_after_area le level area).

Theorem twc_generated_classifier_exact : forall version,
  twc_body version = Ssequence (twc_classifier version) (twc_metadata version) /\
  twc_classifier version =
    Sifthenelse twc_node_guard (twc_type_assignment 1)
      (Ssequence (Sset us_level_update._t'1 twc_level_read)
        (Sifthenelse twc_level_guard (twc_type_assignment 1)
          (Ssequence (Sset us_level_update._t'2 twc_area_read)
            (Ssequence (Sset us_level_update._t'3 twc_index_read)
              (Sifthenelse twc_area_guard (twc_type_assignment 2)
                (twc_type_assignment 3)))))) /\
  ibk_normal (twc_classifier version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

(** No function call or store precedes the selected type assignment.  All
    three values below are therefore read from the same entry memory. *)
Inductive TWCClassificationPath (ge : genv) (e : env) (le : temp_env)
    (before : mem) : Z -> trace -> temp_env -> mem -> outcome -> Prop :=
| twc_credits_path : forall trace last after out,
    ocn_test_value ge e le before twc_node_guard true ->
    ocn_exec ge e le before (twc_type_assignment 1) trace last after out ->
    TWCClassificationPath ge e le before 1 trace last after out
| twc_other_level_path : forall level trace last after out,
    ocn_test_value ge e le before twc_node_guard false ->
    eval_expr ge e le before twc_level_read level ->
    ocn_test_value ge e (twc_after_level le level) before twc_level_guard true ->
    ocn_exec ge e (twc_after_level le level) before
      (twc_type_assignment 1) trace last after out ->
    TWCClassificationPath ge e le before 1 trace last after out
| twc_other_area_path : forall level area index trace last after out,
    ocn_test_value ge e le before twc_node_guard false ->
    eval_expr ge e le before twc_level_read level ->
    ocn_test_value ge e (twc_after_level le level) before twc_level_guard false ->
    eval_expr ge e (twc_after_level le level) before twc_area_read area ->
    eval_expr ge e (twc_after_area le level area) before twc_index_read index ->
    ocn_test_value ge e (twc_after_index le level area index)
      before twc_area_guard true ->
    ocn_exec ge e (twc_after_index le level area index) before
      (twc_type_assignment 2) trace last after out ->
    TWCClassificationPath ge e le before 2 trace last after out
| twc_same_area_path : forall level area index trace last after out,
    ocn_test_value ge e le before twc_node_guard false ->
    eval_expr ge e le before twc_level_read level ->
    ocn_test_value ge e (twc_after_level le level) before twc_level_guard false ->
    eval_expr ge e (twc_after_level le level) before twc_area_read area ->
    eval_expr ge e (twc_after_area le level area) before twc_index_read index ->
    ocn_test_value ge e (twc_after_index le level area index)
      before twc_area_guard false ->
    ocn_exec ge e (twc_after_index le level area index) before
      (twc_type_assignment 3) trace last after out ->
    TWCClassificationPath ge e le before 3 trace last after out.

Lemma twc_read_prefix_exec : forall ge e le before id expression tail
    trace last after out,
  ocn_exec ge e le before (Ssequence (Sset id expression) tail)
    trace last after out ->
  exists value,
    eval_expr ge e le before expression value /\
    ocn_exec ge e (PTree.set id value le) before tail trace last after out.
Proof.
  intros ge e le before id expression tail trace last after out Hrun.
  destruct (ibk_split_sequence _ _ _ _ (Sset id expression) _ _ _ _ _
    eq_refl Hrun) as (middle & memory & pre & rest & Htrace & Hread & Htail).
  inversion Hread; subst. eauto.
Qed.

Definition TWCActualClassifierPaths : Prop :=
  forall version ge e le before trace last after out,
  ocn_exec ge e le before (twc_classifier version) trace last after out ->
  exists code, TWCClassificationPath ge e le before code trace last after out.

Theorem twc_actual_classifier_has_reached_path : TWCActualClassifierPaths.
Proof.
  unfold TWCActualClassifierPaths.
  intros version ge e le before trace last after out Hrun.
  destruct (twc_generated_classifier_exact version) as (_ & Hbody & _).
  rewrite Hbody in Hrun. inversion Hrun; subst.
  match goal with Hchoice : bool_val _ _ _ = Some ?choice |- _ =>
    destruct choice eqn:Hchoicecase end.
  - exists 1. econstructor; [unfold ocn_test_value; eauto|assumption].
  - match goal with Hbranch : ClightBigstep.exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) _) _ _ _ _ |- _ =>
      destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hbranch)
        as (level & Hlevel & Hrest) end.
    inversion Hrest; subst.
    match goal with Hchoice : bool_val _ _ _ = Some ?choice |- _ =>
      destruct choice eqn:Hchoicecase2 end.
    + exists 1. eapply twc_other_level_path; try eassumption;
        unfold ocn_test_value; eauto.
    + match goal with Hbranch : ClightBigstep.exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) _) _ _ _ _ |- _ =>
        destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hbranch)
          as (area & Harea & Harea_rest) end.
      destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Harea_rest)
        as (index & Hindex & Hindex_rest).
      inversion Hindex_rest; subst.
      match goal with Hchoice : bool_val _ _ _ = Some ?choice |- _ =>
        destruct choice eqn:Hchoicecase3 end.
      * exists 2. eapply twc_other_area_path; try eassumption;
          unfold ocn_test_value; eauto.
      * exists 3. eapply twc_same_area_path; try eassumption;
          unfold ocn_test_value; eauto.
Qed.

(** The complete initiate_warp run reaches this classifier before writing
    destination metadata; these two parts belong to that same execution. *)
Definition TWCFullBodyHasClassifierCut : Prop :=
  forall version ge e le before trace last after out,
  ocn_exec ge e le before (twc_body version) trace last after out ->
  exists code middle memory prefix suffix,
    trace = prefix ++ suffix /\
    TWCClassificationPath ge e le before code prefix middle memory Out_normal /\
    ocn_exec ge e middle memory (twc_metadata version) suffix last after out.

Theorem twc_full_body_reaches_classifier : TWCFullBodyHasClassifierCut.
Proof.
  unfold TWCFullBodyHasClassifierCut.
  intros version ge e le before trace last after out Hrun.
  destruct (twc_generated_classifier_exact version) as (Hbody & _ & Hnormal).
  rewrite Hbody in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (middle & memory & prefix & suffix & Htrace & Hfirst & Hlast).
  destruct (twc_actual_classifier_has_reached_path _ _ _ _ _ _ _ _ _ Hfirst)
    as (code & Hpath).
  exists code, middle, memory, prefix, suffix. auto.
Qed.

(** A type-3 path requires the actual reached level and area comparisons
    to be false.  These are observations at classification, not a promise
    about another later warp or area load. *)
Definition TWCSameAreaHasMatchingComparisons : Prop :=
  forall ge e le before trace last after out,
  TWCClassificationPath ge e le before 3 trace last after out ->
  exists level area index,
    ocn_test_value ge e le before twc_node_guard false /\
    eval_expr ge e le before twc_level_read level /\
    ocn_test_value ge e (twc_after_level le level) before twc_level_guard false /\
    eval_expr ge e (twc_after_level le level) before twc_area_read area /\
    eval_expr ge e (twc_after_area le level area) before twc_index_read index /\
    ocn_test_value ge e (twc_after_index le level area index)
      before twc_area_guard false.

Theorem twc_same_area_has_matching_comparisons : TWCSameAreaHasMatchingComparisons.
Proof.
  unfold TWCSameAreaHasMatchingComparisons. intros.
  match goal with Hpath : TWCClassificationPath _ _ _ _ 3 _ _ _ _ |- _ =>
    inversion Hpath; subst end.
  eauto 10.
Qed.

Lemma twc_global_struct_value : forall (ge : genv) e le memory id tag cell value,
  e ! id = None -> Genv.find_symbol ge id = Some cell ->
  eval_expr ge e le memory (Evar id (Tstruct tag noattr)) value ->
  value = Vptr cell Ptrofs.zero.
Proof.
  intros ge e le memory id tag cell value Hlocal Hsymbol Hread.
  inversion Hread; subst.
  match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    inversion Hl; subst; try congruence end.
  match goal with Hfind : Genv.find_symbol _ _ = Some ?found |- _ =>
    assert (found = cell) by congruence; subst found end.
  match goal with Hderef : deref_loc _ _ _ _ _ _ |- _ =>
    inversion Hderef; subst; try discriminate end.
  reflexivity.
Qed.

(** The code in a path receipt is the byte actually stored in sWarpDest.type,
    not merely a label for a hand-written classification. *)
Lemma twc_type_assignment_stores_code : forall version code e le before
    warp_cell trace last after out,
  In code [1; 2; 3] ->
  e ! us_level_update._sWarpDest = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_level_update._sWarpDest = Some warp_cell ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (twc_type_assignment code) trace last after out ->
  trace = E0 /\ out = Out_normal /\
  Mem.load Mint8unsigned after warp_cell 0 = Some (Vint (Int.repr code)).
Proof.
  intros version code e le before cell trace last after out
    Hcode Hlocal Hsymbol Hrun.
  unfold twc_type_assignment, twc_type_target in Hrun.
  inversion Hrun; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location _ _ _ _
      (Evar us_level_update._sWarpDest (Tstruct us_level_update._WarpDest noattr))
      us_level_update._WarpDest us_level_update._type tuchar cell Ptrofs.zero 0
      _ _ _ eq_refl
      ltac:(intros; eapply twc_global_struct_value; eauto)
      (tsa_selected_type_layout version) Hl) as (-> & -> & ->) end.
  match goal with Hr : eval_expr _ _ _ _ (Econst_int _ _) ?raw |- _ =>
    assert (raw = Vint (Int.repr code)) by
      (eapply ocn_const_int_value; exact Hr); subst raw end.
  assert (sem_cast (Vint (Int.repr code)) tint tuchar before =
    Some (Vint (Int.repr code))) as Hcast_code.
  { destruct Hcode as [Hone|[Htwo|[Hthree|[]]]]; subst code; reflexivity. }
  match goal with Hcast : sem_cast _ _ _ _ = Some ?cast |- _ =>
    is_var cast;
    change (sem_cast (Vint (Int.repr code)) tint tuchar before = Some cast)
      in Hcast;
    rewrite Hcast_code in Hcast; inversion Hcast; subst end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hstore : Mem.storev _ _ _ _ = Some after |- _ =>
    change (Mem.store Mint8unsigned before cell 0 (Vint (Int.repr code)) =
      Some after) in Hstore;
    repeat split; try reflexivity;
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore)
  end.
  destruct Hcode as [Hone|[Htwo|[Hthree|[]]]]; subst code; reflexivity.
Qed.

Lemma twc_path_stores_code : forall version e le before code trace last after out
    warp_cell,
  e ! us_level_update._sWarpDest = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_level_update._sWarpDest = Some warp_cell ->
  TWCClassificationPath (Clight.globalenv (selected_clight_target version))
    e le before code trace last after out ->
  In code [1; 2; 3] /\ trace = E0 /\ out = Out_normal /\
  Mem.load Mint8unsigned after warp_cell 0 = Some (Vint (Int.repr code)).
Proof.
  intros version e le before code trace last after out cell Hlocal Hsymbol Hpath.
  inversion Hpath; subst.
  all: split; [simpl; auto|].
  all: eapply (twc_type_assignment_stores_code version); eauto; simpl; auto.
Qed.

Definition TWCStoredSameAreaRequiresMatchingComparisons : Prop :=
  forall version e le before trace last after out warp_cell,
  e ! us_level_update._sWarpDest = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_level_update._sWarpDest = Some warp_cell ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (twc_classifier version) trace last after out ->
  Mem.load Mint8unsigned after warp_cell 0 = Some (Vint (Int.repr 3)) ->
  TWCClassificationPath (Clight.globalenv (selected_clight_target version))
    e le before 3 trace last after out.

Theorem twc_stored_same_area_requires_matching_comparisons :
  TWCStoredSameAreaRequiresMatchingComparisons.
Proof.
  unfold TWCStoredSameAreaRequiresMatchingComparisons.
  intros version e le before trace last after out cell Hlocal Hsymbol Hrun Hthree.
  destruct (twc_actual_classifier_has_reached_path _ _ _ _ _ _ _ _ _ Hrun)
    as (code & Hpath).
  destruct (twc_path_stores_code _ _ _ _ _ _ _ _ _ _ Hlocal Hsymbol Hpath)
    as (Hcode & _ & _ & Hstored).
  rewrite Hthree in Hstored.
  destruct Hcode as [Hone|[Htwo|[Hthree_code|[]]]]; subst code;
    try discriminate. exact Hpath.
Qed.

Lemma twc_false_integer_inequality : forall ge e le memory left right right_type
    lhs rhs,
  right_type = tshort \/ right_type = tschar ->
  le ! left = Some (Vint lhs) -> le ! right = Some (Vint rhs) ->
  ocn_test_value ge e le memory
    (Ebinop One (Etempvar left tshort) (Etempvar right right_type) tint) false ->
  lhs = rhs.
Proof.
  intros ge e le memory left right right_type lhs rhs Htype Hleft Hright
    (answer & Hread & Hfalse).
  inversion Hread; subst.
  - match goal with Hr : eval_expr _ _ _ _ (Etempvar left _) ?value |- _ =>
      assert (value = Vint lhs) by (eapply ocn_temp_value; eauto); subst value end.
    match goal with Hr : eval_expr _ _ _ _ (Etempvar right _) ?value |- _ =>
      assert (value = Vint rhs) by (eapply ocn_temp_value; eauto); subst value end.
    match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
      assert (Some (Val.of_bool (negb (Int.eq lhs rhs))) = Some answer) as Hvalue
        by (destruct Htype as [Hshort|Hchar]; subst right_type; exact Hsem);
      inversion Hvalue; subst answer end.
    destruct (Int.eq lhs rhs) eqn:Heq; cbn in Hfalse; try discriminate.
    apply Int.same_if_eq in Heq. exact Heq.
  - match goal with Hbad : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
      inversion Hbad end.
Qed.

Definition TWCSameAreaIntegerValuesMatch : Prop :=
  forall ge e le before trace last after out dest_level dest_area
    current_level current_area area_pointer,
  TWCClassificationPath ge e le before 3 trace last after out ->
  le ! us_level_update._destLevel = Some (Vint dest_level) ->
  le ! us_level_update._destArea = Some (Vint dest_area) ->
  eval_expr ge e le before twc_level_read (Vint current_level) ->
  eval_expr ge e (twc_after_level le (Vint current_level)) before
    twc_area_read area_pointer ->
  eval_expr ge e (twc_after_area le (Vint current_level) area_pointer) before
    twc_index_read (Vint current_area) ->
  dest_level = current_level /\ dest_area = current_area.

Theorem twc_same_area_integer_values_match : TWCSameAreaIntegerValuesMatch.
Proof.
  unfold TWCSameAreaIntegerValuesMatch.
  intros ge e le before trace last after out dest_level dest_area
    current_level current_area area_pointer Hpath Hdestlevel Hdestarea
    Hlevel Harea Hindex.
  destruct (twc_same_area_has_matching_comparisons _ _ _ _ _ _ _ _ Hpath)
    as (level & area & index & Hnode & Hlevel' & Hlevelguard & Harea' & Hindex' & Hguard).
  assert (level = Vint current_level) by (eapply ocr_expr_unique; eauto). subst level.
  assert (area = area_pointer) by (eapply ocr_expr_unique; eauto). subst area.
  assert (index = Vint current_area) by (eapply ocr_expr_unique; eauto). subst index.
  split.
  - unfold twc_level_guard in Hlevelguard.
    eapply twc_false_integer_inequality; [left; reflexivity| | |exact Hlevelguard].
    + unfold twc_after_level. rewrite PTree.gso by discriminate. exact Hdestlevel.
    + unfold twc_after_level. apply PTree.gss.
  - unfold twc_area_guard in Hguard.
    eapply twc_false_integer_inequality; [right; reflexivity| | |exact Hguard].
    + unfold twc_after_index, twc_after_area, twc_after_level.
      rewrite !PTree.gso by discriminate. exact Hdestarea.
    + unfold twc_after_index. apply PTree.gss.
Qed.

Definition TeleporterWarpClassificationBoundary : Prop :=
  TWCActualClassifierPaths /\ TWCFullBodyHasClassifierCut /\
  TWCSameAreaHasMatchingComparisons /\
  TWCStoredSameAreaRequiresMatchingComparisons /\ TWCSameAreaIntegerValuesMatch.

Theorem teleporter_warp_classification_boundary_checked :
  TeleporterWarpClassificationBoundary.
Proof.
  split; [exact twc_actual_classifier_has_reached_path|].
  split; [exact twc_full_body_reaches_classifier|].
  split; [exact twc_same_area_has_matching_comparisons|].
  split; [exact twc_stored_same_area_requires_matching_comparisons|].
  exact twc_same_area_integer_values_match.
Qed.
