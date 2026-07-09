(* ======================================================================= *)
(*  GOAL-2 PLAYGROUND — T1: WMotR platform-displacement inertness.          *)
(*                                                                          *)
(*  THIS FILE IS A SANDBOX (same regime as FramePlayground.v): outside      *)
(*  proofs/, NOT in _CoqProject, invisible to `make proofs` and to the      *)
(*  discipline audit.  Compile by hand:                                     *)
(*                                                                          *)
(*    source pipeline/env.sh                                                *)
(*    coqc -time -R generated SM64.Generated -R proofs SM64.Proofs \        *)
(*         playground/PlatformInert.v                                       *)
(*                                                                          *)
(*  Track T1 of docs/goal2-real-frame-plan.md: the `seg_platform` segment   *)
(*  of the GOAL-2 frame composition (plan §0) is the memory transition of   *)
(*    apply_mario_platform_displacement()   platform_displacement.c:171-178 *)
(*  which lives in an UN-clightgen'd TU.  So the deliverable here is NOT a  *)
(*  body walk — it is (i) the mechanically-checked SYMBOL SITUATION, (ii)   *)
(*  the named SPEC for the segment, (iii) the WMotR grounding census with   *)
(*  every load-bearing C fact cited, and (iv) the PROVED glue lemmas that   *)
(*  the T0 frame skeleton will consume.  See the (* STATUS *) footer for    *)
(*  the honest proved-vs-premise ledger.                                    *)
(* ======================================================================= *)

From Coq Require Import String List ZArith Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight Clightdefs.
Import Clightdefs.ClightNotations.
From Flocq Require Import Binary.

From SM64.Generated Require mario mario_actions_stationary mario_actions_moving
  mario_actions_airborne mario_actions_submerged mario_actions_cutscene
  mario_actions_automatic mario_actions_object interaction behavior_actions
  level_update mario_step mario_misc math_util shadow surface_collision toy.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame.

Import ListNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.
Local Open Scope clight_scope.

(* ======================================================================= *)
(*  §1  THE SYMBOL SITUATION (mechanically checked below)                   *)
(*                                                                          *)
(*  Question: is `gMarioPlatform` a Gvar / an extern decl / absent in the   *)
(*  generated TUs?  Answer: ABSENT — from every one of the 17 generated     *)
(*  TUs (the linked 12 of LinkedTwelve.v plus mario_misc, math_util,        *)
(*  shadow, surface_collision, toy).  clightgen only emits declarations a   *)
(*  TU references, and no generated TU references gMarioPlatform: the only  *)
(*  readers/writers are in the un-generated platform_displacement.c         *)
(*  (init :16, writes :53/:59/:62/:184, read :172).                         *)
(*                                                                          *)
(*  CONSEQUENCE: the NULL-invariant is NOT statable via Genv.find_symbol    *)
(*  over lp (the symbol does not exist in lp's genv).  We therefore         *)
(*  PARAMETERIZE over an abstract block `bpf` — exactly the precedent of    *)
(*  bm (Mario's MarioState block, a runtime block, not a mario.prog         *)
(*  global; see memory `bm-is-a-runtime-block`).  When platform_displace-   *)
(*  ment.c is eventually clightgen'd+linked, `bpf` becomes                  *)
(*  `find_symbol lp _gMarioPlatform` and these lemmas apply verbatim.       *)
(*                                                                          *)
(*  Related pins (also checked): the whole OUTER chain                      *)
(*  `apply_mario_platform_displacement` / `update_mario_platform` is        *)
(*  absent from every generated TU; the INNER displacement body             *)
(*  `apply_platform_displacement` occurs exactly once in the generated set  *)
(*  — as an EXTERNAL decl in behavior_actions (the object-side isMario=0    *)
(*  call from bowser.inc.c, behavior_actions.v:112405) — never Internal.    *)
(* ======================================================================= *)

(* gMarioPlatform's ident, by the same string→positive encoding clightgen
   uses; if any TU had emitted the symbol, this is the ident it would own. *)
Definition _gMarioPlatform : ident := $"gMarioPlatform".
Definition _update_mario_platform : ident := $"update_mario_platform".
Definition _apply_mario_platform_displacement : ident :=
  $"apply_mario_platform_displacement".

Definition has_symbol (p : Clight.program) (id : ident) : bool :=
  existsb (fun d => Pos.eqb (fst d) id) (prog_defs p).

Definition generated_tus : list Clight.program :=
  [ mario.prog;
    mario_actions_stationary.prog; mario_actions_moving.prog;
    mario_actions_airborne.prog; mario_actions_submerged.prog;
    mario_actions_cutscene.prog; mario_actions_automatic.prog;
    mario_actions_object.prog; interaction.prog; behavior_actions.prog;
    level_update.prog; mario_step.prog;
    (* generated but not in the linked 12: *)
    mario_misc.prog; math_util.prog; shadow.prog; surface_collision.prog;
    toy.prog ].

(* The platform chain is INVISIBLE to the generated set: neither the global
   cell nor the two outer functions exist in any generated TU. *)
Lemma platform_chain_absent_everywhere :
  forallb (fun id => forallb (fun p => negb (has_symbol p id)) generated_tus)
    [_gMarioPlatform; _update_mario_platform;
     _apply_mario_platform_displacement] = true.
Proof. vm_compute. reflexivity. Qed.

(* The inner displacement body appears in the generated set exactly once,
   and only as an External decl (no Internal body anywhere). *)
Lemma apply_platform_displacement_external_only :
  match filter (fun d =>
          Pos.eqb (fst d) behavior_actions._apply_platform_displacement)
        (prog_defs behavior_actions.prog) with
  | (_, Gfun (Ctypes.External (EF_external n _) _ _ _)) :: nil =>
      String.eqb n "apply_platform_displacement"
  | _ => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma apply_platform_displacement_absent_elsewhere :
  forallb (fun p =>
      negb (has_symbol p behavior_actions._apply_platform_displacement))
    [ mario.prog;
      mario_actions_stationary.prog; mario_actions_moving.prog;
      mario_actions_airborne.prog; mario_actions_submerged.prog;
      mario_actions_cutscene.prog; mario_actions_automatic.prog;
      mario_actions_object.prog; interaction.prog;
      level_update.prog; mario_step.prog;
      mario_misc.prog; math_util.prog; shadow.prog; surface_collision.prog;
      toy.prog ] = true.
Proof. vm_compute. reflexivity. Qed.

(* The exclamation-box solid-state handler — the ONLY WMotR behavior that
   loads an object collision model (E1 §2) — is an INTERNAL body in the
   LINKED behavior_actions TU.  This matters for the discharge path (§5):
   the "boxes are motionless" premise is walkable TODAY, without any new
   clightgen. *)
Lemma exclamation_box_act2_internal_in_linked_tu :
  match filter (fun d =>
          Pos.eqb (fst d) behavior_actions._exclamation_box_act_2)
        (prog_defs behavior_actions.prog) with
  | (_, Gfun (Ctypes.Internal _)) :: nil => true
  | _ => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

(* ======================================================================= *)
(*  §2  THE TRACKED CELLS, pinned to the generated AST                      *)
(*      (PIPELINE-not-bespoke: offsets come from prog_comp_env, never       *)
(*      hand-written)                                                       *)
(* ======================================================================= *)

(* pos is a member of the real MarioState composite; its byte offset comes
   from the generated composite env.  pos : tarray tfloat 3, so pos[1] (y)
   sits 4 bytes past the base. *)
Definition pos_field_offset : option Z :=
  match field_offset (prog_comp_env mario.prog) mario._pos mario_state_members
  with
  | Errors.OK (d, _) => Some d
  | Errors.Error _ => None
  end.

Definition POSY : Z := 64.   (* pos base 60 + 4 = pos[1], Mario's y *)

Lemma POSY_from_pipeline : pos_field_offset = Some (POSY - 4).
Proof. vm_compute. reflexivity. Qed.

(* The action cell (bm,12,4 bytes) and action_sat are GOAL-1's, imported
   from ActionValueFrame — NOT redefined here. *)

(* The y-cell as a watched byte-set, mirroring action_cell's shape. *)
Definition pos_y_cell (bm : block) : block -> Z -> Prop :=
  fun b o => b = bm /\ POSY <= o < POSY + size_chunk Mfloat32.

(* The GOAL-2 height invariant on a memory (the analog of action_sat):
   whatever binary32 the y-cell holds has real value <= YMAX. *)
Definition y_le (YMAX : R) (m : mem) (bm : block) : Prop :=
  forall v, Mem.load Mfloat32 m bm POSY = Some (Vsingle v) ->
            (B2R 24 128 v <= YMAX)%R.

(* ======================================================================= *)
(*  §3  THE NULL-CELL PREDICATE AND THE SEGMENT SPEC                        *)
(* ======================================================================= *)

(* "The gMarioPlatform cell holds NULL."  bpf is the abstract block of the
   4-byte pointer cell (§1: not a linked global, so abstract — the bm
   precedent).  Mind ptr64=false (ppc32/N64 target): Mptr = Mint32 and
   Vnullptr = Vint Int.zero — pinned by the lemma below, so downstream
   users can work at the Mint32 level. *)
Definition platform_cell_null (m : mem) (bpf : block) : Prop :=
  Mem.loadv Mptr m (Vptr bpf Ptrofs.zero) = Some Vnullptr.

Lemma platform_cell_null_load :
  forall m bpf,
    platform_cell_null m bpf <-> Mem.load Mint32 m bpf 0 = Some (Vint Int.zero).
Proof.
  intros m bpf. unfold platform_cell_null.
  replace Mptr with Mint32 by (vm_compute; reflexivity).
  replace Vnullptr with (Vint Int.zero) by (vm_compute; reflexivity).
  simpl. rewrite Ptrofs.unsigned_zero. tauto.
Qed.

(* THE NAMED SEGMENT SPEC (the honest un-clightgen'd-TU boundary row).
   seg_platform is the memory transition of one call to
   apply_mario_platform_displacement() (platform_displacement.c:171-178):

       void apply_mario_platform_displacement(void) {
           struct Object *platform = gMarioPlatform;
           if (!(gTimeStopState & TIME_STOP_ACTIVE) && gMarioObject != NULL
               && platform != NULL) {                       // line 174
               apply_platform_displacement(TRUE, platform);
           }
       }

   SPEC (NULL case): if the gMarioPlatform cell holds NULL, the guard at
   line 174 fails, the body executes NO store at all, and memory is
   unchanged — in particular on Mario's block bm and on the cell bpf
   itself.  (The full body is store-free on this path: it performs two
   loads (gTimeStopState, gMarioObject) and the platform load, then
   returns.  unchanged_on {bm,bpf} is a sound under-approximation of
   "unchanged everywhere"; we only ever consume these two blocks.)

   This Definition IS the boundary premise BP-SEG-NULL of the STATUS
   footer: T0 will assume every frame's platform phase satisfies it.
   It cannot be PROVED here because the body is not in any generated TU
   (§1) — discharging it = clightgen'ing platform_displacement.c and
   walking the 8-line body (§5). *)
Definition seg_platform_spec (bpf bm : block) (m m' : mem) : Prop :=
  platform_cell_null m bpf ->
  Mem.unchanged_on (fun b _ => b = bm \/ b = bpf) m m'.

(* The WIDENED consumable spec (see §4 for why WMotR needs it): whatever
   the platform phase did, the y-cell and action-cell LOADS are unchanged.
   The NULL case implies it (proved: yact_inert_of_null); the WMotR box
   case satisfies it by the y-identity argument (§4, boundary premise
   BP-SEG-BOX). *)
Definition seg_platform_yact_inert (bm : block) (m m' : mem) : Prop :=
  Mem.load Mfloat32 m' bm POSY = Mem.load Mfloat32 m bm POSY
  /\ Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12.

(* ======================================================================= *)
(*  §4  THE WMOTR GROUNDING — the invariant census (documented, cited)      *)
(*                                                                          *)
(*  Claim to ground: the platform phase never changes Mario's y or action   *)
(*  in WMotR.  The plan (goal2-real-frame-plan.md §1) grounds this via      *)
(*  "gMarioPlatform ≡ NULL every frame".  The census below GROUNDS THE     *)
(*  CONCLUSION but CORRECTS THE INVARIANT — the blanket NULL claim is       *)
(*  FALSE in WMotR.                                                         *)
(*                                                                          *)
(*  (a) INIT.  gMarioPlatform starts NULL: platform_displacement.c:16       *)
(*      `struct Object *gMarioPlatform = NULL;` — a static initializer in   *)
(*      the UN-generated TU, so it is NOT citable as a gvar_init in         *)
(*      generated/ (contrast: if the TU were linked we would pin            *)
(*      `gvar_init = [Init_int32 Int.zero]` mechanically).  BOUNDARY        *)
(*      PREMISE BP-INIT.                                                    *)
(*                                                                          *)
(*  (b) WRITERS.  The complete writer set of gMarioPlatform (whole-tree     *)
(*      grep of vendor/sm64/src, 2026-07-09):                               *)
(*        platform_displacement.c:53   = NULL   (|marioY-floorHeight| >= 4) *)
(*        platform_displacement.c:59   = floor->object   (THE only          *)
(*             non-NULL write; guarded by floor != NULL &&                  *)
(*             floor->object != NULL && |marioY - floorHeight| < 4)         *)
(*        platform_displacement.c:62   = NULL   (floor static / no floor)   *)
(*        platform_displacement.c:184  = NULL   (clear_mario_platform)      *)
(*      All in update_mario_platform (:22-67) / clear_mario_platform        *)
(*      (:183-185), both un-generated.  So non-NULL requires a floor        *)
(*      surface with object != NULL — a DYNAMIC surface.                    *)
(*                                                                          *)
(*  (c) WMOTR DYNAMIC SURFACES — THE CORRECTION.  The scout                 *)
(*      (goal2-frame-boundary-scout.md §4) and the plan claim WMotR has     *)
(*      "no dynamic-surface objects at all".  That is true of the TERRAIN   *)
(*      mesh (one static block, collision.inc.c; every static surface has   *)
(*      object == NULL) but FALSE for the level: the E1 inventory           *)
(*      (goal2-wmotr-inventory-e1.md §2) shows the 6 macro_box_wing_cap     *)
(*      exclamation boxes (macro.inc.c:15-20) each load the box collision   *)
(*      model in their solid state (exclamation_box.inc.c:101,             *)
(*      load_object_collision_model, oAction == 2 only), producing dynamic  *)
(*      floors with object != NULL (surface_load.c:715 flags them           *)
(*      SURFACE_FLAG_DYNAMIC and stamps surface->object).  Box tops sit at  *)
(*      y = 2012, -1028, -2428, 572, 4932, 2372; THREE of them (-1028,      *)
(*      -2428, 572) are BELOW the 1669 spawn floor and reachable no-A by    *)
(*      falling.  Mario standing on one (|marioY - floorHeight| < 4)        *)
(*      makes writer (b):59 fire ⇒ gMarioPlatform = that box ≠ NULL.        *)
(*      ⇒ "gMarioPlatform ≡ NULL every frame" is NOT a WMotR invariant.     *)
(*      The honest maintainable invariant is:                               *)
(*                                                                          *)
(*        gMarioPlatform ∈ {NULL} ∪ {the 6 bhvExclamationBox objects}       *)
(*                                                                          *)
(*      (only bhvExclamationBox calls load_object_collision_model among     *)
(*      WMotR's objects — E1 §2's census, reconfirmed by the squish         *)
(*      census.)  BOUNDARY PREMISE BP-SURF-OBJ covers the provenance        *)
(*      "floor->object != NULL only for box surfaces" (surface_load.c is    *)
(*      un-generated).                                                      *)
(*                                                                          *)
(*  (d) THE BOX CASE IS STILL Y-INERT.  apply_platform_displacement         *)
(*      (platform_displacement.c:91-167) writes y ONLY in its rotation      *)
(*      branch:                                                             *)
(*        - linear branch (:120-121): x += oVelX; z += oVelZ — NO oVelY     *)
(*          term, y passes through untouched;                               *)
(*        - rotation branch (:123-157): recomputes x,y,z — GUARDED by       *)
(*          oAngleVelPitch|Yaw|Roll != 0 (:123); also the only faceAngle    *)
(*          write (:129);                                                   *)
(*        - commit (:160): set_mario_pos(x,y,z) → stores pos[0..2]          *)
(*          (:81-85).                                                       *)
(*      The exclamation box NEVER writes oVelX/oVelZ/oAngleVel*: the full   *)
(*      grep of exclamation_box.inc.c shows only oVelY:=30/oGravity:=-8 on  *)
(*      the break transition (:92-93, which also leaves the solid state,    *)
(*      making the box intangible and unloading its collision) and the      *)
(*      spawned CONTENTS' velocities (:133-134, a different object); and    *)
(*      object rawData is zero-initialized at allocation                    *)
(*      (spawn_object.c:247,252).  So a ridden box has                      *)
(*      oVelX = oVelZ = oAngleVel* = 0, the rotation branch is skipped,     *)
(*      and the commit stores back the LOADED y: a y-IDENTITY write, with   *)
(*      action and faceAngle untouched.  (The pos[1] STORE does happen —    *)
(*      this is why the consumable spec is "the y-cell LOAD is unchanged",  *)
(*      seg_platform_yact_inert, not "no store".)  BOUNDARY PREMISE         *)
(*      BP-SEG-BOX; its box-motionlessness half is walkable TODAY against   *)
(*      f_exclamation_box_act_2 in the LINKED behavior_actions TU (pinned   *)
(*      in §1) — the store-through-set_mario_pos half still needs the       *)
(*      un-generated TU.                                                    *)
(*                                                                          *)
(*  WHAT COULD NOT BE ENCODED IN COQ (and why): WMotR's level script,       *)
(*  macro-object table and collision mesh (levels/wmotr/script.c,           *)
(*  macro.inc.c, areas/1/collision.inc.c) are DATA in TUs that were never   *)
(*  clightgen'd — no generated TU contains them (the generated set is game  *)
(*  code only, §1).  So 'the only collision-model loader in WMotR is the    *)
(*  exclamation box' and the box-top y list stay DOCUMENTED premises from   *)
(*  the E1 inventory, not vm_compute facts.  What IS encoded: the symbol    *)
(*  pins of §1 (absence / External-only / the box handler being Internal    *)
(*  in a linked TU), the offsets of §2, and every glue lemma of §5.         *)
(* ======================================================================= *)

(* ======================================================================= *)
(*  §5  THE PROVED GLUE (what T0 consumes)                                  *)
(* ======================================================================= *)

(* NULL case ⇒ the widened inert spec.  (valid_block bm: standard; GOAL-1
   carries it through every frame.) *)
Lemma yact_inert_of_null :
  forall bpf bm m m',
    Mem.valid_block m bm ->
    platform_cell_null m bpf ->
    seg_platform_spec bpf bm m m' ->
    seg_platform_yact_inert bm m m'.
Proof.
  intros bpf bm m m' Hvb Hnull Hspec.
  specialize (Hspec Hnull).
  split; eapply Mem.load_unchanged_on_1; eauto; simpl; intros; auto.
Qed.

(* The NULL cell survives the (no-op) segment: the invariant carry for the
   NULL case.  (The carry across the REST of the frame — update_mario_
   platform re-deciding the cell — is BP-SURF-OBJ + the (c) census, not
   this lemma.) *)
Lemma platform_null_carry :
  forall bpf bm m m',
    Mem.valid_block m bpf ->
    platform_cell_null m bpf ->
    seg_platform_spec bpf bm m m' ->
    platform_cell_null m' bpf.
Proof.
  intros bpf bm m m' Hvb Hnull Hspec.
  specialize (Hspec Hnull).
  apply platform_cell_null_load.
  apply platform_cell_null_load in Hnull.
  assert (E : Mem.load Mint32 m' bpf 0 = Mem.load Mint32 m bpf 0).
  { apply (Mem.load_unchanged_on_1 _ m m' Mint32 bpf 0 Hspec Hvb).
    simpl; intros; auto. }
  rewrite E. exact Hnull.
Qed.

(* The widened spec transfers BOTH GOAL-2's y-bound and GOAL-1's action
   invariant across the segment — this is the exact shape the T0 skeleton
   composes per frame (and it serves the box case too, once BP-SEG-BOX
   concludes seg_platform_yact_inert). *)
Lemma transfer_of_yact_inert :
  forall (YMAX : R) (Q : int -> Prop) bm m m',
    seg_platform_yact_inert bm m m' ->
    (y_le YMAX m bm <-> y_le YMAX m' bm)
    /\ (action_sat Q m bm <-> action_sat Q m' bm).
Proof.
  intros YMAX Q bm m m' [Hy Ha].
  split; split; intros H v Hl; apply H; congruence.
Qed.

(* THE COMPOSED LEMMA (task item 4): NULL cell + segment spec ⇒ the y-bound
   is equi-satisfied, the action cell is untouched, and the NULL cell
   persists.  Direct from unchanged_on; no admits. *)
Lemma seg_platform_transfer :
  forall (YMAX : R) (Q : int -> Prop) bpf bm m m',
    Mem.valid_block m bm ->
    Mem.valid_block m bpf ->
    platform_cell_null m bpf ->
    seg_platform_spec bpf bm m m' ->
    (y_le YMAX m bm <-> y_le YMAX m' bm)
    /\ (action_sat Q m bm <-> action_sat Q m' bm)
    /\ platform_cell_null m' bpf.
Proof.
  intros YMAX Q bpf bm m m' Hvbm Hvbp Hnull Hspec.
  destruct (transfer_of_yact_inert YMAX Q bm m m'
              (yact_inert_of_null bpf bm m m' Hvbm Hnull Hspec)) as [Hy Ha].
  split; [exact Hy | split; [exact Ha |]].
  eapply platform_null_carry; eauto.
Qed.

(* ======================================================================= *)
(*  (* STATUS *)  — the honest ledger                                       *)
(*                                                                          *)
(*  PROVED IN THIS FILE (Qed, no admits, no new axioms):                    *)
(*    - platform_chain_absent_everywhere: gMarioPlatform /                  *)
(*      update_mario_platform / apply_mario_platform_displacement exist in  *)
(*      NO generated TU (all 17) — so bpf must be an abstract block (the    *)
(*      bm precedent), not a find_symbol.                                   *)
(*    - apply_platform_displacement_external_only (+ absent_elsewhere):     *)
(*      the inner writer is External-decl-only in the generated set.        *)
(*    - exclamation_box_act2_internal_in_linked_tu: the box solid-state     *)
(*      handler IS Internal in linked behavior_actions — the                *)
(*      box-motionlessness premise has a walkable discharge path TODAY.     *)
(*    - POSY_from_pipeline: pos[1] = (bm,64), from prog_comp_env, matching  *)
(*      the census/scout offset.                                            *)
(*    - platform_cell_null_load: the ptr64=false concrete shape             *)
(*      (Mptr=Mint32, Vnullptr=Vint Int.zero).                              *)
(*    - yact_inert_of_null, platform_null_carry, transfer_of_yact_inert,    *)
(*      seg_platform_transfer: the full T0-consumable glue.                 *)
(*                                                                          *)
(*  NAMED BOUNDARY PREMISES (the honest spec of the un-clightgen'd TU;      *)
(*  T0 assumes these per frame):                                            *)
(*    BP-INIT      gMarioPlatform cell starts NULL                          *)
(*                 (platform_displacement.c:16; would be a gvar_init pin    *)
(*                 if the TU were generated).                               *)
(*    BP-SEG-NULL  every platform phase satisfies seg_platform_spec         *)
(*                 (the :174 early-return; an 8-line body walk once         *)
(*                 generated).                                              *)
(*    BP-SEG-BOX   when the cell is non-NULL it names a WMotR exclamation   *)
(*                 box, and the phase then satisfies                        *)
(*                 seg_platform_yact_inert (the §4(d) y-identity argument;  *)
(*                 box motionlessness walkable today in behavior_actions,   *)
(*                 the set_mario_pos commit not).                           *)
(*    BP-SURF-OBJ  floor->object != NULL only for the 6 box surfaces        *)
(*                 (surface_load.c provenance + E1's level-data census;     *)
(*                 level data is in no generated TU).                       *)
(*                                                                          *)
(*  NOTE the CORRECTION vs the plan (§4(c)): the blanket 'gMarioPlatform    *)
(*  ≡ NULL' of goal2-real-frame-plan.md §1 / the scout §4 is FALSE in       *)
(*  WMotR (3 of the 6 dynamic box tops are reachable no-A by falling).      *)
(*  The maintained invariant is NULL-or-box, and the box arm is y-inert     *)
(*  by §4(d).  T0 should consume seg_platform_yact_inert (both arms         *)
(*  conclude it), not platform_cell_null alone.                             *)
(*                                                                          *)
(*  WHAT WOULD DISCHARGE THE PREMISES LATER:                                *)
(*    - clightgen platform_displacement.c (gives BP-INIT as a gvar_init     *)
(*      pin + the 3 bodies to walk for BP-SEG-*; its math callees mtxf_*    *)
(*      are ALREADY generated in math_util) and object_list_processor.c     *)
(*      (sites/ordering of the two calls around bhv_mario_update);          *)
(*      then extend the 12-TU link to 14 — a P1'-class pipeline+link        *)
(*      campaign, the memory-heavy work class (linking-OOM constraints      *)
(*      apply; symbolic linking per LinkSpike is the template).             *)
(*    - walk f_exclamation_box_act_2 (already linked) for the               *)
(*      motionlessness half of BP-SEG-BOX.                                  *)
(*    - BP-SURF-OBJ additionally needs surface_load.c (un-generated) —      *)
(*      OR is subsumed if the coupled ladder invariant ever pins Mario off  *)
(*      all box tops; note the 3 low boxes make that unlikely: the honest   *)
(*      route is the NULL-or-box invariant.                                 *)
(* ======================================================================= *)
