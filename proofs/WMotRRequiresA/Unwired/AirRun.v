(* ====================================================================== *)
(* AirRun (unwired, GOAL 2): the symbolic walk of the REAL perform_air_step *)
(* (mario_step.c), run once by vm_compute on the twelve-TU link, and what   *)
(* it proves about every execution.                                         *)
(*                                                                          *)
(* The walk is SymExec2.sx_call with the proved contract table             *)
(* AirXc.air_xc (math_util linked, so vec3f_copy etc. run their real       *)
(* bodies).  [wcheck12]: every outcome passes AirMatch.outcome_ok (an      *)
(* S_air / S_air_cut class, or a landing).  [air_step_outcome]: for every  *)
(* execution from a memory the start state describes, the final memory is *)
(* described by one such outcome.  The start state's premises (env_ok, the *)
(* world fact, closedness) are explicit here; building them from the       *)
(* frame's memory is the next step.                                         *)
(* ====================================================================== *)

From Coq Require Import List ZArith.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight
  ClightBigstep Errors.
From SM64.Generated Require mario_step mario surface_collision.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve.
From SM64.Proofs.WMotRRequiresA.Unwired Require Import FloorHeight FloorExec AirXc AirMatch.
Import ListNotations.

Section CFG.
Variable g : genv.

Definition fo (s f : ident) : Z :=
  match (genv_cenv g) ! s with
  | Some co => match field_offset g f (co_members co) with OK (d, _) => d | _ => -1 end
  | None => -1
  end.
Definition szs (s : ident) : Z := sizeof g (Tstruct s noattr).

(* regions: Mario's state, Mario's object, find_floor's three statics *)
Definition NB : positive := 10.
Definition RM : positive := 1.
Definition RO : positive := 2.
Definition RFI : positive := 4.
Definition RMISS : positive := 5.
Definition RCALLS : positive := 6.
Definition R0 : list (positive * Z) :=
  [(RM, szs mario._MarioState); (RO, szs mario._Object); (RFI, 2); (RMISS, 4); (RCALLS, 6)].
Definition gtab : list (ident * positive) :=
  [(surface_collision._gFindFloorIncludeSurfaceIntangible, RFI);
   (surface_collision._gNumFindFloorMisses, RMISS); (surface_collision._gNumCalls, RCALLS)].
(* known cells: m->marioObj, and m->action = ACT_FREEFALL (0x0100088C) *)
Definition kv : list (positive * Z * memory_chunk * sval) :=
  [ (RM, fo mario._MarioState mario._marioObj, Mint32, Sptr RO Ptrofs.zero);
    (RM, 12, Mint32, Sconst (Vint (Int.repr 16779404))) ].

Definition kW : positive := 1.
Definition kH : positive := 2.
Definition xc : ident -> option xcontract :=
  air_xc NB R0 RFI RMISS RCALLS kW kH (szs mario._Surface).

(* cells joins keep exact: action, actionState, actionTimer, pos[1], vel[1],
   floorHeight, gfx.pos[1] *)
Definition jkeys : list (positive * Z * memory_chunk) :=
  [(RM, 12, Mint32); (RM, 24, Mint16unsigned); (RM, 26, Mint16unsigned);
   (RM, 64, Mfloat32); (RM, 76, Mfloat32); (RM, 112, Mfloat32); (RO, 36, Mfloat32)].

Definition mergef (id : ident) : bool :=
  Pos.eqb id mario_step._perform_air_quarter_step || Pos.eqb id mario._resolve_and_return_wall_collisions.

(* the start facts: the world, no A bits in m->input (mask 0x82), the entry
   floor and area are world objects, the floor's type is a WMotR one *)
Definition pc0 : list fact :=
  [Fuser kW (wargs R0); Fbits (Sinit RM 2 Mint16unsigned) (Int.repr 130);
   Fworld (Sinit RM (fo mario._MarioState mario._floor) Mint32) (szs mario._Surface);
   Fworld (Sinit RM (fo mario._MarioState mario._area) Mint32) (szs mario._Area)]
  ++ ffacts (Sinit RM (fo mario._MarioState mario._floor) Mint32).

Definition g0 : gst := mkg nil pc0 NB nil nil.

(* stepArg = AIR_STEP_CHECK_LEDGE_GRAB (1): act_freefall's call, through
   common_air_action_step *)
Definition args0 : list sval := [Sptr RM Ptrofs.zero; Sconst (Vint Int.one)].

Definition ok_c (c : cpath) : bool :=
  outcome_ok (sload NB R0 kv (fst c)) (init_cell kv) (g_pc (fst c)) RM RO kH.

(* the consumer facts' meaning: the world fact, and find_floor's height
   (FloorHeight.ff_height, at the frame's entry memory) *)
Definition ufW (m0 : mem) (gp : meminj) : positive -> list (option val) -> Prop :=
  fun k vs =>
    if Pos.eqb k kW then Wff g m0 gp (szs mario._Surface) vs
    else match vs with
         | [Some (Vsingle h); Some yv] => HPi (Hit_at g m0) (ycast yv) h /\ Hit_at g m0 h
         | _ => False
         end.

Lemma ufW_kH : forall m0 gp vs, ufW m0 gp kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at g m0) (ycast yv) h /\ Hit_at g m0 h.
Proof.
  intros m0 gp vs H. unfold ufW in H. change (Pos.eqb kH kW) with false in H. cbv iota in H.
  destruct vs as [| [[| | | | h |]|] [| [yv|] [| o3 r]]]; cbv iota in H; try contradiction.
  exists h, yv. split; [reflexivity | exact H].
Qed.
End CFG.

(* THE WALK, computed once on the real link.  The executor call is written
   out in full, in exactly the shape sx_call_sound consumes: no conversion
   between the vm-checked term and the abstract genv's (which would make
   the kernel run the executor lazily). *)
Lemma wcheck12 : match ge12 with
  | Some g => match sx_call g NB (R0 g) gtab (kv g) (xc g) jkeys mergef true 400 (g0 g)
                      (Internal mario_step.f_perform_air_step) args0 with
              | Some cs => forallb (ok_c g) cs | None => false end
  | None => false end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma consume : forall (o : option (list cpath)) (P : cpath -> bool),
  match o with Some cs => forallb P cs | None => false end = true ->
  exists cs, o = Some cs /\ forall c, In c cs -> P c = true.
Proof.
  intros [cs|] P H; [| discriminate]. exists cs. split; [reflexivity |].
  apply forallb_forall. exact H.
Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).

Lemma wcheck_lp : exists cs,
  sx_call G NB (R0 G) gtab (kv G) (xc G) jkeys mergef true 400 (g0 G)
    (Internal mario_step.f_perform_air_step) args0 = Some cs
  /\ forall c, In c cs -> ok_c G c = true.
Proof.
  pose proof wcheck12 as W. rewrite (ge12_ok lp H12) in W.
  exact (consume _ (ok_c G) W).
Qed.

Lemma pc0_nlt : forall f, In f (pc0 G) -> fact_nlt NB f.
Proof.
  intros f H. cbn [pc0 app ffacts In] in H.
  repeat (destruct H as [<- | H]; [cbn; repeat split; try (unfold Plt; cbn; lia); repeat constructor; unfold Plt; cbn; lia |]).
  contradiction.
Qed.

(* every execution of the real perform_air_step from a memory the start
   state describes ends in a memory one classified outcome describes *)
Theorem air_step_outcome : forall m0 gp E t m' vres,
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  (forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v) ->
  env_ok G NB (R0 G) gtab (kv G) m0 gp E ->
  (forall f, In f (pc0 G) -> fact_holds G (R0 G) m0 (ufW G m0 gp) E f) ->
  eval_funcall function_entry2 G m0 (Internal mario_step.f_perform_air_step)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero); Vint Int.one] t m' vres ->
  exists E' gs, Ext E E' NB
    /\ MMg G NB (R0 G) gtab (kv G) m0 (ufW G m0 gp) gp E' m' gs
    /\ outcome_ok (sload NB (R0 G) (kv G) gs) (init_cell (kv G)) (g_pc gs) RM RO kH = true.
Proof.
  intros m0 gp E t m' vres GPO MC EO PC EV.
  destruct wcheck_lp as (cs & RUN & W).
  assert (MM0 : MMg G NB (R0 G) gtab (kv G) m0 (ufW G m0 gp) gp E m0 (g0 G)).
  { apply MMg_init; [exact EO | apply Ple_refl |].
    intros f Hf. split; [exact (pc0_nlt f Hf) | exact (PC f Hf)]. }
  assert (XS := air_xc_sound_link lp (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
                  (linked12_LO_mario lp H12) NB (R0 G) gtab (kv G) m0 (ufW G m0 gp) gp
                  RFI RMISS RCALLS kW kH (szs G mario._Surface) GPO eq_refl eq_refl eq_refl
                  (fun vs H => H) (fun h yv H1 H2 => conj H1 H2)).
  assert (ARGS : Forall2 (fun a v => den G m0 E a = Some v /\ sok NB (g_nx (g0 G)) a) args0
                   [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero); Vint Int.one]).
  { constructor; [| constructor; [| constructor]].
    - split; [reflexivity |]. cbn [sok nlt g0 g_nx]. split; [unfold Plt, Pos.lt; reflexivity | exact I].
    - split; [reflexivity |]. split; [exact I | reflexivity]. }
  destruct (sx_call_sound G NB (R0 G) gtab (kv G) (xc G) jkeys mergef true m0 (ufW G m0 gp) gp
              GPO MC XS 400 (g0 G) _ args0 cs E m0 _ t m' vres RUN MM0 ARGS EV) as (c & Hin & CMc).
  destruct c as [gs r]. destruct CMc as (E' & X & MM & _).
  exists E', gs. split; [exact X | split; [exact MM |]].
  exact (W _ Hin).
Qed.
End LP.
