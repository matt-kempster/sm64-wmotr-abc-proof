(* ====================================================================== *)
(* THE INTERACTIONS SURFACE: Hpres_inter DISCHARGED DOWN TO ITS LEAVES    *)
(* (SPINE: consumed by the MWF-grounded capstone).                        *)
(*                                                                        *)
(* f_mario_process_interactions is the LAST whole-handler internal        *)
(* residual: the loop over the 31-entry sInteractionHandlers table that   *)
(* calls the interact_* handlers THROUGH FUNCTION POINTERS loaded from a  *)
(* WRITABLE global table.  The walk is the first to discharge an          *)
(* indirect call:                                                         *)
(*   - the handler-slot load (_t'16 = sInteractionHandlers[i].handler)    *)
(*     is pinned by the OFFSET-FREE MWF table row (mwf_real_itab): any    *)
(*     pointer-valued Mptr load from the table block is one of the 29     *)
(*     censused interact_* symbols at offset zero -- NO field_offset or   *)
(*     loop-range reasoning;                                              *)
(*   - the indirect Scall's find_funct forces the function value to       *)
(*     (block, 0); the pin + the census-internal vm fact + linkorder      *)
(*     resolve it to THE real generated handler body;                     *)
(*   - the handler residual is the GATED class body_pres_io (explicit     *)
(*     m/interactType/object arg shape): a plain body_pres would be a     *)
(*     PHANTOM forall-object -- FALSE for handlers that store through     *)
(*     their object argument.                                             *)
(*                                                                        *)
(* The walk swaps the capstone's opaque Hpres_inter for:                  *)
(*   Hpres_ihandler (29 census-keyed handler bodies, body_pres_io)        *)
(*   + Hcp_mgco (mario_get_collided_object: marg-gated, SafeB-if-ptr      *)
(*     RETURN -- its return seeds the _object chase temp)                 *)
(*   + Hcp_ckpw (check_kick_or_punch_wall: the ordinary call_pres class). *)
(* Both helpers are Internal in interaction.prog: walkable later.         *)
(* DECOMPOSE, NOT COLLAPSE: 1 opaque body -> 31 named, walkable residuals.*)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_actions_airborne interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface AutomaticLeafSurface
  LocalVarsSurface OutParamSurface MWFReal.

Import ListNotations.

(* ====================================================================== *)
(* Shared types (ident sharing across TUs holds: interaction._MarioState  *)
(* = mario._MarioState, so tyMSp serves the interaction body verbatim).   *)
(* ====================================================================== *)

Definition tyObjP : type := tptr (Tstruct interaction._Object noattr).
Definition tyHandlerP : type :=
  tptr (Tfunction (tyMSp :: tuint :: tyObjP :: nil) tuint cc_default).

Example m_ident_shared : interaction._m = mario_actions_airborne._m.
Proof. reflexivity. Qed.
Example ms_ident_shared : interaction._MarioState = mario._MarioState.
Proof. reflexivity. Qed.

(* ====================================================================== *)
(* The recognizer.  Single-column helper booleans throughout (a deep      *)
(* multi-column pattern leaks STUCK goals into the walk's destruct        *)
(* cascade -- the WindSurface lesson).                                    *)
(* ====================================================================== *)

Definition is_table_base (a : expr) : bool :=
  match a with
  | Evar g gty =>
      Pos.eqb g interaction._sInteractionHandlers
      && match gty with Tarray _ _ _ => true | _ => false end
  | _ => false
  end.

Definition is_idx_temp (a : expr) : bool :=
  match a with
  | Etempvar _ ti => proj_sumbool (type_eq ti tint)
  | _ => false
  end.

Definition is_table_elem_addr (a : expr) : bool :=
  match a with
  | Ebinop op ab ai _ =>
      match op with
      | Oadd => is_table_base ab && is_idx_temp ai
      | _ => false
      end
  | _ => false
  end.

Definition is_structy (t : type) : bool :=
  match t with Tstruct _ _ => true | _ => false end.

Definition is_table_elem (a : expr) : bool :=
  match a with
  | Ederef ad ts => is_table_elem_addr ad && is_structy ts
  | _ => false
  end.

Definition is_fptr_ty (t : type) : bool :=
  match t with
  | Tpointer ft _ => match ft with Tfunction _ _ _ => true | _ => false end
  | _ => false
  end.

(* _t'16 = sInteractionHandlers[i].handler *)
Definition is_handler_slot_load (a : expr) : bool :=
  match a with
  | Efield ae fld fpty =>
      is_table_elem ae
      && Pos.eqb fld interaction._handler
      && is_fptr_ty fpty
  | _ => false
  end.

(* _object = _t'2 (the pinned call-result transfer) *)
Definition is_t2_temp (a : expr) : bool :=
  match a with
  | Etempvar q qty => Pos.eqb q interaction._t'2 && is_ptr_ty qty
  | _ => false
  end.

(* Ssets: _m and _t'2 are never Sset targets (the latter only receives
   the mgco call result); _t'16 only from the handler slot; _object only
   from _t'2; every other temp is untracked (loads need no facts). *)
Definition inter_set_chk (id : ident) (a : expr) : bool :=
  negb (Pos.eqb id interaction._m)
  && negb (Pos.eqb id interaction._t'2)
  && (if Pos.eqb id interaction._t'16 then is_handler_slot_load a
      else if Pos.eqb id interaction._object then is_t2_temp a
           else true).

(* stores: the 3 window-checked m->field stores + the 4 censused statics *)
Definition inter_assign_chk (a1 : expr) : bool :=
  safe_mfield_store interaction._m a1 || glob_store_chk a1.

(* a call result may not land in a tracked temp (except _t'2 at the
   pinned mgco site, handled by its own arm) *)
Definition opt_inter_free (optid : option ident) : bool :=
  match optid with
  | None => true
  | Some q =>
      negb (Pos.eqb q interaction._m)
      && negb (Pos.eqb q interaction._t'2)
      && negb (Pos.eqb q interaction._t'16)
      && negb (Pos.eqb q interaction._object)
  end.

Definition is_m_arg (a : expr) : bool :=
  match a with
  | Etempvar p pty =>
      Pos.eqb p interaction._m && proj_sumbool (type_eq pty tyMSp)
  | _ => false
  end.

Definition is_obj_arg (a : expr) : bool :=
  match a with
  | Etempvar ob obty => Pos.eqb ob interaction._object && is_ptr_ty obty
  | _ => false
  end.

(* the three call shapes: t'2 := mario_get_collided_object(m, _);
   check_kick_or_punch_wall(m); the INDIRECT call through _t'16. *)
Definition inter_call_chk (optid : option ident) (a : expr)
    (al : list expr) : bool :=
  match a with
  | Evar fid fty =>
      (Pos.eqb fid interaction._mario_get_collided_object
       && match optid with
          | Some q => Pos.eqb q interaction._t'2
          | None => false
          end
       && match fty with
          | Tfunction tys _ _ =>
              match tys with
              | ty1 :: rest =>
                  proj_sumbool (type_eq ty1 tyMSp)
                  && match rest with _ :: nil => true | _ => false end
              | nil => false
              end
          | _ => false
          end
       && match al with
          | a0 :: rest => is_m_arg a0
                          && match rest with _ :: nil => true | _ => false end
          | nil => false
          end)
      || (Pos.eqb fid interaction._check_kick_or_punch_wall
          && match optid with None => true | Some _ => false end
          && match fty with
             | Tfunction tys _ _ =>
                 match tys with
                 | ty1 :: nil => proj_sumbool (type_eq ty1 tyMSp)
                 | _ => false
                 end
             | _ => false
             end
          && match al with
             | a0 :: nil => is_m_arg a0
             | _ => false
             end)
  | Etempvar fp fpty =>
      Pos.eqb fp interaction._t'16
      && proj_sumbool (type_eq fpty tyHandlerP)
      && opt_inter_free optid
      && match al with
         | a0 :: rest =>
             is_m_arg a0
             && match rest with
                | _ :: rest2 =>
                    match rest2 with
                    | a2 :: nil => is_obj_arg a2
                    | _ => false
                    end
                | nil => false
                end
         | nil => false
         end
  | _ => false
  end.

Fixpoint inter_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak => true
  | Sset id a => inter_set_chk id a
  | Sassign a1 _ => inter_assign_chk a1
  | Scall optid a al => inter_call_chk optid a al
  | Ssequence s1 s2 => inter_chk s1 && inter_chk s2
  | Sloop s1 s2 => inter_chk s1 && inter_chk s2
  | Sifthenelse _ s1 s2 => inter_chk s1 && inter_chk s2
  | _ => false
  end.

(* THE BODY PIN: the real 280-line generated body passes. *)
Example inter_chk_body :
  inter_chk (fn_body interaction.f_mario_process_interactions) = true.
Proof. vm_compute. reflexivity. Qed.

(* the body's shape: no fn_vars (the walk runs at the empty env), one
   MarioState* param *)
Example inter_fn_vars_nil :
  fn_vars interaction.f_mario_process_interactions = nil.
Proof. vm_compute. reflexivity. Qed.

(* mgco / ckpw are Internal in interaction.prog: the two helper residuals
   below are statements about REAL walkable bodies, not externals. *)
Example mgco_internal :
  internal_in (prog_defmap interaction.prog)
    interaction._mario_get_collided_object = true.
Proof. vm_compute. reflexivity. Qed.
Example ckpw_internal :
  internal_in (prog_defmap interaction.prog)
    interaction._check_kick_or_punch_wall = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section InterSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  (* THE TABLE ROW (mwf_real_itab's exact shape): any pointer-valued Mptr
     load from the sInteractionHandlers block is a censused handler symbol
     at offset zero.  OFFSET-FREE: no loop-counter range tracking. *)
  Hypothesis HMWF_itab : forall m tb (ofs : Z) b o,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers
        = Some tb ->
      Mem.load Mptr m tb ofs = Some (Vptr b o) ->
      exists fid,
        In fid interaction_handler_ids /\
        Genv.find_symbol (lp_ge lp) fid = Some b /\
        o = Ptrofs.zero.

  (* ---- THE RESIDUAL CLASSES ---- *)

  (* the GATED per-handler residual: explicit (m, interactType, object)
     argument shape.  vm carries Mario's exact pointer; vo carries the
     SafeB object-pool fact (the mgco return).  A plain body_pres here
     would be a PHANTOM forall-object: FALSE for the handlers that store
     through their object argument. *)
  Definition body_pres_io (f : Clight.function) : Prop :=
    forall m vm vi vo t m' vres,
      (forall b o, vm = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
      (forall b o, vo = Vptr b o -> SafeB b) ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal f)
        (vm :: vi :: vo :: nil) t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm ->
      action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  (* mario_get_collided_object: marg-gated carried preservation + the
     SafeB-if-pointer RETURN (its result is an object-pool slot reached
     from m->collidedObjs -- the chase closure's class).  Internal in
     interaction.prog: dischargeable later by walking that body. *)
  Definition call_pres_mgco : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp lp interaction._mario_get_collided_object fd ->
      marg_ok bm vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\
      (forall b o, vres0 = Vptr b o -> SafeB b).

  Hypothesis Hcp_mgco : call_pres_mgco.
  Hypothesis Hcp_ckpw :
    call_pres lp bm NoA MWF interaction._check_kick_or_punch_wall.
  Hypothesis Hpres_ihandler : forall fid f,
      In fid interaction_handler_ids ->
      (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres_io f.

  (* ---- the threaded temp invariant: only 4 facts (loads need none;
     only store bases, call fn+args, and protected rvalues do). ---- *)
  Definition ile (le : temp_env) : Prop :=
    (forall b o, le ! interaction._m = Some (Vptr b o) ->
                 b = bm /\ o = Ptrofs.zero) /\
    (forall b o, le ! interaction._t'2 = Some (Vptr b o) -> SafeB b) /\
    (forall b o, le ! interaction._object = Some (Vptr b o) -> SafeB b) /\
    (forall b o, le ! interaction._t'16 = Some (Vptr b o) ->
                 exists fid,
                   In fid interaction_handler_ids /\
                   Genv.find_symbol (lp_ge lp) fid = Some b /\
                   o = Ptrofs.zero).

  Ltac id_neq := let E := fresh "E" in intro E; discriminate E.

  Lemma ile_set_other :
    forall le id v,
      Pos.eqb id interaction._m = false ->
      Pos.eqb id interaction._t'2 = false ->
      Pos.eqb id interaction._object = false ->
      Pos.eqb id interaction._t'16 = false ->
      ile le -> ile (PTree.set id v le).
  Proof.
    intros le id v Hm H2 Hob H16 (Im & I2 & Iob & I16).
    refine (conj _ (conj _ (conj _ _))); intros b o Hg;
      rewrite PTree.gso in Hg
        by (intro E; subst id; rewrite Pos.eqb_refl in *; discriminate).
    - exact (Im _ _ Hg).
    - exact (I2 _ _ Hg).
    - exact (Iob _ _ Hg).
    - exact (I16 _ _ Hg).
  Qed.

  Lemma ile_set_t2 :
    forall le v,
      ile le ->
      (forall b o, v = Vptr b o -> SafeB b) ->
      ile (PTree.set interaction._t'2 v le).
  Proof.
    intros le v (Im & I2 & Iob & I16) Hv.
    refine (conj _ (conj _ (conj _ _))); intros b o Hg.
    - rewrite PTree.gso in Hg by id_neq. exact (Im _ _ Hg).
    - rewrite PTree.gss in Hg. injection Hg as ->. exact (Hv _ _ eq_refl).
    - rewrite PTree.gso in Hg by id_neq. exact (Iob _ _ Hg).
    - rewrite PTree.gso in Hg by id_neq. exact (I16 _ _ Hg).
  Qed.

  Lemma ile_set_object :
    forall le v,
      ile le ->
      (forall b o, v = Vptr b o -> SafeB b) ->
      ile (PTree.set interaction._object v le).
  Proof.
    intros le v (Im & I2 & Iob & I16) Hv.
    refine (conj _ (conj _ (conj _ _))); intros b o Hg.
    - rewrite PTree.gso in Hg by id_neq. exact (Im _ _ Hg).
    - rewrite PTree.gso in Hg by id_neq. exact (I2 _ _ Hg).
    - rewrite PTree.gss in Hg. injection Hg as ->. exact (Hv _ _ eq_refl).
    - rewrite PTree.gso in Hg by id_neq. exact (I16 _ _ Hg).
  Qed.

  Lemma ile_set_t16 :
    forall le v,
      ile le ->
      (forall b o, v = Vptr b o ->
         exists fid,
           In fid interaction_handler_ids /\
           Genv.find_symbol (lp_ge lp) fid = Some b /\
           o = Ptrofs.zero) ->
      ile (PTree.set interaction._t'16 v le).
  Proof.
    intros le v (Im & I2 & Iob & I16) Hv.
    refine (conj _ (conj _ (conj _ _))); intros b o Hg.
    - rewrite PTree.gso in Hg by id_neq. exact (Im _ _ Hg).
    - rewrite PTree.gso in Hg by id_neq. exact (I2 _ _ Hg).
    - rewrite PTree.gso in Hg by id_neq. exact (Iob _ _ Hg).
    - rewrite PTree.gss in Hg. injection Hg as ->. exact (Hv _ _ eq_refl).
  Qed.

  (* ================================================================== *)
  (* The handler-slot value brick: a successful POINTER-VALUED          *)
  (* evaluation of sInteractionHandlers[i].handler is a censused        *)
  (* handler symbol at offset zero.  The decode never touches           *)
  (* field_offset or the loop counter: the deref_loc By_value case      *)
  (* yields an Mptr load from the TABLE BLOCK at SOME offset, and the   *)
  (* offset-free table row pins it; the bitfield case yields a Vint     *)
  (* (vacuous); the base block is pinned structurally                   *)
  (* (sem_add_ptrish_block on the Evar-table + index chain).            *)
  (* ================================================================== *)
  Lemma handler_slot_val :
    forall le m0 a v,
      is_handler_slot_load a = true ->
      eval_expr (lp_ge lp) empty_env le m0 a v ->
      MWF m0 ->
      forall b o, v = Vptr b o ->
      exists fid,
        In fid interaction_handler_ids /\
        Genv.find_symbol (lp_ge lp) fid = Some b /\
        o = Ptrofs.zero.
  Proof.
    intros le m0 a v Hrec Hev HM b o ->.
    destruct a as [ ci cty | cf cty | cs cty | cl cty | gid gty | tv tvy
                  | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                  | ae fld fpty | s1' s2' | g1 g2 ];
      try discriminate Hrec.
    cbn [is_handler_slot_load] in Hrec.
    apply andb_prop in Hrec as [Hrec Hfp].
    apply andb_prop in Hrec as [Hel Hfld].
    (* split the Efield read into lvalue + load *)
    apply eval_expr_Efield_load in Hev.
    destruct Hev as (loc & ofs & bf & Hlv & Hdl).
    (* the slot type is a pointer: By_value Mptr; bitfield deref is Vint *)
    destruct fpty as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt pa | a1' a2' a3'
                     | pf pr pc | st1 st2 | un1 un2 ];
      try discriminate Hfp.
    inv Hdl;
      try (match goal with
           | Hac : access_mode (Tpointer _ _) = _ |- _ =>
               cbn in Hac; discriminate Hac
           end).
    2:{ match goal with
        | Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb
        end. }
    match goal with
    | Hac : access_mode (Tpointer _ _) = By_value ?ch |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hldv : Mem.loadv _ _ _ = Some _ |- _ =>
        unfold Mem.loadv in Hldv; rename Hldv into Hld
    end.
    (* the lvalue's block: pinned structurally to the table block *)
    apply eval_lvalue_Efield_base in Hlv.
    destruct Hlv as (o0 & Hbase).
    destruct ae as [ ci cty | cf cty | cs cty | cl cty | gid gty | tv tvy
                   | ad ts | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                   | f1 f2 f3 | s1' s2' | g1 g2 ];
      try discriminate Hel.
    cbn [is_table_elem] in Hel.
    apply andb_prop in Hel as [Had Hts].
    apply eval_expr_Ederef_load in Hbase.
    destruct Hbase as (loc2 & ofs2 & bf2 & Hlv2 & Hdl2).
    destruct ts as [ | ti1 ti2 ti3 | tl1 tl2 | tr1 tr2 | tpt tpa
                   | ta1 ta2 ta3 | tpf tpr tpc | st1 st2 | tun1 tun2 ];
      try discriminate Hts.
    destruct (deref_loc_aggregate_eq (Tstruct st1 st2) m0 loc2 ofs2 bf2 loc o0
                (or_intror eq_refl) Hdl2) as [-> ->].
    apply eval_lvalue_Ederef_base in Hlv2.
    (* the element address: Oadd over the table Evar *)
    destruct ad as [ ci cty | cf cty | cs cty | cl cty | gid gty | tv tvy
                   | da dy | ar ay | u1 u2 u3 | op ab ai bty | c1 c2
                   | f1 f2 f3 | s1' s2' | g1 g2 ];
      try discriminate Had.
    cbn [is_table_elem_addr] in Had.
    destruct op; try discriminate Had.
    apply andb_prop in Had as [Hab _].
    inv Hlv2.
    2:{ match goal with
        | Hlv3 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv3
        end. }
    destruct ab as [ ci cty | cf cty | cs cty | cl cty | g gty | tv tvy
                   | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                   | f1 f2 f3 | s1' s2' | g1 g2 ];
      try discriminate Hab.
    cbn [is_table_base] in Hab.
    apply andb_prop in Hab as [Hg Hgarr].
    apply Pos.eqb_eq in Hg. subst g.
    destruct gty as [ | gi1 gi2 gi3 | gl1 gl2 | gr1 gr2 | gpt gpa
                    | ta tz tat | gpf gpr gpc | gst1 gst2 | gun1 gun2 ];
      try discriminate Hgarr.
    match goal with
    | Hsem : sem_binary_operation ?ce Oadd ?v1 ?t1 ?v2 ?t2 ?mm
               = Some (Vptr ?bb ?oo) |- _ =>
        destruct (sem_add_ptrish_block ce v1 t1 v2 t2 mm bb oo
                    eq_refl Hsem) as (o1 & ->)
    end.
    (* the table Evar at the empty env: its global block at offset 0 *)
    match goal with
    | Hv1 : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hv1
    end.
    match goal with
    | Hlv4 : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv4
    end.
    { match goal with
      | He0 : empty_env ! _ = Some _ |- _ =>
          rewrite PTree.gempty in He0; discriminate He0
      end. }
    match goal with
    | Hdl3 : deref_loc (typeof _) _ _ _ _ _ |- _ =>
        cbn [typeof] in Hdl3;
        inv Hdl3;
        try (match goal with
             | Hac : access_mode (Tarray _ _ _) = _ |- _ =>
                 cbn in Hac; discriminate Hac
             end)
    end.
    (* the load is from the table block: the offset-free row fires *)
    match goal with
    | Hfs : Genv.find_symbol _ interaction._sInteractionHandlers = Some _
      |- _ => exact (HMWF_itab _ _ _ _ _ HM Hfs Hld)
    end.
  Qed.

  (* ================================================================== *)
  (* THE WALK: exec-derivation induction; Sloop by IH; the indirect     *)
  (* call resolved through the ile pin + the census + linkorder.        *)
  (* ================================================================== *)
  Lemma inter_walk_pres :
    forall e le m0 s tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      e = empty_env ->
      inter_chk s = true ->
      ile le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\ ile le'.
  Proof.
    intros e le m0 s tr le' m' out Hexec.
    induction Hexec; intros He Hchk Hile HN HM HV HS.
    - (* Sskip *) exact (conj HV (conj HS (conj HM (conj HN Hile)))).
    - (* Sassign: the window brick or the global brick *)
      cbn [inter_chk] in Hchk. unfold inter_assign_chk in Hchk.
      subst e.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      apply orb_true_iff in Hchk.
      destruct Hchk as [Hsf | Hgs].
      + destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf (proj1 Hile) Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj HV' (conj HS' (conj HM'
                 (conj (HNoA_of_MWF _ HM') Hile)))).
      + destruct (glob_assign_pres lp bm MWF HMWF_glob
                    a1 a2 _ _ _ _ _ _ _ Hgs
                    empty_env_glob_unbound Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj HV' (conj HS' (conj HM'
                 (conj (HNoA_of_MWF _ HM') Hile)))).
    - (* Sset: memory unchanged; the tracked-temp split *)
      cbn [inter_chk] in Hchk. unfold inter_set_chk in Hchk.
      subst e.
      apply andb_prop in Hchk as [Hmt2 Hsel].
      apply andb_prop in Hmt2 as [Hnm Hnt2].
      refine (conj HV (conj HS (conj HM (conj HN _)))).
      destruct (Pos.eqb id interaction._t'16) eqn:E16.
      + apply Pos.eqb_eq in E16. subst id.
        apply ile_set_t16; [ exact Hile | ].
        intros b o ->.
        match goal with
        | Hev : eval_expr _ _ _ _ a _ |- _ =>
            exact (handler_slot_val _ _ _ _ Hsel Hev HM _ _ eq_refl)
        end.
      + destruct (Pos.eqb id interaction._object) eqn:Eob.
        * apply Pos.eqb_eq in Eob. subst id.
          unfold is_t2_temp in Hsel.
          destruct a as [ ci cty | cf cty | cs cty | cl cty | gid gty
                        | q qty | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4
                        | c1 c2 | f1 f2 f3 | s1' s2' | g1 g2 ];
            try discriminate Hsel.
          apply andb_prop in Hsel as [Hq _].
          apply Pos.eqb_eq in Hq. subst q.
          match goal with
          | Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
              apply eval_expr_Etempvar_val in Hev
          end.
          apply ile_set_object; [ exact Hile | ].
          intros b o E. subst v.
          match goal with
          | Hg2 : le ! interaction._t'2 = Some (Vptr _ _) |- _ =>
              exact (proj1 (proj2 Hile) _ _ Hg2)
          end.
        * apply ile_set_other;
            [ apply negb_true_iff; exact Hnm
            | apply negb_true_iff; exact Hnt2
            | exact Eob | exact E16 | exact Hile ].
    - (* Scall: mgco / ckpw / the INDIRECT handler call *)
      subst e.
      destruct a as [ ci cty | cf cty | cs cty | cl cty | cid fty
                    | fp fpty | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4
                    | c1 c2 | f1 f2 f3 | s1' s2' | g1 g2 ];
        try discriminate Hchk.
      + (* direct calls: mgco or ckpw *)
        cbn [inter_chk inter_call_chk] in Hchk.
        apply orb_true_iff in Hchk.
        destruct Hchk as [Hmg | Hck].
        * (* t'2 := mario_get_collided_object(m, interactType) *)
          apply andb_prop in Hmg as [Hmg Hal].
          apply andb_prop in Hmg as [Hmg Hfty].
          apply andb_prop in Hmg as [Hfid Hopt].
          apply Pos.eqb_eq in Hfid. subst cid.
          destruct optid as [q|]; [ | discriminate Hopt ].
          apply Pos.eqb_eq in Hopt. subst q.
          destruct fty as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt pa
                          | a1' a2' a3' | params res cc | st1 st2
                          | un1 un2 ];
            try discriminate Hfty.
          destruct params as [| ty1 rest]; [ discriminate Hfty | ].
          apply andb_prop in Hfty as [Hty1 Hrest].
          destruct (type_eq ty1 tyMSp); [ subst ty1 | discriminate Hty1 ].
          destruct rest as [| ty2 rest2]; [ discriminate Hrest | ].
          destruct rest2; [ | discriminate Hrest ].
          destruct al as [| a0 alr]; [ discriminate Hal | ].
          apply andb_prop in Hal as [Ha0 Halr].
          destruct alr as [| a1' alr2]; [ discriminate Halr | ].
          destruct alr2; [ | discriminate Halr ].
          unfold is_m_arg in Ha0.
          destruct a0 as [ ci cty | cf cty | cs cty | cl cty | gid gty
                         | p pty | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4
                         | c1 c2 | f1 f2 f3 | s1' s2' | g1 g2 ];
            try discriminate Ha0.
          apply andb_prop in Ha0 as [Hp Hpty].
          apply Pos.eqb_eq in Hp. subst p.
          destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
          (* the function value: the mgco symbol's pointer *)
          match goal with
          | Hvf : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
              apply eval_Evar_funct_empty in Hvf;
              destruct Hvf as (fb & Hsym & ->)
          end.
          match goal with
          | Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd0 |- _ =>
              assert (Hres : resolves_lp lp
                               interaction._mario_get_collided_object fd0)
                by (exists fb; split; assumption)
          end.
          (* pin the argument target types via classify_fun *)
          match goal with
          | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
              cbn in Hcf; injection Hcf as <- <- <-
          end.
          (* the first argument: Mario's exact pointer (cast is the id) *)
          match goal with
          | Hargs : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ =>
              inv Hargs
          end.
          match goal with
          | Hv0 : eval_expr _ _ _ _ (Etempvar interaction._m _) _ |- _ =>
              apply eval_expr_Etempvar_val in Hv0
          end.
          match goal with
          | Hc0 : sem_cast _ (typeof (Etempvar _ _)) _ _ = Some _ |- _ =>
              cbn [typeof] in Hc0;
              pose proof (sem_cast_ptr_ptr_id _ _ _ _ _ _ _ Hc0) as ->
          end.
          match goal with
          | Hevf : eval_funcall _ _ _ ?fd0 (?vm0 :: ?vl0) _ _ _,
            Hv0 : le ! interaction._m = Some ?vm0 |- _ =>
              assert (Hmarg : marg_ok bm (vm0 :: vl0))
                by (destruct vm0 as [ | | | | | bb oo ]; cbn [marg_ok];
                    auto; exact (proj1 Hile _ _ Hv0));
              destruct (Hcp_mgco _ _ _ _ _ _ Hevf Hres Hmarg HN HM HV HS)
                as (HV' & HS' & HM' & Hret)
          end.
          refine (conj HV' (conj HS' (conj HM'
                    (conj (HNoA_of_MWF _ HM') _)))).
          cbn [set_opttemp].
          exact (ile_set_t2 _ _ Hile Hret).
        * (* check_kick_or_punch_wall(m): the kit brick *)
          apply andb_prop in Hck as [Hck Hal].
          apply andb_prop in Hck as [Hck Hfty].
          apply andb_prop in Hck as [Hfid Hopt].
          apply Pos.eqb_eq in Hfid. subst cid.
          destruct optid as [q|]; [ discriminate Hopt | ].
          destruct fty as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt pa
                          | a1' a2' a3' | params res cc | st1 st2
                          | un1 un2 ];
            try discriminate Hfty.
          destruct params as [| ty1 rest]; [ discriminate Hfty | ].
          destruct rest; [ | discriminate Hfty ].
          destruct (type_eq ty1 tyMSp); [ subst ty1 | discriminate Hfty ].
          destruct al as [| a0 alr]; [ discriminate Hal | ].
          destruct alr; [ | discriminate Hal ].
          unfold is_m_arg in Hal.
          destruct a0 as [ ci cty | cf cty | cs cty | cl cty | gid gty
                         | p pty | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4
                         | c1 c2 | f1 f2 f3 | s1' s2' | g1 g2 ];
            try discriminate Hal.
          apply andb_prop in Hal as [Hp Hpty].
          apply Pos.eqb_eq in Hp. subst p.
          destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) empty_env le m
                          (Scall None
                             (Evar interaction._check_kick_or_punch_wall
                                (Tfunction (tyMSp :: nil) res cc))
                             (Etempvar interaction._m tyMSp :: nil))
                          t (set_opttemp None vres le) m' Out_normal)
            by (econstructor; eauto).
          destruct (kit_scall_pres lp bm NoA MWF
                      _ _ _ _ _ _ _ _ _ _ Hex Hcp_ckpw (proj1 Hile)
                      HN HM HV HS)
            as (HV' & HS' & HM' & HN' & _ & _).
          exact (conj HV' (conj HS' (conj HM' (conj HN' Hile)))).
      + (* THE INDIRECT CALL through _t'16: handler(m, interactType, object) *)
        cbn [inter_chk inter_call_chk] in Hchk.
        apply andb_prop in Hchk as [Hchk Hal].
        apply andb_prop in Hchk as [Hchk Hfree].
        apply andb_prop in Hchk as [Hfp Hfpty].
        apply Pos.eqb_eq in Hfp. subst fp.
        destruct (type_eq fpty tyHandlerP); [ subst fpty | discriminate Hfpty ].
        destruct al as [| a0 alr]; [ discriminate Hal | ].
        apply andb_prop in Hal as [Ha0 Halr].
        destruct alr as [| a1' alr2]; [ discriminate Halr | ].
        destruct alr2 as [| a2' alr3]; [ discriminate Halr | ].
        destruct alr3; [ | discriminate Halr ].
        unfold is_m_arg in Ha0.
        destruct a0 as [ ci cty | cf cty | cs cty | cl cty | gid gty
                       | p pty | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4
                       | c1 c2 | f1 f2 f3 | s1' s2' | g1 g2 ];
          try discriminate Ha0.
        apply andb_prop in Ha0 as [Hp Hpty].
        apply Pos.eqb_eq in Hp. subst p.
        destruct (type_eq pty tyMSp); [ subst pty | discriminate Hpty ].
        unfold is_obj_arg in Halr.
        destruct a2' as [ ci cty | cf cty | cs cty | cl cty | gid gty
                        | ob obty | da dy | ar ay | u1 u2 u3 | b1 b2 b3 b4
                        | c1 c2 | f1 f2 f3 | s1' s2' | g1 g2 ];
          try discriminate Halr.
        apply andb_prop in Halr as [Hob Hobty].
        apply Pos.eqb_eq in Hob. subst ob.
        destruct obty as [ | i1 i2 i3 | l1 l2 | r1 r2 | opt' opa
                         | a1'' a2'' a3'' | pf pr pc | st1 st2 | un1 un2 ];
          try discriminate Hobty.
        (* the function value: the ile pin forces a censused handler *)
        match goal with
        | Hvf : eval_expr _ _ _ _ (Etempvar interaction._t'16 _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hvf
        end.
        match goal with
        | Hff : Genv.find_funct _ ?vf0 = Some ?fd0 |- _ =>
            destruct vf0 as [ | | | | | fb fo ]; try discriminate Hff;
            unfold Genv.find_funct in Hff;
            destruct (Ptrofs.eq_dec fo Ptrofs.zero) as [-> | ];
            [ | discriminate Hff ]
        end.
        match goal with
        | Hv16 : le ! interaction._t'16 = Some (Vptr fb Ptrofs.zero) |- _ =>
            destruct (proj2 (proj2 (proj2 Hile)) _ _ Hv16)
              as (hid & Hin & Hsymb & _)
        end.
        match goal with
        | Hff : Genv.find_funct_ptr _ fb = Some ?fd0 |- _ =>
            assert (Hres : resolves_lp lp hid fd0)
              by (exists fb; split;
                  [ exact Hsymb
                  | unfold Genv.find_funct;
                    destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero);
                    [ exact Hff | congruence ] ])
        end.
        (* census: the handler is Internal in interaction.prog; linkorder
           pins its lp resolution to THE real generated body *)
        pose proof (proj1 (forallb_forall _ interaction_handler_ids)
                      interaction_handler_ids_internal hid Hin) as Hint.
        apply internal_in_spec in Hint.
        destruct Hint as (g & Hdm).
        match goal with
        | Hff : Genv.find_funct_ptr _ fb = Some ?fd0 |- _ =>
            assert (Efd : fd0 = Internal g)
              by (eapply resolve_pin_fd;
                  [ exact LO_int | exact Hdm | exact Hres ]);
            subst fd0
        end.
        (* pin the argument target types via classify_fun *)
        match goal with
        | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
            cbn in Hcf; injection Hcf as <- <- <-
        end.
        (* the arguments: Mario's pointer and the SafeB object pointer
           (both casts are pointer-to-pointer identities) *)
        match goal with
        | Hargs : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ =>
            inv Hargs
        end.
        match goal with
        | Hv0 : eval_expr _ _ _ _ (Etempvar interaction._m _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hv0
        end.
        match goal with
        | Hc0 : sem_cast _ (typeof (Etempvar interaction._m _)) _ _
                  = Some _ |- _ =>
            cbn [typeof] in Hc0;
            pose proof (sem_cast_ptr_ptr_id _ _ _ _ _ _ _ Hc0) as ->
        end.
        match goal with
        | Hargs2 : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ =>
            inv Hargs2
        end.
        match goal with
        | Hargs3 : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ =>
            inv Hargs3
        end.
        match goal with
        | Hnil : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hnil
        end.
        match goal with
        | Hv2 : eval_expr _ _ _ _ (Etempvar interaction._object _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hv2
        end.
        match goal with
        | Hc2 : sem_cast _ (typeof (Etempvar interaction._object _)) _ _
                  = Some _ |- _ =>
            cbn [typeof] in Hc2;
            pose proof (sem_cast_ptr_ptr_id _ _ _ _ _ _ _ Hc2) as ->
        end.
        (* the gated per-handler residual fires *)
        match goal with
        | Hevf : eval_funcall _ _ _ (Internal g)
                   (?vm0 :: ?vi0 :: ?vo0 :: nil) _ _ _,
          Hv0 : le ! interaction._m = Some ?vm0,
          Hv2 : le ! interaction._object = Some ?vo0 |- _ =>
            assert (Fm : forall b o, vm0 = Vptr b o ->
                         b = bm /\ o = Ptrofs.zero)
              by (intros b o E; rewrite E in Hv0;
                  exact (proj1 Hile _ _ Hv0));
            assert (Fo : forall b o, vo0 = Vptr b o -> SafeB b)
              by (intros b o E; rewrite E in Hv2;
                  exact (proj1 (proj2 (proj2 Hile)) _ _ Hv2));
            destruct (Hpres_ihandler hid g Hin Hdm _ _ _ _ _ _ _
                        Fm Fo Hevf HN HM HV HS)
              as (HV' & HS' & HM')
        end.
        refine (conj HV' (conj HS' (conj HM'
                  (conj (HNoA_of_MWF _ HM') _)))).
        destruct optid as [q|]; cbn [set_opttemp].
        * cbn [opt_inter_free] in Hfree.
          apply andb_prop in Hfree as [Hfree Hqob].
          apply andb_prop in Hfree as [Hfree Hq16].
          apply andb_prop in Hfree as [Hqm Hqt2].
          apply ile_set_other;
            [ apply negb_true_iff; exact Hqm
            | apply negb_true_iff; exact Hqt2
            | apply negb_true_iff; exact Hqob
            | apply negb_true_iff; exact Hq16
            | exact Hile ].
        * exact Hile.
    - (* Sbuiltin: excluded by the recognizer *)
      cbn [inter_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [inter_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Hile HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Hile1).
      exact (IHHexec2 He H2 Hile1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [inter_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec He H1 Hile HN HM HV HS).
    - (* Sifthenelse *)
      cbn [inter_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None: excluded *)
      cbn [inter_chk] in Hchk. discriminate Hchk.
    - (* Sreturn Some: excluded *)
      cbn [inter_chk] in Hchk. discriminate Hchk.
    - (* Sbreak *) exact (conj HV (conj HS (conj HM (conj HN Hile)))).
    - (* Scontinue: excluded *)
      cbn [inter_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop1 *)
      cbn [inter_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec He H1 Hile HN HM HV HS).
    - (* Sloop stop2 *)
      cbn [inter_chk] in Hchk.
      pose proof Hchk as Hchk2.
      apply andb_prop in Hchk2 as [H1 H2].
      destruct (IHHexec1 He H1 Hile HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Hile1).
      exact (IHHexec2 He H2 Hile1 HN1 HM1 HV1 HS1).
    - (* Sloop loop: body, then s2, then the loop again -- all by IH *)
      cbn [inter_chk] in Hchk.
      pose proof Hchk as Hloop.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Hile HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Hile1).
      destruct (IHHexec2 He H2 Hile1 HN1 HM1 HV1 HS1)
        as (HV2 & HS2 & HM2 & HN2 & Hile2).
      apply IHHexec3; try assumption.
    - (* Sswitch: excluded *)
      cbn [inter_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_inter itself, PROVED from the census-keyed       *)
  (* handler residuals + the two named helper rows.                     *)
  (* ================================================================== *)
  Theorem inter_pres :
    body_pres lp NoA MWF bm interaction.f_mario_process_interactions.
  Proof.
    intros m vargs t m' vres Hmargp Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs).
    { apply Hmargp. vm_compute. reflexivity. }
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars interaction.f_mario_process_interactions)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params interaction.f_mario_process_interactions)
      with ((interaction._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps interaction.f_mario_process_interactions))
      in *.
    assert (Hb2 : base ! interaction._t'2 = Some Vundef)
      by (vm_compute; reflexivity).
    assert (Hbob : base ! interaction._object = Some Vundef)
      by (vm_compute; reflexivity).
    assert (Hb16 : base ! interaction._t'16 = Some Vundef)
      by (vm_compute; reflexivity).
    assert (Hile0 : ile (PTree.set interaction._m v0 base)).
    { refine (conj _ (conj _ (conj _ _))); intros b o Hg.
      - rewrite PTree.gss in Hg. injection Hg as ->.
        cbn [marg_ok] in Hmarg. exact Hmarg.
      - rewrite PTree.gso in Hg by id_neq.
        rewrite Hb2 in Hg. discriminate Hg.
      - rewrite PTree.gso in Hg by id_neq.
        rewrite Hbob in Hg. discriminate Hg.
      - rewrite PTree.gso in Hg by id_neq.
        rewrite Hb16 in Hg. discriminate Hg. }
    destruct (inter_walk_pres _ _ _ _ _ _ _ _ Hbody eq_refl
                inter_chk_body Hile0 HN HM HV HS)
      as (HV' & HS' & HM' & _ & _).
    repeat split; assumption.
  Qed.

End InterSurface.

(* ====================================================================== *)
(* THE MGCO WALK: Hcp_mgco DISCHARGED.                                    *)
(*                                                                        *)
(* f_mario_get_collided_object's body is READ-ONLY -- no Sassign, no      *)
(* Scall, no Sbuiltin -- so a frame walk shows memory is preserved        *)
(* EXACTLY; the whole content of the residual is the SafeB-if-ptr         *)
(* RETURN: the returned _object temp is loaded from                       *)
(* m->marioObj->collidedObjs[i] -- one chase-ROOT hop (marioObj, the      *)
(* reused ActWriterSurface.chase_root_set_sound brick) and one indexed    *)
(* chase-STEP hop (the bespoke collided_elem_val brick: the element       *)
(* address is pinned structurally to _t'2's SafeB block, R7 closes the    *)
(* load).  The NULL return is an I32 constant cast to a pointer type --   *)
(* a Vint pass-through on ptr32 (cast_case_pointer), never a Vptr.        *)
(* ====================================================================== *)


(* ---- single-column recognizer helpers (multi-column patterns leak
   stuck cbn goals -- the wind gotcha) ---- *)
Definition is_ptrty (t : type) : bool :=
  match t with Tpointer _ _ => true | _ => false end.
Definition is_ptr_arrty (t : type) : bool :=
  match t with Tarray el _ _ => is_ptrty el | _ => false end.
Definition is_structy2 (t : type) : bool :=
  match t with Tstruct _ _ => true | _ => false end.
Definition is_oadd (op : binary_operation) : bool :=
  match op with Oadd => true | _ => false end.
Definition is_any_tempvar (a : expr) : bool :=
  match a with Etempvar _ _ => true | _ => false end.
Definition is_t2_tempvar (a : expr) : bool :=
  match a with
  | Etempvar q ty => Pos.eqb q interaction._t'2 && is_ptrty ty
  | _ => false
  end.
Definition is_t2obj_base (a : expr) : bool :=
  match a with
  | Ederef b ty => is_t2_tempvar b && is_structy2 ty
  | _ => false
  end.
Definition is_collided_arr (a : expr) : bool :=
  match a with
  | Efield b _ ty => is_t2obj_base b && is_ptr_arrty ty
  | _ => false
  end.
Definition is_collided_elem_addr (a : expr) : bool :=
  match a with
  | Ebinop op b i ty =>
      is_oadd op && is_collided_arr b && is_any_tempvar i && is_ptrty ty
  | _ => false
  end.
Definition collided_elem_chk (a : expr) : bool :=
  match a with
  | Ederef b ty => is_collided_elem_addr b && is_ptrty ty
  | _ => false
  end.

Definition is_i32s (t : type) : bool :=
  match t with
  | Tint sz si _ =>
      proj_sumbool (intsize_eq sz I32)
      && match si with Signed => true | _ => false end
  | _ => false
  end.
Definition is_int_const (a : expr) : bool :=
  match a with Econst_int _ ty => is_i32s ty | _ => false end.

Definition mgco_set_chk (id : ident) (a : expr) : bool :=
  if Pos.eqb id interaction._t'2
  then ActWriterSurface.chase_root_chk a
  else if Pos.eqb id interaction._object
  then collided_elem_chk a
  else negb (Pos.eqb id interaction._m).

Definition mgco_ret_chk (a : expr) : bool :=
  match a with
  | Etempvar q ty => Pos.eqb q interaction._object && is_ptrty ty
  | Ecast b ty => is_int_const b && is_ptrty ty
  | _ => false
  end.

Fixpoint mgco_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak => true
  | Sset id a => mgco_set_chk id a
  | Ssequence s1 s2 => mgco_chk s1 && mgco_chk s2
  | Sifthenelse _ s1 s2 => mgco_chk s1 && mgco_chk s2
  | Sloop s1 s2 => mgco_chk s1 && mgco_chk s2
  | Sreturn (Some a) => mgco_ret_chk a
  | _ => false
  end.

Lemma mgco_chk_body :
  mgco_chk (fn_body interaction.f_mario_get_collided_object) = true.
Proof. vm_compute. reflexivity. Qed.

(* an I32-typed constant cast to a pointer type stays a Vint on ptr32
   (cast_case_pointer pass-through): the NULL return is never a Vptr *)
Lemma sem_cast_int_to_ptr_vint :
  forall z si at1 pt pa m v,
    sem_cast (Vint z) (Tint I32 si at1) (Tpointer pt pa) m = Some v ->
    v = Vint z.
Proof.
  intros z si at1 pt pa m v H.
  unfold sem_cast in H. cbn in H.
  injection H as <-. reflexivity.
Qed.

Section MgcoSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.

  (* ================================================================== *)
  (* The indexed chase-step brick: a pointer value read from            *)
  (* t'2->collidedObjs[i] is SafeB (t'2's block via the temp fact, the  *)
  (* element address pinned structurally, R7 closes the load).          *)
  (* ================================================================== *)
  Lemma collided_elem_val :
    forall le m0 a v,
      collided_elem_chk a = true ->
      (forall b o, le ! interaction._t'2 = Some (Vptr b o) -> SafeB b) ->
      MWF m0 ->
      eval_expr (lp_ge lp) empty_env le m0 a v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof.
    intros le m0 a v Hrec Ht2 HM Hev b o ->.
    (* ---- recognizer-driven destructs FIRST: expose every layer ---- *)
    destruct a as [ ci cty | cf cty | cs cty | cl cty | gid gty | tv tvy
                  | ad dy | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                  | f1 f2 f3 | s1' s2' | g1 g2 ];
      try discriminate Hrec.
    cbn [collided_elem_chk] in Hrec.
    apply andb_prop in Hrec as [Hrec Hdy].
    destruct ad as [ ci cty | cf cty | cs cty | cl cty | gid gty | tv tvy
                   | da2 dy2 | ar ay | u1 u2 u3 | op ab ai bty | c1 c2
                   | f1 f2 f3 | s1' s2' | g1 g2 ];
      try discriminate Hrec.
    cbn [is_collided_elem_addr] in Hrec.
    apply andb_prop in Hrec as [Hrec Hbty].
    apply andb_prop in Hrec as [Hrec Hai].
    apply andb_prop in Hrec as [Hop Hrec].
    destruct op; try discriminate Hop. clear Hop.
    destruct ai as [ ci cty | cf cty | cs cty | cl cty | gid gty | q2 q2y
                   | da2 dy2 | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                   | f1 f2 f3 | s1' s2' | g1 g2 ];
      try discriminate Hai.
    clear Hai.
    destruct ab as [ ci cty | cf cty | cs cty | cl cty | gid gty | tv tvy
                   | da2 dy2 | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                   | fe fld fty | s1' s2' | g1 g2 ];
      try discriminate Hrec.
    cbn [is_collided_arr] in Hrec.
    apply andb_prop in Hrec as [Hrec Hfty].
    destruct fty as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt2 pa2 | aty asz aat
                    | pf pr pc | st1 st2 | un1 un2 ];
      try discriminate Hfty.
    cbn [is_ptr_arrty] in Hfty.
    destruct aty as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt3 pa3 | a1' a2' a3'
                    | pf pr pc | st1 st2 | un1 un2 ];
      try discriminate Hfty.
    clear Hfty.
    destruct fe as [ ci cty | cf cty | cs cty | cl cty | gid gty | tv tvy
                   | de dey | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                   | f1 f2 f3 | s1' s2' | g1 g2 ];
      try discriminate Hrec.
    cbn [is_t2obj_base] in Hrec.
    apply andb_prop in Hrec as [Hrec Hdey].
    destruct de as [ ci cty | cf cty | cs cty | cl cty | gid gty | q qty
                   | da2 dy2 | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                   | f1 f2 f3 | s1' s2' | g1 g2 ];
      try discriminate Hrec.
    cbn [is_t2_tempvar] in Hrec.
    apply andb_prop in Hrec as [Hq Hqty].
    apply Pos.eqb_eq in Hq. subst q.
    destruct qty as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt2 pa2 | a1' a2' a3'
                    | pf pr pc | st1 st2 | un1 un2 ];
      try discriminate Hqty.
    clear Hqty.
    destruct dey as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt4 pa4 | a1' a2' a3'
                    | pf pr pc | st2 sa2 | un1 un2 ];
      try discriminate Hdey.
    clear Hdey.
    destruct dy as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt pa | a1' a2' a3'
                   | pf pr pc | st1 st3 | un1 un2 ];
      try discriminate Hdy.
    clear Hdy.
    destruct bty as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt5 pa5 | a1' a2' a3'
                    | pf pr pc | st1 st3 | un1 un2 ];
      try discriminate Hbty.
    clear Hbty.
    (* ---- now the eval inversions over fully concrete exprs ---- *)
    apply eval_expr_Ederef_load in Hev.
    destruct Hev as (loc & ofs & bf & Hlv & Hdl).
    inv Hdl;
      try (match goal with
           | Hac : access_mode (Tpointer _ _) = _ |- _ =>
               cbn in Hac; discriminate Hac
           end).
    2:{ match goal with
        | Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb
        end. }
    match goal with
    | Hac : access_mode (Tpointer _ _) = By_value ?ch |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hldv : Mem.loadv _ _ _ = Some _ |- _ => rename Hldv into Hld
    end.
    inv Hlv.
    match goal with
    | Ha : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => rename Ha into Hadd
    end.
    inv Hadd.
    2:{ match goal with
        | Hlv3 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv3
        end. }
    match goal with
    | Hsem : sem_binary_operation _ Oadd ?v1 ?t1 ?v2 ?t2 _
               = Some (Vptr _ _) |- _ =>
        destruct (sem_add_ptrish_block _ v1 t1 v2 t2 _ _ _
                    eq_refl Hsem) as (o1 & ->)
    end.
    match goal with
    | Hv1 : eval_expr _ _ _ _ (Efield _ _ _) (Vptr _ _) |- _ =>
        rename Hv1 into Hfe
    end.
    inv Hfe.
    match goal with
    | Hd2 : deref_loc (typeof _) _ _ _ _ _ |- _ =>
        cbn [typeof] in Hd2
    end.
    match goal with
    | Hlv3 : eval_lvalue _ _ _ _ (Efield _ _ _) ?l3 ?o3 ?b3,
      Hd2 : deref_loc (Tarray ?ety ?esz ?eat) ?mm ?l3 ?o3 ?b3
              (Vptr ?vb ?vo) |- _ =>
        destruct (deref_loc_aggregate_eq (Tarray ety esz eat) mm l3 o3 b3
                    vb vo (or_introl eq_refl) Hd2) as [-> ->];
        apply eval_lvalue_Efield_base in Hlv3;
        destruct Hlv3 as (oo0 & Hbase)
    end.
    apply eval_expr_Ederef_load in Hbase.
    destruct Hbase as (lb & ob & bfb & Hlvb & Hdlb).
    match goal with
    | Hdx : deref_loc (Tstruct ?sn ?sa) ?mm ?lb2 ?ob2 ?bf2
              (Vptr ?vb ?vo) |- _ =>
        destruct (deref_loc_aggregate_eq (Tstruct sn sa) mm lb2 ob2 bf2
                    vb vo (or_intror eq_refl) Hdx) as [-> ->]
    end.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    pose proof (Ht2 _ _ Hlvb) as Hsafe.
    exact (HchaseStep _ _ _ _ _ HM Hsafe Hld).
  Qed.


  (* the rows chase_root_set_sound consumes (all PROVED at MWF_real) *)
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = Errors.OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') -> SafeB b'.
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = Errors.OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm -> Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.

  (* ---- the temp invariant: 3 facts ---- *)
  Definition mle (le : temp_env) : Prop :=
    (forall b o, le ! interaction._m = Some (Vptr b o) ->
                 b = bm /\ o = Ptrofs.zero) /\
    (forall b o, le ! interaction._t'2 = Some (Vptr b o) -> SafeB b) /\
    (forall b o, le ! interaction._object = Some (Vptr b o) -> SafeB b).

  Ltac mgco_id_neq := let E := fresh "E" in intro E; discriminate E.

  Lemma mle_set_other :
    forall le id v,
      Pos.eqb id interaction._m = false ->
      Pos.eqb id interaction._t'2 = false ->
      Pos.eqb id interaction._object = false ->
      mle le -> mle (PTree.set id v le).
  Proof.
    intros le id v Hm H2 Hob (Im & I2 & Iob).
    refine (conj _ (conj _ _)); intros b o Hg;
      rewrite PTree.gso in Hg
        by (intro E; subst id; rewrite Pos.eqb_refl in *; discriminate).
    - exact (Im _ _ Hg).
    - exact (I2 _ _ Hg).
    - exact (Iob _ _ Hg).
  Qed.

  Lemma mle_set_t2 :
    forall le v,
      mle le ->
      (forall b o, v = Vptr b o -> SafeB b) ->
      mle (PTree.set interaction._t'2 v le).
  Proof.
    intros le v (Im & I2 & Iob) Hv.
    refine (conj _ (conj _ _)); intros b o Hg.
    - rewrite PTree.gso in Hg by mgco_id_neq. exact (Im _ _ Hg).
    - rewrite PTree.gss in Hg. injection Hg as ->. exact (Hv _ _ eq_refl).
    - rewrite PTree.gso in Hg by mgco_id_neq. exact (Iob _ _ Hg).
  Qed.

  Lemma mle_set_object :
    forall le v,
      mle le ->
      (forall b o, v = Vptr b o -> SafeB b) ->
      mle (PTree.set interaction._object v le).
  Proof.
    intros le v (Im & I2 & Iob) Hv.
    refine (conj _ (conj _ _)); intros b o Hg.
    - rewrite PTree.gso in Hg by mgco_id_neq. exact (Im _ _ Hg).
    - rewrite PTree.gso in Hg by mgco_id_neq. exact (I2 _ _ Hg).
    - rewrite PTree.gss in Hg. injection Hg as ->. exact (Hv _ _ eq_refl).
  Qed.

  (* ================================================================== *)
  (* THE WALK: the body is READ-ONLY (no Sassign/Scall/Sbuiltin), so    *)
  (* memory is preserved EXACTLY; the payload is the temp invariant     *)
  (* and the SafeB-if-ptr return fact.                                  *)
  (* ================================================================== *)
  Lemma mgco_walk_pres :
    forall e le m0 s tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      e = empty_env ->
      mgco_chk s = true ->
      mle le -> MWF m0 ->
      m' = m0 /\ mle le' /\
      (forall v ty, out = Out_return (Some (v, ty)) ->
         (exists pt pa, ty = Tpointer pt pa) /\
         (forall b o, v = Vptr b o -> SafeB b)).
  Proof.
    intros e le m0 s tr le' m' out Hexec.
    induction Hexec; intros He Hchk Hile HM.
    - (* Sskip *)
      refine (conj eq_refl (conj Hile _)). intros v ty Hq; discriminate Hq.
    - (* Sassign: excluded *) cbn [mgco_chk] in Hchk. discriminate Hchk.
    - (* Sset *)
      cbn [mgco_chk] in Hchk. unfold mgco_set_chk in Hchk. subst e.
      refine (conj eq_refl (conj _ _));
        [ | intros v0 ty Hq; discriminate Hq ].
      destruct (Pos.eqb id interaction._t'2) eqn:E2.
      + apply Pos.eqb_eq in E2. subst id.
        apply mle_set_t2; [ exact Hile | ].
        match goal with
        | Hev : eval_expr _ _ _ _ a _ |- _ =>
            exact (ActWriterSurface.chase_root_set_sound lp LO_mario bm MWF
                     HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm
                     HchaseRoot HMWF_root a _ _ _ _ Hchk (proj1 Hile) HM Hev)
        end.
      + destruct (Pos.eqb id interaction._object) eqn:Eob.
        * apply Pos.eqb_eq in Eob. subst id.
          apply mle_set_object; [ exact Hile | ].
          match goal with
          | Hev : eval_expr _ _ _ _ a _ |- _ =>
              exact (collided_elem_val _ _ _ _ Hchk
                       (proj1 (proj2 Hile)) HM Hev)
          end.
        * apply negb_true_iff in Hchk.
          exact (mle_set_other _ _ _ Hchk E2 Eob Hile).
    - (* Scall: excluded *) cbn [mgco_chk] in Hchk. discriminate Hchk.
    - (* Sbuiltin: excluded *) cbn [mgco_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [mgco_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Hile HM) as (-> & Hile1 & _).
      exact (IHHexec2 He H2 Hile1 HM).
    - (* Sseq_2: s1 exits early *)
      cbn [mgco_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      exact (IHHexec He H1 Hile HM).
    - (* Sifthenelse *)
      cbn [mgco_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None: excluded *) cbn [mgco_chk] in Hchk. discriminate Hchk.
    - (* Sreturn Some *)
      cbn [mgco_chk] in Hchk.
      refine (conj eq_refl (conj Hile _)).
      intros v0 ty Hq. injection Hq as <- <-.
      unfold mgco_ret_chk in Hchk.
      destruct a as [ ci cty | cf cty | cs cty | cl cty | gid gty | q qty
                    | da2 dy2 | ar ay | u1 u2 u3 | b1 b2 b3 b4 | ce cey
                    | f1 f2 f3 | s1' s2' | g1 g2 ];
        try discriminate Hchk.
      + (* return object *)
        apply andb_prop in Hchk as [Hq2 Hqty].
        apply Pos.eqb_eq in Hq2. subst q.
        destruct qty as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt pa | a1' a2' a3'
                        | pf pr pc | st1 st2 | un1 un2 ];
          try discriminate Hqty.
        split; [ cbn [typeof]; eauto | ].
        match goal with
        | Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hev
        end.
        intros b o ->.
        match goal with
        | Hg : le ! interaction._object = Some (Vptr _ _) |- _ =>
            exact (proj2 (proj2 Hile) _ _ Hg)
        end.
      + (* return NULL: an I32 const cast to a pointer stays Vint *)
        apply andb_prop in Hchk as [Hic Hcey].
        destruct ce as [ zi zty | cf cty | cs cty | cl cty | gid gty | q qty
                       | da2 dy2 | ar ay | u1 u2 u3 | b1 b2 b3 b4 | c1 c2
                       | f1 f2 f3 | s1' s2' | g1 g2 ];
          try discriminate Hic.
        cbn [is_int_const is_i32s] in Hic.
        destruct zty as [ | sz si zat | zl1 zl2 | zr1 zr2 | zpt zpa
                        | za1 za2 za3 | zpf zpr zpc | zst1 zst2
                        | zun1 zun2 ];
          try discriminate Hic.
        apply andb_prop in Hic as [Hsz Hsi].
        destruct (intsize_eq sz I32); [ subst sz | discriminate Hsz ].
        destruct si; try discriminate Hsi.
        destruct cey as [ | i1 i2 i3 | l1 l2 | r1 r2 | pt pa | a1' a2' a3'
                        | pf pr pc | st1 st2 | un1 un2 ];
          try discriminate Hcey.
        split; [ cbn [typeof]; eauto | ].
        match goal with
        | Hev : eval_expr _ _ _ _ (Ecast _ _) _ |- _ => rename Hev into Hca
        end.
        inv Hca.
        2:{ match goal with
            | Hlvc : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hlvc
            end. }
        match goal with
        | Hv1 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => rename Hv1 into He1
        end.
        inv He1.
        2:{ match goal with
            | Hlvc : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                inv Hlvc
            end. }
        match goal with
        | Hsc : sem_cast (Vint _) (typeof _) _ _ = Some _ |- _ =>
            cbn [typeof] in Hsc;
            apply sem_cast_int_to_ptr_vint in Hsc; subst v
        end.
        intros b o Hq2; discriminate Hq2.
    - (* Sbreak *)
      refine (conj eq_refl (conj Hile _)). intros v ty Hq; discriminate Hq.
    - (* Scontinue: excluded *) cbn [mgco_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop1 *)
      cbn [mgco_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
      destruct (IHHexec He H1 Hile HM) as (-> & Hile1 & Hret1).
      refine (conj eq_refl (conj Hile1 _)).
      match goal with
      | Hbr : out_break_or_return _ _ |- _ => inv Hbr
      end.
      + intros v ty Hq; discriminate Hq.
      + exact Hret1.
    - (* Sloop stop2 *)
      cbn [mgco_chk] in Hchk.
      pose proof Hchk as Hloop.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Hile HM) as (-> & Hile1 & _).
      destruct (IHHexec2 He H2 Hile1 HM) as (-> & Hile2 & Hret2).
      refine (conj eq_refl (conj Hile2 _)).
      match goal with
      | Hbr : out_break_or_return _ _ |- _ => inv Hbr
      end.
      + intros v ty Hq; discriminate Hq.
      + exact Hret2.
    - (* Sloop loop *)
      cbn [mgco_chk] in Hchk.
      pose proof Hchk as Hloop.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 He H1 Hile HM) as (-> & Hile1 & _).
      destruct (IHHexec2 He H2 Hile1 HM) as (-> & Hile2 & _).
      apply IHHexec3; try assumption.
    - (* Sswitch: excluded *) cbn [mgco_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: call_pres_mgco PROVED (the InterSurface residual).     *)
  (* ================================================================== *)
  Lemma mgco_cp : call_pres_mgco lp bm NoA MWF SafeB.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hmarg HN HM HV HS.
    assert (Hfd : fd = Internal interaction.f_mario_get_collided_object).
    { eapply (resolve_pin_fd lp interaction.prog
                interaction._mario_get_collided_object);
        [ exact LO_int | vm_compute; reflexivity | exact Hres ]. }
    subst fd.
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    match goal with
    | Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hout
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars interaction.f_mario_get_collided_object)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params interaction.f_mario_get_collided_object)
      with ((interaction._m, tyMSp) :: (interaction._interactType, tuint)
            :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs0 as [| v0 vr]; [ discriminate Hbind | ].
    destruct vr as [| v1 vr2]; [ discriminate Hbind | ].
    destruct vr2; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps interaction.f_mario_get_collided_object))
      in *.
    assert (Hb2 : base ! interaction._t'2 = Some Vundef)
      by (vm_compute; reflexivity).
    assert (Hbob : base ! interaction._object = Some Vundef)
      by (vm_compute; reflexivity).
    assert (Hile0 : mle (PTree.set interaction._interactType v1
                           (PTree.set interaction._m v0 base))).
    { refine (conj _ (conj _ _)); intros b o Hg;
        rewrite PTree.gso in Hg by mgco_id_neq.
      - rewrite PTree.gss in Hg. injection Hg as ->.
        destruct Hmarg as [E1 E2]; subst; split; reflexivity.
      - rewrite PTree.gso in Hg by mgco_id_neq.
        rewrite Hb2 in Hg. discriminate Hg.
      - rewrite PTree.gso in Hg by mgco_id_neq.
        rewrite Hbob in Hg. discriminate Hg. }
    destruct (mgco_walk_pres _ _ _ _ _ _ _ _ Hbody eq_refl
                mgco_chk_body Hile0 HM)
      as (-> & _ & Hret).
    refine (conj HV (conj HS (conj HM _))).
    change (fn_return interaction.f_mario_get_collided_object)
      with (Tpointer (Tstruct interaction._Object noattr) noattr) in Hout.
    destruct out as [ | | | [[v' ty']|] ]; cbn in Hout;
      try contradiction.
    destruct Hout as [_ Hcast].
    destruct (Hret _ _ eq_refl) as [(pt & pa & ->) Hsafe].
    apply sem_cast_ptr_ptr_id in Hcast. subst vres0.
    exact Hsafe.
  Qed.

End MgcoSurface.

(* ====================================================================== *)
(* ====================  check_kick_or_punch_wall  ====================== *)
(* The last named interaction.prog helper residual (interaction.v:10513,  *)
(* ~290 lines, straight-line): 3 detector[i] stores into the fn_var stack *)
(* array, ONE m->action := inline UNTAINTED constant (the kick-rebound    *)
(* action -- const_act_assign_pres, wact_const-checked), one safe         *)
(* particleFlags window store; calls = resolve_and_return_wall_collisions *)
(* (ol, dst = &detector), mario_set_forward_vel (marg internal via the    *)
(* NEW rest-tolerant cp2_scall_pres), play_sound (pure-audio external).   *)
(* ====================================================================== *)

(* ---- ident coincidences ---- *)
Example id_resolve_i :
  Pos.eqb interaction._resolve_and_return_wall_collisions
    mario_actions_automatic._resolve_and_return_wall_collisions = true.
Proof. vm_compute. reflexivity. Qed.
Example id_msfv_i :
  Pos.eqb interaction._mario_set_forward_vel
    mario._mario_set_forward_vel = true.
Proof. vm_compute. reflexivity. Qed.
Example id_m_i :
  Pos.eqb interaction._m mario_actions_airborne._m = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the defmap pin ---- *)
Lemma ckpw_pin :
  (prog_defmap interaction.prog) ! interaction._check_kick_or_punch_wall
  = Some (Gfun (Internal interaction.f_check_kick_or_punch_wall)).
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* recognizers                                                            *)
(* ====================================================================== *)
Definition tyMSi : type := tptr (Tstruct interaction._MarioState noattr).

Definition ckpw_assign_chk (a1 a2 : expr) : bool :=
  (* safe Mario-field store (particleFlags): value-blind window epi *)
  safe_mfield_store interaction._m a1
  (* m->action := statically untainted Econst_int (the kick-rebound act) *)
  || const_act_store_chk a1 a2
  (* detector[i] := ...: indexed store into the fn_var stack array *)
  || match a1 with
     | Ederef (Ebinop Oadd (Evar vid vty) (Econst_int _ ict) bty) eity =>
         Pos.eqb vid interaction._detector
         && proj_sumbool (type_eq vty (tarray tfloat 3))
         && proj_sumbool (type_eq ict tint)
         && proj_sumbool (type_eq bty (tptr tfloat))
         && proj_sumbool (type_eq eity tfloat)
     | _ => false
     end.

Definition ckpw_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (* resolve_and_return_wall_collisions(detector, c1, c2): the ol arm *)
  (Pos.eqb fid interaction._resolve_and_return_wall_collisions
   && proj_sumbool
        (type_eq fty
           (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
              (tptr (Tstruct interaction._Surface noattr)) cc_default))
   && match al with
      | Evar dv dvt :: Econst_single _ _ :: Econst_single _ _ :: nil =>
          Pos.eqb dv interaction._detector
          && proj_sumbool (type_eq dvt (tarray tfloat 3))
      | _ => false
      end)
  (* mario_set_forward_vel(m, vel): marg internal, rest-tolerant *)
  || (Pos.eqb fid interaction._mario_set_forward_vel
      && proj_sumbool
           (type_eq fty
              (Tfunction (tyMSi :: tfloat :: nil) tvoid cc_default))
      && match al with
         | Etempvar mp tmp :: _ =>
             Pos.eqb mp interaction._m
             && proj_sumbool (type_eq tmp tyMSi)
         | _ => false
         end)
  (* play_sound: ungated pure-audio external *)
  || (Pos.eqb fid interaction._play_sound
      && proj_sumbool
           (type_eq fty
              (Tfunction (tint :: tptr tfloat :: nil) tvoid cc_default))).

Definition ckpw_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id interaction._m)
  | None => true
  end.

Fixpoint ckpw_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 => ckpw_chk s1 && ckpw_chk s2
  | Sifthenelse _ s1 s2 => ckpw_chk s1 && ckpw_chk s2
  | Sset id _ => ckpw_optid_ok (Some id)
  | Sassign a1 a2 => ckpw_assign_chk a1 a2
  | Scall optid (Evar fid fty) al =>
      ckpw_optid_ok optid && ckpw_call_chk fid fty al
  | _ => false
  end.

(* NON-VACUITY: the recognizer accepts the REAL generated body. *)
Lemma ckpw_chk_body :
  ckpw_chk (fn_body interaction.f_check_kick_or_punch_wall) = true.
Proof. vm_compute. reflexivity. Qed.

Section CkpwSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.
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

  (* the callee rows *)
  Hypothesis Hocp_resolve :
    call_pres_ext_ol lp bm NoA MWF SafeB
      interaction._resolve_and_return_wall_collisions.
  Hypothesis Hcp_msfv :
    call_pres lp bm NoA MWF interaction._mario_set_forward_vel.
  Hypothesis Hcpx_play :
    call_pres_ext lp bm NoA MWF interaction._play_sound.

  (* ---- decoders ---- *)
  Lemma ckpw_assign_decode :
    forall a1 a2, ckpw_assign_chk a1 a2 = true ->
      safe_mfield_store interaction._m a1 = true
      \/ const_act_store_chk a1 a2 = true
      \/ exists idxN,
          a1 = Ederef (Ebinop Oadd
                         (Evar interaction._detector (tarray tfloat 3))
                         (Econst_int idxN tint) (tptr tfloat)) tfloat.
  Proof.
    intros a1 a2 H. unfold ckpw_assign_chk in H.
    apply orb_true_iff in H as [H | Hidx];
      [ apply orb_true_iff in H as [Hsf | Hca];
        [ left; exact Hsf | right; left; exact Hca ] | right; right ].
    destruct a1 as [ | | | | | | ein eity | | | | | | | ]; try discriminate Hidx.
    destruct ein as [ | | | | | | | | | bop e1 e2 bty | | | | ];
      try discriminate Hidx.
    destruct bop; try discriminate Hidx.
    destruct e1 as [ | | | | vid vty | | | | | | | | | ]; try discriminate Hidx.
    destruct e2 as [ ic ict | | | | | | | | | | | | | ]; try discriminate Hidx.
    apply andb_true_iff in Hidx as [Hidx He2y].
    apply andb_true_iff in Hidx as [Hidx Hity].
    apply andb_true_iff in Hidx as [Hidx Hict].
    apply andb_true_iff in Hidx as [Hlid Harr].
    apply Pos.eqb_eq in Hlid; subst vid.
    destruct (type_eq vty (tarray tfloat 3)) as [Ea | ]; [ subst vty | discriminate Harr ].
    destruct (type_eq ict tint) as [Ei | ]; [ subst ict | discriminate Hict ].
    destruct (type_eq bty (tptr tfloat)) as [Eb | ]; [ subst bty | discriminate Hity ].
    destruct (type_eq eity tfloat) as [Ee | ]; [ subst eity | discriminate He2y ].
    exists ic. reflexivity.
  Qed.

  Lemma ckpw_call_decode :
    forall fid fty al, ckpw_call_chk fid fty al = true ->
      (fid = interaction._resolve_and_return_wall_collisions /\
       fty = Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
               (tptr (Tstruct interaction._Surface noattr)) cc_default /\
       exists c1 t1 c2 t2,
         al = Evar interaction._detector (tarray tfloat 3)
              :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
      \/ (fid = interaction._mario_set_forward_vel /\
          fty = Tfunction (tyMSi :: tfloat :: nil) tvoid cc_default /\
          exists rest, al = Etempvar interaction._m tyMSi :: rest)
      \/ (fid = interaction._play_sound /\
          fty = Tfunction (tint :: tptr tfloat :: nil) tvoid cc_default).
  Proof.
    intros fid fty al H. unfold ckpw_call_chk in H.
    apply orb_true_iff in H as [H | Hps].
    apply orb_true_iff in H as [Hres | Hms].
    - left.
      apply andb_true_iff in Hres as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid; subst fid.
      destruct (type_eq fty (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
                  (tptr (Tstruct interaction._Surface noattr)) cc_default))
        as [-> | ]; [ | discriminate Hfty ].
      split; [ reflexivity | split; [ reflexivity | ] ].
      destruct al as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | dv dvt | | | | | | | | | ]; try discriminate Hal.
      destruct al1 as [ | a2 al2 ]; try discriminate Hal.
      destruct a2 as [ | | c1 t1 | | | | | | | | | | | ]; try discriminate Hal.
      destruct al2 as [ | a3 al3 ]; try discriminate Hal.
      destruct a3 as [ | | c2 t2 | | | | | | | | | | | ]; try discriminate Hal.
      destruct al3; try discriminate Hal.
      apply andb_true_iff in Hal as [Hdv Hdvt].
      apply Pos.eqb_eq in Hdv; subst dv.
      destruct (type_eq dvt (tarray tfloat 3)) as [-> | ]; [ | discriminate Hdvt ].
      exists c1, t1, c2, t2. reflexivity.
    - right; left.
      apply andb_true_iff in Hms as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid; subst fid.
      destruct (type_eq fty (Tfunction (tyMSi :: tfloat :: nil) tvoid cc_default))
        as [-> | ]; [ | discriminate Hfty ].
      split; [ reflexivity | split; [ reflexivity | ] ].
      destruct al as [ | a1 rest ]; try discriminate Hal.
      destruct a1 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      apply andb_true_iff in Hal as [Hmp Htmp].
      apply Pos.eqb_eq in Hmp; subst mp.
      destruct (type_eq tmp tyMSi) as [-> | ]; [ | discriminate Htmp ].
      exists rest. reflexivity.
    - right; right.
      apply andb_true_iff in Hps as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid; subst fid.
      destruct (type_eq fty (Tfunction (tint :: tptr tfloat :: nil) tvoid
                  cc_default)) as [-> | ]; [ | discriminate Hfty ].
      split; reflexivity.
  Qed.

  (* ---- the rest-tolerant marg internal-call brick: `optid := f(m, ...)`
     where only the HEAD arg is Mario's pointer (marg_ok ignores the
     tail).  cp_scall_pres twin with arbitrary trailing args. ---- *)
  Lemma cp2_scall_pres :
    forall optid fid tyrest rty cc rest e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction (tyMSi :: tyrest) rty cc))
           (Etempvar interaction._m tyMSi :: rest))
        tr le1 m1 out0 ->
      call_pres lp bm NoA MWF fid ->
      (forall b o, le0 ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyrest rty cc rest e le0 m0 tr le1 m1 out0
           He Hexec Hcp Htat Hc.
    destruct Hc as (HV & HS & HM & HN).
    inv Hexec.
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv)
          as (bf & Hsym & ->)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: _) (_ :: _) _ |- _ =>
        inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
        subst; clear Hvl
    end.
    apply RealFrameValue.eval_expr_Etempvar_val in Hev_a.
    match goal with
    | Hca : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hca; subst
    end.
    assert (Hmarg : marg_ok bm (v1a :: vl1))
      by (destruct v1a; cbn; try exact I; exact (Htat _ _ Hev_a)).
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _) _ _ _,
      Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some _ |- _ =>
        destruct (Hcp _ _ _ _ _ _ Hevf
                    ltac:(red; exists bf; split; assumption)
                    Hmarg HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

  (* ==================================================================== *)
  (* THE WALKER (pgs shape: carried + the conditional _m marg)            *)
  (* ==================================================================== *)
  Lemma ckpw_walk_pres :
    forall db dty,
      local_blk lp bm SafeB db ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        ckpw_chk s = true ->
        e ! interaction._resolve_and_return_wall_collisions = None ->
        e ! interaction._mario_set_forward_vel = None ->
        e ! interaction._play_sound = None ->
        e ! interaction._detector = Some (db, dty) ->
        (forall b o, le ! interaction._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        carried bm NoA MWF m0 ->
        carried bm NoA MWF m' /\
        (forall b o, le' ! interaction._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero).
  Proof.
    intros db dty Hdetloc s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hrn Hms Hps Hdet Hm Hc.
    - (* Sskip *) exact (conj Hc Hm).
    - (* Sassign a1 a2 *)
      cbn [ckpw_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct (ckpw_assign_decode _ _ Hchk) as [Hsf | [Hca | (idxN & ->)]].
      + (* safe Mario-field store: value-blind epi *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))) Hm).
      + (* m->action := statically untainted constant *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (const_act_assign_pres lp LO_mario bm MWF HMWF_act
                    a1 a2 e le m _ _ m' _ Hca Hm Hex HM HV)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))) Hm).
      + (* detector[i] indexed fn_var local store *)
        destruct (local_idx_assign_pres' lp bm NoA MWF SafeB Hls_real
                    HNoA_of_MWF e interaction._detector tfloat 3%Z noattr
                    idxN (tptr tfloat) tfloat a2 le m E0 le m' Out_normal
                    db dty Mfloat32 Hdet Hdetloc eq_refl Hex Hc)
          as (Hc' & _ & _).
        exact (conj Hc' Hm).
    - (* Sset id a: id <> _m *)
      cbn [ckpw_chk ckpw_optid_ok] in Hchk.
      apply negb_true_iff in Hchk.
      refine (conj Hc _).
      intros b o Hg.
      rewrite PTree.gso in Hg by (intro EE; subst id;
        rewrite Pos.eqb_refl in Hchk; discriminate Hchk).
      exact (Hm b o Hg).
    - (* Scall optid a al *)
      cbn [ckpw_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t
                      (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : forall b o,
                 (set_opttemp optid vres le) ! interaction._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { cbn [ckpw_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply negb_true_iff in Hopt.
          intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt; discriminate Hopt). exact (Hm b o Hg).
        - exact Hm. }
      destruct (ckpw_call_decode _ _ _ Hcc)
        as [ (Hfeq & Hftyeq & (c1 & t1c & c2 & t2c & Haleq))
           | [ (Hfeq & Hftyeq & (rest & Haleq))
             | (Hfeq & Hftyeq) ] ].
      + (* ol: resolve_and_return_wall_collisions(detector, c1, c2) *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Evar interaction._detector (tarray tfloat 3)
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
          (* head: the fn_var stack array decays to its base pointer *)
          inv Hev_a;
            [ match goal with
              | Hop : match _ with _ => _ end = Some _ |- _ =>
                  cbn in Hop; discriminate Hop
              end .. | ].
          match goal with
          | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
          end;
          [ | match goal with
              | Hn : e ! interaction._detector = None |- _ =>
                  rewrite Hdet in Hn; discriminate Hn
              end ].
          match goal with
          | Hb : e ! interaction._detector = Some (?loc, _) |- _ =>
              assert (Eloc : loc = db) by congruence; subst loc
          end.
          match goal with
          | Hd : deref_loc _ _ db _ _ _ |- _ =>
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
          | Hca : sem_cast (Vptr db _) _ _ _ = Some _ |- _ =>
              cbn in Hca; injection Hca as <-
          end.
          apply eval_Econst_single_val in Hev_b; subst v1b.
          apply eval_Econst_single_val in Hev_c; subst v1c.
          intros bb oo Hin; cbn in Hin.
          destruct Hin as [E | [E | [E | []]]];
          [ injection E as <- <-; exact Hdetloc
          | rewrite E in Hsc_b;
            apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_b;
            discriminate Hsc_b
          | rewrite E in Hsc_c;
            apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_c;
            discriminate Hsc_c ]. }
        destruct (ol_scall_pres lp bm NoA MWF SafeB optid
                    interaction._resolve_and_return_wall_collisions
                    (tptr tfloat :: tfloat :: tfloat :: nil)
                    (tptr (Tstruct interaction._Surface noattr)) cc_default
                    (Evar interaction._detector (tarray tfloat 3)
                     :: Econst_single c1 t1c :: Econst_single c2 t2c :: nil)
                    e le m _ _ m' _ Hrn Hocp_resolve Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' HmL).
      + (* marg internal: mario_set_forward_vel(m, vel) *)
        subst fid fty al.
        destruct (cp2_scall_pres optid interaction._mario_set_forward_vel
                    (tfloat :: nil) tvoid cc_default rest
                    e le m _ _ m' _ Hms Hex Hcp_msfv Hm Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* play_sound: ungated audio external *)
        subst fid fty.
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid interaction._play_sound
                    (tint :: tptr tfloat :: nil) tvoid cc_default
                    al e le m _ _ m' _ Hps Hex Hcpx_play HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
    - (* Sbuiltin: rejected *)
      cbn [ckpw_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [ckpw_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hrn Hms Hps Hdet Hm Hc) as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hrn Hms Hps Hdet Hm1 Hc1).
    - (* Sseq_2 *)
      cbn [ckpw_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hrn Hms Hps Hdet Hm Hc).
    - (* Sifthenelse *)
      cbn [ckpw_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc Hm).
    - (* Sreturn (Some _) *) exact (conj Hc Hm).
    - (* Sbreak *) exact (conj Hc Hm).
    - (* Scontinue *) exact (conj Hc Hm).
    - (* Sloop stop1: rejected *)
      cbn [ckpw_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: rejected *)
      cbn [ckpw_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: rejected *)
      cbn [ckpw_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [ckpw_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ==================================================================== *)
  (* THE ENTRY: alloc _detector, bind _m (marg), walk, free.              *)
  (* ==================================================================== *)
  Lemma ckpw_body_pres :
    body_pres lp NoA MWF bm interaction.f_check_kick_or_punch_wall.
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
    unfold interaction.f_check_kick_or_punch_wall in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _detector fn_var is a watched-disjoint stack block *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (interaction._detector :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_eq
                        | discriminate Hf ]))
      as Hlids.
    destruct (Hlids interaction._detector eq_refl)
      as (db & dty & Hdet & Hdetloc).
    (* bind the 1 param _m *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1; [ | cbn [bind_parameter_temps] in Hbind;
                      discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! interaction._m = Some v_m)
      by (rewrite <- Hle_init; apply PTree.gss).
    assert (Hmcond : forall b o,
               le1 ! interaction._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite Hmeq in Hg. injection Hg as Hg.
      subst v_m. exact Hmarg. }
    (* the 3 callees are unbound globals in the entry env *)
    assert (Hrn : eloc !
              interaction._resolve_and_return_wall_collisions = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._resolve_and_return_wall_collisions)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hms : eloc ! interaction._mario_set_forward_vel = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._mario_set_forward_vel)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hps : eloc ! interaction._play_sound = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._play_sound)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (ckpw_walk_pres db dty Hdetloc _ _ _ _ _ _ _ _
                Hbody ckpw_chk_body Hrn Hms Hps Hdet Hmcond Hcar)
      as (Hcarr & _).
    (* ---- exit: free the fn_var stack block ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* THE DISCHARGE *)
  Lemma ckpw_cp :
    call_pres lp bm NoA MWF interaction._check_kick_or_punch_wall.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF interaction.prog
             interaction._check_kick_or_punch_wall
             interaction.f_check_kick_or_punch_wall
             LO_int ckpw_pin ckpw_body_pres).
  Qed.

End CkpwSurface.

(* ====================================================================== *)
(* ====================  push_mario_out_of_object  ====================== *)
(* interaction.v:3939, ~260 lines: chase loads through _o/_t'19 (memory-  *)
(* pure), local scalar stores (newMarioX/newMarioZ), m->pos[i] indexed    *)
(* window stores, sqrtf/atan2s (ungated math externals), find_floor       *)
(* (oc, &_floor), and the MIXED f32_find_wall_collision(&newMarioX,       *)
(* &m->pos[1], &newMarioZ, c, c) (the wol arc).  _o is only ever LOADED   *)
(* through, so the honest gate is plain marg: call_pres.                  *)
(* ====================================================================== *)

Definition pmoo_lids : list ident :=
  interaction._floor :: interaction._newMarioX
    :: interaction._newMarioZ :: nil.

Definition pmoo_local_store_chk (a1 : expr) : bool :=
  match a1 with
  | Evar l ty =>
      mem_id l (interaction._newMarioX :: interaction._newMarioZ :: nil)
      && proj_sumbool (type_eq ty tfloat)
  | _ => false
  end.

Definition pmoo_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  oc_call_chk (interaction._floor :: nil) (interaction._find_floor :: nil)
    fid fty al
  || (Pos.eqb fid interaction._f32_find_wall_collision
      && proj_sumbool
           (type_eq fty
              (Tfunction
                 (tptr tfloat :: tptr tfloat :: tptr tfloat
                  :: tfloat :: tfloat :: nil) tint cc_default))
      && match al with
         | Eaddrof (Evar x1 tx1) tp1
           :: Ebinop Oadd
                (Efield (Ederef (Etempvar mp tmp) tsm) fld tfa)
                (Econst_int idx ti) tp2
           :: Eaddrof (Evar x2 tx2) tp3
           :: Econst_single _ _ :: Econst_single _ _ :: nil =>
             Pos.eqb x1 interaction._newMarioX
             && Pos.eqb x2 interaction._newMarioZ
             && Pos.eqb mp interaction._m
             && Pos.eqb fld interaction._pos
             && proj_sumbool (type_eq tx1 tfloat)
             && proj_sumbool (type_eq tx2 tfloat)
             && proj_sumbool (type_eq tp1 (tptr tfloat))
             && proj_sumbool (type_eq tp3 (tptr tfloat))
             && proj_sumbool (type_eq tmp (tptr tyMS))
             && proj_sumbool (type_eq tsm tyMS)
             && proj_sumbool (type_eq tfa (tarray tfloat 3))
             && proj_sumbool (type_eq ti tint)
             && proj_sumbool (type_eq tp2 (tptr tfloat))
             && idx_geom_chk interaction._pos idx 4 Mfloat32
         | _ => false
         end)
  || (Pos.eqb fid interaction._sqrtf
      && proj_sumbool
           (type_eq fty (Tfunction (tfloat :: nil) tfloat cc_default)))
  || (Pos.eqb fid interaction._atan2s
      && proj_sumbool
           (type_eq fty
              (Tfunction (tfloat :: tfloat :: nil) tshort cc_default))).

Definition pmoo_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id interaction._m)
  | None => true
  end.

Fixpoint pmoo_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 => pmoo_chk s1 && pmoo_chk s2
  | Sifthenelse _ s1 s2 => pmoo_chk s1 && pmoo_chk s2
  | Sset id _ => pmoo_optid_ok (Some id)
  | Sassign a1 _ =>
      safe_mfield_store interaction._m a1
      || idx_mfield_store interaction._m a1
      || pmoo_local_store_chk a1
  | Scall optid (Evar fid fty) al =>
      pmoo_optid_ok optid && pmoo_call_chk fid fty al
  | _ => false
  end.

Lemma pmoo_chk_body :
  pmoo_chk (fn_body interaction.f_push_mario_out_of_object) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma pmoo_pin :
  (prog_defmap interaction.prog) ! interaction._push_mario_out_of_object
  = Some (Gfun (Internal interaction.f_push_mario_out_of_object)).
Proof. vm_compute. reflexivity. Qed.

Lemma pmoo_not_exempt :
  marg_exempt (Internal interaction.f_push_mario_out_of_object) = false.
Proof. vm_compute. reflexivity. Qed.

Section PmooSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

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

  (* the callee rows *)
  Hypothesis Hocp_ff :
    call_pres_ext_oc lp bm NoA MWF SafeB interaction._find_floor.
  Hypothesis Hwolcp_fwc :
    call_pres_ext_wol lp bm NoA MWF SafeB
      interaction._f32_find_wall_collision.
  Hypothesis Hcpx_sqrtf :
    call_pres_ext lp bm NoA MWF interaction._sqrtf.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF interaction._atan2s.

  (* ---- decoders ---- *)
  Lemma pmoo_local_decode :
    forall a1, pmoo_local_store_chk a1 = true ->
      exists l, a1 = Evar l tfloat /\
        mem_id l (interaction._newMarioX :: interaction._newMarioZ :: nil)
        = true.
  Proof.
    intros a1 H.
    destruct a1 as [ | | | | l ty | | | | | | | | | ]; try discriminate H.
    unfold pmoo_local_store_chk in H.
    apply andb_true_iff in H as [Hl Hty].
    destruct (type_eq ty tfloat) as [-> | ]; [ | discriminate Hty ].
    exists l. split; [ reflexivity | exact Hl ].
  Qed.

  Lemma pmoo_call_decode :
    forall fid fty al, pmoo_call_chk fid fty al = true ->
      oc_call_chk (interaction._floor :: nil)
        (interaction._find_floor :: nil) fid fty al = true
      \/ (fid = interaction._f32_find_wall_collision /\
          fty = Tfunction
                  (tptr tfloat :: tptr tfloat :: tptr tfloat
                   :: tfloat :: tfloat :: nil) tint cc_default /\
          exists idx c4 t4 c5 t5,
            al = Eaddrof (Evar interaction._newMarioX tfloat) (tptr tfloat)
                 :: Ebinop Oadd
                      (Efield
                         (Ederef (Etempvar interaction._m (tptr tyMS)) tyMS)
                         interaction._pos (tarray tfloat 3))
                      (Econst_int idx tint) (tptr tfloat)
                 :: Eaddrof (Evar interaction._newMarioZ tfloat) (tptr tfloat)
                 :: Econst_single c4 t4 :: Econst_single c5 t5 :: nil /\
            idx_geom_chk interaction._pos idx 4 Mfloat32 = true)
      \/ (fid = interaction._sqrtf /\
          fty = Tfunction (tfloat :: nil) tfloat cc_default)
      \/ (fid = interaction._atan2s /\
          fty = Tfunction (tfloat :: tfloat :: nil) tshort cc_default).
  Proof.
    intros fid fty al H. unfold pmoo_call_chk in H.
    apply orb_true_iff in H as [H | Hat].
    apply orb_true_iff in H as [H | Hsq].
    apply orb_true_iff in H as [Hoc | Hfwc].
    - left. exact Hoc.
    - right; left.
      apply andb_true_iff in Hfwc as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction
                     (tptr tfloat :: tptr tfloat :: tptr tfloat
                      :: tfloat :: tfloat :: nil) tint cc_default))
        as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | | | | inner1 tp1 | | | | | | ];
        try discriminate Hal.
      destruct inner1 as [ | | | | x1 tx1 | | | | | | | | | ];
        try discriminate Hal.
      destruct al1 as [ | a2 al2 ]; try discriminate Hal.
      destruct a2 as [ | | | | | | | | | op b1 b2 tp2 | | | | ];
        try discriminate Hal.
      destruct op; try discriminate Hal.
      destruct b1 as [ | | | | | | | | | | | ef fld tfa | | ];
        try discriminate Hal.
      destruct ef as [ | | | | | | edb tsm | | | | | | | ];
        try discriminate Hal.
      destruct edb as [ | | | | | mp tmp | | | | | | | | ];
        try discriminate Hal.
      destruct b2 as [ idx ti | | | | | | | | | | | | | ];
        try discriminate Hal.
      destruct al2 as [ | a3 al3 ]; try discriminate Hal.
      destruct a3 as [ | | | | | | | inner3 tp3 | | | | | | ];
        try discriminate Hal.
      destruct inner3 as [ | | | | x2 tx2 | | | | | | | | | ];
        try discriminate Hal.
      destruct al3 as [ | a4 al4 ]; try discriminate Hal.
      destruct a4 as [ | | c4 t4 | | | | | | | | | | | ];
        try discriminate Hal.
      destruct al4 as [ | a5 al5 ]; try discriminate Hal.
      destruct a5 as [ | | c5 t5 | | | | | | | | | | | ];
        try discriminate Hal.
      destruct al5; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Hgeo].
      apply andb_true_iff in Hal as [Hal Htp2].
      apply andb_true_iff in Hal as [Hal Hti].
      apply andb_true_iff in Hal as [Hal Htfa].
      apply andb_true_iff in Hal as [Hal Htsm].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hal Htp3].
      apply andb_true_iff in Hal as [Hal Htp1].
      apply andb_true_iff in Hal as [Hal Htx2].
      apply andb_true_iff in Hal as [Hal Htx1].
      apply andb_true_iff in Hal as [Hal Hfld].
      apply andb_true_iff in Hal as [Hal Hmp].
      apply andb_true_iff in Hal as [Hx1 Hx2].
      apply Pos.eqb_eq in Hx1; subst x1.
      apply Pos.eqb_eq in Hx2; subst x2.
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hfld; subst fld.
      destruct (type_eq tx1 tfloat) as [-> | ]; [ | discriminate Htx1 ].
      destruct (type_eq tx2 tfloat) as [-> | ]; [ | discriminate Htx2 ].
      destruct (type_eq tp1 (tptr tfloat)) as [-> | ];
        [ | discriminate Htp1 ].
      destruct (type_eq tp3 (tptr tfloat)) as [-> | ];
        [ | discriminate Htp3 ].
      destruct (type_eq tmp (tptr tyMS)) as [-> | ];
        [ | discriminate Htmp ].
      destruct (type_eq tsm tyMS) as [-> | ]; [ | discriminate Htsm ].
      destruct (type_eq tfa (tarray tfloat 3)) as [-> | ];
        [ | discriminate Htfa ].
      destruct (type_eq ti tint) as [-> | ]; [ | discriminate Hti ].
      destruct (type_eq tp2 (tptr tfloat)) as [-> | ];
        [ | discriminate Htp2 ].
      exists idx, c4, t4, c5, t5. split; [ reflexivity | exact Hgeo ].
    - do 2 right; left.
      apply andb_true_iff in Hsq as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tfloat :: nil) tfloat cc_default))
        as [Efty | ]; [ | discriminate Hfty ].
      exact (conj Hfid Efty).
    - do 3 right.
      apply andb_true_iff in Hat as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tshort
                               cc_default)) as [Efty | ];
        [ | discriminate Hfty ].
      exact (conj Hfid Efty).
  Qed.

  (* ---- the local scalar store brick (newMarioX/newMarioZ) ---- *)
  Lemma pmoo_local_assign_pres :
    forall l lb lty a2 e le m0 tr le' m' out,
      e ! l = Some (lb, lty) ->
      local_blk lp bm SafeB lb ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign (Evar l tfloat) a2) tr le' m' out ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros l lb lty a2 e le m0 tr le' m' out Hl Hloc Hexec Hc.
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
    end.
    2:{ match goal with
        | Hn : e ! l = None |- _ => rewrite Hl in Hn; discriminate Hn
        end. }
    match goal with
    | Hb : e ! l = Some _ |- _ =>
        rewrite Hl in Hb; injection Hb as <- _
    end.
    match goal with
    | Has : assign_loc _ (typeof _) _ _ _ _ _ _ |- _ =>
        cbn [typeof] in Has; inv Has
    end.
    2:{ match goal with
        | Hac : access_mode _ = By_copy |- _ =>
            cbn in Hac; discriminate Hac
        end. }
    match goal with
    | Hac : access_mode _ = By_value _ |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hsv : Mem.storev _ _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hsv; rewrite Ptrofs.unsigned_zero in Hsv
    end.
    refine (conj _ (conj eq_refl eq_refl)).
    eapply (localstore_carried lp bm NoA MWF SafeB Hls_real HNoA_of_MWF);
      [ exact Hloc | | exact Hc ].
    match goal with
    | Hst : Mem.store _ _ lb _ _ = Some _ |- _ => exact Hst
    end.
  Qed.

  (* ---- the mixed fwc gate: ptr args are (local, bm-window, local) ---- *)
  Lemma fwc_args_gate :
    forall idx c4 t4 c5 t5 e le m nXb nXty nZb nZty,
      e ! interaction._newMarioX = Some (nXb, nXty) ->
      local_blk lp bm SafeB nXb ->
      e ! interaction._newMarioZ = Some (nZb, nZty) ->
      local_blk lp bm SafeB nZb ->
      (forall b o, le ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      idx_geom_chk interaction._pos idx 4 Mfloat32 = true ->
      forall vargs,
        eval_exprlist (lp_ge lp) e le m
          (Eaddrof (Evar interaction._newMarioX tfloat) (tptr tfloat)
           :: Ebinop Oadd
                (Efield (Ederef (Etempvar interaction._m (tptr tyMS)) tyMS)
                   interaction._pos (tarray tfloat 3))
                (Econst_int idx tint) (tptr tfloat)
           :: Eaddrof (Evar interaction._newMarioZ tfloat) (tptr tfloat)
           :: Econst_single c4 t4 :: Econst_single c5 t5 :: nil)
          (tptr tfloat :: tptr tfloat :: tptr tfloat
           :: tfloat :: tfloat :: nil) vargs ->
        args_window_or_local lp bm SafeB vargs.
  Proof.
    intros idx c4 t4 c5 t5 e le m nXb nXty nZb nZty
           HnX HnXloc HnZ HnZloc Hm Hgeo vargs Hvl.
    inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
      subst; clear Hvl.
    inversion Htl1 as [ | a2 bl2 ty2 tyl2 v1b v2b vl2 Hev_b Hsc_b Htl2 ];
      subst; clear Htl1.
    inversion Htl2 as [ | a3 bl3 ty3 tyl3 v1c v2c vl3 Hev_c Hsc_c Htl3 ];
      subst; clear Htl2.
    inversion Htl3 as [ | a4 bl4 ty4 tyl4 v1d v2d vl4 Hev_d Hsc_d Htl4 ];
      subst; clear Htl3.
    inversion Htl4 as [ | a5 bl5 ty5 tyl5 v1e v2e vl5 Hev_e Hsc_e Htl5 ];
      subst; clear Htl4.
    inversion Htl5; subst; clear Htl5.
    (* arg1: &newMarioX -> Vptr nXb 0 *)
    inv Hev_a.
    2:{ match goal with
        | Hlv : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hlv
        end. }
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar interaction._newMarioX _) _ _ _ |- _ =>
        inv Hlv
    end.
    2:{ match goal with
        | Hn : e ! interaction._newMarioX = None |- _ =>
            rewrite HnX in Hn; discriminate Hn
        end. }
    match goal with
    | Hb : e ! interaction._newMarioX = Some (?l0, tfloat) |- _ =>
        rewrite HnX in Hb; injection Hb as <- _
    end.
    (* arg2: &m->pos[idx] -> Vptr bm o2 (safe window) *)
    destruct (window_addr_val lp LO_mario bm _ _ _ _ _ _ _ _ Hm Hgeo Hev_b)
      as (o2 & Ev2 & Hwin2).
    subst v1b.
    (* arg3: &newMarioZ -> Vptr nZb 0 *)
    inv Hev_c.
    2:{ match goal with
        | Hlv : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hlv
        end. }
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar interaction._newMarioZ _) _ _ _ |- _ =>
        inv Hlv
    end.
    2:{ match goal with
        | Hn : e ! interaction._newMarioZ = None |- _ =>
            rewrite HnZ in Hn; discriminate Hn
        end. }
    match goal with
    | Hb : e ! interaction._newMarioZ = Some (?l0, tfloat) |- _ =>
        rewrite HnZ in Hb; injection Hb as <- _
    end.
    (* args 4/5: float singles *)
    apply (eval_Econst_single_val lp) in Hev_d; subst v1d.
    apply (eval_Econst_single_val lp) in Hev_e; subst v1e.
    intros bb oo Hin; cbn in Hin.
    destruct Hin as [E | [E | [E | [E | [E | []]]]]]; subst.
    - apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_a;
        injection Hsc_a as <- <-.
      right. exact HnXloc.
    - apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_b;
        injection Hsc_b as <- <-.
      left. exact (conj eq_refl Hwin2).
    - apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_c;
        injection Hsc_c as <- <-.
      right. exact HnZloc.
    - apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_d;
        discriminate Hsc_d.
    - apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_e;
        discriminate Hsc_e.
  Qed.

  (* ---- THE WALKER ---- *)
  Lemma pmoo_walk_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      pmoo_chk s = true ->
      e ! interaction._find_floor = None ->
      e ! interaction._f32_find_wall_collision = None ->
      e ! interaction._sqrtf = None ->
      e ! interaction._atan2s = None ->
      (forall l, mem_id l pmoo_lids = true ->
         exists lblk tyenv, e ! l = Some (lblk, tyenv) /\
                            local_blk lp bm SafeB lblk) ->
      (forall b o, le ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\
      (forall b o, le' ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero).
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hff Hfwc Hsq Hat Hlids Hm Hc.
    - (* Sskip *) exact (conj Hc Hm).
    - (* Sassign *)
      cbn [pmoo_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      apply orb_true_iff in Hchk as [Hchk | Hloc].
      apply orb_true_iff in Hchk as [Hsf | Hix].
      + destruct Hc as (HV & HS & HM & HN).
        destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 Hm).
      + destruct Hc as (HV & HS & HM & HN).
        destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hix Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 Hm).
      + destruct (pmoo_local_decode _ Hloc) as (l & -> & Hmem).
        assert (Hmem3 : mem_id l pmoo_lids = true).
        { unfold mem_id in Hmem; cbn [existsb] in Hmem.
          apply Bool.orb_true_iff in Hmem as [He | Hmem].
          - apply Pos.eqb_eq in He; subst l. reflexivity.
          - apply Bool.orb_true_iff in Hmem as [He | F];
              [ apply Pos.eqb_eq in He; subst l; reflexivity
              | discriminate F ]. }
        destruct (Hlids l Hmem3) as (lb & lty & Hl & Hloc').
        destruct (pmoo_local_assign_pres l lb lty a2 _ _ _ _ _ _ _
                    Hl Hloc' Hex Hc) as (Hc' & _ & _).
        exact (conj Hc' Hm).
    - (* Sset *)
      cbn [pmoo_chk pmoo_optid_ok] in Hchk.
      apply negb_true_iff in Hchk.
      refine (conj Hc _).
      intros b o Hg.
      rewrite PTree.gso in Hg by (intro EE; subst id;
        rewrite Pos.eqb_refl in Hchk; discriminate Hchk).
      exact (Hm b o Hg).
    - (* Scall *)
      cbn [pmoo_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t
                      (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : forall b o,
                 (set_opttemp optid vres le) ! interaction._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { cbn [pmoo_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply negb_true_iff in Hopt.
          intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt; discriminate Hopt).
          exact (Hm b o Hg).
        - exact Hm. }
      destruct (pmoo_call_decode _ _ _ Hcc)
        as [ Hoc
           | [ (Hfeq & Hftyeq & (idx & c4 & t4 & c5 & t5 & Haleq & Hgeo))
             | [ (Hfeq & Hftyeq) | (Hfeq & Hftyeq) ] ] ].
      + (* oc: find_floor(.., &floor) *)
        assert (Hcp_oc : forall g,
                  mem_id g (interaction._find_floor :: nil) = true ->
                  call_pres_ext_oc lp bm NoA MWF SafeB g).
        { intros g Hg. unfold mem_id in Hg; cbn [existsb] in Hg.
          apply Bool.orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hocp_ff
            | discriminate F ]. }
        assert (Hnone_oc : forall g,
                  mem_id g (interaction._find_floor :: nil) = true ->
                  e ! g = None).
        { intros g Hg. unfold mem_id in Hg; cbn [existsb] in Hg.
          apply Bool.orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hff
            | discriminate F ]. }
        assert (Hlids_oc : forall l,
                  mem_id l (interaction._floor :: nil) = true ->
                  exists lblk tyenv, e ! l = Some (lblk, tyenv) /\
                                     local_blk lp bm SafeB lblk).
        { intros l Hg. unfold mem_id in Hg; cbn [existsb] in Hg.
          apply Bool.orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst l | discriminate F ].
          apply Hlids. reflexivity. }
        destruct (oc_call_chk_pres lp bm NoA MWF SafeB
                    (interaction._floor :: nil)
                    (interaction._find_floor :: nil)
                    optid fid fty al e le m _ _ m' _
                    Hcp_oc Hnone_oc Hlids_oc Hoc Hex Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* wol: f32_find_wall_collision (mixed window/local ptr args) *)
        subst fid fty al.
        destruct (Hlids interaction._newMarioX eq_refl)
          as (nXb & nXty & HnX & HnXloc).
        destruct (Hlids interaction._newMarioZ eq_refl)
          as (nZb & nZty & HnZ & HnZloc).
        pose proof (fwc_args_gate idx c4 t4 c5 t5 e le m
                      nXb nXty nZb nZty HnX HnXloc HnZ HnZloc Hm Hgeo)
          as Hgate.
        destruct (wol_scall_pres lp bm NoA MWF SafeB optid
                    interaction._f32_find_wall_collision
                    (tptr tfloat :: tptr tfloat :: tptr tfloat
                     :: tfloat :: tfloat :: nil) tint cc_default
                    (Eaddrof (Evar interaction._newMarioX tfloat)
                       (tptr tfloat)
                     :: Ebinop Oadd
                          (Efield
                             (Ederef
                                (Etempvar interaction._m (tptr tyMS)) tyMS)
                             interaction._pos (tarray tfloat 3))
                          (Econst_int idx tint) (tptr tfloat)
                     :: Eaddrof (Evar interaction._newMarioZ tfloat)
                          (tptr tfloat)
                     :: Econst_single c4 t4 :: Econst_single c5 t5 :: nil)
                    e le m _ _ m' _ Hfwc Hwolcp_fwc Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' HmL).
      + (* sqrtf: ungated math external *)
        subst fid fty.
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid interaction._sqrtf
                    (tfloat :: nil) tfloat cc_default
                    al e le m _ _ m' _ Hsq Hex Hcpx_sqrtf HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
      + (* atan2s: ungated math external *)
        subst fid fty.
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid interaction._atan2s
                    (tfloat :: tfloat :: nil) tshort cc_default
                    al e le m _ _ m' _ Hat Hex Hcpx_atan2s HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
    - (* Sbuiltin *)
      cbn [pmoo_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [pmoo_chk] in Hchk.
      apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hff Hfwc Hsq Hat Hlids Hm Hc) as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hff Hfwc Hsq Hat Hlids Hm1 Hc1).
    - (* Sseq_2 *)
      cbn [pmoo_chk] in Hchk.
      apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hff Hfwc Hsq Hat Hlids Hm Hc).
    - (* Sifthenelse *)
      cbn [pmoo_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc Hm).
    - (* Sreturn (Some _) *) exact (conj Hc Hm).
    - (* Sbreak *) exact (conj Hc Hm).
    - (* Scontinue *) exact (conj Hc Hm).
    - (* Sloop stop1 *)
      cbn [pmoo_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2 *)
      cbn [pmoo_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop *)
      cbn [pmoo_chk] in Hchk. discriminate Hchk.
    - (* Sswitch *)
      cbn [pmoo_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ---- THE ENTRY LEMMA ---- *)
  Lemma pmoo_body_pres :
    body_pres lp NoA MWF bm interaction.f_push_mario_out_of_object.
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
    unfold interaction.f_push_mario_out_of_object in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the 3 fn_vars are watched-disjoint stack blocks *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _ pmoo_lids
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id, pmoo_lids in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hmem];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_eq | ];
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hmem];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_cons, in_eq | ];
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_cons, in_cons, in_eq
                        | discriminate Hf ]))
      as Hlids.
    (* bind the 3 params (m, o, padding) *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_o vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2 as [| v_p vr3];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr3 as [| vx vr4];
      cbn [bind_parameter_temps] in Hbind; [ | discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! interaction._m = Some v_m).
    { rewrite <- Hle_init.
      rewrite PTree.gso by (vm_compute; discriminate).
      rewrite PTree.gso by (vm_compute; discriminate).
      apply PTree.gss. }
    assert (Hmcond : forall b o,
               le1 ! interaction._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite Hmeq in Hg. injection Hg as Hg.
      subst v_m. exact Hmarg. }
    (* the 4 callees are unbound globals in the entry env *)
    assert (Hff_none : eloc ! interaction._find_floor = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._find_floor)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH;
            discriminate HH).
      apply PTree.gempty. }
    assert (Hfwc_none :
              eloc ! interaction._f32_find_wall_collision = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._f32_find_wall_collision)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH;
            discriminate HH).
      apply PTree.gempty. }
    assert (Hsq_none : eloc ! interaction._sqrtf = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._sqrtf)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH;
            discriminate HH).
      apply PTree.gempty. }
    assert (Hat_none : eloc ! interaction._atan2s = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._atan2s)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH;
            discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (pmoo_walk_pres _ _ _ _ _ _ _ _
                Hbody pmoo_chk_body Hff_none Hfwc_none Hsq_none Hat_none
                Hlids Hmcond Hcar)
      as (Hcarr & _).
    (* ---- exit: free the fn_var stack blocks ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* THE DISCHARGE *)
  Lemma pmoo_cp :
    call_pres lp bm NoA MWF interaction._push_mario_out_of_object.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF interaction.prog
             interaction._push_mario_out_of_object
             interaction.f_push_mario_out_of_object
             LO_int pmoo_pin pmoo_body_pres).
  Qed.

End PmooSurface.

(* ====================================================================== *)
(* determine_knockback_action (dka): a marg walk whose RETURN value is    *)
(* UNTAINTED -- _bonkAction is only ever loaded from the two knockback    *)
(* tables, whose contents carry MWF's R10 row (MWFReal.mwf_real_ktab).    *)
(* The row shape call_pres_ret_act = call_pres + untainted_scalar vres    *)
(* is what tdaknb's `_t'2 := dka(m, damage)` site needs to feed dasma's   *)
(* call_pres_act action argument.                                         *)
(* ====================================================================== *)

(* the per-helper residual shape: Mario's pointer first, anything after
   -- the funcall preserves the carried run facts AND returns an
   untainted scalar (the table-sourced knockback action). *)
Definition call_pres_ret_act (lp : Clight.program) (bm : block)
    (NoA MWF : mem -> Prop) (fid : ident) : Prop :=
  forall fd m0 vargs0 t0 m1 vres0,
    eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
    resolves_lp lp fid fd ->
    marg_ok bm vargs0 ->
    NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
    action_sat not_tainted m0 bm ->
    Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
    MWF m1 /\ NoA m1 /\ untainted_scalar vres0.

(* recognizer: the exact 2D table-load shape
   sXKnockbackActions[terrainIndex][strengthIndex] *)
Definition dka_table_load_chk (a : expr) : bool :=
  match a with
  | Ederef
      (Ebinop Oadd
         (Ederef
            (Ebinop Oadd (Evar tbl tta) (Etempvar i1 ti1) tp1) ta1)
         (Etempvar i2 ti2) tp2) tyv =>
      mem_id tbl knockback_table_ids
      && proj_sumbool (type_eq tta (tarray (tarray tuint 3) 3))
      && proj_sumbool (type_eq ti1 tshort)
      && proj_sumbool (type_eq tp1 (tptr (tarray tuint 3)))
      && proj_sumbool (type_eq ta1 (tarray tuint 3))
      && proj_sumbool (type_eq ti2 tshort)
      && proj_sumbool (type_eq tp2 (tptr tuint))
      && proj_sumbool (type_eq tyv tuint)
  | _ => false
  end.

(* _bonkAction may ONLY be Sset from a table load; every other Sset just
   has to keep its hands off _m. *)
Definition dka_set_chk (id : ident) (a : expr) : bool :=
  if Pos.eqb id interaction._bonkAction then dka_table_load_chk a
  else negb (Pos.eqb id interaction._m).

(* the two callees, both marg-class rows, called with _m first *)
Definition dka_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (Pos.eqb fid interaction._mario_obj_angle_to_object
   || Pos.eqb fid interaction._mario_set_forward_vel)
  && match fty with
     | Tfunction (tyh :: _) _ _ => proj_sumbool (type_eq tyh tyMSi)
     | _ => false
     end
  && match al with
     | Etempvar mp tmp :: _ =>
         Pos.eqb mp interaction._m && proj_sumbool (type_eq tmp tyMSi)
     | _ => false
     end.

Definition dka_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id interaction._m)
               && negb (Pos.eqb id interaction._bonkAction)
  | None => true
  end.

Fixpoint dka_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn None => true
  | Sreturn (Some a) =>
      match a with
      | Etempvar q ty =>
          Pos.eqb q interaction._bonkAction
          && proj_sumbool (type_eq ty tuint)
      | _ => false
      end
  | Ssequence s1 s2 => dka_chk s1 && dka_chk s2
  | Sifthenelse _ s1 s2 => dka_chk s1 && dka_chk s2
  | Sset id a => dka_set_chk id a
  | Sassign a1 _ =>
      safe_mfield_store interaction._m a1
      || idx_mfield_store interaction._m a1
      || idx16_mfield_store interaction._m a1
  | Scall optid (Evar fid fty) al =>
      dka_optid_ok optid && dka_call_chk fid fty al
  | _ => false
  end.

(* ---- vm pins ---- *)
Lemma dka_chk_body :
  dka_chk (fn_body interaction.f_determine_knockback_action) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma dka_pin :
  (prog_defmap interaction.prog) ! interaction._determine_knockback_action
  = Some (Gfun (Internal interaction.f_determine_knockback_action)).
Proof. vm_compute. reflexivity. Qed.

Lemma dka_vars : fn_vars interaction.f_determine_knockback_action = nil.
Proof. vm_compute. reflexivity. Qed.

Lemma dka_params :
  fn_params interaction.f_determine_knockback_action
  = (interaction._m, tyMSi) :: (interaction._arg, tint) :: nil.
Proof. vm_compute. reflexivity. Qed.

Lemma dka_ret : fn_return interaction.f_determine_knockback_action = tuint.
Proof. vm_compute. reflexivity. Qed.

Section DkaSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  (* the R10 projection (MWFReal.mwf_real_ktab at the capstone) *)
  Hypothesis HMWF_ktab : forall m gid kb (ofs : Z) v,
      MWF m -> mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      Mem.load Mint32 m kb ofs = Some v ->
      untainted_scalar v.

  (* the callee rows (both Internal in interaction.prog, both WALKED:
     ObjectLeafSurface.moato_row / ActWriterSurface.msfv_row) *)
  Hypothesis Hcp_moato :
    call_pres lp bm NoA MWF interaction._mario_obj_angle_to_object.
  Hypothesis Hcp_msfv :
    call_pres lp bm NoA MWF interaction._mario_set_forward_vel.

  (* the walk-carried temp fact: _bonkAction, when bound, is untainted *)
  Definition bonk_inv (le : temp_env) : Prop :=
    forall v, le ! interaction._bonkAction = Some v -> untainted_scalar v.

  (* ---- decoders ---- *)
  Lemma dka_table_decode : forall a, dka_table_load_chk a = true ->
      exists tbl ia ib,
        a = Ederef
              (Ebinop Oadd
                 (Ederef
                    (Ebinop Oadd
                       (Evar tbl (tarray (tarray tuint 3) 3))
                       (Etempvar ia tshort) (tptr (tarray tuint 3)))
                    (tarray tuint 3))
                 (Etempvar ib tshort) (tptr tuint)) tuint /\
        mem_id tbl knockback_table_ids = true.
  Proof.
    intros a H.
    destruct a as [ | | | | | | inner tyv | | | | | | | ];
      try discriminate H.
    destruct inner as [ | | | | | | | | | op b1 b2 tpo | | | | ];
      try discriminate H.
    destruct op; try discriminate H.
    destruct b1 as [ | | | | | | mid ta1 | | | | | | | ];
      try discriminate H.
    destruct mid as [ | | | | | | | | | op2 c1 c2 tpi | | | | ];
      try discriminate H.
    destruct op2; try discriminate H.
    destruct c1 as [ | | | | tbl tta | | | | | | | | | ];
      try discriminate H.
    destruct c2 as [ | | | | | ia tia | | | | | | | | ];
      try discriminate H.
    destruct b2 as [ | | | | | ib tib | | | | | | | | ];
      try discriminate H.
    cbn [dka_table_load_chk] in H.
    apply andb_true_iff in H as [H Htyv].
    apply andb_true_iff in H as [H Htpo].
    apply andb_true_iff in H as [H Htib].
    apply andb_true_iff in H as [H Hta1].
    apply andb_true_iff in H as [H Htpi].
    apply andb_true_iff in H as [H Htia].
    apply andb_true_iff in H as [Hmem Htta].
    destruct (type_eq tta (tarray (tarray tuint 3) 3)) as [-> | ];
      [ | discriminate Htta ].
    destruct (type_eq tia tshort) as [-> | ]; [ | discriminate Htia ].
    destruct (type_eq tpi (tptr (tarray tuint 3))) as [-> | ];
      [ | discriminate Htpi ].
    destruct (type_eq ta1 (tarray tuint 3)) as [-> | ];
      [ | discriminate Hta1 ].
    destruct (type_eq tib tshort) as [-> | ]; [ | discriminate Htib ].
    destruct (type_eq tpo (tptr tuint)) as [-> | ];
      [ | discriminate Htpo ].
    destruct (type_eq tyv tuint) as [-> | ]; [ | discriminate Htyv ].
    exists tbl, ia, ib. split; [ reflexivity | exact Hmem ].
  Qed.

  Lemma dka_call_decode : forall fid fty al,
      dka_call_chk fid fty al = true ->
      (fid = interaction._mario_obj_angle_to_object
       \/ fid = interaction._mario_set_forward_vel) /\
      exists tyrest rty cc rest,
        fty = Tfunction (tyMSi :: tyrest) rty cc /\
        al = Etempvar interaction._m tyMSi :: rest.
  Proof.
    intros fid fty al H. unfold dka_call_chk in H.
    apply andb_true_iff in H as [H Hal].
    apply andb_true_iff in H as [Hfid Hfty].
    split.
    { apply orb_true_iff in Hfid as [E | E]; apply Pos.eqb_eq in E;
        [ left | right ]; exact E. }
    destruct fty as [ | | | | | | tyl rty cc | | ]; try discriminate Hfty.
    destruct tyl as [ | tyh tyrest ]; try discriminate Hfty.
    destruct (type_eq tyh tyMSi) as [-> | ]; [ | discriminate Hfty ].
    destruct al as [ | a1 rest ]; try discriminate Hal.
    destruct a1 as [ | | | | | mp tmp | | | | | | | | ];
      try discriminate Hal.
    apply andb_true_iff in Hal as [Hmp Htmp].
    apply Pos.eqb_eq in Hmp; subst mp.
    destruct (type_eq tmp tyMSi) as [-> | ]; [ | discriminate Htmp ].
    exists tyrest, rty, cc, rest. split; reflexivity.
  Qed.
  (* ---- the table-load value brick (consumes R10) ---- *)
  Lemma dka_table_load_val :
    forall tbl ia ib e le m v,
      mem_id tbl knockback_table_ids = true ->
      e ! tbl = None ->
      MWF m ->
      eval_expr (lp_ge lp) e le m
        (Ederef
           (Ebinop Oadd
              (Ederef
                 (Ebinop Oadd
                    (Evar tbl (tarray (tarray tuint 3) 3))
                    (Etempvar ia tshort) (tptr (tarray tuint 3)))
                 (tarray tuint 3))
              (Etempvar ib tshort) (tptr tuint)) tuint) v ->
      untainted_scalar v.
  Proof.
    intros tbl ia ib e le m v Hmem Hnone HM Hev.
    (* outer Ederef rvalue: only eval_Elvalue applies *)
    inv Hev.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ =>
        cbn [typeof] in Hd; rename Hd into Hdl
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    (* the outer Oadd *)
    match goal with
    | Hx : eval_expr _ _ _ _ (Ebinop _ _ _ _) (Vptr _ _) |- _ => inv Hx
    end.
    2:{ match goal with
        | Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv
        end. }
    match goal with
    | Hs : sem_binary_operation _ _ _ (typeof _) _ _ _ = Some (Vptr _ _)
      |- _ => cbn [typeof] in Hs; rename Hs into Hsem
    end.
    (* the middle Ederef at array type: By_reference passthrough *)
    match goal with
    | Hx : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hx
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ =>
        cbn [typeof] in Hd; rename Hd into Hdl2
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    inv Hdl2;
      try (match goal with
           | Hacc : access_mode (tarray tuint 3) = _ |- _ =>
               cbn in Hacc; discriminate Hacc
           end).
    (* the inner Oadd: table base + terrain index *)
    match goal with
    | Hx : eval_expr _ _ _ _ (Ebinop _ (Evar _ _) _ _) (Vptr _ _) |- _ =>
        inv Hx
    end.
    2:{ match goal with
        | Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv
        end. }
    match goal with
    | Hs : sem_binary_operation _ _ _ (typeof _) _ _ _ = Some (Vptr _ _)
      |- _ => cbn [typeof] in Hs; rename Hs into Hsem2
    end.
    (* the table base: a global array symbol *)
    match goal with
    | Hx : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hx
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ =>
        cbn [typeof] in Hd; rename Hd into Hdl3
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
    end.
    1:{ match goal with
        | Hl : e ! tbl = Some _ |- _ =>
            rewrite Hnone in Hl; discriminate Hl
        end. }
    inv Hdl3;
      try (match goal with
           | Hacc : access_mode (tarray (tarray tuint 3) 3) = _ |- _ =>
               cbn in Hacc; discriminate Hacc
           end).
    (* pin the inner Oadd result block to the symbol block *)
    unfold sem_binary_operation, sem_add in Hsem2.
    change (classify_add (tarray (tarray tuint 3) 3) tshort)
      with (add_case_pi (tarray tuint 3) Signed) in Hsem2.
    unfold sem_add_ptr_int in Hsem2.
    match type of Hsem2 with
    | match ?vi with _ => _ end = _ =>
        destruct vi; try discriminate Hsem2
    end.
    injection Hsem2 as E1 E2; subst.
    (* pin the outer Oadd result block likewise *)
    unfold sem_binary_operation, sem_add in Hsem.
    change (classify_add (tarray tuint 3) tshort)
      with (add_case_pi tuint Signed) in Hsem.
    unfold sem_add_ptr_int in Hsem.
    match type of Hsem with
    | match ?vi with _ => _ end = _ =>
        destruct vi; try discriminate Hsem
    end.
    injection Hsem as E3 E4; subst.
    (* the final load *)
    inv Hdl;
      try (match goal with
           | Hacc : access_mode tuint = By_reference |- _ =>
               cbn in Hacc; discriminate Hacc
           end);
      try (match goal with
           | Hacc : access_mode tuint = By_copy |- _ =>
               cbn in Hacc; discriminate Hacc
           end).
    match goal with
    | Hacc : access_mode tuint = By_value ?ch |- _ =>
        cbn in Hacc; injection Hacc as <-
    end.
    match goal with
    | Hld : Mem.loadv Mint32 _ (Vptr _ _) = Some v |- _ => cbn in Hld
    end.
    match goal with
    | Hfs : Genv.find_symbol _ tbl = Some ?kb |- _ =>
        match goal with
        | Hld : Mem.load Mint32 m kb ?oo = Some v |- _ =>
            exact (HMWF_ktab m tbl kb oo v HM Hmem Hfs Hld)
        end
    end.
  Qed.

  (* ---- THE WALKER ---- *)
  Lemma dka_walk_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      dka_chk s = true ->
      e ! interaction._mario_obj_angle_to_object = None ->
      e ! interaction._mario_set_forward_vel = None ->
      (forall gid, mem_id gid knockback_table_ids = true ->
                   e ! gid = None) ->
      (forall b o, le ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      bonk_inv le ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\
      (forall b o, le' ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      bonk_inv le' /\
      wret_ok true out.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hmoa Hmsf Hktab Hm Hbonk Hc.
    - (* Sskip *) exact (conj Hc (conj Hm (conj Hbonk I))).
    - (* Sassign *)
      cbn [dka_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      apply orb_true_iff in Hchk as [Hchk | Hix16].
      apply orb_true_iff in Hchk as [Hsf | Hix].
      + destruct Hc as (HV & HS & HM & HN).
        destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm (conj Hbonk I))).
      + destruct Hc as (HV & HS & HM & HN).
        destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hix Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm (conj Hbonk I))).
      + destruct Hc as (HV & HS & HM & HN).
        destruct (idx16_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hix16 Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm (conj Hbonk I))).
    - (* Sset *)
      cbn [dka_chk dka_set_chk] in Hchk.
      destruct (Pos.eqb id interaction._bonkAction) eqn:Eb.
      + apply Pos.eqb_eq in Eb; subst id.
        destruct (dka_table_decode _ Hchk) as (tbl & ia & ib & -> & Hmem).
        destruct Hc as (HV & HS & HM & HN).
        match goal with
        | Hev : eval_expr _ _ _ _ _ ?w |- _ =>
            pose proof (dka_table_load_val tbl ia ib e le m w
                          Hmem (Hktab tbl Hmem) HM Hev) as Huv
        end.
        refine (conj (conj HV (conj HS (conj HM HN))) (conj _ (conj _ I))).
        * intros b o Hg.
          rewrite PTree.gso in Hg
            by (intro EE; vm_compute in EE; discriminate EE).
          exact (Hm b o Hg).
        * intros w Hg. rewrite PTree.gss in Hg.
          injection Hg as <-. exact Huv.
      + refine (conj Hc (conj _ (conj _ I))).
        * intros b o Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst id; vm_compute in Hchk;
                discriminate Hchk).
          exact (Hm b o Hg).
        * intros w Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst id; rewrite Pos.eqb_refl in Eb;
                discriminate Eb).
          exact (Hbonk w Hg).
    - (* Scall *)
      cbn [dka_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      destruct (dka_call_decode _ _ _ Hcc)
        as (Hfid & tyrest & rty & cc & rest & -> & ->).
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid
                         (Evar fid (Tfunction (tyMSi :: tyrest) rty cc))
                         (Etempvar interaction._m tyMSi :: rest)) t
                      (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : forall b o,
                 (set_opttemp optid vres le) ! interaction._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { cbn [dka_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply andb_true_iff in Hopt as [Hopt1 _].
          apply negb_true_iff in Hopt1.
          intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt1; discriminate Hopt1).
          exact (Hm b o Hg).
        - exact Hm. }
      assert (HbonkL : bonk_inv (set_opttemp optid vres le)).
      { cbn [dka_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply andb_true_iff in Hopt as [_ Hopt2].
          apply negb_true_iff in Hopt2.
          intros w Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt2; discriminate Hopt2).
          exact (Hbonk w Hg).
        - exact Hbonk. }
      destruct Hfid as [-> | ->].
      + destruct (cp2_scall_pres lp bm NoA MWF optid
                    interaction._mario_obj_angle_to_object
                    tyrest rty cc rest e le m _ _ m' _
                    Hmoa Hex Hcp_moato Hm Hc) as (Hc' & _).
        exact (conj Hc' (conj HmL (conj HbonkL I))).
      + destruct (cp2_scall_pres lp bm NoA MWF optid
                    interaction._mario_set_forward_vel
                    tyrest rty cc rest e le m _ _ m' _
                    Hmsf Hex Hcp_msfv Hm Hc) as (Hc' & _).
        exact (conj Hc' (conj HmL (conj HbonkL I))).
    - (* Sbuiltin *)
      cbn [dka_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [dka_chk] in Hchk.
      apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hmoa Hmsf Hktab Hm Hbonk Hc)
        as (Hc1 & Hm1 & Hb1 & _).
      exact (IHHexec2 H2 Hmoa Hmsf Hktab Hm1 Hb1 Hc1).
    - (* Sseq_2 *)
      cbn [dka_chk] in Hchk.
      apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hmoa Hmsf Hktab Hm Hbonk Hc).
    - (* Sifthenelse *)
      cbn [dka_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc (conj Hm (conj Hbonk I))).
    - (* Sreturn (Some a) *)
      cbn [dka_chk] in Hchk.
      destruct a as [ | | | | | q ty | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hq Hty].
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq ty tuint) as [-> | ]; [ | discriminate Hty ].
      match goal with
      | Hev : eval_expr _ _ _ _ (Etempvar _ _) ?w |- _ => inv Hev
      end.
      2:{ match goal with
          | Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hlv
          end. }
      refine (conj Hc (conj Hm (conj Hbonk _))).
      cbn [wret_ok typeof]. intros _.
      match goal with
      | Hg : le ! interaction._bonkAction = Some ?w |- _ =>
          exact (conj (Hbonk _ Hg) eq_refl)
      end.
    - (* Sbreak *) exact (conj Hc (conj Hm (conj Hbonk I))).
    - (* Scontinue *) exact (conj Hc (conj Hm (conj Hbonk I))).
    - (* Sloop stop1 *)
      cbn [dka_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2 *)
      cbn [dka_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop *)
      cbn [dka_chk] in Hchk. discriminate Hchk.
    - (* Sswitch *)
      cbn [dka_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ---- THE ROW ---- *)
  Lemma dka_row :
    call_pres_ret_act lp bm NoA MWF
      interaction._determine_knockback_action.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hmarg HN HM HV HS.
    pose proof (resolve_pin_fd lp interaction.prog
                  interaction._determine_knockback_action
                  interaction.f_determine_knockback_action fd
                  LO_int dka_pin Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
      rename Ho into Hout end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite dka_vars in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite dka_params in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs0 as [| v_m vr1]; [ discriminate Hbind | ].
    destruct vr1 as [| v_a vr2]; [ discriminate Hbind | ].
    destruct vr2 as [| vx vr3]; [ | discriminate Hbind ].
    injection Hbind as <-.
    (* entry env facts *)
    assert (Hm0 : forall b o,
               (PTree.set interaction._arg v_a
                  (PTree.set interaction._m v_m
                     (create_undef_temps
                        (fn_temps interaction.f_determine_knockback_action))))
                 ! interaction._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hbonk0 : bonk_inv
               (PTree.set interaction._arg v_a
                  (PTree.set interaction._m v_m
                     (create_undef_temps
                        (fn_temps interaction.f_determine_knockback_action))))).
    { intros w Hg.
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      left. exact (create_undef_temps_val _ _ _ Hg). }
    match type of Hbody with
    | exec_stmt _ _ _ _ ?mm _ _ _ _ _ =>
        assert (Hcar : carried bm NoA MWF mm)
          by (split; [ exact HV | split; [ exact HS
                     | split; [ exact HM | exact HN ] ] ])
    end.
    (* the walk *)
    destruct (dka_walk_pres _ _ _ _ _ _ _ _ Hbody dka_chk_body
                (PTree.gempty _ _) (PTree.gempty _ _)
                (fun gid _ => PTree.gempty _ _)
                Hm0 Hbonk0 Hcar)
      as (Hc' & _ & _ & Hret').
    destruct Hc' as (HV' & HS' & HM' & HN').
    (* exit: nothing to free at the empty env *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    (* the return value: tuint forces Out_return + an i32-neutral cast *)
    change (fn_return interaction.f_determine_knockback_action)
      with tuint in Hout.
    unfold outcome_result_value in Hout.
    match type of Hret' with
    | wret_ok _ ?oo => destruct oo as [ | | | ov ]
    end.
    - destruct Hout.
    - destruct Hout.
    - destruct Hout.
    - destruct ov as [ [v' t'] | ]; [ | destruct Hout ].
      destruct Hout as [_ Hcast].
      destruct (Hret' eq_refl) as [Huv Hi32'].
      assert (Hi32t : i32_ty tuint = true) by reflexivity.
      exact (conj HV' (conj HS' (conj HM' (conj HN'
               (sem_cast_i32_untainted _ _ _ _ _ Hi32' Hi32t
                  Huv Hcast))))).
  Qed.

End DkaSurface.

Definition tdfio_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id interaction._m)
  | None => true
  end.

Fixpoint tdfio_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 => tdfio_chk s1 && tdfio_chk s2
  | Sifthenelse _ s1 s2 => tdfio_chk s1 && tdfio_chk s2
  | Sset id _ => negb (Pos.eqb id interaction._m)
  | Sassign a1 _ => safe_mfield_store interaction._m a1
  | Scall optid (Evar fid fty) al =>
      tdfio_optid_ok optid
      && Pos.eqb fid interaction._set_camera_shake_from_hit
      && match fty with Tfunction _ _ _ => true | _ => false end
  | _ => false
  end.

Lemma tdfio_chk_body :
  tdfio_chk (fn_body interaction.f_take_damage_from_interact_object)
  = true.
Proof. vm_compute. reflexivity. Qed.

Lemma tdfio_pin :
  (prog_defmap interaction.prog)
    ! interaction._take_damage_from_interact_object
  = Some (Gfun (Internal interaction.f_take_damage_from_interact_object)).
Proof. vm_compute. reflexivity. Qed.

Lemma tdfio_vars :
  fn_vars interaction.f_take_damage_from_interact_object = nil.
Proof. vm_compute. reflexivity. Qed.

Lemma tdfio_params :
  fn_params interaction.f_take_damage_from_interact_object
  = (interaction._m, tyMSi) :: nil.
Proof. vm_compute. reflexivity. Qed.

Section TdfioSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  (* the ungated camera external (no pointer args: tshort -> void) *)
  Hypothesis Hcpx_scsfh :
    call_pres_ext lp bm NoA MWF interaction._set_camera_shake_from_hit.

  Lemma tdfio_walk_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      tdfio_chk s = true ->
      e ! interaction._set_camera_shake_from_hit = None ->
      (forall b o, le ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\
      (forall b o, le' ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero).
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hsc Hm Hc.
    - (* Sskip *) exact (conj Hc Hm).
    - (* Sassign *)
      cbn [tdfio_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct Hc as (HV & HS & HM & HN).
      destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                  a1 a2 _ _ _ _ _ _ _ Hchk Hm Hex HM HV HS)
        as (HV' & HS' & HM' & _ & _).
      exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))) Hm).
    - (* Sset *)
      cbn [tdfio_chk] in Hchk.
      refine (conj Hc _).
      intros b o Hg.
      rewrite PTree.gso in Hg by (intro EE; subst id;
        rewrite Pos.eqb_refl in Hchk; discriminate Hchk).
      exact (Hm b o Hg).
    - (* Scall *)
      cbn [tdfio_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hchk Hftyb].
      apply andb_true_iff in Hchk as [Hopt Hfid].
      apply Pos.eqb_eq in Hfid; subst fid.
      destruct fty as [ | | | | | | targs tres tcc | | ];
        try discriminate Hftyb.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid
                         (Evar interaction._set_camera_shake_from_hit
                            (Tfunction targs tres tcc)) al) t
                      (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : forall b o,
                 (set_opttemp optid vres le) ! interaction._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { cbn [tdfio_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply negb_true_iff in Hopt.
          intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt; discriminate Hopt).
          exact (Hm b o Hg).
        - exact Hm. }
      destruct Hc as (HV & HS & HM & HN).
      destruct (kit_scallx_pres lp bm NoA MWF optid
                  interaction._set_camera_shake_from_hit
                  targs tres tcc al e le m _ _ m' _
                  Hsc Hex Hcpx_scsfh HN HM HV HS)
        as (HV' & HS' & HM' & HN' & _ & _).
      exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
    - (* Sbuiltin *)
      cbn [tdfio_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [tdfio_chk] in Hchk.
      apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hsc Hm Hc) as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hsc Hm1 Hc1).
    - (* Sseq_2 *)
      cbn [tdfio_chk] in Hchk.
      apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hsc Hm Hc).
    - (* Sifthenelse *)
      cbn [tdfio_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc Hm).
    - (* Sreturn (Some _) *) exact (conj Hc Hm).
    - (* Sbreak *) exact (conj Hc Hm).
    - (* Scontinue *) exact (conj Hc Hm).
    - (* Sloop stop1 *) cbn [tdfio_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2 *) cbn [tdfio_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop *) cbn [tdfio_chk] in Hchk. discriminate Hchk.
    - (* Sswitch *) cbn [tdfio_chk] in Hchk. discriminate Hchk.
  Qed.

  Lemma tdfio_body_pres :
    body_pres lp NoA MWF bm interaction.f_take_damage_from_interact_object.
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
      rewrite tdfio_vars in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite tdfio_params in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs0 as [| v_m vr1]; [ discriminate Hbind | ].
    destruct vr1 as [| vx vr2]; [ | discriminate Hbind ].
    injection Hbind as <-.
    assert (Hm0 : forall b o,
               (PTree.set interaction._m v_m
                  (create_undef_temps
                     (fn_temps
                        interaction.f_take_damage_from_interact_object)))
                 ! interaction._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    match type of Hbody with
    | exec_stmt _ _ _ _ ?mm _ _ _ _ _ =>
        assert (Hcar : carried bm NoA MWF mm)
          by (split; [ exact HV | split; [ exact HS
                     | split; [ exact HM | exact HN ] ] ])
    end.
    destruct (tdfio_walk_pres _ _ _ _ _ _ _ _ Hbody tdfio_chk_body
                (PTree.gempty _ _) Hm0 Hcar)
      as (Hc' & _).
    destruct Hc' as (HV' & HS' & HM' & HN').
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact (conj HV' (conj HS' HM')).
  Qed.

  Lemma tdfio_row :
    call_pres lp bm NoA MWF
      interaction._take_damage_from_interact_object.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF interaction.prog
             interaction._take_damage_from_interact_object
             interaction.f_take_damage_from_interact_object
             LO_int tdfio_pin tdfio_body_pres).
  Qed.

End TdfioSurface.

(* the per-helper residual shape: Mario's exact pointer first, a SafeB
   object-pool pointer second -- the io gate as a CALL row.  No
   return-value claim (handlers use the result only in a condition). *)
Definition call_pres_ms (lp : Clight.program) (bm : block)
    (NoA MWF : mem -> Prop) (SafeB : block -> Prop) (fid : ident) : Prop :=
  forall fd m0 vm vo t0 m1 vres0,
    eval_funcall function_entry2 (lp_ge lp) m0 fd (vm :: vo :: nil)
      t0 m1 vres0 ->
    resolves_lp lp fid fd ->
    (forall b o, vm = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
    (forall b o, vo = Vptr b o -> SafeB b) ->
    NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
    action_sat not_tainted m0 bm ->
    Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
    MWF m1 /\ NoA m1.

(* the 3-arg io-shaped helper row: the handler gate itself as a CALL row
   (check_object_grab_mario).  vm carries Mario's pointer, vo the SafeB
   object; the MIDDLE value (interactType) is unconstrained. *)
Definition call_pres_io (lp : Clight.program) (bm : block)
    (NoA MWF : mem -> Prop) (SafeB : block -> Prop) (fid : ident) : Prop :=
  forall fd m0 vm vi vo t0 m1 vres0,
    eval_funcall function_entry2 (lp_ge lp) m0 fd (vm :: vi :: vo :: nil)
      t0 m1 vres0 ->
    resolves_lp lp fid fd ->
    (forall b o, vm = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
    (forall b o, vo = Vptr b o -> SafeB b) ->
    NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
    action_sat not_tainted m0 bm ->
    Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
    MWF m1 /\ NoA m1.

(* ---- the censuses ---- *)
Definition tdaknb_ids : list ident :=
  interaction._take_damage_from_interact_object ::
  interaction._update_mario_sound_and_camera :: nil.
Definition tdaknb_cact : list ident := interaction._o :: nil.
Definition tdaknb_xids : list ident := interaction._play_sound :: nil.

(* a temp the pair arm may bind without disturbing the threaded facts *)
Definition tdaknb_tmp_ok (t : ident) : bool :=
  negb (Pos.eqb t interaction._m) && negb (Pos.eqb t interaction._o).

(* ---- the special pair ---- *)
Definition tdaknb_sp_chk (s : statement) : bool :=
  match s with
  | Ssequence
      (Ssequence
         (Sset t6 _)
         (Scall (Some t2)
            (Evar fd ftyd)
            (Etempvar mp1 tmp1 :: Etempvar t6' tt6 :: nil)))
      (Scall (Some t3)
         (Evar fa ftya)
         (Etempvar mp2 tmp2 :: Etempvar t2' tt2
          :: Etempvar dmg tdmg :: nil)) =>
      tdaknb_tmp_ok t6 && tdaknb_tmp_ok t2 && tdaknb_tmp_ok t3
      && Pos.eqb fd interaction._determine_knockback_action
      && Pos.eqb fa interaction._drop_and_set_mario_action
      && Pos.eqb mp1 interaction._m && Pos.eqb mp2 interaction._m
      && Pos.eqb t6' t6 && Pos.eqb t2' t2
      && negb (Pos.eqb t2 t6)
      && negb (Pos.eqb dmg t2)
      && proj_sumbool (type_eq tmp1 tyMSi)
      && proj_sumbool (type_eq tmp2 tyMSi)
      && proj_sumbool (type_eq tt6 tint)
      && proj_sumbool (type_eq tt2 tuint)
      && proj_sumbool (type_eq tdmg tuint)
      && proj_sumbool (type_eq ftyd
           (Tfunction (tyMSi :: tint :: nil) tuint cc_default))
      && proj_sumbool (type_eq ftya
           (Tfunction (tyMSi :: tuint :: tuint :: nil) tint cc_default))
  | _ => false
  end.

Fixpoint tdaknb_chk (s : statement) : bool :=
  wwalk_chk' nil nil nil nil nil nil false
    nil tdaknb_ids nil tdaknb_cact tdaknb_xids nil nil s
  || match s with
     | Ssequence s1 s2 =>
         tdaknb_sp_chk s || (tdaknb_chk s1 && tdaknb_chk s2)
     | Sifthenelse _ s1 s2 => tdaknb_chk s1 && tdaknb_chk s2
     | _ => false
     end.

(* ---- vm pins ---- *)
Lemma tdaknb_chk_body :
  tdaknb_chk (fn_body interaction.f_take_damage_and_knock_back) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma tdaknb_pin :
  (prog_defmap interaction.prog) ! interaction._take_damage_and_knock_back
  = Some (Gfun (Internal interaction.f_take_damage_and_knock_back)).
Proof. vm_compute. reflexivity. Qed.

Lemma tdaknb_vars :
  fn_vars interaction.f_take_damage_and_knock_back = nil.
Proof. vm_compute. reflexivity. Qed.

Lemma tdaknb_params :
  fn_params interaction.f_take_damage_and_knock_back
  = (interaction._m, tyMSi)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.

(* ---- the pair decoder ---- *)
Lemma tdaknb_sp_decode :
  forall s1 s2, tdaknb_sp_chk (Ssequence s1 s2) = true ->
    exists t6 a6 t2 t3 dmg,
      s1 = Ssequence (Sset t6 a6)
             (Scall (Some t2)
                (Evar interaction._determine_knockback_action
                   (Tfunction (tyMSi :: tint :: nil) tuint cc_default))
                (Etempvar interaction._m tyMSi
                 :: Etempvar t6 tint :: nil)) /\
      s2 = Scall (Some t3)
             (Evar interaction._drop_and_set_mario_action
                (Tfunction (tyMSi :: tuint :: tuint :: nil) tint
                   cc_default))
             (Etempvar interaction._m tyMSi
              :: Etempvar t2 tuint :: Etempvar dmg tuint :: nil) /\
      tdaknb_tmp_ok t6 = true /\ tdaknb_tmp_ok t2 = true /\
      tdaknb_tmp_ok t3 = true /\
      Pos.eqb t2 t6 = false /\ Pos.eqb dmg t2 = false.
Proof.
  intros s1 s2 H. cbn [tdaknb_sp_chk] in H.
  destruct s1 as [ | | | | | s1a s1b | | | | | | | | ];
    try discriminate H.
  destruct s1a as [ | | t6 a6 | | | | | | | | | | | ];
    try discriminate H.
  destruct s1b as [ | | | optd ad ald | | | | | | | | | | ];
    try discriminate H.
  destruct optd as [ t2 | ]; try discriminate H.
  destruct ad as [ | | | | fd ftyd | | | | | | | | | ];
    try discriminate H.
  destruct ald as [ | ad1 ald1 ]; try discriminate H.
  destruct ad1 as [ | | | | | mp1 tmp1 | | | | | | | | ];
    try discriminate H.
  destruct ald1 as [ | ad2 ald2 ]; try discriminate H.
  destruct ad2 as [ | | | | | t6' tt6 | | | | | | | | ];
    try discriminate H.
  destruct ald2; try discriminate H.
  destruct s2 as [ | | | opta aa ala | | | | | | | | | | ];
    try discriminate H.
  destruct opta as [ t3 | ]; try discriminate H.
  destruct aa as [ | | | | fa ftya | | | | | | | | | ];
    try discriminate H.
  destruct ala as [ | aa1 ala1 ]; try discriminate H.
  destruct aa1 as [ | | | | | mp2 tmp2 | | | | | | | | ];
    try discriminate H.
  destruct ala1 as [ | aa2 ala2 ]; try discriminate H.
  destruct aa2 as [ | | | | | t2' tt2 | | | | | | | | ];
    try discriminate H.
  destruct ala2 as [ | aa3 ala3 ]; try discriminate H.
  destruct aa3 as [ | | | | | dmg tdmg | | | | | | | | ];
    try discriminate H.
  destruct ala3; try discriminate H.
  apply andb_true_iff in H as [H Hftya].
  apply andb_true_iff in H as [H Hftyd].
  apply andb_true_iff in H as [H Htdmg].
  apply andb_true_iff in H as [H Htt2].
  apply andb_true_iff in H as [H Htt6].
  apply andb_true_iff in H as [H Htmp2].
  apply andb_true_iff in H as [H Htmp1].
  apply andb_true_iff in H as [H Hnedmg].
  apply andb_true_iff in H as [H Hne26].
  apply andb_true_iff in H as [H Ht2'].
  apply andb_true_iff in H as [H Ht6'].
  apply andb_true_iff in H as [H Hmp2].
  apply andb_true_iff in H as [H Hmp1].
  apply andb_true_iff in H as [H Hfa].
  apply andb_true_iff in H as [H Hfd].
  apply andb_true_iff in H as [H Ht3].
  apply andb_true_iff in H as [Ht6 Ht2].
  apply Pos.eqb_eq in Hfd; subst fd.
  apply Pos.eqb_eq in Hfa; subst fa.
  apply Pos.eqb_eq in Hmp1; subst mp1.
  apply Pos.eqb_eq in Hmp2; subst mp2.
  apply Pos.eqb_eq in Ht6'; subst t6'.
  apply Pos.eqb_eq in Ht2'; subst t2'.
  destruct (type_eq tmp1 tyMSi) as [-> | ]; [ | discriminate Htmp1 ].
  destruct (type_eq tmp2 tyMSi) as [-> | ]; [ | discriminate Htmp2 ].
  destruct (type_eq tt6 tint) as [-> | ]; [ | discriminate Htt6 ].
  destruct (type_eq tt2 tuint) as [-> | ]; [ | discriminate Htt2 ].
  destruct (type_eq tdmg tuint) as [-> | ]; [ | discriminate Htdmg ].
  destruct (type_eq ftyd
              (Tfunction (tyMSi :: tint :: nil) tuint cc_default))
    as [-> | ]; [ | discriminate Hftyd ].
  destruct (type_eq ftya
              (Tfunction (tyMSi :: tuint :: tuint :: nil) tint cc_default))
    as [-> | ]; [ | discriminate Hftya ].
  apply negb_true_iff in Hne26.
  apply negb_true_iff in Hnedmg.
  exists t6, a6, t2, t3, dmg.
  repeat split; assumption.
Qed.

Section TdaknbSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
        bg <> bm /\
        (forall mm mm' ch0 (d : Z) vv,
            MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = Errors.OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = Errors.OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* the callee rows *)
  Hypothesis Hcp_tdfio :
    call_pres lp bm NoA MWF interaction._take_damage_from_interact_object.
  Hypothesis Hcp_umsc :
    call_pres lp bm NoA MWF interaction._update_mario_sound_and_camera.
  Hypothesis Hcpx_ps :
    call_pres_ext lp bm NoA MWF interaction._play_sound.
  Hypothesis Hcpra_dka :
    call_pres_ret_act lp bm NoA MWF
      interaction._determine_knockback_action.
  Hypothesis Hcpa_dasma :
    call_pres_act lp bm NoA MWF interaction._drop_and_set_mario_action.

  Lemma tdaknb_ids_rows : forall fid, mem_id fid tdaknb_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold tdaknb_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_tdfio | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_umsc | ].
    discriminate H.
  Qed.

  Lemma tdaknb_xids_rows : forall fid, mem_id fid tdaknb_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold tdaknb_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_ps | ].
    discriminate H.
  Qed.

  (* ---- the generic (engine) delegate ---- *)
  Lemma tdaknb_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g tdaknb_ids = true -> e ! g = None) ->
      (forall g, mem_id g tdaknb_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      wwalk_chk' nil nil nil nil nil nil false
        nil tdaknb_ids nil tdaknb_cact tdaknb_xids nil nil s = true ->
      (forall b o, le ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB tdaknb_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB tdaknb_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hubgt Hchk
           Htat Hact Hch HN HM HV HS Hexec.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil tdaknb_ids nil tdaknb_cact tdaknb_xids nil nil
                nil nil nil nil nil nil
                tdaknb_ids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                tdaknb_xids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                _ _ _ _ _ _ _ _
                (fun HH => match HH eq_refl with end)
                (fun lid HH => match Bool.diff_false_true HH with end)
                Hexec
                Hub_g Hub_i
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hubgt
                Hchk Htat Hact Hch
                (fun t HH => match Bool.diff_false_true HH with end)
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* ---- the dka-site brick: cp2_scall_pres + the untainted result
     landing in the bound temp (and the le frame for everything else) *)
  Lemma cp2_scall_ret_act_pres :
    forall t fid tyrest rty cc rest e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall (Some t) (Evar fid (Tfunction (tyMSi :: tyrest) rty cc))
           (Etempvar interaction._m tyMSi :: rest))
        tr le1 m1 out0 ->
      call_pres_ret_act lp bm NoA MWF fid ->
      (forall b o, le0 ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal /\
      (forall x, le1 ! t = Some x -> untainted_scalar x) /\
      (forall t0, t0 <> t -> le1 ! t0 = le0 ! t0).
  Proof.
    intros t fid tyrest rty cc rest e le0 m0 tr le1 m1 out0
           He Hexec Hcp Htat Hc.
    destruct Hc as (HV & HS & HM & HN).
    inv Hexec.
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv)
          as (bf & Hsym & ->)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: _) (_ :: _) _ |- _ =>
        inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
        subst; clear Hvl
    end.
    apply RealFrameValue.eval_expr_Etempvar_val in Hev_a.
    match goal with
    | Hca : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hca; subst
    end.
    assert (Hmarg : marg_ok bm (v1a :: vl1))
      by (destruct v1a; cbn; try exact I; exact (Htat _ _ Hev_a)).
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _) _ _ _,
      Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some _ |- _ =>
        destruct (Hcp _ _ _ _ _ _ Hevf
                    ltac:(red; exists bf; split; assumption)
                    Hmarg HN HM HV HS)
          as (HV' & HS' & HM' & HN' & Hu')
    end.
    refine (conj (conj HV' (conj HS' (conj HM' HN')))
              (conj eq_refl (conj _ _))).
    { intros x Hg. cbn [set_opttemp] in Hg.
      rewrite PTree.gss in Hg. injection Hg as <-. exact Hu'. }
    intros t0 Hne. cbn [set_opttemp].
    rewrite PTree.gso by exact Hne. reflexivity.
  Qed.

  (* ---- THE HYBRID WALKER ---- *)
  Lemma tdaknb_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g tdaknb_ids = true -> e ! g = None) ->
      (forall g, mem_id g tdaknb_xids = true -> e ! g = None) ->
      e ! interaction._determine_knockback_action = None ->
      e ! interaction._drop_and_set_mario_action = None ->
      e ! interaction._gGlobalTimer = None ->
      tdaknb_chk s = true ->
      (forall b o, le ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB tdaknb_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB tdaknb_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hub_dka Hub_dasma Hubgt
             Hchk Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sassign: generic only *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic only *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall: generic only (the special sites live in the pair arm) *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Scall; eauto.
    - (* Sbuiltin *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [wwalk_chk'] in Hg; discriminate Hg | discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply orb_true_iff in Hsp as [Hsp | Hrec].
      2:{ apply andb_prop in Hrec as [H1 H2].
          destruct (IHHexec1 Hub_g Hub_i Hub_x Hub_dka Hub_dasma Hubgt
                      H1 Htat Hact Hch HN HM HV HS)
            as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
          exact (IHHexec2 Hub_g Hub_i Hub_x Hub_dka Hub_dasma Hubgt
                   H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1). }
      (* THE PAIR: Sset t6; _t2 := dka(m, t6); _t3 := dasma(m, t2, dmg) *)
      destruct (tdaknb_sp_decode _ _ Hsp)
        as (q6 & qa6 & q2 & q3 & qd & Es1 & Es2
            & Ht6 & Ht2 & Ht3 & Hne26 & Hnedmg).
      subst s1 s2.
      apply andb_true_iff in Ht6 as [Ht6m Ht6o].
      apply negb_true_iff in Ht6m. apply negb_true_iff in Ht6o.
      apply andb_true_iff in Ht2 as [Ht2m Ht2o].
      apply negb_true_iff in Ht2m. apply negb_true_iff in Ht2o.
      apply andb_true_iff in Ht3 as [Ht3m Ht3o].
      apply negb_true_iff in Ht3m. apply negb_true_iff in Ht3o.
      (* invert the inner sequence *)
      inv Hexec1.
      2:{ (* inner Sseq_2: the Sset can't exit abnormally *)
          match goal with
          | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o1,
            Hne : ?o1 <> Out_normal |- _ => inv Hs; congruence
          end. }
      match goal with
      | Hs : exec_stmt _ _ _ _ _ (Sset q6 qa6) _ _ _ _ |- _ =>
          rename Hs into HSet
      end.
      match goal with
      | Hs : exec_stmt _ _ _ _ _ (Scall (Some q2) _ _) _ _ _ _ |- _ =>
          rename Hs into HCallD
      end.
      inv HSet.
      (* the dka call *)
      assert (Htat_a : forall b o,
                 (PTree.set q6 v le) ! interaction._m = Some (Vptr b o) ->
                 b = bm /\ o = Ptrofs.zero).
      { intros b o Hg.
        rewrite PTree.gso in Hg
          by (intro EE; rewrite EE, Pos.eqb_refl in Ht6m;
              discriminate Ht6m).
        exact (Htat b o Hg). }
      destruct (cp2_scall_ret_act_pres q2
                  interaction._determine_knockback_action
                  (tint :: nil) tuint cc_default
                  (Etempvar q6 tint :: nil)
                  e (PTree.set q6 v le) _ _ _ _ _
                  Hub_dka HCallD Hcpra_dka Htat_a
                  (conj HV (conj HS (conj HM HN))))
        as (Hc1 & _ & Hu2 & Hfr2).
      destruct Hc1 as (HV1 & HS1 & HM1 & HN1).
      (* the dasma call *)
      assert (Hne_m2 : interaction._m <> q2)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht2m;
            discriminate Ht2m).
      match type of Hexec2 with
      | exec_stmt _ _ _ ?leb _ _ _ _ _ _ =>
          assert (Htat_b : forall b o,
                     leb ! interaction._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero)
            by (intros b o Hg; rewrite (Hfr2 _ Hne_m2) in Hg;
                exact (Htat_a b o Hg))
      end.
      destruct (kit_scallw_pres lp bm NoA MWF q3
                  interaction._drop_and_set_mario_action
                  tuint (tuint :: nil) tint cc_default
                  q2 tuint (Etempvar qd tuint :: nil)
                  e _ _ _ _ _ _
                  Hub_dasma Hexec2 Hcpa_dasma eq_refl eq_refl
                  Htat_b Hu2 HN1 HM1 HV1 HS1)
        as (HV' & HS' & HM' & HN' & _ & Hu3 & Hfr3).
      assert (Hne_m3 : interaction._m <> q3)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht3m;
            discriminate Ht3m).
      assert (Hne_o3 : interaction._o <> q3)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht3o;
            discriminate Ht3o).
      assert (Hne_o2 : interaction._o <> q2)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht2o;
            discriminate Ht2o).
      refine (conj HV' (conj HS' (conj HM' (conj HN' (conj _ (conj _ _)))))).
      + intros b o Hg. rewrite (Hfr3 _ Hne_m3) in Hg.
        exact (Htat_b b o Hg).
      + intros t' HH x Hg'. discriminate HH.
      + intros t' Hmem' b o Hg'.
        unfold tdaknb_cact, mem_id in Hmem'; cbn [existsb] in Hmem'.
        apply orb_true_iff in Hmem' as [E | F]; [ | discriminate F ].
        apply Pos.eqb_eq in E; subst t'.
        rewrite (Hfr3 _ Hne_o3) in Hg'.
        rewrite (Hfr2 _ Hne_o2) in Hg'.
        rewrite PTree.gso in Hg'
          by (intro EE; rewrite EE, Pos.eqb_refl in Ht6o;
              discriminate Ht6o).
        exact (Hch interaction._o eq_refl b o Hg').
    - (* Sseq_2 *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply orb_true_iff in Hsp as [Hsp | Hrec].
      2:{ apply andb_prop in Hrec as [H1 _].
          exact (IHHexec Hub_g Hub_i Hub_x Hub_dka Hub_dasma Hubgt
                   H1 Htat Hact Hch HN HM HV HS). }
      (* the pair's s1 (Sset; Scall) always exits Out_normal *)
      destruct (tdaknb_sp_decode _ _ Hsp)
        as (q6 & qa6 & q2 & q3 & qd & Es1 & Es2 & _).
      subst s1.
      exfalso. inv Hexec.
      + match goal with
        | Hs : exec_stmt _ _ _ _ _ (Scall (Some q2) _ _) _ _ _ ?oo,
          Hne : ?oo <> Out_normal |- _ => inv Hs; congruence
        end.
      + match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?oo,
          Hne : ?oo <> Out_normal |- _ => inv Hs; congruence
        end.
    - (* Sifthenelse *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrec].
      { eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hact Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hrec as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sloop stop1: generic only *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic only *)
      cbn [tdaknb_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp]; [ | discriminate Hsp ].
      eapply (tdaknb_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sswitch; eauto.
  Qed.

  (* ---- THE ROW ---- *)
  Lemma tdaknb_row :
    call_pres_ms lp bm NoA MWF SafeB
      interaction._take_damage_and_knock_back.
  Proof.
    intros fd m0 vm vo t0 m1 vres0 Hevf Hres Hvm Hvo HN HM HV HS.
    pose proof (resolve_pin_fd lp interaction.prog
                  interaction._take_damage_and_knock_back
                  interaction.f_take_damage_and_knock_back fd
                  LO_int tdaknb_pin Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite tdaknb_vars in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite tdaknb_params in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as <-.
    (* the entry env facts *)
    assert (Htat0 : forall b o,
               (PTree.set interaction._o vo
                  (PTree.set interaction._m vm
                     (create_undef_temps
                        (fn_temps interaction.f_take_damage_and_knock_back))))
                 ! interaction._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      rewrite PTree.gss in Hg. injection Hg as ->.
      exact (Hvm b o eq_refl). }
    assert (Hch0 : chase_inv SafeB tdaknb_cact
               (PTree.set interaction._o vo
                  (PTree.set interaction._m vm
                     (create_undef_temps
                        (fn_temps interaction.f_take_damage_and_knock_back))))).
    { intros t' Hmem' b o Hg'.
      unfold tdaknb_cact, mem_id in Hmem'; cbn [existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [E | F]; [ | discriminate F ].
      apply Pos.eqb_eq in E; subst t'.
      rewrite PTree.gss in Hg'. injection Hg' as ->.
      exact (Hvo b o eq_refl). }
    assert (Hact0 : act_inv nil
               (PTree.set interaction._o vo
                  (PTree.set interaction._m vm
                     (create_undef_temps
                        (fn_temps interaction.f_take_damage_and_knock_back)))))
      by (intros t' HH x Hg'; discriminate HH).
    destruct (tdaknb_pres _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _)
                (PTree.gempty _ _) (PTree.gempty _ _) (PTree.gempty _ _)
                tdaknb_chk_body Htat0 Hact0 Hch0 HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _ & _ & _).
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

End TdaknbSurface.

(* ====================================================================== *)
(* =================  the 29 interact_* handler walks  ================== *)
(* The io arc: every handler has params EXACTLY (m, interactType, o) and  *)
(* the shell's io gate supplies vm = Mario-conditional + vo = SafeB-      *)
(* object-conditional.  body_pres_io_of_wwalk seeds _o into the wwalk     *)
(* engine's chase census (chase_inv) straight from the gate -- NO new     *)
(* checker arms were needed.  Walked handlers leave io_rest_ids (the      *)
(* census the capstone's Hio_rest row is keyed on); every new walk        *)
(* SHRINKS that list.                                                     *)
(* ====================================================================== *)

(* ---- water_ring vm pins ---- *)
Lemma io_wr_pin :
  (prog_defmap interaction.prog) ! interaction._interact_water_ring
  = Some (Gfun (Internal interaction.f_interact_water_ring)).
Proof. vm_compute. reflexivity. Qed.

Example io_wr_vars : fn_vars interaction.f_interact_water_ring = nil.
Proof. vm_compute. reflexivity. Qed.

Example io_wr_params :
  fn_params interaction.f_interact_water_ring
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.

Example io_wr_walk :
  wwalk_chk false nil nil nil (interaction._o :: nil) nil nil nil
    (fn_body interaction.f_interact_water_ring) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- igloo_barrier vm pins: 2 chase-root stores (m->interactObj /
   m->usedObj := o, the engine's root_store_chk arm) + ONE marg internal
   call push_mario_out_of_object(m, o, 5.0f) (the engine's ids arm; _o is
   only ever LOADED through inside pmoo, so plain call_pres is honest --
   see Section PmooSurface above). ---- *)
Lemma io_ig_pin :
  (prog_defmap interaction.prog) ! interaction._interact_igloo_barrier
  = Some (Gfun (Internal interaction.f_interact_igloo_barrier)).
Proof. vm_compute. reflexivity. Qed.

Example io_ig_vars : fn_vars interaction.f_interact_igloo_barrier = nil.
Proof. vm_compute. reflexivity. Qed.

Example io_ig_params :
  fn_params interaction.f_interact_igloo_barrier
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.

Example io_ig_walk :
  wwalk_chk false nil (interaction._push_mario_out_of_object :: nil) nil
    (interaction._o :: nil) nil nil nil
    (fn_body interaction.f_interact_igloo_barrier) = true.
Proof. vm_compute. reflexivity. Qed.

(* the REST census: the 8 handlers not yet walked (shrinks per slice) *)
Definition io_rest_ids : list ident :=
  interaction._interact_bully
  :: interaction._interact_text :: nil.

Definition tyObjI : type := tptr (Tstruct interaction._Object noattr).

(* ---- the special site: _t'1 := take_damage_and_knock_back(m, o) ---- *)
Definition ioms_sp_chk (s : statement) : bool :=
  match s with
  | Scall (Some t1) (Evar fd fty)
      (Etempvar mp tmp :: Etempvar op2 top2 :: nil) =>
      tdaknb_tmp_ok t1
      && Pos.eqb fd interaction._take_damage_and_knock_back
      && Pos.eqb mp interaction._m && Pos.eqb op2 interaction._o
      && proj_sumbool (type_eq tmp tyMSi)
      && proj_sumbool (type_eq top2 tyObjI)
      && proj_sumbool (type_eq fty
           (Tfunction (tyMSi :: tyObjI :: nil) tuint cc_default))
  | _ => false
  end.

(* ---- the ob special site: a censused OBJECT-first callee with the _o
   chase temp as arg0 (SafeB at the site), trailing args FREE.  Covers
   attack_object(o, interaction) and get_mario_cap_flag(o). ---- *)
Definition ioms_ob_chk (oids : list ident) (s : statement) : bool :=
  match s with
  | Scall optid (Evar fd fty) (Etempvar op top2 :: rest) =>
      mem_id fd oids
      && Pos.eqb op interaction._o
      && proj_sumbool (type_eq top2 tyObjI)
      && match optid with
         | Some t1 => tdaknb_tmp_ok t1
         | None => true
         end
      && match fty with
         | Tfunction (tyh :: tyl) rty cc =>
             proj_sumbool (type_eq tyh tyObjI)
         | _ => false
         end
  | _ => false
  end.

Lemma ioms_ob_decode : forall oids optid a al,
    ioms_ob_chk oids (Scall optid a al) = true ->
    exists fid tyl rty cc rest,
      a = Evar fid (Tfunction (tyObjI :: tyl) rty cc) /\
      al = Etempvar interaction._o tyObjI :: rest /\
      mem_id fid oids = true /\
      match optid with
      | Some t1 => tdaknb_tmp_ok t1 = true
      | None => True
      end.
Proof.
  intros oids optid a al H. cbn [ioms_ob_chk] in H.
  destruct a as [ | | | | fd fty | | | | | | | | | ]; try discriminate H.
  destruct al as [| a0 rest]; [ discriminate H | ].
  destruct a0 as [ | | | | | op top2 | | | | | | | | ]; try discriminate H.
  apply andb_prop in H as [H Hfty].
  apply andb_prop in H as [H Hopt].
  apply andb_prop in H as [H Htop].
  apply andb_prop in H as [Hmem Hop].
  apply Pos.eqb_eq in Hop. subst op.
  destruct (type_eq top2 tyObjI); [ subst top2 | discriminate Htop ].
  destruct fty as [ | | | | | | tyl rty cc | | ]; try discriminate Hfty.
  destruct tyl as [| tyh tyl]; [ discriminate Hfty | ].
  destruct (type_eq tyh tyObjI); [ subst tyh | discriminate Hfty ].
  exists fd, tyl, rty, cc, rest.
  repeat split; [ exact Hmem | ].
  destruct optid as [t1|]; [ exact Hopt | exact I ].
Qed.

(* ---- the io special site: a censused IO-SHAPED callee f(m, <any>, o)
   (check_object_grab_mario).  The middle arg is ANY expr -- vi is
   unconstrained in call_pres_io. ---- *)
Definition ioms_io_chk (qids : list ident) (s : statement) : bool :=
  match s with
  | Scall optid (Evar fd fty)
      (Etempvar mp tmp :: a2 :: Etempvar op top2 :: nil) =>
      mem_id fd qids
      && Pos.eqb mp interaction._m && Pos.eqb op interaction._o
      && proj_sumbool (type_eq tmp tyMSi)
      && proj_sumbool (type_eq top2 tyObjI)
      && match optid with
         | Some t1 => tdaknb_tmp_ok t1
         | None => true
         end
      && match fty with
         | Tfunction (tyh :: ty2 :: tyh3 :: nil) rty cc =>
             proj_sumbool (type_eq tyh tyMSi)
             && proj_sumbool (type_eq tyh3 tyObjI)
         | _ => false
         end
  | _ => false
  end.

Lemma ioms_io_decode : forall qids optid a al,
    ioms_io_chk qids (Scall optid a al) = true ->
    exists fd ty2 rty cc a2,
      a = Evar fd (Tfunction (tyMSi :: ty2 :: tyObjI :: nil) rty cc) /\
      al = Etempvar interaction._m tyMSi :: a2
           :: Etempvar interaction._o tyObjI :: nil /\
      mem_id fd qids = true /\
      match optid with
      | Some t1 => tdaknb_tmp_ok t1 = true
      | None => True
      end.
Proof.
  intros qids optid a al H. cbn [ioms_io_chk] in H.
  destruct a as [ | | | | fd fty | | | | | | | | | ];
    try discriminate H.
  destruct al as [ | a1 al1 ]; try discriminate H.
  destruct a1 as [ | | | | | mp tmp | | | | | | | | ];
    try discriminate H.
  destruct al1 as [ | a2 al2 ]; try discriminate H.
  destruct al2 as [ | a3 al3 ]; try discriminate H.
  destruct a3 as [ | | | | | op top2 | | | | | | | | ];
    try discriminate H.
  destruct al3; try discriminate H.
  apply andb_true_iff in H as [H Hfty].
  apply andb_true_iff in H as [H Hopt].
  apply andb_true_iff in H as [H Htop2].
  apply andb_true_iff in H as [H Htmp].
  apply andb_true_iff in H as [H Hop].
  apply andb_true_iff in H as [Hmem Hmp].
  apply Pos.eqb_eq in Hmp; subst mp.
  apply Pos.eqb_eq in Hop; subst op.
  destruct (type_eq tmp tyMSi) as [-> | ]; [ | discriminate Htmp ].
  destruct (type_eq top2 tyObjI) as [-> | ]; [ | discriminate Htop2 ].
  destruct fty as [ | | | | | | tyl rty cc | | ]; try discriminate Hfty.
  destruct tyl as [ | tyh tyl1 ]; try discriminate Hfty.
  destruct tyl1 as [ | ty2 tyl2 ]; try discriminate Hfty.
  destruct tyl2 as [ | tyh3 tyl3 ]; try discriminate Hfty.
  destruct tyl3; try discriminate Hfty.
  apply andb_true_iff in Hfty as [Htyh Htyh3].
  destruct (type_eq tyh tyMSi) as [-> | ]; [ | discriminate Htyh ].
  destruct (type_eq tyh3 tyObjI) as [-> | ]; [ | discriminate Htyh3 ].
  exists fd, ty2, rty, cc, a2.
  split; [ reflexivity | split; [ reflexivity | split; [ exact Hmem | ] ] ].
  destruct optid as [t1|]; [ exact Hopt | exact I ].
Qed.

(* ---- the input-OR pair: `t = m->input; m->input = t | C` with C's
   A-bit (INPUT_A_PRESSED = 2) clear.  The loaded halfword is A-clear by
   MWF's input row; OR keeps bit 1 clear; the MWF input row absorbs the
   store of the PROTECTED cell [2,4).  grabbable's
   `m->input |= INPUT_INTERACT_OBJ_GRABBABLE`. ---- *)
Definition tyInpu : type := Tint I16 Unsigned noattr.

Definition ioms_inp_chk (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset t (Efield (Ederef (Etempvar mp tmp) sty) fld tyf))
      (Sassign (Efield (Ederef (Etempvar mp2 tmp2) sty2) fld2 tyf2)
         (Ebinop Oor (Etempvar t2 tyt) (Econst_int c tyc) ty3)) =>
      Pos.eqb mp interaction._m && Pos.eqb mp2 interaction._m
      && Pos.eqb fld interaction._input
      && Pos.eqb fld2 interaction._input
      && Pos.eqb t2 t && tdaknb_tmp_ok t
      && proj_sumbool (type_eq tmp tyMSi)
      && proj_sumbool (type_eq tmp2 tyMSi)
      && proj_sumbool
           (type_eq sty (Tstruct interaction._MarioState noattr))
      && proj_sumbool
           (type_eq sty2 (Tstruct interaction._MarioState noattr))
      && proj_sumbool (type_eq tyf tyInpu)
      && proj_sumbool (type_eq tyf2 tyInpu)
      && proj_sumbool (type_eq tyt tyInpu)
      && proj_sumbool (type_eq tyc tint)
      && proj_sumbool (type_eq ty3 tint)
      && Int.eq (Int.and c (Int.repr 2)) Int.zero
  | _ => false
  end.

Lemma ioms_inp_decode :
  forall s1 s2, ioms_inp_chk (Ssequence s1 s2) = true ->
    exists t c,
      s1 = Sset t (Efield (Ederef (Etempvar interaction._m tyMSi)
                     (Tstruct interaction._MarioState noattr))
                     interaction._input tyInpu) /\
      s2 = Sassign (Efield (Ederef (Etempvar interaction._m tyMSi)
                      (Tstruct interaction._MarioState noattr))
                      interaction._input tyInpu)
             (Ebinop Oor (Etempvar t tyInpu) (Econst_int c tint) tint) /\
      tdaknb_tmp_ok t = true /\
      Int.eq (Int.and c (Int.repr 2)) Int.zero = true.
Proof.
  intros s1 s2 H. cbn [ioms_inp_chk] in H.
  destruct s1 as [ | | t a | | | | | | | | | | | ];
    try discriminate H.
  destruct a as [ | | | | | | | | | | | ein fld tyf | | ];
    try discriminate H.
  destruct ein as [ | | | | | | eb sty | | | | | | | ];
    try discriminate H.
  destruct eb as [ | | | | | mp tmp | | | | | | | | ];
    try discriminate H.
  destruct s2 as [ | a1 a2 | | | | | | | | | | | | ];
    try discriminate H.
  destruct a1 as [ | | | | | | | | | | | ein2 fld2 tyf2 | | ];
    try discriminate H.
  destruct ein2 as [ | | | | | | eb2 sty2 | | | | | | | ];
    try discriminate H.
  destruct eb2 as [ | | | | | mp2 tmp2 | | | | | | | | ];
    try discriminate H.
  destruct a2 as [ | | | | | | | | | bop b1 b2 ty3 | | | | ];
    try discriminate H.
  destruct bop; try discriminate H.
  destruct b1 as [ | | | | | t2 tyt | | | | | | | | ];
    try discriminate H.
  destruct b2 as [ c tyc | | | | | | | | | | | | | ];
    try discriminate H.
  apply andb_true_iff in H as [H Hcclr].
  apply andb_true_iff in H as [H Hty3].
  apply andb_true_iff in H as [H Htyc].
  apply andb_true_iff in H as [H Htyt].
  apply andb_true_iff in H as [H Htyf2].
  apply andb_true_iff in H as [H Htyf].
  apply andb_true_iff in H as [H Hsty2].
  apply andb_true_iff in H as [H Hsty].
  apply andb_true_iff in H as [H Htmp2].
  apply andb_true_iff in H as [H Htmp].
  apply andb_true_iff in H as [H Htok].
  apply andb_true_iff in H as [H Ht2].
  apply andb_true_iff in H as [H Hfld2].
  apply andb_true_iff in H as [H Hfld].
  apply andb_true_iff in H as [Hmp Hmp2].
  apply Pos.eqb_eq in Hmp; subst mp.
  apply Pos.eqb_eq in Hmp2; subst mp2.
  apply Pos.eqb_eq in Hfld; subst fld.
  apply Pos.eqb_eq in Hfld2; subst fld2.
  apply Pos.eqb_eq in Ht2; subst t2.
  destruct (type_eq tmp tyMSi) as [-> | ]; [ | discriminate Htmp ].
  destruct (type_eq tmp2 tyMSi) as [-> | ]; [ | discriminate Htmp2 ].
  destruct (type_eq sty (Tstruct interaction._MarioState noattr))
    as [-> | ]; [ | discriminate Hsty ].
  destruct (type_eq sty2 (Tstruct interaction._MarioState noattr))
    as [-> | ]; [ | discriminate Hsty2 ].
  destruct (type_eq tyf tyInpu) as [-> | ]; [ | discriminate Htyf ].
  destruct (type_eq tyf2 tyInpu) as [-> | ]; [ | discriminate Htyf2 ].
  destruct (type_eq tyt tyInpu) as [-> | ]; [ | discriminate Htyt ].
  destruct (type_eq tyc tint) as [-> | ]; [ | discriminate Htyc ].
  destruct (type_eq ty3 tint) as [-> | ]; [ | discriminate Hty3 ].
  exists t, c.
  split; [ reflexivity | split; [ reflexivity | ] ].
  split; assumption.
Qed.

(* the input field offset pin + the bit-1-through-zero_ext lemma *)
Lemma input_field_off :
  field_offset (prog_comp_env mario.prog) interaction._input
    mario_state_members = Errors.OK (2, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma inp_and2_zero_ext16 :
  forall x, Int.and (Int.zero_ext 16 x) (Int.repr 2)
            = Int.and x (Int.repr 2).
Proof.
  intros x. apply Int.same_bits_eq; intros i Hi.
  rewrite !Int.bits_and by exact Hi.
  rewrite Int.bits_zero_ext by lia.
  destruct (zlt i 16) as [Hl | Hl]; [ reflexivity | ].
  assert (E2 : Int.testbit (Int.repr 2) i = false).
  { rewrite Int.testbit_repr by exact Hi.
    apply Z.bits_above_log2; [ lia | cbn; lia ]. }
  rewrite E2, !andb_false_r. reflexivity.
Qed.

(* ---- the snufit dka->dasma pair: the slice-3 tdaknb pair with an
   INTERPOSED chase-load Sset between the two calls.  q6 must not
   clobber the dka result temp q1 (vm-checked). ---- *)
Definition iodp_sp_chk (s : statement) : bool :=
  match s with
  | Ssequence
      (Ssequence
         (Sset t7 _)
         (Scall (Some t1) (Evar fd ftyd)
            (Etempvar mp1 tmp1 :: Etempvar t7' tt7 :: nil)))
      (Ssequence
         (Sset t6 _)
         (Scall (Some t2) (Evar fa ftya)
            (Etempvar mp2 tmp2 :: Etempvar t1' tt1
             :: Etempvar t6' tt6 :: nil))) =>
      tdaknb_tmp_ok t7 && tdaknb_tmp_ok t1 && tdaknb_tmp_ok t6
      && tdaknb_tmp_ok t2
      && Pos.eqb fd interaction._determine_knockback_action
      && Pos.eqb fa interaction._drop_and_set_mario_action
      && Pos.eqb mp1 interaction._m && Pos.eqb mp2 interaction._m
      && Pos.eqb t7' t7 && Pos.eqb t1' t1 && Pos.eqb t6' t6
      && negb (Pos.eqb t6 t1)
      && proj_sumbool (type_eq tmp1 tyMSi)
      && proj_sumbool (type_eq tmp2 tyMSi)
      && proj_sumbool (type_eq tt7 tint)
      && proj_sumbool (type_eq tt1 tuint)
      && proj_sumbool (type_eq tt6 tint)
      && proj_sumbool (type_eq ftyd
           (Tfunction (tyMSi :: tint :: nil) tuint cc_default))
      && proj_sumbool (type_eq ftya
           (Tfunction (tyMSi :: tuint :: tuint :: nil) tint cc_default))
  | _ => false
  end.

Lemma iodp_sp_decode :
  forall s1 s2, iodp_sp_chk (Ssequence s1 s2) = true ->
    exists t7 a7 t1 t6 a6 t2,
      s1 = Ssequence (Sset t7 a7)
             (Scall (Some t1)
                (Evar interaction._determine_knockback_action
                   (Tfunction (tyMSi :: tint :: nil) tuint cc_default))
                (Etempvar interaction._m tyMSi
                 :: Etempvar t7 tint :: nil)) /\
      s2 = Ssequence (Sset t6 a6)
             (Scall (Some t2)
                (Evar interaction._drop_and_set_mario_action
                   (Tfunction (tyMSi :: tuint :: tuint :: nil) tint
                      cc_default))
                (Etempvar interaction._m tyMSi
                 :: Etempvar t1 tuint :: Etempvar t6 tint :: nil)) /\
      tdaknb_tmp_ok t7 = true /\ tdaknb_tmp_ok t1 = true /\
      tdaknb_tmp_ok t6 = true /\ tdaknb_tmp_ok t2 = true /\
      Pos.eqb t6 t1 = false.
Proof.
  intros s1 s2 H. cbn [iodp_sp_chk] in H.
  destruct s1 as [ | | | | | s1a s1b | | | | | | | | ];
    try discriminate H.
  destruct s1a as [ | | t7 a7 | | | | | | | | | | | ];
    try discriminate H.
  destruct s1b as [ | | | optd ad ald | | | | | | | | | | ];
    try discriminate H.
  destruct optd as [ t1 | ]; try discriminate H.
  destruct ad as [ | | | | fd ftyd | | | | | | | | | ];
    try discriminate H.
  destruct ald as [ | ad1 ald1 ]; try discriminate H.
  destruct ad1 as [ | | | | | mp1 tmp1 | | | | | | | | ];
    try discriminate H.
  destruct ald1 as [ | ad2 ald2 ]; try discriminate H.
  destruct ad2 as [ | | | | | t7' tt7 | | | | | | | | ];
    try discriminate H.
  destruct ald2; try discriminate H.
  destruct s2 as [ | | | | | s2a s2b | | | | | | | | ];
    try discriminate H.
  destruct s2a as [ | | t6 a6 | | | | | | | | | | | ];
    try discriminate H.
  destruct s2b as [ | | | opta aa ala | | | | | | | | | | ];
    try discriminate H.
  destruct opta as [ t2 | ]; try discriminate H.
  destruct aa as [ | | | | fa ftya | | | | | | | | | ];
    try discriminate H.
  destruct ala as [ | aa1 ala1 ]; try discriminate H.
  destruct aa1 as [ | | | | | mp2 tmp2 | | | | | | | | ];
    try discriminate H.
  destruct ala1 as [ | aa2 ala2 ]; try discriminate H.
  destruct aa2 as [ | | | | | t1' tt1 | | | | | | | | ];
    try discriminate H.
  destruct ala2 as [ | aa3 ala3 ]; try discriminate H.
  destruct aa3 as [ | | | | | t6' tt6 | | | | | | | | ];
    try discriminate H.
  destruct ala3; try discriminate H.
  apply andb_true_iff in H as [H Hftya].
  apply andb_true_iff in H as [H Hftyd].
  apply andb_true_iff in H as [H Htt6].
  apply andb_true_iff in H as [H Htt1].
  apply andb_true_iff in H as [H Htt7].
  apply andb_true_iff in H as [H Htmp2].
  apply andb_true_iff in H as [H Htmp1].
  apply andb_true_iff in H as [H Hne61].
  apply andb_true_iff in H as [H Ht6'].
  apply andb_true_iff in H as [H Ht1'].
  apply andb_true_iff in H as [H Ht7'].
  apply andb_true_iff in H as [H Hmp2].
  apply andb_true_iff in H as [H Hmp1].
  apply andb_true_iff in H as [H Hfa].
  apply andb_true_iff in H as [H Hfd].
  apply andb_true_iff in H as [H Ht2ok].
  apply andb_true_iff in H as [H Ht6ok].
  apply andb_true_iff in H as [Ht7ok Ht1ok].
  apply Pos.eqb_eq in Hfd; subst fd.
  apply Pos.eqb_eq in Hfa; subst fa.
  apply Pos.eqb_eq in Hmp1; subst mp1.
  apply Pos.eqb_eq in Hmp2; subst mp2.
  apply Pos.eqb_eq in Ht7'; subst t7'.
  apply Pos.eqb_eq in Ht1'; subst t1'.
  apply Pos.eqb_eq in Ht6'; subst t6'.
  apply negb_true_iff in Hne61.
  destruct (type_eq tmp1 tyMSi) as [-> | ]; [ | discriminate Htmp1 ].
  destruct (type_eq tmp2 tyMSi) as [-> | ]; [ | discriminate Htmp2 ].
  destruct (type_eq tt7 tint) as [-> | ]; [ | discriminate Htt7 ].
  destruct (type_eq tt1 tuint) as [-> | ]; [ | discriminate Htt1 ].
  destruct (type_eq tt6 tint) as [-> | ]; [ | discriminate Htt6 ].
  destruct (type_eq ftyd (Tfunction (tyMSi :: tint :: nil) tuint
                            cc_default)) as [-> | ];
    [ | discriminate Hftyd ].
  destruct (type_eq ftya (Tfunction (tyMSi :: tuint :: tuint :: nil)
                            tint cc_default)) as [-> | ];
    [ | discriminate Hftya ].
  exists t7, a7, t1, t6, a6, t2. repeat split; assumption.
Qed.

Fixpoint ioms_chk (ids xids sids oids qids : list ident) (s : statement)
  : bool :=
  wwalk_chk' nil nil nil nil nil nil false
    nil ids nil tdaknb_cact xids sids nil s
  || match s with
     | Ssequence s1 s2 =>
         iodp_sp_chk s
         || ioms_inp_chk s
         || (ioms_chk ids xids sids oids qids s1
             && ioms_chk ids xids sids oids qids s2)
     | Sifthenelse _ s1 s2 =>
         ioms_chk ids xids sids oids qids s1
         && ioms_chk ids xids sids oids qids s2
     | _ => ioms_sp_chk s || ioms_ob_chk oids s || ioms_io_chk qids s
     end.

(* ---- vm pins ---- *)
Lemma ioms_mrb_walk :
  ioms_chk nil nil nil nil nil
    (fn_body interaction.f_interact_mr_blizzard) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ioms_dmg_walk :
  ioms_chk nil nil nil nil nil (fn_body interaction.f_interact_damage) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma io_mrb_pin :
  (prog_defmap interaction.prog) ! interaction._interact_mr_blizzard
  = Some (Gfun (Internal interaction.f_interact_mr_blizzard)).
Proof. vm_compute. reflexivity. Qed.

Lemma io_dmg_pin :
  (prog_defmap interaction.prog) ! interaction._interact_damage
  = Some (Gfun (Internal interaction.f_interact_damage)).
Proof. vm_compute. reflexivity. Qed.

Lemma io_mrb_vars : fn_vars interaction.f_interact_mr_blizzard = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_dmg_vars : fn_vars interaction.f_interact_damage = nil.
Proof. vm_compute. reflexivity. Qed.

Lemma io_mrb_params :
  fn_params interaction.f_interact_mr_blizzard
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.

Lemma io_dmg_params :
  fn_params interaction.f_interact_damage
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.

(* ---- clam_or_bubba: tdaknb site (ioms arm) + a const-action sma
   call + o->rawData chase loads; rides the PARAMETRIC ioms walker
   with sids = [set_mario_action]. ---- *)
Lemma io_cl_pin :
  (prog_defmap interaction.prog) ! interaction._interact_clam_or_bubba
  = Some (Gfun (Internal interaction.f_interact_clam_or_bubba)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_cl_vars : fn_vars interaction.f_interact_clam_or_bubba = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_cl_params :
  fn_params interaction.f_interact_clam_or_bubba
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_cl_walk :
  ioms_chk nil nil (interaction._set_mario_action :: nil) nil nil
    (fn_body interaction.f_interact_clam_or_bubba) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- snufit_bullet: the dka->dasma pair (iodp arm) + tdfio/umsc
   internal calls + play_sound + a const-arg dasma site. ---- *)
Lemma io_sn_pin :
  (prog_defmap interaction.prog) ! interaction._interact_snufit_bullet
  = Some (Gfun (Internal interaction.f_interact_snufit_bullet)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_sn_vars : fn_vars interaction.f_interact_snufit_bullet = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_sn_params :
  fn_params interaction.f_interact_snufit_bullet
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_sn_walk :
  ioms_chk
    (interaction._take_damage_from_interact_object
     :: interaction._update_mario_sound_and_camera :: nil)
    (interaction._play_sound :: nil)
    (interaction._drop_and_set_mario_action :: nil) nil nil
    (fn_body interaction.f_interact_snufit_bullet) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the site decoder ---- *)
Lemma ioms_sp_decode :
  forall optid a al, ioms_sp_chk (Scall optid a al) = true ->
    exists t1,
      optid = Some t1 /\
      a = Evar interaction._take_damage_and_knock_back
            (Tfunction (tyMSi :: tyObjI :: nil) tuint cc_default) /\
      al = Etempvar interaction._m tyMSi
           :: Etempvar interaction._o tyObjI :: nil /\
      tdaknb_tmp_ok t1 = true.
Proof.
  intros optid a al H. cbn [ioms_sp_chk] in H.
  destruct optid as [ t1 | ]; try discriminate H.
  destruct a as [ | | | | fd fty | | | | | | | | | ];
    try discriminate H.
  destruct al as [ | a1 al1 ]; try discriminate H.
  destruct a1 as [ | | | | | mp tmp | | | | | | | | ];
    try discriminate H.
  destruct al1 as [ | a2 al2 ]; try discriminate H.
  destruct a2 as [ | | | | | op2 top2 | | | | | | | | ];
    try discriminate H.
  destruct al2; try discriminate H.
  apply andb_true_iff in H as [H Hfty].
  apply andb_true_iff in H as [H Htop2].
  apply andb_true_iff in H as [H Htmp].
  apply andb_true_iff in H as [H Hop2].
  apply andb_true_iff in H as [H Hmp].
  apply andb_true_iff in H as [Ht1 Hfd].
  apply Pos.eqb_eq in Hfd; subst fd.
  apply Pos.eqb_eq in Hmp; subst mp.
  apply Pos.eqb_eq in Hop2; subst op2.
  destruct (type_eq tmp tyMSi) as [-> | ]; [ | discriminate Htmp ].
  destruct (type_eq top2 tyObjI) as [-> | ]; [ | discriminate Htop2 ].
  destruct (type_eq fty (Tfunction (tyMSi :: tyObjI :: nil) tuint
                           cc_default)) as [-> | ];
    [ | discriminate Hfty ].
  exists t1. repeat split; assumption.
Qed.

(* ====================================================================== *)
(* SLICE 4 (the pure-engine handlers): EIGHT handler bodies pass the      *)
(* PLAIN wwalk with per-handler censuses -- no special sites at all.      *)
(* ids   = walked internal call rows (msrah/umsc/msfv/tdfio);             *)
(* sids  = the act-writer rows (sma/dasma) -- their const-action call     *)
(*         sites ride the engine's smact_call_chk arm;                    *)
(* xids  = play_sound (model-boundary external);                          *)
(* cact  = _o (seeded from the io gate) plus the chase temps the body     *)
(*         loads from m's chase-root fields (marioObj/usedObj/_t'10);     *)
(* wact  = flame's _burningAction only (Sset from untainted consts).     *)
(* ====================================================================== *)

(* ---- cannon_base ---- *)
Lemma io_cb_pin :
  (prog_defmap interaction.prog) ! interaction._interact_cannon_base
  = Some (Gfun (Internal interaction.f_interact_cannon_base)).
Proof. vm_compute. reflexivity. Qed.
Example io_cb_vars : fn_vars interaction.f_interact_cannon_base = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_cb_params :
  fn_params interaction.f_interact_cannon_base
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_cb_walk :
  wwalk_chk false nil
    (interaction._mario_stop_riding_and_holding :: nil) nil
    (interaction._o :: nil) nil
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_cannon_base) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- bbh_entrance ---- *)
Lemma io_bbh_pin :
  (prog_defmap interaction.prog) ! interaction._interact_bbh_entrance
  = Some (Gfun (Internal interaction.f_interact_bbh_entrance)).
Proof. vm_compute. reflexivity. Qed.
Example io_bbh_vars : fn_vars interaction.f_interact_bbh_entrance = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_bbh_params :
  fn_params interaction.f_interact_bbh_entrance
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_bbh_walk :
  wwalk_chk false nil
    (interaction._mario_stop_riding_and_holding :: nil) nil
    (interaction._o :: nil) nil
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_bbh_entrance) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- strong_wind ---- *)
Lemma io_sw_pin :
  (prog_defmap interaction.prog) ! interaction._interact_strong_wind
  = Some (Gfun (Internal interaction.f_interact_strong_wind)).
Proof. vm_compute. reflexivity. Qed.
Example io_sw_vars : fn_vars interaction.f_interact_strong_wind = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_sw_params :
  fn_params interaction.f_interact_strong_wind
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_sw_walk :
  wwalk_chk false nil
    (interaction._mario_stop_riding_and_holding
     :: interaction._update_mario_sound_and_camera :: nil) nil
    (interaction._o :: nil)
    (interaction._play_sound :: nil)
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_strong_wind) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- whirlpool ---- *)
Lemma io_wp_pin :
  (prog_defmap interaction.prog) ! interaction._interact_whirlpool
  = Some (Gfun (Internal interaction.f_interact_whirlpool)).
Proof. vm_compute. reflexivity. Qed.
Example io_wp_vars : fn_vars interaction.f_interact_whirlpool = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_wp_params :
  fn_params interaction.f_interact_whirlpool
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_wp_walk :
  wwalk_chk false nil
    (interaction._mario_stop_riding_and_holding :: nil) nil
    (interaction._o :: interaction._marioObj :: nil)
    (interaction._play_sound :: nil)
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_whirlpool) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- tornado ---- *)
Lemma io_tn_pin :
  (prog_defmap interaction.prog) ! interaction._interact_tornado
  = Some (Gfun (Internal interaction.f_interact_tornado)).
Proof. vm_compute. reflexivity. Qed.
Example io_tn_vars : fn_vars interaction.f_interact_tornado = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_tn_params :
  fn_params interaction.f_interact_tornado
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_tn_walk :
  wwalk_chk false nil
    (interaction._mario_stop_riding_and_holding
     :: interaction._update_mario_sound_and_camera
     :: interaction._mario_set_forward_vel :: nil) nil
    (interaction._o :: interaction._marioObj :: nil)
    (interaction._play_sound :: nil)
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_tornado) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- hoot ---- *)
Lemma io_ho_pin :
  (prog_defmap interaction.prog) ! interaction._interact_hoot
  = Some (Gfun (Internal interaction.f_interact_hoot)).
Proof. vm_compute. reflexivity. Qed.
Example io_ho_vars : fn_vars interaction.f_interact_hoot = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_ho_params :
  fn_params interaction.f_interact_hoot
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_ho_walk :
  wwalk_chk false nil
    (interaction._mario_stop_riding_and_holding
     :: interaction._update_mario_sound_and_camera :: nil) nil
    (interaction._o :: interaction._usedObj :: nil) nil
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_hoot) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- shock ---- *)
Lemma io_sh_pin :
  (prog_defmap interaction.prog) ! interaction._interact_shock
  = Some (Gfun (Internal interaction.f_interact_shock)).
Proof. vm_compute. reflexivity. Qed.
Example io_sh_vars : fn_vars interaction.f_interact_shock = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_sh_params :
  fn_params interaction.f_interact_shock
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_sh_walk :
  wwalk_chk false nil
    (interaction._update_mario_sound_and_camera
     :: interaction._take_damage_from_interact_object :: nil) nil
    (interaction._o :: nil)
    (interaction._play_sound :: nil)
    (interaction._drop_and_set_mario_action :: nil) nil
    (fn_body interaction.f_interact_shock) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- flame: the one wact temp (_burningAction, Sset from untainted
   ACT_ constants in both branches) feeds the dasma temp-arg site;
   _t'10 is a chase temp loaded from m->marioObj. ---- *)
Lemma io_fl_pin :
  (prog_defmap interaction.prog) ! interaction._interact_flame
  = Some (Gfun (Internal interaction.f_interact_flame)).
Proof. vm_compute. reflexivity. Qed.
Example io_fl_vars : fn_vars interaction.f_interact_flame = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_fl_params :
  fn_params interaction.f_interact_flame
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_fl_walk :
  wwalk_chk false
    (interaction._burningAction :: nil)
    (interaction._update_mario_sound_and_camera :: nil) nil
    (interaction._o :: interaction._marioObj :: interaction._t'10 :: nil)
    (interaction._play_sound :: nil)
    (interaction._drop_and_set_mario_action :: nil) nil
    (fn_body interaction.f_interact_flame) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- warp (slice 5): pure engine -- mario_stop_riding_object internal
   row + play_sound/segmented_to_virtual externals + const-action sma. *)
Lemma io_wa_pin :
  (prog_defmap interaction.prog) ! interaction._interact_warp
  = Some (Gfun (Internal interaction.f_interact_warp)).
Proof. vm_compute. reflexivity. Qed.
Example io_wa_vars : fn_vars interaction.f_interact_warp = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_wa_params :
  fn_params interaction.f_interact_warp
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_wa_walk :
  wwalk_chk false nil
    (interaction._mario_stop_riding_object :: nil) nil
    (interaction._o :: nil)
    (interaction._play_sound :: interaction._segmented_to_virtual :: nil)
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_warp) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- coin (slice 5): pure engine -- the only callee is the EXTERNAL
   bhv_spawn_star_no_level_exit (obj_ext model boundary). *)
Lemma io_co_pin :
  (prog_defmap interaction.prog) ! interaction._interact_coin
  = Some (Gfun (Internal interaction.f_interact_coin)).
Proof. vm_compute. reflexivity. Qed.
Example io_co_vars : fn_vars interaction.f_interact_coin = nil.
Proof. vm_compute. reflexivity. Qed.
Example io_co_params :
  fn_params interaction.f_interact_coin
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example io_co_walk :
  wwalk_chk false nil nil nil
    (interaction._o :: nil)
    (interaction._bhv_spawn_star_no_level_exit :: nil)
    nil nil
    (fn_body interaction.f_interact_coin) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- slice-5 (m,o)-helpers: determine_interaction (reader + the
   moato angle helper) and bounce_back_from_attack (m-window vel
   stores + msfv + two model-boundary externals).  Both ride the
   PLAIN call_pres_of_wwalk producer: only the FIRST param is gated
   (_m = Mario's pointer); the trailing Object*/u32 params are
   harmless because neither body stores through them. ---- *)
Definition di_ids : list ident :=
  interaction._mario_obj_angle_to_object :: nil.
Lemma di_pin :
  (prog_defmap interaction.prog) ! interaction._determine_interaction
  = Some (Gfun (Internal interaction.f_determine_interaction)).
Proof. vm_compute. reflexivity. Qed.
Lemma di_vars : fn_vars interaction.f_determine_interaction = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma di_params_ok :
  match fn_params interaction.f_determine_interaction with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma di_walk :
  wwalk_chk false nil di_ids nil nil nil nil nil
    (fn_body interaction.f_determine_interaction) = true.
Proof. vm_compute. reflexivity. Qed.

Definition bba_ids : list ident :=
  interaction._mario_set_forward_vel :: nil.
Definition bba_xids : list ident :=
  interaction._play_sound :: interaction._set_camera_shake_from_hit :: nil.
Lemma bba_pin :
  (prog_defmap interaction.prog) ! interaction._bounce_back_from_attack
  = Some (Gfun (Internal interaction.f_bounce_back_from_attack)).
Proof. vm_compute. reflexivity. Qed.
Lemma bba_vars : fn_vars interaction.f_bounce_back_from_attack = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma bba_params_ok :
  match fn_params interaction.f_bounce_back_from_attack with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma bba_walk :
  wwalk_chk false nil bba_ids nil nil bba_xids nil nil
    (fn_body interaction.f_bounce_back_from_attack) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- unknown_08: di + bba internal calls + the tdaknb ms site
   (rides the ioms special arm). ---- *)
Lemma io_u08_pin :
  (prog_defmap interaction.prog) ! interaction._interact_unknown_08
  = Some (Gfun (Internal interaction.f_interact_unknown_08)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_u08_vars : fn_vars interaction.f_interact_unknown_08 = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_u08_params :
  fn_params interaction.f_interact_unknown_08
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_u08_walk :
  ioms_chk
    (interaction._determine_interaction
     :: interaction._bounce_back_from_attack :: nil)
    nil nil nil nil (fn_body interaction.f_interact_unknown_08) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- should_push_or_pull_door: pure (m,o) reader + atan2s ---- *)
Definition spd_xids : list ident := interaction._atan2s :: nil.
Lemma spd_pin :
  (prog_defmap interaction.prog) ! interaction._should_push_or_pull_door
  = Some (Gfun (Internal interaction.f_should_push_or_pull_door)).
Proof. vm_compute. reflexivity. Qed.
Lemma spd_vars : fn_vars interaction.f_should_push_or_pull_door = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma spd_params_ok :
  match fn_params interaction.f_should_push_or_pull_door with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma spd_walk :
  wwalk_chk false nil nil nil nil spd_xids nil nil
    (fn_body interaction.f_should_push_or_pull_door) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- warp_door: spd internal + sfgf/s2v externals + ONE sma call
   whose action arg is the _doorAction temp -- threaded through wact
   (every Sset into it is an untainted door-action const). ---- *)
Definition io_wd_wact : list ident := 1574089240964072973%positive :: nil.
Lemma io_wd_pin :
  (prog_defmap interaction.prog) ! interaction._interact_warp_door
  = Some (Gfun (Internal interaction.f_interact_warp_door)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_wd_vars : fn_vars interaction.f_interact_warp_door = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_wd_params :
  fn_params interaction.f_interact_warp_door
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_wd_walk :
  wwalk_chk false io_wd_wact
    (interaction._should_push_or_pull_door :: nil) nil
    (interaction._o :: nil)
    (interaction._save_file_get_flags
     :: interaction._segmented_to_virtual :: nil)
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_warp_door) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the ob pair: attack_object (stores THROUGH its Object param;
   needs the SafeB gate) and get_mario_cap_flag (pure reader + the
   virtual_to_segmented boundary).  Both ride call_pres_ob_of_wwalk. ---- *)
Lemma ao_pin :
  (prog_defmap interaction.prog) ! interaction._attack_object
  = Some (Gfun (Internal interaction.f_attack_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma ao_vars : fn_vars interaction.f_attack_object = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ao_params_ok :
  match fn_params interaction.f_attack_object with
  | (i, _) :: ps =>
      Pos.eqb i interaction._o
      && negb (mem_id interaction._o (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ao_no_m :
  negb (mem_id mario_actions_airborne._m
          (map fst (fn_params interaction.f_attack_object))) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ao_walk :
  wwalk_chk false nil nil nil (interaction._o :: nil) nil nil nil
    (fn_body interaction.f_attack_object) = true.
Proof. vm_compute. reflexivity. Qed.

Definition gmcf_xids : list ident :=
  interaction._virtual_to_segmented :: nil.
Lemma gmcf_pin :
  (prog_defmap interaction.prog) ! interaction._get_mario_cap_flag
  = Some (Gfun (Internal interaction.f_get_mario_cap_flag)).
Proof. vm_compute. reflexivity. Qed.
Lemma gmcf_vars : fn_vars interaction.f_get_mario_cap_flag = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma gmcf_params_ok :
  match fn_params interaction.f_get_mario_cap_flag with
  | (i, _) :: ps =>
      Pos.eqb i interaction._capObject
      && negb (mem_id interaction._capObject (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma gmcf_no_m :
  negb (mem_id mario_actions_airborne._m
          (map fst (fn_params interaction.f_get_mario_cap_flag))) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma gmcf_walk :
  wwalk_chk false nil nil nil (interaction._capObject :: nil)
    gmcf_xids nil nil
    (fn_body interaction.f_get_mario_cap_flag) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- bounce_off_object / hit_object_from_below: plain (m,..) rows
   (all stores are m-window; the Object args are read-only) ---- *)
Definition boo_xids : list ident := interaction._play_sound :: nil.
Lemma boo_pin :
  (prog_defmap interaction.prog) ! interaction._bounce_off_object
  = Some (Gfun (Internal interaction.f_bounce_off_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma boo_vars : fn_vars interaction.f_bounce_off_object = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma boo_params_ok :
  match fn_params interaction.f_bounce_off_object with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma boo_walk :
  wwalk_chk false nil nil nil nil boo_xids nil nil
    (fn_body interaction.f_bounce_off_object) = true.
Proof. vm_compute. reflexivity. Qed.

Definition hofb_xids : list ident :=
  interaction._set_camera_shake_from_hit :: nil.
Lemma hofb_pin :
  (prog_defmap interaction.prog) ! interaction._hit_object_from_below
  = Some (Gfun (Internal interaction.f_hit_object_from_below)).
Proof. vm_compute. reflexivity. Qed.
Lemma hofb_vars : fn_vars interaction.f_hit_object_from_below = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma hofb_params_ok :
  match fn_params interaction.f_hit_object_from_below with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma hofb_walk :
  wwalk_chk false nil nil nil nil hofb_xids nil nil
    (fn_body interaction.f_hit_object_from_below) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- reset_mario_pitch: plain (m) row; its only callee is the
   set_camera_mode camera external (already in obj_ext_ids). ---- *)
Definition rmp_xids : list ident := interaction._set_camera_mode :: nil.
Lemma rmp_pin :
  (prog_defmap interaction.prog) ! interaction._reset_mario_pitch
  = Some (Gfun (Internal interaction.f_reset_mario_pitch)).
Proof. vm_compute. reflexivity. Qed.
Lemma rmp_vars : fn_vars interaction.f_reset_mario_pitch = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma rmp_params_ok :
  match fn_params interaction.f_reset_mario_pitch with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma rmp_walk :
  wwalk_chk false nil nil nil nil rmp_xids nil nil
    (fn_body interaction.f_reset_mario_pitch) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- bounce_top: di/bba/boo/rmp internals + play_sound + ONE
   dasma sma-class call + attack_object through the _o chase temp ---- *)
Lemma io_bt_pin :
  (prog_defmap interaction.prog) ! interaction._interact_bounce_top
  = Some (Gfun (Internal interaction.f_interact_bounce_top)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_bt_vars : fn_vars interaction.f_interact_bounce_top = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_bt_params :
  fn_params interaction.f_interact_bounce_top
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_bt_walk :
  ioms_chk
    (interaction._determine_interaction
     :: interaction._bounce_back_from_attack
     :: interaction._bounce_off_object
     :: interaction._reset_mario_pitch :: nil)
    (interaction._play_sound :: nil)
    (interaction._drop_and_set_mario_action :: nil)
    (interaction._attack_object :: nil) nil
    (fn_body interaction.f_interact_bounce_top) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- get_door_save_file_flag: a STORELESS internal (reads the door
   object's star fields through its only param, calls the
   save_file_get_flags boundary).  Takes the marg-free call_pres_ext
   row via call_pres_ext_of_wwalk, so the door call site rides the
   EXISTING xids arm -- no walker surgery. ---- *)
Definition gdsff_xids : list ident :=
  interaction._save_file_get_flags :: nil.
Lemma gdsff_pin :
  (prog_defmap interaction.prog) ! interaction._get_door_save_file_flag
  = Some (Gfun (Internal interaction.f_get_door_save_file_flag)).
Proof. vm_compute. reflexivity. Qed.
Lemma gdsff_vars : fn_vars interaction.f_get_door_save_file_flag = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma gdsff_no_m :
  negb (mem_id mario_actions_airborne._m
          (map fst (fn_params interaction.f_get_door_save_file_flag)))
  = true.
Proof. vm_compute. reflexivity. Qed.
Lemma gdsff_walk :
  wwalk_chk false nil nil nil nil gdsff_xids nil nil
    (fn_body interaction.f_get_door_save_file_flag) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- door: spd internal + the save-file readers + ONE sma call whose
   action arg is the _doorAction temp -- threaded through wact (every
   Sset into it is an untainted door-action const). ---- *)
Definition io_door_wact : list ident :=
  1690165452731539260872185294%positive :: nil.
Definition io_door_ids : list ident :=
  interaction._should_push_or_pull_door :: nil.
Definition io_door_xids : list ident :=
  interaction._save_file_get_flags
  :: interaction._save_file_get_total_star_count
  :: interaction._get_door_save_file_flag :: nil.
Lemma io_door_pin :
  (prog_defmap interaction.prog) ! interaction._interact_door
  = Some (Gfun (Internal interaction.f_interact_door)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_door_vars : fn_vars interaction.f_interact_door = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_door_params :
  fn_params interaction.f_interact_door
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_door_walk :
  wwalk_chk false io_door_wact io_door_ids nil
    (interaction._o :: nil) io_door_xids
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_door) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- pole: msrah/rmp internals + TWO const-action sma calls.  The
   marioObj local rides the chase census (clightgen reuses the FIELD
   ident 365847869239958 for the local temp); its rawData indexed
   stores take the chase arm, and the fast-branch
   `oMarioPoleYawVel = (s32)(m->forwardVel*256+4096)` site takes the
   NEW float-source-cast rhs arm (wchase_rhs_ok's Ecast row). ---- *)
Definition io_pole_ids : list ident :=
  interaction._mario_stop_riding_and_holding
  :: interaction._reset_mario_pitch :: nil.
Definition io_pole_cact : list ident :=
  interaction._o :: 365847869239958%positive :: nil.
Lemma io_pole_pin :
  (prog_defmap interaction.prog) ! interaction._interact_pole
  = Some (Gfun (Internal interaction.f_interact_pole)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_pole_vars : fn_vars interaction.f_interact_pole = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_pole_params :
  fn_params interaction.f_interact_pole
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_pole_walk :
  wwalk_chk false nil io_pole_ids nil io_pole_cact nil
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_pole) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the grabbable cluster: two pure-reader internals, the io-shaped
   check_object_grab_mario helper (the FIRST call_pres_io row), and the
   handler itself. ---- *)
Definition ofm_xids : list ident := interaction._atan2s :: nil.
Lemma ofm_pin :
  (prog_defmap interaction.prog) ! interaction._object_facing_mario
  = Some (Gfun (Internal interaction.f_object_facing_mario)).
Proof. vm_compute. reflexivity. Qed.
Lemma ofm_vars : fn_vars interaction.f_object_facing_mario = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ofm_params_ok :
  match fn_params interaction.f_object_facing_mario with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ofm_walk :
  wwalk_chk false nil nil nil nil ofm_xids nil nil
    (fn_body interaction.f_object_facing_mario) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma atgo_pin :
  (prog_defmap interaction.prog) ! interaction._able_to_grab_object
  = Some (Gfun (Internal interaction.f_able_to_grab_object)).
Proof. vm_compute. reflexivity. Qed.
Lemma atgo_vars : fn_vars interaction.f_able_to_grab_object = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma atgo_params_ok :
  match fn_params interaction.f_able_to_grab_object with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma atgo_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body interaction.f_able_to_grab_object) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma cogm_pin :
  (prog_defmap interaction.prog) ! interaction._check_object_grab_mario
  = Some (Gfun (Internal interaction.f_check_object_grab_mario)).
Proof. vm_compute. reflexivity. Qed.
Lemma cogm_vars : fn_vars interaction.f_check_object_grab_mario = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma cogm_params :
  fn_params interaction.f_check_object_grab_mario
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_cogm_walk :
  ioms_chk
    (interaction._object_facing_mario
     :: interaction._mario_stop_riding_and_holding
     :: interaction._update_mario_sound_and_camera
     :: interaction._push_mario_out_of_object :: nil)
    (interaction._play_sound :: nil)
    (interaction._set_mario_action :: nil) nil nil
    (fn_body interaction.f_check_object_grab_mario) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma io_grab_pin :
  (prog_defmap interaction.prog) ! interaction._interact_grabbable
  = Some (Gfun (Internal interaction.f_interact_grabbable)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_grab_vars : fn_vars interaction.f_interact_grabbable = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_grab_params :
  fn_params interaction.f_interact_grabbable
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_grab_walk :
  ioms_chk
    (interaction._determine_interaction
     :: interaction._bounce_back_from_attack
     :: interaction._push_mario_out_of_object
     :: interaction._able_to_grab_object :: nil)
    (interaction._virtual_to_segmented :: nil)
    nil
    (interaction._attack_object :: nil)
    (interaction._check_object_grab_mario :: nil)
    (fn_body interaction.f_interact_grabbable) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- star_or_key: the wact channel (starGrabAction is a TEMP fed only
   ACT_* constants), spawn_object via the sr-row weakening, and four
   music/save model-boundary externals. ---- *)
Definition io_sok_wact : list ident :=
  26408835198858973405816668%positive (* starGrabAction *) :: nil.
Definition io_sok_ids : list ident :=
  interaction._mario_stop_riding_and_holding
  :: interaction._update_mario_sound_and_camera :: nil.
Definition io_sok_xids : list ident :=
  interaction._play_sound
  :: interaction._save_file_get_total_star_count
  :: interaction._save_file_collect_star_or_key
  :: interaction._drop_queued_background_music
  :: interaction._fadeout_level_music
  :: interaction._spawn_object :: nil.
Lemma io_sok_pin :
  (prog_defmap interaction.prog) ! interaction._interact_star_or_key
  = Some (Gfun (Internal interaction.f_interact_star_or_key)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_sok_vars : fn_vars interaction.f_interact_star_or_key = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_sok_params :
  fn_params interaction.f_interact_star_or_key
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_sok_walk :
  wwalk_chk false io_sok_wact io_sok_ids nil
    (interaction._o :: nil) io_sok_xids
    (interaction._set_mario_action :: nil) nil
    (fn_body interaction.f_interact_star_or_key) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- hit_from_below: fn_vars = ONE DEAD u8[4] filler (never referenced
   anywhere in the body -- a clightgen artifact of the UNUSED filler
   array).  The vars-tolerant io entry (ioms_body_pres_dv) eats it via
   the LocalVarsSurface alloc/free bricks; no lids store machinery. ---- *)
Definition io_filler : ident := 97950979215%positive.

(* mem_id membership + a forallb-ne census check pin an ident apart from
   the filler (discharges the engine's e!g = None premises for the
   singleton stack env). *)
Lemma mem_id_forallb_ne :
  forall (fl : ident) (l : list ident) (g : ident),
    forallb (fun fid => negb (Pos.eqb fid fl)) l = true ->
    mem_id g l = true -> Pos.eqb g fl = false.
Proof.
  intros fl l g Hall Hmem.
  unfold mem_id in Hmem.
  apply existsb_exists in Hmem as (x & Hin & He).
  apply Pos.eqb_eq in He. subst x.
  rewrite forallb_forall in Hall.
  apply negb_true_iff. exact (Hall _ Hin).
Qed.

Lemma io_hfb_pin :
  (prog_defmap interaction.prog) ! interaction._interact_hit_from_below
  = Some (Gfun (Internal interaction.f_interact_hit_from_below)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_hfb_vars :
  fn_vars interaction.f_interact_hit_from_below
  = (io_filler, Tarray tuchar 4 noattr) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_hfb_params :
  fn_params interaction.f_interact_hit_from_below
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_hfb_walk :
  ioms_chk
    (interaction._reset_mario_pitch
     :: interaction._determine_interaction
     :: interaction._bounce_back_from_attack
     :: interaction._update_mario_sound_and_camera
     :: interaction._push_mario_out_of_object
     :: interaction._hit_object_from_below
     :: interaction._bounce_off_object :: nil)
    (interaction._play_sound :: nil)
    (interaction._set_mario_action
     :: interaction._drop_and_set_mario_action :: nil)
    (interaction._attack_object :: nil)
    nil
    (fn_body interaction.f_interact_hit_from_below) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the three ob-unlocked handlers: cap, koopa_shell, breakable ---- *)
Lemma io_cap_pin :
  (prog_defmap interaction.prog) ! interaction._interact_cap
  = Some (Gfun (Internal interaction.f_interact_cap)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_cap_vars : fn_vars interaction.f_interact_cap = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_cap_params :
  fn_params interaction.f_interact_cap
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_cap_walk :
  ioms_chk nil
    (interaction._play_cap_music :: interaction._play_sound :: nil)
    (interaction._set_mario_action :: nil)
    (interaction._get_mario_cap_flag :: nil) nil
    (fn_body interaction.f_interact_cap) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma io_ks_pin :
  (prog_defmap interaction.prog) ! interaction._interact_koopa_shell
  = Some (Gfun (Internal interaction.f_interact_koopa_shell)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_ks_vars : fn_vars interaction.f_interact_koopa_shell = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_ks_params :
  fn_params interaction.f_interact_koopa_shell
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_ks_walk :
  ioms_chk
    (interaction._determine_interaction
     :: interaction._update_mario_sound_and_camera
     :: interaction._mario_drop_held_object
     :: interaction._push_mario_out_of_object :: nil)
    (interaction._play_shell_music :: nil)
    (interaction._set_mario_action :: nil)
    (interaction._attack_object :: nil) nil
    (fn_body interaction.f_interact_koopa_shell) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma io_brk_pin :
  (prog_defmap interaction.prog) ! interaction._interact_breakable
  = Some (Gfun (Internal interaction.f_interact_breakable)).
Proof. vm_compute. reflexivity. Qed.
Lemma io_brk_vars : fn_vars interaction.f_interact_breakable = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma io_brk_params :
  fn_params interaction.f_interact_breakable
  = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
    :: (interaction._interactType, tuint)
    :: (interaction._o, tptr (Tstruct interaction._Object noattr)) :: nil.
Proof. vm_compute. reflexivity. Qed.
Lemma ioms_brk_walk :
  ioms_chk
    (interaction._determine_interaction
     :: interaction._bounce_back_from_attack
     :: interaction._bounce_off_object
     :: interaction._hit_object_from_below :: nil)
    nil
    (interaction._set_mario_action :: nil)
    (interaction._attack_object :: nil) nil
    (fn_body interaction.f_interact_breakable) = true.
Proof. vm_compute. reflexivity. Qed.

Section IoSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
        bg <> bm /\
        (forall mm mm' ch0 (d : Z) vv,
            MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = Errors.OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = Errors.OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* the walked-callee row: push_mario_out_of_object (Section
     PmooSurface's pmoo_cp at the capstone; igloo's only callee). *)
  Hypothesis Hcp_pmoo :
    call_pres lp bm NoA MWF interaction._push_mario_out_of_object.

  (* ---- slice-3 rows: the dka/tdfio/tdaknb helper chain feeding the
     mr_blizzard + damage handler walks.  All 7 hypotheses are
     dischargeable at the capstone from EXISTING materials (MWF_real's
     R10 ktab row, the walked moato/msfv/umsc/dasma internals, and the
     obj_ext model-boundary externals). ---- *)
  Hypothesis HMWF_ktab : forall m gid kb (ofs : Z) v,
      MWF m -> mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      Mem.load Mint32 m kb ofs = Some v ->
      untainted_scalar v.
  Hypothesis Hcp_moato :
    call_pres lp bm NoA MWF interaction._mario_obj_angle_to_object.
  Hypothesis Hcp_msfv :
    call_pres lp bm NoA MWF interaction._mario_set_forward_vel.
  Hypothesis Hcpx_scsfh :
    call_pres_ext lp bm NoA MWF interaction._set_camera_shake_from_hit.
  Hypothesis Hcp_umsc :
    call_pres lp bm NoA MWF interaction._update_mario_sound_and_camera.
  Hypothesis Hcpx_ps :
    call_pres_ext lp bm NoA MWF interaction._play_sound.
  Hypothesis Hcpa_dasma :
    call_pres_act lp bm NoA MWF interaction._drop_and_set_mario_action.

  (* ---- slice-4 rows: the two remaining shared callees of the eight
     pure-engine handlers.  At the capstone: msrah_row (the walked
     mario_stop_riding_and_holding internal) and the smact_pres
     keystone (set_mario_action itself). ---- *)
  Hypothesis Hcp_msrah :
    call_pres lp bm NoA MWF interaction._mario_stop_riding_and_holding.
  Hypothesis Hcpa_sma :
    call_pres_act lp bm NoA MWF interaction._set_mario_action.
  (* slice-5: the walked mario_stop_riding_object internal (msro_row)
     and the segmented_to_virtual model boundary *)
  Hypothesis Hcp_msro :
    call_pres lp bm NoA MWF interaction._mario_stop_riding_object.
  Hypothesis Hcpx_s2v_io :
    call_pres_ext lp bm NoA MWF interaction._segmented_to_virtual.
  Hypothesis Hcpx_bssnle :
    call_pres_ext lp bm NoA MWF
      interaction._bhv_spawn_star_no_level_exit.
  (* slice-5 (warp_door): the atan2s math external (spd's only callee)
     and the save-buffer reader. *)
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF interaction._atan2s.
  Hypothesis Hcpx_sfgf :
    call_pres_ext lp bm NoA MWF interaction._save_file_get_flags.
  (* slice-5 ob arc (cap / koopa_shell / breakable): gmcf's
     virtual_to_segmented boundary, the two music externals, and the
     walked mario_drop_held_object internal (mdho_row). *)
  Hypothesis Hcpx_v2seg_io :
    call_pres_ext lp bm NoA MWF interaction._virtual_to_segmented.
  Hypothesis Hcpx_pcm :
    call_pres_ext lp bm NoA MWF interaction._play_cap_music.
  Hypothesis Hcpx_psm :
    call_pres_ext lp bm NoA MWF interaction._play_shell_music.
  Hypothesis Hcp_mdho :
    call_pres lp bm NoA MWF interaction._mario_drop_held_object.
  (* slice-5 (bounce_top + door): the set_camera_mode camera external
     (rmp's only callee; already in obj_ext_ids) and the save-file
     total-star-count reader. *)
  Hypothesis Hcpx_scm :
    call_pres_ext lp bm NoA MWF interaction._set_camera_mode.
  Hypothesis Hcpx_sfgtsc :
    call_pres_ext lp bm NoA MWF
      interaction._save_file_get_total_star_count.
  (* slice-5 (grabbable): the input-cell MWF rows -- mwf_real_input /
     mwf_real_inp at the capstone, BOTH ALREADY PROVED (zero new trust). *)
  Hypothesis HMWF_input : forall mm mm' vv,
      MWF mm -> Int.and vv (Int.repr 2) = Int.zero ->
      Mem.store Mint16unsigned mm bm 2 (Vint vv) = Some mm' -> MWF mm'.
  Hypothesis HMWF_inp : forall m v,
      MWF m -> Mem.load Mint16unsigned m bm 2 = Some (Vint v) ->
      Int.and v (Int.repr 2) = Int.zero.
  (* slice-5 (hit_from_below): the stack-frame alloc/free rows --
     mwf_real_alloc / mwf_real_free at the capstone, BOTH PROVED. *)
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.
  (* slice-5 (star_or_key): three music/save model-boundary externals
     (same classes as play_sound / sfgtsc -- obj_ext rows at the
     capstone) + spawn_object as a PLAIN ext row (the capstone
     discharges it by WEAKENING the existing call_pres_ext_sr
     spawn_object row -- zero new trust). *)
  Hypothesis Hcpx_sfcsok :
    call_pres_ext lp bm NoA MWF
      interaction._save_file_collect_star_or_key.
  Hypothesis Hcpx_dqbm :
    call_pres_ext lp bm NoA MWF
      interaction._drop_queued_background_music.
  Hypothesis Hcpx_flm :
    call_pres_ext lp bm NoA MWF interaction._fadeout_level_music.
  Hypothesis Hcpx_so :
    call_pres_ext lp bm NoA MWF interaction._spawn_object.

  Let Hcp_tdfio :
    call_pres lp bm NoA MWF interaction._take_damage_from_interact_object
    := tdfio_row lp LO_mario LO_int bm NoA MWF HNoA_of_MWF HMWF_window
         Hcpx_scsfh.
  Let Hcpra_dka :
    call_pres_ret_act lp bm NoA MWF
      interaction._determine_knockback_action
    := dka_row lp LO_mario LO_int bm NoA MWF HNoA_of_MWF HMWF_window
         HMWF_ktab Hcp_moato Hcp_msfv.
  Let Hcp_ms_tdaknb :
    call_pres_ms lp bm NoA MWF SafeB
      interaction._take_damage_and_knock_back
    := tdaknb_row lp LO_mario LO_int bm NoA MWF SafeB HNoA_of_MWF
         HMWF_window HMWF_glob HMWF_act HSafeNotBm HchaseRoot HMWF_chase
         HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
         Hcp_tdfio Hcp_umsc Hcpx_ps Hcpra_dka Hcpa_dasma.

  (* ================================================================== *)
  (* THE io ENTRY PRODUCER: a handler body whose params are EXACTLY      *)
  (* (m, interactType, o), walked by the wwalk engine with _o seeded     *)
  (* into the chase census from the io gate's SafeB-object conditional.  *)
  (* Twin of body_pres_of_wwalk_cact; the io gate replaces marg_ok.      *)
  (* ================================================================== *)
  Lemma body_pres_io_of_wwalk :
    forall (f : Clight.function)
           (wact ids wids cact xids sids tids : list ident),
      fn_vars f = nil ->
      fn_params f
      = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
        :: (interaction._interactType, tuint)
        :: (interaction._o, tptr (Tstruct interaction._Object noattr))
        :: nil ->
      forallb (fun t' => negb (Pos.eqb t' interaction._m)
                         && negb (Pos.eqb t' interaction._interactType))
        cact = true ->
      forallb (fun t' => negb (Pos.eqb t' interaction._m)
                         && negb (Pos.eqb t' interaction._interactType)
                         && negb (Pos.eqb t' interaction._o))
        wact = true ->
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' wids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' tids = true ->
                    call_pres_act3 lp bm NoA MWF fid') ->
      wwalk_chk false wact ids wids cact xids sids tids (fn_body f)
        = true ->
      body_pres_io lp bm NoA MWF SafeB f.
  Proof.
    intros f wact ids wids cact xids sids tids Hvars Hps Hcok Hwok
           Hcp Hcpa Hcpx Hcps Hcp3t Hchk
           m0 vm vi vo t0 m1 vres0 Hvm Hvo Hevf HN HM HV HS.
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        rewrite Hvars in Ha; inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    rewrite Hps in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as Hle1.
    (* the entry env facts *)
    assert (Htat0 : forall b o,
               le1 ! interaction._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite <- Hle1 in Hg.
      rewrite PTree.gso in Hg by (vm_compute; discriminate).
      rewrite PTree.gso in Hg by (vm_compute; discriminate).
      rewrite PTree.gss in Hg. injection Hg as ->.
      exact (Hvm b o eq_refl). }
    assert (Hact0 : act_inv wact le1).
    { intros t' Hmem' x Hg'.
      assert (Hin' : In t' wact).
      { unfold mem_id in Hmem'. apply existsb_exists in Hmem'.
        destruct Hmem' as (y & Hy & Heq).
        apply Pos.eqb_eq in Heq. subst y. exact Hy. }
      pose proof (proj1 (forallb_forall _ _) Hwok t' Hin') as Ht'.
      apply andb_prop in Ht' as [Ht' Hne_o].
      apply andb_prop in Ht' as [Hne_m Hne_it].
      apply negb_true_iff in Hne_m. apply negb_true_iff in Hne_it.
      apply negb_true_iff in Hne_o.
      rewrite <- Hle1 in Hg'.
      rewrite PTree.gso in Hg'
        by (intro EE; rewrite EE, Pos.eqb_refl in Hne_o;
            discriminate Hne_o).
      rewrite PTree.gso in Hg'
        by (intro EE; rewrite EE, Pos.eqb_refl in Hne_it;
            discriminate Hne_it).
      rewrite PTree.gso in Hg'
        by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m;
            discriminate Hne_m).
      pose proof (create_undef_temps_val _ _ _ Hg') as ->.
      left; reflexivity. }
    assert (Hch0 : chase_inv SafeB cact le1).
    { intros t' Hmem' b o Hg'.
      assert (Hin' : In t' cact).
      { unfold mem_id in Hmem'. apply existsb_exists in Hmem'.
        destruct Hmem' as (x & Hx & Heq).
        apply Pos.eqb_eq in Heq. subst x. exact Hx. }
      pose proof (proj1 (forallb_forall _ _) Hcok t' Hin') as Ht'.
      apply andb_prop in Ht' as [Hne_m Hne_it].
      apply negb_true_iff in Hne_m. apply negb_true_iff in Hne_it.
      destruct (Pos.eqb t' interaction._o) eqn:Eo.
      - apply Pos.eqb_eq in Eo. subst t'.
        rewrite <- Hle1 in Hg'. rewrite PTree.gss in Hg'.
        injection Hg' as ->.
        exact (Hvo b o eq_refl).
      - rewrite <- Hle1 in Hg'.
        rewrite PTree.gso in Hg'
          by (intro EE; rewrite EE, Pos.eqb_refl in Eo; discriminate Eo).
        rewrite PTree.gso in Hg'
          by (intro EE; rewrite EE, Pos.eqb_refl in Hne_it;
              discriminate Hne_it).
        rewrite PTree.gso in Hg'
          by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m;
              discriminate Hne_m).
        pose proof (create_undef_temps_val _ _ _ Hg') as EE.
        discriminate EE. }
    (* the free list at the empty env *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    (* the walk *)
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false wact ids wids cact xids sids tids Hcp Hcpa Hcpx Hcps
                Hcp3t _ _ _ _ _ _ _ _ Hbody (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _)
                (PTree.gempty _ _) Hchk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & _).
    exact (conj HV' (conj HS' HM')).
  Qed.

  (* ---- interact_water_ring: 2 sites (healCounter window store +
     o->rawData.asS32[43] chase-indexed store), ZERO callees. ---- *)
  Lemma io_water_ring :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_water_ring.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_water_ring
             nil nil nil (interaction._o :: nil) nil nil nil
             io_wr_vars io_wr_params eq_refl eq_refl).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact io_wr_walk.
  Qed.

  (* ---- interact_igloo_barrier: 2 chase-root stores + the pmoo call
     (engine ids arm, discharged by Hcp_pmoo). ---- *)
  Lemma io_igloo :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_igloo_barrier.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_igloo_barrier
             nil (interaction._push_mario_out_of_object :: nil) nil
             (interaction._o :: nil) nil nil nil
             io_ig_vars io_ig_params eq_refl eq_refl).
    - intros fid' H.
      unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_pmoo
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact io_ig_walk.
  Qed.

  (* ---- the generic (engine) delegate: cact only ---- *)
  Lemma ioms_generic :
    forall (ids xids sids : list ident),
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g ids = true -> e ! g = None) ->
      (forall g, mem_id g xids = true -> e ! g = None) ->
      (forall g, mem_id g sids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      wwalk_chk' nil nil nil nil nil nil false
        nil ids nil tdaknb_cact xids sids nil s = true ->
      (forall b o, le ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB tdaknb_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB tdaknb_cact le'.
  Proof.
    intros ids xids sids Hcp_i Hcpx_i Hcps_i
           s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hub_s Hubgt Hchk
           Htat Hact Hch HN HM HV HS Hexec.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil ids nil tdaknb_cact xids sids nil
                nil nil nil nil nil nil
                Hcp_i
                (fun fid HH => match Bool.diff_false_true HH with end)
                Hcpx_i
                Hcps_i
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                _ _ _ _ _ _ _ _
                (fun HH => match HH eq_refl with end)
                (fun lid HH => match Bool.diff_false_true HH with end)
                Hexec
                Hub_g
                Hub_i
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x
                Hub_s
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hubgt
                Hchk Htat Hact Hch
                (fun t HH => match Bool.diff_false_true HH with end)
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* ---- the special-site brick ---- *)
  Lemma ms_scall_pres :
    forall t1 e le0 m0 tr le1 m1 out0,
      e ! interaction._take_damage_and_knock_back = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall (Some t1)
           (Evar interaction._take_damage_and_knock_back
              (Tfunction (tyMSi :: tyObjI :: nil) tuint cc_default))
           (Etempvar interaction._m tyMSi
            :: Etempvar interaction._o tyObjI :: nil))
        tr le1 m1 out0 ->
      (forall b o, le0 ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      (forall b o, le0 ! interaction._o = Some (Vptr b o) -> SafeB b) ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal /\
      (forall t0, t0 <> t1 -> le1 ! t0 = le0 ! t0).
  Proof.
    intros t1 e le0 m0 tr le1 m1 out0 He Hexec Htat Hcho Hc.
    destruct Hc as (HV & HS & HM & HN).
    inv Hexec.
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv)
          as (bf & Hsym & ->)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: _) (_ :: _) _ |- _ =>
        inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
        subst; clear Hvl
    end.
    apply RealFrameValue.eval_expr_Etempvar_val in Hev_a.
    match goal with
    | Hca : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hca; subst
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: _) (_ :: _) _ |- _ =>
        inversion Hvl as [ | a2 bl2 ty2 tyl2 v1b v2b vl2 Hev_b Hsc_b Htl2 ];
        subst; clear Hvl
    end.
    apply RealFrameValue.eval_expr_Etempvar_val in Hev_b.
    match goal with
    | Hca : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hca; subst
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hvl
    end.
    assert (Hvm : forall b o, v1a = Vptr b o -> b = bm /\ o = Ptrofs.zero)
      by (intros b o E; rewrite E in Hev_a; exact (Htat _ _ Hev_a)).
    assert (Hvo : forall b o, v1b = Vptr b o -> SafeB b)
      by (intros b o E; rewrite E in Hev_b; exact (Hcho _ _ Hev_b)).
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _ :: nil) _ _ _,
      Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some _ |- _ =>
        destruct (Hcp_ms_tdaknb _ _ _ _ _ _ _ Hevf
                    ltac:(red; exists bf; split; assumption)
                    Hvm Hvo HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj (conj HV' (conj HS' (conj HM' HN')))
              (conj eq_refl _)).
    intros t0 Hne. cbn [set_opttemp].
    rewrite PTree.gso by exact Hne. reflexivity.
  Qed.

  (* ---- the ob special-site brick ---- *)
  Lemma ob_scall_pres :
    forall (oids : list ident),
      (forall fid', mem_id fid' oids = true ->
                    call_pres_ob lp bm NoA MWF SafeB fid') ->
    forall optid fid tyl rty cc rest e le0 m0 tr le1 m1 out0,
      mem_id fid oids = true ->
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction (tyObjI :: tyl) rty cc))
           (Etempvar interaction._o tyObjI :: rest))
        tr le1 m1 out0 ->
      (forall b o, le0 ! interaction._o = Some (Vptr b o) -> SafeB b) ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1.
  Proof.
    intros oids Hrows optid fid tyl rty cc rest e le0 m0 tr le1 m1 out0
           Hmem He Hexec Hcho Hc.
    destruct Hc as (HV & HS & HM & HN).
    inv Hexec.
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv)
          as (bf & Hsym & ->)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: _) (_ :: _) _ |- _ =>
        inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
        subst; clear Hvl
    end.
    apply RealFrameValue.eval_expr_Etempvar_val in Hev_a.
    match goal with
    | Hca : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hca; subst
    end.
    assert (Hv0 : forall b o, v1a = Vptr b o -> SafeB b)
      by (intros b o E; rewrite E in Hev_a; exact (Hcho _ _ Hev_a)).
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _) _ _ _,
      Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some _ |- _ =>
        destruct (Hrows _ Hmem _ _ _ _ _ _ _ Hevf
                    ltac:(red; exists bf; split; assumption)
                    Hv0 HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the io special-site brick: optid := f(m, <any>, o) for a
     censused io-shaped callee (check_object_grab_mario).  vm/vo gates
     come from the env facts; the middle value is unconstrained. ---- *)
  Lemma io_scall_pres :
    forall (qids : list ident),
      (forall fid', mem_id fid' qids = true ->
                    call_pres_io lp bm NoA MWF SafeB fid') ->
    forall optid fid ty2 rty cc a2 e le0 m0 tr le1 m1 out0,
      mem_id fid qids = true ->
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid
           (Evar fid (Tfunction (tyMSi :: ty2 :: tyObjI :: nil) rty cc))
           (Etempvar interaction._m tyMSi :: a2
            :: Etempvar interaction._o tyObjI :: nil))
        tr le1 m1 out0 ->
      (forall b o, le0 ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      (forall b o, le0 ! interaction._o = Some (Vptr b o) -> SafeB b) ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1.
  Proof.
    intros qids Hrows optid fid ty2 rty cc a2 e le0 m0 tr le1 m1 out0
           Hmem He Hexec Htat Hcho Hc.
    destruct Hc as (HV & HS & HM & HN).
    inv Hexec.
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv)
          as (bf & Hsym & ->)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: _) (_ :: _) _ |- _ =>
        inversion Hvl as [ | a1' bl1 ty1' tyl1 v1a v2a vl1
                             Hev_a Hsc_a Htl1 ];
        subst; clear Hvl
    end.
    apply RealFrameValue.eval_expr_Etempvar_val in Hev_a.
    apply sem_cast_ptr_ptr_id in Hsc_a. subst v2a.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: _) (_ :: _) _ |- _ =>
        inversion Hvl as [ | a2' bl2 ty2' tyl2 v1b v2b vl2
                             Hev_b Hsc_b Htl2 ];
        subst; clear Hvl
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: _) (_ :: _) _ |- _ =>
        inversion Hvl as [ | a3' bl3 ty3' tyl3 v1c v2c vl3
                             Hev_c Hsc_c Htl3 ];
        subst; clear Hvl
    end.
    apply RealFrameValue.eval_expr_Etempvar_val in Hev_c.
    apply sem_cast_ptr_ptr_id in Hsc_c. subst v2c.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hvl
    end.
    assert (Hvm : forall b o, v1a = Vptr b o -> b = bm /\ o = Ptrofs.zero)
      by (intros b o E; rewrite E in Hev_a; exact (Htat _ _ Hev_a)).
    assert (Hvo : forall b o, v1c = Vptr b o -> SafeB b)
      by (intros b o E; rewrite E in Hev_c; exact (Hcho _ _ Hev_c)).
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _ :: _ :: nil) _ _ _,
      Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some _ |- _ =>
        destruct (Hrows _ Hmem _ _ _ _ _ _ _ _ Hevf
                    ltac:(red; exists bf; split; assumption)
                    Hvm Hvo HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ---- the input-OR pair brick: the loaded halfword is A-clear by
     MWF's input row (HMWF_inp); the OR with an A-clear const keeps
     bit 1 clear; HMWF_input absorbs the store of the protected
     [2,4) cell.  Takes the two component execs (the walker's Sseq_1
     case applies it to Hexec1/Hexec2 directly). ---- *)
  Lemma inp_pair_pres :
    forall t c e le0 m0 tr1 le1 m1 out1 tr2 le2 m2 out2,
      tdaknb_tmp_ok t = true ->
      Int.eq (Int.and c (Int.repr 2)) Int.zero = true ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Sset t (Efield (Ederef (Etempvar interaction._m tyMSi)
                   (Tstruct interaction._MarioState noattr))
                   interaction._input tyInpu))
        tr1 le1 m1 out1 ->
      exec_stmt function_entry2 (lp_ge lp) e le1 m1
        (Sassign (Efield (Ederef (Etempvar interaction._m tyMSi)
                    (Tstruct interaction._MarioState noattr))
                    interaction._input tyInpu)
           (Ebinop Oor (Etempvar t tyInpu) (Econst_int c tint) tint))
        tr2 le2 m2 out2 ->
      (forall b o, le0 ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m2 bm /\ action_sat not_tainted m2 bm /\
      MWF m2 /\ NoA m2 /\
      (forall t0, t0 <> t -> le2 ! t0 = le0 ! t0).
  Proof.
    intros t c e le0 m0 tr1 le1 m1 out1 tr2 le2 m2 out2
           Htok Hcclr HSet HAsn Htat HN HM HV HS.
    apply andb_true_iff in Htok as [Htm Hto].
    apply negb_true_iff in Htm. apply negb_true_iff in Hto.
    inv HSet.
    (* ---- the load half: v = the input halfword at (bm,2) ---- *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ =>
        destruct (eval_expr_Efield_load _ _ _ _ _ _ _ _ Hev)
          as (loc & ofs & bf & Hlv & Hd)
    end.
    pose proof Hlv as Hbase0.
    apply eval_lvalue_Efield_base in Hbase0.
    destruct Hbase0 as (oo0 & Hbase).
    apply eval_expr_Ederef_load in Hbase.
    destruct Hbase as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                loc ofs bf _ _ _ Hlvb input_field_off Hlv)
      as (E3 & E4 & E5).
    subst loc ofs bf. clear Hlv.
    inv Hd.
    2:{ match goal with
        | Hac : access_mode _ = By_reference |- _ =>
            cbn in Hac; discriminate Hac end. }
    2:{ match goal with
        | Hac : access_mode _ = By_copy |- _ =>
            cbn in Hac; discriminate Hac end. }
    match goal with
    | Hac : access_mode _ = By_value _ |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hldv : Mem.loadv _ _ _ = Some _ |- _ =>
        unfold Mem.loadv in Hldv;
        change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 2)))
          with 2 in Hldv;
        rename Hldv into HldInput
    end.
    (* ---- the store half ---- *)
    inv HAsn.
    match goal with
    | Hlv2 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv2 as Hbase2;
        apply eval_lvalue_Efield_base in Hbase2;
        destruct Hbase2 as (oo2 & Hbase2');
        apply eval_expr_Ederef_load in Hbase2';
        destruct Hbase2' as (lb2 & ob2 & bfb2 & Hlvb2 & _);
        apply eval_lvalue_Ederef_base in Hlvb2;
        apply eval_expr_Etempvar_val in Hlvb2
    end.
    pose proof Hlvb2 as Hm0.
    rewrite PTree.gso in Hm0
      by (intro EE; rewrite EE, Pos.eqb_refl in Htm; discriminate Htm).
    destruct (Htat _ _ Hm0) as [F1 F2]. subst lb2 ob2.
    match goal with
    | Hlv2 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc2 ?ofs2 ?bf2 |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    loc2 ofs2 bf2 _ _ _ Hlvb2 input_field_off Hlv2)
          as (F3 & F4 & F5);
        subst loc2 ofs2 bf2
    end.
    (* the rhs: (loaded v) | c *)
    match goal with
    | Hev2 : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
        inv Hev2;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
                 inv Hlv3 end)
    end.
    match goal with
    | Hev3 : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hev3;
        rewrite PTree.gss in Hev3; injection Hev3 as Ev1; subst
    end.
    match goal with
    | Hev4 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hev4;
        try (match goal with
             | Hlv4 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv4 end)
    end.
    match goal with
    | Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        rename Hsem into HsemOr
    end.
    (* the or_temp_vint recipe (AGates): unfold the binarith pipeline,
       destruct the operand, reduce the classifiers *)
    unfold sem_binary_operation, sem_or, sem_binarith, sem_cast in HsemOr.
    match type of HldInput with
    | Mem.load _ _ _ _ = Some ?vv =>
        destruct vv as [ | vi | | | | bv ov ];
        cbn [classify_binarith binarith_type classify_cast cast_int_int]
          in HsemOr;
        try discriminate HsemOr;
        injection HsemOr as Eres; subst
    end.
    (* the assign cast: i32 -> u16 zero-extends *)
    match goal with
    | Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
        cbn in Hcast; injection Hcast as Ecast; subst
    end.
    (* the store at (bm,2): inv self-discharges By_copy (concrete
       access_mode) *)
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m2 |- _ => inv Has
    end.
    match goal with
    | Hac : access_mode _ = By_value _ |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hsv : Mem.storev _ _ _ _ = Some m2 |- _ =>
        unfold Mem.storev in Hsv;
        change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 2)))
          with 2 in Hsv
    end.
    (* the A-clear chain *)
    assert (Hvi2 : Int.and vi (Int.repr 2) = Int.zero)
      by exact (HMWF_inp _ _ HM HldInput).
    generalize (Int.eq_spec (Int.and c (Int.repr 2)) Int.zero);
      rewrite Hcclr; intro Hc2.
    assert (Hor2 : Int.and (Int.or vi c) (Int.repr 2) = Int.zero).
    { rewrite Int.and_commut, Int.and_or_distrib.
      rewrite (Int.and_commut (Int.repr 2) vi),
              (Int.and_commut (Int.repr 2) c).
      rewrite Hvi2, Hc2. apply Int.or_zero. }
    assert (Hst2 : Int.and (Int.zero_ext 16 (Int.or vi c)) (Int.repr 2)
                   = Int.zero)
      by (rewrite inp_and2_zero_ext16; exact Hor2).
    match goal with
    | Hsv : Mem.store _ _ _ _ _ = Some m2 |- _ =>
        split; [ eauto using Mem.store_valid_block_1 | ];
        split;
        [ intros av Hload;
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (HS av Hload) | right; right; cbn; lia ]
        | ];
        split; [ exact (HMWF_input _ _ _ HM Hst2 Hsv) | ];
        split; [ exact (HNoA_of_MWF _ (HMWF_input _ _ _ HM Hst2 Hsv)) | ]
    end.
    intros t0 Hne. rewrite PTree.gso by exact Hne. reflexivity.
  Qed.

  (* ---- THE HYBRID WALKER ---- *)
  Lemma ioms_pres :
    forall (ids xids sids oids qids : list ident),
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' oids = true ->
                    call_pres_ob lp bm NoA MWF SafeB fid') ->
      (forall fid', mem_id fid' qids = true ->
                    call_pres_io lp bm NoA MWF SafeB fid') ->
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g ids = true -> e ! g = None) ->
      (forall g, mem_id g xids = true -> e ! g = None) ->
      (forall g, mem_id g sids = true -> e ! g = None) ->
      (forall g, mem_id g oids = true -> e ! g = None) ->
      (forall g, mem_id g qids = true -> e ! g = None) ->
      e ! interaction._determine_knockback_action = None ->
      e ! interaction._drop_and_set_mario_action = None ->
      e ! interaction._take_damage_and_knock_back = None ->
      e ! interaction._gGlobalTimer = None ->
      ioms_chk ids xids sids oids qids s = true ->
      (forall b o, le ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB tdaknb_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! interaction._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB tdaknb_cact le'.
  Proof.
    intros ids xids sids oids qids Hcp_i Hcpx_i Hcps_i Hcpo_i Hcpq_i
           s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hub_s Hub_o Hub_q Hub_dka Hub_dasma Hub_tk Hubgt Hchk
             Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sassign: generic only *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ioms_sp_chk ioms_ob_chk ioms_io_chk orb] in Hsp; discriminate Hsp ].
      eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic only *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ioms_sp_chk ioms_ob_chk ioms_io_chk orb] in Hsp; discriminate Hsp ].
      eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall: generic or THE tdaknb site *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                  Htat Hact Hch HN HM HV HS);
          eapply exec_Scall; eauto. }
      (* || is LEFT-assoc: (sp || ob) || io *)
      apply orb_true_iff in Hsp as [Hsp | Hio].
      2:{ (* the io site *)
              destruct (ioms_io_decode _ _ _ _ Hio)
                as (fid2 & ty2x & rty2 & cc2 & a2x & Ea & Eal & Hmem2
                    & Hopt2).
              subst a al.
              assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                              (Scall optid
                                 (Evar fid2
                                    (Tfunction
                                       (tyMSi :: ty2x :: tyObjI :: nil)
                                       rty2 cc2))
                                 (Etempvar interaction._m tyMSi :: a2x
                                  :: Etempvar interaction._o tyObjI
                                  :: nil))
                              t (set_opttemp optid vres le) m' Out_normal)
                by (eapply exec_Scall; eauto).
              pose proof (io_scall_pres _ Hcpq_i optid fid2 ty2x rty2 cc2
                            a2x e le m _ _ _ _ Hmem2 (Hub_q _ Hmem2) Hex
                            Htat
                            (fun b o Hg' =>
                               Hch interaction._o eq_refl b o Hg')
                            (conj HV (conj HS (conj HM HN))))
                as (HV' & HS' & HM' & HN').
              refine (conj HV' (conj HS' (conj HM' (conj HN'
                        (conj _ (conj _ _)))))).
              + intros b o Hg. destruct optid as [t1|];
                  cbn [set_opttemp] in Hg.
                * unfold tdaknb_tmp_ok in Hopt2.
                  apply andb_true_iff in Hopt2 as [Ht1m Ht1o].
                  apply negb_true_iff in Ht1m.
                  rewrite PTree.gso in Hg
                    by (intro EE; rewrite EE, Pos.eqb_refl in Ht1m;
                        discriminate Ht1m).
                  exact (Htat b o Hg).
                * exact (Htat b o Hg).
              + intros t' HH x Hg'. discriminate HH.
              + intros t' Hmem' b o Hg'.
                unfold tdaknb_cact, mem_id in Hmem';
                  cbn [existsb] in Hmem'.
                apply orb_true_iff in Hmem' as [E | F];
                  [ | discriminate F ].
                apply Pos.eqb_eq in E; subst t'.
                destruct optid as [t1|]; cbn [set_opttemp] in Hg'.
                * unfold tdaknb_tmp_ok in Hopt2.
                  apply andb_true_iff in Hopt2 as [Ht1m Ht1o].
                  apply negb_true_iff in Ht1o.
                  rewrite PTree.gso in Hg'
                    by (intro EE; rewrite EE, Pos.eqb_refl in Ht1o;
                        discriminate Ht1o).
                  exact (Hch interaction._o eq_refl b o Hg').
                * exact (Hch interaction._o eq_refl b o Hg'). }
      apply orb_true_iff in Hsp as [Hsp | Hob].
      2:{ (* the ob site *)
          destruct (ioms_ob_decode _ _ _ _ Hob)
            as (fid2 & tyl2 & rty2 & cc2 & rest2 & Ea & Eal & Hmem2 & Hopt2).
          subst a al.
          assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                          (Scall optid
                             (Evar fid2
                                (Tfunction (tyObjI :: tyl2) rty2 cc2))
                             (Etempvar interaction._o tyObjI :: rest2))
                          t (set_opttemp optid vres le) m' Out_normal)
            by (eapply exec_Scall; eauto).
          pose proof (ob_scall_pres _ Hcpo_i optid fid2 tyl2 rty2 cc2 rest2
                        e le m _ _ _ _ Hmem2 (Hub_o _ Hmem2) Hex
                        (fun b o Hg' => Hch interaction._o eq_refl b o Hg')
                        (conj HV (conj HS (conj HM HN))))
            as (HV' & HS' & HM' & HN').
          refine (conj HV' (conj HS' (conj HM' (conj HN'
                    (conj _ (conj _ _)))))).
          + intros b o Hg. destruct optid as [t1|];
              cbn [set_opttemp] in Hg.
            * unfold tdaknb_tmp_ok in Hopt2.
              apply andb_true_iff in Hopt2 as [Ht1m Ht1o].
              apply negb_true_iff in Ht1m.
              rewrite PTree.gso in Hg
                by (intro EE; rewrite EE, Pos.eqb_refl in Ht1m;
                    discriminate Ht1m).
              exact (Htat b o Hg).
            * exact (Htat b o Hg).
          + intros t' HH x Hg'. discriminate HH.
          + intros t' Hmem' b o Hg'.
            unfold tdaknb_cact, mem_id in Hmem'; cbn [existsb] in Hmem'.
            apply orb_true_iff in Hmem' as [E | F]; [ | discriminate F ].
            apply Pos.eqb_eq in E; subst t'.
            destruct optid as [t1|]; cbn [set_opttemp] in Hg'.
            * unfold tdaknb_tmp_ok in Hopt2.
              apply andb_true_iff in Hopt2 as [Ht1m Ht1o].
              apply negb_true_iff in Ht1o.
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Ht1o;
                    discriminate Ht1o).
              exact (Hch interaction._o eq_refl b o Hg').
            * exact (Hch interaction._o eq_refl b o Hg'). }
      destruct (ioms_sp_decode _ _ _ Hsp)
        as (t1 & Eopt & Ea & Eal & Ht1).
      subst optid a al.
      apply andb_true_iff in Ht1 as [Ht1m Ht1o].
      apply negb_true_iff in Ht1m. apply negb_true_iff in Ht1o.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall (Some t1)
                         (Evar interaction._take_damage_and_knock_back
                            (Tfunction (tyMSi :: tyObjI :: nil) tuint
                               cc_default))
                         (Etempvar interaction._m tyMSi
                          :: Etempvar interaction._o tyObjI :: nil))
                      t (set_opttemp (Some t1) vres le) m' Out_normal)
        by (eapply exec_Scall; eauto).
      destruct (ms_scall_pres t1 e le m _ _ _ _
                  Hub_tk Hex Htat
                  (fun b o Hg => Hch interaction._o eq_refl b o Hg)
                  (conj HV (conj HS (conj HM HN))))
        as (Hc' & _ & Hfr).
      destruct Hc' as (HV' & HS' & HM' & HN').
      assert (Hne_m1 : interaction._m <> t1)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht1m;
            discriminate Ht1m).
      assert (Hne_o1 : interaction._o <> t1)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht1o;
            discriminate Ht1o).
      refine (conj HV' (conj HS' (conj HM' (conj HN'
                (conj _ (conj _ _)))))).
      + intros b o Hg. rewrite (Hfr _ Hne_m1) in Hg.
        exact (Htat b o Hg).
      + intros t' HH x Hg'. discriminate HH.
      + intros t' Hmem' b o Hg'.
        unfold tdaknb_cact, mem_id in Hmem'; cbn [existsb] in Hmem'.
        apply orb_true_iff in Hmem' as [E | F]; [ | discriminate F ].
        apply Pos.eqb_eq in E; subst t'.
        rewrite (Hfr _ Hne_o1) in Hg'.
        exact (Hch interaction._o eq_refl b o Hg').
    - (* Sbuiltin *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [wwalk_chk'] in Hg; discriminate Hg
        | cbn [ioms_sp_chk ioms_ob_chk ioms_io_chk orb] in Hsp; discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrec].
      { eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                  Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      (* || is LEFT-assoc: (iodp || inp) || (rec && rec) *)
      apply orb_true_iff in Hrec as [Hsp | Hrec].
      2:{ apply andb_prop in Hrec as [H1 H2].
          destruct (IHHexec1 Hub_g Hub_i Hub_x Hub_s Hub_o Hub_q
                      Hub_dka Hub_dasma
                      Hub_tk Hubgt H1 Htat Hact Hch HN HM HV HS)
            as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
          exact (IHHexec2 Hub_g Hub_i Hub_x Hub_s Hub_o Hub_q
                   Hub_dka Hub_dasma
                   Hub_tk Hubgt H2 Htat1 Hact1 Hch1 HN1 HM1 HV1
                   HS1). }
      apply orb_true_iff in Hsp as [Hsp | Hinp].
      2:{ (* THE INPUT-OR PAIR *)
          destruct (ioms_inp_decode _ _ Hinp)
            as (q & c0 & Es1 & Es2 & Hqok & Hcclr).
          subst s1 s2.
          destruct (inp_pair_pres q c0 e le m _ _ _ _ _ _ _ _
                      Hqok Hcclr Hexec1 Hexec2 Htat HN HM HV HS)
            as (HV' & HS' & HM' & HN' & Hfr).
          unfold tdaknb_tmp_ok in Hqok.
          apply andb_true_iff in Hqok as [Hqm Hqo].
          apply negb_true_iff in Hqm. apply negb_true_iff in Hqo.
          assert (Hne_m : interaction._m <> q)
            by (intro EE; rewrite <- EE, Pos.eqb_refl in Hqm;
                discriminate Hqm).
          assert (Hne_o : interaction._o <> q)
            by (intro EE; rewrite <- EE, Pos.eqb_refl in Hqo;
                discriminate Hqo).
          refine (conj HV' (conj HS' (conj HM' (conj HN'
                    (conj _ (conj _ _)))))).
          + intros b o Hg. rewrite (Hfr _ Hne_m) in Hg.
            exact (Htat b o Hg).
          + intros t' HH x Hg'. discriminate HH.
          + intros t' Hmem' b o Hg'.
            unfold tdaknb_cact, mem_id in Hmem'; cbn [existsb] in Hmem'.
            apply orb_true_iff in Hmem' as [E | F]; [ | discriminate F ].
            apply Pos.eqb_eq in E; subst t'.
            rewrite (Hfr _ Hne_o) in Hg'.
            exact (Hch interaction._o eq_refl b o Hg'). }
      (* THE SNUFIT PAIR: (Sset q7; q1 := dka(m,q7));
                          (Sset q6; q2 := dasma(m,q1,q6)) *)
      destruct (iodp_sp_decode _ _ Hsp)
        as (q7 & qa7 & q1 & q6 & qa6 & q2 & Es1 & Es2
            & Ht7 & Ht1 & Ht6 & Ht2 & Hne61).
      subst s1 s2.
      apply andb_true_iff in Ht7 as [Ht7m Ht7o].
      apply negb_true_iff in Ht7m. apply negb_true_iff in Ht7o.
      apply andb_true_iff in Ht1 as [Ht1m Ht1o].
      apply negb_true_iff in Ht1m. apply negb_true_iff in Ht1o.
      apply andb_true_iff in Ht6 as [Ht6m Ht6o].
      apply negb_true_iff in Ht6m. apply negb_true_iff in Ht6o.
      apply andb_true_iff in Ht2 as [Ht2m Ht2o].
      apply negb_true_iff in Ht2m. apply negb_true_iff in Ht2o.
      (* s1: invert (Sset q7; Scall q1 dka) *)
      inv Hexec1.
      2:{ match goal with
          | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o1,
            Hne : ?o1 <> Out_normal |- _ => inv Hs; congruence
          end. }
      match goal with
      | Hs : exec_stmt _ _ _ _ _ (Sset q7 qa7) _ _ _ _ |- _ =>
          rename Hs into HSet end.
      match goal with
      | Hs : exec_stmt _ _ _ _ _ (Scall (Some q1) _ _) _ _ _ _ |- _ =>
          rename Hs into HCallD end.
      inv HSet.
      assert (Htat_a : forall b o,
                 (PTree.set q7 v le) ! interaction._m = Some (Vptr b o) ->
                 b = bm /\ o = Ptrofs.zero).
      { intros b o Hg.
        rewrite PTree.gso in Hg
          by (intro EE; rewrite EE, Pos.eqb_refl in Ht7m;
              discriminate Ht7m).
        exact (Htat b o Hg). }
      destruct (cp2_scall_ret_act_pres lp bm NoA MWF q1
                  interaction._determine_knockback_action
                  (tint :: nil) tuint cc_default
                  (Etempvar q7 tint :: nil)
                  e (PTree.set q7 v le) _ _ _ _ _
                  Hub_dka HCallD Hcpra_dka Htat_a
                  (conj HV (conj HS (conj HM HN))))
        as (Hc1 & _ & Hu2 & Hfr2).
      destruct Hc1 as (HV1 & HS1 & HM1 & HN1).
      assert (Hne_m1 : interaction._m <> q1)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht1m;
            discriminate Ht1m).
      assert (Hne_o1 : interaction._o <> q1)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht1o;
            discriminate Ht1o).
      (* s2: invert (Sset q6; Scall q2 dasma) *)
      inv Hexec2.
      2:{ match goal with
          | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o1,
            Hne : ?o1 <> Out_normal |- _ => inv Hs; congruence
          end. }
      match goal with
      | Hs : exec_stmt _ _ _ _ _ (Sset q6 qa6) _ _ _ _ |- _ =>
          rename Hs into HSet2 end.
      match goal with
      | Hs : exec_stmt _ _ _ _ _ (Scall (Some q2) _ _) _ _ _ _ |- _ =>
          rename Hs into HCallA end.
      inv HSet2.
      match type of HCallA with
      | exec_stmt _ _ _ ?lec _ _ _ _ _ _ =>
          assert (Htat_c : forall b o,
                     lec ! interaction._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero)
            by (intros b o Hg;
                rewrite PTree.gso in Hg
                  by (intro EE; rewrite EE, Pos.eqb_refl in Ht6m;
                      discriminate Ht6m);
                rewrite (Hfr2 _ Hne_m1) in Hg;
                exact (Htat_a b o Hg));
          assert (Hq_c : forall x,
                     lec ! q1 = Some x -> untainted_scalar x)
            by (intros x Hg;
                rewrite PTree.gso in Hg
                  by (intro EE; rewrite EE, Pos.eqb_refl in Hne61;
                      discriminate Hne61);
                exact (Hu2 x Hg))
      end.
      destruct (kit_scallw_pres lp bm NoA MWF q2
                  interaction._drop_and_set_mario_action
                  tuint (tuint :: nil) tint cc_default
                  q1 tuint (Etempvar q6 tint :: nil)
                  e _ _ _ _ _ _
                  Hub_dasma HCallA Hcpa_dasma eq_refl eq_refl
                  Htat_c Hq_c HN1 HM1 HV1 HS1)
        as (HV' & HS' & HM' & HN' & _ & Hu3 & Hfr3).
      assert (Hne_m2 : interaction._m <> q2)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht2m;
            discriminate Ht2m).
      assert (Hne_o2 : interaction._o <> q2)
        by (intro EE; rewrite <- EE, Pos.eqb_refl in Ht2o;
            discriminate Ht2o).
      refine (conj HV' (conj HS' (conj HM' (conj HN'
                (conj _ (conj _ _)))))).
      + intros b o Hg. rewrite (Hfr3 _ Hne_m2) in Hg.
        exact (Htat_c b o Hg).
      + intros t' HH x Hg'. discriminate HH.
      + intros t' Hmem' b o Hg'.
        unfold tdaknb_cact, mem_id in Hmem'; cbn [existsb] in Hmem'.
        apply orb_true_iff in Hmem' as [E | F]; [ | discriminate F ].
        apply Pos.eqb_eq in E; subst t'.
        rewrite (Hfr3 _ Hne_o2) in Hg'.
        rewrite PTree.gso in Hg'
          by (intro EE; rewrite EE, Pos.eqb_refl in Ht6o;
              discriminate Ht6o).
        rewrite (Hfr2 _ Hne_o1) in Hg'.
        rewrite PTree.gso in Hg'
          by (intro EE; rewrite EE, Pos.eqb_refl in Ht7o;
              discriminate Ht7o).
        exact (Hch interaction._o eq_refl b o Hg').
    - (* Sseq_2 *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrec].
      { eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                  Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      (* || is LEFT-assoc: (iodp || inp) || (rec && rec) *)
      apply orb_true_iff in Hrec as [Hsp | Hrec].
      2:{ apply andb_prop in Hrec as [H1 _].
          exact (IHHexec Hub_g Hub_i Hub_x Hub_s Hub_o Hub_q
                   Hub_dka Hub_dasma
                   Hub_tk Hubgt H1 Htat Hact Hch HN HM HV HS). }
      apply orb_true_iff in Hsp as [Hsp | Hinp].
      2:{ (* the inp pair's s1 is an Sset: always Out_normal *)
          destruct (ioms_inp_decode _ _ Hinp)
            as (q & c0 & Es1 & _).
          subst s1. exfalso. inv Hexec. congruence. }
      (* the pair's s1 (Sset; Scall) always exits Out_normal *)
      destruct (iodp_sp_decode _ _ Hsp)
        as (q7 & qa7 & q1 & q6 & qa6 & q2 & Es1 & Es2 & _).
      subst s1.
      exfalso. inv Hexec.
      + match goal with
        | Hs : exec_stmt _ _ _ _ _ (Scall (Some q1) _ _) _ _ _ ?oo,
          Hne : ?oo <> Out_normal |- _ => inv Hs; congruence
        end.
      + match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?oo,
          Hne : ?oo <> Out_normal |- _ => inv Hs; congruence
        end.
    - (* Sifthenelse *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrec].
      { eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                  Htat Hact Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hrec as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sloop stop1: generic only *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ioms_sp_chk ioms_ob_chk ioms_io_chk orb] in Hsp; discriminate Hsp ].
      eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ioms_sp_chk ioms_ob_chk ioms_io_chk orb] in Hsp; discriminate Hsp ].
      eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ioms_sp_chk ioms_ob_chk ioms_io_chk orb] in Hsp; discriminate Hsp ].
      eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic only *)
      cbn [ioms_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ioms_sp_chk ioms_ob_chk ioms_io_chk orb] in Hsp; discriminate Hsp ].
      eapply (ioms_generic ids xids sids Hcp_i Hcpx_i Hcps_i _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hub_s Hubgt Hg
                Htat Hact Hch HN HM HV HS);
        eapply exec_Sswitch; eauto.
  Qed.

  (* ---- the two handler producers (body_pres_io entry, 3 params) ---- *)
  Lemma ioms_body_pres :
    forall (f : Clight.function) (ids xids sids oids qids : list ident),
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' oids = true ->
                    call_pres_ob lp bm NoA MWF SafeB fid') ->
      (forall fid', mem_id fid' qids = true ->
                    call_pres_io lp bm NoA MWF SafeB fid') ->
      fn_vars f = nil ->
      fn_params f
      = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
        :: (interaction._interactType, tuint)
        :: (interaction._o, tptr (Tstruct interaction._Object noattr))
        :: nil ->
      ioms_chk ids xids sids oids qids (fn_body f) = true ->
      body_pres_io lp bm NoA MWF SafeB f.
  Proof.
    intros f ids xids sids oids qids Hcp_i Hcpx_i Hcps_i Hcpo_i Hcpq_i Hvars Hps Hchk
           m0 vm vi vo t0 m1 vres0 Hvm Hvo Hevf
           HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite Hvars in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite Hps in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as Hle1.
    assert (Htat0 : forall b o,
               le1 ! interaction._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite <- Hle1 in Hg.
      rewrite PTree.gso in Hg by (vm_compute; discriminate).
      rewrite PTree.gso in Hg by (vm_compute; discriminate).
      rewrite PTree.gss in Hg. injection Hg as ->.
      exact (Hvm b o eq_refl). }
    assert (Hch0 : chase_inv SafeB tdaknb_cact le1).
    { intros t' Hmem' b o Hg'.
      unfold tdaknb_cact, mem_id in Hmem'; cbn [existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [E | F]; [ | discriminate F ].
      apply Pos.eqb_eq in E; subst t'.
      rewrite <- Hle1 in Hg'. rewrite PTree.gss in Hg'.
      injection Hg' as ->.
      exact (Hvo b o eq_refl). }
    assert (Hact0 : act_inv nil le1)
      by (intros t' HH x Hg'; discriminate HH).
    match type of Hbody with
    | exec_stmt _ _ _ _ ?mm _ _ _ _ _ => idtac
    end.
    destruct (ioms_pres ids xids sids oids qids Hcp_i Hcpx_i Hcps_i
                Hcpo_i Hcpq_i
                _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) (PTree.gempty _ _)
                (PTree.gempty _ _) (PTree.gempty _ _)
                Hchk Htat0 Hact0 Hch0 HN HM HV HS)
      as (HV' & HS' & HM' & _ & _ & _ & _).
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact (conj HV' (conj HS' HM')).
  Qed.

  (* the vars-tolerant twin: ONE dead stack local (the u8[4] filler) --
     entry alloc preserves carried (alloc_variables_carried), the env
     binds ONLY the filler so every census ident stays globally resolved
     (alloc_variables_unbound + the forallb-ne census check), and the
     exit free_list of the fresh frame preserves carried
     (blocks_of_env_bm + free_list_carried_bm). *)
  Lemma ioms_body_pres_dv :
    forall (f : Clight.function) (ids xids sids oids qids : list ident),
      (forall fid', mem_id fid' ids = true ->
                    call_pres lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' xids = true ->
                    call_pres_ext lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' sids = true ->
                    call_pres_act lp bm NoA MWF fid') ->
      (forall fid', mem_id fid' oids = true ->
                    call_pres_ob lp bm NoA MWF SafeB fid') ->
      (forall fid', mem_id fid' qids = true ->
                    call_pres_io lp bm NoA MWF SafeB fid') ->
      fn_vars f = (io_filler, Tarray tuchar 4 noattr) :: nil ->
      fn_params f
      = (interaction._m, tptr (Tstruct interaction._MarioState noattr))
        :: (interaction._interactType, tuint)
        :: (interaction._o, tptr (Tstruct interaction._Object noattr))
        :: nil ->
      forallb (fun fid => negb (Pos.eqb fid io_filler))
        (stored_globals ++ ids ++ xids ++ sids ++ oids ++ qids) = true ->
      ioms_chk ids xids sids oids qids (fn_body f) = true ->
      body_pres_io lp bm NoA MWF SafeB f.
  Proof.
    intros f ids xids sids oids qids Hcp_i Hcpx_i Hcps_i Hcpo_i Hcpq_i
           Hvars Hps Hne Hchk
           m0 vm vi vo t0 m1 vres0 Hvm Hvo Hevf
           HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite Hvars in Ha; rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite Hps in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as Hle1.
    (* entry: the stack alloc preserves the carried facts *)
    destruct (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                _ _ _ _ _ _ Halloc
                (conj HV (conj HS (conj HM HN))))
      as (HVe & HSe & HMe & HNe).
    (* env: only the dead filler is bound *)
    match type of Halloc with
    | alloc_variables _ _ _ _ ?E _ => set (eloc := E) in *
    end.
    assert (Hub_one : forall g, Pos.eqb g io_filler = false ->
                                eloc ! g = None).
    { intros g Hneg.
      rewrite (alloc_variables_unbound _ _ _ _ _ _ Halloc g)
        by (cbn [map fst In]; intros [HH | HH];
            [ rewrite <- HH, Pos.eqb_refl in Hneg; discriminate Hneg
            | exact HH ]).
      apply PTree.gempty. }
    rewrite !forallb_app in Hne.
    apply andb_true_iff in Hne as [Hne_sg Hne].
    apply andb_true_iff in Hne as [Hne_ids Hne].
    apply andb_true_iff in Hne as [Hne_xids Hne].
    apply andb_true_iff in Hne as [Hne_sids Hne].
    apply andb_true_iff in Hne as [Hne_oids Hne_qids].
    assert (Htat0 : forall b o,
               le1 ! interaction._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite <- Hle1 in Hg.
      rewrite PTree.gso in Hg by (vm_compute; discriminate).
      rewrite PTree.gso in Hg by (vm_compute; discriminate).
      rewrite PTree.gss in Hg. injection Hg as ->.
      exact (Hvm b o eq_refl). }
    assert (Hch0 : chase_inv SafeB tdaknb_cact le1).
    { intros t' Hmem' b o Hg'.
      unfold tdaknb_cact, mem_id in Hmem'; cbn [existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [E | F]; [ | discriminate F ].
      apply Pos.eqb_eq in E; subst t'.
      rewrite <- Hle1 in Hg'. rewrite PTree.gss in Hg'.
      injection Hg' as ->.
      exact (Hvo b o eq_refl). }
    assert (Hact0 : act_inv nil le1)
      by (intros t' HH x Hg'; discriminate HH).
    destruct (ioms_pres ids xids sids oids qids Hcp_i Hcpx_i Hcps_i
                Hcpo_i Hcpq_i
                _ _ _ _ _ _ _ _ Hbody
                (fun g Hg =>
                   Hub_one g (mem_id_forallb_ne _ _ _ Hne_sg Hg))
                (fun g Hg =>
                   Hub_one g (mem_id_forallb_ne _ _ _ Hne_ids Hg))
                (fun g Hg =>
                   Hub_one g (mem_id_forallb_ne _ _ _ Hne_xids Hg))
                (fun g Hg =>
                   Hub_one g (mem_id_forallb_ne _ _ _ Hne_sids Hg))
                (fun g Hg =>
                   Hub_one g (mem_id_forallb_ne _ _ _ Hne_oids Hg))
                (fun g Hg =>
                   Hub_one g (mem_id_forallb_ne _ _ _ Hne_qids Hg))
                (Hub_one interaction._determine_knockback_action eq_refl)
                (Hub_one interaction._drop_and_set_mario_action eq_refl)
                (Hub_one interaction._take_damage_and_knock_back eq_refl)
                (Hub_one interaction._gGlobalTimer eq_refl)
                Hchk Htat0 Hact0 Hch0 HNe HMe HVe HSe)
      as (HV' & HS' & HM' & HN' & _ & _ & _).
    (* exit: free the fresh stack frame *)
    pose proof (blocks_of_env_bm lp bm _ _ _ _ Halloc HV) as Hforall.
    destruct (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                _ _ _ Hforall Hfree
                (conj HV' (conj HS' (conj HM' HN'))))
      as (HVf & HSf & HMf & _).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  Lemma io_mr_blizzard :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_mr_blizzard.
  Proof.
    exact (ioms_body_pres interaction.f_interact_mr_blizzard
             nil nil nil nil nil
             (fun fid HH => match Bool.diff_false_true HH with end)
             (fun fid HH => match Bool.diff_false_true HH with end)
             (fun fid HH => match Bool.diff_false_true HH with end)
             (fun fid HH => match Bool.diff_false_true HH with end)
             (fun fid HH => match Bool.diff_false_true HH with end)
             io_mrb_vars io_mrb_params ioms_mrb_walk).
  Qed.

  Lemma io_damage :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_damage.
  Proof.
    exact (ioms_body_pres interaction.f_interact_damage
             nil nil nil nil nil
             (fun fid HH => match Bool.diff_false_true HH with end)
             (fun fid HH => match Bool.diff_false_true HH with end)
             (fun fid HH => match Bool.diff_false_true HH with end)
             (fun fid HH => match Bool.diff_false_true HH with end)
             (fun fid HH => match Bool.diff_false_true HH with end)
             io_dmg_vars io_dmg_params ioms_dmg_walk).
  Qed.

  Lemma io_clam_or_bubba :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_clam_or_bubba.
  Proof.
    apply (ioms_body_pres interaction.f_interact_clam_or_bubba
             nil nil (interaction._set_mario_action :: nil) nil nil).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact io_cl_vars.
    - exact io_cl_params.
    - exact ioms_cl_walk.
  Qed.

  Lemma io_snufit_bullet :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_snufit_bullet.
  Proof.
    apply (ioms_body_pres interaction.f_interact_snufit_bullet
             (interaction._take_damage_from_interact_object
              :: interaction._update_mario_sound_and_camera :: nil)
             (interaction._play_sound :: nil)
             (interaction._drop_and_set_mario_action :: nil) nil nil).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_tdfio | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_dasma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact io_sn_vars.
    - exact io_sn_params.
    - exact ioms_sn_walk.
  Qed.

  Lemma io_warp :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_warp.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_warp
             nil (interaction._mario_stop_riding_object :: nil) nil
             (interaction._o :: nil)
             (interaction._play_sound
              :: interaction._segmented_to_virtual :: nil)
             (interaction._set_mario_action :: nil) nil
             io_wa_vars io_wa_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msro
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid';
          exact Hcpx_s2v_io
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_wa_walk.
  Qed.

  Lemma io_coin :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_coin.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_coin
             nil nil nil (interaction._o :: nil)
             (interaction._bhv_spawn_star_no_level_exit :: nil) nil nil
             io_co_vars io_co_params eq_refl eq_refl).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_bssnle
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact io_co_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE 4: the eight pure-engine handlers.  Each is the water_ring    *)
  (* pattern -- body_pres_io_of_wwalk + the per-handler censuses; the    *)
  (* row dischargers map each censused callee to its section row.        *)
  (* ================================================================== *)

  Lemma io_cannon_base :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_cannon_base.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_cannon_base
             nil (interaction._mario_stop_riding_and_holding :: nil) nil
             (interaction._o :: nil) nil
             (interaction._set_mario_action :: nil) nil
             io_cb_vars io_cb_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_cb_walk.
  Qed.

  Lemma io_bbh_entrance :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_bbh_entrance.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_bbh_entrance
             nil (interaction._mario_stop_riding_and_holding :: nil) nil
             (interaction._o :: nil) nil
             (interaction._set_mario_action :: nil) nil
             io_bbh_vars io_bbh_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_bbh_walk.
  Qed.

  Lemma io_strong_wind :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_strong_wind.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_strong_wind
             nil (interaction._mario_stop_riding_and_holding
              :: interaction._update_mario_sound_and_camera :: nil) nil
             (interaction._o :: nil)
             (interaction._play_sound :: nil)
             (interaction._set_mario_action :: nil) nil
             io_sw_vars io_sw_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_sw_walk.
  Qed.

  Lemma io_whirlpool :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_whirlpool.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_whirlpool
             nil (interaction._mario_stop_riding_and_holding :: nil) nil
             (interaction._o :: interaction._marioObj :: nil)
             (interaction._play_sound :: nil)
             (interaction._set_mario_action :: nil) nil
             io_wp_vars io_wp_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_wp_walk.
  Qed.

  Lemma io_tornado :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_tornado.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_tornado
             nil (interaction._mario_stop_riding_and_holding
              :: interaction._update_mario_sound_and_camera
              :: interaction._mario_set_forward_vel :: nil) nil
             (interaction._o :: interaction._marioObj :: nil)
             (interaction._play_sound :: nil)
             (interaction._set_mario_action :: nil) nil
             io_tn_vars io_tn_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msfv
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_tn_walk.
  Qed.

  Lemma io_hoot :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_hoot.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_hoot
             nil (interaction._mario_stop_riding_and_holding
              :: interaction._update_mario_sound_and_camera :: nil) nil
             (interaction._o :: interaction._usedObj :: nil) nil
             (interaction._set_mario_action :: nil) nil
             io_ho_vars io_ho_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_ho_walk.
  Qed.

  Lemma io_shock :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_shock.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_shock
             nil (interaction._update_mario_sound_and_camera
              :: interaction._take_damage_from_interact_object :: nil) nil
             (interaction._o :: nil)
             (interaction._play_sound :: nil)
             (interaction._drop_and_set_mario_action :: nil) nil
             io_sh_vars io_sh_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_tdfio
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_dasma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_sh_walk.
  Qed.

  Lemma io_flame :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_flame.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_flame
             (interaction._burningAction :: nil)
             (interaction._update_mario_sound_and_camera :: nil) nil
             (interaction._o :: interaction._marioObj
              :: interaction._t'10 :: nil)
             (interaction._play_sound :: nil)
             (interaction._drop_and_set_mario_action :: nil) nil
             io_fl_vars io_fl_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_dasma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_fl_walk.
  Qed.

  (* ---- slice-5: the di / bba rows (walked internals consuming only
     EXISTING section rows: moato, msfv, play_sound, scsfh) and the
     unknown_08 handler (ioms walker: di + bba ids + the tdaknb ms
     special site). ---- *)
  Lemma di_row :
    call_pres lp bm NoA MWF interaction._determine_interaction.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._determine_interaction
             interaction.f_determine_interaction
             di_ids nil nil nil
             LO_int di_pin di_vars di_params_ok).
    - intros fid' H. unfold di_ids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcp_moato | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact di_walk.
  Qed.

  Lemma bba_row :
    call_pres lp bm NoA MWF interaction._bounce_back_from_attack.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._bounce_back_from_attack
             interaction.f_bounce_back_from_attack
             bba_ids nil bba_xids nil
             LO_int bba_pin bba_vars bba_params_ok).
    - intros fid' H. unfold bba_ids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcp_msfv | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold bba_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_ps | ].
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_scsfh | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact bba_walk.
  Qed.

  Lemma io_unknown_08 :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_unknown_08.
  Proof.
    apply (ioms_body_pres interaction.f_interact_unknown_08
             (interaction._determine_interaction
              :: interaction._bounce_back_from_attack :: nil)
             nil nil nil nil).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact di_row | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact bba_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact io_u08_vars.
    - exact io_u08_params.
    - exact ioms_u08_walk.
  Qed.

  Lemma spd_row :
    call_pres lp bm NoA MWF interaction._should_push_or_pull_door.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._should_push_or_pull_door
             interaction.f_should_push_or_pull_door
             nil nil spd_xids nil
             LO_int spd_pin spd_vars spd_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold spd_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_atan2s | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact spd_walk.
  Qed.

  Lemma io_warp_door :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_warp_door.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_warp_door
             io_wd_wact
             (interaction._should_push_or_pull_door :: nil) nil
             (interaction._o :: nil)
             (interaction._save_file_get_flags
              :: interaction._segmented_to_virtual :: nil)
             (interaction._set_mario_action :: nil) nil
             io_wd_vars io_wd_params eq_refl eq_refl).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact spd_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_sfgf | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_s2v_io
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_wd_walk.
  Qed.

  (* ---- the ob rows ---- *)
  Lemma ao_row :
    call_pres_ob lp bm NoA MWF SafeB interaction._attack_object.
  Proof.
    apply (call_pres_ob_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._attack_object
             interaction.f_attack_object
             interaction._o nil nil nil nil
             LO_int ao_pin ao_vars ao_params_ok ao_no_m).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact ao_walk.
  Qed.

  Lemma gmcf_row :
    call_pres_ob lp bm NoA MWF SafeB interaction._get_mario_cap_flag.
  Proof.
    apply (call_pres_ob_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._get_mario_cap_flag
             interaction.f_get_mario_cap_flag
             interaction._capObject nil nil gmcf_xids nil
             LO_int gmcf_pin gmcf_vars gmcf_params_ok gmcf_no_m).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold gmcf_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_v2seg_io | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact gmcf_walk.
  Qed.

  (* ---- the boo / hofb plain rows ---- *)
  Lemma boo_row :
    call_pres lp bm NoA MWF interaction._bounce_off_object.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._bounce_off_object
             interaction.f_bounce_off_object
             nil nil boo_xids nil
             LO_int boo_pin boo_vars boo_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold boo_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_ps | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact boo_walk.
  Qed.

  Lemma hofb_row :
    call_pres lp bm NoA MWF interaction._hit_object_from_below.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._hit_object_from_below
             interaction.f_hit_object_from_below
             nil nil hofb_xids nil
             LO_int hofb_pin hofb_vars hofb_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold hofb_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_scsfh | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact hofb_walk.
  Qed.

  (* ---- the bounce_top / door rows ---- *)
  Lemma rmp_row :
    call_pres lp bm NoA MWF interaction._reset_mario_pitch.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._reset_mario_pitch
             interaction.f_reset_mario_pitch
             nil nil rmp_xids nil
             LO_int rmp_pin rmp_vars rmp_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold rmp_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_scm | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact rmp_walk.
  Qed.

  Lemma gdsff_row :
    call_pres_ext lp bm NoA MWF interaction._get_door_save_file_flag.
  Proof.
    apply (call_pres_ext_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._get_door_save_file_flag
             interaction.f_get_door_save_file_flag
             nil nil gdsff_xids nil
             LO_int gdsff_pin gdsff_vars gdsff_no_m).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold gdsff_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_sfgf | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact gdsff_walk.
  Qed.

  Lemma io_bounce_top :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_bounce_top.
  Proof.
    apply (ioms_body_pres interaction.f_interact_bounce_top
             (interaction._determine_interaction
              :: interaction._bounce_back_from_attack
              :: interaction._bounce_off_object
              :: interaction._reset_mario_pitch :: nil)
             (interaction._play_sound :: nil)
             (interaction._drop_and_set_mario_action :: nil)
             (interaction._attack_object :: nil) nil).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact di_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact bba_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact boo_row | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact rmp_row
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_dasma
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact ao_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_bt_vars.
    - exact io_bt_params.
    - exact ioms_bt_walk.
  Qed.

  Lemma io_door :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_door.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_door
             io_door_wact io_door_ids nil
             (interaction._o :: nil) io_door_xids
             (interaction._set_mario_action :: nil) nil
             io_door_vars io_door_params eq_refl eq_refl).
    - intros fid' H. unfold io_door_ids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact spd_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold io_door_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_sfgf | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_sfgtsc | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact gdsff_row
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_door_walk.
  Qed.

  (* ---- pole (every callee row already exists: msrah hypothesis,
     rmp_row, the sma keystone) ---- *)
  Lemma io_pole :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_pole.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_pole
             nil io_pole_ids nil io_pole_cact nil
             (interaction._set_mario_action :: nil) nil
             io_pole_vars io_pole_params eq_refl eq_refl).
    - intros fid' H. unfold io_pole_ids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact rmp_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_pole_walk.
  Qed.

  (* ---- the three ob-unlocked handlers ---- *)
  Lemma io_cap :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_cap.
  Proof.
    apply (ioms_body_pres interaction.f_interact_cap
             nil
             (interaction._play_cap_music :: interaction._play_sound :: nil)
             (interaction._set_mario_action :: nil)
             (interaction._get_mario_cap_flag :: nil) nil).
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_pcm | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact gmcf_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_cap_vars.
    - exact io_cap_params.
    - exact ioms_cap_walk.
  Qed.

  Lemma io_koopa_shell :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_koopa_shell.
  Proof.
    apply (ioms_body_pres interaction.f_interact_koopa_shell
             (interaction._determine_interaction
              :: interaction._update_mario_sound_and_camera
              :: interaction._mario_drop_held_object
              :: interaction._push_mario_out_of_object :: nil)
             (interaction._play_shell_music :: nil)
             (interaction._set_mario_action :: nil)
             (interaction._attack_object :: nil) nil).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact di_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_mdho | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_pmoo
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_psm
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact ao_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_ks_vars.
    - exact io_ks_params.
    - exact ioms_ks_walk.
  Qed.

  Lemma io_breakable :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_breakable.
  Proof.
    apply (ioms_body_pres interaction.f_interact_breakable
             (interaction._determine_interaction
              :: interaction._bounce_back_from_attack
              :: interaction._bounce_off_object
              :: interaction._hit_object_from_below :: nil)
             nil
             (interaction._set_mario_action :: nil)
             (interaction._attack_object :: nil) nil).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact di_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact bba_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact boo_row | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact hofb_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact ao_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_brk_vars.
    - exact io_brk_params.
    - exact ioms_brk_walk.
  Qed.

  (* ---- the grabbable rows: two pure readers, the io-call row
     producer (a walked io-shaped body as a CALL row), the
     check_object_grab_mario row, and the handler itself ---- *)
  Lemma ofm_row :
    call_pres lp bm NoA MWF interaction._object_facing_mario.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._object_facing_mario
             interaction.f_object_facing_mario
             nil nil ofm_xids nil
             LO_int ofm_pin ofm_vars ofm_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold ofm_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_atan2s | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact ofm_walk.
  Qed.

  Lemma atgo_row :
    call_pres lp bm NoA MWF interaction._able_to_grab_object.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._able_to_grab_object
             interaction.f_able_to_grab_object
             nil nil nil nil
             LO_int atgo_pin atgo_vars atgo_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact atgo_walk.
  Qed.

  Lemma call_pres_io_of_body :
    forall fid f,
      (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres_io lp bm NoA MWF SafeB f ->
      call_pres_io lp bm NoA MWF SafeB fid.
  Proof.
    intros fid f Hpin Hbp fd m0 vm vi vo t0 m1 vres0 Hevf Hres Hvm Hvo
           HN HM HV HS.
    pose proof (resolve_pin_fd lp interaction.prog fid f fd
                  LO_int Hpin Hres) as ->.
    destruct (Hbp _ _ _ _ _ _ _ Hvm Hvo Hevf HN HM HV HS)
      as (HV' & HS' & HM').
    exact (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))).
  Qed.

  Lemma cogm_row :
    call_pres_io lp bm NoA MWF SafeB
      interaction._check_object_grab_mario.
  Proof.
    apply (call_pres_io_of_body interaction._check_object_grab_mario
             interaction.f_check_object_grab_mario cogm_pin).
    apply (ioms_body_pres interaction.f_check_object_grab_mario
             (interaction._object_facing_mario
              :: interaction._mario_stop_riding_and_holding
              :: interaction._update_mario_sound_and_camera
              :: interaction._push_mario_out_of_object :: nil)
             (interaction._play_sound :: nil)
             (interaction._set_mario_action :: nil) nil nil).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact ofm_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_pmoo
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cogm_vars.
    - exact cogm_params.
    - exact ioms_cogm_walk.
  Qed.

  Lemma io_grabbable :
    body_pres_io lp bm NoA MWF SafeB interaction.f_interact_grabbable.
  Proof.
    apply (ioms_body_pres interaction.f_interact_grabbable
             (interaction._determine_interaction
              :: interaction._bounce_back_from_attack
              :: interaction._push_mario_out_of_object
              :: interaction._able_to_grab_object :: nil)
             (interaction._virtual_to_segmented :: nil)
             nil
             (interaction._attack_object :: nil)
             (interaction._check_object_grab_mario :: nil)).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact di_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact bba_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_pmoo | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact atgo_row
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_v2seg_io
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact ao_row
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact cogm_row
        | discriminate F ].
    - exact io_grab_vars.
    - exact io_grab_params.
    - exact ioms_grab_walk.
  Qed.

  (* ---- star_or_key: wwalk + the wact temp-action channel ---- *)
  Lemma io_star_or_key :
    body_pres_io lp bm NoA MWF SafeB
      interaction.f_interact_star_or_key.
  Proof.
    apply (body_pres_io_of_wwalk interaction.f_interact_star_or_key
             io_sok_wact io_sok_ids nil
             (interaction._o :: nil) io_sok_xids
             (interaction._set_mario_action :: nil) nil
             io_sok_vars io_sok_params eq_refl eq_refl).
    - intros fid' H. unfold io_sok_ids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_msrah | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc
        | discriminate F ].
    - intros fid' H. discriminate H.
    - intros fid' H. unfold io_sok_xids in H. cbn [mem_id existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_sfgtsc | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_sfcsok | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_dqbm | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_flm | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_so
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_sok_walk.
  Qed.

  (* ---- hit_from_below: ioms walk + the DEAD-FILLER vars entry ---- *)
  Lemma io_hit_from_below :
    body_pres_io lp bm NoA MWF SafeB
      interaction.f_interact_hit_from_below.
  Proof.
    apply (ioms_body_pres_dv interaction.f_interact_hit_from_below
             (interaction._reset_mario_pitch
              :: interaction._determine_interaction
              :: interaction._bounce_back_from_attack
              :: interaction._update_mario_sound_and_camera
              :: interaction._push_mario_out_of_object
              :: interaction._hit_object_from_below
              :: interaction._bounce_off_object :: nil)
             (interaction._play_sound :: nil)
             (interaction._set_mario_action
              :: interaction._drop_and_set_mario_action :: nil)
             (interaction._attack_object :: nil)
             nil).
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact rmp_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact di_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact bba_row | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_umsc | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcp_pmoo | ].
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact hofb_row | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact boo_row
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpx_ps
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | H];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_sma | ].
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact Hcpa_dasma
        | discriminate F ].
    - intros fid' H. unfold mem_id in H; cbn [existsb] in H.
      apply Bool.orb_true_iff in H as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst fid'; exact ao_row
        | discriminate F ].
    - intros fid' H. discriminate H.
    - exact io_hfb_vars.
    - exact io_hfb_params.
    - vm_compute. reflexivity.
    - exact ioms_hfb_walk.
  Qed.

  (* ---- the handler-table dispatch splitter: the capstone's
     Hpres_ihandler from the walked handlers + the io_rest census. ---- *)
  Lemma ihandler_pres_split :
    (forall fid f, mem_id fid io_rest_ids = true ->
       (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
       body_pres_io lp bm NoA MWF SafeB f) ->
    forall fid f, In fid interaction_handler_ids ->
      (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres_io lp bm NoA MWF SafeB f.
  Proof.
    intros Hrest fid f Hin Hdm.
    cbn [interaction_handler_ids In] in Hin.
    repeat (destruct Hin as [<- | Hin];
            [ solve [ (eapply Hrest; [ | exact Hdm ]; reflexivity)
                    | (pose proof io_wr_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_water_ring)
                    | (pose proof io_ig_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_igloo)
                    | (pose proof io_mrb_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_mr_blizzard)
                    | (pose proof io_dmg_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_damage)
                    | (pose proof io_cb_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_cannon_base)
                    | (pose proof io_bbh_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_bbh_entrance)
                    | (pose proof io_sw_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_strong_wind)
                    | (pose proof io_wp_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_whirlpool)
                    | (pose proof io_tn_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_tornado)
                    | (pose proof io_ho_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_hoot)
                    | (pose proof io_sh_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_shock)
                    | (pose proof io_fl_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_flame)
                    | (pose proof io_cl_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_clam_or_bubba)
                    | (pose proof io_sn_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_snufit_bullet)
                    | (pose proof io_wa_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_warp)
                    | (pose proof io_co_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_coin)
                    | (pose proof io_u08_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_unknown_08)
                    | (pose proof io_wd_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_warp_door)
                    | (pose proof io_cap_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_cap)
                    | (pose proof io_ks_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_koopa_shell)
                    | (pose proof io_brk_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_breakable)
                    | (pose proof io_bt_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_bounce_top)
                    | (pose proof io_door_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_door)
                    | (pose proof io_pole_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_pole)
                    | (pose proof io_grab_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_grabbable)
                    | (pose proof io_hfb_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_hit_from_below)
                    | (pose proof io_sok_pin as E; rewrite Hdm in E;
                       injection E as ->; exact io_star_or_key) ]
            | ]).
    destruct Hin.
  Qed.

End IoSurface.
