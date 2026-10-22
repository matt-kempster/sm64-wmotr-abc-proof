(* spine-root: POLE POSITIVE CONTROL -- with NO A pressed, real
   execute_mario_action frames over the linked12 link (30 TUs, behavior_data.c
   linked) run Mario on one of WMotR's real poles (the level script's
   bhvPoleGrabbing object, script.c:19) through each behavior-script compare of
   mario_actions_automatic.c (lines 31, 45, 144, 164).  Before behavior_data.c
   was linked every bhv* script was a size-0 block and each of these compares
   had NO CompCert execution (WMotREntry.cmp_size0_stuck), so every claim the
   capstones make about the pole path held vacuously. *)

(* How it is proved: exactly PositiveControl's method.  The frame is RUN by the
   executable Clight interpreter (Interp/ClightInterp.v, proved sound against
   CompCert's big-step semantics) over the computable linked genv
   (Interp/LinkGenv.v, = globalenv lp), from a concrete memory built by
   Interp/MemBuild.v (every global allocated and initialised from the linked
   AST, so bhvPoleGrabbing's block holds its 12 real script words).  One
   vm_compute per frame checks the run; soundness turns it into an
   eval_funcall derivation.

   The world outside the link ([pole_world]) is PositiveControl's flat world
   plus set_sound_moving_speed (audio, silent).  The real surface_collision
   bodies run over a static partition holding one flat floor under the pole
   (y = -2739, the pole's base); walls and ceilings are empty.

   The three frames (Mario in ACT_HOLDING_POLE on the low pole, oPosY -2739,
   hitboxHeight 820 = 10 * bparam2 82, pole.inc.c:21):
   - stick down (stickY -64): the yaw-velocity branch, mario_actions_automatic.c
     :164 (usedObj->behavior == bhvTree, false) and play_climbing_sounds (:45);
     the frame stays on the pole with oMarioPoleYawVel = 128.
   - Z pressed: add_tree_leaf_particles (:31), then ACT_SOFT_BONK.
   - stick up (stickY +64) at the pole top: virtual_to_segmented(0x13, ..)
     compared with bhvGiantPole (:144), then ACT_TOP_OF_POLE_TRANSITION. *)

From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Integers Floats Values AST Memory Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import LinkedTwelve RealFrameLinked AGates.
Require SM64.Generated.mario.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Local Open Scope string_scope.

(* ---------------------------------------------------------------------- *)
(* The world outside the link                                              *)
(* ---------------------------------------------------------------------- *)

Definition f32 (z : Z) : val := Vsingle (Float32.of_int (Int.repr z)).
Definition i32 (z : Z) : val := Vint (Int.repr z).
Definition ret (v : val) (m : mem) : option (trace * val * mem) := Some (E0, v, m).

Definition pole_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) :=
  match ef with
  | EF_external n _ =>
      if String.eqb n "sqrtf" then
        match args with [Vsingle x] => ret (Vsingle (Float32.sqrt x)) m | _ => None end
      else if String.eqb n "play_sound" || String.eqb n "play_infinite_stairs_music"
              || String.eqb n "set_sound_moving_speed"
      then ret Vundef m
      else None
  | _ => None
  end.

(* ---------------------------------------------------------------------- *)
(* The starting memory                                                     *)
(* ---------------------------------------------------------------------- *)

Definition externs (i : ident) : option Z :=
  if Pos.eqb i (id "gSineTable") then Some (5120 * 4) else None.

Fixpoint fresh_many (ge : genv) (m : mem) (l : list string) : option (mem * list block) :=
  match l with
  | [] => Some (m, [])
  | s :: l' =>
      match fresh m (ssize ge s) with
      | Some (m1, b) =>
          match fresh_many ge m1 l' with
          | Some (m2, bs) => Some (m2, b :: bs)
          | None => None
          end
      | None => None
      end
  end.

Definition ACT_HOLDING_POLE : Z := 135267136.            (* 0x08100340 *)
Definition ACT_SOFT_BONK : Z := 16910518.                (* 0x010208B6 *)
Definition ACT_TOP_OF_POLE_TRANSITION : Z := 1049412.    (* 0x00100344 *)
Definition Z_TRIG : Z := 8192.                           (* 0x2000 *)

(* WMotR's low pole (levels/wmotr/script.c:19): (3996, -2739, 5477), bparam2 82 *)
Definition POLE_X : Z := 3996.
Definition POLE_Y : Z := -2739.
Definition POLE_Z : Z := 5477.
Definition POLE_H : Z := 820.

(* Mario holding the low pole, oMarioPolePos = pp, with the given stick and
   buttons.  Returns the memory, Mario's block, the pole object's block. *)
Definition build (ge : genv) (ast : AST.program (Ctypes.fundef function) type)
    (pp stickY : Z) (buttons : Z) : option (mem * block * block * block) :=
  let o s f := match off ge s f with Some d => d | None => -1000 end in
  let raw k := o "Object" "rawData" + 4 * k in
  let P b := Vptr b Ptrofs.zero in
  let M := "MarioState" in
  match alloc_globs ge externs Mem.empty (AST.prog_defs ast) with
  | None => None
  | Some m0 =>
    match sym ge "gMarioStates", sym ge "gMarioState", sym ge "bhvPoleGrabbing" with
    | Some bm, Some gp, Some bpole =>
      match sym ge "gStaticSurfacePartition",
            fresh_many ge m0 ["Object"; "Object"; "MarioBodyState"; "Controller"; "Area";
                              "Camera"; "Surface"; "PlayerCameraState";
                              "DmaHandlerList"; "Animation"; "SurfaceNode"; "DmaTable";
                              "Object"; "Object"] with
      | Some gsp, Some (m1, [bobj; bpo; bbody; bctl; barea; bcam; bfloor; bpcs; bdma; banim;
                             bnode; btbl; bidx; bval]) =>
        let V k := o "Surface" k in
        (* the floor cell of (POLE_X, POLE_Z): ((x + 0x2000) / 0x400, ...) *)
        let cx := (POLE_X + 8192) / 1024 in
        let cz := (POLE_Z + 8192) / 1024 in
        let ws := [ W Mint32 gp 0 (P bm);
                    W Mint32 bm (o M "action") (i32 ACT_HOLDING_POLE);
                    W Mint32 bm (o M "prevAction") (i32 ACT_HOLDING_POLE);
                    W Mint32 bm (o M "marioObj") (P bobj);
                    W Mint32 bm (o M "usedObj") (P bpo);
                    W Mint32 bm (o M "marioBodyState") (P bbody);
                    W Mint32 bm (o M "controller") (P bctl);
                    W Mint32 bm (o M "area") (P barea);
                    W Mint32 bm (o M "statusForCamera") (P bpcs);
                    W Mint32 bm (o M "floor") (P bfloor);
                    W Mint16signed bm (o M "health") (i32 2176);
                    W Mint32 bm (o M "animList") (P bdma);
                    W Mfloat32 bm (o M "pos") (f32 POLE_X);
                    W Mfloat32 bm (o M "pos" + 4) (f32 (POLE_Y + pp));
                    W Mfloat32 bm (o M "pos" + 8) (f32 POLE_Z);
                    W Mint32 bdma (o "DmaHandlerList" "bufTarget") (P banim);
                    W Mint32 bdma (o "DmaHandlerList" "dmaTable") (P btbl);
                    (* the animation's index / values tables: zero-filled
                       blocks (load_patchable_table loads nothing here) *)
                    W Mint32 banim (o "Animation" "index") (P bidx);
                    W Mint32 banim (o "Animation" "values") (P bval);
                    (* three index entries (count 256, offset 40): every
                       retrieve_animation_index lookup for a frame in
                       [-40, 256) reads inside the zero-filled values *)
                    W Mint16unsigned bidx 0 (i32 256);
                    W Mint16unsigned bidx 2 (i32 40);
                    W Mint16unsigned bidx 4 (i32 256);
                    W Mint16unsigned bidx 6 (i32 40);
                    W Mint16unsigned bidx 8 (i32 256);
                    W Mint16unsigned bidx 10 (i32 40);
                    W Mint32 barea (o "Area" "camera") (P bcam);
                    W Mint16unsigned bctl (o "Controller" "buttonPressed") (i32 buttons);
                    W Mint16unsigned bctl (o "Controller" "buttonDown") (i32 buttons);
                    W Mfloat32 bctl (o "Controller" "stickY") (f32 stickY);
                    W Mfloat32 bctl (o "Controller" "stickMag") (f32 (Z.abs stickY));
                    (* Mario's object: oMarioPolePos (0x22) *)
                    W Mfloat32 bobj (raw 34) (f32 pp);
                    (* the pole object, as the level script spawns it *)
                    W Mint32 bpo (o "Object" "behavior") (P bpole);
                    W Mfloat32 bpo (raw 6) (f32 POLE_X);
                    W Mfloat32 bpo (raw 7) (f32 POLE_Y);
                    W Mfloat32 bpo (raw 8) (f32 POLE_Z);
                    W Mfloat32 bpo (o "Object" "hitboxHeight") (f32 POLE_H);
                    (* the floor under the pole: one flat triangle, height POLE_Y *)
                    W Mint32 gsp ((cz * 16 + cx) * 3 * ssize ge "SurfaceNode"
                                  + o "SurfaceNode" "next") (P bnode);
                    W Mint32 bnode (o "SurfaceNode" "surface") (P bfloor);
                    W Mint16signed bfloor (V "vertex1") (i32 POLE_X);
                    W Mint16signed bfloor (V "vertex1" + 2) (i32 POLE_Y);
                    W Mint16signed bfloor (V "vertex1" + 4) (i32 (POLE_Z + 1000));
                    W Mint16signed bfloor (V "vertex2") (i32 (POLE_X + 1000));
                    W Mint16signed bfloor (V "vertex2" + 2) (i32 POLE_Y);
                    W Mint16signed bfloor (V "vertex2" + 4) (i32 (POLE_Z - 1000));
                    W Mint16signed bfloor (V "vertex3") (i32 (POLE_X - 1000));
                    W Mint16signed bfloor (V "vertex3" + 2) (i32 POLE_Y);
                    W Mint16signed bfloor (V "vertex3" + 4) (i32 (POLE_Z - 1000));
                    W Mfloat32 bfloor (V "normal" + 4) (f32 1);
                    W Mfloat32 bfloor (V "originOffset") (f32 (- POLE_Y)) ] in
        match apply_writes m1 ws 0 with
        | inl m2 => Some (m2, bm, bobj, bpo)
        | inr _ => None
        end
      | _, _ => None
      end
    | _, _, _ => None
    end
  end.

(* ---------------------------------------------------------------------- *)
(* The runs and their check                                                *)
(* ---------------------------------------------------------------------- *)

Definition FUEL : nat := Z.to_nat 5000.

(* Offsets (pinned by the lab run over ge12): MarioState.action @12,
   MarioState.usedObj @128, MarioState.marioObj's oMarioPoleYawVel =
   rawData (136) + 4 * 0x21 = 268, Object.behavior @524. *)
Definition act_is (bm : block) (m : mem) (z : Z) : bool :=
  match CM.load Mint32 m bm 12 with
  | Some (Vint v) => Int.eq v (Int.repr z)
  | _ => false
  end.

Definition yaw_is (bobj : block) (m : mem) (z : Z) : bool :=
  match CM.load Mint32 m bobj 268 with
  | Some (Vint v) => Int.eq v (Int.repr z)
  | _ => false
  end.

(* m->usedObj->behavior == &bhvPoleGrabbing *)
Definition used_pole_b (ge : genv) (bm : block) (m : mem) : bool :=
  match CM.load Mint32 m bm 128, Genv.find_symbol ge (id "bhvPoleGrabbing") with
  | Some (Vptr bo oo), Some bp =>
      Ptrofs.eq oo Ptrofs.zero &&
      match CM.load Mint32 m bo 524 with
      | Some (Vptr b' o') => Pos.eqb b' bp && Ptrofs.eq o' Ptrofs.zero
      | _ => false
      end
  | _, _ => false
  end.

Definition a_pressed_b (bm : block) (m : mem) : bool :=
  match CM.load Mptr m bm 156 with
  | Some (Vptr bc oc) =>
      match CM.load Mint16unsigned m bc (Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr 18))) with
      | Some (Vint v) => negb (Int.eq (Int.and v (Int.repr 32768)) Int.zero)
      | _ => true
      end
  | _ => true
  end.

(* Generic in the fuel and the function (PositiveControl's pattern: the
   soundness lemma never mentions the concrete body). *)
Definition check_gen (fuel : nat) (f : fundef) (ge : genv) (m : mem) (bm bobj : block)
    (after yaw : Z) : bool :=
  match ex_call ge pole_world fuel m f [Vptr bobj Ptrofs.zero] with
  | Done _ (_, m', _) =>
      act_is bm m ACT_HOLDING_POLE && act_is bm m' after && yaw_is bobj m' yaw
      && used_pole_b ge bm m && negb (a_pressed_b bm m)
      && match Genv.find_symbol ge (id "gMarioStates") with
         | Some b => Pos.eqb b bm
         | None => false
         end
  | Stuck _ _ _ _ => false
  end.

(* the genv / AST are arguments, not a `match ge12` in the body: elaborating
   a match on the constant ge12 reduces the whole linked program (WithGe) *)
Definition witness_gen (oge : option genv)
    (oast : option (AST.program (Ctypes.fundef function) type))
    (pp stickY buttons after yaw : Z) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      match build ge ast pp stickY buttons with
      | Some (m, bm, bobj, _) =>
          check_gen FUEL (Internal mario.f_execute_mario_action) ge m bm bobj after yaw
      | None => false
      end
  | _, _ => false
  end.

Definition witness_ok (pp stickY buttons after yaw : Z) : bool :=
  witness_gen ge12 ast12 pp stickY buttons after yaw.

Definition ACT_TOP_OF_POLE : Z := 1049413.               (* 0x00100345 *)

(* THE COMPUTATIONS (~2-3 min each, most of it building ge12). *)
(* stick down: the yaw-velocity branch (oMarioPoleYawVel := 0 - (-64) * 2 =
   128), with mario_actions_automatic.c:164 and play_climbing_sounds (:45);
   still holding the pole *)
Lemma run_stick_down : witness_ok 300 (-64) 0 ACT_HOLDING_POLE 128 = true.
Proof. vm_compute. reflexivity. Qed.
(* Z pressed: add_tree_leaf_particles (:31), then the soft bonk *)
Lemma run_z : witness_ok 300 0 Z_TRIG ACT_SOFT_BONK 0 = true.
Proof. vm_compute. reflexivity. Qed.
(* stick up at the top (oMarioPolePos 720 = poleTop): the bhvGiantPole
   compare (:144), then ACT_TOP_OF_POLE_TRANSITION, which reaches
   ACT_TOP_OF_POLE in the same frame *)
Lemma run_top : witness_ok 720 64 0 ACT_TOP_OF_POLE 0 = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* From the check to the semantics                                         *)
(* ---------------------------------------------------------------------- *)

Definition mario_action_is (bm : block) (m : mem) (z : Z) : Prop :=
  Mem.load Mint32 m bm 12 = Some (Vint (Int.repr z)).

Definition used_obj_is_pole (ge : genv) (bm : block) (m : mem) : Prop :=
  exists bo bp,
    Mem.load Mint32 m bm 128 = Some (Vptr bo Ptrofs.zero) /\
    Genv.find_symbol ge (id "bhvPoleGrabbing") = Some bp /\
    Mem.load Mint32 m bo 524 = Some (Vptr bp Ptrofs.zero).

Lemma act_is_sound : forall bm m z, act_is bm m z = true -> mario_action_is bm m z.
Proof.
  unfold act_is, mario_action_is; intros bm m z H. rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m bm 12) as [[]|]; try discriminate.
  apply Int.same_if_eq in H. subst. reflexivity.
Qed.

Lemma used_pole_sound : forall ge bm m,
    used_pole_b ge bm m = true -> used_obj_is_pole ge bm m.
Proof.
  unfold used_pole_b, used_obj_is_pole; intros ge bm m H. rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m bm 128) as [[| | | | | bo oo]|]; try discriminate.
  destruct (Genv.find_symbol ge (id "bhvPoleGrabbing")) as [bp|]; try discriminate.
  apply andb_prop in H as [Ho H]. apply Ptrofs.same_if_eq in Ho. subst oo.
  rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m bo 524) as [[| | | | | b' o']|] eqn:E; try discriminate.
  apply andb_prop in H as [Hb Ho']. apply Pos.eqb_eq in Hb. apply Ptrofs.same_if_eq in Ho'.
  subst. exists bo, bp. auto.
Qed.

Lemma a_pressed_b_eq : forall bm m, a_pressed_b bm m = a_pressed_real bm m.
Proof.
  intros. unfold a_pressed_b, a_pressed_real. rewrite !CM.load_eq.
  destruct (Mem.load Mptr m bm 156) as [[]|]; auto. rewrite CM.load_eq. reflexivity.
Qed.

Lemma check_gen_sound : forall fuel f (ge : genv) m bm bobj after yaw,
    (forall ef args m0 t v m1, pole_world ef args m0 = Some (t, v, m1) ->
       external_call ef ge args m0 t v m1) ->
    check_gen fuel f ge m bm bobj after yaw = true ->
    Genv.find_symbol ge (id "gMarioStates") = Some bm /\
    a_pressed_real bm m = false /\
    mario_action_is bm m ACT_HOLDING_POLE /\ used_obj_is_pole ge bm m /\
    exists t res m',
      eval_funcall function_entry2 ge m f [Vptr bobj Ptrofs.zero] t m' res /\
      mario_action_is bm m' after.
Proof.
  intros fuel f ge m bm bobj after yaw Hw H. unfold check_gen in H.
  destruct (ex_call ge pole_world fuel m f _) as [[[t m'] res]| ? ? ?] eqn:Hrun;
    [ | discriminate].
  rewrite !andb_true_iff in H. destruct H as [[[[[H0 H1] _] Hu] Ha] Hs].
  split; [ | split; [ | split; [ | split ] ] ].
  - destruct (Genv.find_symbol ge (id "gMarioStates")) as [b|]; [ | discriminate].
    apply Pos.eqb_eq in Hs. congruence.
  - rewrite <- a_pressed_b_eq. destruct (a_pressed_b bm m); [ discriminate | reflexivity ].
  - exact (act_is_sound _ _ _ H0).
  - exact (used_pole_sound _ _ _ Hu).
  - exists t, res, m'. split.
    + eapply ex_call_sound; eauto.
    + exact (act_is_sound _ _ _ H1).
Qed.

(* one frame, over the real link *)
Lemma frame_of_witness : forall lp pp stickY buttons after yaw,
    linked12 lp ->
    (forall ef args m t v m', pole_world ef args m = Some (t, v, m') ->
       external_call ef (globalenv lp) args m t v m') ->
    witness_ok pp stickY buttons after yaw = true ->
    exists bm m m',
      Genv.find_symbol (globalenv lp) (id "gMarioStates") = Some bm /\
      a_pressed_real bm m = false /\
      mario_action_is bm m ACT_HOLDING_POLE /\
      used_obj_is_pole (globalenv lp) bm m /\
      execute_mario_action_step_lp lp m m' /\
      mario_action_is bm m' after.
Proof.
  intros lp pp stickY buttons after yaw Hlink Hworld W. unfold witness_ok in W.
  rewrite (ge12_ok lp Hlink), (ast12_ok lp Hlink) in W. unfold witness_gen in W.
  destruct (build (globalenv lp) (program_of_program lp) pp stickY buttons)
    as [[[[m bm] bobj] bpo]|]; [ | discriminate].
  destruct (check_gen_sound FUEL (Internal mario.f_execute_mario_action) _ _ _ _ _ _
              Hworld W)
    as [Hs [Ha [H0 [Hu [t [res [m' [Hev H1]]]]]]]].
  exists bm, m, m'. repeat split; auto.
  exists bobj, t, res. exact Hev.
Qed.

(* ---------------------------------------------------------------------- *)
(* THE POLE CONTROL                                                        *)
(* ---------------------------------------------------------------------- *)

(* Over every 30-TU link: the pole path through each behavior-script compare
   of mario_actions_automatic.c has a real execute_mario_action execution,
   with A not pressed, from Mario holding WMotR's pole (usedObj->behavior =
   &bhvPoleGrabbing).  The frames end on the pole, in a soft bonk, and on the
   pole top. *)
Theorem noA_pole_frames_run : forall lp,
    linked12 lp ->
    (forall ef args m t v m', pole_world ef args m = Some (t, v, m') ->
       external_call ef (globalenv lp) args m t v m') ->
    forall after, In after [ACT_HOLDING_POLE; ACT_SOFT_BONK; ACT_TOP_OF_POLE] ->
    exists bm m m',
      Genv.find_symbol (globalenv lp) (id "gMarioStates") = Some bm /\
      a_pressed_real bm m = false /\
      mario_action_is bm m ACT_HOLDING_POLE /\
      used_obj_is_pole (globalenv lp) bm m /\
      execute_mario_action_step_lp lp m m' /\
      mario_action_is bm m' after.
Proof.
  intros lp Hlink Hworld after Hin.
  destruct Hin as [<- | [<- | [<- | []]]].
  - exact (frame_of_witness lp _ _ _ _ _ Hlink Hworld run_stick_down).
  - exact (frame_of_witness lp _ _ _ _ _ Hlink Hworld run_z).
  - exact (frame_of_witness lp _ _ _ _ _ Hlink Hworld run_top).
Qed.
