(* ======================================================================= *)
(* EntryWarp (GOAL 2): the stores that put the game IN WMotR, run as the   *)
(* generated Clight of the linked program (area.c linked, 2026-10-21).     *)
(*                                                                          *)
(* HeightFrame.in_wmotr reads gCurrLevelNum.  Before area.c was linked     *)
(* that global had a size-0 block, so in_wmotr was false on every memory   *)
(* real code reaches from boot and no from-boot run could take a           *)
(* frame_step.  Now it has area.c's storage (initialised to LEVEL_MIN = 1),*)
(* and the entry path's two stores run here as real code:                  *)
(*                                                                          *)
(*  1. initiate_warp(LEVEL_WMOTR, 1, 0x0A, 0) (level_update.c:615), the    *)
(*     call initiate_delayed_warp makes for a warp node whose destination  *)
(*     is WMotR's area 1 node 0x0A.  Its WHOLE generated body runs as an    *)
(*     eval_funcall from any memory where gCurrLevelNum <> LEVEL_WMOTR:    *)
(*     sWarpDest := {type 1 (WARP_TYPE_CHANGE_LEVEL), level 31, area 1,    *)
(*     node 10, arg 0} (initiate_warp_runs).  The arguments are WMotR's    *)
(*     own warp node 0x0A, decoded from the generated level script          *)
(*     (wmotr_warp_node_0A); the castle-side painting node that sends Mario*)
(*     there (castle_inside/script.c) is not generated, so that the castle  *)
(*     node has the same destination is read from source.                  *)
(*  2. init_level -> warp_level (level_update.c:477), whose generated body  *)
(*     starts gCurrLevelNum = sWarpDest.levelNum; that statement runs here *)
(*     (warp_level_head_runs) and stores 31 into gCurrLevelNum.            *)
(*                                                                          *)
(* NOT run: the level script between the two (lvl_init_or_update, the       *)
(* level loads), and the rest of warp_level (level_control_timer,          *)
(* load_area -> load_area_terrain, which is surface_load.c (not linked),    *)
(* init_mario_after_warp).  StartSat stores those effects as the cells      *)
(* WMotREntry reads off the generated code.                                 *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require level_update area wmotr_script.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve WMotRLevel.
Import ListNotations.

Local Open Scope Z_scope.

(* ----------------------------------------------------------------------- *)
(* 0. The warp node every entry targets, decoded from the generated script.*)
(*    WARP_NODE(id, destLevel, destArea, destNode, flags) is two words:    *)
(*    0x2608 id destLevel, then destArea destNode flags 0                   *)
(*    (level_commands.h).                                                   *)
(* ----------------------------------------------------------------------- *)
Fixpoint warp_node_dest (l : list init_data) (id : Z) : option (Z * Z * Z) :=
  match l with
  | Init_int32 h :: (Init_int32 w :: _) as r =>
      if Z.eqb (Z.shiftr (Int.unsigned h) 16) 0x2608
         && Z.eqb (Z.land (Z.shiftr (Int.unsigned h) 8) 255) id
      then Some (Z.land (Int.unsigned h) 255, Z.shiftr (Int.unsigned w) 24,
                 Z.land (Z.shiftr (Int.unsigned w) 16) 255)
      else warp_node_dest r id
  | _ :: r => warp_node_dest r id
  | nil => None
  end.

Definition WARP_AREA : Z := 1.
Definition WARP_NODE : Z := 10.

(* WMotR's warp node 0x0A: destination (LEVEL_WMOTR, area 1, node 0x0A) *)
Lemma wmotr_warp_node_0A :
  warp_node_dest (gvar_init wmotr_script.v_level_wmotr_entry) 10
  = Some (LEVEL_WMOTR, WARP_AREA, WARP_NODE).
Proof. vm_compute. reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* 1. The real bodies, by name.                                             *)
(* ----------------------------------------------------------------------- *)
Definition iw_args : list val :=
  [Vint (Int.repr LEVEL_WMOTR); Vint (Int.repr WARP_AREA); Vint (Int.repr WARP_NODE);
   Vint Int.zero].

(* warp_level's first statement: gCurrLevelNum = sWarpDest.levelNum *)
Definition warp_level_head : statement :=
  match fn_body level_update.f_warp_level with
  | Ssequence s _ => s
  | _ => Sskip
  end.

Lemma warp_level_head_eq :
  warp_level_head =
  Ssequence
    (Sset level_update._t'2
       (Efield (Evar level_update._sWarpDest (Tstruct level_update._WarpDest noattr))
          level_update._levelNum tuchar))
    (Sassign (Evar level_update._gCurrLevelNum tshort)
       (Etempvar level_update._t'2 tuchar)).
Proof. reflexivity. Qed.

Definition WD_MEMBERS : members :=
  [Member_plain level_update._type tuchar; Member_plain level_update._levelNum tuchar;
   Member_plain level_update._areaIdx tuchar; Member_plain level_update._nodeId tuchar;
   Member_plain level_update._arg tuint].

Lemma wd_lookup :
  option_map co_members ((prog_comp_env level_update.prog) ! level_update._WarpDest)
  = Some WD_MEMBERS.
Proof. vm_compute. reflexivity. Qed.

Section EntryExec.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bw bL : block.
  Hypothesis Hbw : Genv.find_symbol (lp_ge lp) level_update._sWarpDest = Some bw.
  Hypothesis HbL : Genv.find_symbol (lp_ge lp) level_update._gCurrLevelNum = Some bL.

  (* the linked composite env has level_update's WarpDest *)
  Lemma cenv_wd : exists co, (genv_cenv (lp_ge lp)) ! level_update._WarpDest = Some co
                             /\ co_members co = WD_MEMBERS.
  Proof.
    pose proof (linked12_LO_lvl lp H12) as LO.
    Local Transparent Linker_program.
    destruct LO as [_ Hce].
    pose proof wd_lookup as W.
    destruct ((prog_comp_env level_update.prog) ! level_update._WarpDest) as [co | ] eqn:E;
      [ | discriminate W ].
    exists co. split; [ exact (Hce _ _ E) | injection W as W; exact W ].
  Qed.

  Lemma fo_wd : forall ce fld delta,
      (fld = level_update._type /\ delta = 0) \/ (fld = level_update._levelNum /\ delta = 1)
      \/ (fld = level_update._areaIdx /\ delta = 2) \/ (fld = level_update._nodeId /\ delta = 3)
      \/ (fld = level_update._arg /\ delta = 4) ->
      field_offset ce fld WD_MEMBERS = OK (delta, Full).
  Proof.
    intros ce fld delta H.
    destruct H as [[-> ->] | [[-> ->] | [[-> ->] | [[-> ->] | [-> ->]]]]];
      vm_compute; reflexivity.
  Qed.

  Lemma ptr_small : forall z, 0 <= z <= 4 -> 0 <= z <= Ptrofs.max_unsigned.
  Proof.
    intros z H. unfold Ptrofs.max_unsigned, Ptrofs.modulus, Ptrofs.wordsize, Wordsize_Ptrofs.wordsize.
    destruct Archi.ptr64; cbn; lia.
  Qed.

  (* a store into a field of the global sWarpDest *)
  Lemma exec_wd_store : forall e le m fld delta ty ch a2 v v' m',
      e ! level_update._sWarpDest = None ->
      field_offset (genv_cenv (lp_ge lp)) fld WD_MEMBERS = OK (delta, Full) ->
      access_mode ty = By_value ch -> type_is_volatile ty = false ->
      eval_expr (lp_ge lp) e le m a2 v ->
      sem_cast v (typeof a2) ty m = Some v' ->
      0 <= delta <= 4 ->
      Mem.store ch m bw delta v' = Some m' ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (Sassign (Efield (Evar level_update._sWarpDest (Tstruct level_update._WarpDest noattr))
                   fld ty) a2) E0 le m' Out_normal.
  Proof.
    intros e le m fld delta ty ch a2 v v' m' He Hfo Hac Hvol Hev Hc Hd Hst.
    destruct cenv_wd as (co & Hco & Hmem).
    eapply exec_Sassign.
    - eapply eval_Efield_struct.
      + eapply eval_Elvalue.
        * eapply eval_Evar_global; [ exact He | exact Hbw ].
        * eapply deref_loc_copy. reflexivity.
      + reflexivity.
      + exact Hco.
      + rewrite Hmem. exact Hfo.
    - exact Hev.
    - exact Hc.
    - eapply assign_loc_value; [ exact Hac | ].
      cbn [Mem.storev]. rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr
        by (apply ptr_small; lia).
      exact Hst.
  Qed.

  (* ===================================================================== *)
  (* 2. initiate_warp(LEVEL_WMOTR, 1, 0x0A, 0): the whole body.            *)
  (* ===================================================================== *)
  Lemma initiate_warp_resolves :
    exists b, Genv.find_symbol (lp_ge lp) level_update._initiate_warp = Some b
              /\ Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero)
                 = Some (Internal level_update.f_initiate_warp).
  Proof.
    apply (linkorder_resolves_funct lp level_update.prog _ _ (linked12_LO_lvl lp H12)).
    vm_compute. reflexivity.
  Qed.

  Definition iw_le : temp_env :=
    match bind_parameter_temps (fn_params level_update.f_initiate_warp) iw_args
            (create_undef_temps (fn_temps level_update.f_initiate_warp)) with
    | Some le => le
    | None => PTree.empty val
    end.

  Lemma iw_bind :
    bind_parameter_temps (fn_params level_update.f_initiate_warp) iw_args
      (create_undef_temps (fn_temps level_update.f_initiate_warp)) = Some iw_le.
  Proof. reflexivity. Qed.

  Lemma iw_body_eq :
    fn_body level_update.f_initiate_warp =
    Ssequence
      (Sifthenelse (Ebinop Oge (Etempvar level_update._destWarpNode tshort)
                     (Econst_int (Int.repr 248) tint) tint)
        (Sassign
          (Efield (Evar level_update._sWarpDest (Tstruct level_update._WarpDest noattr))
             level_update._type tuchar)
          (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset level_update._t'1 (Evar level_update._gCurrLevelNum tshort))
          (Sifthenelse (Ebinop One (Etempvar level_update._destLevel tshort)
                         (Etempvar level_update._t'1 tshort) tint)
            (Sassign
              (Efield (Evar level_update._sWarpDest (Tstruct level_update._WarpDest noattr))
                 level_update._type tuchar)
              (Econst_int (Int.repr 1) tint))
            (match fn_body level_update.f_initiate_warp with
             | Ssequence (Sifthenelse _ _ (Ssequence _ (Sifthenelse _ _ s))) _ => s
             | _ => Sskip
             end))))
      (Ssequence
        (Sassign
          (Efield (Evar level_update._sWarpDest (Tstruct level_update._WarpDest noattr))
             level_update._levelNum tuchar)
          (Etempvar level_update._destLevel tshort))
        (Ssequence
          (Sassign
            (Efield (Evar level_update._sWarpDest (Tstruct level_update._WarpDest noattr))
               level_update._areaIdx tuchar)
            (Etempvar level_update._destArea tshort))
          (Ssequence
            (Sassign
              (Efield (Evar level_update._sWarpDest (Tstruct level_update._WarpDest noattr))
                 level_update._nodeId tuchar)
              (Etempvar level_update._destWarpNode tshort))
            (Sassign
              (Efield (Evar level_update._sWarpDest (Tstruct level_update._WarpDest noattr))
                 level_update._arg tuint)
              (Etempvar level_update._arg3 tint))))).
  Proof. reflexivity. Qed.

  Lemma empty_none : forall i, (empty_env : env) ! i = None.
  Proof. intro. apply PTree.gempty. Qed.

  Lemma cmp_ne_31 : forall ce m l, Int.eq (Int.repr LEVEL_WMOTR) l = false ->
      sem_binary_operation ce One (Vint (Int.repr LEVEL_WMOTR)) tshort (Vint l) tshort m
      = Some (Vint Int.one).
  Proof.
    intros ce m l H.
    unfold sem_binary_operation, sem_cmp. cbn.
    unfold sem_binarith, sem_cast, classify_cast, binarith_type, classify_binarith. cbn.
    destruct Archi.ptr64; cbn; rewrite H; reflexivity.
  Qed.

  Lemma iw_entry : forall m,
      function_entry2 (lp_ge lp) level_update.f_initiate_warp iw_args m empty_env iw_le m.
  Proof.
    intro m. constructor.
    - constructor.
    - apply (proj_sumbool_true (list_norepet_dec ident_eq _)). vm_compute. reflexivity.
    - apply (proj_sumbool_true (list_disjoint_dec ident_eq _ _)). vm_compute. reflexivity.
    - constructor.
    - exact iw_bind.
  Qed.

  (* initiate_warp(31, 1, 10, 0) from any memory whose gCurrLevelNum is not
     already 31 (the castle's, LEVEL_CASTLE = 6, in the game; LEVEL_MIN = 1
     at boot) runs its real body and does exactly these five stores *)
  Theorem initiate_warp_runs : forall m l m1 m2 m3 m4 m5,
      Mem.load Mint16signed m bL 0 = Some (Vint l) ->
      Int.eq (Int.repr LEVEL_WMOTR) l = false ->
      Mem.store Mint8unsigned m bw 0 (Vint (Int.repr 1)) = Some m1 ->
      Mem.store Mint8unsigned m1 bw 1 (Vint (Int.repr LEVEL_WMOTR)) = Some m2 ->
      Mem.store Mint8unsigned m2 bw 2 (Vint (Int.repr WARP_AREA)) = Some m3 ->
      Mem.store Mint8unsigned m3 bw 3 (Vint (Int.repr WARP_NODE)) = Some m4 ->
      Mem.store Mint32 m4 bw 4 (Vint Int.zero) = Some m5 ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal level_update.f_initiate_warp)
        iw_args E0 m5 Vundef.
  Proof.
    intros m l m1 m2 m3 m4 m5 Hl Hne S1 S2 S3 S4 S5.
    eapply eval_funcall_internal with (out := Out_normal) (le2 := PTree.set level_update._t'1 (Vint l) iw_le);
      [ exact (iw_entry m) | | exact eq_refl | reflexivity ].
    rewrite iw_body_eq.
    change E0 with (E0 ** E0). eapply exec_Sseq_1.
    { (* destWarpNode = 10 < 248; then gCurrLevelNum = l <> 31: type := 1 *)
      eapply exec_Sifthenelse.
      - econstructor; [ econstructor; reflexivity | econstructor | vm_compute; reflexivity ].
      - vm_compute. reflexivity.
      - change E0 with (E0 ** E0). eapply exec_Sseq_1.
        + eapply exec_Sset. eapply eval_Elvalue.
          * eapply eval_Evar_global; [ apply empty_none | exact HbL ].
          * eapply deref_loc_value; [ reflexivity | exact Hl ].
        + eapply exec_Sifthenelse.
          * econstructor; [ econstructor; reflexivity | econstructor; reflexivity | ].
            exact (cmp_ne_31 _ _ _ Hne).
          * reflexivity.
          * eapply exec_wd_store with (delta := 0) (ch := Mint8unsigned);
              [ apply empty_none | apply fo_wd; tauto | reflexivity | reflexivity
              | econstructor | vm_compute; reflexivity | lia | exact S1 ]. }
    change E0 with (E0 ** E0). eapply exec_Sseq_1.
    { eapply exec_wd_store with (delta := 1) (ch := Mint8unsigned);
        [ apply empty_none | apply fo_wd; tauto | reflexivity | reflexivity
        | econstructor; reflexivity | vm_compute; reflexivity | lia | exact S2 ]. }
    change E0 with (E0 ** E0). eapply exec_Sseq_1.
    { eapply exec_wd_store with (delta := 2) (ch := Mint8unsigned);
        [ apply empty_none | apply fo_wd; tauto | reflexivity | reflexivity
        | econstructor; reflexivity | vm_compute; reflexivity | lia | exact S3 ]. }
    change E0 with (E0 ** E0). eapply exec_Sseq_1.
    { eapply exec_wd_store with (delta := 3) (ch := Mint8unsigned);
        [ apply empty_none | apply fo_wd; tauto | reflexivity | reflexivity
        | econstructor; reflexivity | vm_compute; reflexivity | lia | exact S4 ]. }
    eapply exec_wd_store with (delta := 4) (ch := Mint32);
      [ apply empty_none | apply fo_wd; tauto | reflexivity | reflexivity
      | econstructor; reflexivity | vm_compute; reflexivity | lia | exact S5 ].
  Qed.

  (* ===================================================================== *)
  (* 3. warp_level's head: gCurrLevelNum = sWarpDest.levelNum.             *)
  (* ===================================================================== *)
  Theorem warp_level_head_runs : forall le m lv m',
      Mem.load Mint8unsigned m bw 1 = Some (Vint lv) ->
      Mem.store Mint16signed m bL 0 (Vint (Int.sign_ext 16 lv)) = Some m' ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m warp_level_head E0
        (PTree.set level_update._t'2 (Vint lv) le) m' Out_normal.
  Proof.
    intros le m lv m' Hl Hst.
    destruct cenv_wd as (co & Hco & Hmem).
    rewrite warp_level_head_eq.
    change E0 with (E0 ** E0). eapply exec_Sseq_1.
    - eapply exec_Sset. eapply eval_Elvalue.
      + eapply eval_Efield_struct.
        * eapply eval_Elvalue.
          -- eapply eval_Evar_global; [ apply empty_none | exact Hbw ].
          -- eapply deref_loc_copy. reflexivity.
        * reflexivity.
        * exact Hco.
        * rewrite Hmem. apply fo_wd. tauto.
      + eapply deref_loc_value; [ reflexivity | ].
        cbn [Mem.loadv]. rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr
          by (apply ptr_small; lia).
        exact Hl.
    - eapply exec_Sassign.
      + eapply eval_Evar_global; [ apply empty_none | exact HbL ].
      + econstructor. apply PTree.gss.
      + cbn [typeof]. unfold sem_cast, classify_cast. cbn.
        destruct Archi.ptr64; reflexivity.
      + eapply assign_loc_value; [ reflexivity | exact Hst ].
  Qed.

  (* ===================================================================== *)
  (* 4. The boot image's gCurrLevelNum: area.c's LEVEL_MIN = 1.            *)
  (* ===================================================================== *)
  Lemma dm_lvlnum : (prog_defmap area.prog) ! level_update._gCurrLevelNum
                    = Some (Gvar area.v_gCurrLevelNum).
  Proof. vm_compute. reflexivity. Qed.

  Lemma boot_levelnum : forall m0, Genv.init_mem lp = Some m0 ->
      Mem.load Mint16signed m0 bL 0 = Some (Vint (Int.repr 1)).
  Proof.
    intros m0 Hinit.
    pose proof (linked12_LO_area lp H12) as LOq.
    Local Transparent Linker_program.
    unfold linkorder, Linker_program, linkorder_program in LOq.
    destruct LOq as [LOast _].
    destruct (prog_defmap_linkorder _ _ _ _ LOast dm_lvlnum) as (gd' & Hgd' & Hlo).
    change (prog_defmap (program_of_program lp)) with (prog_defmap lp) in Hgd'.
    inv Hlo. match goal with H : linkorder _ _ |- _ => inv H end.
    match goal with H : linkorder _ i2 |- _ => inv H end.
    apply Genv.find_def_symbol in Hgd' as (b' & Hfs' & Hfd).
    change (Genv.globalenv (program_of_program lp)) with (Genv.globalenv lp) in Hfs', Hfd.
    change (Genv.find_symbol (Genv.globalenv lp) level_update._gCurrLevelNum = Some bL) in HbL.
    rewrite HbL in Hfs'. injection Hfs' as <-.
    pose proof Hinit as GI. apply Genv.init_mem_characterization_gen in GI.
    specialize (GI bL _ Hfd). cbn in GI. destruct GI as (_ & _ & Hli & _).
    specialize (Hli eq_refl). cbn in Hli. destruct Hli as [Hl _].
    rewrite Mem.load_int16_signed_unsigned, Hl. reflexivity.
  Qed.

  (* the two together: from a memory with gCurrLevelNum <> 31, the real
     initiate_warp call then warp_level's head leave gCurrLevelNum = 31 *)
  Lemma entry_levelnum : forall m m',
      Mem.store Mint16signed m bL 0 (Vint (Int.repr LEVEL_WMOTR)) = Some m' ->
      Mem.load Mint16signed m' bL 0 = Some (Vint (Int.repr LEVEL_WMOTR)).
  Proof.
    intros m m' Hst. rewrite (Mem.load_store_same _ _ _ _ _ _ Hst). reflexivity.
  Qed.

End EntryExec.
