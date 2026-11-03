(* kept: AudioInv at boot (2026-11-02).  Consumed by the deferred root
   rebuild (FfWorld.lvl_w's aud_w clause, proved at the start witness). *)
(* ====================================================================== *)
(* AudioBoot.v -- AudioInv holds on the boot images, by vm.               *)
(*                                                                        *)
(* Two memories, both computed from the real 53-TU link:                 *)
(*   - Genv.init_mem (the boot image);                                     *)
(*   - the GOAL-2 start witness, m11 of StartTerrain.wit_chain (the real  *)
(*     entry, 2026-11-03: the level script's commands run through the     *)
(*     real handlers, then init_level / warp_level /                       *)
(*     init_mario_after_warp; the stand-ins are StartTerrain's header     *)
(*     table).  THE WITNESS IS NAMED ONCE: aud_wit.                         *)
(*                                                                        *)
(* Both memories have NO pointer in any audio block (the audio thread and *)
(* audio_init are not linked: the audio state is its zero initializers).  *)
(* ====================================================================== *)
From Coq Require Import String List ZArith Lia.
From compcert Require Import Coqlib Maps Integers Floats Values AST Memory Memdata Globalenvs
  Ctypes Clight ClightBigstep Events.
From SM64.Proofs Require Import Interp.ClightInterp Interp.LinkGenv Interp.MemBuild
  Interp.InitMemC Interp.InterpFrame.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import CensusV2 SpawnInit LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec FfWorld WMotRWorld
  HeightInvariant WMotRLevel WMotREntry EntryWarp TerrainRun StartTerrain.
From SM64.Generated Require mario level_update object_list_processor surface_load
  surface_collision wmotr_script graph_node area memory camera interaction game_init.
From SM64.Proofs.WMotRRequiresA Require ObjWorld.
From SM64.Proofs.NoAImpliesNoFly Require BootRun.
From SM64.Proofs.WMotRRequiresA Require Import AudioInv.
Import ListNotations.
Module CM := SM64.Proofs.Interp.CMem.
Arguments Done {A}.

(* THE WITNESS (re-point here) *)
Definition aud_wit (ge : genv) (m0 : mem) : option mem :=
  match wit_chain ge m0 with Some (_, _, _, _, _, m11) => Some m11 | None => None end.

Definition aud_boot_gen (oge : option genv) (oast : option (AST.program (Ctypes.fundef function) type)) : bool :=
  match oge, oast with
  | Some ge, Some ast =>
      match alloc_globals_c (Genv.globalenv ast) Mem.empty (AST.prog_defs ast) with
      | Some m0 => aud_chk ge m0 && match aud_wit ge m0 with Some m => aud_chk ge m | None => false end
      | None => false
      end
  | _, _ => false
  end.

Lemma aud_boot_gen_true : aud_boot_gen ge12 ast12 = true.
Proof. vm_cast_no_check (eq_refl true). Qed.

Lemma aud_boot_chk : forall lp, linked12 lp -> forall m0, Genv.init_mem lp = Some m0 ->
    aud_chk (globalenv lp) m0 = true
    /\ exists m, aud_wit (globalenv lp) m0 = Some m /\ aud_chk (globalenv lp) m = true.
Proof.
  intros lp H12 m0 Hinit.
  pose proof aud_boot_gen_true as W. unfold aud_boot_gen in W.
  rewrite (ge12_ok lp H12), (ast12_ok lp H12) in W.
  rewrite (init_mem_c _ _ Hinit) in W.
  apply andb_prop in W as [W0 W1]. split; [ exact W0 | ].
  destruct (aud_wit (globalenv lp) m0) as [m|]; [ | discriminate W1 ].
  exists m. split; [ reflexivity | exact W1 ].
Qed.

(* THE RESULT: AudioInv on the boot image and on the start witness *)
Theorem audio_inv_boot : forall lp, linked12 lp -> forall m0, Genv.init_mem lp = Some m0 ->
    AudioInv (globalenv lp) m0
    /\ exists m, aud_wit (globalenv lp) m0 = Some m /\ AudioInv (globalenv lp) m.
Proof.
  intros lp H12 m0 Hinit.
  destruct (aud_boot_chk lp H12 m0 Hinit) as (C0 & m & Ew & C1).
  split; [ exact (aud_chk_sound _ _ C0) | exists m; split; [ exact Ew | exact (aud_chk_sound _ _ C1) ] ].
Qed.
