From Coq Require Import Bool List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clight ClightBigstep.

Definition assignment_preserves
    (I : mem -> Prop) (ge : genv) (e : env) (lhs rhs : expr) : Prop :=
  forall le before loc ofs bf rhs_value stored after,
    eval_lvalue ge e le before lhs loc ofs bf ->
    eval_expr ge e le before rhs rhs_value ->
    sem_cast rhs_value (typeof rhs) (typeof lhs) before = Some stored ->
    assign_loc ge (typeof lhs) before loc ofs bf stored after ->
    I before -> I after.

Fixpoint target_stmt_certificate
    (authorized : statement -> bool) (I : mem -> Prop)
    (ge : genv) (e : env) (s : statement) : Prop :=
  match s with
  | Sassign lhs rhs => assignment_preserves I ge e lhs rhs
  | Ssequence first second =>
      if authorized s then True
      else target_stmt_certificate authorized I ge e first /\
           target_stmt_certificate authorized I ge e second
  | Sifthenelse _ yes no | Sloop yes no =>
      target_stmt_certificate authorized I ge e yes /\
      target_stmt_certificate authorized I ge e no
  | Slabel _ body => target_stmt_certificate authorized I ge e body
  | Sswitch _ cases => target_ls_certificate authorized I ge e cases
  | _ => True
  end
with target_ls_certificate
    (authorized : statement -> bool) (I : mem -> Prop)
    (ge : genv) (e : env) (cases : labeled_statements) : Prop :=
  match cases with
  | LSnil => True
  | LScons _ body rest =>
      target_stmt_certificate authorized I ge e body /\
      target_ls_certificate authorized I ge e rest
  end.

Definition reached_internal_bodies_certified
    (authorized : statement -> bool) (I : mem -> Prop) (ge : genv) : Prop :=
  forall f vargs before e le after_entry,
    function_entry2 ge f vargs before e le after_entry ->
    target_stmt_certificate authorized I ge e (fn_body f).

Definition authorized_sequences_preserve
    (authorized : statement -> bool) (I : mem -> Prop) (ge : genv) : Prop :=
  forall e le before s trace le' after out,
    authorized s = true ->
    exec_stmt function_entry2 ge e le before s trace le' after out ->
    I before -> I after.

Definition reached_externals_preserve (I : mem -> Prop) (ge : genv) : Prop :=
  forall ef vargs before trace result after,
    external_call ef ge vargs before trace result after ->
    I before -> I after.

Definition function_entries_preserve (I : mem -> Prop) (ge : genv) : Prop :=
  forall f vargs before e le after,
    function_entry2 ge f vargs before e le after ->
    I before -> I after.

Definition function_frees_preserve (I : mem -> Prop) (ge : genv) : Prop :=
  forall e before after,
    Mem.free_list before (blocks_of_env ge e) = Some after ->
    I before -> I after.

Lemma selected_default_certificate :
  forall authorized I ge e cases,
    target_ls_certificate authorized I ge e cases ->
    target_ls_certificate authorized I ge e (select_switch_default cases).
Proof.
  induction cases as [| option body rest IH]; simpl; intros H; auto.
  destruct H as [Hbody Hrest].
  destruct option as [case_value |].
  - apply IH. exact Hrest.
  - simpl. split; assumption.
Qed.

Lemma selected_case_certificate :
  forall authorized I ge e n cases selected,
    target_ls_certificate authorized I ge e cases ->
    select_switch_case n cases = Some selected ->
    target_ls_certificate authorized I ge e selected.
Proof.
  induction cases as [| option body rest IH]; simpl; intros selected Hcert Hselect;
    try discriminate.
  destruct Hcert as [Hbody Hrest].
  destruct option as [case_value |].
  - destruct (zeq case_value n).
    + inv Hselect. simpl. auto.
    + eapply IH; eauto.
  - eapply IH; eauto.
Qed.

Lemma selected_switch_certificate :
  forall authorized I ge e n cases,
    target_ls_certificate authorized I ge e cases ->
    target_ls_certificate authorized I ge e (select_switch n cases).
Proof.
  intros authorized I ge e n cases Hcert.
  unfold select_switch.
  destruct (select_switch_case n cases) eqn:Hcase.
  - eapply selected_case_certificate; eauto.
  - apply selected_default_certificate. exact Hcert.
Qed.

Lemma seq_of_ls_certificate :
  forall authorized I ge e cases,
    target_ls_certificate authorized I ge e cases ->
    target_stmt_certificate authorized I ge e
      (seq_of_labeled_statement cases).
Proof.
  induction cases as [| option body rest IH]; simpl; intros Hcert; auto.
  destruct Hcert as [Hbody Hrest].
  destruct (authorized
    (Ssequence body (seq_of_labeled_statement rest))) eqn:Hauth; simpl; auto.
Qed.

Theorem exec_stmt_eval_funcall_target_lift :
  forall (authorized : statement -> bool) (I : mem -> Prop) (ge : genv),
    reached_internal_bodies_certified authorized I ge ->
    authorized_sequences_preserve authorized I ge ->
    reached_externals_preserve I ge ->
    function_entries_preserve I ge ->
    function_frees_preserve I ge ->
    (forall e le before s trace le' after out,
      exec_stmt function_entry2 ge e le before s trace le' after out ->
      target_stmt_certificate authorized I ge e s ->
      I before -> I after) /\
    (forall before fd vargs trace after result,
      eval_funcall function_entry2 ge before fd vargs trace after result ->
      I before -> I after).
Proof.
  intros authorized I ge Hbodies Hauthorized Hexternals Hentry Hfree.
  apply (exec_stmt_funcall_ind function_entry2 ge
    (fun e le before s trace le' after out =>
      target_stmt_certificate authorized I ge e s ->
      I before -> I after)
    (fun before fd vargs trace after result => I before -> I after)).
  - intros; assumption.
  - intros e le before lhs rhs loc ofs bf rhs_value stored after
      Hlv Hrhs Hcast Hassign Hcert HI.
    simpl in Hcert. eapply Hcert; eauto.
  - intros; assumption.
  - intros e le before optid callee args tyargs tyres cc vf vargs fd trace
      after result Hcallee Hargs Harglist Hfind Htype Hcall IH Hcert HI.
    apply IH. exact HI.
  - intros e le before optid ef args tyargs vargs trace after result
      Hargs Hcall Hcert HI.
    eapply Hexternals; eauto.
  - intros e le before first second trace1 le1 middle trace2 le2 after out
      Hfirst IHfirst Hsecond IHsecond Hcert HI.
    simpl in Hcert.
    destruct (authorized (Ssequence first second)) eqn:Hauth.
    + eapply Hauthorized; [exact Hauth | econstructor; eauto | exact HI].
    + destruct Hcert as [Hcert1 Hcert2].
      apply IHsecond; [exact Hcert2 |].
      apply IHfirst; assumption.
  - intros e le before first second trace le' after out Hfirst IHfirst Hout
      Hcert HI.
    simpl in Hcert.
    destruct (authorized (Ssequence first second)) eqn:Hauth.
    + eapply Hauthorized; [exact Hauth | eapply exec_Sseq_2; eauto | exact HI].
    + apply IHfirst; [exact (proj1 Hcert) | exact HI].
  - intros e le before condition yes no value branch trace le' after out
      Hcondition Hbool Hbranch IH Hcert HI.
    simpl in Hcert. apply IH; [destruct branch; tauto | exact HI].
  - intros; assumption.
  - intros; assumption.
  - intros; assumption.
  - intros; assumption.
  - intros e le before body incr trace le' after out' out Hbody IH Hstop
      Hcert HI.
    apply IH; [exact (proj1 Hcert) | exact HI].
  - intros e le before body incr trace1 le1 middle out1 trace2 le2 after out2 out
      Hbody IHbody Hnormal Hincr IHincr Hstop Hcert HI.
    apply IHincr; [exact (proj2 Hcert) |].
    apply IHbody; [exact (proj1 Hcert) | exact HI].
  - intros e le before body incr trace1 le1 middle out1 trace2 le2 middle2
      trace3 le3 after out Hbody IHbody Hnormal Hincr IHincr Hloop IHloop
      Hcert HI.
    apply IHloop; [exact Hcert |].
    apply IHincr; [exact (proj2 Hcert) |].
    apply IHbody; [exact (proj1 Hcert) | exact HI].
  - intros e le before value trace evaluated number cases le' after out
      Hvalue Hswitch Hselected IH Hcert HI.
    apply IH; [| exact HI].
    apply seq_of_ls_certificate.
    apply selected_switch_certificate.
    exact Hcert.
  - intros before f vargs trace e le1 le2 after_entry after_body out result after
      Hentry_call Hbody IHbody Hresult Hfree_call HI.
    apply Hfree with (e := e) (before := after_body); [exact Hfree_call |].
    apply IHbody.
    + eapply Hbodies; exact Hentry_call.
    + eapply Hentry; eauto.
  - intros before ef targs tres cc vargs trace result after Hcall HI.
    eapply Hexternals; eauto.
Qed.
