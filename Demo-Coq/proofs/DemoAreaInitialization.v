From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_area jp_area.
From Demo.Proofs Require Import DemoStartExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module AC := us_area.

Definition clear_area_members : members :=
 [Member_plain AC._index tschar; Member_plain AC._flags tschar;
  Member_plain AC._terrainType tushort;
  Member_plain AC._unk04 (tptr (Tstruct AC._GraphNodeRoot noattr));
  Member_plain AC._terrainData (tptr tshort);
  Member_plain AC._surfaceRooms (tptr tschar);
  Member_plain AC._macroObjects (tptr tshort);
  Member_plain AC._warpNodes (tptr (Tstruct AC._ObjectWarpNode noattr));
  Member_plain AC._paintingWarpNodes (tptr (Tstruct AC._WarpNode noattr));
  Member_plain AC._instantWarps (tptr (Tstruct AC._InstantWarp noattr));
  Member_plain AC._objectSpawnInfos (tptr (Tstruct AC._SpawnInfo noattr));
  Member_plain AC._camera (tptr (Tstruct AC._Camera noattr));
  Member_plain AC._unused (tptr (Tstruct AC._UnusedArea28 noattr));
  Member_plain AC._whirlpools (tarray (tptr (Tstruct AC._Whirlpool noattr)) 2);
  Member_plain AC._dialog (tarray tuchar 2);
  Member_plain AC._musicParam tushort; Member_plain AC._musicParam2 tushort].

Record clear_area_layout (ge : Clight.genv) : Type := {
 clear_area_co : composite;
 clear_area_lookup : (genv_cenv ge) ! AC._Area = Some clear_area_co;
 clear_area_members_match : co_members clear_area_co = clear_area_members;
 clear_area_size : co_sizeof clear_area_co = 60;
 clear_spawn_co : composite;
 clear_spawn_lookup : (genv_cenv ge) ! AC._SpawnInfo = Some clear_spawn_co;
 clear_spawn_offset : field_offset (genv_cenv ge) AC._areaIndex
   (co_members clear_spawn_co) = OK (12, Full);
 clear_transition_co : composite;
 clear_transition_lookup : (genv_cenv ge) ! AC._WarpTransition = Some clear_transition_co;
 clear_transition_active : field_offset (genv_cenv ge) AC._isActive
   (co_members clear_transition_co) = OK (0, Full);
 clear_transition_pause : field_offset (genv_cenv ge) AC._pauseRendering
   (co_members clear_transition_co) = OK (3, Full)
}.

Definition clear_spawn_members : members :=
 [Member_plain AC._startPos (tarray tshort 3);
  Member_plain AC._startAngle (tarray tshort 3);
  Member_plain AC._areaIndex tschar; Member_plain AC._activeAreaIndex tschar;
  Member_plain AC._behaviorArg tuint;
  Member_plain AC._behaviorScript (tptr tvoid);
  Member_plain AC._model (tptr (Tstruct AC._GraphNode noattr));
  Member_plain AC._next (tptr (Tstruct AC._SpawnInfo noattr))].

Definition clear_transition_members : members :=
 [Member_plain AC._isActive tuchar; Member_plain AC._type tuchar;
  Member_plain AC._time tuchar; Member_plain AC._pauseRendering tuchar;
  Member_plain AC._data (Tstruct AC._WarpTransitionData noattr)].

Definition clear_area_program (us : bool) : Clight.program :=
 if us then AC.prog else jp_area.prog.

Lemma clear_mkprogram_types : forall types defs public main
    (WF : wf_composites types),
 prog_types (mkprogram types defs public main WF) = types.
Proof.
 intros. unfold mkprogram. destruct (build_composite_env' types WF). reflexivity.
Qed.

(** Project the source type list symbolically. The finite receipts below
    need not evaluate the generated program or construct its environment. *)
Lemma generated_clear_area_type_list : forall us,
 prog_types (clear_area_program us) =
 if us then AC.composites else jp_area.composites.
Proof.
 intros [].
 - change (prog_types AC.prog = AC.composites).
   unfold AC.prog. apply clear_mkprogram_types.
 - change (prog_types jp_area.prog = jp_area.composites).
   unfold jp_area.prog. apply clear_mkprogram_types.
Qed.

Lemma generated_clear_area_definition : forall us,
 In (Composite AC._Area Struct clear_area_members noattr)
   (prog_types (clear_area_program us)).
Proof.
 intros us; rewrite generated_clear_area_type_list.
 destruct us; vm_compute; repeat first [left; reflexivity | right].
Qed.

Lemma generated_clear_spawn_definition : forall us,
 In (Composite AC._SpawnInfo Struct clear_spawn_members noattr)
   (prog_types (clear_area_program us)).
Proof.
 intros us; rewrite generated_clear_area_type_list.
 destruct us; vm_compute; repeat first [left; reflexivity | right].
Qed.

Lemma generated_clear_transition_definition : forall us,
 In (Composite AC._WarpTransition Struct clear_transition_members noattr)
   (prog_types (clear_area_program us)).
Proof.
 intros us; rewrite generated_clear_area_type_list.
 destruct us; vm_compute; repeat first [left; reflexivity | right].
Qed.

Lemma generated_clear_area_layout_exists_us_jp :
 forall us (ge : Clight.genv),
 genv_cenv ge = prog_comp_env (clear_area_program us) ->
 exists layout : clear_area_layout ge, True.
Proof.
 intros us ge Henv.
 destruct (build_composite_env_charact AC._Area Struct clear_area_members noattr
   (prog_types (clear_area_program us)) (prog_comp_env (clear_area_program us))
   (prog_comp_env_eq (clear_area_program us)) (generated_clear_area_definition us))
   as (area_co & Harea & Ham & Haa & Has).
 destruct (build_composite_env_charact AC._SpawnInfo Struct clear_spawn_members noattr
   (prog_types (clear_area_program us)) (prog_comp_env (clear_area_program us))
   (prog_comp_env_eq (clear_area_program us)) (generated_clear_spawn_definition us))
   as (spawn_co & Hspawn & Hsm & Hsa & Hss).
 destruct (build_composite_env_charact AC._WarpTransition Struct clear_transition_members noattr
   (prog_types (clear_area_program us)) (prog_comp_env (clear_area_program us))
   (prog_comp_env_eq (clear_area_program us)) (generated_clear_transition_definition us))
   as (transition_co & Htransition & Htm & Hta & Hts).
 pose proof (build_composite_env_consistent _ _
   (prog_comp_env_eq (clear_area_program us)) _ _ Harea)
   as [Hcomplete Halign Hsize Hrank].
 assert (Hsixty : co_sizeof area_co = 60).
 { rewrite Hsize, Halign, Ham, Haa, Has. reflexivity. }
 refine (ex_intro _ {| clear_area_co := area_co;
   clear_area_lookup := _; clear_area_members_match := Ham;
   clear_area_size := Hsixty; clear_spawn_co := spawn_co;
   clear_spawn_lookup := _; clear_spawn_offset := _;
   clear_transition_co := transition_co; clear_transition_lookup := _;
   clear_transition_active := _; clear_transition_pause := _ |} I).
 - rewrite Henv; exact Harea.
 - rewrite Henv; exact Hspawn.
 - rewrite Hsm; reflexivity.
 - rewrite Henv; exact Htransition.
 - rewrite Htm; reflexivity.
 - rewrite Htm; reflexivity.
Qed.

Lemma clear_area_function_entry : forall ge before,
 function_entry2 ge AC.f_clear_areas [] before empty_env
   (create_undef_temps (fn_temps AC.f_clear_areas)) before.
Proof.
 intros. apply function_entry2_intro.
 - change (list_norepet ([] : list ident)). constructor.
 - change (list_norepet ([] : list ident)). constructor.
 - unfold list_disjoint. cbn. tauto.
 - constructor.
 - reflexivity.
Qed.

(** These are store receipts used to construct a proof of the real generated
    body below, not a replacement gameplay transition. Any wrong field,
    offset, chunk or value fails the generated exec_stmt proof. *)
Definition clear_area_operations (i : Z) : list (memory_chunk * Z * val) :=
 [(Mint8signed,60*i,Vint (Int.repr i));
  (Mint8signed,60*i+1,Vzero); (Mint16unsigned,60*i+2,Vzero);
  (Mptr,60*i+4,Vzero); (Mptr,60*i+8,Vzero);
  (Mptr,60*i+12,Vzero); (Mptr,60*i+16,Vzero);
  (Mptr,60*i+20,Vzero); (Mptr,60*i+24,Vzero);
  (Mptr,60*i+28,Vzero); (Mptr,60*i+32,Vzero);
  (Mptr,60*i+36,Vzero); (Mptr,60*i+40,Vzero);
  (Mptr,60*i+44,Vzero); (Mptr,60*i+48,Vzero);
  (Mint8unsigned,60*i+52,Vint (Int.repr 255));
  (Mint8unsigned,60*i+53,Vint (Int.repr 255));
  (Mint16unsigned,60*i+54,Vzero); (Mint16unsigned,60*i+56,Vzero)].

Lemma clear_array_access : forall memory block chunk offset,
 Mem.range_perm memory block 0 480 Cur Writable ->
 0 <= offset -> offset + size_chunk chunk <= 480 ->
 (align_chunk chunk | offset) ->
 Mem.valid_access memory chunk block offset Writable.
Proof.
 unfold Mem.valid_access, Mem.range_perm. intros memory block chunk offset Hrange Hlo Hhi Halign.
 split; [intros byte Hbyte; apply Hrange; lia | exact Halign].
Qed.

Ltac clear_access :=
 first [assumption |
  lazymatch goal with
  | |- Mem.valid_access ?m ?chunk ?block ?offset _ =>
    first [match goal with H : Mem.store _ _ _ _ _ = Some m |- _ =>
      eapply Mem.store_valid_access_1; [exact H | clear_access] end |
      eapply clear_array_access;
      [eassumption | cbn; lia | cbn; lia |
       let quotient := eval vm_compute in (offset / align_chunk chunk) in
       unfold Z.divide; exists quotient; vm_compute; reflexivity]]
  end].

Ltac clear_make_stores memory block operations finish :=
 lazymatch operations with
 | [] => finish memory
 | (?chunk,?offset,?value) :: ?rest =>
   let next := fresh "cleared_mem" in let receipt := fresh "Hclear_store" in
   destruct (Mem.valid_access_store memory chunk block offset value
     ltac:(first [clear_access |
       idtac "CLEAR ACCESS FAILED" chunk offset; fail 100])) as [next receipt];
   clear_make_stores next block rest finish
 end.

Ltac clear_load_core :=
 lazymatch goal with |- Mem.load ?chunk ?m ?b ?ofs = ?v =>
   let offset := eval vm_compute in ofs in change (Mem.load chunk m b offset = v)
 end;
 first [reflexivity | eassumption |
  match goal with H : Mem.store _ _ _ _ _ = Some ?m |-
     Mem.load _ ?m _ _ = _ =>
   first [rewrite (Mem.load_store_same _ _ _ _ _ _ H); cbn; reflexivity |
    rewrite (Mem.load_store_other _ _ _ _ _ _ H) by
      (first [left; congruence | right; left; vm_compute; discriminate |
        right; right; vm_compute; discriminate]);
    clear_load_core]
  end | match goal with |- Mem.load ?c ?m ?b ?o = ?v => idtac "CLEAR LOAD FAILED" c m b o v; fail 100 end].

Ltac clear_load :=
 let Hptr := fresh "Hclear_pointer_chunk" in
 assert (Hptr : Mptr = Mint32) by (vm_compute; reflexivity);
 try rewrite Hptr in *; clear Hptr;
 clear_load_core.

Ltac clear_reduce :=
 cbn -[Int.repr Int.sign_ext Ptrofs.repr Ptrofs.add Ptrofs.mul Ptrofs.of_ints];
 repeat match goal with
 | H : (genv_cenv _) ! _ = Some _ |- _ => progress rewrite H
 | H : co_sizeof _ = _ |- _ => progress rewrite H
 end;
 cbn -[Int.repr Int.sign_ext Ptrofs.repr Ptrofs.add Ptrofs.mul Ptrofs.of_ints];
 first [reflexivity | eassumption | vm_compute; reflexivity].

Ltac clear_expr :=
 lazymatch goal with
 | |- eval_expr _ _ _ _ (Econst_int _ _) _ => eapply eval_Econst_int
 | |- eval_expr _ _ _ _ (Etempvar _ _) _ => eapply eval_Etempvar;
   repeat rewrite PTree.gsspec; cbn; first [eassumption | reflexivity]
 | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
   eapply eval_Ebinop; [clear_expr | clear_expr | clear_reduce]
 | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
   eapply eval_Eunop; [clear_expr | clear_reduce]
 | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
   eapply eval_Ecast; [clear_expr | clear_reduce]
 | |- eval_expr _ _ _ _ _ _ => eapply eval_Elvalue;
   [clear_lvalue | first [eapply deref_loc_value; [reflexivity | cbn; clear_load] |
     eapply deref_loc_reference; reflexivity |
     eapply deref_loc_copy; reflexivity]]
 end
with clear_lvalue :=
 lazymatch goal with
 | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
   eapply eval_Evar_global; [reflexivity | eassumption]
 | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; clear_expr
 | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
   eapply eval_Efield_struct; [clear_expr | reflexivity | eassumption |
    first [eassumption | match goal with
      H : co_members ?co = _ |- context [co_members ?co] => rewrite H; reflexivity end]]
 end.

Ltac clear_stmt :=
 lazymatch goal with
 | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => eapply exec_Sskip
 | |- exec_stmt _ _ _ _ _ Sbreak _ _ _ _ => eapply exec_Sbreak
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ Out_break =>
   eapply exec_Sseq_2; [clear_stmt | discriminate]
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
   eapply exec_Sseq_1 with (t1:=E0) (t2:=E0); [clear_stmt | clear_stmt]
 | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; clear_expr
 | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
   eapply exec_Sassign;
   [first [clear_lvalue | match goal with |- ?g => idtac "CLEAR LVALUE" g end; fail 100] |
    first [clear_expr | match goal with |- ?g => idtac "CLEAR RHS" g end; fail 100] |
    first [clear_reduce | match goal with |- ?g => idtac "CLEAR CAST" g end; fail 100] |
    eapply assign_loc_value; [reflexivity | cbn;
     lazymatch goal with |- Mem.store ?chunk ?m ?b ?ofs ?v = ?out =>
       let offset := eval vm_compute in ofs in
       let value := eval vm_compute in v in
       change (Mem.store chunk m b offset value = out) end;
     first [eassumption | match goal with |- ?g => idtac "CLEAR STORE" g end; fail 100]]]
 | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
   eapply exec_Sifthenelse; [clear_expr | reflexivity |
     lazymatch goal with |- exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ =>
       let decision := eval vm_compute in b in change b with decision end;
     cbn; clear_stmt]
 | |- exec_stmt _ _ _ _ _ (Sloop _ _) _ _ _ _ =>
   first [eapply exec_Sloop_stop1 with (out':=Out_break); [clear_stmt | exact Out_break_or_return_B] |
    eapply exec_Sloop_loop with (out1:=Out_normal)
      (t1:=E0) (t2:=E0) (t3:=E0);
     [clear_stmt | first [reflexivity | left; reflexivity] |
      clear_stmt | clear_stmt]]
 end.

Definition demo_clear_areas_execution_claim (f : function) : Prop :=
 forall (ge : Clight.genv) (layout : clear_area_layout ge) before
     areas current transition spawn_global spawn,
  Genv.find_symbol ge AC._gAreaData = Some areas ->
  Genv.find_symbol ge AC._gCurrentArea = Some current ->
  Genv.find_symbol ge AC._gWarpTransition = Some transition ->
  Genv.find_symbol ge AC._gMarioSpawnInfo = Some spawn_global ->
  current <> transition -> current <> spawn_global -> transition <> spawn_global ->
  areas <> current -> areas <> transition -> areas <> spawn ->
  current <> spawn -> transition <> spawn ->
  Mem.load Mptr before spawn_global 0 = Some (Vptr spawn Ptrofs.zero) ->
  Mem.valid_access before Mptr current 0 Writable ->
  Mem.valid_access before Mint8unsigned transition 0 Writable ->
  Mem.valid_access before Mint8unsigned transition 3 Writable ->
  Mem.valid_access before Mint8signed spawn 12 Writable ->
  Mem.range_perm before areas 0 480 Cur Writable ->
  exists after,
    eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef /\
    Mem.load Mptr after current 0 = Some Vzero /\
    (forall i, 0 <= i < 8 ->
      Mem.load Mptr after areas (60*i+24) = Some Vzero /\
      Mem.load Mptr after areas (60*i+28) = Some Vzero) /\
    (forall chunk b ofs, b <> areas -> b <> current -> b <> transition -> b <> spawn ->
      Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_clear_areas_executes : demo_clear_areas_execution_claim AC.f_clear_areas.
Proof.
 intros ge layout before areas current transition spawn_global spawn
   Hareas Hcurrent Htransition Hspawn_global Hct Hcg Htg Hac Hat Has Hcs Hts
   Hspawn Hwc Hwt0 Hwt3 Hws Hrange.
 destruct layout as [area_co Harea_co Harea_members Harea_size
   spawn_co Hspawn_co Hspawn_offset transition_co Htransition_co Hactive Hpause].
 destruct (Mem.valid_access_store before Mptr current 0 Vzero ltac:(clear_access)) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8unsigned transition 0 Vzero ltac:(clear_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint8unsigned transition 3 Vzero ltac:(clear_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mint8signed spawn 12 (Vint Int.mone) ltac:(clear_access)) as [m4 Hs4].
 let operations := eval vm_compute in
   (flat_map clear_area_operations [0;1;2;3;4;5;6;7]) in
 clear_make_stores m4 areas operations ltac:(fun after =>
   exists after; split;
   [eapply eval_funcall_internal with (e:=empty_env)
      (le1:=create_undef_temps (fn_temps AC.f_clear_areas))
      (m1:=before) (m2:=after) (out:=Out_normal);
    [apply clear_area_function_entry |
     cbn [AC.f_clear_areas fn_body]; clear_stmt | reflexivity | reflexivity] |
    split; [clear_load | split;
      [intros i Hi; assert (i=0 \/ i=1 \/ i=2 \/ i=3 \/ i=4 \/ i=5 \/ i=6 \/ i=7) by lia;
       repeat match goal with H : _ \/ _ |- _ => destruct H end; subst i;
       split; clear_load |
       intros chunk b ofs Hba Hbc Hbt Hbs; clear_load]]]).
Qed.

Definition demo_clear_areas_with_generated_layout_claim : Prop :=
 forall (us : bool) (ge : Clight.genv) before
     areas current transition spawn_global spawn,
  genv_cenv ge = prog_comp_env (clear_area_program us) ->
  Genv.find_symbol ge AC._gAreaData = Some areas ->
  Genv.find_symbol ge AC._gCurrentArea = Some current ->
  Genv.find_symbol ge AC._gWarpTransition = Some transition ->
  Genv.find_symbol ge AC._gMarioSpawnInfo = Some spawn_global ->
  current <> transition -> current <> spawn_global -> transition <> spawn_global ->
  areas <> current -> areas <> transition -> areas <> spawn ->
  current <> spawn -> transition <> spawn ->
  Mem.load Mptr before spawn_global 0 = Some (Vptr spawn Ptrofs.zero) ->
  Mem.valid_access before Mptr current 0 Writable ->
  Mem.valid_access before Mint8unsigned transition 0 Writable ->
  Mem.valid_access before Mint8unsigned transition 3 Writable ->
  Mem.valid_access before Mint8signed spawn 12 Writable ->
  Mem.range_perm before areas 0 480 Cur Writable ->
  exists after,
    eval_funcall function_entry2 ge before
      (Internal (if us then AC.f_clear_areas else jp_area.f_clear_areas))
      [] E0 after Vundef /\
    Mem.load Mptr after current 0 = Some Vzero /\
    (forall i, 0 <= i < 8 ->
      Mem.load Mptr after areas (60*i+24) = Some Vzero /\
      Mem.load Mptr after areas (60*i+28) = Some Vzero) /\
    (forall chunk b ofs, b <> areas -> b <> current -> b <> transition -> b <> spawn ->
      Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_clear_areas_executes_with_checked_layout :
 demo_clear_areas_with_generated_layout_claim.
Proof.
 intros us ge before areas current transition spawn_global spawn Henv
   Hareas Hcurrent Htransition Hspawn_global Hct Hcg Htg Hac Hat Has Hcs Hts
   Hspawn Hwc Hwt0 Hwt3 Hws Hrange.
 destruct (generated_clear_area_layout_exists_us_jp us ge Henv) as [layout Hlayout].
 pose proof (generated_clear_areas_executes ge layout before areas current transition
   spawn_global spawn Hareas Hcurrent Htransition Hspawn_global Hct Hcg Htg Hac
   Hat Has Hcs Hts Hspawn Hwc Hwt0 Hwt3 Hws Hrange) as Hexec.
 destruct us; exact Hexec.
Qed.

Definition demo_area_initialization_claim_us_jp : Prop :=
 demo_clear_areas_with_generated_layout_claim /\
 AC.f_clear_areas = jp_area.f_clear_areas /\
 demo_clear_areas_execution_claim AC.f_clear_areas /\
 demo_clear_areas_execution_claim jp_area.f_clear_areas.

Theorem generated_demo_area_initialization_us_jp : demo_area_initialization_claim_us_jp.
Proof.
 split; [exact generated_clear_areas_executes_with_checked_layout |].
 split; [reflexivity |]. split; exact generated_clear_areas_executes.
Qed.
