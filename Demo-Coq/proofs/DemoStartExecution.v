From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_title_screen jp_title_screen.
Import ListNotations.
Open Scope Z_scope.
Module T := us_title_screen.

(** These selectors take the installation block and the return directly from
    the generated function.  They do not replace the surrounding title-screen
    branch or the DMA loader with an invented transition system. *)
Definition demo_install_block (body : statement) : statement :=
  match body with
  | Ssequence _
      (Ssequence
        (Sifthenelse _
          (Ssequence _
            (Sifthenelse _
              (Ssequence _
                (Sifthenelse _
                  (Ssequence _ (Ssequence _ installation)) _)) _)) _)
        _) => installation
  | _ => Sskip
  end.

Definition demo_return_block (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ ret) => ret
  | _ => Sskip
  end.

Definition demo_install_and_return : statement :=
  Ssequence (demo_install_block (fn_body T.f_run_level_id_or_demo))
    (demo_return_block (fn_body T.f_run_level_id_or_demo)).

Lemma generated_demo_installation_identical_us_jp :
  demo_install_and_return =
  Ssequence
    (demo_install_block (fn_body jp_title_screen.f_run_level_id_or_demo))
    (demo_return_block (fn_body jp_title_screen.f_run_level_id_or_demo)).
Proof. reflexivity. Qed.

(** These are explicit layout conditions on the executing CompCert genv.
    They are not a claim that an arbitrary genv is the linked retail program. *)
Record demo_install_layout (ge : Clight.genv) : Type := {
  demo_handler_composite : composite;
  demo_input_composite : composite;
  demo_handler_lookup : (genv_cenv ge) ! T._DmaHandlerList = Some demo_handler_composite;
  demo_input_lookup : (genv_cenv ge) ! T._DemoInput = Some demo_input_composite;
  demo_target_offset : field_offset (genv_cenv ge) T._bufTarget
    (co_members demo_handler_composite) = OK (8, Full);
  demo_timer_offset : field_offset (genv_cenv ge) T._timer
    (co_members demo_input_composite) = OK (0, Full);
  demo_record_size : co_sizeof demo_input_composite = 4
}.

Definition demo_handler_members : members :=
  [Member_plain T._dmaTable (tptr (Tstruct T._DmaTable noattr));
   Member_plain T._currentAddr (tptr tvoid);
   Member_plain T._bufTarget (tptr tvoid)].
Definition demo_input_members : members :=
  [Member_plain T._timer tuchar; Member_plain T._rawStickX tschar;
   Member_plain T._rawStickY tschar; Member_plain T._buttonMask tuchar].

Lemma generated_demo_handler_definition :
  In (Composite T._DmaHandlerList Struct demo_handler_members noattr)
    (prog_types T.prog).
Proof. vm_compute. do 5 right. left. reflexivity. Qed.

Lemma generated_demo_input_definition :
  In (Composite T._DemoInput Struct demo_input_members noattr)
    (prog_types T.prog).
Proof. vm_compute. do 6 right. left. reflexivity. Qed.

(** Characterize only these two generated composites; do not compute the whole
    generated program or expand mkprogram's composite-environment proof. *)
Lemma generated_demo_install_layout_exists :
  forall ge, genv_cenv ge = prog_comp_env T.prog ->
    exists layout : demo_install_layout ge, True.
Proof.
  intros ge Hce.
  destruct (build_composite_env_charact T._DmaHandlerList Struct demo_handler_members
    noattr (prog_types T.prog) (prog_comp_env T.prog)
    (prog_comp_env_eq T.prog) generated_demo_handler_definition)
    as (handler_co & Hhandler & Hhm & Hha & Hhs).
  destruct (build_composite_env_charact T._DemoInput Struct demo_input_members
    noattr (prog_types T.prog) (prog_comp_env T.prog)
    (prog_comp_env_eq T.prog) generated_demo_input_definition)
    as (input_co & Hinput & Him & Hia & His).
  pose proof (build_composite_env_consistent _ _ (prog_comp_env_eq T.prog)
    _ _ Hinput) as Hconsistent.
  destruct Hconsistent as [Hcomplete Halign Hsize Hrank].
  assert (Hfour : co_sizeof input_co = 4).
  { rewrite Hsize, Halign, Him, Hia, His. reflexivity. }
  refine (ex_intro _ {| demo_handler_composite := handler_co;
    demo_input_composite := input_co;
    demo_handler_lookup := _; demo_input_lookup := _;
    demo_target_offset := _; demo_timer_offset := _;
    demo_record_size := Hfour |} I).
  - rewrite Hce. exact Hhandler.
  - rewrite Hce. exact Hinput.
  - rewrite Hhm. reflexivity.
  - rewrite Him. reflexivity.
Qed.

Ltac demo_access :=
  first [assumption |
    lazymatch goal with
    | |- Mem.valid_access ?m _ _ _ _ =>
      match goal with
      | H : Mem.store _ _ _ _ _ = Some m |- _ =>
        eapply Mem.store_valid_access_1; [exact H | demo_access]
      end
    end].

Ltac demo_load :=
  lazymatch goal with
  | |- Mem.load ?chunk ?m ?b ?ofs = ?value =>
      let offset := eval vm_compute in ofs in
      change (Mem.load chunk m b offset = value)
  end;
  first [eassumption |
    lazymatch goal with
    | |- Mem.load _ ?m _ _ = _ =>
      match goal with
      | H : Mem.store _ _ _ _ _ = Some m |- _ =>
        first
          [rewrite (Mem.load_store_same _ _ _ _ _ _ H); cbn; reflexivity
          |rewrite (Mem.load_store_other _ _ _ _ _ _ H);
           [demo_load | left; congruence]]
      end
    end].

Ltac demo_reduce :=
  cbn -[Int.sign_ext Int.repr Ptrofs.repr Ptrofs.add Ptrofs.mul Ptrofs.of_ints];
  repeat match goal with
  | H : (genv_cenv ?ge) ! ?id = Some ?co |-
      context [match (genv_cenv ?ge) ! ?id with _ => _ end] => rewrite H
  | H : co_sizeof ?co = _ |- context [co_sizeof ?co] => rewrite H
  end;
  cbn -[Int.sign_ext Int.repr].

Ltac demo_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; repeat rewrite PTree.gsspec; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [demo_expr | demo_expr | demo_reduce; reflexivity]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [demo_expr | demo_reduce; reflexivity]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue;
      [demo_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; demo_load]
             |eapply deref_loc_reference; reflexivity
             |eapply deref_loc_copy; reflexivity]]
  end
with demo_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; demo_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [demo_expr | reflexivity | eassumption | eassumption]
  end.

Ltac demo_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [demo_stmt | demo_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; demo_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [demo_lvalue | demo_expr | demo_reduce; reflexivity |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; demo_expr
  end.

(** A constructive execution of the generated installation suffix.  Loading
    and choosing the DMA entry, reaching this branch, and subsequent gameplay
    are deliberately outside this local theorem. *)
Theorem generated_demo_installation_executes :
  forall ge (layout : demo_install_layout ge) le before
      handler buffer current save act header,
    Genv.find_symbol ge T._gDemoInputsBuf = Some handler ->
    Genv.find_symbol ge T._gCurrDemoInput = Some current ->
    Genv.find_symbol ge T._gCurrSaveFileNum = Some save ->
    Genv.find_symbol ge T._gCurrActNum = Some act ->
    handler <> current -> buffer <> current ->
    current <> save -> current <> act -> save <> act ->
    Mem.load Mptr before handler 8 = Some (Vptr buffer Ptrofs.zero) ->
    Mem.load Mint8unsigned before buffer 0 = Some (Vint header) ->
    Mem.valid_access before Mptr current 0 Writable ->
    Mem.valid_access before Mint16signed save 0 Writable ->
    Mem.valid_access before Mint16signed act 0 Writable ->
    exists m1 m2 after le',
      Mem.store Mptr before current 0 (Vptr buffer (Ptrofs.repr 4)) = Some m1 /\
      Mem.store Mint16signed m1 save 0 (Vint Int.one) = Some m2 /\
      Mem.store Mint16signed m2 act 0 (Vint Int.one) = Some after /\
      exec_stmt function_entry2 ge (PTree.empty _) le before
        demo_install_and_return E0 le' after
        (Out_return (Some (Vint (Int.sign_ext 8 header), tint))) /\
      Mem.load Mptr after current 0 = Some (Vptr buffer (Ptrofs.repr 4)) /\
      Mem.load Mint16signed after save 0 = Some (Vint Int.one) /\
      Mem.load Mint16signed after act 0 = Some (Vint Int.one).
Proof.
  intros ge layout le before handler buffer current save act header
    Hhandler Hcurrent Hsave Hact Hhc Hbc Hcs Hca Hsa
    Htarget Hheader Hwcurrent Hwsave Hwact.
  destruct layout as [handler_co input_co Hhandler_co Hinput_co Htarget_offset Htimer_offset Hsize].
  destruct (Mem.valid_access_store before Mptr current 0
    (Vptr buffer (Ptrofs.repr 4)) ltac:(demo_access)) as [m1 Hs1].
  destruct (Mem.valid_access_store m1 Mint16signed save 0
    (Vint Int.one) ltac:(demo_access)) as [m2 Hs2].
  destruct (Mem.valid_access_store m2 Mint16signed act 0
    (Vint Int.one) ltac:(demo_access)) as [after Hs3].
  exists m1, m2, after. eexists.
  repeat split; try assumption.
  - unfold demo_install_and_return, demo_install_block, demo_return_block.
    cbn [T.f_run_level_id_or_demo fn_body]. demo_stmt.
  - demo_load.
  - demo_load.
  - demo_load.
Qed.

Definition demo_installation_execution_claim : Prop :=
  forall ge (layout : demo_install_layout ge) le before
      handler buffer current save act header,
    Genv.find_symbol ge T._gDemoInputsBuf = Some handler ->
    Genv.find_symbol ge T._gCurrDemoInput = Some current ->
    Genv.find_symbol ge T._gCurrSaveFileNum = Some save ->
    Genv.find_symbol ge T._gCurrActNum = Some act ->
    handler <> current -> buffer <> current ->
    current <> save -> current <> act -> save <> act ->
    Mem.load Mptr before handler 8 = Some (Vptr buffer Ptrofs.zero) ->
    Mem.load Mint8unsigned before buffer 0 = Some (Vint header) ->
    Mem.valid_access before Mptr current 0 Writable ->
    Mem.valid_access before Mint16signed save 0 Writable ->
    Mem.valid_access before Mint16signed act 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge (PTree.empty _) le before
        demo_install_and_return E0 le' after
        (Out_return (Some (Vint (Int.sign_ext 8 header), tint))) /\
      Mem.load Mptr after current 0 = Some (Vptr buffer (Ptrofs.repr 4)).
Theorem generated_demo_installation_returns_its_own_header :
  demo_installation_execution_claim.
Proof.
  unfold demo_installation_execution_claim.
  intros ge layout le before handler buffer current save act header
    Hhandler Hcurrent Hsave Hact Hhc Hbc Hcs Hca Hsa
    Htarget Hheader Hwcurrent Hwsave Hwact.
  destruct (generated_demo_installation_executes ge layout le before
    handler buffer current save act header Hhandler Hcurrent Hsave Hact
    Hhc Hbc Hcs Hca Hsa Htarget Hheader Hwcurrent Hwsave Hwact)
    as (m1 & m2 & after & le' & Hs1 & Hs2 & Hs3 & Hexec & Hpointer & Hrest).
  exists after, le'. split; assumption.
Qed.

(** A small allocated memory witness establishes that the load, separation and
    writability premises are compatible.  It is an arbitrary CompCert memory
    image, not a claim about retail reachability or completed DMA loading. *)
Definition demo_install_memory_premises_satisfiable_claim : Prop :=
  exists before,
    Mem.load Mptr before 1%positive 8 = Some (Vptr 2%positive Ptrofs.zero) /\
    Mem.load Mint8unsigned before 2%positive 0 = Some (Vint (Int.repr 9)) /\
    Mem.valid_access before Mptr 3%positive 0 Writable /\
    Mem.valid_access before Mint16signed 4%positive 0 Writable /\
    Mem.valid_access before Mint16signed 5%positive 0 Writable /\
    1%positive <> 3%positive /\ 2%positive <> 3%positive /\
    3%positive <> 4%positive /\ 3%positive <> 5%positive /\
    4%positive <> 5%positive.

Ltac demo_alloc_access :=
  first
    [eapply Mem.valid_access_alloc_same;
      [eassumption | vm_compute; discriminate | vm_compute; discriminate | first [exists 0; reflexivity | exists 2; reflexivity]]
    |eapply Mem.valid_access_alloc_other; [eassumption | demo_alloc_access]].

Theorem generated_demo_memory_premises_satisfiable :
  demo_install_memory_premises_satisfiable_claim.
Proof.
  destruct (Mem.alloc Mem.empty 0 12) as [m1 handler] eqn:Ha1.
  destruct (Mem.alloc m1 0 8) as [m2 buffer] eqn:Ha2.
  destruct (Mem.alloc m2 0 4) as [m3 current] eqn:Ha3.
  destruct (Mem.alloc m3 0 2) as [m4 save] eqn:Ha4.
  destruct (Mem.alloc m4 0 2) as [m5 act] eqn:Ha5.
  assert (Hn1 : Mem.nextblock m1 = 2%positive).
  { rewrite (Mem.nextblock_alloc _ _ _ _ _ Ha1). reflexivity. }
  assert (Hn2 : Mem.nextblock m2 = 3%positive).
  { rewrite (Mem.nextblock_alloc _ _ _ _ _ Ha2), Hn1. reflexivity. }
  assert (Hn3 : Mem.nextblock m3 = 4%positive).
  { rewrite (Mem.nextblock_alloc _ _ _ _ _ Ha3), Hn2. reflexivity. }
  assert (Hn4 : Mem.nextblock m4 = 5%positive).
  { rewrite (Mem.nextblock_alloc _ _ _ _ _ Ha4), Hn3. reflexivity. }
  assert (Hhandler : handler = 1%positive).
  { rewrite (Mem.alloc_result _ _ _ _ _ Ha1). reflexivity. }
  assert (Hbuffer : buffer = 2%positive).
  { rewrite (Mem.alloc_result _ _ _ _ _ Ha2). exact Hn1. }
  assert (Hcurrent : current = 3%positive).
  { rewrite (Mem.alloc_result _ _ _ _ _ Ha3). exact Hn2. }
  assert (Hsave : save = 4%positive).
  { rewrite (Mem.alloc_result _ _ _ _ _ Ha4). exact Hn3. }
  assert (Hact : act = 5%positive).
  { rewrite (Mem.alloc_result _ _ _ _ _ Ha5). exact Hn4. }
  subst handler buffer current save act.
  assert (Hwtarget : Mem.valid_access m5 Mptr 1%positive 8 Writable).
  { eapply Mem.valid_access_implies with (p1 := Freeable).
    - eapply (Mem.valid_access_alloc_other _ _ _ _ _ Ha5).
      eapply (Mem.valid_access_alloc_other _ _ _ _ _ Ha4).
      eapply (Mem.valid_access_alloc_other _ _ _ _ _ Ha3).
      eapply (Mem.valid_access_alloc_other _ _ _ _ _ Ha2).
      eapply (Mem.valid_access_alloc_same _ _ _ _ _ Ha1).
      + vm_compute. discriminate.
      + vm_compute. discriminate.
      + exists 2. reflexivity.
    - constructor. }
  assert (Hwheader : Mem.valid_access m5 Mint8unsigned 2%positive 0 Writable).
  { eapply Mem.valid_access_implies with (p1 := Freeable);
      [demo_alloc_access | constructor]. }
  assert (Hwcurrent : Mem.valid_access m5 Mptr 3%positive 0 Writable).
  { eapply Mem.valid_access_implies with (p1 := Freeable);
      [demo_alloc_access | constructor]. }
  assert (Hwsave : Mem.valid_access m5 Mint16signed 4%positive 0 Writable).
  { eapply Mem.valid_access_implies with (p1 := Freeable);
      [demo_alloc_access | constructor]. }
  assert (Hwact : Mem.valid_access m5 Mint16signed 5%positive 0 Writable).
  { eapply Mem.valid_access_implies with (p1 := Freeable);
      [demo_alloc_access | constructor]. }
  destruct (Mem.valid_access_store m5 Mptr 1%positive 8
    (Vptr 2%positive Ptrofs.zero) Hwtarget) as [m6 Hs1].
  destruct (Mem.valid_access_store m6 Mint8unsigned 2%positive 0
    (Vint (Int.repr 9)) ltac:(demo_access)) as [ready Hs2].
  exists ready. split.
  - demo_load.
  - split; [demo_load |].
    split; [demo_access |].
    split; [demo_access |].
    split; [demo_access |].
    repeat split; discriminate.
Qed.

Definition demo_installation_execution_claim_us_jp : Prop :=
  demo_install_and_return =
    Ssequence
      (demo_install_block (fn_body jp_title_screen.f_run_level_id_or_demo))
      (demo_return_block (fn_body jp_title_screen.f_run_level_id_or_demo)) /\
  demo_installation_execution_claim /\
  demo_install_memory_premises_satisfiable_claim /\
  (forall ge, genv_cenv ge = prog_comp_env T.prog ->
    exists layout : demo_install_layout ge, True).

Theorem generated_demo_installation_execution_us_jp :
  demo_installation_execution_claim_us_jp.
Proof.
  split; [exact generated_demo_installation_identical_us_jp |].
  split; [exact generated_demo_installation_returns_its_own_header |].
  split; [exact generated_demo_memory_premises_satisfiable |
    exact generated_demo_install_layout_exists].
Qed.
