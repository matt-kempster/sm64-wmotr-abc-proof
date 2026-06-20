(* ====================================================================== *)
(* THE PERFORM_WATER_STEP SURFACE                                          *)
(*                                                                        *)
(* The water twin of PerformAirStepSurface.  Discharges the capstone's     *)
(* Hcp_pws_real residual                                                   *)
(*   call_pres lp bm (NoA_real bm) MWF                                     *)
(*     mario_actions_submerged._perform_water_step                         *)
(* by WALKING the whole body of perform_water_step.  Two internal callees  *)
(* are walked / carried one call-graph level down:                         *)
(*   - perform_water_full_step (pwfs): a stripped perform_air_quarter_step  *)
(*     (paqs) -- WALKED here (pwfs_cp), resting only on the SAME gated      *)
(*     externals the paqs walk consumes (resolve / find_floor /            *)
(*     vec3f_find_ceil / vec3f_copy-window / vec3f_set-window).  Its arg1   *)
(*     _nextPos is a pointer PARAMETER pinned local by the paqs gate.       *)
(*   - apply_water_current (apw): a whirlpool-current writer through its    *)
(*     _step float* PARAM (a local block under the gate) -- carried as the  *)
(*     one new residual Hcp_apw (call_pres_paqs), to be walked later.       *)
(* vec3f_copy / vec3s_set in perform_water_step ride the SAME ungated       *)
(* obj_ext boundary the pas walk uses (kit_scallx_pres + call_pres_ext).    *)
(*                                                                        *)
(* All generated TUs share ONE ident table (vm_compute-verified), so the    *)
(* mario_actions_submerged idents for the shared externals ARE the          *)
(* mario_step idents the capstone already carries -- pwfs adds NO new        *)
(* external rows; only Hcp_apw is new at the capstone.                      *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Linking Integers Floats Values Ctypes
     Cop Clight ClightBigstep Clightdefs Memory Events Globalenvs.
From SM64.Generated Require mario mario_step mario_actions_submerged.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame RealFrameLinked
     Flying Taint CensusV2 EngineV2Consumer RestSurface FloorsSurface DispatchKit
     LocalVarsSurface OutParamSurface ActWriterSurface PerformAirStepSurface.
Import ListNotations.

Module Sub := mario_actions_submerged.

(* the Mario-pointer type (shared composite ident across all TUs) *)
Definition tyMSstp : type := tptr (Tstruct Sub._MarioState noattr).
Definition tSurfp : type := tptr (Tstruct Sub._Surface noattr).

(* ====================================================================== *)
(* recognizer: perform_water_full_step (pwfs)                              *)
(* ====================================================================== *)
Definition pwfs_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (Pos.eqb fid Sub._resolve_and_return_wall_collisions
   && proj_sumbool (type_eq fty
        (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil) tSurfp cc_default))
   && match al with
      | Etempvar q tq :: Econst_single _ _ :: Econst_single _ _ :: nil =>
          Pos.eqb q Sub._nextPos && proj_sumbool (type_eq tq (tptr tfloat))
      | _ => false
      end)
  || OutParamSurface.oc_call_chk (Sub._floor :: Sub._ceil :: nil)
       (Sub._find_floor :: Sub._vec3f_find_ceil :: nil) fid fty al
  || (Pos.eqb fid Sub._vec3f_copy
      && proj_sumbool (type_eq fty
           (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default))
      && match al with
         | Efield (Ederef (Etempvar mp tmp) tsm) fld tfa :: Etempvar q tq :: nil =>
             Pos.eqb mp Sub._m && Pos.eqb fld Sub._pos && Pos.eqb q Sub._nextPos
             && proj_sumbool (type_eq tmp tyMSstp)
             && proj_sumbool (type_eq tsm (Tstruct Sub._MarioState noattr))
             && proj_sumbool (type_eq tfa (tarray tfloat 3))
             && proj_sumbool (type_eq tq (tptr tfloat))
         | _ => false
         end)
  || (Pos.eqb fid Sub._vec3f_set
      && proj_sumbool (type_eq fty
           (Tfunction (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil)
              (tptr tvoid) cc_default))
      && match al with
         | Efield (Ederef (Etempvar mp tmp) tsm) fld tfa :: _ :: _ :: _ :: nil =>
             Pos.eqb mp Sub._m && Pos.eqb fld Sub._pos
             && proj_sumbool (type_eq tmp tyMSstp)
             && proj_sumbool (type_eq tsm (Tstruct Sub._MarioState noattr))
             && proj_sumbool (type_eq tfa (tarray tfloat 3))
         | _ => false
         end).

Fixpoint pwfs_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 => pwfs_chk s1 && pwfs_chk s2
  | Sifthenelse _ s1 s2 => pwfs_chk s1 && pwfs_chk s2
  | Sset id _ => negb (Pos.eqb id Sub._m) && negb (Pos.eqb id Sub._nextPos)
  | Sassign a1 _ => safe_mfield_store Sub._m a1 || idx_mfield_store Sub._m a1
  | Scall optid (Evar fid fty) al =>
      (match optid with
       | Some id => negb (Pos.eqb id Sub._m) && negb (Pos.eqb id Sub._nextPos)
       | None => true
       end)
      && pwfs_call_chk fid fty al
  | _ => false
  end.

Lemma pwfs_pin :
  (prog_defmap Sub.prog) ! Sub._perform_water_full_step
  = Some (Gfun (Internal Sub.f_perform_water_full_step)).
Proof. vm_compute. reflexivity. Qed.

Lemma pwfs_chk_body :
  pwfs_chk (fn_body Sub.f_perform_water_full_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* recognizer: perform_water_step (pws) -- the pas twin                    *)
(* ====================================================================== *)
Definition pws_assign_chk (a1 : expr) : bool :=
  idx_mfield_store Sub._m a1
  || match a1 with
     | Ederef (Ebinop Oadd (Evar lid (Tarray ety sz attr))
                 (Econst_int _ tci) itya) ety2 =>
         Pos.eqb lid Sub._nextPos
         && proj_sumbool (type_eq (Tarray ety sz attr) (tarray tfloat 3))
         && proj_sumbool (type_eq tci tint)
         && proj_sumbool (type_eq itya (tptr tfloat))
         && proj_sumbool (type_eq ety2 tfloat)
     | _ => false
     end.

Definition pws_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (Pos.eqb fid Sub._apply_water_current
   && proj_sumbool (type_eq fty
        (Tfunction (tyMSstp :: tptr tfloat :: nil) tvoid cc_default))
   && match al with
      | Etempvar mp tmp :: Evar q tq :: nil =>
          Pos.eqb mp Sub._m && Pos.eqb q Sub._step
          && proj_sumbool (type_eq tmp tyMSstp)
          && proj_sumbool (type_eq tq (tarray tfloat 3))
      | _ => false
      end)
  || (Pos.eqb fid Sub._perform_water_full_step
      && proj_sumbool (type_eq fty
           (Tfunction (tyMSstp :: tptr tfloat :: nil) tuint cc_default))
      && match al with
         | Etempvar mp tmp :: Evar q tq :: nil =>
             Pos.eqb mp Sub._m && Pos.eqb q Sub._nextPos
             && proj_sumbool (type_eq tmp tyMSstp)
             && proj_sumbool (type_eq tq (tarray tfloat 3))
         | _ => false
         end)
  || (Pos.eqb fid Sub._vec3f_copy
      && proj_sumbool (type_eq fty
           (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default)))
  || (Pos.eqb fid Sub._vec3s_set
      && proj_sumbool (type_eq fty
           (Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
              (tptr tvoid) cc_default))).

Definition pws_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id Sub._m)
  | None => true
  end.

Fixpoint pws_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 => pws_chk s1 && pws_chk s2
  | Sifthenelse _ s1 s2 => pws_chk s1 && pws_chk s2
  | Sset id _ => pws_optid_ok (Some id)
  | Sassign a1 _ => pws_assign_chk a1
  | Scall optid (Evar fid fty) al => pws_optid_ok optid && pws_call_chk fid fty al
  | _ => false
  end.

Lemma pws_pin :
  (prog_defmap Sub.prog) ! Sub._perform_water_step
  = Some (Gfun (Internal Sub.f_perform_water_step)).
Proof. vm_compute. reflexivity. Qed.

Lemma pws_chk_body :
  pws_chk (fn_body Sub.f_perform_water_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* THE SURFACE SECTION                                                     *)
(* ====================================================================== *)
Section WaterStepSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_stp : linkorder mario_step.prog lp.
  Hypothesis LO_sub : linkorder Sub.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.
  Hypothesis HSafeValid :
    forall m, MWF m -> forall b, SafeB b -> Mem.valid_block m b.
  Hypothesis HGlobValid :
    forall m, MWF m -> forall gid bg,
        Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg.
  Hypothesis Hls_real :
    forall m ch b (d : Z) v m',
      local_blk lp bm SafeB b ->
      Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.

  (* pwfs gated-external rows -- SAME idents as the paqs walk consumes. *)
  Hypothesis Hocp_resolve :
    call_pres_ext_ol lp bm NoA MWF SafeB Sub._resolve_and_return_wall_collisions.
  Hypothesis Hocp_ff :
    call_pres_ext_oc lp bm NoA MWF SafeB Sub._find_floor.
  Hypothesis Hocp_vfc :
    call_pres_ext_oc lp bm NoA MWF SafeB Sub._vec3f_find_ceil.
  Hypothesis Hw1cp_v3f :
    call_pres_ext_w1 lp bm NoA MWF Sub._vec3f_copy.
  Hypothesis Hw1cp_v3fset :
    call_pres_ext_w1 lp bm NoA MWF Sub._vec3f_set.

  (* ==================================================================== *)
  (* pwfs decoder                                                         *)
  (* ==================================================================== *)
  Lemma pwfs_call_decode :
    forall fid fty al, pwfs_call_chk fid fty al = true ->
      (fid = Sub._resolve_and_return_wall_collisions /\
       fty = Tfunction (tptr tfloat :: tfloat :: tfloat :: nil) tSurfp cc_default /\
       exists c1 t1 c2 t2,
         al = Etempvar Sub._nextPos (tptr tfloat)
              :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
      \/ OutParamSurface.oc_call_chk (Sub._floor :: Sub._ceil :: nil)
           (Sub._find_floor :: Sub._vec3f_find_ceil :: nil) fid fty al = true
      \/ (fid = Sub._vec3f_copy /\
          fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default /\
          al = Efield (Ederef (Etempvar Sub._m tyMSstp)
                  (Tstruct Sub._MarioState noattr)) Sub._pos (tarray tfloat 3)
               :: Etempvar Sub._nextPos (tptr tfloat) :: nil)
      \/ (fid = Sub._vec3f_set /\
          fty = Tfunction (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil)
                  (tptr tvoid) cc_default /\
          exists a2 a3 a4,
            al = Efield (Ederef (Etempvar Sub._m tyMSstp)
                    (Tstruct Sub._MarioState noattr)) Sub._pos (tarray tfloat 3)
                 :: a2 :: a3 :: a4 :: nil).
  Proof.
    intros fid fty al H. unfold pwfs_call_chk in H.
    apply orb_true_iff in H as [H | Hvs].
    apply orb_true_iff in H as [H | Hvc].
    apply orb_true_iff in H as [Hres | Hoc].
    - (* resolve *)
      left.
      apply andb_true_iff in Hres as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
                  tSurfp cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | q tq | | | | | | | | ]; try discriminate Hal.
      destruct al0 as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | c1 t1 | | | | | | | | | | | ]; try discriminate Hal.
      destruct al1 as [ | a2 al2 ]; try discriminate Hal.
      destruct a2 as [ | | c2 t2 | | | | | | | | | | | ]; try discriminate Hal.
      destruct al2; try discriminate Hal.
      apply andb_true_iff in Hal as [Hq Htq].
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq tq (tptr tfloat)) as [-> | ]; [ | discriminate Htq ].
      exists c1, t1, c2, t2. reflexivity.
    - (* oc *) right; left. exact Hoc.
    - (* vec3f_copy *)
      right; right; left.
      apply andb_true_iff in Hvc as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                  (tptr tvoid) cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 tail ]; try discriminate Hal.
      destruct a0 as [ | | | | | | | | | | | ef fld tfa | | ]; try discriminate Hal.
      destruct ef as [ | | | | | | edb edt | | | | | | | ]; try discriminate Hal.
      destruct edb as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct tail as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | | q tq | | | | | | | | ]; try discriminate Hal.
      destruct al1; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Htq].
      apply andb_true_iff in Hal as [Hal Htfa].
      apply andb_true_iff in Hal as [Hal Htsm].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hal Hq].
      apply andb_true_iff in Hal as [Hmp Hfld].
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hfld; subst fld.
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq tmp tyMSstp) as [-> | ]; [ | discriminate Htmp ].
      destruct (type_eq edt (Tstruct Sub._MarioState noattr)) as [-> | ];
        [ | discriminate Htsm ].
      destruct (type_eq tfa (tarray tfloat 3)) as [-> | ]; [ | discriminate Htfa ].
      destruct (type_eq tq (tptr tfloat)) as [-> | ]; [ | discriminate Htq ].
      reflexivity.
    - (* vec3f_set *)
      right; right; right.
      apply andb_true_iff in Hvs as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil)
                  (tptr tvoid) cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 tail ]; try discriminate Hal.
      destruct a0 as [ | | | | | | | | | | | ef fld tfa | | ]; try discriminate Hal.
      destruct ef as [ | | | | | | edb edt | | | | | | | ]; try discriminate Hal.
      destruct edb as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct tail as [ | b1 [ | b2 [ | b3 al3 ] ] ]; try discriminate Hal.
      destruct al3; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Htfa].
      apply andb_true_iff in Hal as [Hal Htsm].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hmp Hfld].
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hfld; subst fld.
      destruct (type_eq tmp tyMSstp) as [-> | ]; [ | discriminate Htmp ].
      destruct (type_eq edt (Tstruct Sub._MarioState noattr)) as [-> | ];
        [ | discriminate Htsm ].
      destruct (type_eq tfa (tarray tfloat 3)) as [-> | ]; [ | discriminate Htfa ].
      exists b1, b2, b3. reflexivity.
  Qed.

  (* ==================================================================== *)
  (* pwfs body walk.  _nextPos is a pointer PARAM pinned local (Hnp/Hnploc) *)
  (* exactly as paqs pins its _intendedPos param.                          *)
  (* ==================================================================== *)
  Lemma pwfs_walk_pres :
    forall npb npo,
      local_blk lp bm SafeB npb ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        pwfs_chk s = true ->
        (forall l, mem_id l (Sub._floor :: Sub._ceil :: nil) = true ->
           exists lblk tyenv, e ! l = Some (lblk, tyenv)
                              /\ local_blk lp bm SafeB lblk) ->
        e ! Sub._resolve_and_return_wall_collisions = None ->
        e ! Sub._find_floor = None ->
        e ! Sub._vec3f_find_ceil = None ->
        e ! Sub._vec3f_copy = None ->
        e ! Sub._vec3f_set = None ->
        (forall b o, le ! Sub._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        le ! Sub._nextPos = Some (Vptr npb npo) ->
        carried bm NoA MWF m0 ->
        carried bm NoA MWF m' /\
        (forall b o, le' ! Sub._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) /\
        le' ! Sub._nextPos = Some (Vptr npb npo).
  Proof.
    intros npb npo Hnploc s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hchk Hlids Hrn Hff Hvfc Hvc Hvs Hm Hnp Hc.
    - (* Sskip *) exact (conj Hc (conj Hm Hnp)).
    - (* Sassign a1 a2 *)
      cbn [pwfs_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct Hc as (HV & HS & HM & HN).
      apply orb_true_iff in Hchk as [Hsf | Hidx].
      + destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm Hnp)).
      + destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hidx Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm Hnp)).
    - (* Sset id a: id <> _m, _nextPos *)
      cbn [pwfs_chk] in Hchk.
      apply andb_true_iff in Hchk as [Hnm Hnnp].
      apply negb_true_iff in Hnm; apply negb_true_iff in Hnnp.
      refine (conj Hc (conj _ _)).
      + intros b o Hg.
        rewrite PTree.gso in Hg by (intro EE; subst id;
          rewrite Pos.eqb_refl in Hnm; discriminate Hnm).
        exact (Hm b o Hg).
      + rewrite PTree.gso by (intro EE; subst id;
          rewrite Pos.eqb_refl in Hnnp; discriminate Hnnp).
        exact Hnp.
    - (* Scall optid a al *)
      cbn [pwfs_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t
                      (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : (forall b o,
                       (set_opttemp optid vres le) ! Sub._m
                       = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) /\
                    (set_opttemp optid vres le) ! Sub._nextPos
                    = Some (Vptr npb npo)).
      { destruct optid as [oid | ]; cbn [set_opttemp].
        - apply andb_true_iff in Hopt as [Hom Hoip].
          apply negb_true_iff in Hom; apply negb_true_iff in Hoip.
          split.
          + intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
              rewrite Pos.eqb_refl in Hom; discriminate Hom). exact (Hm b o Hg).
          + rewrite PTree.gso by (intro EE; subst oid;
              rewrite Pos.eqb_refl in Hoip; discriminate Hoip). exact Hnp.
        - split; [ exact Hm | exact Hnp ]. }
      destruct (pwfs_call_decode _ _ _ Hcc)
        as [ (Hfeq & Hftyeq & (c1 & t1c & c2 & t2c & Haleq))
           | [ Hoc
             | [ (Hfeq & Hftyeq & Haleq)
               | (Hfeq & Hftyeq & (b1 & b2 & b3 & Haleq)) ] ] ].
      + (* resolve(nextPos, c1, c2): ol gate *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Etempvar Sub._nextPos (tptr tfloat)
               :: Econst_single c1 t1c :: Econst_single c2 t2c :: nil)
              (tptr tfloat :: tfloat :: tfloat :: nil) vargs ->
            args_all_local lp bm SafeB vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          inversion Htl1 as [ | a2 bl2 ty2 tyl2 v1b v2b vl2 Hev_b Hsc_b Htl2 ];
            subst; clear Htl1.
          inversion Htl2 as [ | a3 bl3 ty3 tyl3 v1c v2c vl3 Hev_c Hsc_c Htl3 ];
            subst; clear Htl2.
          inversion Htl3; subst; clear Htl3.
          apply RealFrameValue.eval_expr_Etempvar_val in Hev_a.
          rewrite Hnp in Hev_a; injection Hev_a as <-.
          apply AutomaticLeafSurface.eval_Econst_single_val in Hev_b; subst v1b.
          apply AutomaticLeafSurface.eval_Econst_single_val in Hev_c; subst v1c.
          intros bb oo Hin; cbn in Hin.
          destruct Hin as [E | [E | [E | []]]]; subst;
          [ apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_a;
            injection Hsc_a as <- <-; exact Hnploc
          | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_b;
            discriminate Hsc_b
          | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_c;
            discriminate Hsc_c ]. }
        destruct (ol_scall_pres lp bm NoA MWF SafeB optid
                    Sub._resolve_and_return_wall_collisions
                    (tptr tfloat :: tfloat :: tfloat :: nil) tSurfp cc_default
                    (Etempvar Sub._nextPos (tptr tfloat)
                     :: Econst_single c1 t1c :: Econst_single c2 t2c :: nil)
                    e le m _ _ m' _ Hrn Hocp_resolve Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* oc: find_floor / vec3f_find_ceil *)
        assert (Hcp_oc : forall g,
                  mem_id g (Sub._find_floor :: Sub._vec3f_find_ceil :: nil) = true ->
                  call_pres_ext_oc lp bm NoA MWF SafeB g).
        { intros g Hg. cbn [mem_id existsb] in Hg.
          apply orb_true_iff in Hg as [Eg | Hg];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hocp_ff | ].
          apply orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hocp_vfc
            | discriminate F ]. }
        assert (Hnone : forall g,
                  mem_id g (Sub._find_floor :: Sub._vec3f_find_ceil :: nil) = true ->
                  e ! g = None).
        { intros g Hg. cbn [mem_id existsb] in Hg.
          apply orb_true_iff in Hg as [Eg | Hg];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hff | ].
          apply orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hvfc | discriminate F ]. }
        destruct (oc_call_chk_pres lp bm NoA MWF SafeB
                    (Sub._floor :: Sub._ceil :: nil)
                    (Sub._find_floor :: Sub._vec3f_find_ceil :: nil)
                    optid fid fty al e le m _ _ m' _
                    Hcp_oc Hnone Hlids Hoc Hex Hc) as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* vec3f_copy(m->pos, nextPos): w1 gate (dst = m->pos window) *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Efield (Ederef (Etempvar Sub._m tyMSstp)
                  (Tstruct Sub._MarioState noattr)) Sub._pos (tarray tfloat 3)
               :: Etempvar Sub._nextPos (tptr tfloat) :: nil)
              (tptr tfloat :: tptr tfloat :: nil) vargs ->
            arg0_window bm vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          destruct (AutomaticLeafSurface.pos_window_val lp LO_mario bm _ _ _ _ Hm Hev_a)
            as (o0 & Ev0 & Hwin0).
          subst v1a. cbn in Hsc_a. injection Hsc_a as <-.
          red. exists o0, vl1. split; [ reflexivity | exact Hwin0 ]. }
        destruct (w1_scall_pres lp bm NoA MWF optid Sub._vec3f_copy
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default
                    (Efield (Ederef (Etempvar Sub._m tyMSstp)
                       (Tstruct Sub._MarioState noattr)) Sub._pos (tarray tfloat 3)
                     :: Etempvar Sub._nextPos (tptr tfloat) :: nil)
                    e le m _ _ m' _ Hvc Hw1cp_v3f Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* vec3f_set(m->pos, b1, b2, b3): w1 gate (dst = m->pos window) *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Efield (Ederef (Etempvar Sub._m tyMSstp)
                  (Tstruct Sub._MarioState noattr)) Sub._pos (tarray tfloat 3)
               :: b1 :: b2 :: b3 :: nil)
              (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil) vargs ->
            arg0_window bm vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          destruct (AutomaticLeafSurface.pos_window_val lp LO_mario bm _ _ _ _ Hm Hev_a)
            as (o0 & Ev0 & Hwin0).
          subst v1a. cbn in Hsc_a. injection Hsc_a as <-.
          red. exists o0, vl1. split; [ reflexivity | exact Hwin0 ]. }
        destruct (w1_scall_pres lp bm NoA MWF optid Sub._vec3f_set
                    (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil)
                    (tptr tvoid) cc_default
                    (Efield (Ederef (Etempvar Sub._m tyMSstp)
                       (Tstruct Sub._MarioState noattr)) Sub._pos (tarray tfloat 3)
                     :: b1 :: b2 :: b3 :: nil)
                    e le m _ _ m' _ Hvs Hw1cp_v3fset Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
    - (* Sbuiltin: rejected *)
      cbn [pwfs_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [pwfs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hlids Hrn Hff Hvfc Hvc Hvs Hm Hnp Hc)
        as (Hc1 & Hm1 & Hnp1).
      exact (IHHexec2 H2 Hlids Hrn Hff Hvfc Hvc Hvs Hm1 Hnp1 Hc1).
    - (* Sseq_2 (s1 aborts) *)
      cbn [pwfs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hlids Hrn Hff Hvfc Hvc Hvs Hm Hnp Hc).
    - (* Sifthenelse *)
      cbn [pwfs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc (conj Hm Hnp)).
    - (* Sreturn (Some _) *) exact (conj Hc (conj Hm Hnp)).
    - (* Sbreak *) exact (conj Hc (conj Hm Hnp)).
    - (* Scontinue *) exact (conj Hc (conj Hm Hnp)).
    - (* Sloop stop1: rejected *)
      cbn [pwfs_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: rejected *)
      cbn [pwfs_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: rejected *)
      cbn [pwfs_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [pwfs_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ==================================================================== *)
  (* pwfs entry assembly: discharge call_pres_paqs for perform_water_full_step *)
  (* params [_m; _nextPos]  (arg0 marg, arg1 local), fn_vars [_ceil; _floor]    *)
  (* ==================================================================== *)
  Lemma pwfs_cp :
    call_pres_paqs lp bm NoA MWF SafeB Sub._perform_water_full_step.
  Proof.
    unfold call_pres_paqs.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hgate HN HM HV HS.
    pose proof (OutParamSurface.resolve_pin_fd lp Sub.prog _
                  Sub.f_perform_water_full_step fd LO_sub pwfs_pin Hres)
      as ->.
    destruct Hgate as (Hcond & Hlocal).
    (* ---- entry ---- *)
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold Sub.f_perform_water_full_step in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _ceil/_floor fn_vars: watched-disjoint stack blocks *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (Sub._floor :: Sub._ceil :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hmem];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_cons; apply in_eq
                        | apply Bool.orb_true_iff in Hmem;
                          destruct Hmem as [He | Hf];
                          [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                            apply in_eq
                          | discriminate Hf ] ]))
      as Hlids.
    (* bind the 2 params _m, _nextPos *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_np vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2; [ | cbn [bind_parameter_temps] in Hbind;
                      discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! Sub._m = Some v_m)
      by (rewrite <- Hle_init;
          rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss).
    assert (Hnpeq : le1 ! Sub._nextPos = Some v_np)
      by (rewrite <- Hle_init; apply PTree.gss).
    (* _m conditional from arg0_marg_p *)
    cbn [arg0_marg_p] in Hcond.
    assert (Hmcond : forall b o,
               le1 ! Sub._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero)
      by (intros b o Hg; rewrite Hmeq in Hg; injection Hg as Hg;
          apply (Hcond b o Hg)).
    (* _nextPos local from arg1_local *)
    cbn [arg1_local arg1_val] in Hlocal.
    destruct Hlocal as (npb & npo & Hvnp & Hnploc).
    injection Hvnp as Hvnp; subst v_np.
    (* the 5 callees are unbound in the entry env *)
    assert (Hrn : eloc !
              Sub._resolve_and_return_wall_collisions = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._resolve_and_return_wall_collisions)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hff : eloc ! Sub._find_floor = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._find_floor)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvfc : eloc ! Sub._vec3f_find_ceil = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._vec3f_find_ceil)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvc : eloc ! Sub._vec3f_copy = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._vec3f_copy)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvs : eloc ! Sub._vec3f_set = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._vec3f_set)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (pwfs_walk_pres npb npo Hnploc _ _ _ _ _ _ _ _
                Hbody pwfs_chk_body Hlids Hrn Hff Hvfc Hvc Hvs Hmcond Hnpeq Hcar)
      as (Hcarr & _ & _).
    (* ---- exit: free the fn_var stack blocks ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ _ Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf (conj HMf HNf))).
  Qed.

  (* ==================================================================== *)
  (* pws-only callee rows.                                                 *)
  (*  - apply_water_current: the whirlpool-current writer through its      *)
  (*    _step float* PARAM (local under the gate) -- the SAME paqs gate     *)
  (*    (arg0 marg, arg1 local).  Carried as the one new residual.          *)
  (*  - vec3f_copy / vec3s_set: the ungated obj_ext boundary (their dst     *)
  (*    is `step` (local) or `marioObj->...gfx` (a chased SafeB pool        *)
  (*    block), never bm) -- the SAME treatment the pas walk uses.          *)
  (* ==================================================================== *)
  Hypothesis Hcp_apw :
    call_pres_paqs lp bm NoA MWF SafeB Sub._apply_water_current.
  Hypothesis Hcpx_v3f :
    call_pres_ext lp bm NoA MWF Sub._vec3f_copy.
  Hypothesis Hcpx_v3s :
    call_pres_ext lp bm NoA MWF Sub._vec3s_set.

  (* ==================================================================== *)
  (* the paqs gate at a (Etempvar _m :: Evar <fn_var array> :: nil) call   *)
  (* site: arg0 = _m under the marg conditional, arg1 = the local stack    *)
  (* array (By_reference decay to its local_blk base).                      *)
  (* ==================================================================== *)
  Lemma pws_arg2_gate :
    forall e le m lid lb lty vargs,
      (forall b o, le ! Sub._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      e ! lid = Some (lb, lty) ->
      local_blk lp bm SafeB lb ->
      eval_exprlist (lp_ge lp) e le m
        (Etempvar Sub._m tyMSstp :: Evar lid (tarray tfloat 3) :: nil)
        (tyMSstp :: tptr tfloat :: nil) vargs ->
      paqs_gate lp bm SafeB vargs.
  Proof.
    intros e le m lid lb lty vargs Hmarg Helid Hloc Hvl.
    inv Hvl.
    match goal with H : eval_exprlist _ _ _ _ (Evar _ _ :: _) _ _ |- _ => inv H end.
    match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
    (* arg0: the marg conditional *)
    match goal with
    | He : eval_expr _ _ _ _ (Etempvar Sub._m _) ?v0 |- _ =>
        apply RealFrameValue.eval_expr_Etempvar_val in He
    end.
    match goal with
    | He : le ! Sub._m = Some ?v0,
      Hc : sem_cast ?v0 _ _ _ = Some ?vc |- _ =>
        assert (Hv0 : forall b o, vc = Vptr b o -> b = bm /\ o = Ptrofs.zero)
          by (intros b o Heqvc; rewrite Heqvc in Hc; cbn in Hc;
              destruct v0 as [| ? | ? | ? | ? | b1 o1 ]; cbn in Hc;
              try discriminate Hc;
              injection Hc as Hb Ho; subst b1 o1; exact (Hmarg b o He))
    end.
    (* arg1: the Evar lid local *)
    match goal with
    | He : eval_expr _ _ _ _ (Evar _ _) ?v1 |- _ => inv He
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
    end;
    [ | match goal with
        | Hn : e ! lid = None |- _ => rewrite Helid in Hn; discriminate Hn
        end ].
    match goal with
    | He : e ! lid = Some (?loc, _) |- _ =>
        assert (loc = lb) by congruence; subst loc
    end.
    match goal with
    | Hd : deref_loc _ _ lb _ _ _ |- _ =>
        cbn [typeof] in Hd; inv Hd;
        try (match goal with
             | Hac : access_mode _ = By_value _ |- _ =>
                 cbn in Hac; discriminate Hac
             end);
        try (match goal with
             | Hac : access_mode _ = By_copy |- _ =>
                 cbn in Hac; discriminate Hac
             end);
        try (match goal with
             | Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb
             end)
    end.
    match goal with
    | Hc : sem_cast (Vptr lb _) _ _ _ = Some _ |- _ =>
        cbn in Hc; injection Hc as <-
    end.
    split.
    - cbn [arg0_marg_p]. exact Hv0.
    - red. cbn [arg1_val]. exists lb, Ptrofs.zero.
      split; [ reflexivity | exact Hloc ].
  Qed.

  (* ==================================================================== *)
  (* pws decoders                                                          *)
  (* ==================================================================== *)
  Lemma pws_assign_decode :
    forall a1, pws_assign_chk a1 = true ->
      idx_mfield_store Sub._m a1 = true
      \/ exists idxN,
          a1 = Ederef (Ebinop Oadd
                         (Evar Sub._nextPos (tarray tfloat 3))
                         (Econst_int idxN tint) (tptr tfloat)) tfloat.
  Proof.
    intros a1 H. unfold pws_assign_chk in H.
    apply orb_true_iff in H as [Hidx | Hnp]; [ left; exact Hidx | right ].
    destruct a1 as [ | | | | | | ein eity | | | | | | | ]; try discriminate Hnp.
    destruct ein as [ | | | | | | | | | bop e1 e2 bty | | | | ];
      try discriminate Hnp.
    destruct bop; try discriminate Hnp.
    destruct e1 as [ | | | | vid vty | | | | | | | | | ]; try discriminate Hnp.
    destruct vty as [ | | | | | aty asz aattr | | | ]; try discriminate Hnp.
    destruct e2 as [ ic ict | | | | | | | | | | | | | ]; try discriminate Hnp.
    apply andb_true_iff in Hnp as [Hnp He2y].
    apply andb_true_iff in Hnp as [Hnp Hity].
    apply andb_true_iff in Hnp as [Hnp Hict].
    apply andb_true_iff in Hnp as [Hlid Harr].
    apply Pos.eqb_eq in Hlid; subst vid.
    destruct (type_eq (Tarray aty asz aattr) (tarray tfloat 3))
      as [Ea | ]; [ | discriminate Harr ].
    destruct (type_eq ict tint) as [Ei | ]; [ subst ict | discriminate Hict ].
    destruct (type_eq bty (tptr tfloat)) as [Eb | ]; [ subst bty | discriminate Hity ].
    destruct (type_eq eity tfloat) as [Ee | ]; [ subst eity | discriminate He2y ].
    rewrite Ea. exists ic. reflexivity.
  Qed.

  Lemma pws_call_decode :
    forall fid fty al, pws_call_chk fid fty al = true ->
      (fid = Sub._apply_water_current /\
       fty = Tfunction (tyMSstp :: tptr tfloat :: nil) tvoid cc_default /\
       al = Etempvar Sub._m tyMSstp
            :: Evar Sub._step (tarray tfloat 3) :: nil)
      \/ (fid = Sub._perform_water_full_step /\
          fty = Tfunction (tyMSstp :: tptr tfloat :: nil) tuint cc_default /\
          al = Etempvar Sub._m tyMSstp
               :: Evar Sub._nextPos (tarray tfloat 3) :: nil)
      \/ (fid = Sub._vec3f_copy /\
          fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                  cc_default)
      \/ (fid = Sub._vec3s_set /\
          fty = Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
                  (tptr tvoid) cc_default).
  Proof.
    intros fid fty al H. unfold pws_call_chk in H.
    apply orb_true_iff in H as [H | Hv3s].
    apply orb_true_iff in H as [H | Hv3f].
    apply orb_true_iff in H as [Hapw | Hpwfs].
    - (* apply_water_current *)
      left.
      apply andb_true_iff in Hapw as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tyMSstp :: tptr tfloat :: nil) tvoid
                  cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct al0 as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
      destruct al1; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Htq].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hmp Hq].
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq tmp tyMSstp) as [E1 | ]; [ subst tmp | discriminate Htmp ].
      destruct (type_eq tq (tarray tfloat 3)) as [E2 | ];
        [ subst tq | discriminate Htq ].
      reflexivity.
    - (* perform_water_full_step *)
      right; left.
      apply andb_true_iff in Hpwfs as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tyMSstp :: tptr tfloat :: nil) tuint
                  cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct al0 as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
      destruct al1; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Htq].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hmp Hq].
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq tmp tyMSstp) as [E1 | ]; [ subst tmp | discriminate Htmp ].
      destruct (type_eq tq (tarray tfloat 3)) as [E2 | ];
        [ subst tq | discriminate Htq ].
      reflexivity.
    - (* vec3f_copy *)
      right; right; left.
      apply andb_true_iff in Hv3f as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                  (tptr tvoid) cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | exact Efty ].
    - (* vec3s_set *)
      right; right; right.
      apply andb_true_iff in Hv3s as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction
                  (tptr tshort :: tshort :: tshort :: tshort :: nil)
                  (tptr tvoid) cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | exact Efty ].
  Qed.

  (* ==================================================================== *)
  (* pws body walk.  _nextPos and _step are the two fn_var stack arrays    *)
  (* passed as out-params to the gated pwfs / apw calls; both pinned local *)
  (* by their env bindings.                                                *)
  (* ==================================================================== *)
  Lemma pws_walk_pres :
    forall npb npty sb sty,
      local_blk lp bm SafeB npb ->
      local_blk lp bm SafeB sb ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        pws_chk s = true ->
        e ! Sub._apply_water_current = None ->
        e ! Sub._perform_water_full_step = None ->
        e ! Sub._vec3f_copy = None ->
        e ! Sub._vec3s_set = None ->
        e ! Sub._nextPos = Some (npb, npty) ->
        e ! Sub._step = Some (sb, sty) ->
        (forall b o, le ! Sub._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        carried bm NoA MWF m0 ->
        carried bm NoA MWF m' /\
        (forall b o, le' ! Sub._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero).
  Proof.
    intros npb npty sb sty Hnploc Hstloc s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hchk Hapw_n Hpwfs_n Hv3f_n Hv3s_n Hnp Hstep Hm Hc.
    - (* Sskip *) exact (conj Hc Hm).
    - (* Sassign a1 a2 *)
      cbn [pws_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct (pws_assign_decode _ Hchk) as [Hidx | (idxN & ->)].
      + (* m->vel[1] indexed window store *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hidx Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))) Hm).
      + (* nextPos[i] indexed fn_var local store *)
        destruct (local_idx_assign_pres' lp bm NoA MWF SafeB Hls_real
                    HNoA_of_MWF e Sub._nextPos tfloat 3%Z noattr
                    idxN (tptr tfloat) tfloat a2 le m E0 le m' Out_normal
                    npb npty Mfloat32 Hnp Hnploc eq_refl Hex Hc)
          as (Hc' & _ & _).
        exact (conj Hc' Hm).
    - (* Sset id a: id <> _m (pws_optid_ok) *)
      cbn [pws_chk pws_optid_ok] in Hchk.
      apply negb_true_iff in Hchk.
      refine (conj Hc _).
      intros b o Hg.
      rewrite PTree.gso in Hg by (intro EE; subst id; rewrite Pos.eqb_refl in Hchk;
                                  discriminate Hchk).
      exact (Hm b o Hg).
    - (* Scall optid a al *)
      cbn [pws_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t (set_opttemp optid vres le)
                      m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : forall b o,
                 (set_opttemp optid vres le) ! Sub._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { cbn [pws_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply negb_true_iff in Hopt.
          intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt; discriminate Hopt). exact (Hm b o Hg).
        - exact Hm. }
      destruct (pws_call_decode _ _ _ Hcc)
        as [ (Hfeq & Hftyeq & Haleq)
           | [ (Hfeq & Hftyeq & Haleq)
             | [ (Hfeq & Hftyeq) | (Hfeq & Hftyeq) ] ] ];
        subst fid fty.
      + (* apply_water_current(m, step): the paqs-gated helper (Hcp_apw) *)
        subst al.
        destruct (paqs_scall_pres lp bm NoA MWF SafeB optid
                    Sub._apply_water_current
                    (tyMSstp :: tptr tfloat :: nil) tvoid cc_default
                    (Etempvar Sub._m tyMSstp
                       :: Evar Sub._step (tarray tfloat 3) :: nil)
                    e le m _ _ m' _ Hapw_n Hcp_apw
                    ltac:(intros vargs1 Hvl;
                          exact (pws_arg2_gate e le m Sub._step sb sty _
                                   Hm Hstep Hstloc Hvl))
                    Hex Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* perform_water_full_step(m, nextPos): pwfs_cp (in-surface) *)
        subst al.
        destruct (paqs_scall_pres lp bm NoA MWF SafeB optid
                    Sub._perform_water_full_step
                    (tyMSstp :: tptr tfloat :: nil) tuint cc_default
                    (Etempvar Sub._m tyMSstp
                       :: Evar Sub._nextPos (tarray tfloat 3) :: nil)
                    e le m _ _ m' _ Hpwfs_n pwfs_cp
                    ltac:(intros vargs1 Hvl;
                          exact (pws_arg2_gate e le m Sub._nextPos npb npty _
                                   Hm Hnp Hnploc Hvl))
                    Hex Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* vec3f_copy: ungated obj_ext external *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid Sub._vec3f_copy
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default
                    al e le m _ _ m' _ Hv3f_n Hex Hcpx_v3f HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
      + (* vec3s_set: ungated obj_ext external *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid Sub._vec3s_set
                    (tptr tshort :: tshort :: tshort :: tshort :: nil)
                    (tptr tvoid) cc_default
                    al e le m _ _ m' _ Hv3s_n Hex Hcpx_v3s HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
    - (* Sbuiltin: rejected *)
      cbn [pws_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [pws_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hapw_n Hpwfs_n Hv3f_n Hv3s_n Hnp Hstep Hm Hc)
        as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hapw_n Hpwfs_n Hv3f_n Hv3s_n Hnp Hstep Hm1 Hc1).
    - (* Sseq_2 (s1 aborts) *)
      cbn [pws_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hapw_n Hpwfs_n Hv3f_n Hv3s_n Hnp Hstep Hm Hc).
    - (* Sifthenelse *)
      cbn [pws_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc Hm).
    - (* Sreturn (Some _) *) exact (conj Hc Hm).
    - (* Sbreak *) exact (conj Hc Hm).
    - (* Scontinue *) exact (conj Hc Hm).
    - (* Sloop stop1: rejected (pws is straight-line) *)
      cbn [pws_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: rejected *)
      cbn [pws_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: rejected *)
      cbn [pws_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [pws_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ==================================================================== *)
  (* pws entry: the whole perform_water_step body preserves carried.       *)
  (* params [_m], fn_vars [_filler; _nextPos; _step].                       *)
  (* ==================================================================== *)
  Lemma pws_body_pres :
    body_pres lp NoA MWF bm Sub.f_perform_water_step.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hgate Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hgate; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold Sub.f_perform_water_step in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _nextPos / _step fn_vars: watched-disjoint stack arrays *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (Sub._nextPos :: Sub._step :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hmem];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_cons; apply in_eq
                        | apply Bool.orb_true_iff in Hmem;
                          destruct Hmem as [He | Hf];
                          [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                            apply in_cons; apply in_cons; apply in_eq
                          | discriminate Hf ] ]))
      as Hlids.
    destruct (Hlids Sub._nextPos eq_refl) as (npb & npty & Hnp & Hnploc).
    destruct (Hlids Sub._step eq_refl) as (sb & sty & Hstep & Hstloc).
    (* bind the 1 param _m *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1; [ | cbn [bind_parameter_temps] in Hbind; discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! Sub._m = Some v_m)
      by (rewrite <- Hle_init; apply PTree.gss).
    assert (Hmcond : forall b o,
               le1 ! Sub._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite Hmeq in Hg. injection Hg as Hg.
      subst v_m. exact Hmarg. }
    (* the 4 callees are unbound in the entry env *)
    assert (Hapw_none : eloc ! Sub._apply_water_current = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._apply_water_current)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hpwfs_none : eloc ! Sub._perform_water_full_step = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._perform_water_full_step)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hv3f_none : eloc ! Sub._vec3f_copy = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._vec3f_copy)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hv3s_none : eloc ! Sub._vec3s_set = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 Sub._vec3s_set)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (pws_walk_pres npb npty sb sty Hnploc Hstloc _ _ _ _ _ _ _ _
                Hbody pws_chk_body Hapw_none Hpwfs_none Hv3f_none Hv3s_none
                Hnp Hstep Hmcond Hcar)
      as (Hcarr & _).
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* THE DISCHARGE *)
  Lemma pws_cp :
    call_pres lp bm NoA MWF Sub._perform_water_step.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF Sub.prog
             Sub._perform_water_step Sub.f_perform_water_step
             LO_sub pws_pin pws_body_pres).
  Qed.

End WaterStepSurface.
