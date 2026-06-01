(* ValueFrameStmt.v -- THE STATEMENT-LEVEL BUNDLE FRAME (the assembly).
 *
 * ActionValueFrame.exec_stmt_value_preserves already threads {valid, action_sat}
 * through a whole statement (calls/loops/switch included), consuming a per-Sassign
 * obligation stmt_value_ok quantified `forall le m`. That obligation is FALSE for
 * chase stores `p->..f = rhs`: under an arbitrary le, p could point INTO Mario's
 * block bm. ValueFrameINV's engine fixed that by threading a temp-provenance
 * invariant tmps_off_bm at RUNTIME -- but that means the invariant must be threaded
 * THROUGH the statement induction, not assumed once. This file does that: a fresh
 * induction over exec_stmt carrying the 4-part bundle
 *
 *     Mem.valid_block m bm  /\  action_sat Q m bm
 *  /\ tmps_off_bm bm _m le  /\  mem_wf FS m bm
 *
 * (mem_wf = "the chased pointer fields FS all load off-bm in m" -- what re-creates
 * tmps_off_bm at each chase-LOAD Sset). The chase-store Sassign case drops in from
 * ValueFrameINV.rooted_store_*; the chase-load Sset case from tmps_off_bm_set_field;
 * direct stores from the value-ok / offset-disjoint route; control flow & calls
 * structurally (calls via reach-style callee assumptions, exactly as
 * ActionValueFrame.reach_value_preserves).
 *
 * THIS FILE grows the frame bottom-up; each commit is green + axiom-clean.
 * Stage 1a (here): mem_wf + the keystone -- a chase store leaves Mario's whole
 * block bm UNCHANGED (it lands off-bm), so it preserves action_sat AND mem_wf AND
 * validity at once, with le untouched (so tmps_off_bm survives trivially).
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import List Lia.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Proofs Require Import Flying ActionFrame ActionValueFrame MarioMemWF ResetBodystate RootedLvalue ValueFrameINV.

(* Memory well-formedness for a SET of chased pointer fields: each field in FS
   loads, in m, a pointer into a block other than Mario's block bm. This is what
   the chase-LOAD Ssets consume (via field_loads_off_bm) to re-establish
   tmps_off_bm, so the frame must thread it forward across the body. *)
Definition mem_wf (FS : list ident) (m : mem) (bm : block) : Prop :=
  forall fid, In fid FS -> field_loads_off_bm m bm fid.

(* ================================================================== *)
(* THE KEYSTONE. A chase store (lvalue rooted at a non-Mario temp p)    *)
(* leaves Mario's WHOLE block bm unchanged: the store lands in p's       *)
(* block, which tmps_off_bm puts off bm. Phrased as Mem.unchanged_on     *)
(* (fun b _ => b = bm) so it drives BOTH preservation facts (action_sat  *)
(* at (bm,12); the chased-field loads at (bm,off)) in one stroke.        *)
(* Generalizes the action_sat-only ValueFrameINV.rooted_store_preserves  *)
(* by keeping the full unchanged_on rather than just the load at 12.     *)
(* ================================================================== *)
Lemma rooted_store_unchanged_bm :
  forall ge e le m p lhs rhs t le' m' out bm,
    tmps_off_bm bm mario._m le ->
    p <> mario._m ->
    rooted_lv p lhs = true ->
    exec_stmt function_entry2 ge e le m (Sassign lhs rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.unchanged_on (fun b _ => b = bm) m m'.
Proof.
  intros ge e le m p lhs rhs t le' m' out bm Hinv Hp Hroot Hexec.
  pose proof Hexec as Hc. inv Hc.
  match goal with Hlv : eval_lvalue _ _ _ _ lhs _ _ _ |- _ =>
    destruct (rooted_lv_root_value _ _ _ _ p _ _ _ _ Hlv Hroot) as (pb & po & Hlk) end.
  assert (Hpb : pb <> bm) by (eapply Hinv; [ exact Hp | exact Hlk ]).
  match goal with Hlv : eval_lvalue _ _ _ _ lhs ?loc ?ofs ?bf |- _ =>
    assert (Hloc : loc = pb) by (eapply eval_lvalue_rooted; [ exact Hlk | exact Hlv | exact Hroot ]);
    subst loc end.
  split; [ reflexivity | split; [ reflexivity | ] ].
  match goal with Hass : assign_loc _ _ _ pb _ _ _ _ |- _ =>
    eapply assign_loc_unchanged_on; [ exact Hass | ] end.
  intros i _. exact Hpb.
Qed.

(* unchanged_on the whole bm block transports mem_wf forward (every chased
   field's load at (bm,off) is preserved). *)
Lemma unchanged_bm_preserves_mem_wf :
  forall FS m m' bm,
    Mem.unchanged_on (fun b _ => b = bm) m m' ->
    Mem.valid_block m bm ->
    mem_wf FS m bm ->
    mem_wf FS m' bm.
Proof.
  intros FS m m' bm Hu Hv Hwf fid Hin.
  destruct (Hwf fid Hin) as (off & b & ofs & Hfo & Hbound & Hld & Hboff).
  exists off, b, ofs.
  split; [ exact Hfo | split; [ exact Hbound | split; [ | exact Hboff ] ] ].
  assert (Heq : Mem.load Mptr m' bm off = Mem.load Mptr m bm off)
    by (eapply Mem.load_unchanged_on_1; [ exact Hu | exact Hv | intros i _; reflexivity ]).
  rewrite Heq. exact Hld.
Qed.

(* unchanged_on the whole bm block transports action_sat forward (the load at
   (bm,12) is within the block, hence preserved). *)
Lemma unchanged_bm_preserves_action_sat :
  forall (Q : int -> Prop) m m' bm,
    Mem.unchanged_on (fun b _ => b = bm) m m' ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    action_sat Q m' bm.
Proof.
  intros Q m m' bm Hu Hv Hsat.
  eapply action_sat_unchanged_on; [ | exact Hv | exact Hsat ].
  eapply Mem.unchanged_on_implies; [ exact Hu | ].
  intros b o [Hb _] _. exact Hb.
Qed.

(* ================================================================== *)
(* THE CHASE-STORE BUNDLE HELPER. A chase store preserves the ENTIRE     *)
(* 4-part bundle: validity, action_sat, tmps_off_bm (le untouched), and  *)
(* mem_wf. This is the Sassign-chase case of the statement induction.    *)
(* ================================================================== *)
Lemma chase_store_preserves_bundle :
  forall FS (Q : int -> Prop) e le m p lhs rhs t le' m' out bm,
    tmps_off_bm bm mario._m le ->
    p <> mario._m ->
    rooted_lv p lhs = true ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    mem_wf FS m bm ->
    exec_stmt function_entry2 mario_ge e le m (Sassign lhs rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\
    Mem.valid_block m' bm /\ action_sat Q m' bm /\
    tmps_off_bm bm mario._m le' /\ mem_wf FS m' bm.
Proof.
  intros FS Q e le m p lhs rhs t le' m' out bm Hinv Hp Hroot Hv Hsat Hwf Hexec.
  destruct (rooted_store_unchanged_bm _ _ _ _ _ _ _ _ _ _ _ _ Hinv Hp Hroot Hexec)
    as (Hle & Hout & Hu).
  subst le'.
  split; [ reflexivity | split; [ exact Hout | ] ].
  split; [ eapply Mem.valid_block_unchanged_on; [ exact Hu | exact Hv ] | ].
  split; [ eapply unchanged_bm_preserves_action_sat; [ exact Hu | exact Hv | exact Hsat ] | ].
  split; [ exact Hinv | ].
  eapply unchanged_bm_preserves_mem_wf; [ exact Hu | exact Hv | exact Hwf ].
Qed.

(* ================================================================== *)
(* THE DIRECT-STORE WATCH SET. A direct store `m->fid = rhs` lands IN   *)
(* bm; to preserve the bundle it must AVOID two regions: the action      *)
(* cell (so action_sat survives) AND every chased pointer field's load   *)
(* range (so mem_wf survives). Both are static byte-ranges in bm, so we  *)
(* fold them into one watched set `watch` and demand the store avoid it. *)
(* (A direct LITERAL write of m->action -- a raw action writer -- is NOT *)
(* covered by "avoid"; such functions need the value-store disjunct, a   *)
(* later stage. The chase functions targeted here write the action field *)
(* only through the set_mario_action call, handled by the Scall case.)   *)
(* ================================================================== *)

(* the static byte-range of a chased pointer field's load in bm. *)
Definition chased_byte (FS : list ident) (bm : block) : block -> Z -> Prop :=
  fun b o => b = bm /\ exists fid off, In fid FS /\
             field_offset mario_ce fid mario_members = OK (off, Full) /\
             off <= o < off + size_chunk Mptr.

Definition watch (FS : list ident) (bm : block) : block -> Z -> Prop :=
  fun b o => action_cell bm b o \/ chased_byte FS bm b o.

Lemma unchanged_watch_preserves_action_sat :
  forall FS (Q : int -> Prop) m m' bm,
    Mem.unchanged_on (watch FS bm) m m' ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    action_sat Q m' bm.
Proof.
  intros FS Q m m' bm Hu Hv Hsat.
  eapply action_sat_unchanged_on; [ | exact Hv | exact Hsat ].
  eapply Mem.unchanged_on_implies; [ exact Hu | ].
  intros b o Hac _. left. exact Hac.
Qed.

Lemma unchanged_watch_preserves_mem_wf :
  forall FS m m' bm,
    Mem.unchanged_on (watch FS bm) m m' ->
    Mem.valid_block m bm ->
    mem_wf FS m bm ->
    mem_wf FS m' bm.
Proof.
  intros FS m m' bm Hu Hv Hwf fid Hin.
  destruct (Hwf fid Hin) as (off & b & ofs & Hfo & Hbound & Hld & Hboff).
  exists off, b, ofs.
  split; [ exact Hfo | split; [ exact Hbound | split; [ | exact Hboff ] ] ].
  assert (Heq : Mem.load Mptr m' bm off = Mem.load Mptr m bm off).
  { eapply Mem.load_unchanged_on_1; [ exact Hu | exact Hv | ].
    intros i Hi. right. split; [ reflexivity | ].
    exists fid, off. split; [ exact Hin | split; [ exact Hfo | exact Hi ] ]. }
  rewrite Heq. exact Hld.
Qed.

(* ================================================================== *)
(* THE PER-STATEMENT OBLIGATION and the bundle invariant `fr`.          *)
(* ================================================================== *)

(* The Sset obligation: in any state where the invariant holds, the rhs  *)
(* evaluates to a value that, if a pointer and the target temp is not _m, *)
(* points off bm -- so the Sset re-establishes tmps_off_bm. Dischargeable *)
(* for chase-loads (m->fid, fid in FS) via mem_wf, for scalar sets        *)
(* (no Vptr), and for off-bm pointer copies via tmps_off_bm.              *)
Definition set_off_bm_ok (FS : list ident) (bm : block) (e : env)
                         (id : ident) (a : expr) : Prop :=
  forall le m v,
    tmps_off_bm bm mario._m le ->
    mem_wf FS m bm ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    eval_expr mario_ge e le m a v ->
    id <> mario._m ->
    forall b o, v = Vptr b o -> b <> bm.

(* The whole-statement obligation. Sassign: chase OR avoid-the-watch-set.  *)
(* Sset: target not _m and the rhs keeps tmps_off_bm. Scall: result temp   *)
(* (if any) not _m (off-bm-ness of the result comes from the callee, via   *)
(* reach_frame_preserves). Sbuiltin: unsupported for now (False). Control  *)
(* flow / sequencing: recurse. Leaves: True. *)
Fixpoint body_nf_ok (FS : list ident) (bm : block) (e : env) (s : statement) : Prop :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ | Sgoto _ => True
  | Sassign a1 a2 =>
      (exists p, p <> mario._m /\ rooted_lv p a1 = true)
      \/ assign_avoids (watch FS bm) mario_ge e a1
  | Sset id a => id <> mario._m /\ set_off_bm_ok FS bm e id a
  | Scall optid a al => match optid with None => True | Some id => id <> mario._m end
  | Sbuiltin _ _ _ _ => False
  | Ssequence s1 s2 => body_nf_ok FS bm e s1 /\ body_nf_ok FS bm e s2
  | Sifthenelse _ s1 s2 => body_nf_ok FS bm e s1 /\ body_nf_ok FS bm e s2
  | Sloop s1 s2 => body_nf_ok FS bm e s1 /\ body_nf_ok FS bm e s2
  | Slabel _ s1 => body_nf_ok FS bm e s1
  | Sswitch _ ls => ls_body_nf_ok FS bm e ls
  end
with ls_body_nf_ok (FS : list ident) (bm : block) (e : env)
                   (ls : labeled_statements) : Prop :=
  match ls with
  | LSnil => True
  | LScons _ s rest => body_nf_ok FS bm e s /\ ls_body_nf_ok FS bm e rest
  end.

(* switch structural lemmas (mirror ActionValueFrame's *_value_ok). *)
Lemma ssd_body_nf_ok :
  forall FS bm e sl, ls_body_nf_ok FS bm e sl ->
    ls_body_nf_ok FS bm e (select_switch_default sl).
Proof.
  induction sl as [| o s rest IH]; simpl; intros H; auto.
  destruct o as [c|]; simpl.
  - destruct H as [_ Hrest]. apply IH; exact Hrest.
  - exact H.
Qed.

Lemma ssc_body_nf_ok :
  forall FS bm e n sl res,
    ls_body_nf_ok FS bm e sl -> select_switch_case n sl = Some res ->
    ls_body_nf_ok FS bm e res.
Proof.
  induction sl as [| o s rest IH]; simpl; intros res Hav Hsel; try discriminate.
  destruct Hav as [Hs Hrest]. destruct o as [c|]; simpl in Hsel.
  - destruct (zeq c n).
    + inv Hsel. simpl. split; [ exact Hs | exact Hrest ].
    + eapply IH; eauto.
  - eapply IH; eauto.
Qed.

Lemma select_switch_body_nf_ok :
  forall FS bm e n sl,
    ls_body_nf_ok FS bm e sl -> ls_body_nf_ok FS bm e (select_switch n sl).
Proof.
  intros FS bm e n sl H. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - eapply ssc_body_nf_ok; eauto.
  - apply ssd_body_nf_ok; auto.
Qed.

Lemma seq_of_ls_body_nf_ok :
  forall FS bm e ls,
    ls_body_nf_ok FS bm e ls -> body_nf_ok FS bm e (seq_of_labeled_statement ls).
Proof.
  induction ls as [| o s rest IH]; simpl; intros H; auto.
  destruct H. split; auto.
Qed.

(* The bundle invariant threaded by the frame. *)
Definition fr (FS : list ident) (Q : int -> Prop) (bm : block)
              (m : mem) (le : temp_env) : Prop :=
  Mem.valid_block m bm /\
  action_sat Q m bm /\
  tmps_off_bm bm mario._m le /\
  mem_wf FS m bm /\
  le ! mario._m = Some (Vptr bm Ptrofs.zero).

(* The honest call boundary (value analogue of reach_value_preserves, but   *)
(* carrying mem_wf and the result-off-bm fact too). Any reached funcall that *)
(* starts with the (valid, action_sat, mem_wf) part of the bundle holding    *)
(* preserves all three and returns a value off bm. To be discharged later by *)
(* the whole-program closure; here an explicit assumption, not hidden. *)
Definition reach_frame_preserves (FS : list ident) (Q : int -> Prop)
                                 (bm : block) (ge : genv) : Prop :=
  forall m fd vargs t m' vres,
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    mem_wf FS m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ mem_wf FS m' bm
    /\ (forall b o, vres = Vptr b o -> b <> bm).

(* ================================================================== *)
(* THE FRAME. Executing any clightgen statement satisfying body_nf_ok    *)
(* carries the whole bundle fr forward, given the reach assumption for    *)
(* calls. Induction over exec_stmt mirroring                              *)
(* ActionValueFrame.exec_stmt_value_preserves, but threading tmps_off_bm  *)
(* and mem_wf (and le!_m) alongside validity and action_sat.              *)
(* ================================================================== *)
Theorem exec_body_nf :
  forall (FS : list ident) (Q : int -> Prop) (bm : block),
    reach_frame_preserves FS Q bm mario_ge ->
    forall e le m s t le' m' out,
      exec_stmt function_entry2 mario_ge e le m s t le' m' out ->
      fr FS Q bm m le ->
      body_nf_ok FS bm e s ->
      fr FS Q bm m' le'.
Proof.
  intros FS Q bm Hreach e le m s t le' m' out H.
  induction H; intros Hfr Hok.
  - (* Sskip *) exact Hfr.
  - (* Sassign *)
    destruct Hfr as (Hv & Hsat & Htmps & Hwf & Hmle).
    simpl in Hok.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ ?a1v ?loc ?ofs ?bf,
      Hass : assign_loc _ _ _ ?loc ?ofs ?bf ?vv ?mm |- _ =>
      destruct Hok as [ (p & Hpm & Hr) | Havoid ];
      [ (* chase store: lands off bm *)
        destruct (rooted_lv_root_value _ _ _ _ p _ _ _ _ Hlv Hr) as (pb & po & Hlk);
        assert (Hpb : pb <> bm) by (eapply Htmps; [ exact Hpm | exact Hlk ]);
        assert (Hloc : loc = pb) by (eapply eval_lvalue_rooted; [ exact Hlk | exact Hlv | exact Hr ]);
        subst loc;
        assert (Hu : Mem.unchanged_on (fun b _ => b = bm) m mm)
          by (eapply assign_loc_unchanged_on; [ exact Hass | intros i _; exact Hpb ]);
        unfold fr; repeat split;
          [ eapply Mem.valid_block_unchanged_on; [ exact Hu | exact Hv ]
          | eapply unchanged_bm_preserves_action_sat; [ exact Hu | exact Hv | exact Hsat ]
          | exact Htmps
          | eapply unchanged_bm_preserves_mem_wf; [ exact Hu | exact Hv | exact Hwf ]
          | exact Hmle ]
      | (* direct/other store: avoids the watch set *)
        assert (Hu : Mem.unchanged_on (watch FS bm) m mm)
          by (eapply assign_loc_unchanged_on;
                [ exact Hass | intros i Hi; eapply (Havoid _ _ _ _ _ Hlv); exact Hi ]);
        unfold fr; repeat split;
          [ eapply Mem.valid_block_unchanged_on; [ exact Hu | exact Hv ]
          | eapply unchanged_watch_preserves_action_sat; [ exact Hu | exact Hv | exact Hsat ]
          | exact Htmps
          | eapply unchanged_watch_preserves_mem_wf; [ exact Hu | exact Hv | exact Hwf ]
          | exact Hmle ] ]
    end.
  - (* Sset *)
    destruct Hfr as (Hv & Hsat & Htmps & Hwf & Hmle).
    simpl in Hok. destruct Hok as (Hidm & Hset).
    unfold fr; repeat split.
    + exact Hv.
    + exact Hsat.
    + apply tmps_off_bm_set; [ exact Htmps | ].
      intros Hne b o Hvp.
      match goal with He : eval_expr _ _ _ _ ?a0 _ |- _ =>
        eapply (Hset _ _ _ Htmps Hwf Hmle He Hidm); exact Hvp end.
    + exact Hwf.
    + rewrite PTree.gso by congruence; exact Hmle.
  - (* Scall *)
    destruct Hfr as (Hv & Hsat & Htmps & Hwf & Hmle).
    simpl in Hok.
    match goal with Hfun : eval_funcall function_entry2 mario_ge _ _ _ _ _ _ |- _ =>
      destruct (Hreach _ _ _ _ _ _ Hfun Hv Hsat Hwf) as (Hv' & Hsat' & Hwf' & Hvres) end.
    unfold fr. destruct optid as [id|]; cbn [set_opttemp].
    + repeat split.
      * exact Hv'.
      * exact Hsat'.
      * apply tmps_off_bm_set; [ exact Htmps | intros _ b o Hvp; eapply Hvres; exact Hvp ].
      * exact Hwf'.
      * rewrite PTree.gso by congruence; exact Hmle.
    + repeat split; [ exact Hv' | exact Hsat' | exact Htmps | exact Hwf' | exact Hmle ].
  - (* Sbuiltin: unsupported (body_nf_ok = False) *)
    simpl in Hok. destruct Hok.
  - (* Sseq, s1 normal then s2 *)
    simpl in Hok; destruct Hok as [Hok1 Hok2].
    exact (IHexec_stmt2 (IHexec_stmt1 Hfr Hok1) Hok2).
  - (* Sseq, s1 abnormal *)
    simpl in Hok; destruct Hok as [Hok1 _].
    exact (IHexec_stmt Hfr Hok1).
  - (* Sifthenelse *)
    simpl in Hok; destruct Hok as [Hok1 Hok2].
    destruct b; [ exact (IHexec_stmt Hfr Hok1) | exact (IHexec_stmt Hfr Hok2) ].
  - (* Sreturn_none *) exact Hfr.
  - (* Sreturn_some *) exact Hfr.
  - (* Sbreak *) exact Hfr.
  - (* Scontinue *) exact Hfr.
  - (* Sloop_stop1 *)
    simpl in Hok; destruct Hok as [Hok1 _].
    exact (IHexec_stmt Hfr Hok1).
  - (* Sloop_stop2 *)
    simpl in Hok; destruct Hok as [Hok1 Hok2].
    exact (IHexec_stmt2 (IHexec_stmt1 Hfr Hok1) Hok2).
  - (* Sloop_loop *)
    simpl in Hok; destruct Hok as [Hok1 Hok2].
    exact (IHexec_stmt3 (IHexec_stmt2 (IHexec_stmt1 Hfr Hok1) Hok2) (conj Hok1 Hok2)).
  - (* Sswitch *)
    simpl in Hok.
    exact (IHexec_stmt Hfr
             (seq_of_ls_body_nf_ok _ _ _ _ (select_switch_body_nf_ok _ _ _ _ _ Hok))).
Qed.

(* ================================================================== *)
(* PER-FUNCTION DISCHARGE TOOLKIT. The frame consumes body_nf_ok; these  *)
(* lemmas discharge its obligations for the statement shapes clightgen    *)
(* actually emits, so a function's body_nf_ok proof is a short sequence.   *)
(* ================================================================== *)

(* Discharge the Sset obligation for a CHASE-LOAD `tid = m->fid` where fid *)
(* is one of the tracked pointer fields FS: the loaded pointer is off-bm   *)
(* by mem_wf, so the Sset re-establishes tmps_off_bm. Reuses the           *)
(* exec_field_ptr_load inverter by wrapping the rhs eval back into an Sset. *)
Lemma set_off_bm_ok_chase_load :
  forall FS bm e tid fid resty,
    In fid FS ->
    set_off_bm_ok FS bm e tid
      (Efield
        (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
          (Tstruct mario._MarioState noattr)) fid (tptr resty)).
Proof.
  intros FS bm e tid fid resty Hin.
  unfold set_off_bm_ok. intros le m v Htmps Hwf Hmle Heval Hne b o Hvp.
  destruct (Hwf fid Hin) as (off & b1 & ofs1 & Hfo & Hbound & Hld & Hboff).
  assert (Hexec : exec_stmt function_entry2 mario_ge e le m
            (Sset tid
              (Efield
                (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr)) fid (tptr resty)))
            E0 (PTree.set tid v le) m Out_normal)
    by (apply exec_Sset; exact Heval).
  destruct (exec_field_ptr_load e le m tid fid resty E0 (PTree.set tid v le) m
              Out_normal bm b1 off ofs1 Hmle Hfo Hbound Hld Hexec) as (Hle' & _ & _).
  assert (Hvv : v = Vptr b1 ofs1).
  { assert (Hq : (PTree.set tid v le) ! tid
                 = (PTree.set tid (Vptr b1 ofs1) le) ! tid) by (rewrite Hle'; reflexivity).
    rewrite !PTree.gss in Hq. congruence. }
  assert (Hbb : b = b1) by congruence. subst b. exact Hboff.
Qed.

(* Discharge the Sset obligation for a POINTER COPY `tid = q` where q is    *)
(* any temp other than the Mario pointer: the value is le!q, off-bm by      *)
(* tmps_off_bm. (clightgen hoists casts of loaded pointers through such     *)
(* temp copies.) *)
Lemma set_off_bm_ok_tempcopy :
  forall FS bm e tid q ty,
    q <> mario._m ->
    set_off_bm_ok FS bm e tid (Etempvar q ty).
Proof.
  intros FS bm e tid q ty Hq.
  unfold set_off_bm_ok. intros le m v Htmps Hwf Hmle Heval Hne b o Hvp.
  inversion Heval; subst;
    try (match goal with Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
           solve [ inv Hlv ] end);
    apply (Htmps q b o); [ exact Hq | assumption ].
Qed.

(* NOTE (Obstacle 2, reopened under the faithful ppc/N64 model). A word-sized
   scalar load `tid = m->flags` (tuint -> Mint32) CAN, under Archi.ptr64=false,
   yield a Vptr (a 4-byte load can hold a pointer fragment), so set_off_bm_ok is
   NOT provable for it from mem_wf alone. The clean fix is to restrict tmps_off_bm
   to chase-rooted temps (flags' temp is never a chase root). The chase-load and
   pointer-copy Sset dischargers above remain valid; the word-scalar-load case is
   the remaining open obligation. *)
