(* spine (via ObjFrame): OBJECTS phase S3 -- UcKit's recursive class walker extended
   with (a) Mario-state store arms pinned to listed cells and (b) a FRAME:
   every walked body changes memory only in SafeB blocks, blocks allocated
   during the walk, globals MWF does not read, and the listed Mario cells. *)
(* ====================================================================== *)
(* ObjWalk.v -- the extended walker (generic over the table).             *)
(*                                                                        *)
(* UcKit proves, for every body of a checked table, that it keeps the    *)
(* carried facts (UInv).  It cannot walk a body that stores into Mario's  *)
(* state (gMarioStates is a block MWF reads: class kA), nor a pointer     *)
(* store into a stored global.  This file re-proves UcKit's mutual        *)
(* induction with three more store arms and one more temp invariant:      *)
(*                                                                        *)
(*   MARIO TEMPS (mt)  temps whose every definition is the load of the    *)
(*                     gMarioState cell; MWF pins that cell to (bm, 0).  *)
(*   ms_store1         mt->fld := v      (any value; the field's cells     *)
(*                                        must lie in mcells and outside   *)
(*                                        MWF's protected windows)        *)
(*   ms_store2         gMarioStates[0].fld[k] := v  (float array element; *)
(*                                        same two checks)                *)
(*   sg_store          g := v for a stored global g (any value:           *)
(*                                        MWFReal.mwf_real_glob)          *)
(*                                                                        *)
(* and carries a FRAME conjunct through every statement and call:         *)
(*   FR m m' = Mem.unchanged_on (not FP) m m',                            *)
(*   FP b ofs = SafeB b \/ b >= nl \/ GBu b \/ (b = bm /\ MC ofs)         *)
(* (nl: the walk's starting nextblock; GBu: a global outside mwf_syms;    *)
(* MC: a Mario-cell predicate containing mcells).  The leaves must meet   *)
(* the same frame (xspec).                                                *)
(*                                                                        *)
(* S-LOCALS (sl_of f): pointer locals whose cell holds only SafeB         *)
(* pointers (or none), so a read-back `t := x` is kS, not kW.  Carried by  *)
(* SLI (per body) and XS nb0 m m' (every call: blocks in [nl, nb0) gain   *)
(* only SafeB pointers).  In a body with S-locals every store target is   *)
(* kS (or a Mario cell / stored global) and every call restarts (a clean  *)
(* callee with kfree parameter classes, run at nb1 = nextblock m), so a   *)
(* callee's XS at nb1 covers the S-locals.  This types                    *)
(* cur_obj_update_floor_height_and_get_floor's `floor` out-cell, filled   *)
(* by find_floor.                                                         *)
(*                                                                        *)
(* mcells (pinned below): Mario's pos[0], pos[2] (cur_obj_push_mario_away) *)
(* and numLives (bhv_1up_interact) -- the only Mario-state cells an       *)
(* object body stores to directly.  set_mario_npc_dialog's writes come    *)
(* through its leaf (GOAL 1's smact_pres row).                            *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario level_update.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit MathBodies
  LinkedTwelve LocalVarsSurface SpawnBodies MathGeomGated UcKit.
From SM64.Proofs Require CameraModeBody MtxfBody ObjHelpersBodies PrintBodies ObjExtBodies
  NpcDialogBody.

Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 1. The Mario cells and the extra recognizers.                            *)
(* ---------------------------------------------------------------------- *)

Definition mfo (fld : ident) : Z :=
  match field_offset (prog_comp_env mario.prog) fld mario_state_members with
  | OK (d, _) => d
  | Error _ => 0
  end.

(* (start, length): pos[0], pos[2] (push_mario_away), numLives (1up) *)
Definition pos_cells : list (Z * Z) := [(mfo mario._pos, 4); (mfo mario._pos + 8, 4)].
Definition lives_cells : list (Z * Z) := [(mfo mario._numLives, 1)].
Definition mcells : list (Z * Z) := pos_cells ++ lives_cells.

Lemma mcells_value : mcells = [(60, 4); (68, 4); (173, 1)].
Proof. vm_compute. reflexivity. Qed.

Definition in_mcells (cl : list (Z * Z)) (ofs : Z) : Prop :=
  exists c, In c cl /\ fst c <= ofs < fst c + snd c.

Definition cell_cover (cl : list (Z * Z)) (d sz : Z) : bool :=
  existsb (fun c => (fst c <=? d) && (d + sz <=? fst c + snd c)) cl.

Lemma cell_cover_sound : forall cl d sz, cell_cover cl d sz = true ->
    forall i, d <= i < d + sz -> in_mcells cl i.
Proof.
  intros cl d sz H i Hi. unfold cell_cover in H. apply existsb_exists in H as (c & Hin & Hc).
  apply andb_prop in Hc as [H1 H2]. apply Z.leb_le in H1. apply Z.leb_le in H2.
  exists c. split; [ exact Hin | lia ].
Qed.

Definition mcell_chk (cl : list (Z * Z)) (fld : ident) (fty : type) : bool :=
  match field_offset (prog_comp_env mario.prog) fld mario_state_members with
  | OK (delta, Full) =>
      match access_mode fty with
      | By_value ch => store_window_ok delta (size_chunk ch) && cell_cover cl delta (size_chunk ch)
      | _ => false
      end
  | _ => false
  end.

Lemma mcell_chk_sound : forall cl fld fty, mcell_chk cl fld fty = true ->
    exists delta ch,
      field_offset (prog_comp_env mario.prog) fld mario_state_members = OK (delta, Full)
      /\ access_mode fty = By_value ch
      /\ store_window_ok delta (size_chunk ch) = true
      /\ cell_cover cl delta (size_chunk ch) = true.
Proof.
  intros cl fld fty H. unfold mcell_chk in H.
  destruct (field_offset (prog_comp_env mario.prog) fld mario_state_members)
    as [[delta [|]]|] eqn:E; try discriminate H.
  destruct (access_mode fty) eqn:A; try discriminate H.
  apply andb_prop in H as [H1 H2]. exists delta, m. auto.
Qed.

(* the canonical gMarioState load *)
Definition gms_shape (a : expr) : bool :=
  match a with
  | Evar x (Tpointer _ _) => Pos.eqb x mario._gMarioState
  | _ => false
  end.

Definition is_gms_load (lv : list ident) (a : expr) : bool :=
  gms_shape a && match a with Evar x _ => negb (mem_id x lv) | _ => false end.

(* the Mario temps: every temp some Sset defines by the gMarioState load *)
Fixpoint gms_temps (s : statement) : list ident :=
  match s with
  | Sset id a => if gms_shape a then [id] else []
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => gms_temps s1 ++ gms_temps s2
  | Sswitch _ sl => gms_temps_ls sl
  | _ => []
  end
with gms_temps_ls (sl : labeled_statements) : list ident :=
  match sl with
  | LSnil => []
  | LScons _ s sl' => gms_temps s ++ gms_temps_ls sl'
  end.

(* mt->fld := v *)
Definition ms_store1 (cl : list (Z * Z)) (mt : list ident) (l : expr) : bool :=
  match l with
  | Efield (Ederef (Etempvar t pty) sty) fld fty =>
      mem_id t mt && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS) && mcell_chk cl fld fty
  | _ => false
  end.

(* gMarioStates[0].fld[k] := v  (a float array member) *)
Definition ms2_geom (cl : list (Z * Z)) (fld : ident) (k : int) : bool :=
  match field_offset (prog_comp_env mario.prog) fld mario_state_members with
  | OK (delta, Full) =>
      (0 <=? delta) && (0 <=? Int.signed k)
      && store_window_ok (delta + 4 * Int.signed k) 4
      && cell_cover cl (delta + 4 * Int.signed k) 4
  | _ => false
  end.

Definition ms_store2 (cl : list (Z * Z)) (lv : list ident) (l : expr) : bool :=
  match l with
  | Ederef (Ebinop Oadd (Efield (Ederef (Ebinop Oadd (Evar g gty) (Econst_int z zt) pt) sty)
                                fld aty)
                        (Econst_int k kt) pt2) ety =>
      Pos.eqb g level_update._gMarioStates && negb (mem_id g lv)
      && proj_sumbool (type_eq gty (tarray tyMS 0)) && Int.eq z Int.zero
      && proj_sumbool (type_eq zt tint) && proj_sumbool (type_eq pt (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS) && proj_sumbool (type_eq aty (tarray tfloat 3))
      && proj_sumbool (type_eq kt tint) && proj_sumbool (type_eq pt2 (tptr tfloat))
      && proj_sumbool (type_eq ety tfloat)
      && ms2_geom cl fld k
  | _ => false
  end.

(* g := v, g a stored global *)
Definition sg_store (lv : list ident) (l : expr) : bool :=
  match l with
  | Evar g _ => mem_id g stored_globals && negb (mem_id g lv)
  | _ => false
  end.

(* ---- S-LOCALS (sl): pointer locals whose cell holds a SafeB pointer or no
   pointer.  The out cell of `find_floor(.., &floor)`: read back, `floor` is
   class kS (UcKit's RL alone gives kW).  A function with sl <> [] is
   checked under restrictions that keep every sl cell kS: its stores go
   only to kS lvalues, Mario cells or stored globals, and its calls all
   RESTART the RL threshold (a clean callee whose parameter classes are all
   nb0-free), so the callee's XS conjunct (below) covers the caller's
   locals. ---- *)
Definition is_ptr_ty (ty : type) : bool :=
  match access_mode ty with By_value Mint32 => true | _ => false end.

Definition sl_load (sl lv : list ident) (a : expr) : bool :=
  match a with
  | Evar x ty => mem_id x sl && mem_id x lv && is_ptr_ty ty
  | _ => false
  end.

Fixpoint sl_temps (sl : list ident) (s : statement) : list ident :=
  match s with
  | Sset id (Evar x _) => if mem_id x sl then [id] else []
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => sl_temps sl s1 ++ sl_temps sl s2
  | Sswitch _ sl' => sl_temps_ls sl sl'
  | _ => []
  end
with sl_temps_ls (sl : list ident) (ls : labeled_statements) : list ident :=
  match ls with
  | LSnil => []
  | LScons _ s ls' => sl_temps sl s ++ sl_temps_ls sl ls'
  end.

(* the read-back temps are class kS *)
Definition sl_tc (st : list ident) (tc : ident -> kcls) (t : ident) : kcls :=
  if mem_id t st then kS else tc t.

Definition nil_sl (sl : list ident) : bool := match sl with nil => true | _ => false end.

Definition call_restart (ut : utab) (it : uitab) (a : expr) : bool :=
  match u_call_sig ut it a with
  | Some (pcs, _, dme) => negb dme && forallb kfree pcs
  | None => false
  end.

Definition sl_of (f : Clight.function) : list ident :=
  map fst (filter (fun p => is_ptr_ty (snd p)) (fn_vars f)).

Definition xp_set dm lv gs tc (mt sl : list ident) (id : ident) (a : expr) : bool :=
  (kp_setd dm lv gs tc id a || (sl_load sl lv a && kle kS (tc id)))
  && (negb (mem_id id mt) || is_gms_load lv a).
Definition xp_store (cl : list (Z * Z)) dm lv gs tc (mt sl : list ident) (l r : expr) : bool :=
  (kp_stored dm lv gs tc l r && (nil_sl sl || kle (klvd dm lv gs tc l) kS))
  || (MtxfBody.is_byval (typeof l) && (ms_store1 cl mt l || ms_store2 cl lv l || sg_store lv l)).
(* an argument cast (at the call) to a narrow scalar parameter type is never
   a pointer, whatever its class: a short / char / float / long parameter
   (2026-10-25, for the action bodies' `(s16) o->oFoo` arguments) *)
Definition narrow_ty (ty : type) : bool :=
  match ty with
  | Tint I8 _ _ | Tint I16 _ _ | Tfloat _ _ | Tlong _ _ => true
  | _ => false
  end.

Lemma narrow_cast_nonptr : forall v1 ty1 ty2 m b o, narrow_ty ty2 = true ->
    sem_cast v1 ty1 ty2 m = Some (Vptr b o) -> False.
Proof.
  intros v1 ty1 ty2 m b o Hn H.
  destruct ty2 as [| [ | | | ] ? ? | | [ | ] ? | | | | |]; try discriminate Hn;
  unfold sem_cast in H;
  destruct ty1 as [| [ | | | ] ? ? | | [ | ] ? | | | | |]; cbn in H;
  destruct v1; try discriminate H;
    repeat match type of H with
           | (if ?c then _ else _) = _ => destruct c; try discriminate H
           | (match ?x with _ => _ end) = _ => destruct x; try discriminate H
           end.
Qed.

Definition call_targs (a : expr) : list type :=
  match classify_fun (typeof a) with fun_case_f tl _ _ => tl | _ => nil end.

Fixpoint kargs_okx dm lv gs tc (al : list expr) (pcs : list kcls) (tl : list type) : bool :=
  match al, pcs with
  | nil, nil => true
  | a :: al', c :: pcs' =>
      match tl with
      | ty :: tl' => (kle (kxd dm lv gs tc a) c || narrow_ty ty) && kargs_okx dm lv gs tc al' pcs' tl'
      | nil => kle (kxd dm lv gs tc a) c && kargs_okx dm lv gs tc al' pcs' nil
      end
  | _, _ => false
  end.

(* UcKit's kp_calld, with the narrow-parameter argument rule *)
Definition kp_calldx dm lv gs tc (ut : utab) (it : uitab)
    (optid : option ident) (a : expr) (al : list expr) : bool :=
  match direct_fid a with Some fid => negb (mem_id fid lv) | None => true end &&
  match u_call_sig ut it a with
  | Some (pcs, rc, dme) =>
      kargs_okx dm lv gs tc al pcs (call_targs a) && mode_ok dm dme pcs &&
      match optid with None => true | Some id => kle rc (tc id) end
  | None => false
  end.

Definition xp_call dm lv gs tc ut it (mt sl : list ident) (optid : option ident) (a : expr)
    (al : list expr) : bool :=
  kp_calldx dm lv gs tc ut it optid a al
  && match optid with Some id => negb (mem_id id mt) | None => true end
  && (nil_sl sl || call_restart ut it a).

Definition xchk_tc (cl : list (Z * Z)) dm (gs : list ident) (tc : ident -> kcls) (ut : utab) (it : uitab)
    (pcs : list kcls) (rc : kcls) (sl : list ident) (f : Clight.function) : bool :=
  let lv := map fst (fn_vars f) in
  let mt := gms_temps (fn_body f) in
  sw_chk (xp_set dm lv gs tc mt sl) (xp_store cl dm lv gs tc mt sl) (xp_call dm lv gs tc ut it mt sl)
    (kp_retd dm lv gs tc rc) (fn_body f)
  && kpar_ok tc (map fst (fn_params f)) pcs
  && forallb (fun p => negb (mem_id p mt)) (map fst (fn_params f)).

Definition xchk_sl (cl : list (Z * Z)) (gs : list ident) (ut : utab) (it : uitab) (s : usig)
    (sl : list ident) (f : Clight.function) : bool :=
  let '(pcs, rc, dm) := s in
  xchk_tc cl dm gs (sl_tc (sl_temps sl (fn_body f)) (utc_of dm gs ut it pcs f)) ut it pcs rc sl f.

(* plain, or with the function's pointer locals as S-locals *)
Definition xchk (cl : list (Z * Z)) (gs : list ident) (ut : utab) (it : uitab) (s : usig) (f : Clight.function) : bool :=
  xchk_sl cl gs ut it s [] f || xchk_sl cl gs ut it s (sl_of f) f.

(* the stored globals are globals MWF does not read *)
Lemma stored_not_mwf : forallb (fun g => negb (mem_id g ObjExtBodies.mwf_syms)) stored_globals = true.
Proof. vm_compute. reflexivity. Qed.

Lemma sg_not_mwf : forall g, mem_id g stored_globals = true -> mem_id g ObjExtBodies.mwf_syms = false.
Proof.
  intros g H. apply existsb_exists in H as (y & Hy & E). apply Pos.eqb_eq in E. subst y.
  pose proof (proj1 (forallb_forall _ _) stored_not_mwf g Hy) as Hn.
  apply negb_true_iff in Hn. exact Hn.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Generic frame bricks.                                                 *)
(* ---------------------------------------------------------------------- *)

Lemma av_unch : forall (P : block -> Z -> Prop) ge e0 m vars e m1,
    alloc_variables ge e0 m vars e m1 -> Mem.unchanged_on P m m1.
Proof.
  intros P ge e0 m vars e m1 H. induction H.
  - apply Mem.unchanged_on_refl.
  - eapply Mem.unchanged_on_trans; [ eapply Mem.alloc_unchanged_on; eassumption | exact IHalloc_variables ].
Qed.

(* a function's locals start out valid and undefined *)
Lemma av_undef : forall ge e0 m vars e m1,
    alloc_variables ge e0 m vars e m1 ->
    (forall x xb ty, e0 ! x = Some (xb, ty) -> Mem.valid_block m xb /\
       forall ofs v, Mem.load Mint32 m xb ofs = Some v -> v = Vundef) ->
    forall x xb ty, e ! x = Some (xb, ty) -> Mem.valid_block m1 xb /\
       forall ofs v, Mem.load Mint32 m1 xb ofs = Some v -> v = Vundef.
Proof.
  intros ge e0 m vars e m1 H.
  induction H as [e0 m0 | e0 m0 id ty vars0 m1 b1 m2 e2 Hal Hrest IH]; intros H0; [ exact H0 | ].
  apply IH. intros x xb tx Hx. destruct (peq x id) as [-> | Hne].
  - rewrite PTree.gss in Hx. injection Hx as <- _.
    split; [ exact (Mem.valid_new_block _ _ _ _ _ Hal) | ].
    intros ofs v Hld. exact (Mem.load_alloc_same _ _ _ _ _ Hal _ _ _ Hld).
  - rewrite PTree.gso in Hx by exact Hne.
    destruct (H0 x xb tx Hx) as (Hv & Hc).
    split; [ exact (Mem.valid_block_alloc _ _ _ _ _ Hal _ Hv) | ].
    intros ofs v Hld. apply (Hc ofs).
    rewrite <- (Mem.load_alloc_unchanged _ _ _ _ _ Hal _ _ _ Hv). exact Hld.
Qed.

Lemma fl_unch : forall (P : block -> Z -> Prop) l m m',
    Mem.free_list m l = Some m' ->
    (forall b lo hi, In (b, lo, hi) l -> forall i, lo <= i < hi -> ~ P b i) ->
    Mem.unchanged_on P m m'.
Proof.
  induction l as [| [[b lo] hi] l IH]; intros m m' Hf Hn; cbn in Hf.
  - injection Hf as <-. apply Mem.unchanged_on_refl.
  - destruct (Mem.free m b lo hi) as [m1|] eqn:E; [ | discriminate Hf ].
    eapply Mem.unchanged_on_trans.
    + eapply Mem.free_unchanged_on; [ exact E | ].
      intros i Hi. exact (Hn b lo hi (or_introl eq_refl) i Hi).
    + apply (IH m1 m' Hf). intros b' lo' hi' Hin. exact (Hn b' lo' hi' (or_intror Hin)).
Qed.

Lemma boe_in : forall ge e b lo hi, In (b, lo, hi) (blocks_of_env ge e) ->
    exists x ty, e ! x = Some (b, ty).
Proof.
  intros ge e b lo hi H. unfold blocks_of_env in H.
  apply in_map_iff in H as ([x [b' ty]] & E & Hin).
  unfold block_of_binding in E. injection E as -> _ _.
  exists x, ty. apply PTree.elements_complete. exact Hin.
Qed.

Lemma assign_loc_unch : forall (P : block -> Z -> Prop) ce ty m loc ofs bf v m',
    assign_loc ce ty m loc ofs bf v m' -> (forall i, ~ P loc i) -> Mem.unchanged_on P m m'.
Proof.
  intros P ce ty m loc ofs bf v m' Ha Hn. inv Ha.
  - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs;
      eapply Mem.store_unchanged_on; [ exact Hs | intros i _; apply Hn ] end.
  - match goal with Hs : Mem.storebytes _ _ _ _ = Some _ |- _ =>
      eapply Mem.storebytes_unchanged_on; [ exact Hs | intros i _; apply Hn ] end.
  - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hs;
      eapply Mem.store_unchanged_on; [ exact Hs | intros i _; apply Hn ] end.
Qed.

Lemma kp_stored_cls : forall dm lv gs tc l r,
    kp_stored dm lv gs tc l r = true -> kle (klvd dm lv gs tc l) kW = true.
Proof.
  intros dm lv gs tc l r H. unfold kp_stored in H. apply andb_prop in H as [_ H].
  destruct (klvd dm lv gs tc l); try discriminate H; reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The walker.                                                           *)
(* ---------------------------------------------------------------------- *)

Section XW.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let ge := lp_ge lp.
  Let MWF := MWF_real lp bm bc oc0 SafeB.

  Let Hbc_bm := ObjExtBodies.ox_Hbc_bm lp bm bc oc0 Hspawn.
  Let Hnot_bm := ObjExtBodies.ox_not_bm lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hgms := ObjExtBodies.ox_gms lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hgt := ObjExtBodies.ox_gtimer lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Htb := ObjExtBodies.ox_table lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hkt := ObjExtBodies.ox_ktab lp bm bc oc0 SafeB HSafeB_syms Hspawn.
  Let Hglob := ObjExtBodies.ox_glob lp bm bc oc0 SafeB HSafeB_syms Hspawn.

  Lemma x_gms_bm : Genv.find_symbol ge level_update._gMarioStates = Some bm.
  Proof. pose proof Hspawn as (init & _ & Hb & _). exact Hb. Qed.

  Variable nl : block.
  Hypothesis HNL : HnB lp bm SafeB nl.

  (* the Mario cells the frame allows *)
  Variable MC : Z -> Prop.
  Variable cl : list (Z * Z).
  Hypothesis HMC : forall ofs, in_mcells cl ofs -> MC ofs.

  Definition FP (b : block) (ofs : Z) : Prop :=
    SafeB b \/ Ple nl b \/ GBu lp b \/ (b = bm /\ MC ofs).
  Definition FR (m m' : mem) : Prop := Mem.unchanged_on (fun b ofs => ~ FP b ofs) m m'.

  Local Notation UI := (UInv lp bm bc oc0 SafeB nl).
  Local Notation KTP := (KTPu lp SafeB nl).
  Local Notation VOK := (uvok lp SafeB nl).

  Lemma FR_refl : forall m, FR m m.
  Proof. intros m. apply Mem.unchanged_on_refl. Qed.
  Lemma FR_trans : forall m1 m2 m3, FR m1 m2 -> FR m2 m3 -> FR m1 m3.
  Proof. intros m1 m2 m3 H1 H2. exact (Mem.unchanged_on_trans _ _ _ _ H1 H2). Qed.

  (* XS: a block allocated since the walk began but below the RL threshold
     (a caller's local) receives no pointer but a SafeB one *)
  Definition XS (nb0 : block) (m m' : mem) : Prop :=
    forall b ofs bb oo, Ple nl b -> Plt b nb0 ->
      Mem.load Mint32 m' b ofs = Some (Vptr bb oo) ->
      Mem.load Mint32 m b ofs = Some (Vptr bb oo) \/ SafeB bb.

  Lemma XS_refl : forall nb0 m, XS nb0 m m.
  Proof. intros nb0 m b ofs bb oo _ _ H. left; exact H. Qed.

  Lemma XS_trans : forall nb0 m1 m2 m3, XS nb0 m1 m2 -> XS nb0 m2 m3 -> XS nb0 m1 m3.
  Proof.
    intros nb0 m1 m2 m3 H1 H2 b ofs bb oo Hl Hlt Hld.
    destruct (H2 b ofs bb oo Hl Hlt Hld) as [H | H]; [ exact (H1 b ofs bb oo Hl Hlt H) | right; exact H ].
  Qed.

  Lemma XS_mono : forall nb0 nb1 m m', Ple nb0 nb1 -> XS nb1 m m' -> XS nb0 m m'.
  Proof.
    intros nb0 nb1 m m' Hle H b ofs bb oo Hl Hlt Hld.
    exact (H b ofs bb oo Hl (Plt_Ple_trans _ _ _ Hlt Hle) Hld).
  Qed.

  Lemma XS_store : forall nb0 ch m b z v m',
      Mem.store ch m b z v = Some m' ->
      (Ple nl b -> Plt b nb0 -> forall bb oo, v = Vptr bb oo -> SafeB bb) ->
      XS nb0 m m'.
  Proof.
    intros nb0 ch m b z v m' Hst Hv b1 ofs bb oo Hl Hlt Hld.
    destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hld)
      as [(Ev & _ & Eb & _) | Hdis].
    - subst b1. right. exact (Hv Hl Hlt bb oo Ev).
    - left. rewrite (Mem.load_store_other _ _ _ _ _ _ Hst _ _ _ Hdis) in Hld. exact Hld.
  Qed.

  Lemma XS_unch : forall nb0 m m', Ple nb0 (Mem.nextblock m) ->
      Mem.unchanged_on (fun b _ => Ple nl b /\ Plt b nb0) m m' -> XS nb0 m m'.
  Proof.
    intros nb0 m m' Hnb HU b ofs bb oo Hl Hlt Hld. left.
    rewrite <- (Mem.load_unchanged_on_1 _ _ _ Mint32 b ofs HU
                  (Plt_Ple_trans _ _ _ Hlt Hnb) (fun i _ => conj Hl Hlt)).
    exact Hld.
  Qed.

  (* a store below nl (SafeB, Mario's block, a global) keeps XS *)
  Lemma XS_low : forall nb0 m m' loc, Plt loc nl -> Ple nb0 (Mem.nextblock m) ->
      Mem.unchanged_on (fun b _ => b <> loc) m m' -> XS nb0 m m'.
  Proof.
    intros nb0 m m' loc Hlo Hnb HU. apply (XS_unch nb0 m m' Hnb).
    eapply Mem.unchanged_on_implies; [ exact HU | ].
    intros b ofs (Hl & _) _ E. subst b. exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hlo Hl)).
  Qed.

  (* SLI: the S-locals' cells hold SafeB pointers or no pointer *)
  Definition SLI (sl : list ident) (e : env) (m : mem) : Prop :=
    forall x xb ty, mem_id x sl = true -> e ! x = Some (xb, ty) ->
      Plt xb (Mem.nextblock m) /\
      (forall ofs bb oo, Mem.load Mint32 m xb ofs = Some (Vptr bb oo) -> SafeB bb).

  Lemma SLI_nil : forall e m, SLI nil e m.
  Proof. intros e m x xb ty Hx. discriminate Hx. Qed.

  Lemma SLI_unch : forall (P : block -> Z -> Prop) sl e m m',
      (forall x xb ty, mem_id x sl = true -> e ! x = Some (xb, ty) -> forall i, P xb i) ->
      Mem.unchanged_on P m m' -> SLI sl e m -> SLI sl e m'.
  Proof.
    intros P sl e m m' HP HU HS x xb ty Hx He.
    destruct (HS x xb ty Hx He) as (Hv & Hc).
    split; [ exact (Plt_Ple_trans _ _ _ Hv (Mem.unchanged_on_nextblock _ _ _ HU)) | ].
    intros ofs bb oo Hld. apply (Hc ofs bb oo).
    rewrite <- (Mem.load_unchanged_on_1 _ _ _ Mint32 xb ofs HU Hv (fun i _ => HP x xb ty Hx He i)).
    exact Hld.
  Qed.

  (* a store below nb0 keeps SLI (the S-locals live at or above nb0) *)
  Lemma SLI_low : forall nb0 lv sl e m m' loc, KEILu nb0 lv e -> Plt loc nb0 ->
      Mem.unchanged_on (fun b _ => b <> loc) m m' -> SLI sl e m -> SLI sl e m'.
  Proof.
    intros nb0 lv sl e m m' loc HEI Hlo HU HS.
    refine (SLI_unch _ sl e m m' _ HU HS).
    intros x xb ty _ He i E. subst xb.
    destruct (proj1 HEI _ _ _ He) as (_ & Hb).
    exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hlo Hb)).
  Qed.

  (* a callee that keeps XS above the caller's locals keeps SLI *)
  Lemma SLI_XS : forall nb0 lv sl e m m', Hn nl nb0 -> KEILu nb0 lv e ->
      XS (Mem.nextblock m) m m' -> Ple (Mem.nextblock m) (Mem.nextblock m') ->
      SLI sl e m -> SLI sl e m'.
  Proof.
    intros nb0 lv sl e m m' HN HEI HX Hnb HS x xb ty Hx He.
    destruct (HS x xb ty Hx He) as (Hv & Hc).
    destruct (proj1 HEI _ _ _ He) as (_ & Hb).
    split; [ exact (Plt_Ple_trans _ _ _ Hv Hnb) | ].
    intros ofs bb oo Hld.
    destruct (HX xb ofs bb oo (Ple_trans _ _ _ HN Hb) Hv Hld) as [H | H];
      [ exact (Hc ofs bb oo H) | exact H ].
  Qed.

  Lemma kW_FP : forall nb0 b ofs, Hn nl nb0 -> upc lp SafeB nl nb0 kW b -> FP b ofs.
  Proof.
    intros nb0 b ofs HN H. unfold Hn in HN. unfold upc in H. cbn [kpc] in H.
    destruct H as [H | [[H | H] | H]].
    - left; exact H.
    - right; left; exact H.
    - right; left; exact (Ple_trans _ _ _ HN H).
    - right; right; left; exact H.
  Qed.

  (* the per-function spec: UcKit's, plus the frame *)
  Definition xspec (fd : Clight.fundef) (s : usig) : Prop :=
    let '(pcs, rc, dm) := s in
    forall nb0, Hn nl nb0 ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 (VOK nb0) pcs vargs -> UI dm nb0 m ->
      UI dm nb0 m' /\ VOK nb0 rc vres /\ FR m m' /\ XS nb0 m m'.

  Definition MP (mt : list ident) (le : temp_env) : Prop :=
    forall t b o, mem_id t mt = true -> le ! t = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero.

  (* a store into one block below nl (Mario's block, a global) *)
  Definition LOW (m m' : mem) : Prop :=
    exists loc, Plt loc nl /\ Mem.unchanged_on (fun b _ => b <> loc) m m'.

  Lemma LOW_store : forall ch m loc z v m', Plt loc nl ->
      Mem.store ch m loc z v = Some m' -> LOW m m'.
  Proof.
    intros ch m loc z v m' Hlo Hst. exists loc. split; [ exact Hlo | ].
    eapply Mem.store_unchanged_on; [ exact Hst | ]. intros i _ H. exact (H eq_refl).
  Qed.

  (* ---- a store into Mario's block at listed cells ---- *)
  Lemma x_bm_store : forall dm nb0 ch m delta vv m',
      Hn nl nb0 -> store_window_ok delta (size_chunk ch) = true ->
      cell_cover cl delta (size_chunk ch) = true ->
      Mem.store ch m bm delta vv = Some m' ->
      UI dm nb0 m -> UI dm nb0 m' /\ FR m m' /\ LOW m m'.
  Proof.
    intros dm nb0 ch m delta vv m' HN Hw Hcov Hst ((Hv & Hsat & HM) & Hnb & HL).
    destruct (NpcDialogBody.win_bounds _ _ Hw) as (_ & _ & Hd2).
    destruct (NpcDialogBody.store_keeps_act _ _ _ _ _ _ Hst Hd2 Hv Hsat) as (Hv' & Hsat').
    destruct (hn_base lp bm SafeB nl HNL nb0 HN) as (Hbm & _ & _).
    split; [ split; [ split; [ exact Hv' | split; [ exact Hsat' | ] ] | split ] | split ].
    - exact (mwf_real_window lp bm bc oc0 SafeB Hbc_bm Hnot_bm Hgms Hgt Htb Hkt _ _ _ _ _ HM Hw Hst).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
    - intros Hd. exact (u_rl_other lp SafeB nl nb0 _ _ _ _ _ _ Hbm Hst (HL Hd)).
    - eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i Hi Hn'. apply Hn'. right; right; right. split; [ reflexivity | ].
      apply HMC. exact (cell_cover_sound _ _ _ Hcov i Hi).
    - exact (LOW_store _ _ _ _ _ _ (proj1 HNL) Hst).
  Qed.

  (* ---- a store into a stored global ---- *)
  Lemma x_sg_store : forall dm nb0 g loc ch m z vv m',
      Hn nl nb0 -> mem_id g stored_globals = true -> Genv.find_symbol ge g = Some loc ->
      Mem.store ch m loc z vv = Some m' ->
      UI dm nb0 m -> UI dm nb0 m' /\ FR m m' /\ LOW m m'.
  Proof.
    intros dm nb0 g loc ch m z vv m' HN Hsg Hfs Hst ((Hv & Hsat & HM) & Hnb & HL).
    destruct (mwf_real_glob lp bm bc oc0 SafeB Hbc_bm Hglob g Hsg _ Hfs) as (Hne & Hpres).
    destruct (hn_base lp bm SafeB nl HNL nb0 HN) as (_ & _ & Hn_glob).
    split; [ split; [ split; [ | split ] | split ] | split ].
    - eauto using Mem.store_valid_block_1.
    - eapply action_sat_unchanged_on with (m := m); [ | exact Hv | exact Hsat ].
      eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ [Hb' _]. exact (Hne Hb').
    - exact (Hpres _ _ _ _ _ HM Hst).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnb.
    - intros Hd. exact (u_rl_other lp SafeB nl nb0 _ _ _ _ _ _ (Hn_glob _ _ Hfs) Hst (HL Hd)).
    - eapply Mem.store_unchanged_on; [ exact Hst | ].
      intros i _ Hn'. apply Hn'. right; right; left. exists g. split; [ exact Hfs | exact (sg_not_mwf g Hsg) ].
    - exact (LOW_store _ _ _ _ _ _ (proj2 (proj2 HNL) _ _ Hfs) Hst).
  Qed.

  (* ---- the gMarioStates[0].fld[k] lvalue ---- *)
  Lemma gms_arr_geom : forall e le m g z k fld delta loc ofs bf,
      e ! g = None -> Genv.find_symbol ge g = Some bm ->
      Int.eq z Int.zero = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members = OK (delta, Full) ->
      0 <= delta -> 0 <= Int.signed k -> delta + 4 * Int.signed k + 4 <= Ptrofs.max_unsigned ->
      eval_lvalue ge e le m
        (Ederef (Ebinop Oadd (Efield (Ederef (Ebinop Oadd (Evar g (tarray tyMS 0))
                                                     (Econst_int z tint) (tptr tyMS)) tyMS)
                                      fld (tarray tfloat 3))
                        (Econst_int k tint) (tptr tfloat)) tfloat) loc ofs bf ->
      loc = bm /\ Ptrofs.unsigned ofs = delta + 4 * Int.signed k /\ bf = Full.
  Proof.
    intros e le m g z k fld delta loc ofs bf Hg Hs Hz Hfo Hd0 Hk0 Hb1 Hlv.
    pose proof (Int.eq_spec z Int.zero) as Ez. rewrite Hz in Ez. subst z.
    inv Hlv.
    match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => rename He into Hadd end.
    inv Hadd;
      [ | match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end ].
    match goal with Hc : eval_expr _ _ _ _ (Econst_int k _) _ |- _ =>
      inv Hc; [ | match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H end ] end.
    match goal with Ha : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv Ha end.
    match goal with Hd : deref_loc _ _ _ _ _ _ |- _ =>
      inv Hd;
      try (match goal with Hacc : access_mode _ = _ |- _ => cbn in Hacc; discriminate Hacc end);
      try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end) end.
    match goal with Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
      rename Hflv into Hfl end.
    apply eval_lvalue_Efield_inv in Hfl as (o0 & id & att & co & delta' & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ]. subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    inv Hlvb;
      [ | match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end ].
    match goal with Hc : eval_expr _ _ _ _ (Econst_int Int.zero _) _ |- _ =>
      inv Hc; [ | match goal with H : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv H end ] end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_expr_Evar_load in Hv as (lg & og & bfg & Hlg & Hdg) end.
    inv Hlg; [ congruence | ].
    match goal with Hs' : Genv.find_symbol _ g = Some _ |- _ => rewrite Hs in Hs'; injection Hs' as <- end.
    inv Hdg;
      try (match goal with Hacc : access_mode _ = _ |- _ => cbn in Hacc; discriminate Hacc end);
      try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end).
    (* the two additions *)
    repeat match goal with
      | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
          cbn in Hsem; injection Hsem as ?
      end.
    (* the struct field *)
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; [ | cbn in Hty; discriminate ].
    cbn in Hty; inv Hty.
    change (genv_cenv ge) with (prog_comp_env lp) in Hco, Hfo2.
    destruct mario_defines_MarioState as (co0 & Hmar).
    pose proof (linkorder_comp_env_extends lp mario.prog mario._MarioState
                  co0 (linked12_LO_mario lp H12) Hmar) as Hext_lp.
    assert (co = co0) by congruence. subst co0.
    assert (Hmm : mario_state_members = co_members co)
      by (unfold mario_state_members; rewrite Hmar; reflexivity).
    rewrite (linkorder_field_offset_agree lp mario.prog fld (co_members co)
               (linked12_LO_mario lp H12)) in Hfo2;
      [ | rewrite <- Hmm; exact mario_state_members_complete ].
    rewrite Hmm in Hfo. rewrite Hfo in Hfo2. injection Hfo2 as <-.
    repeat match goal with E : Vptr _ _ = Vptr _ _ |- _ => injection E as ? ? end.
    subst.
    split; [ reflexivity | split; [ | reflexivity ] ].
    change (Ptrofs.of_ints Int.zero) with Ptrofs.zero.
    rewrite Ptrofs.mul_zero, Ptrofs.add_zero.
    rewrite Ptrofs.add_zero_l.
    unfold Ptrofs.of_ints, Ptrofs.mul.
    rewrite (Ptrofs.unsigned_repr 4) by (unfold Ptrofs.max_unsigned in *; lia).
    rewrite (Ptrofs.unsigned_repr (Int.signed k)) by lia.
    unfold Ptrofs.add.
    rewrite (Ptrofs.unsigned_repr delta) by lia.
    rewrite (Ptrofs.unsigned_repr (4 * Int.signed k)) by lia.
    apply Ptrofs.unsigned_repr. lia.
  Qed.

  (* ---- the three new store arms, at the statement ---- *)
  Lemma x_ms1 : forall dm nb0 e mt l r le m t le' m' out,
      Hn nl nb0 -> ms_store1 cl mt l = true -> MP mt le ->
      exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
      UI dm nb0 m -> UI dm nb0 m' /\ FR m m' /\ LOW m m'.
  Proof.
    intros dm nb0 e mt l r le m t le' m' out HN Hok HM Hx Hi.
    destruct l as [ | | | | | | | | | | | a0 fld fty | | ]; try discriminate Hok.
    destruct a0 as [ | | | | | | a1 sty | | | | | | | ]; try discriminate Hok.
    destruct a1 as [ | | | | | p pty | | | | | | | | ]; try discriminate Hok.
    unfold ms_store1 in Hok.
    apply andb_prop in Hok as [Hok Hg]. apply andb_prop in Hok as [Hok Hsty].
    apply andb_prop in Hok as [Hmp Hpty].
    apply proj_sumbool_true in Hpty. apply proj_sumbool_true in Hsty. subst pty sty.
    destruct (mcell_chk_sound _ _ _ Hg) as (delta & ch & Hfo & Hac & Hw & Hcov).
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename Hl into Hlv end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Hal end.
    pose proof Hlv as Hlv0.
    apply eval_lvalue_Efield_base in Hlv0 as (o0 & Hb0).
    apply eval_expr_Ederef_load in Hb0 as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    destruct (HM _ _ _ Hmp Hlvb) as [-> ->].
    destruct (mfield_lvalue_geom_lp lp (linked12_LO_mario lp H12)
                _ _ _ _ _ _ _ _ _ _ _ _ Hlvb Hfo Hlv) as (-> & -> & ->).
    destruct (NpcDialogBody.win_bounds _ _ Hw) as (Hd0 & Hd1 & Hd2).
    inv Hal; try (match goal with Hm : access_mode _ = By_copy |- _ =>
                    cbn [typeof] in Hm; rewrite Hac in Hm; discriminate Hm end).
    match goal with Hm : access_mode (typeof _) = By_value ?c, Hs : Mem.storev ?c _ _ _ = Some _ |- _ =>
      cbn [typeof] in Hm; rewrite Hac in Hm; injection Hm as <-; rename Hs into Hst end.
    cbn [Mem.storev] in Hst.
    rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr in Hst
      by (pose proof (size_chunk_pos ch); lia).
    exact (x_bm_store dm nb0 ch m delta _ _ HN Hw Hcov Hst Hi).
  Qed.

  Lemma x_ms2 : forall dm nb0 lv e l r le m t le' m' out,
      Hn nl nb0 -> KEILu nb0 lv e -> ms_store2 cl lv l = true ->
      exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
      UI dm nb0 m -> UI dm nb0 m' /\ FR m m' /\ LOW m m'.
  Proof.
    intros dm nb0 lv e l r le m t le' m' out HN HEI Hok Hx Hi.
    destruct l as [ | | | | | | l1 ety | | | | | | | ]; try discriminate Hok.
    destruct l1 as [ | | | | | | | | | op l2 kc pt2 | | | | ]; try discriminate Hok.
    destruct op; try discriminate Hok.
    destruct l2 as [ | | | | | | | | | | | b0 fld aty | | ]; try discriminate Hok.
    destruct b0 as [ | | | | | | b1 sty | | | | | | | ]; try discriminate Hok.
    destruct b1 as [ | | | | | | | | | op1 gv zc pt | | | | ]; try discriminate Hok.
    destruct op1; try discriminate Hok.
    destruct gv as [ | | | | g gty | | | | | | | | | ]; try discriminate Hok.
    destruct zc as [ z zt | | | | | | | | | | | | | ]; try discriminate Hok.
    destruct kc as [ k kt | | | | | | | | | | | | | ]; try discriminate Hok.
    unfold ms_store2 in Hok.
    repeat (apply andb_prop in Hok as [Hok ?]).
    repeat match goal with H : proj_sumbool (type_eq _ _) = true |- _ =>
      apply proj_sumbool_true in H; subst end.
    apply Pos.eqb_eq in Hok. subst g.
    match goal with H : negb (mem_id _ lv) = true |- _ => apply negb_true_iff in H; rename H into Hnl end.
    match goal with H : Int.eq z Int.zero = true |- _ => rename H into Hz end.
    match goal with H : ms2_geom cl fld k = true |- _ => rename H into Hgeo end.
    unfold ms2_geom in Hgeo.
    destruct (field_offset (prog_comp_env mario.prog) fld mario_state_members)
      as [[delta [|]]|] eqn:Hfo; try discriminate Hgeo.
    apply andb_prop in Hgeo as [Hgeo Hcov]. apply andb_prop in Hgeo as [Hgeo Hw].
    apply andb_prop in Hgeo as [Hd0 Hk0]. apply Z.leb_le in Hd0. apply Z.leb_le in Hk0.
    destruct (NpcDialogBody.win_bounds _ _ Hw) as (_ & Hb1 & _).
    assert (Hen : e ! level_update._gMarioStates = None).
    { destruct (e ! level_update._gMarioStates) as [[bb tt]|] eqn:E; [ | reflexivity ].
      destruct (proj1 HEI _ _ _ E) as (Hm & _). congruence. }
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => rename Hl into Hlv end.
    destruct (gms_arr_geom _ _ _ _ z k fld delta _ _ _ Hen x_gms_bm Hz Hfo Hd0 Hk0 Hb1 Hlv)
      as (-> & Hofs & ->).
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      try (match goal with Hm : access_mode _ = By_copy |- _ => cbn in Hm; discriminate Hm end).
    match goal with Hm : access_mode _ = By_value ?c, Hs : Mem.storev ?c _ _ _ = Some _ |- _ =>
      cbn in Hm; injection Hm as <-; rename Hs into Hst end.
    cbn [Mem.storev] in Hst. rewrite Hofs in Hst.
    exact (x_bm_store dm nb0 Mfloat32 m _ _ _ HN Hw Hcov Hst Hi).
  Qed.

  Lemma x_sg : forall dm nb0 lv e l r le m t le' m' out,
      Hn nl nb0 -> KEILu nb0 lv e -> sg_store lv l = true ->
      MtxfBody.is_byval (typeof l) = true ->
      exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
      UI dm nb0 m -> UI dm nb0 m' /\ FR m m' /\ LOW m m'.
  Proof.
    intros dm nb0 lv e l r le m t le' m' out HN HEI Hok Hbv Hx Hi.
    destruct l as [ | | | | g gty | | | | | | | | | ]; try discriminate Hok.
    unfold sg_store in Hok. apply andb_prop in Hok as [Hsg Hnl]. apply negb_true_iff in Hnl.
    cbn [typeof] in Hbv.
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
    - exfalso. match goal with H : e ! g = Some _ |- _ => destruct (proj1 HEI _ _ _ H) as (Hm & _) end.
      congruence.
    - match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
      + match goal with Hs : Mem.storev _ _ _ _ = Some _, Hfs : Genv.find_symbol _ g = Some _ |- _ =>
          unfold Mem.storev in Hs; exact (x_sg_store dm nb0 g _ _ _ _ _ _ HN Hsg Hfs Hs Hi) end.
      + unfold MtxfBody.is_byval in Hbv.
        match goal with Hc : access_mode _ = By_copy |- _ =>
          cbn [typeof] in Hc; rewrite Hc in Hbv; discriminate Hbv end.
  Qed.

  (* ---- the walker's table ---- *)
  Variable gs : list ident.
  Hypothesis Hgs : forall x b, mem_id x gs = true -> Genv.find_symbol ge x = Some b -> SafeB b.
  Variable ut : utab.
  Variable it : uitab.
  Variable Leaf : Clight.fundef -> usig -> Prop.
  Hypothesis HLeaf : forall fd s, Leaf fd s -> xspec fd s.

  Definition xGood (fd : Clight.fundef) (s : usig) : Prop :=
    (exists f, fd = Internal f /\ xchk cl gs ut it s f = true) \/ Leaf fd s.

  Definition xTabGood : Prop :=
    forall fid s, ut_find fid ut = Some s ->
      forall b fd, Genv.find_symbol ge fid = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> xGood fd s.

  Definition xItGood : Prop :=
    forall ty s, uit_find ty it = Some s ->
      forall vf fd, Genv.find_funct ge vf = Some fd -> type_of_fundef fd = ty ->
        exists se, xGood fd se /\ fitsb se s = true.

  Hypothesis HTab : xTabGood.
  Hypothesis HIt : xItGood.

  (* ---- a classed store: XS, and the store's single target block ---- *)
  Lemma xs_kstore : forall dm nb0 lv tc e l r le m t le' m' out,
      Hn nl nb0 -> KEILu nb0 lv e ->
      kp_stored dm lv gs tc l r = true -> KTP nb0 tc le ->
      exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
      UI dm nb0 m ->
      XS nb0 m m' /\ exists loc, upc lp SafeB nl nb0 (klvd dm lv gs tc l) loc
                          /\ Mem.unchanged_on (fun b _ => b <> loc) m m'.
  Proof.
    intros dm nb0 lv tc e l r le m t le' m' out HN HEI Hok HP Hx Hi.
    unfold kp_stored in Hok. apply andb_prop in Hok as [Hbv Hcl].
    pose proof HNL as (_ & Hsafe_nl & _).
    inv Hx.
    lazymatch goal with Hlv : eval_lvalue _ _ _ _ _ ?loc _ _ |- _ =>
      pose proof (ub_lv lp bm bc oc0 SafeB nl gs Hgs dm nb0 lv tc e HEI _ _ _ _ _ _ HP Hi Hlv) as Hpc end.
    match goal with Hre : eval_expr _ _ _ _ r ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?vv |- _ =>
      pose proof (fun K' H => ustore_val lp bm bc oc0 SafeB nl gs Hgs dm nb0 lv tc e HEI
                                K' _ _ _ _ _ _ HP Hi Hre Hc H) as Hval end.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
    - match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hst; rename Hst into Hst0 end.
      split.
      + apply (XS_store nb0 _ _ _ _ _ _ Hst0). intros Hl Hlt bb oo Ev.
        unfold upc in Hpc.
        destruct (klvd dm lv gs tc l); cbn [kpc] in Hpc; try discriminate Hcl.
        * exact (False_ind _ (Plt_strict _ (Plt_Ple_trans _ _ _ (Hsafe_nl _ Hpc) Hl))).
        * exact (False_ind _ (Plt_strict _ (Plt_Ple_trans _ _ _ Hlt Hpc))).
        * destruct (Hval kS Hcl) as (Hv & _). exact (Hv bb oo Ev).
        * destruct (Hval kN Hcl) as (Hv & _). exact (False_ind _ (Hv bb oo Ev)).
      + eexists. split; [ exact Hpc | ].
        eapply Mem.store_unchanged_on; [ exact Hst0 | ]. intros i _ Hne. exact (Hne eq_refl).
    - unfold MtxfBody.is_byval in Hbv.
      match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
    - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
      match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ => unfold Mem.storev in Hst; rename Hst into Hst0 end.
      split.
      + apply (XS_store nb0 _ _ _ _ _ _ Hst0). intros _ _ bb oo Ev. discriminate Ev.
      + eexists. split; [ exact Hpc | ].
        eapply Mem.store_unchanged_on; [ exact Hst0 | ]. intros i _ Hne. exact (Hne eq_refl).
  Qed.

  (* ---- every store arm ---- *)
  Lemma xb_store : forall dm nb0 lv tc e mt sl l r le m t le' m' out,
      Hn nl nb0 -> KEILu nb0 lv e ->
      xp_store cl dm lv gs tc mt sl l r = true -> KTP nb0 tc le -> MP mt le ->
      exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
      UI dm nb0 m -> SLI sl e m ->
      UI dm nb0 m' /\ FR m m' /\ XS nb0 m m' /\ SLI sl e m'.
  Proof.
    intros dm nb0 lv tc e mt sl l r le m t le' m' out HN HEI Hok HP HM Hx Hi HS.
    pose proof (proj1 (proj2 Hi)) as Hnb.
    unfold xp_store in Hok. apply orb_true_iff in Hok as [Hk0 | Hx2].
    - apply andb_prop in Hk0 as [Hk Hsl].
      pose proof (ub_store lp bm bc oc0 SafeB HSafeB_syms Hspawn nl HNL gs Hgs dm nb0 HN lv tc e HEI
                    l r le m t le' m' out Hk HP Hx Hi) as Hi'.
      destruct (xs_kstore dm nb0 lv tc e l r le m t le' m' out HN HEI Hk HP Hx Hi) as (HX & loc & Hpc & HU).
      split; [ exact Hi' | split; [ | split; [ exact HX | ] ] ].
      + pose proof (kp_stored_cls _ _ _ _ _ _ Hk) as Hc.
        eapply Mem.unchanged_on_implies; [ exact HU | ].
        intros b ofs Hn' _ E. subst b. apply Hn'. apply (kW_FP nb0 _ ofs HN).
        exact (kle_pc _ _ _ _ _ _ _ Hc Hpc).
      + apply orb_true_iff in Hsl as [Hnil | HkS].
        * destruct sl; [ exact (SLI_nil e m') | discriminate Hnil ].
        * assert (Hs : SafeB loc).
          { unfold upc in Hpc.
            destruct (klvd dm lv gs tc l); cbn [kpc] in Hpc; try discriminate HkS;
              [ destruct Hpc | exact Hpc ]. }
          refine (SLI_low nb0 lv sl e m m' loc HEI _ HU HS).
          exact (Plt_Ple_trans _ _ _ (proj1 (proj2 HNL) _ Hs) HN).
    - apply andb_prop in Hx2 as [Hbv Hx2].
      assert (Hlow : UI dm nb0 m' /\ FR m m' /\ LOW m m').
      { apply orb_true_iff in Hx2 as [Hx2 | Hsg]; [ apply orb_true_iff in Hx2 as [H1 | H2] | ].
        + exact (x_ms1 dm nb0 e mt l r le m t le' m' out HN H1 HM Hx Hi).
        + exact (x_ms2 dm nb0 lv e l r le m t le' m' out HN HEI H2 Hx Hi).
        + exact (x_sg dm nb0 lv e l r le m t le' m' out HN HEI Hsg Hbv Hx Hi). }
      destruct Hlow as (Hi' & HF & loc & Hlo & HU).
      split; [ exact Hi' | split; [ exact HF | split ] ].
      + exact (XS_low nb0 m m' loc Hlo Hnb HU).
      + exact (SLI_low nb0 lv sl e m m' loc HEI (Plt_Ple_trans _ _ _ Hlo HN) HU HS).
  Qed.

  (* ---- the set arm: the Mario temps hold (bm, 0) or no pointer ---- *)
  Lemma gload_e : forall e le m x ty att v, e ! x = None ->
      eval_expr ge e le m (Evar x (Tpointer ty att)) v ->
      exists gb, Genv.find_symbol ge x = Some gb /\ Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some v.
  Proof.
    intros e le m x ty att v Hn Hev.
    apply eval_expr_Evar_load in Hev as (loc & ofs & bf & Hlv & Hd).
    inv Hlv; [ congruence | ].
    exists loc. split; [ assumption | ].
    inv Hd; try (match goal with Hm : access_mode _ = _ |- _ => cbn in Hm; discriminate Hm end).
    match goal with Hm : access_mode _ = By_value _ |- _ => cbn in Hm; injection Hm as <- end.
    assumption.
  Qed.

  (* an S-local read gives a SafeB pointer or no pointer *)
  Lemma sl_load_val : forall sl lv nb0 e le m a v,
      KEILu nb0 lv e -> sl_load sl lv a = true -> SLI sl e m -> eval_expr ge e le m a v ->
      forall bb oo, v = Vptr bb oo -> SafeB bb.
  Proof.
    intros sl lv nb0 e le m a v HEI Hok HS Hev bb oo Ev.
    destruct a as [ | | | | x ty | | | | | | | | | ]; try discriminate Hok.
    cbn [sl_load] in Hok. apply andb_prop in Hok as [Hok Hpt]. apply andb_prop in Hok as [Hsl Hlv].
    destruct (e ! x) as [[xb xty]|] eqn:Ex; [ | exact (False_ind _ (proj2 HEI x Hlv Ex)) ].
    destruct (HS x xb xty Hsl Ex) as (_ & Hc).
    apply eval_expr_Evar_load in Hev as (loc & ofs & bf & Hl & Hd).
    inv Hl; [ | congruence ].
    match goal with H : e ! x = Some (loc, _) |- _ => rewrite Ex in H; injection H as <- _ end.
    unfold is_ptr_ty in Hpt.
    inv Hd;
      try (match goal with Hm : access_mode _ = _ |- _ => rewrite Hm in Hpt; discriminate Hpt end).
    match goal with Hm : access_mode _ = By_value ?c, Hld : Mem.loadv ?c _ _ = Some _ |- _ =>
      rewrite Hm in Hpt; destruct c; try discriminate Hpt; cbn [Mem.loadv] in Hld; exact (Hc _ _ _ Hld) end.
  Qed.

  Lemma xb_set : forall dm nb0 lv tc e mt sl id a le m v,
      KEILu nb0 lv e -> xp_set dm lv gs tc mt sl id a = true -> KTP nb0 tc le -> MP mt le ->
      UI dm nb0 m -> SLI sl e m -> eval_expr ge e le m a v ->
      KTP nb0 tc (PTree.set id v le) /\ MP mt (PTree.set id v le).
  Proof.
    intros dm nb0 lv tc e mt sl id a le m v HEI Hok HP HM Hi HS Hev.
    unfold xp_set in Hok. apply andb_prop in Hok as [Hk0 Hm].
    split.
    - apply orb_true_iff in Hk0 as [Hk | Hsl].
      + exact (ub_set lp bm bc oc0 SafeB nl gs Hgs dm nb0 lv tc e HEI id a le m v Hk HP Hi Hev).
      + apply andb_prop in Hsl as [Hsl Hkle].
        intros t0 v0 Hg. rewrite PTree.gsspec in Hg.
        destruct (peq t0 id) as [-> | Hne].
        * injection Hg as <-. refine (kle_vok _ _ _ _ _ _ _ Hkle _).
          intros bb oo Ev. exact (sl_load_val sl lv nb0 e le m a v HEI Hsl HS Hev bb oo Ev).
        * exact (HP t0 v0 Hg).
    - intros t0 b o Ht Hg. rewrite PTree.gsspec in Hg.
      destruct (peq t0 id) as [-> | Hne]; [ | exact (HM t0 b o Ht Hg) ].
      injection Hg as ->.
      rewrite Ht in Hm. cbn [negb orb] in Hm.
      destruct a as [ | | | | x [ | | | | pt pa | | | | ] | | | | | | | | | ]; try discriminate Hm.
      unfold is_gms_load, gms_shape in Hm. apply andb_prop in Hm as [Hx Hnl].
      apply Pos.eqb_eq in Hx. subst x. apply negb_true_iff in Hnl.
      assert (Hen : e ! mario._gMarioState = None).
      { destruct (e ! mario._gMarioState) as [[bb tt]|] eqn:E; [ | reflexivity ].
        destruct (proj1 HEI _ _ _ E) as (Hm & _). congruence. }
      destruct (gload_e _ _ _ _ _ _ _ Hen Hev) as (gb & Hs & Hld).
      destruct Hi as ((_ & _ & HMW) & _).
      exact (mwf_real_pgms lp bm bc oc0 SafeB m gb b o HMW Hs Hld).
  Qed.

  (* ---- the induction predicates: UcKit's, plus MP, the frame, XS, SLI ---- *)
  Definition xPstmt (e : env) (le : temp_env) (m : mem) (s : statement) (t : trace)
      (le' : temp_env) (m' : mem) (out : outcome) : Prop :=
    exec_stmt function_entry2 ge e le m s t le' m' out /\
    forall dm nb0 lv tc rc mt sl, Hn nl nb0 -> KEILu nb0 lv e ->
      sw_chk (xp_set dm lv gs tc mt sl) (xp_store cl dm lv gs tc mt sl) (xp_call dm lv gs tc ut it mt sl)
        (kp_retd dm lv gs tc rc) s = true ->
      KTP nb0 tc le -> MP mt le -> UI dm nb0 m -> SLI sl e m ->
      UI dm nb0 m' /\ KTP nb0 tc le' /\ uout_ok lp SafeB nl nb0 rc out /\ MP mt le' /\ FR m m'
      /\ XS nb0 m m' /\ SLI sl e m'.

  Definition xPfun (m : mem) (fd : Clight.fundef) (vargs : list val) (t : trace)
      (m' : mem) (vres : val) : Prop :=
    eval_funcall function_entry2 ge m fd vargs t m' vres /\
    forall s, xGood fd s ->
      let '(pcs, rc, dm) := s in
      forall nb0, Hn nl nb0 ->
      Forall2 (VOK nb0) pcs vargs -> UI dm nb0 m ->
      UI dm nb0 m' /\ VOK nb0 rc vres /\ FR m m' /\ XS nb0 m m'.

  Lemma xb_callee : forall nb0 lv e a le m vf fd targs tres cc sg,
      KEILu nb0 lv e ->
      match direct_fid a with Some fid => negb (mem_id fid lv) | None => true end = true ->
      u_call_sig ut it a = Some sg ->
      classify_fun (typeof a) = fun_case_f targs tres cc ->
      eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
      type_of_fundef fd = Tfunction targs tres cc ->
      exists se, xGood fd se /\ fitsb se sg = true.
  Proof.
    intros nb0 lv e a le m vf fd targs tres cc sg HEI Hnl Hsig Hcf Hev Hff Hty.
    unfold u_call_sig in Hsig.
    destruct (direct_fid a) as [fid|] eqn:Ed.
    - destruct (direct_fid_inv _ _ Ed) as (targs' & tres' & cc' & ->).
      apply negb_true_iff in Hnl.
      assert (Hnone : e ! fid = None).
      { destruct (e ! fid) as [[b ty]|] eqn:E; [ | reflexivity ].
        destruct (proj1 HEI _ _ _ E) as (Hm & _). congruence. }
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hev Hnone) as (lf & Hsy & ->).
      exists sg. split; [ exact (HTab _ _ Hsig lf fd Hsy Hff) | ].
      destruct sg as [[pcs rc] d]. unfold fitsb.
      assert (Hrefl : forall l, kcls_leq l l = true).
      { induction l as [| c l IH]; [ reflexivity | cbn [kcls_leq]; rewrite IH;
          destruct c; reflexivity ]. }
      rewrite Hrefl. destruct rc, d; reflexivity.
    - rewrite Hcf in Hsig. exact (HIt _ _ Hsig vf fd Hff Hty).
  Qed.

  (* a restarted callee keeps the caller's RL: its XS covers the caller's locals *)
  Lemma rl_restart : forall nb0 nb1 m m', Hn nl nb0 -> Ple nb0 nb1 ->
      RLu lp SafeB nl nb0 m -> RLu lp SafeB nl nb1 m' -> XS nb1 m m' -> RLu lp SafeB nl nb0 m'.
  Proof.
    intros nb0 nb1 m m' HN Hle H0 H1 HX b ofs b' o' Hb Hld.
    destruct (plt b nb1) as [Hlt | Hge].
    - destruct (HX b ofs b' o' (Ple_trans _ _ _ HN Hb) Hlt Hld) as [H | H].
      + exact (H0 b ofs b' o' Hb H).
      + unfold upc. cbn [kpc]. left. exact H.
    - assert (Hb1 : Ple nb1 b) by (unfold Plt, Ple in *; lia).
      exact (kpc_mono _ _ _ _ _ _ _ Hle (H1 b ofs b' o' Hb1 Hld)).
  Qed.

  Lemma kargsx_sound : forall dm nb0 lv tc e le m al tyl vl,
      KEILu nb0 lv e -> KTP nb0 tc le -> UI dm nb0 m ->
      eval_exprlist ge e le m al tyl vl ->
      forall pcs, kargs_okx dm lv gs tc al pcs tyl = true -> Forall2 (VOK nb0) pcs vl.
  Proof.
    intros dm nb0 lv tc e le m al tyl vl HEI HP Hi Hel.
    induction Hel as [| a1 bl ty tyl v1 v2 vl Hx Hc Hel' IHel]; intros pcs Hok;
      destruct pcs as [| c pcs]; cbn [kargs_okx] in Hok; try discriminate Hok; [ constructor | ].
    apply andb_prop in Hok as [H1 H2]. constructor; [ | exact (IHel _ H2) ].
    apply orb_true_iff in H1 as [H1 | H1].
    - assert (Hl1 : eval_exprlist ge e le m [a1] [ty] [v2])
        by (econstructor; [ exact Hx | exact Hc | constructor ]).
      assert (Hk1 : kargs_okd dm lv gs tc [a1] [c] = true) by (cbn; rewrite H1; reflexivity).
      pose proof (kargsd_sound ge e le m SafeB nl nb0 dm lv gs tc HP (proj1 HEI) (proj2 HEI) Hgs
                    (u_R7 lp bm bc oc0 SafeB m (proj1 Hi)) (proj2 (proj2 Hi)) _ _ _ Hl1 _ Hk1) as Hs.
      inv Hs. assumption.
    - intros bb oo E. subst v2. exact (False_ind _ (narrow_cast_nonptr _ _ _ _ _ _ H1 Hc)).
  Qed.

  Lemma xb_call_ih : forall dm nb0 lv tc e mt sl optid a al le m targs tres cc vf vargs fd t m' vres,
      Hn nl nb0 -> KEILu nb0 lv e ->
      xp_call dm lv gs tc ut it mt sl optid a al = true -> KTP nb0 tc le -> MP mt le -> UI dm nb0 m ->
      SLI sl e m ->
      classify_fun (typeof a) = fun_case_f targs tres cc ->
      eval_expr ge e le m a vf -> eval_exprlist ge e le m al targs vargs ->
      Genv.find_funct ge vf = Some fd -> type_of_fundef fd = Tfunction targs tres cc ->
      xPfun m fd vargs t m' vres ->
      UI dm nb0 m' /\ KTP nb0 tc (set_opttemp optid vres le)
      /\ MP mt (set_opttemp optid vres le) /\ FR m m' /\ XS nb0 m m' /\ SLI sl e m'.
  Proof.
    intros dm nb0 lv tc e mt sl optid a al le m targs tres cc vf vargs fd t m' vres
      HN HEI Hok0 HP HM Hi HS Hcf Hev Hel Hff Hty (_ & IH).
    unfold xp_call in Hok0. apply andb_prop in Hok0 as [Hok0 Hrs]. apply andb_prop in Hok0 as [Hok Hnm].
    unfold kp_calldx in Hok. apply andb_prop in Hok as [Hnl Hok].
    unfold call_restart in Hrs.
    destruct (u_call_sig ut it a) as [[[pcs rc] dme]|] eqn:Hsig; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hok Hopt]. apply andb_prop in Hok as [Hal Hmode].
    destruct (xb_callee nb0 lv e a le m vf fd targs tres cc _ HEI Hnl Hsig Hcf Hev Hff Hty)
      as ([[pcs' rc'] dm'] & Hgood & Hfit).
    unfold fitsb in Hfit.
    apply andb_prop in Hfit as [Hfit Hfm]. apply andb_prop in Hfit as [Hpl Hrc].
    apply kcls_leq_eq in Hpl. subst pcs'.
    pose proof (IH _ Hgood) as IH'. cbv beta iota in IH'.
    assert (Htl : call_targs a = targs) by (unfold call_targs; rewrite Hcf; reflexivity).
    rewrite Htl in Hal.
    pose proof (kargsx_sound dm nb0 lv tc e le m _ _ _ HEI HP Hi Hel _ Hal) as Hargs.
    assert (Hnil : nil_sl sl = true -> SLI sl e m').
    { intros Hn0. destruct sl; [ exact (SLI_nil e m') | discriminate Hn0 ]. }
    unfold mode_ok in Hmode.
    assert (Hres : UI dm nb0 m' /\ VOK nb0 rc' vres /\ FR m m' /\ XS nb0 m m' /\ SLI sl e m').
    { destruct dm' eqn:Edm'.
      - assert (Hdme : dme = true) by (cbn in Hfm; destruct dme; [ reflexivity | discriminate Hfm ]).
        subst dme.
        assert (Edm : dm = true) by (destruct dm; [ reflexivity | cbn in Hmode; discriminate Hmode ]).
        subst dm.
        destruct (IH' nb0 HN Hargs Hi) as (Hi' & Hr & HF & HX).
        refine (conj Hi' (conj Hr (conj HF (conj HX (Hnil _))))).
        destruct (nil_sl sl); [ reflexivity | cbn in Hrs; discriminate Hrs ].
      - destruct (forallb kfree pcs) eqn:Hfree.
        + pose proof Hi as (Hf & Hnb & HL).
          set (nb1 := Mem.nextblock m).
          assert (HN1 : Hn nl nb1) by exact (Hn_mono _ _ _ HN Hnb).
          destruct (IH' nb1 HN1 (forall2_kvok_free _ _ _ _ _ _ _ HN Hfree Hargs)
                      (conj Hf (conj (Ple_refl _) (fun _ => rl_fresh lp SafeB nl nb1 m eq_refl))))
            as ((Hf' & Hnb' & HL') & Hr & HF & HX).
          split; [ split; [ exact Hf' | split; [ exact (Ple_trans _ _ _ Hnb Hnb') | ] ] | ].
          * intros Hd. exact (rl_restart nb0 nb1 m m' HN Hnb (HL Hd) (HL' eq_refl) HX).
          * split; [ exact (kvok_mono _ _ _ _ _ _ _ Hnb Hr) | split; [ exact HF | split ] ].
            -- exact (XS_mono nb0 nb1 m m' Hnb HX).
            -- exact (SLI_XS nb0 lv sl e m m' HN HEI HX (Mem.unchanged_on_nextblock _ _ _ HF) HS).
        + assert (Hdme : dme = false) by (cbn in Hfm; destruct dme; [ cbn in Hfm; discriminate Hfm | reflexivity ]).
          subst dme.
          assert (Edm : dm = false) by (destruct dm; [ cbn in Hmode; discriminate Hmode | reflexivity ]).
          subst dm.
          destruct (IH' nb0 HN Hargs Hi) as (Hi' & Hr & HF & HX).
          refine (conj Hi' (conj Hr (conj HF (conj HX (Hnil _))))).
          destruct (nil_sl sl); [ reflexivity | cbn in Hrs; discriminate Hrs ]. }
    destruct Hres as (Hi' & Hr & HF & HX & HS').
    split; [ exact Hi' | split; [ | split; [ | exact (conj HF (conj HX HS')) ] ] ].
    - intros t0 v0 Hg. destruct optid as [ti|]; cbn [set_opttemp] in Hg; [ | exact (HP _ _ Hg) ].
      destruct (peq t0 ti) as [-> | Hne].
      + rewrite PTree.gss in Hg. injection Hg as <-.
        exact (kle_vok _ _ _ _ _ _ _ Hopt (kle_vok _ _ _ _ _ _ _ Hrc Hr)).
      + rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
    - intros t0 b o Hm Hg. destruct optid as [ti|]; cbn [set_opttemp] in Hg; [ | exact (HM _ _ _ Hm Hg) ].
      destruct (peq t0 ti) as [-> | Hne].
      + apply negb_true_iff in Hnm. rewrite Hm in Hnm. discriminate Hnm.
      + rewrite PTree.gso in Hg by exact Hne. exact (HM _ _ _ Hm Hg).
  Qed.

  (* the function body, given the statement induction hypothesis *)
  Lemma xb_body : forall f vargs m e le1 m1 t le2 m2 out vres m3 s,
      function_entry2 ge f vargs m e le1 m1 ->
      xPstmt e le1 m1 (fn_body f) t le2 m2 out ->
      outcome_result_value out (fn_return f) vres m2 ->
      Mem.free_list m2 (blocks_of_env ge e) = Some m3 ->
      xchk cl gs ut it s f = true ->
      let '(pcs, rc, dm) := s in
      forall nb0, Hn nl nb0 ->
      Forall2 (VOK nb0) pcs vargs -> UI dm nb0 m ->
      UI dm nb0 m3 /\ VOK nb0 rc vres /\ FR m m3 /\ XS nb0 m m3.
  Proof.
    intros f vargs m e le1 m1 t le2 m2 out vres m3 [[pcs rc] dm] Hentry (_ & IHb) Hor Hfree Hchk0
      nb0 HN Hva (Hf & Hnb & HL).
    assert (Hsl : exists sl, xchk_sl cl gs ut it (pcs, rc, dm) sl f = true).
    { unfold xchk in Hchk0. apply orb_true_iff in Hchk0 as [H | H]; eexists; exact H. }
    destruct Hsl as (sl & Hchk).
    unfold xchk_sl in Hchk.
    set (tc := sl_tc (sl_temps sl (fn_body f)) (utc_of dm gs ut it pcs f)) in Hchk.
    unfold xchk_tc in Hchk. apply andb_prop in Hchk as [Hchk Hpm].
    apply andb_prop in Hchk as [Hchk Hpar].
    set (mt := gms_temps (fn_body f)) in *.
    pose proof Hf as (Hv & Hs & HM).
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbp end.
    set (lv := map fst (fn_vars f)) in *.
    pose proof (MtxfBody.av_facts bm MWF _ _ _ _ _ _ (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm) Hav Hf)
      as Hf1.
    destruct (u_av lp SafeB nl nb0 _ _ _ _ _ Hav
                ltac:(intros x b ty Hx; rewrite PTree.gempty in Hx; discriminate Hx) Hnb)
      as (Hnb1 & He1 & HL1).
    assert (HEI : KEILu nb0 lv e).
    { split.
      - intros x b ty Hx. split; [ | exact (He1 _ _ _ Hx) ].
        destruct (mem_id x lv) eqn:E; [ reflexivity | exfalso ].
        rewrite (alloc_variables_unbound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_notin _ _ E)) in Hx.
        rewrite PTree.gempty in Hx. discriminate Hx.
      - intros x Hx. destruct (alloc_variables_in_bound _ _ _ _ _ _ Hav x (MtxfBody.mem_id_In _ _ Hx))
          as (b & ty & E). congruence. }
    assert (HP1 : KTP nb0 tc le1).
    { intros t0 v Hg.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hg) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. subst v. apply kvok_undef.
      - destruct (PrintBodies.forall2_nth_l _ _ _ _ _ Hva Hvi) as (c & Hc).
        exact (kle_vok _ _ _ _ _ _ _ (kpar_ok_nth _ _ _ _ _ _ Hpar Hi Hc)
                 (PrintBodies.forall2_nth _ _ _ _ _ _ Hva Hc Hvi)). }
    assert (HM1 : MP mt le1).
    { intros t0 b0 o0 Hm Hg.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hg) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. discriminate Hu.
      - exfalso. pose proof (nth_error_In _ _ Hi) as Hin.
        pose proof (proj1 (forallb_forall _ _) Hpm t0 Hin) as Hn'.
        cbv beta in Hn'. rewrite Hm in Hn'. discriminate Hn'. }
    assert (HS1 : SLI sl e m1).
    { intros x xb ty _ Ex.
      destruct (av_undef _ _ _ _ _ _ Hav
                  ltac:(intros x0 b0 t0 Hq0; rewrite PTree.gempty in Hq0; discriminate Hq0) x xb ty Ex)
        as (Hv1 & Hc).
      split; [ exact Hv1 | ]. intros ofs bb oo Hld. discriminate (Hc ofs _ Hld). }
    destruct (IHb dm nb0 lv tc rc mt sl HN HEI Hchk HP1 HM1
                (conj Hf1 (conj Hnb1 (fun Hd => HL1 (HL Hd)))) HS1)
      as ((Hf2 & Hnb2 & HL2) & _ & Hout & _ & HF & HX & _).
    pose proof Hf2 as (Hv2 & Hs2 & HM2).
    assert (Hfa : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                    (blocks_of_env (lp_ge lp) e)).
    { eapply Forall_impl; [ | exact (blocks_of_env_bm lp bm _ _ _ _ Hav Hv) ].
      intros [[b lo] hi] Hq. exact Hq. }
    destruct (vfc_free_list_frame not_tainted bm _ _ _ Hfa Hfree Hv2 Hs2) as (Hvf & Hsf).
    destruct (u_free lp SafeB nl nb0 _ _ _ Hfree Hnb2) as (Hnb3 & HL3).
    split; [ exact (conj (conj Hvf (conj Hsf (mwf_real_free lp bm bc oc0 SafeB Hbc_bm _ _ _ Hfree HM2)))
                         (conj Hnb3 (fun Hd => HL3 (HL2 Hd)))) | split ].
    - intros bb oo Ev. subst vres.
      destruct out as [ | | | [[v' t']|] ]; cbn in Hor.
      + contradiction Hor.
      + contradiction Hor.
      + destruct (fn_return f); try contradiction Hor; discriminate Hor.
      + destruct Hor as (_ & Hc). exact (Hout _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
      + destruct (fn_return f); try contradiction Hor; discriminate Hor.
    - split.
      + apply FR_trans with m2; [ apply FR_trans with m1; [ exact (av_unch _ _ _ _ _ _ _ Hav) | exact HF ] | ].
        apply (fl_unch _ _ _ _ Hfree). intros b lo hi Hin i _ Hn'. apply Hn'. right; left.
        destruct (boe_in _ _ _ _ _ Hin) as (x & ty & Hx).
        exact (Ple_trans _ _ _ HN (He1 _ _ _ Hx)).
      + apply XS_trans with m2; [ apply XS_trans with m1; [ | exact HX ] | ].
        * exact (XS_unch nb0 m m1 Hnb (av_unch _ _ _ _ _ _ _ Hav)).
        * intros b ofs bb oo _ _ Hld. left. exact (free_list_load_2 _ _ _ Hfree _ _ _ _ Hld).
  Qed.

  (* THE MUTUAL INDUCTION *)
  Lemma x_mutual :
    (forall e le m s t le' m' out,
        exec_stmt function_entry2 ge e le m s t le' m' out -> xPstmt e le m s t le' m' out) /\
    (forall m fd vargs t m' vres,
        eval_funcall function_entry2 ge m fd vargs t m' vres -> xPfun m fd vargs t m' vres).
  Proof.
    apply (exec_stmt_funcall_ind function_entry2 ge xPstmt xPfun); unfold xPstmt, xPfun.
    - (* Sskip *)
      intros e le m. split; [ constructor | ].
      intros dm nb0 lv tc rc mt sl _ _ _ HP HM Hi HS.
      exact (conj Hi (conj HP (conj I (conj HM (conj (FR_refl m) (conj (XS_refl nb0 m) HS)))))).
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hl Hr Hc Ha.
      assert (Hx : exec_stmt function_entry2 ge e le m (Sassign a1 a2) E0 le m' Out_normal)
        by (eapply exec_Sassign; eassumption).
      split; [ exact Hx | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      destruct (xb_store dm nb0 lv tc e mt sl _ _ _ _ _ _ _ _ HN HEI Hchk HP HM Hx Hi HS)
        as (Hi' & HF & HX & HS').
      exact (conj Hi' (conj HP (conj I (conj HM (conj HF (conj HX HS')))))).
    - (* Sset *)
      intros e le m id a v Hev.
      split; [ exact (exec_Sset _ _ _ _ _ _ _ _ Hev) | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      destruct (xb_set dm nb0 lv tc e mt sl id a le m v HEI Hchk HP HM Hi HS Hev) as (HP' & HM').
      exact (conj Hi (conj HP' (conj I (conj HM' (conj (FR_refl m) (conj (XS_refl nb0 m) HS)))))).
    - (* Scall *)
      intros e le m optid a al targs tres cc vf vargs fd t m' vres Hcf Hev Hel Hff Hty _ IHf.
      split; [ exact (exec_Scall _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hcf Hev Hel Hff Hty (proj1 IHf)) | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      destruct (xb_call_ih dm nb0 lv tc e mt sl optid a al le m targs tres cc vf vargs fd t m' vres
                  HN HEI Hchk HP HM Hi HS Hcf Hev Hel Hff Hty IHf) as (Hi' & HP' & HM' & HF & HX & HS').
      exact (conj Hi' (conj HP' (conj I (conj HM' (conj HF (conj HX HS')))))).
    - (* Sbuiltin *)
      intros e le m optid ef al targs vargs t m' vres Hel Hext.
      split; [ exact (exec_Sbuiltin _ _ _ _ _ _ _ _ _ _ _ _ _ Hel Hext) | ].
      intros dm nb0 lv tc rc mt sl _ _ Hchk. cbn [sw_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out D1 (_ & IH1) D2 (_ & IH2).
      split; [ exact (exec_Sseq_1 _ _ _ _ _ _ _ _ _ _ _ _ _ _ D1 D2) | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 dm nb0 lv tc rc mt sl HN HEI H1 HP HM Hi HS) as (Hi1 & HP1 & _ & HM1 & HF1 & HX1 & HS1).
      destruct (IH2 dm nb0 lv tc rc mt sl HN HEI H2 HP1 HM1 Hi1 HS1)
        as (Hi2 & HP2 & Ho2 & HM2 & HF2 & HX2 & HS2).
      exact (conj Hi2 (conj HP2 (conj Ho2 (conj HM2 (conj (FR_trans _ _ _ HF1 HF2)
               (conj (XS_trans _ _ _ _ HX1 HX2) HS2)))))).
    - (* Sseq_2 *)
      intros e le m s1 s2 t1 le1 m1 out D1 (_ & IH1) Hne.
      split; [ exact (exec_Sseq_2 _ _ _ _ _ _ _ _ _ _ _ D1 Hne) | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 _].
      exact (IH1 dm nb0 lv tc rc mt sl HN HEI H1 HP HM Hi HS).
    - (* Sifthenelse *)
      intros e le m a s1 s2 v1 b t le' m' out Hev Hbv D (_ & IH).
      split; [ exact (exec_Sifthenelse _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hev Hbv D) | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      apply (IH dm nb0 lv tc rc mt sl HN HEI);
        [ destruct b; assumption | exact HP | exact HM | exact Hi | exact HS ].
    - (* Sreturn None *)
      intros e le m. split; [ constructor | ].
      intros dm nb0 lv tc rc mt sl _ _ _ HP HM Hi HS.
      exact (conj Hi (conj HP (conj I (conj HM (conj (FR_refl m) (conj (XS_refl nb0 m) HS)))))).
    - (* Sreturn Some *)
      intros e le m a v Hev. split; [ exact (exec_Sreturn_some _ _ _ _ _ _ _ Hev) | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      exact (conj Hi (conj HP (conj (ub_ret lp bm bc oc0 SafeB nl gs Hgs dm nb0 lv tc e HEI _ _ _ _ _ Hchk HP Hi Hev)
                                 (conj HM (conj (FR_refl m) (conj (XS_refl nb0 m) HS)))))).
    - (* Sbreak *)
      intros e le m. split; [ constructor | ].
      intros dm nb0 lv tc rc mt sl _ _ _ HP HM Hi HS.
      exact (conj Hi (conj HP (conj I (conj HM (conj (FR_refl m) (conj (XS_refl nb0 m) HS)))))).
    - (* Scontinue *)
      intros e le m. split; [ constructor | ].
      intros dm nb0 lv tc rc mt sl _ _ _ HP HM Hi HS.
      exact (conj Hi (conj HP (conj I (conj HM (conj (FR_refl m) (conj (XS_refl nb0 m) HS)))))).
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out D (_ & IH) Hbr.
      split; [ exact (exec_Sloop_stop1 _ _ _ _ _ _ _ _ _ _ _ _ D Hbr) | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 _].
      destruct (IH dm nb0 lv tc rc mt sl HN HEI H1 HP HM Hi HS) as (Hi1 & HP1 & Ho1 & HM1 & HF1 & HX1 & HS1).
      split; [ exact Hi1 | split; [ exact HP1 | split; [ | exact (conj HM1 (conj HF1 (conj HX1 HS1))) ] ] ].
      inv Hbr; [ exact I | exact Ho1 ].
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out D1 (_ & IH1) Hnc D2 (_ & IH2) Hbr.
      split; [ eapply exec_Sloop_stop2; [ exact D1 | exact Hnc | exact D2 | exact Hbr ] | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 dm nb0 lv tc rc mt sl HN HEI H1 HP HM Hi HS) as (Hi1 & HP1 & _ & HM1 & HF1 & HX1 & HS1).
      destruct (IH2 dm nb0 lv tc rc mt sl HN HEI H2 HP1 HM1 Hi1 HS1)
        as (Hi2 & HP2 & Ho2 & HM2 & HF2 & HX2 & HS2).
      split; [ exact Hi2 | split; [ exact HP2 | split;
        [ | exact (conj HM2 (conj (FR_trans _ _ _ HF1 HF2) (conj (XS_trans _ _ _ _ HX1 HX2) HS2))) ] ] ].
      inv Hbr; [ exact I | exact Ho2 ].
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out D1 (_ & IH1) Hnc D2 (_ & IH2) D3 (_ & IH3).
      split; [ eapply exec_Sloop_loop; [ exact D1 | exact Hnc | exact D2 | exact D3 ] | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS.
      pose proof Hchk as Hchk'. cbn [sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 dm nb0 lv tc rc mt sl HN HEI H1 HP HM Hi HS) as (Hi1 & HP1 & _ & HM1 & HF1 & HX1 & HS1).
      destruct (IH2 dm nb0 lv tc rc mt sl HN HEI H2 HP1 HM1 Hi1 HS1) as (Hi2 & HP2 & _ & HM2 & HF2 & HX2 & HS2).
      destruct (IH3 dm nb0 lv tc rc mt sl HN HEI Hchk' HP2 HM2 Hi2 HS2)
        as (Hi3 & HP3 & Ho3 & HM3 & HF3 & HX3 & HS3).
      exact (conj Hi3 (conj HP3 (conj Ho3 (conj HM3 (conj (FR_trans _ _ _ (FR_trans _ _ _ HF1 HF2) HF3)
               (conj (XS_trans _ _ _ _ (XS_trans _ _ _ _ HX1 HX2) HX3) HS3)))))).
    - (* Sswitch *)
      intros e le m a t v n sl0 le1 m1 out Hev Hsw D (_ & IH).
      split; [ eapply exec_Sswitch; [ exact Hev | exact Hsw | exact D ] | ].
      intros dm nb0 lv tc rc mt sl HN HEI Hchk HP HM Hi HS. cbn [sw_chk] in Hchk.
      destruct (IH dm nb0 lv tc rc mt sl HN HEI (sw_chk_select _ _ _ _ _ _ Hchk) HP HM Hi HS)
        as (Hi1 & HP1 & Ho1 & HM1 & HF1 & HX1 & HS1).
      split; [ exact Hi1 | split; [ exact HP1 | split; [ | exact (conj HM1 (conj HF1 (conj HX1 HS1))) ] ] ].
      destruct out as [ | | | [[vr tyr]|] ]; cbn; auto.
    - (* funcall internal *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3 Hentry _ IHb Hor Hfree.
      assert (D : eval_funcall function_entry2 ge m (Internal f) vargs t m3 vres)
        by (eapply eval_funcall_internal; [ exact Hentry | exact (proj1 IHb) | exact Hor | exact Hfree ]).
      split; [ exact D | ].
      intros [[pcs rc] dm] Hg.
      destruct Hg as [(f' & Ef & Hchk) | Hlf].
      + injection Ef as <-.
        exact (xb_body f vargs m e le1 m1 t le2 m2 out vres m3 (pcs, rc, dm) Hentry IHb Hor Hfree Hchk).
      + intros nb0 HN Hva Hi. exact (HLeaf _ _ Hlf nb0 HN _ _ _ _ _ D Hva Hi).
    - (* funcall external *)
      intros m ef targs tres cc vargs t vres m' Hext.
      assert (D : eval_funcall function_entry2 ge m (External ef targs tres cc) vargs t m' vres)
        by (eapply eval_funcall_external; exact Hext).
      split; [ exact D | ].
      intros [[pcs rc] dm] Hg.
      destruct Hg as [(f' & Ef & _) | Hlf]; [ discriminate Ef | ].
      intros nb0 HN Hva Hi. exact (HLeaf _ _ Hlf nb0 HN _ _ _ _ _ D Hva Hi).
  Qed.

  (* THE RESULT: every table function meets its spec, frame included *)
  Theorem xgood_spec : forall fd s, xGood fd s -> xspec fd s.
  Proof.
    intros fd [[pcs rc] dm] Hg nb0 HN m vargs t m' vres Hev Hva Hi.
    destruct (proj2 x_mutual _ _ _ _ _ _ Hev) as (_ & IH).
    exact (IH (pcs, rc, dm) Hg nb0 HN Hva Hi).
  Qed.
End XW.
