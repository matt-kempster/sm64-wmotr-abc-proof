(* spine-root: GOAL-1 POSITIVE CONTROL -- with A pressed, ONE real
   execute_mario_action frame over the linked12 link (14 TUs) takes Mario from a
   non-flying action to ACT_FLYING_TRIPLE_JUMP.  So the capstone's step
   relation is not empty and "flying" is reachable by it: the no-fly
   conclusion is not vacuous, and the no-A premise is what does the work. *)

(* How it is proved.  The frame is RUN, not reasoned about: the executable
   Clight interpreter (Interp/ClightInterp.v, proved sound against CompCert's
   big-step semantics) runs the real generated code over the computable
   linked genv (Interp/LinkGenv.v, proved equal to [globalenv lp]), from a
   concrete memory built by Interp/MemBuild.v.  One vm_compute checks the
   whole run; soundness turns it into an [eval_funcall] derivation.

   The one assumption, [Hworld], is about the functions OUTSIDE the
   fourteen linked TUs (audio, anim loading, sqrtf).  CompCert models
   those as an abstract [external_functions_sem] with no content, so no
   derivation that calls them can exist without saying what they may do.
   [flat_world] says: silent audio, a zero patchable-table load, and IEEE
   sqrtf.  Collision and math_util are NOT in it: the real
   surface_collision bodies run, over a static partition holding one flat
   floor triangle under Mario (built below), and the real math_util bodies
   (vec3*, approach_*, atan2s over the real gArctanTable) run too. *)

From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Integers Floats Values AST Memory Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import LinkedTwelve RealFrameLinked NoAImpliesNoFlyLinked
  AGates Flying.
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

Definition flat_world (ef : external_function) (args : list val) (m : mem)
    : option (trace * val * mem) :=
  match ef with
  | EF_external n _ =>
      if String.eqb n "sqrtf" then
        match args with [Vsingle x] => ret (Vsingle (Float32.sqrt x)) m | _ => None end
      else if String.eqb n "play_sound" || String.eqb n "play_infinite_stairs_music"
      then ret Vundef m
      else None
  | _ => None
  end.

(* ---------------------------------------------------------------------- *)
(* The starting memory                                                     *)
(* ---------------------------------------------------------------------- *)

(* trig_tables.inc.c: gSineTable has 0x1000 + 0x400 f32 entries. *)
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

Definition ACT_DOUBLE_JUMP_LAND : Z := 67110002.   (* 0x04000472 *)
Definition MARIO_WING_CAP : Z := 8.
Definition A_BUTTON : Z := 32768.

(* Mario on flat ground in ACT_DOUBLE_JUMP_LAND, wearing the wing cap, with
   A pressed this frame.  Returns the memory, Mario's block, his object. *)
Definition build (ge : genv) (ast : AST.program (Ctypes.fundef function) type)
    : option (mem * block * block) :=
  let o s f := match off ge s f with Some d => d | None => -1000 end in
  let P b := Vptr b Ptrofs.zero in
  let M := "MarioState" in
  match alloc_globs ge externs Mem.empty (AST.prog_defs ast) with
  | None => None
  | Some m0 =>
    match sym ge "gMarioStates", sym ge "gMarioState" with
    | Some bm, Some gp =>
      match sym ge "gStaticSurfacePartition",
            fresh_many ge m0 ["Object"; "MarioBodyState"; "Controller"; "Area";
                              "Camera"; "Surface"; "PlayerCameraState";
                              "DmaHandlerList"; "Animation"; "SurfaceNode"; "DmaTable"] with
      | Some gsp, Some (m1, [bobj; bbody; bctl; barea; bcam; bfloor; bpcs; bdma; banim;
                             bnode; btbl]) =>
        let V k := o "Surface" k in
        let ws := [ W Mint32 gp 0 (P bm);
                    W Mint32 bm (o M "action") (i32 ACT_DOUBLE_JUMP_LAND);
                    W Mint32 bm (o M "prevAction") (i32 ACT_DOUBLE_JUMP_LAND);
                    W Mint32 bm (o M "flags") (i32 MARIO_WING_CAP);
                    W Mint32 bm (o M "marioObj") (P bobj);
                    W Mint32 bm (o M "marioBodyState") (P bbody);
                    W Mint32 bm (o M "controller") (P bctl);
                    W Mint32 bm (o M "area") (P barea);
                    W Mint32 bm (o M "statusForCamera") (P bpcs);
                    W Mint32 bm (o M "floor") (P bfloor);
                    W Mint16signed bm (o M "health") (i32 2176);
                    W Mint32 bm (o M "animList") (P bdma);
                    W Mint32 bdma (o "DmaHandlerList" "bufTarget") (P banim);
                    (* the real load_patchable_table (memory.c, linked) runs:
                       an empty DMA table (count = 0, zero-filled) takes its
                       index >= count branch, no DMA, returns FALSE *)
                    W Mint32 bdma (o "DmaHandlerList" "dmaTable") (P btbl);
                    W Mint32 barea (o "Area" "camera") (P bcam);
                    W Mint16unsigned bctl (o "Controller" "buttonPressed") (i32 A_BUTTON);
                    W Mint16unsigned bctl (o "Controller" "buttonDown") (i32 A_BUTTON);
                    (* The floor: Mario (at the origin) lies in cell (8,8);
                       gStaticSurfacePartition[8][8][SPATIAL_PARTITION_FLOORS]
                       lists one triangle (0,1000) (1000,-1000) (-1000,-1000)
                       in (x,z), normal (0,1,0), originOffset 0: height 0. *)
                    W Mint32 gsp ((8 * 16 + 8) * 3 * ssize ge "SurfaceNode"
                                  + o "SurfaceNode" "next") (P bnode);
                    W Mint32 bnode (o "SurfaceNode" "surface") (P bfloor);
                    W Mint16signed bfloor (V "vertex1" + 4) (i32 1000);
                    W Mint16signed bfloor (V "vertex2") (i32 1000);
                    W Mint16signed bfloor (V "vertex2" + 4) (i32 (-1000));
                    W Mint16signed bfloor (V "vertex3") (i32 (-1000));
                    W Mint16signed bfloor (V "vertex3" + 4) (i32 (-1000));
                    W Mfloat32 bfloor (V "normal" + 4) (f32 1) ] in
        match apply_writes m1 ws 0 with
        | inl m2 => Some (m2, bm, bobj)
        | inr _ => None
        end
      | _, _ => None
      end
    | _, _ => None
    end
  end.

(* ---------------------------------------------------------------------- *)
(* The run and its check                                                   *)
(* ---------------------------------------------------------------------- *)

Definition FUEL : nat := Z.to_nat 5000.

Definition flying_b (bm : block) (m : mem) : bool :=
  match CM.load Mint32 m bm 12 with Some (Vint v) => is_flying_int v | _ => false end.

Definition a_pressed_b (bm : block) (m : mem) : bool :=
  match CM.load Mptr m bm 156 with
  | Some (Vptr bc oc) =>
      match CM.load Mint16unsigned m bc (Ptrofs.unsigned (Ptrofs.add oc (Ptrofs.repr 18))) with
      | Some (Vint v) => negb (Int.eq (Int.and v (Int.repr 32768)) Int.zero)
      | _ => true
      end
  | _ => true
  end.

(* Generic in the fuel and the function, so the soundness lemma below never
   mentions (and the kernel never unfolds) the concrete 5000 or the body. *)
Definition check_gen (fuel : nat) (f : fundef) (ge : genv) (m : mem) (bm bobj : block)
    : bool :=
  match ex_call ge flat_world fuel m f [Vptr bobj Ptrofs.zero] with
  | Done _ (_, m', _) =>
      flying_b bm m' && negb (flying_b bm m) && a_pressed_b bm m
      && match Genv.find_symbol ge (id "gMarioStates") with
         | Some b => Pos.eqb b bm
         | None => false
         end
  | Stuck _ _ _ _ => false
  end.

Definition witness_ok : bool :=
  match ge12, ast12 with
  | Some ge, Some ast =>
      match build ge ast with
      | Some (m, bm, bobj) =>
          check_gen FUEL (Internal mario.f_execute_mario_action) ge m bm bobj
      | None => false
      end
  | _, _ => false
  end.

(* THE COMPUTATION: one vm_compute runs the whole frame (~20 s). *)
Lemma witness_ok_true : witness_ok = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* From the check to the semantics (small, abstract-ge lemmas)             *)
(* ---------------------------------------------------------------------- *)

Lemma flying_b_sound : forall bm m, flying_b bm m = true -> mem_flying_lp bm m.
Proof.
  unfold flying_b, mem_flying_lp; intros bm m H.
  rewrite CM.load_eq in H.
  destruct (Mem.load Mint32 m bm 12) as [[]|]; try discriminate. eauto.
Qed.

Lemma flying_b_complete : forall bm m, mem_flying_lp bm m -> flying_b bm m = true.
Proof.
  unfold flying_b, mem_flying_lp; intros bm m [v [H1 H2]].
  rewrite CM.load_eq, H1. exact H2.
Qed.

Lemma a_pressed_b_eq : forall bm m, a_pressed_b bm m = a_pressed_real bm m.
Proof.
  intros. unfold a_pressed_b, a_pressed_real. rewrite !CM.load_eq.
  destruct (Mem.load Mptr m bm 156) as [[]|]; auto. rewrite CM.load_eq. reflexivity.
Qed.

Lemma check_gen_sound : forall fuel f (ge : genv) m bm bobj,
    (forall ef args m0 t v m1, flat_world ef args m0 = Some (t, v, m1) ->
       external_call ef ge args m0 t v m1) ->
    check_gen fuel f ge m bm bobj = true ->
    Genv.find_symbol ge (id "gMarioStates") = Some bm /\
    a_pressed_real bm m = true /\ ~ mem_flying_lp bm m /\
    exists t res m',
      eval_funcall function_entry2 ge m f [Vptr bobj Ptrofs.zero] t m' res /\
      mem_flying_lp bm m'.
Proof.
  intros fuel f ge m bm bobj Hw H. unfold check_gen in H.
  destruct (ex_call ge flat_world fuel m f _) as [[[t m'] res]| ? ? ?] eqn:Hrun;
    [ | discriminate].
  rewrite !andb_true_iff in H. destruct H as [[[Hf Hnf] Ha] Hs].
  split; [ | split; [ | split ] ].
  - destruct (Genv.find_symbol ge (id "gMarioStates")) as [b|]; [ | discriminate].
    apply Pos.eqb_eq in Hs. congruence.
  - rewrite <- a_pressed_b_eq. exact Ha.
  - intros Hfly. apply flying_b_complete in Hfly. rewrite Hfly in Hnf. discriminate.
  - exists t, res, m'. split.
    + eapply ex_call_sound; eauto.
    + apply flying_b_sound; auto.
Qed.

(* ---------------------------------------------------------------------- *)
(* THE POSITIVE CONTROL                                                    *)
(* ---------------------------------------------------------------------- *)

Theorem A_pressed_frame_reaches_flying : forall lp,
    linked12 lp ->
    (forall ef args m t v m', flat_world ef args m = Some (t, v, m') ->
       external_call ef (globalenv lp) args m t v m') ->
    exists bm m m',
      Genv.find_symbol (globalenv lp) (id "gMarioStates") = Some bm /\
      a_pressed_real bm m = true /\
      ~ mem_flying_lp bm m /\
      execute_mario_action_step_lp lp m m' /\
      mem_flying_lp bm m'.
Proof.
  intros lp Hlink Hworld.
  pose proof witness_ok_true as W. unfold witness_ok in W.
  rewrite (ge12_ok lp Hlink), (ast12_ok lp Hlink) in W.
  destruct (build (globalenv lp) (program_of_program lp)) as [[[m bm] bobj]|];
    [ | discriminate].
  destruct (check_gen_sound FUEL (Internal mario.f_execute_mario_action) _ _ _ _ Hworld W)
    as [Hs [Ha [Hnf [t [res [m' [Hev Hf]]]]]]].
  exists bm, m, m'. repeat split; auto.
  exists bobj, t, res. exact Hev.
Qed.
