(** Bilateral source closure for the direct designated raw-Mario-Object part of the
    different-sample installer.

    A final [update_mario_platform] query reads Object rawData.asF32[6..8].
    Therefore a collision/query mismatch can be created after Mario's normal
    State-to-Object copy only if that Object receiver is written, retargeted,
    aliased, or changed by an external effect before the final query.

    The census below recognizes the two direct generated receiver forms which
    designate Mario's Object without a separate alias argument:

    - a temporary loaded from [gMarioObject]; or
    - a temporary loaded from a typed [MarioState.marioObj] field.

    Across all 38 generated US units and all 38 generated JP units, the
    conservative direct-designated checker selects only [init_mario],
    [butterfly_calculate_angle], and [check_instant_warp].  A broader
    origin checker selects the same three, and every receiver-neutral raw-XYZ
    lvalue has the normalized temporary-Object receiver form.  The first site
    is initialization/warp reinitialization, the last is scheduled before
    [area_update_objects].  The butterfly callback's later subtraction is not
    used as a restoration argument: binary32 add-then-subtract need not be
    exact.  Static butterfly-origin exclusion is kept in the
    dependent [Area1ButterflyStaticOriginClosure] module so this foundational
    census does not repeat another whole-corpus reduction.

    This does not prove a linked memory frame.  Writes through [gCurrentObject]
    or another pointer still require receiver non-aliasing; external calls,
    forged behavior pointers, unclassified transitive dispatch, lifecycle
    retargeting, and abnormal control remain explicit residuals.

    The second half closes the explicit cached-Y=768-only alternative in the
    finite stock model: preserving collision X/Z while snapping Y to 768 keeps
    Mario inside the upper-warp hitbox, so a completed copy still queries no
    stock dynamic owner.  The exact-centre corollary uses the independently
    audited static 768 result there.  A displaced State/Graphics sample, a
    post-copy writer, or proof that another live X/Z actually selects 768 is
    deliberately outside these theorems. *)

From Coq Require Import List ZArith Lia.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_mario us_obj_behaviors us_level_update
  jp_mario jp_obj_behaviors jp_level_update.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1EntryDepthClosure Area1FirstNull Area1PlatformExhaustiveness
  Area1QueryScheduleClosure Area1WarpTopCloneCensus ClightRefinement
  PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

Module APC_USMario := us_mario.
Module APC_USObjects := us_obj_behaviors.
Module APC_USLevel := us_level_update.
Module APC_JPMario := jp_mario.
Module APC_JPObjects := jp_obj_behaviors.
Module APC_JPLevel := jp_level_update.

(** A generated expression which loads a designated Mario-Object pointer.
    The [MarioState.marioObj] case checks the receiver's generated struct tag,
    rather than accepting an unrelated field with the same atom. *)
Definition expression_loads_designated_mario_object
    (mario_object_global mario_state_tag mario_object_field : ident)
    (expression : expr) : bool :=
  match expression with
  | Evar found _ => Pos.eqb found mario_object_global
  | Efield receiver found_field _ =>
      Pos.eqb found_field mario_object_field &&
      match typeof receiver with
      | Tstruct found_tag _ => Pos.eqb found_tag mario_state_tag
      | _ => false
      end
  | _ => false
  end.

Fixpoint temp_loads_designated_mario_object_s
    (mario_object_global mario_state_tag mario_object_field temp : ident)
    (statement_value : statement) : bool :=
  match statement_value with
  | Sset found_temp rhs =>
      Pos.eqb found_temp temp &&
      expression_loads_designated_mario_object
        mario_object_global mario_state_tag mario_object_field rhs
  | Ssequence first second | Sloop first second =>
      temp_loads_designated_mario_object_s
        mario_object_global mario_state_tag mario_object_field temp first ||
      temp_loads_designated_mario_object_s
        mario_object_global mario_state_tag mario_object_field temp second
  | Sifthenelse _ yes no =>
      temp_loads_designated_mario_object_s
        mario_object_global mario_state_tag mario_object_field temp yes ||
      temp_loads_designated_mario_object_s
        mario_object_global mario_state_tag mario_object_field temp no
  | Sswitch _ cases =>
      temp_loads_designated_mario_object_ls
        mario_object_global mario_state_tag mario_object_field temp cases
  | Slabel _ body =>
      temp_loads_designated_mario_object_s
        mario_object_global mario_state_tag mario_object_field temp body
  | _ => false
  end
with temp_loads_designated_mario_object_ls
    (mario_object_global mario_state_tag mario_object_field temp : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      temp_loads_designated_mario_object_s
        mario_object_global mario_state_tag mario_object_field temp body ||
      temp_loads_designated_mario_object_ls
        mario_object_global mario_state_tag mario_object_field temp rest
  end.

Definition expression_is_raw_xyz_through_temp
    (object_tag raw_data as_f32 temp : ident) (expression : expr) : bool :=
  match expression with
  | Ederef
      (Ebinop Oadd
        (Efield
          (Efield
            (Ederef (Etempvar found_temp _) (Tstruct found_object _))
            found_raw_data _)
          found_as_f32 _)
        offset _) _ =>
      Pos.eqb found_temp temp &&
      Pos.eqb found_object object_tag &&
      Pos.eqb found_raw_data raw_data &&
      Pos.eqb found_as_f32 as_f32 &&
      match expression_const_int_z offset with
      | Some found_index =>
          existsb (fun index => Z.eqb found_index index) [6; 7; 8]
      | None => false
      end
  | _ => false
  end.

Fixpoint assigns_raw_xyz_through_temp_s
    (object_tag raw_data as_f32 temp : ident)
    (statement_value : statement) : bool :=
  match statement_value with
  | Sassign lhs _ =>
      expression_is_raw_xyz_through_temp
        object_tag raw_data as_f32 temp lhs
  | Ssequence first second | Sloop first second =>
      assigns_raw_xyz_through_temp_s object_tag raw_data as_f32 temp first ||
      assigns_raw_xyz_through_temp_s object_tag raw_data as_f32 temp second
  | Sifthenelse _ yes no =>
      assigns_raw_xyz_through_temp_s object_tag raw_data as_f32 temp yes ||
      assigns_raw_xyz_through_temp_s object_tag raw_data as_f32 temp no
  | Sswitch _ cases =>
      assigns_raw_xyz_through_temp_ls object_tag raw_data as_f32 temp cases
  | Slabel _ body =>
      assigns_raw_xyz_through_temp_s object_tag raw_data as_f32 temp body
  | _ => false
  end
with assigns_raw_xyz_through_temp_ls
    (object_tag raw_data as_f32 temp : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_raw_xyz_through_temp_s
        object_tag raw_data as_f32 temp body ||
      assigns_raw_xyz_through_temp_ls
        object_tag raw_data as_f32 temp rest
  end.

(** Linear collectors used by the whole-corpus checker.  The earlier boolean
    predicates are useful for local facts, but applying each one once per
    declared temporary rescans a large body quadratically.  These collectors
    traverse each statement once and then intersect the two short temporary
    lists. *)
Fixpoint temp_rhs_match_sites_s
    (accept_rhs : expr -> bool) (statement_value : statement) : list ident :=
  match statement_value with
  | Sset temp rhs => if accept_rhs rhs then [temp] else []
  | Ssequence first second | Sloop first second =>
      temp_rhs_match_sites_s accept_rhs first ++
      temp_rhs_match_sites_s accept_rhs second
  | Sifthenelse _ yes no =>
      temp_rhs_match_sites_s accept_rhs yes ++
      temp_rhs_match_sites_s accept_rhs no
  | Sswitch _ cases => temp_rhs_match_sites_ls accept_rhs cases
  | Slabel _ body => temp_rhs_match_sites_s accept_rhs body
  | _ => []
  end
with temp_rhs_match_sites_ls
    (accept_rhs : expr -> bool) (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      temp_rhs_match_sites_s accept_rhs body ++
      temp_rhs_match_sites_ls accept_rhs rest
  end.

Definition raw_xyz_receiver_temp
    (object_tag raw_data as_f32 : ident) (expression : expr) : option ident :=
  match expression with
  | Ederef
      (Ebinop Oadd
        (Efield
          (Efield
            (Ederef (Etempvar found_temp _) _)
            _ _)
          _ _)
        _ _) _ =>
      if expression_is_raw_xyz_through_temp
           object_tag raw_data as_f32 found_temp expression
      then Some found_temp
      else None
  | _ => None
  end.

Fixpoint raw_xyz_receiver_temp_sites_s
    (object_tag raw_data as_f32 : ident)
    (statement_value : statement) : list ident :=
  match statement_value with
  | Sassign lhs _ =>
      match raw_xyz_receiver_temp object_tag raw_data as_f32 lhs with
      | Some temp => [temp]
      | None => []
      end
  | Ssequence first second | Sloop first second =>
      raw_xyz_receiver_temp_sites_s object_tag raw_data as_f32 first ++
      raw_xyz_receiver_temp_sites_s object_tag raw_data as_f32 second
  | Sifthenelse _ yes no =>
      raw_xyz_receiver_temp_sites_s object_tag raw_data as_f32 yes ++
      raw_xyz_receiver_temp_sites_s object_tag raw_data as_f32 no
  | Sswitch _ cases =>
      raw_xyz_receiver_temp_sites_ls object_tag raw_data as_f32 cases
  | Slabel _ body =>
      raw_xyz_receiver_temp_sites_s object_tag raw_data as_f32 body
  | _ => []
  end
with raw_xyz_receiver_temp_sites_ls
    (object_tag raw_data as_f32 : ident)
    (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      raw_xyz_receiver_temp_sites_s object_tag raw_data as_f32 body ++
      raw_xyz_receiver_temp_sites_ls object_tag raw_data as_f32 rest
  end.

Definition ident_lists_intersectb
    (left right : list ident) : bool :=
  existsb (fun candidate => existsb (Pos.eqb candidate) right) left.

(** This is an intentionally conservative within-body source test.  It asks
    whether one generated temporary is ever loaded from a designated Mario
    receiver and is ever used as a raw-XYZ assignment receiver.  Reuse or
    reassignment of that temporary can add false positives, but cannot hide
    the direct generated pattern being audited. *)
Definition function_has_direct_designated_mario_raw_xyz_writer
    (mario_object_global mario_state_tag mario_object_field
      object_tag raw_data as_f32 : ident)
    (function_value : Clight.function) : bool :=
  ident_lists_intersectb
    (temp_rhs_match_sites_s
      (expression_loads_designated_mario_object
        mario_object_global mario_state_tag mario_object_field)
      (fn_body function_value))
    (raw_xyz_receiver_temp_sites_s
      object_tag raw_data as_f32 (fn_body function_value)).

(** A deliberately broader origin recognizer used to audit the narrow one.
    It accepts a designated global or [marioObj] field below casts or another
    generated expression, and does not require the [MarioState] struct tag.
    It can therefore add false positives.  Equality of the broad and narrow
    corpora below is evidence that casts and field-layout variants do not hide
    another direct generated receiver origin. *)
Definition expression_mentions_designated_mario_object_origin
    (mario_object_global mario_object_field : ident)
    (expression : expr) : bool :=
  expression_mentions_ident mario_object_global expression ||
  expression_mentions_field mario_object_field expression.

Fixpoint temp_mentions_designated_mario_object_origin_s
    (mario_object_global mario_object_field temp : ident)
    (statement_value : statement) : bool :=
  match statement_value with
  | Sset found_temp rhs =>
      Pos.eqb found_temp temp &&
      expression_mentions_designated_mario_object_origin
        mario_object_global mario_object_field rhs
  | Ssequence first second | Sloop first second =>
      temp_mentions_designated_mario_object_origin_s
        mario_object_global mario_object_field temp first ||
      temp_mentions_designated_mario_object_origin_s
        mario_object_global mario_object_field temp second
  | Sifthenelse _ yes no =>
      temp_mentions_designated_mario_object_origin_s
        mario_object_global mario_object_field temp yes ||
      temp_mentions_designated_mario_object_origin_s
        mario_object_global mario_object_field temp no
  | Sswitch _ cases =>
      temp_mentions_designated_mario_object_origin_ls
        mario_object_global mario_object_field temp cases
  | Slabel _ body =>
      temp_mentions_designated_mario_object_origin_s
        mario_object_global mario_object_field temp body
  | _ => false
  end
with temp_mentions_designated_mario_object_origin_ls
    (mario_object_global mario_object_field temp : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      temp_mentions_designated_mario_object_origin_s
        mario_object_global mario_object_field temp body ||
      temp_mentions_designated_mario_object_origin_ls
        mario_object_global mario_object_field temp rest
  end.

Definition function_has_broad_designated_mario_raw_xyz_writer
    (mario_object_global mario_object_field object_tag raw_data as_f32 : ident)
    (function_value : Clight.function) : bool :=
  ident_lists_intersectb
    (temp_rhs_match_sites_s
      (expression_mentions_designated_mario_object_origin
        mario_object_global mario_object_field)
      (fn_body function_value))
    (raw_xyz_receiver_temp_sites_s
      object_tag raw_data as_f32 (fn_body function_value)).

Definition broad_designated_mario_raw_xyz_writer_sites
    (mario_object_global mario_object_field object_tag raw_data as_f32 : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst
    (filter
      (fun entry =>
        match snd entry with
        | Gfun (Internal function_value) =>
            function_has_broad_designated_mario_raw_xyz_writer
              mario_object_global mario_object_field object_tag raw_data as_f32
              function_value
        | _ => false
        end)
      definitions).

(** Receiver-neutral raw-XYZ syntax already used elsewhere in the project,
    strengthened here with the exact generated receiver shape. *)
Definition expression_is_any_raw_xyz
    (raw_data as_f32 : ident) (expression : expr) : bool :=
  match expression with
  | Ederef
      (Ebinop Oadd
        (Efield (Efield _ found_raw_data _) found_as_f32 _)
        offset _) _ =>
      Pos.eqb found_raw_data raw_data &&
      Pos.eqb found_as_f32 as_f32 &&
      match expression_const_int_z offset with
      | Some found_index =>
          existsb (fun index => Z.eqb found_index index) [6; 7; 8]
      | None => false
      end
  | _ => false
  end.

Definition expression_is_normalized_raw_xyz_temp_receiver
    (object_tag raw_data as_f32 : ident) (expression : expr) : bool :=
  match expression with
  | Ederef
      (Ebinop Oadd
        (Efield
          (Efield
            (Ederef (Etempvar _ _) (Tstruct found_object _))
            found_raw_data _)
          found_as_f32 _)
        offset _) _ =>
      Pos.eqb found_object object_tag &&
      Pos.eqb found_raw_data raw_data &&
      Pos.eqb found_as_f32 as_f32 &&
      match expression_const_int_z offset with
      | Some found_index =>
          existsb (fun index => Z.eqb found_index index) [6; 7; 8]
      | None => false
      end
  | _ => false
  end.

Fixpoint has_unnormalized_raw_xyz_receiver_s
    (object_tag raw_data as_f32 : ident)
    (statement_value : statement) : bool :=
  match statement_value with
  | Sassign lhs _ =>
      andb
        (expression_is_any_raw_xyz raw_data as_f32 lhs)
        (negb
          (expression_is_normalized_raw_xyz_temp_receiver
            object_tag raw_data as_f32 lhs))
  | Ssequence first second | Sloop first second =>
      has_unnormalized_raw_xyz_receiver_s
        object_tag raw_data as_f32 first ||
      has_unnormalized_raw_xyz_receiver_s
        object_tag raw_data as_f32 second
  | Sifthenelse _ yes no =>
      has_unnormalized_raw_xyz_receiver_s object_tag raw_data as_f32 yes ||
      has_unnormalized_raw_xyz_receiver_s object_tag raw_data as_f32 no
  | Sswitch _ cases =>
      has_unnormalized_raw_xyz_receiver_ls
        object_tag raw_data as_f32 cases
  | Slabel _ body =>
      has_unnormalized_raw_xyz_receiver_s
        object_tag raw_data as_f32 body
  | _ => false
  end
with has_unnormalized_raw_xyz_receiver_ls
    (object_tag raw_data as_f32 : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      has_unnormalized_raw_xyz_receiver_s
        object_tag raw_data as_f32 body ||
      has_unnormalized_raw_xyz_receiver_ls
        object_tag raw_data as_f32 rest
  end.

Definition unnormalized_raw_xyz_receiver_sites
    (object_tag raw_data as_f32 : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst
    (filter
      (fun entry =>
        match snd entry with
        | Gfun (Internal function_value) =>
            has_unnormalized_raw_xyz_receiver_s
              object_tag raw_data as_f32 (fn_body function_value)
        | _ => false
        end)
      definitions).

Definition direct_designated_mario_raw_xyz_writer_sites
    (mario_object_global mario_state_tag mario_object_field
      object_tag raw_data as_f32 : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst
    (filter
      (fun entry =>
        match snd entry with
        | Gfun (Internal function_value) =>
            function_has_direct_designated_mario_raw_xyz_writer
              mario_object_global mario_state_tag mario_object_field
              object_tag raw_data as_f32 function_value
        | _ => false
        end)
      definitions).

Definition direct_designated_mario_raw_xyz_writer_sites_in_program
    (mario_object_global mario_state_tag mario_object_field
      object_tag raw_data as_f32 : ident)
    (program : Clight.program) : list ident :=
  direct_designated_mario_raw_xyz_writer_sites
    mario_object_global mario_state_tag mario_object_field
    object_tag raw_data as_f32 (prog_defs program).

Definition broad_designated_mario_raw_xyz_writer_sites_in_program
    (mario_object_global mario_object_field object_tag raw_data as_f32 : ident)
    (program : Clight.program) : list ident :=
  broad_designated_mario_raw_xyz_writer_sites
    mario_object_global mario_object_field object_tag raw_data as_f32
    (prog_defs program).

Definition unnormalized_raw_xyz_receiver_sites_in_program
    (object_tag raw_data as_f32 : ident) (program : Clight.program) : list ident :=
  unnormalized_raw_xyz_receiver_sites
    object_tag raw_data as_f32 (prog_defs program).

Definition us_direct_designated_mario_raw_xyz_writer_sites : list ident :=
  concat
    (map
      (direct_designated_mario_raw_xyz_writer_sites_in_program
        APC_USMario._gMarioObject APC_USMario._MarioState
        APC_USMario._marioObj APC_USMario._Object APC_USMario._rawData
        APC_USMario._asF32)
      us_translation_units).

Definition jp_direct_designated_mario_raw_xyz_writer_sites : list ident :=
  concat
    (map
      (direct_designated_mario_raw_xyz_writer_sites_in_program
        APC_JPMario._gMarioObject APC_JPMario._MarioState
        APC_JPMario._marioObj APC_JPMario._Object APC_JPMario._rawData
        APC_JPMario._asF32)
      jp_translation_units).

Definition us_broad_designated_mario_raw_xyz_writer_sites : list ident :=
  concat
    (map
      (broad_designated_mario_raw_xyz_writer_sites_in_program
        APC_USMario._gMarioObject APC_USMario._marioObj APC_USMario._Object
        APC_USMario._rawData APC_USMario._asF32)
      us_translation_units).

Definition jp_broad_designated_mario_raw_xyz_writer_sites : list ident :=
  concat
    (map
      (broad_designated_mario_raw_xyz_writer_sites_in_program
        APC_JPMario._gMarioObject APC_JPMario._marioObj APC_JPMario._Object
        APC_JPMario._rawData APC_JPMario._asF32)
      jp_translation_units).

Definition us_unnormalized_raw_xyz_receiver_sites : list ident :=
  concat
    (map
      (unnormalized_raw_xyz_receiver_sites_in_program
        APC_USMario._Object APC_USMario._rawData APC_USMario._asF32)
      us_translation_units).

Definition jp_unnormalized_raw_xyz_receiver_sites : list ident :=
  concat
    (map
      (unnormalized_raw_xyz_receiver_sites_in_program
        APC_JPMario._Object APC_JPMario._rawData APC_JPMario._asF32)
      jp_translation_units).

(** Program-local result vectors.  Each component is reduced in its own small
    proof below; the corpus theorem then concatenates already-checked values
    instead of normalizing one giant AST expression. *)
Definition us_direct_designated_writer_partition : list (list ident) :=
  map
    (direct_designated_mario_raw_xyz_writer_sites_in_program
      APC_USMario._gMarioObject APC_USMario._MarioState
      APC_USMario._marioObj APC_USMario._Object APC_USMario._rawData
      APC_USMario._asF32)
    us_translation_units.

Definition jp_direct_designated_writer_partition : list (list ident) :=
  map
    (direct_designated_mario_raw_xyz_writer_sites_in_program
      APC_JPMario._gMarioObject APC_JPMario._MarioState
      APC_JPMario._marioObj APC_JPMario._Object APC_JPMario._rawData
      APC_JPMario._asF32)
    jp_translation_units.

Definition us_broad_designated_writer_partition : list (list ident) :=
  map
    (broad_designated_mario_raw_xyz_writer_sites_in_program
      APC_USMario._gMarioObject APC_USMario._marioObj APC_USMario._Object
      APC_USMario._rawData APC_USMario._asF32)
    us_translation_units.

Definition jp_broad_designated_writer_partition : list (list ident) :=
  map
    (broad_designated_mario_raw_xyz_writer_sites_in_program
      APC_JPMario._gMarioObject APC_JPMario._marioObj APC_JPMario._Object
      APC_JPMario._rawData APC_JPMario._asF32)
    jp_translation_units.

Definition us_unnormalized_raw_xyz_partition : list (list ident) :=
  map
    (unnormalized_raw_xyz_receiver_sites_in_program
      APC_USMario._Object APC_USMario._rawData APC_USMario._asF32)
    us_translation_units.

Definition jp_unnormalized_raw_xyz_partition : list (list ident) :=
  map
    (unnormalized_raw_xyz_receiver_sites_in_program
      APC_JPMario._Object APC_JPMario._rawData APC_JPMario._asF32)
    jp_translation_units.

Definition us_expected_direct_designated_writer_partition : list (list ident) :=
  [[];
   [APC_USMario._init_mario];
   []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; [];
   []; [];
   [APC_USObjects._butterfly_calculate_angle];
   []; []; []; []; [APC_USLevel._check_instant_warp];
   []; []; []; []; []; []; []; []; []].

Definition jp_expected_direct_designated_writer_partition : list (list ident) :=
  [[];
   [APC_JPMario._init_mario];
   []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; [];
   []; [];
   [APC_JPObjects._butterfly_calculate_angle];
   []; []; []; []; [APC_JPLevel._check_instant_warp];
   []; []; []; []; []; []; []; []; []].

Definition empty_38_ident_partitions : list (list ident) :=
  map (fun _ : Clight.program => []) us_translation_units.

Ltac solve_program_partition :=
  unfold us_direct_designated_writer_partition,
    jp_direct_designated_writer_partition,
    us_broad_designated_writer_partition,
    jp_broad_designated_writer_partition,
    us_unnormalized_raw_xyz_partition,
    jp_unnormalized_raw_xyz_partition,
    us_expected_direct_designated_writer_partition,
    jp_expected_direct_designated_writer_partition,
    empty_38_ident_partitions,
    us_translation_units, jp_translation_units;
  cbn [map];
  repeat match goal with
  | |- @eq (list _) (_ :: _) (_ :: _) =>
      apply f_equal2; [vm_compute; reflexivity |]
  end;
  reflexivity.

Theorem us_direct_designated_writer_partition_checked :
  us_direct_designated_writer_partition =
    us_expected_direct_designated_writer_partition.
Proof. solve_program_partition. Qed.

Theorem jp_direct_designated_writer_partition_checked :
  jp_direct_designated_writer_partition =
    jp_expected_direct_designated_writer_partition.
Proof. solve_program_partition. Qed.

Theorem us_broad_designated_writer_partition_checked :
  us_broad_designated_writer_partition =
    us_expected_direct_designated_writer_partition.
Proof. solve_program_partition. Qed.

Theorem jp_broad_designated_writer_partition_checked :
  jp_broad_designated_writer_partition =
    jp_expected_direct_designated_writer_partition.
Proof. solve_program_partition. Qed.

Theorem us_raw_xyz_receiver_normalization_partition_checked :
  us_unnormalized_raw_xyz_partition = empty_38_ident_partitions.
Proof. solve_program_partition. Qed.

Theorem jp_raw_xyz_receiver_normalization_partition_checked :
  jp_unnormalized_raw_xyz_partition = empty_38_ident_partitions.
Proof. solve_program_partition. Qed.

Theorem us_direct_designated_mario_raw_xyz_writer_census :
  us_direct_designated_mario_raw_xyz_writer_sites =
    [APC_USMario._init_mario;
     APC_USObjects._butterfly_calculate_angle;
     APC_USLevel._check_instant_warp].
Proof.
  change
    (concat us_direct_designated_writer_partition =
      [APC_USMario._init_mario;
       APC_USObjects._butterfly_calculate_angle;
       APC_USLevel._check_instant_warp]).
  rewrite us_direct_designated_writer_partition_checked.
  reflexivity.
Qed.

Theorem jp_direct_designated_mario_raw_xyz_writer_census :
  jp_direct_designated_mario_raw_xyz_writer_sites =
    [APC_JPMario._init_mario;
     APC_JPObjects._butterfly_calculate_angle;
     APC_JPLevel._check_instant_warp].
Proof.
  change
    (concat jp_direct_designated_writer_partition =
      [APC_JPMario._init_mario;
       APC_JPObjects._butterfly_calculate_angle;
       APC_JPLevel._check_instant_warp]).
  rewrite jp_direct_designated_writer_partition_checked.
  reflexivity.
Qed.

(** Corpus-wide normalization receipts.  These rule out a hidden direct
    [gMarioObject] or [marioObj] writer caused merely by a cast, alternate
    field spelling, or a non-temporary receiver in the generated AST.  They
    do not rule out writes through a genuinely different alias origin. *)
Theorem us_direct_writer_origin_and_receiver_normalization_census :
  us_broad_designated_mario_raw_xyz_writer_sites =
    us_direct_designated_mario_raw_xyz_writer_sites /\
  us_unnormalized_raw_xyz_receiver_sites = [].
Proof.
  change
    (concat us_broad_designated_writer_partition =
       concat us_direct_designated_writer_partition /\
     concat us_unnormalized_raw_xyz_partition = []).
  rewrite us_broad_designated_writer_partition_checked,
    us_direct_designated_writer_partition_checked,
    us_raw_xyz_receiver_normalization_partition_checked.
  split; reflexivity.
Qed.

Theorem jp_direct_writer_origin_and_receiver_normalization_census :
  jp_broad_designated_mario_raw_xyz_writer_sites =
    jp_direct_designated_mario_raw_xyz_writer_sites /\
  jp_unnormalized_raw_xyz_receiver_sites = [].
Proof.
  change
    (concat jp_broad_designated_writer_partition =
       concat jp_direct_designated_writer_partition /\
     concat jp_unnormalized_raw_xyz_partition = []).
  rewrite jp_broad_designated_writer_partition_checked,
    jp_direct_designated_writer_partition_checked,
    jp_raw_xyz_receiver_normalization_partition_checked.
  split; reflexivity.
Qed.

Theorem us_postcopy_direct_designated_writer_reduces_to_butterfly :
  forall writer,
    In writer us_direct_designated_mario_raw_xyz_writer_sites ->
    writer <> APC_USMario._init_mario ->
    writer <> APC_USLevel._check_instant_warp ->
    writer = APC_USObjects._butterfly_calculate_angle.
Proof.
  intros writer Hwriter Hnot_init Hnot_instant.
  rewrite us_direct_designated_mario_raw_xyz_writer_census in Hwriter.
  cbn in Hwriter. intuition congruence.
Qed.

Theorem jp_postcopy_direct_designated_writer_reduces_to_butterfly :
  forall writer,
    In writer jp_direct_designated_mario_raw_xyz_writer_sites ->
    writer <> APC_JPMario._init_mario ->
    writer <> APC_JPLevel._check_instant_warp ->
    writer = APC_JPObjects._butterfly_calculate_angle.
Proof.
  intros writer Hwriter Hnot_init Hnot_instant.
  rewrite jp_direct_designated_mario_raw_xyz_writer_census in Hwriter.
  cbn in Hwriter. intuition congruence.
Qed.

(** The source corpus confines direct [init_mario] call sites to the three
    initialization/warp routines shown below.  In a normal active frame,
    [warp_area] and [check_instant_warp] both precede the object update
    containing Mario's copy and final platform query.  These receipts are only
    direct-call/caller syntax facts, not a linked execution or return proof. *)
Definition postcopy_direct_writer_phase_source_claim : Prop :=
  ident_subsequenceb
    [APC_USLevel._warp_area;
     APC_USLevel._check_instant_warp;
     APC_USLevel._area_update_objects]
    (direct_callees_s (fn_body APC_USLevel.f_play_mode_normal)) = true /\
  ident_subsequenceb
    [APC_JPLevel._warp_area;
     APC_JPLevel._check_instant_warp;
     APC_JPLevel._area_update_objects]
    (direct_callees_s (fn_body APC_JPLevel.f_play_mode_normal)) = true.

Theorem postcopy_direct_writer_phase_source_checked :
  postcopy_direct_writer_phase_source_claim.
Proof.
  unfold postcopy_direct_writer_phase_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Cached-floor-only closure at the audited exact centre *)

Lemma schedule_position_extensionality :
  forall left right,
    schedule_x left = schedule_x right ->
    schedule_y left = schedule_y right ->
    schedule_z left = schedule_z right ->
    left = right.
Proof.
  intros [lx ly lz] [rx ry rz]; cbn.
  intros; now subst.
Qed.

Theorem cached_floor_snap_at_collision_height_preserves_query_sample :
  forall schedule,
    schedule_state_at_selection schedule =
      schedule_collision_object schedule ->
    schedule_y (schedule_state_after_disappeared schedule) =
      schedule_y (schedule_collision_object schedule) ->
    schedule_final_query schedule = schedule_object_after_copy schedule ->
    schedule_final_query schedule = schedule_collision_object schedule.
Proof.
  intros schedule Hselection Hy Hquery.
  rewrite Hquery, schedule_copy_synchronizes_object.
  apply schedule_position_extensionality.
  - destruct (schedule_disappeared_continuation schedule) as
      [Hunchanged | cached_y Hx _ Hz].
    + now rewrite Hunchanged, Hselection.
    + now rewrite Hx, Hselection.
  - exact Hy.
  - destruct (schedule_disappeared_continuation schedule) as
      [Hunchanged | cached_y Hx _ Hz].
    + now rewrite Hunchanged, Hselection.
    + now rewrite Hz, Hselection.
Qed.

Definition position_z_of_schedule (position : SchedulePosition) : PositionZ :=
  {| position_x := schedule_x position;
     position_y := schedule_y position;
     position_z := schedule_z position |}.

Lemma upper_warp_center_contact_checked :
  upper_warp_contact upper_warp_center.
Proof.
  unfold upper_warp_contact, horizontal_distance_squared,
    upper_warp_center, upper_warp_radius, mario_hitbox_radius,
    upper_warp_y, upper_warp_height, mario_hitbox_height.
  cbn. repeat split; lia.
Qed.

(** Pure geometry fact for an explicitly supplied cached value.  Replacing Y
    by 768 cannot spoil an upper-warp contact when X and Z are preserved.  No
    claim is made here that a live floor query returns 768 at every X/Z in the
    warp envelope. *)
Lemma explicit_cached_y_768_preserves_upper_warp_contact :
  forall before after,
    upper_warp_contact (position_z_of_schedule before) ->
    schedule_x after = schedule_x before ->
    schedule_y after = 768 ->
    schedule_z after = schedule_z before ->
    upper_warp_contact (position_z_of_schedule after).
Proof.
  intros before after Hcontact Hx Hy Hz.
  unfold upper_warp_contact in *.
  destruct Hcontact as (Hhorizontal & _ & _).
  repeat split.
  - unfold horizontal_distance_squared in *.
    cbn in *.
    now rewrite Hx, Hz.
  - cbn. rewrite Hy.
    unfold upper_warp_y, upper_warp_height. lia.
  - cbn. rewrite Hy.
    unfold upper_warp_y, mario_hitbox_height. lia.
Qed.

(** Complete closure of the *explicit cached-Y=768 only* subcase.  State at
    selection must still be the collision sample and the final query must
    still read the completed copy.  Establishing a 768 live cached floor at a
    displaced horizontal point is outside this theorem. *)
Theorem explicit_cached_y_768_only_stock_query_is_null :
  forall schedule platform,
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    schedule_state_at_selection schedule =
      schedule_collision_object schedule ->
    schedule_y (schedule_state_after_disappeared schedule) = 768 ->
    schedule_final_query schedule = schedule_object_after_copy schedule ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule)) platform ->
    platform = None.
Proof.
  intros schedule platform Hcontact Hselection Hy Hquery Hstock.
  assert (Hx :
    schedule_x (schedule_final_query schedule) =
      schedule_x (schedule_collision_object schedule)).
  { rewrite Hquery, schedule_copy_synchronizes_object.
    destruct (schedule_disappeared_continuation schedule) as
      [Hunchanged | cached_y Hsame_x _ _].
    - now rewrite Hunchanged, Hselection.
    - now rewrite Hsame_x, Hselection. }
  assert (Hfinal_y :
    schedule_y (schedule_final_query schedule) = 768).
  { now rewrite Hquery, schedule_copy_synchronizes_object. }
  assert (Hz :
    schedule_z (schedule_final_query schedule) =
      schedule_z (schedule_collision_object schedule)).
  { rewrite Hquery, schedule_copy_synchronizes_object.
    destruct (schedule_disappeared_continuation schedule) as
      [Hunchanged | cached_y _ _ Hsame_z].
    - now rewrite Hunchanged, Hselection.
    - now rewrite Hsame_z, Hselection. }
  apply (stock_upper_warp_final_query_clears_platform
    (position_z_of_schedule (schedule_final_query schedule)) platform).
  - eapply explicit_cached_y_768_preserves_upper_warp_contact; eauto.
  - exact Hstock.
Qed.

(** At the exact centre, the generated static collision evaluator independently
    records the selected floor as binary32 768.0f.  Under the explicit bridge
    from that receipt to the schedule's cached Y, the snap cannot create a
    different final sample, and the finite stock dynamic-owner projection
    forces the platform result to [None]. *)
Theorem exact_center_cached_floor_only_stock_query_is_null :
  forall schedule platform,
    schedule_collision_object schedule =
      schedule_upper_warp_center ->
    schedule_state_at_selection schedule =
      schedule_collision_object schedule ->
    schedule_y (schedule_state_after_disappeared schedule) = 768 ->
    schedule_final_query schedule = schedule_object_after_copy schedule ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule)) platform ->
    platform = None.
Proof.
  intros schedule platform Hcollision Hselection Hy Hquery Hstock.
  assert (Hcollision_y :
    schedule_y (schedule_collision_object schedule) = 768).
  { rewrite Hcollision. reflexivity. }
  assert (Hsame :
    schedule_final_query schedule = schedule_collision_object schedule).
  { apply cached_floor_snap_at_collision_height_preserves_query_sample;
      try assumption.
    now rewrite Hy, Hcollision_y. }
  apply (stock_upper_warp_final_query_clears_platform
    (position_z_of_schedule (schedule_final_query schedule)) platform).
  - rewrite Hsame, Hcollision.
    exact upper_warp_center_contact_checked.
  - exact Hstock.
Qed.

Definition Area1PostCopyDirectDesignatedObjectWriterCheckedBoundary : Prop :=
  us_direct_designated_mario_raw_xyz_writer_sites =
    [APC_USMario._init_mario;
     APC_USObjects._butterfly_calculate_angle;
     APC_USLevel._check_instant_warp] /\
  jp_direct_designated_mario_raw_xyz_writer_sites =
    [APC_JPMario._init_mario;
     APC_JPObjects._butterfly_calculate_angle;
     APC_JPLevel._check_instant_warp] /\
  us_broad_designated_mario_raw_xyz_writer_sites =
    us_direct_designated_mario_raw_xyz_writer_sites /\
  jp_broad_designated_mario_raw_xyz_writer_sites =
    jp_direct_designated_mario_raw_xyz_writer_sites /\
  us_unnormalized_raw_xyz_receiver_sites = [] /\
  jp_unnormalized_raw_xyz_receiver_sites = [] /\
  postcopy_direct_writer_phase_source_claim.

Theorem area1_postcopy_direct_designated_object_writer_checked_boundary_holds :
  Area1PostCopyDirectDesignatedObjectWriterCheckedBoundary.
Proof.
  unfold Area1PostCopyDirectDesignatedObjectWriterCheckedBoundary.
  split; [exact us_direct_designated_mario_raw_xyz_writer_census |].
  split; [exact jp_direct_designated_mario_raw_xyz_writer_census |].
  pose proof
    us_direct_writer_origin_and_receiver_normalization_census as
    (Hus_broad & Hus_receiver).
  pose proof
    jp_direct_writer_origin_and_receiver_normalization_census as
    (Hjp_broad & Hjp_receiver).
  split; [exact Hus_broad |].
  split; [exact Hjp_broad |].
  split; [exact Hus_receiver |].
  split; [exact Hjp_receiver |].
  exact postcopy_direct_writer_phase_source_checked.
Qed.
