(* ====================================================================== *)
(* THE GAME-THREAD AUDIO CALLS, PROVED FROM THEIR REAL BODIES (SPINE:      *)
(* the audio link, 2026-10-23).                                            *)
(*                                                                        *)
(* audio/external.c and game/sound_init.c are TUs 40 and 41.  Every audio  *)
(* entry the Mario code calls -- play_sound, stop_sound,                   *)
(* stop_sounds_from_source, set_sound_moving_speed, the background-noise   *)
(* pair, the music queue (play_music / stop_background_music /             *)
(* fadeout_ family), the cap / shell / cutscene / course-clear / Peach jingles,  *)
(* the volume fades, play_infinite_stairs_music -- now resolves to its     *)
(* real generated body, and each is walked here.  The walk accepts a      *)
(* body whose                                                              *)
(*  - stores go to a global-rooted address chain (SaveFileBody.groot_l),   *)
(*    or through a TRACKED temp that only ever holds an address into one   *)
(*    named global (the `seqPlayer = &gSequencePlayers[player]` and        *)
(*    `temp = &D_80360928[player][i]` idioms), and land in a              *)
(*    CensusV2.stored_globals block (any value), or in a global MWF does   *)
(*    not read with a value that cannot be a pointer;                      *)
(*  - calls are to listed functions, themselves proved here (bottom-up),   *)
(*    or to load_sequence;                                                 *)
(*  - loops and switches are allowed (the facts are a loop invariant).     *)
(* Every store index is whatever the memory says (sSoundRequestCount, a    *)
(* sound bank's list links, a player number): the claim is about any      *)
(* execution, so an out-of-range index just has no execution.             *)
(*                                                                        *)
(* The one pointer store is play_sound's pos into sSoundRequests, a        *)
(* stored global since this link (CensusV2, the D_8032CE74/78 class).      *)
(*                                                                        *)
(* THE ONE OPEN AUDIO PREMISE, Hls (labeled; TRUST 4.1): load_sequence     *)
(* (audio/load.c, not linked: sequence DMA and the audio heap) keeps the   *)
(* carried facts.  Every music-starting path reaches it through           *)
(* seq_player_play_sequence; play_sound, the stop / fade paths and the     *)
(* background-noise pair do not.                                           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario audio_external sound_init.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked RealFrameValue AGates CensusV2 RestSurface MWFReal SpawnInit
  MathGeomBodies MathGeomGated SurfaceBodies OutParamSurface LocalVarsSurface
  FloorsSurface MathBodies BullyBodies LinkedTwelve MtxfBody SaveFileBody
  ObjHelpersBodies ObjExtBodies.
From SM64.Proofs Require ActWriterSurface.

Import ListNotations.

Module AX := audio_external.
Module SI := sound_init.

(* ---------------------------------------------------------------------- *)
(* 1. The walk: tw_chk with loops and switches.                             *)
(* ---------------------------------------------------------------------- *)

Section LW.
  Variable ge : genv.
  Variable e : env.
  (* the carried memory invariant (ow_facts for the rows; a footprint
     relation for the GOAL 2 contracts) *)
  Variable Q : mem -> Prop.
  Variable P : temp_env -> Prop.
  Variable set_ok : ident -> expr -> bool.
  Variable store_ok : expr -> expr -> bool.
  Variable call_ok : option ident -> expr -> list expr -> bool.

  Hypothesis Hset : forall id a le m v,
      set_ok id a = true -> P le -> Q m ->
      eval_expr ge e le m a v -> P (PTree.set id v le).
  Hypothesis Hstore : forall lv rhs le m t le' m' out,
      store_ok lv rhs = true -> P le ->
      exec_stmt function_entry2 ge e le m (Sassign lv rhs) t le' m' out ->
      Q m -> Q m'.
  Hypothesis Hcall : forall optid a al le m t le' m' out,
      call_ok optid a al = true -> P le ->
      exec_stmt function_entry2 ge e le m (Scall optid a al) t le' m' out ->
      Q m -> Q m' /\ P le'.

  Fixpoint lw_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue | Sreturn _ => true
    | Sset id a => set_ok id a
    | Sassign lv rhs => store_ok lv rhs
    | Scall optid a al => call_ok optid a al
    | Ssequence s1 s2 => lw_chk s1 && lw_chk s2
    | Sifthenelse _ s1 s2 => lw_chk s1 && lw_chk s2
    | Sloop s1 s2 => lw_chk s1 && lw_chk s2
    | Sswitch _ sl => lw_chk_ls sl
    | _ => false
    end
  with lw_chk_ls (sl : labeled_statements) : bool :=
    match sl with
    | LSnil => true
    | LScons _ s sl' => lw_chk s && lw_chk_ls sl'
    end.

  Lemma lw_chk_ls_seq : forall sl,
      lw_chk_ls sl = true -> lw_chk (seq_of_labeled_statement sl) = true.
  Proof.
    induction sl as [| o s sl0 IH]; intros H; [reflexivity|].
    cbn in H. apply andb_prop in H as [H1 H2].
    cbn. rewrite H1. exact (IH H2).
  Qed.

  Lemma lw_chk_ls_case : forall n sl sl',
      lw_chk_ls sl = true -> select_switch_case n sl = Some sl' ->
      lw_chk_ls sl' = true.
  Proof.
    intros n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel;
      [discriminate Hsel|].
    cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn in Hsel.
    - destruct (zeq c n).
      + injection Hsel as <-. cbn. rewrite H1, H2. reflexivity.
      + exact (IH sl' H2 Hsel).
    - exact (IH sl' H2 Hsel).
  Qed.

  Lemma lw_chk_ls_default : forall sl,
      lw_chk_ls sl = true -> lw_chk_ls (select_switch_default sl) = true.
  Proof.
    induction sl as [| o s sl0 IH]; intros H; [exact H|].
    cbn in H. apply andb_prop in H as [H1 H2].
    destruct o as [c|]; cbn; [exact (IH H2)|rewrite H1, H2; reflexivity].
  Qed.

  Lemma lw_chk_select : forall n sl,
      lw_chk_ls sl = true ->
      lw_chk (seq_of_labeled_statement (select_switch n sl)) = true.
  Proof.
    intros n sl H. apply lw_chk_ls_seq. unfold select_switch.
    destruct (select_switch_case n sl) eqn:E.
    - exact (lw_chk_ls_case _ _ _ H E).
    - exact (lw_chk_ls_default _ H).
  Qed.

  Lemma lw_walk : forall e1 le m s t le' m' out,
      exec_stmt function_entry2 ge e1 le m s t le' m' out -> e1 = e ->
      lw_chk s = true -> P le -> Q m ->
      Q m' /\ P le'.
  Proof.
    intros e1 le m s t le' m' out Hexec.
    induction Hexec; intros He Hchk Hp Hf; subst; cbn [lw_chk] in Hchk;
      try discriminate Hchk.
    - (* Sskip *) split; assumption.
    - (* Sassign *)
      split; [ | exact Hp ].
      lazymatch goal with Hl : eval_lvalue ?gg ?ee ?ll ?mm a1 _ _ _ |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Sassign a1 a2) E0 ll m' Out_normal)
          by (eapply exec_Sassign; eassumption) end.
      exact (Hstore _ _ _ _ _ _ _ _ Hchk Hp Hx Hf).
    - (* Sset *)
      split; [ exact Hf | ]. eapply Hset; eassumption.
    - (* Scall *)
      lazymatch goal with Hee : eval_expr ?gg ?ee ?ll ?mm a _,
                          Hfc : eval_funcall _ _ _ _ _ ?tt ?mm' ?vr |- _ =>
        assert (Hx : exec_stmt function_entry2 gg ee ll mm (Scall optid a al) tt
                       (set_opttemp optid vr ll) mm' Out_normal)
          by (eapply exec_Scall; eassumption) end.
      exact (Hcall _ _ _ _ _ _ _ _ _ Hchk Hp Hx Hf).
    - (* Sseq_1 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as [Hf1 Hp1].
      exact (IHHexec2 eq_refl H2 Hp1 Hf1).
    - (* Sseq_2 *)
      apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hp Hf).
    - (* Sifthenelse *)
      apply andb_prop in Hchk as [H1 H2].
      apply IHHexec; [ reflexivity | destruct b; assumption | exact Hp | exact Hf ].
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - split; assumption.
    - (* Sloop_stop1 *)
      apply andb_prop in Hchk as [H1 _].
      exact (IHHexec eq_refl H1 Hp Hf).
    - (* Sloop_stop2 *)
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as [Hf1 Hp1].
      exact (IHHexec2 eq_refl H2 Hp1 Hf1).
    - (* Sloop_loop *)
      pose proof Hchk as Hchk0.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IHHexec1 eq_refl H1 Hp Hf) as [Hf1 Hp1].
      destruct (IHHexec2 eq_refl H2 Hp1 Hf1) as [Hf2 Hp2].
      exact (IHHexec3 eq_refl Hchk0 Hp2 Hf2).
    - (* Sswitch *)
      exact (IHHexec eq_refl (lw_chk_select _ _ Hchk) Hp Hf).
  Qed.
End LW.

(* the body frame: a no-locals body walked by lw_chk *)
Lemma lw_body_frame :
  forall (ge : genv) (Q : mem -> Prop) (f : Clight.function) P set_ok store_ok call_ok,
    fn_vars f = nil ->
    lw_chk set_ok store_ok call_ok (fn_body f) = true ->
    (forall id a le m v,
       set_ok id a = true -> P le -> Q m ->
       eval_expr ge empty_env le m a v -> P (PTree.set id v le)) ->
    (forall lv rhs le m t le' m' out,
       store_ok lv rhs = true -> P le ->
       exec_stmt function_entry2 ge empty_env le m (Sassign lv rhs) t le' m' out ->
       Q m -> Q m') ->
    (forall optid a al le m t le' m' out,
       call_ok optid a al = true -> P le ->
       exec_stmt function_entry2 ge empty_env le m (Scall optid a al) t le' m' out ->
       Q m -> Q m' /\ P le') ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
      (forall le1, bind_parameter_temps (fn_params f) vargs
                     (create_undef_temps (fn_temps f)) = Some le1 -> P le1) ->
      Q m -> Q m'.
Proof.
  intros ge Q f P set_ok store_ok call_ok Hvars Hchk Hset Hst Hca
         m vargs t m' vres Hevf HP0 Hf0.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    pose proof (HP0 LE Hb) as HP1 end.
  destruct (lw_walk ge empty_env Q P set_ok store_ok call_ok Hset Hst Hca
              _ _ _ _ _ _ _ _ Hbody eq_refl Hchk HP1 Hf0) as (Hf1 & _).
  change (blocks_of_env ge empty_env) with (@nil (block * Z * Z)) in Hfree.
  cbn [Mem.free_list] in Hfree. injection Hfree as <-.
  exact Hf1.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The tracked temps and the recognizers.                                *)
(* ---------------------------------------------------------------------- *)

(* gt: (temp, global) -- the temp only ever holds an address in the global *)
Definition gt_of (gt : list (ident * ident)) (t : ident) : option ident :=
  match find (fun p => Pos.eqb (fst p) t) gt with
  | Some (_, g) => Some g
  | None => None
  end.

Definition au_set_ok (gt : list (ident * ident)) (id : ident) (a : expr) : bool :=
  match gt_of gt id with
  | None => true
  | Some g => match groot_e a with Some g' => Pos.eqb g g' | None => false end
  end.

Definition au_root (gt : list (ident * ident)) (lv : expr) : option ident :=
  match groot_l lv with
  | Some g => Some g
  | None => match chain_root_l lv with Some t => gt_of gt t | None => None end
  end.

(* a right-hand side that is never a pointer: a never-pointer binop, or an
   integer literal (`sSoundBanks[bank][i].soundBits = NO_SOUND`) *)
Definition au_np_rhs (rhs : expr) : bool :=
  ActWriterSurface.nonptr_binop_head rhs
  || match rhs with Econst_int _ _ => true | _ => false end.

Lemma au_np_rhs_eval : forall ge e le m rhs v,
    au_np_rhs rhs = true -> eval_expr ge e le m rhs v -> forall bb oo, v <> Vptr bb oo.
Proof.
  intros ge e le m rhs v Hh Hev. unfold au_np_rhs in Hh.
  apply orb_true_iff in Hh as [Hb | Hc].
  - destruct rhs as [ | | | | | | | | | op r1 r2 rty | | | | ]; try discriminate Hb.
    exact (ActWriterSurface.eval_nonptr_binop_head _ _ _ _ _ _ _ _ _ Hb Hev).
  - destruct rhs; try discriminate Hc.
    inv Hev; [ intros bb oo E; discriminate E |
               match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end ].
Qed.

Definition au_store_ok (gt : list (ident * ident)) (lv rhs : expr) : bool :=
  match au_root gt lv with
  | Some g =>
      MtxfBody.is_byval (typeof lv)
      && (mem_id g stored_globals
          || (negb (mem_id g mwf_syms)
              && (nonptr_scalar (typeof lv) || au_np_rhs rhs)))
  | None => false
  end.

Definition au_call_ok (gt : list (ident * ident)) (ids : list ident)
    (optid : option ident) (a : expr) (al : list expr) : bool :=
  gcall_ok ids a al
  && match optid with Some t => match gt_of gt t with Some _ => false | None => true end
                    | None => true end.

(* no parameter is tracked (they hold whatever the caller passes) *)
Definition au_params_ok (gt : list (ident * ident)) (f : Clight.function) : bool :=
  forallb (fun p => match gt_of gt (fst p) with Some _ => false | None => true end)
    (fn_params f).

Definition au_chk (gt : list (ident * ident)) (ids : list ident) (f : Clight.function) : bool :=
  match fn_vars f with nil => true | _ => false end
  && au_params_ok gt f
  && lw_chk (au_set_ok gt) (au_store_ok gt) (au_call_ok gt ids) (fn_body f).

Lemma bind_notin : forall ps vargs te le t,
    bind_parameter_temps ps vargs te = Some le ->
    forallb (fun p => negb (Pos.eqb (fst p) t)) ps = true ->
    le ! t = te ! t.
Proof.
  induction ps as [| [id ty] ps IH]; intros vargs te le t Hb Hn;
    destruct vargs as [| v0 vr]; cbn in Hb; try discriminate Hb.
  - injection Hb as <-. reflexivity.
  - cbn in Hn. apply andb_prop in Hn as [H1 H2].
    rewrite (IH _ _ _ _ Hb H2).
    apply PTree.gso. intro E; subst. rewrite Pos.eqb_refl in H1. discriminate H1.
Qed.

Lemma gt_of_find : forall gt t g,
    gt_of gt t = Some g -> exists p, In p gt /\ fst p = t.
Proof.
  intros gt t g H. unfold gt_of in H.
  destruct (find (fun p => Pos.eqb (fst p) t) gt) as [[t' g']|] eqn:E; [ | discriminate H ].
  apply find_some in E as [Hin Heq]. apply Pos.eqb_eq in Heq.
  exists (t', g'). auto.
Qed.

Lemma au_params_notin : forall gt f t g,
    au_params_ok gt f = true -> gt_of gt t = Some g ->
    forallb (fun p => negb (Pos.eqb (fst p) t)) (fn_params f) = true.
Proof.
  intros gt f t g Hok Hg. unfold au_params_ok in Hok.
  apply forallb_forall. intros p Hp.
  pose proof (proj1 (forallb_forall _ _) Hok p Hp) as Hq.
  destruct p as [pid pty]. cbn [fst] in Hq |- *.
  destruct (Pos.eqb pid t) eqn:E; [ | reflexivity ].
  apply Pos.eqb_eq in E. subst pid. rewrite Hg in Hq. discriminate Hq.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The rows, at the concrete MWF_real.                                   *)
(* ---------------------------------------------------------------------- *)

(* every audio entry that sits on one of the capstones' any-argument rows
   (obj_ext / cut_ext / sta_ext / floors_ext / warp_ext), plus the cap /
   shell / level music wrappers and the infinite-stairs helper *)
Definition audio_row_ids : list ident :=
  [ AX._play_sound; AX._stop_sound; AX._stop_sounds_from_source;
    AX._set_sound_moving_speed; SI._raise_background_noise; SI._lower_background_noise;
    SI._stop_shell_music; SI._play_cutscene_music; SI._disable_background_sound;
    SI._enable_background_sound; AX._play_course_clear; AX._play_music;
    AX._play_peachs_jingle; SI._fadeout_music; AX._sound_banks_enable;
    AX._seq_player_lower_volume; AX._seq_player_unlower_volume;
    AX._get_current_background_music; SI._stop_cap_music; SI._fadeout_cap_music;
    SI._play_cap_music; SI._play_shell_music; SI._play_infinite_stairs_music;
    SI._fadeout_level_music ].

Definition audio_id (i : ident) : bool := mem_id i audio_row_ids.

Section AudioRows.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.

  (* THE LABELED OPEN AUDIO PREMISE (TRUST 4.1): load_sequence
     (audio/load.c, not linked) keeps Mario's block valid, its action
     untainted, MWF_real and the A-clear controller.  It DMAs a sequence
     into the audio heap and initialises gSequencePlayers[player]: audio
     state, none of it Mario's block, a controller, or a block MWF reads. *)
  Hypothesis Hls : call_pres_ext lp bm NoA MWF AX._load_sequence.

  Definition au_P (gt : list (ident * ident)) (le : temp_env) : Prop :=
    forall t g b o, gt_of gt t = Some g -> le ! t = Some (Vptr b o) ->
      Genv.find_symbol (lp_ge lp) g = Some b.

  Lemma au_set : forall gt id a le m v,
      au_set_ok gt id a = true -> au_P gt le -> ow_facts bm MWF m ->
      eval_expr (lp_ge lp) empty_env le m a v -> au_P gt (PTree.set id v le).
  Proof.
    intros gt id a le m v Hok HP _ Hev t g b o Ht Hle.
    destruct (peq t id) as [-> | Hne].
    - rewrite PTree.gss in Hle. injection Hle as ->.
      unfold au_set_ok in Hok. rewrite Ht in Hok.
      destruct (groot_e a) as [g'|] eqn:Hg; [ | discriminate Hok ].
      apply Pos.eqb_eq in Hok. subst g'.
      destruct (groot_e_val _ _ _ _ _ _ Hg Hev) as (b' & o' & E & Hs).
      injection E as -> ->. exact Hs.
    - rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ _ Ht Hle).
  Qed.

  Lemma au_root_blk : forall gt lv le m loc ofs bf g,
      au_root gt lv = Some g -> au_P gt le ->
      eval_lvalue (lp_ge lp) empty_env le m lv loc ofs bf ->
      Genv.find_symbol (lp_ge lp) g = Some loc.
  Proof.
    intros gt lv le m loc ofs bf g Hr HP Hl.
    unfold au_root in Hr.
    destruct (groot_l lv) as [g0|] eqn:Hg0.
    - injection Hr as <-. exact (groot_l_blk _ _ _ _ _ _ _ _ Hg0 Hl).
    - destruct (chain_root_l lv) as [t|] eqn:Hc; [ | discriminate Hr ].
      destruct (chain_root_l_block _ _ _ _ _ _ _ _ _ Hc Hl) as (o0 & Hle).
      exact (HP _ _ _ _ Hr Hle).
  Qed.

  Lemma au_store : forall gt lv rhs le m t le' m' out,
      au_store_ok gt lv rhs = true -> au_P gt le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros gt lv rhs le m0 t0 le' m0' out Hok HP Hx Hf0.
    unfold au_store_ok in Hok.
    destruct (au_root gt lv) as [g|] eqn:Hg; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hbv Hor].
    apply orb_true_iff in Hor as [Hsg | Hnp].
    - (* a stored global *)
      apply (assign_blk_pres bm MWF (lp_ge lp) empty_env le m0 lv rhs t0 le' m0' out);
        [ | exact Hbv | exact Hx | exact Hf0 ].
      intros loc ofs bf Hl.
      exact (ox_glob_pres lp bm bc oc0 SafeB HSafeB_syms Hspawn g loc Hsg
               (au_root_blk _ _ _ _ _ _ _ _ Hg HP Hl)).
    - (* a global MWF does not read, non-pointer value *)
      apply andb_prop in Hnp as [Hng Hval]. apply negb_true_iff in Hng.
      inv Hx.
      match goal with Hl : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
        pose proof (au_root_blk _ _ _ _ _ _ _ _ Hg HP Hl) as Hfs end.
      match goal with
      | Hr : eval_expr _ _ _ _ rhs ?v2, Hc : sem_cast ?v2 _ _ _ = Some ?v |- _ =>
        assert (Hvnp : forall bb oo, v <> Vptr bb oo);
        [ apply orb_true_iff in Hval as [Hsc | Hbo];
          [ exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hsc Hc)
          | exact (ActWriterSurface.sem_cast_nonptr_pres _ _ _ _ _ Hc
                     (au_np_rhs_eval _ _ _ _ _ _ Hbo Hr)) ]
        | ]
      end.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
      + match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst;
          exact (np_store_pres lp bm bc oc0 SafeB Hspawn _ _ _ _ _ _ _ Hng Hfs Hvnp Hst Hf0) end.
      + unfold MtxfBody.is_byval in Hbv.
        match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
      + match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
        match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hst;
          refine (np_store_pres lp bm bc oc0 SafeB Hspawn _ _ _ _ _ _ _ Hng Hfs _ Hst Hf0);
          intros bb oo E; discriminate E end.
  Qed.

  Let sym_pres := ObjExtBodies.sym_pres lp bm bc oc0 SafeB.

  Lemma au_call : forall gt ids,
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall optid a al le m t le' m' out,
        au_call_ok gt ids optid a al = true -> au_P gt le ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
        ow_facts bm MWF m -> ow_facts bm MWF m' /\ au_P gt le'.
  Proof.
    intros gt ids Hids optid a al le m t le' m' out Hok HP Hx Hf.
    unfold au_call_ok in Hok. apply andb_prop in Hok as [Hc Ho].
    split; [ exact (gcall_pres lp bm bc oc0 SafeB ids Hids optid a al le m t le' m' out Hc Hx Hf) | ].
    inv Hx.
    destruct optid as [ti|]; cbn [set_opttemp]; [ | exact HP ].
    intros t0 g b o Ht Hle.
    destruct (peq t0 ti) as [-> | Hne].
    - rewrite Ht in Ho. discriminate Ho.
    - rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ _ Ht Hle).
  Qed.

  (* THE BODY BRICK *)
  Lemma au_body_pres : forall gt ids f,
      au_chk gt ids f = true ->
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros gt ids f Hchk Hids m vargs t m' vres Hevf Hf.
    unfold au_chk in Hchk.
    apply andb_prop in Hchk as [Hchk Hw]. apply andb_prop in Hchk as [Hv Hpar].
    assert (Hvars : fn_vars f = nil) by (destruct (fn_vars f); [ reflexivity | discriminate Hv ]).
    refine (lw_body_frame (lp_ge lp) (ow_facts bm MWF) f (au_P gt) (au_set_ok gt) (au_store_ok gt)
              (au_call_ok gt ids) Hvars Hw (au_set gt) (au_store gt) (au_call gt ids Hids)
              _ _ _ _ _ Hevf _ Hf).
    intros le1 Hb t0 g b o Ht Hle.
    rewrite (bind_notin _ _ _ _ _ Hb (au_params_notin _ _ _ _ Hpar Ht)) in Hle.
    apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
  Qed.

  (* load_sequence, from the premise *)
  Lemma sp_ls : sym_pres AX._load_sequence.
  Proof.
    intros b fd Hs Hfp m vargs t m' vres Hevf (Hv & Hsat & HM).
    assert (Hres : resolves_lp lp AX._load_sequence fd).
    { exists b. split; [ exact Hs | rewrite Genv.find_funct_find_funct_ptr; exact Hfp ]. }
    destruct (Hls fd m vargs t m' vres Hevf Hres (mwf_real_ctl lp bm bc oc0 SafeB _ HM) HM Hv Hsat)
      as (Hv' & Hs' & HM' & _).
    exact (conj Hv' (conj Hs' HM')).
  Qed.

  Ltac ids_pres :=
    let g := fresh "g" in let Hg := fresh "Hg" in
    intros g Hg; cbn [mem_id existsb] in Hg;
    repeat (apply orb_true_iff in Hg as [Hg | Hg];
            [ apply Pos.eqb_eq in Hg; subst g; assumption | ]);
    discriminate Hg.

  (* q: the defining TU's prog; LO: its linkorder pin *)
  Ltac au_sym q LO f gt ids :=
    refine (sym_pres_of_body lp bm bc oc0 SafeB q _ f LO _ _);
    [ vm_compute; reflexivity
    | apply (au_body_pres gt ids f); [ vm_compute; reflexivity | ids_pres ] ].

  Let LOx := linked12_LO_audio_external lp H12.
  Let LOs := linked12_LO_sound_init lp H12.

  Definition gt_sp : list (ident * ident) := [(AX._seqPlayer, AX._gSequencePlayers)].
  Definition gt_fcvs : list (ident * ident) := [(AX._temp, AX._D_80360928)].

  (* ---- 3a. the leaves (no calls) ---- *)
  Lemma sp_fade_to_zero : sym_pres AX._seq_player_fade_to_zero_volume.
  Proof. au_sym AX.prog LOx AX.f_seq_player_fade_to_zero_volume gt_sp (@nil ident). Qed.
  Lemma sp_8031D690 : sym_pres AX._func_8031D690.
  Proof. au_sym AX.prog LOx AX.f_func_8031D690 gt_sp (@nil ident). Qed.
  Lemma sp_fade_to_pct : sym_pres AX._seq_player_fade_to_percentage_of_volume.
  Proof. au_sym AX.prog LOx AX.f_seq_player_fade_to_percentage_of_volume gt_sp (@nil ident). Qed.
  Lemma sp_fade_to_normal : sym_pres AX._seq_player_fade_to_normal_volume.
  Proof. au_sym AX.prog LOx AX.f_seq_player_fade_to_normal_volume gt_sp (@nil ident). Qed.
  Lemma sp_fade_to_target : sym_pres AX._seq_player_fade_to_target_volume.
  Proof. au_sym AX.prog LOx AX.f_seq_player_fade_to_target_volume gt_sp (@nil ident). Qed.
  Lemma sp_play_sound : sym_pres AX._play_sound.
  Proof. au_sym AX.prog LOx AX.f_play_sound (@nil (ident * ident)) (@nil ident). Qed.
  Lemma sp_set_audio_muted : sym_pres AX._set_audio_muted.
  Proof. au_sym AX.prog LOx AX.f_set_audio_muted (@nil (ident * ident)) (@nil ident). Qed.
  Lemma sp_ssms : sym_pres AX._set_sound_moving_speed.
  Proof. au_sym AX.prog LOx AX.f_set_sound_moving_speed (@nil (ident * ident)) (@nil ident). Qed.
  Lemma sp_banks_disable : sym_pres AX._sound_banks_disable.
  Proof. au_sym AX.prog LOx AX.f_sound_banks_disable (@nil (ident * ident)) (@nil ident). Qed.
  Lemma sp_banks_enable : sym_pres AX._sound_banks_enable.
  Proof. au_sym AX.prog LOx AX.f_sound_banks_enable (@nil (ident * ident)) (@nil ident). Qed.
  Lemma sp_fcvs : sym_pres AX._fade_channel_volume_scale.
  Proof. au_sym AX.prog LOx AX.f_fade_channel_volume_scale gt_fcvs (@nil ident). Qed.
  Lemma sp_gcbm : sym_pres AX._get_current_background_music.
  Proof. au_sym AX.prog LOx AX.f_get_current_background_music (@nil (ident * ident)) (@nil ident). Qed.

  (* ---- 3b. one level up ---- *)
  Lemma sp_fade_out : sym_pres AX._seq_player_fade_out.
  Proof.
    pose proof sp_fade_to_zero.
    au_sym AX.prog LOx AX.f_seq_player_fade_out (@nil (ident * ident))
      [AX._seq_player_fade_to_zero_volume].
  Qed.
  Lemma sp_bbmf : sym_pres AX._begin_background_music_fade.
  Proof.
    pose proof sp_fade_to_normal. pose proof sp_fade_to_target.
    au_sym AX.prog LOx AX.f_begin_background_music_fade (@nil (ident * ident))
      [AX._seq_player_fade_to_normal_volume; AX._seq_player_fade_to_target_volume].
  Qed.
  Lemma sp_803210D4 : sym_pres AX._func_803210D4.
  Proof.
    pose proof sp_fcvs. pose proof sp_fade_to_zero.
    au_sym AX.prog LOx AX.f_func_803210D4 (@nil (ident * ident))
      [AX._fade_channel_volume_scale; AX._seq_player_fade_to_zero_volume].
  Qed.

  (* ---- 3c. two levels up ---- *)
  Lemma sp_ubmas : sym_pres AX._update_background_music_after_sound.
  Proof.
    pose proof sp_bbmf.
    au_sym AX.prog LOx AX.f_update_background_music_after_sound (@nil (ident * ident))
      [AX._begin_background_music_fade].
  Qed.
  Lemma sp_play_seq : sym_pres AX._seq_player_play_sequence.
  Proof.
    pose proof sp_bbmf. pose proof sp_8031D690. pose proof sp_ls.
    au_sym AX.prog LOx AX.f_seq_player_play_sequence (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._func_8031D690; AX._load_sequence].
  Qed.
  Lemma sp_lower_volume : sym_pres AX._seq_player_lower_volume.
  Proof.
    pose proof sp_bbmf. pose proof sp_fade_to_pct.
    au_sym AX.prog LOx AX.f_seq_player_lower_volume (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._seq_player_fade_to_percentage_of_volume].
  Qed.
  Lemma sp_unlower_volume : sym_pres AX._seq_player_unlower_volume.
  Proof.
    pose proof sp_bbmf. pose proof sp_fade_to_normal.
    au_sym AX.prog LOx AX.f_seq_player_unlower_volume (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._seq_player_fade_to_normal_volume].
  Qed.
  Lemma sp_fadeout_bgm : sym_pres AX._fadeout_background_music.
  Proof.
    pose proof sp_fade_out.
    au_sym AX.prog LOx AX.f_fadeout_background_music (@nil (ident * ident))
      [AX._seq_player_fade_out].
  Qed.
  Lemma sp_80321080 : sym_pres AX._func_80321080.
  Proof.
    pose proof sp_bbmf. pose proof sp_fade_out.
    au_sym AX.prog LOx AX.f_func_80321080 (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._seq_player_fade_out].
  Qed.
  Lemma sp_fadeout_music : sym_pres SI._fadeout_music.
  Proof.
    pose proof sp_803210D4.
    au_sym SI.prog LOs SI.f_fadeout_music (@nil (ident * ident)) [AX._func_803210D4].
  Qed.
  Lemma sp_fadeout_level_music : sym_pres SI._fadeout_level_music.
  Proof.
    pose proof sp_fade_out.
    au_sym SI.prog LOs SI.f_fadeout_level_music (@nil (ident * ident)) [AX._seq_player_fade_out].
  Qed.

  (* ---- 3d. three levels up ---- *)
  Lemma sp_stop_sound : sym_pres AX._stop_sound.
  Proof.
    pose proof sp_ubmas.
    au_sym AX.prog LOx AX.f_stop_sound (@nil (ident * ident))
      [AX._update_background_music_after_sound].
  Qed.
  Lemma sp_stop_sounds_from_source : sym_pres AX._stop_sounds_from_source.
  Proof.
    pose proof sp_ubmas.
    au_sym AX.prog LOx AX.f_stop_sounds_from_source (@nil (ident * ident))
      [AX._update_background_music_after_sound].
  Qed.
  Lemma sp_stop_bgm : sym_pres AX._stop_background_music.
  Proof.
    pose proof sp_fade_out. pose proof sp_play_seq.
    au_sym AX.prog LOx AX.f_stop_background_music (@nil (ident * ident))
      [AX._seq_player_fade_out; AX._seq_player_play_sequence].
  Qed.
  Lemma sp_play_music : sym_pres AX._play_music.
  Proof.
    pose proof sp_play_seq. pose proof sp_stop_bgm.
    au_sym AX.prog LOx AX.f_play_music (@nil (ident * ident))
      [AX._seq_player_play_sequence; AX._stop_background_music].
  Qed.
  Lemma sp_play_course_clear : sym_pres AX._play_course_clear.
  Proof.
    pose proof sp_bbmf. pose proof sp_play_seq.
    au_sym AX.prog LOx AX.f_play_course_clear (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._seq_player_play_sequence].
  Qed.
  Lemma sp_play_peachs_jingle : sym_pres AX._play_peachs_jingle.
  Proof.
    pose proof sp_bbmf. pose proof sp_play_seq.
    au_sym AX.prog LOx AX.f_play_peachs_jingle (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._seq_player_play_sequence].
  Qed.
  Lemma sp_play_secondary_music : sym_pres AX._play_secondary_music.
  Proof.
    pose proof sp_bbmf. pose proof sp_fade_to_target. pose proof sp_play_seq.
    au_sym AX.prog LOx AX.f_play_secondary_music (@nil (ident * ident))
      [AX._begin_background_music_fade; AX._seq_player_fade_to_target_volume;
       AX._seq_player_play_sequence].
  Qed.
  Lemma sp_raise_bgn : sym_pres SI._raise_background_noise.
  Proof.
    pose proof sp_unlower_volume. pose proof sp_set_audio_muted.
    au_sym SI.prog LOs SI.f_raise_background_noise (@nil (ident * ident))
      [AX._seq_player_unlower_volume; AX._set_audio_muted].
  Qed.
  Lemma sp_lower_bgn : sym_pres SI._lower_background_noise.
  Proof.
    pose proof sp_lower_volume. pose proof sp_set_audio_muted.
    au_sym SI.prog LOs SI.f_lower_background_noise (@nil (ident * ident))
      [AX._seq_player_lower_volume; AX._set_audio_muted].
  Qed.
  Lemma sp_disable_bgs : sym_pres SI._disable_background_sound.
  Proof.
    pose proof sp_banks_disable.
    au_sym SI.prog LOs SI.f_disable_background_sound (@nil (ident * ident))
      [AX._sound_banks_disable].
  Qed.
  Lemma sp_enable_bgs : sym_pres SI._enable_background_sound.
  Proof.
    pose proof sp_banks_enable.
    au_sym SI.prog LOs SI.f_enable_background_sound (@nil (ident * ident))
      [AX._sound_banks_enable].
  Qed.
  Lemma sp_fadeout_cap_music : sym_pres SI._fadeout_cap_music.
  Proof.
    pose proof sp_fadeout_bgm.
    au_sym SI.prog LOs SI.f_fadeout_cap_music (@nil (ident * ident))
      [AX._fadeout_background_music].
  Qed.

  (* ---- 3e. the sound_init.c wrappers ---- *)
  Lemma sp_stop_cap_music : sym_pres SI._stop_cap_music.
  Proof.
    pose proof sp_stop_bgm.
    au_sym SI.prog LOs SI.f_stop_cap_music (@nil (ident * ident)) [AX._stop_background_music].
  Qed.
  Lemma sp_stop_shell_music : sym_pres SI._stop_shell_music.
  Proof.
    pose proof sp_stop_bgm.
    au_sym SI.prog LOs SI.f_stop_shell_music (@nil (ident * ident)) [AX._stop_background_music].
  Qed.
  Lemma sp_play_cap_music : sym_pres SI._play_cap_music.
  Proof.
    pose proof sp_play_music. pose proof sp_stop_bgm.
    au_sym SI.prog LOs SI.f_play_cap_music (@nil (ident * ident))
      [AX._play_music; AX._stop_background_music].
  Qed.
  Lemma sp_play_shell_music : sym_pres SI._play_shell_music.
  Proof.
    pose proof sp_play_music.
    au_sym SI.prog LOs SI.f_play_shell_music (@nil (ident * ident)) [AX._play_music].
  Qed.
  Lemma sp_play_cutscene_music : sym_pres SI._play_cutscene_music.
  Proof.
    pose proof sp_play_music.
    au_sym SI.prog LOs SI.f_play_cutscene_music (@nil (ident * ident)) [AX._play_music].
  Qed.
  Lemma sp_pism : sym_pres SI._play_infinite_stairs_music.
  Proof.
    pose proof sp_80321080. pose proof sp_play_secondary_music.
    au_sym SI.prog LOs SI.f_play_infinite_stairs_music (@nil (ident * ident))
      [AX._func_80321080; AX._play_secondary_music].
  Qed.

  (* ---- 4. the rows ---- *)

  (* the any-argument row of every audio entry the Mario code calls *)
  Lemma audio_rows : forall fid, mem_id fid audio_row_ids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. apply (row_of_sym lp bm bc oc0 SafeB).
    unfold audio_row_ids in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [H | H];
            [ apply Pos.eqb_eq in H; subst fid | ]); try discriminate H.
    - exact sp_play_sound.
    - exact sp_stop_sound.
    - exact sp_stop_sounds_from_source.
    - exact sp_ssms.
    - exact sp_raise_bgn.
    - exact sp_lower_bgn.
    - exact sp_stop_shell_music.
    - exact sp_play_cutscene_music.
    - exact sp_disable_bgs.
    - exact sp_enable_bgs.
    - exact sp_play_course_clear.
    - exact sp_play_music.
    - exact sp_play_peachs_jingle.
    - exact sp_fadeout_music.
    - exact sp_banks_enable.
    - exact sp_lower_volume.
    - exact sp_unlower_volume.
    - exact sp_gcbm.
    - exact sp_stop_cap_music.
    - exact sp_fadeout_cap_music.
    - exact sp_play_cap_music.
    - exact sp_play_shell_music.
    - exact sp_pism.
    - exact sp_fadeout_level_music.
  Qed.

  (* the rest-surface residual of a pinned audio body *)
  Lemma bpw_of_sym : forall (q : Clight.program) g f,
      linkorder q lp -> (prog_defmap q) ! g = Some (Gfun (Internal f)) ->
      sym_pres g -> body_pres_w lp MWF bm SafeB f.
  Proof.
    intros q g f LO Hdm Hp m vargs t m' vres _ Hevf HM Hv Hsat.
    destruct (linkorder_resolves_funct lp q g f LO Hdm) as (b & Hs & Hf).
    rewrite Genv.find_funct_find_funct_ptr in Hf.
    exact (Hp b _ Hs Hf _ _ _ _ _ Hevf (conj Hv (conj Hsat HM))).
  Qed.

  Lemma Hps_body_proved : body_pres_w lp MWF bm SafeB AX.f_play_sound.
  Proof. exact (bpw_of_sym _ _ _ LOx audio_defmap_ps sp_play_sound). Qed.
  Lemma Hstcm_body_proved : body_pres_w lp MWF bm SafeB SI.f_stop_cap_music.
  Proof. exact (bpw_of_sym _ _ _ LOs sinit_defmap_scm sp_stop_cap_music). Qed.
  Lemma Hfcm_body_proved : body_pres_w lp MWF bm SafeB SI.f_fadeout_cap_music.
  Proof. exact (bpw_of_sym _ _ _ LOs sinit_defmap_fcm sp_fadeout_cap_music). Qed.
  Lemma Hpism_body_proved :
    body_pres_w lp MWF bm SafeB SI.f_play_infinite_stairs_music.
  Proof. exact (bpw_of_sym _ _ _ LOs sinit_defmap_pism sp_pism). Qed.
End AudioRows.

(* ---------------------------------------------------------------------- *)
(* 4. Footprints (for GOAL 2's clobber contracts, WMotRRequiresA.SndXc):   *)
(*    a no-locals body whose every store lands in one of the named globals *)
(*    ids changes memory only inside those globals' blocks, at offsets     *)
(*    0 .. 2^32, and keeps nextblock and every permission.                 *)
(* ---------------------------------------------------------------------- *)

(* a chunk whose size is its alignment (all but Mfloat64 / Many64) *)
Definition chunk_sa (ch : memory_chunk) : bool := Z.eqb (size_chunk ch) (align_chunk ch).

Lemma store_end : forall ch m b ofs v m', chunk_sa ch = true ->
    Mem.store ch m b (Ptrofs.unsigned ofs) v = Some m' ->
    Ptrofs.unsigned ofs + size_chunk ch <= Ptrofs.modulus.
Proof.
  intros ch m b ofs v m' Hch Hs.
  apply Mem.store_valid_access_3 in Hs. destruct Hs as [_ [k Hk]].
  pose proof (Ptrofs.unsigned_range ofs) as Hr.
  assert (M : Ptrofs.modulus = 4294967296) by reflexivity. rewrite M in *.
  destruct ch; cbn in Hch; try discriminate Hch; unfold align_chunk, size_chunk in *; lia.
Qed.

Lemma void_ret : forall (ge : genv) f m vargs t m' vres,
    fn_return f = Tvoid ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' vres -> vres = Vundef.
Proof.
  intros ge f m vargs t m' vres Hr H. inv H.
  match goal with Ho : outcome_result_value _ _ _ _ |- _ => rewrite Hr in Ho; revert Ho end.
  unfold outcome_result_value.
  match goal with |- context [match ?o with _ => _ end] => destruct o as [ | | | [[v' t']|] ] end;
    intros Ho; try exact Ho; try contradiction.
  destruct Ho as [N _]. exfalso. exact (N eq_refl).
Qed.

Lemma au_P_nil : forall lp le, au_P lp nil le.
Proof. intros lp le t g b o H. discriminate H. Qed.

Section FP.
  Variable lp : Clight.program.
  Variable ids : list ident.
  Variable blks : list block.
  Hypothesis Hblks : forall g b, mem_id g ids = true ->
    Genv.find_symbol (lp_ge lp) g = Some b -> In b blks.
  Variable m0 : mem.

  Definition fp_P (b : block) (z : Z) : Prop := ~ (In b blks /\ 0 <= z < Ptrofs.modulus).
  Definition fp_rel (m : mem) : Prop :=
    Mem.unchanged_on fp_P m0 m /\ Mem.nextblock m = Mem.nextblock m0
    /\ (forall b o k p, Mem.perm m b o k p <-> Mem.perm m0 b o k p).

  Lemma fp_store : forall ch m b ofs v m', chunk_sa ch = true -> In b blks ->
      Mem.store ch m b (Ptrofs.unsigned ofs) v = Some m' -> fp_rel m -> fp_rel m'.
  Proof.
    intros ch m b ofs v m' Hch Hb Hs (U & N & P).
    pose proof (store_end _ _ _ _ _ _ Hch Hs) as He.
    pose proof (Ptrofs.unsigned_range ofs) as Hr.
    split; [ | split ].
    - eapply Mem.unchanged_on_trans; [ exact U | ].
      eapply Mem.store_unchanged_on; [ exact Hs | ].
      intros i Hi HP. apply HP. split; [ exact Hb | lia ].
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hs). exact N.
    - intros b' o k p. rewrite <- P. split.
      + eapply Mem.perm_store_2; eassumption.
      + eapply Mem.perm_store_1; eassumption.
  Qed.

  Definition fp_store_ok (lv rhs : expr) : bool :=
    match au_root nil lv with
    | Some g => mem_id g ids && MtxfBody.is_byval (typeof lv)
                && match access_mode (typeof lv) with
                   | By_value ch => chunk_sa ch | _ => true end
    | None => false
    end.

  Lemma fp_assign : forall lv rhs le m t le' m' out,
      fp_store_ok lv rhs = true ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign lv rhs) t le' m' out ->
      fp_rel m -> fp_rel m'.
  Proof.
    intros lv rhs le m t le' m' out Hok Hx Hf.
    unfold fp_store_ok in Hok.
    destruct (au_root nil lv) as [g|] eqn:Hg; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hok Hsa]. apply andb_prop in Hok as [Hm Hbv].
    inv Hx.
    match goal with Hl : eval_lvalue _ _ _ _ lv ?loc _ _ |- _ =>
      pose proof (au_root_blk lp nil lv _ _ _ _ _ g Hg (au_P_nil lp _) Hl) as Hfs end.
    pose proof (Hblks _ _ Hm Hfs) as Hin.
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end.
    - match goal with Hst : Mem.storev _ _ _ _ = Some _,
                      Ham : access_mode _ = By_value _ |- _ =>
        unfold Mem.storev in Hst; rewrite Ham in Hsa;
        exact (fp_store _ _ _ _ _ _ Hsa Hin Hst Hf) end.
    - unfold MtxfBody.is_byval in Hbv.
      match goal with Hc : access_mode _ = By_copy |- _ => rewrite Hc in Hbv; discriminate Hbv end.
    - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
      match goal with Hst : Mem.storev _ _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hst;
        refine (fp_store _ _ _ _ _ _ _ Hin Hst Hf) end.
      match goal with |- chunk_sa (chunk_for_carrier ?sz) = true => destruct sz; reflexivity end.
  Qed.

  Lemma fp_body : forall f, fn_vars f = nil ->
      lw_chk (fun _ _ => true) fp_store_ok (fun _ _ _ => false) (fn_body f) = true ->
      forall vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m0 (Internal f) vargs t m' vres ->
        fp_rel m'.
  Proof.
    intros f Hv Hc vargs t m' vres Hev.
    refine (lw_body_frame (lp_ge lp) fp_rel f (fun _ => True) _ _ _ Hv Hc _ _ _
              m0 vargs t m' vres Hev (fun _ _ => I) _).
    - intros; exact I.
    - intros lv rhs le m t0 le' m1 out Hok _ Hx Hf. exact (fp_assign _ _ _ _ _ _ _ _ Hok Hx Hf).
    - intros optid a al le m t0 le' m1 out Hok. discriminate Hok.
    - split; [ apply Mem.unchanged_on_refl | split; [ reflexivity | tauto ] ].
  Qed.
End FP.
