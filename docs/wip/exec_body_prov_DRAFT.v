  Lemma ssd_prov_ok : forall sl, prov_ok_ls sl -> prov_ok_ls (select_switch_default sl).
  Proof.
    induction sl as [| o s rest IH]; simpl; intros H; auto.
    destruct o as [c|]; simpl; [ destruct H as [_ Hr]; apply IH; exact Hr | exact H ].
  Qed.
  Lemma ssc_prov_ok : forall n sl res,
    prov_ok_ls sl -> select_switch_case n sl = Some res -> prov_ok_ls res.
  Proof.
    induction sl as [| o s rest IH]; simpl; intros res Hav Hsel; try discriminate.
    destruct Hav as [Hs Hr]. destruct o as [c|]; simpl in Hsel.
    - destruct (zeq c n). + inv Hsel. simpl. split; [ exact Hs | exact Hr ]. + eapply IH; eauto.
    - eapply IH; eauto.
  Qed.
  Lemma seq_of_prov_ok : forall ls, prov_ok_ls ls -> prov_ok (seq_of_labeled_statement ls).
  Proof.
    induction ls as [| o s rest IH]; simpl; intros H; auto. destruct H. split; auto.
  Qed.
  Lemma select_switch_prov_ok : forall n sl,
    prov_ok_ls sl -> prov_ok_ls (select_switch n sl).
  Proof.
    intros n sl H. unfold select_switch.
    destruct (select_switch_case n sl) eqn:E.
    - eapply ssc_prov_ok; eauto. - apply ssd_prov_ok; auto.
  Qed.

  (* THE AUGMENTED INDUCTION: every body execution preserves meminv /\ tprov,
     given the per-statement check and the reach residuals. *)
  Theorem exec_body_prov :
    forall e le m s t le' m' out,
      e ! mario._gMarioState = None ->
      exec_stmt function_entry2 mario_ge e le m s t le' m' out ->
      meminv m -> tprov le -> prov_ok s ->
      meminv m' /\ tprov le'.
  Proof.
    intros e le m s t le' m' out He H. revert He.
    induction H; intros He Hmem Htp Hck; cbn [prov_ok prov_ok_ls] in Hck.
    - (* Sskip *) exact (conj Hmem Htp).
    - (* Sassign *)
      split; [ | exact Htp ].
      destruct Htp as (T48 & T12 & T49 & T13).
      destruct Hck as [ [Ha1 Ha2] | [Ha1 Ha2] ]; subst.
      + eapply (store_preserves_meminv store1_lval store1_rval mario._t'49 store1_loc_is_t49);
          [ exact Hmem | exact T49 | eapply exec_Sassign; eassumption ].
      + eapply (store_preserves_meminv store2_lval store2_rval mario._t'13 store2_loc_is_t13);
          [ exact Hmem | exact T13 | eapply exec_Sassign; eassumption ].
    - (* Sset *)
      eapply sset_case_preserves;
        [ exact He | exact Hmem | exact Htp | exact Hck | eapply exec_Sset; eassumption ].
    - (* Scall *)
      split; [ eapply reach_meminv; [ eassumption | exact Hmem ]
             | apply tprov_set_opttemp; assumption ].
    - (* Sbuiltin *)
      split; [ eapply ext_meminv; [ eassumption | exact Hmem ]
             | apply tprov_set_opttemp; assumption ].
    - (* Sseq, normal *)
      destruct Hck as [Hck1 Hck2].
      destruct (IHexec_stmt1 He Hmem Htp Hck1) as [Hm1 Hl1].
      exact (IHexec_stmt2 He Hm1 Hl1 Hck2).
    - (* Sseq, abnormal *)
      destruct Hck as [Hck1 _]. exact (IHexec_stmt He Hmem Htp Hck1).
    - (* Sifthenelse *)
      destruct Hck as [Hck1 Hck2].
      apply IHexec_stmt; [ exact He | exact Hmem | exact Htp | destruct b; assumption ].
    - (* Sreturn None *) exact (conj Hmem Htp).
    - (* Sreturn Some *) exact (conj Hmem Htp).
    - (* Sbreak *) exact (conj Hmem Htp).
    - (* Scontinue *) exact (conj Hmem Htp).
    - (* Sloop, stop after s1 *)
      destruct Hck as [Hck1 _]. exact (IHexec_stmt He Hmem Htp Hck1).
    - (* Sloop, stop after s1;s2 *)
      destruct Hck as [Hck1 Hck2].
      destruct (IHexec_stmt1 He Hmem Htp Hck1) as [Hm1 Hl1].
      exact (IHexec_stmt2 He Hm1 Hl1 Hck2).
    - (* Sloop, loop again *)
      destruct Hck as [Hck1 Hck2].
      destruct (IHexec_stmt1 He Hmem Htp Hck1) as [Hm1 Hl1].
      destruct (IHexec_stmt2 He Hm1 Hl1 Hck2) as [Hm2 Hl2].
      apply IHexec_stmt3; [ exact He | exact Hm2 | exact Hl2 | cbn [prov_ok]; split; assumption ].
    - (* Sswitch *)
      apply IHexec_stmt; [ exact He | exact Hmem | exact Htp | ].
      apply seq_of_prov_ok. apply select_switch_prov_ok. exact Hck.
  Qed.

End ProvEngine.
