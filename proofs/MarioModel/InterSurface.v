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
From SM64.Proofs Require ActWriterSurface.

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
