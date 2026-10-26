(* ====================================================================== *)
(* LevelGvars (GOAL 2): the globals the level phase of play_mode_normal   *)
(* writes (2026-10-24, LevelFlank / LevelWalk / LevelKeep).               *)
(*                                                                        *)
(* Every store the walked level code makes lands in one of these blocks   *)
(* (LevelWalk checks each store's root against the list), except the two  *)
(* counters update_hud_values writes in gMarioStates (numCoins, numLives; *)
(* LevelWalk.lv_W):                                                       *)
(*   - the PRE slice: gHudDisplay.timer;                                  *)
(*   - the POST slice minus the camera: update_hud_values (gHudDisplay,   *)
(*     play_sound's queue), initiate_delayed_warp and its callees (the    *)
(*     warp / transition / dialog / cutscene statics, the save buffer and *)
(*     its dirty flags, the warp checkpoint, the credits cursor, the     *)
(*     sound banks), the play-mode switch (sCurrPlayMode,                 *)
(*     gCameraMovementFlags, lower_background_noise's music volumes and   *)
(*     the sequence players).                                             *)
(* The list joins AnimWorld.flank_gvars, so the frame world keeps these   *)
(* blocks apart from Mario's object and off the surface partition.        *)
(* ====================================================================== *)

From Coq Require Import List.
From compcert Require Import Coqlib AST.
From SM64.Generated Require level_update camera audio_external sound_init ingame_menu
  save_file.
Import ListNotations.

(* the written globals minus the three warp cells FfWorld.lvl_w pins *)
Definition lvl_safe_gvars : list ident :=
  [ level_update._gHudDisplay; audio_external._sSoundRequests;
    audio_external._sSoundRequestCount; level_update._sDelayedWarpTimer;
    level_update._D_80339ECA;
    level_update._D_80339EE0; level_update._gCameraMovementFlags;
    level_update._sTransitionTimer; level_update._sTransitionUpdate;
    ingame_menu._gDialogBoxScale; ingame_menu._gDialogBoxAngle; ingame_menu._gMenuState;
    ingame_menu._gDialogID; ingame_menu._gDialogPageStartStrIndex;
    ingame_menu._gDialogWithChoice; ingame_menu._gNextDialogPageStartStrIndex;
    ingame_menu._gDialogResponse; camera._sObjectCutscene; camera._sCutsceneDialogResponse;
    save_file._gSaveBuffer; save_file._gMainMenuDataModified; save_file._gSaveFileModified;
    save_file._gWarpCheckpoint; level_update._gCurrActNum;
    audio_external._sSoundBankDisabled; sound_init._sMusicVolume;
    audio_external._sLowerBackgroundMusicVolume; audio_external._gSequencePlayers ].

(* the warp cells the level phase writes (initiate_warp, set_play_mode /
   warp_special, the credits arms of initiate_delayed_warp) *)
Definition warp_gvars : list ident :=
  [ level_update._sWarpDest; level_update._sCurrPlayMode; level_update._gCurrCreditsEntry ].

Definition level_gvars : list ident := lvl_safe_gvars ++ warp_gvars.
