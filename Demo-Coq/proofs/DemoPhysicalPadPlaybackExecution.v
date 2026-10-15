From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop Ctypes
 Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_game_init jp_game_init.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution
 DemoPlaybackExecution DemoPlaybackAdvanceExecution DemoControllerCopyExecution
 DemoPlaybackSecondControllerExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module P := us_game_init.

Definition physical_pad_base_bounds (base : Z) : Prop := 0 <= base <= 18.

Lemma physical_port_has_bounded_pad_base : forall port,
 0 <= port < 4 -> physical_pad_base_bounds (6 * port).
Proof. unfold physical_pad_base_bounds. intros; lia. Qed.

Lemma physical_port_order_separates_pads : forall first second,
 0 <= first < second -> second < 4 -> 6 * first + 4 <= 6 * second.
Proof. intros; lia. Qed.

Lemma generated_physical_second_absent :
 forall ge (layout : playback_layout ge) le before controllers,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Mem.load Mptr before controllers 52 = Some Vzero ->
 exec_stmt function_entry2 ge empty_env le before
  (playback_second_decision (fn_body P.f_run_demo_inputs)) E0
  (PTree.set P._t'28 Vzero le) before Out_normal.
Proof.
 intros ge layout le before controllers Hcontrollers Hdata2.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 unfold playback_second_decision. cbn [P.f_run_demo_inputs fn_body]. playback_stmt.
Qed.

Lemma physical_pad_base_unsigned : forall base,
 physical_pad_base_bounds base -> Ptrofs.unsigned (Ptrofs.repr base) = base.
Proof.
 intros base Hbase. unfold physical_pad_base_bounds in Hbase.
 apply Ptrofs.unsigned_repr. change Ptrofs.max_unsigned with 4294967295. lia.
Qed.

Lemma physical_pad_field_unsigned : forall base field,
 physical_pad_base_bounds base -> 0 <= field <= 3 ->
 Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr base) (Ptrofs.repr field)) = base + field.
Proof.
 intros base field Hbase Hfield. rewrite Ptrofs.add_unsigned.
 rewrite (physical_pad_base_unsigned base Hbase).
 rewrite (Ptrofs.unsigned_repr field) by (change Ptrofs.max_unsigned with 4294967295; lia).
 apply Ptrofs.unsigned_repr. unfold physical_pad_base_bounds in Hbase.
 change Ptrofs.max_unsigned with 4294967295. lia.
Qed.

Lemma physical_pad_writable_valid : forall before pads base,
 Mem.valid_access before Mint16unsigned pads base Writable ->
 Mem.valid_pointer before pads base = true.
Proof.
 intros before pads base Haccess. apply Mem.valid_pointer_nonempty_perm.
 eapply Mem.perm_implies.
 - exact (proj1 Haccess base ltac:(cbn; lia)).
 - constructor.
Qed.

Ltac physical_pad_address :=
 cbn -[Ptrofs.repr Ptrofs.add Ptrofs.unsigned Ptrofs.mul Ptrofs.of_ints];
 repeat rewrite Ptrofs.add_zero;
 repeat match goal with
 | H : physical_pad_base_bounds ?base |-
   context [Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr ?base) (Ptrofs.repr ?field))] =>
   rewrite (physical_pad_field_unsigned base field H) by (vm_compute; intuition discriminate)
 | H : physical_pad_base_bounds ?base |- context [Ptrofs.unsigned (Ptrofs.repr ?base)] =>
   rewrite (physical_pad_base_unsigned base H)
 end;
 cbn; repeat rewrite Z.add_0_r.

Ltac physical_pad_expr :=
 lazymatch goal with
 | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
 | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
   eapply eval_Etempvar; cbn [set_opttemp]; repeat rewrite PTree.gsspec;
   cbn -[Ptrofs.repr]; first [reflexivity | eassumption]
 | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
   eapply eval_Ebinop; [physical_pad_expr | physical_pad_expr | playback_normalize]
 | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
   eapply eval_Ecast; [physical_pad_expr | playback_normalize]
 | |- eval_expr _ _ _ _ _ _ => eapply eval_Elvalue;
   [physical_pad_lvalue |
    first [eapply deref_loc_value; [reflexivity | physical_pad_address; playback_load] |
     eapply deref_loc_reference; reflexivity | eapply deref_loc_copy; reflexivity]]
 end
with physical_pad_lvalue :=
 lazymatch goal with
 | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
   eapply eval_Evar_global; [reflexivity | eassumption]
 | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; physical_pad_expr
 | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
   eapply eval_Efield_struct; [physical_pad_expr | reflexivity | eassumption | eassumption]
 end.

Ltac physical_pad_stmt :=
 lazymatch goal with
 | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
   eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [physical_pad_stmt | physical_pad_stmt]
 | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; physical_pad_expr
 | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ => eapply exec_Sassign;
   [physical_pad_lvalue | physical_pad_expr | playback_normalize |
    eapply assign_loc_value; [reflexivity | physical_pad_address; eassumption]]
 | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ => first
   [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
     [physical_pad_expr | reflexivity | physical_pad_stmt] |
    eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
     [physical_pad_expr | reflexivity | physical_pad_stmt]]
 | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
 end.


Theorem generated_physical_second_pad_clear :
 forall ge (layout : playback_layout ge) le before controllers pads base,
 Genv.find_symbol ge P._gControllers = Some controllers -> pads <> controllers -> physical_pad_base_bounds base ->
 Mem.load Mptr before controllers 52 = Some (Vptr pads (Ptrofs.repr base)) ->
 Mem.valid_access before Mint8signed pads (base+2) Writable ->
 Mem.valid_access before Mint8signed pads (base+3) Writable ->
 Mem.valid_access before Mint16unsigned pads base Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_second_decision (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mint8signed after pads (base+2) = Some Vzero /\
 Mem.load Mint8signed after pads (base+3) = Some Vzero /\
 Mem.load Mint16unsigned after pads base = Some Vzero /\
 Mem.unchanged_on (controller_outside_bytes pads base (base+4)) before after /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset pads base (base+4) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset) /\
 (forall chunk b offset permission,
  Mem.valid_access before chunk b offset permission ->
  Mem.valid_access after chunk b offset permission).
Proof.
 intros ge layout le before controllers pads base Hcontrollers Hpc Hbase Hpad2 Hwx Hwy Hwb.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpad Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 assert (Hvalid2 : Mem.valid_pointer before pads (Ptrofs.unsigned (Ptrofs.repr base)) = true).
 { rewrite (physical_pad_base_unsigned base Hbase). apply physical_pad_writable_valid. exact Hwb. }
 destruct (Mem.valid_access_store before Mint8signed pads (base+2) Vzero Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8signed pads (base+3) Vzero ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned pads base Vzero ltac:(demo_access)) as [after Hs3].
 exists after. eexists. split.
 - unfold playback_second_decision. cbn [P.f_run_demo_inputs fn_body]. physical_pad_stmt.
 - split; [playback_load |]. split; [playback_load |]. split; [playback_load |]. split.
   + eapply Mem.unchanged_on_trans with (m2 := m2).
     * eapply Mem.unchanged_on_trans with (m2 := m1);
        eapply controller_store_unchanged; eassumption || (cbn; lia).
     * eapply controller_store_unchanged; eassumption || (cbn; lia).
   + split.
     * intros chunk b offset Havoid.
       rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
        (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
         first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
       rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
        (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
         first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
       rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
        (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
         first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]). reflexivity.
     * intros. demo_access.
Qed.


Lemma generated_physical_playback_normalization_executes :
 forall ge (layout : playback_layout ge) le before after controllers pads base physical,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 physical_pad_base_bounds base ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads (Ptrofs.repr base)) ->
 Mem.load Mint16unsigned before pads base = Some (Vint physical) ->
 Mem.store Mint16unsigned before pads base (Vint (playback_masked_buttons physical)) = Some after ->
 exists le', exec_stmt function_entry2 ge empty_env le before
  (playback_initial_normalization (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal.
Proof.
 intros ge layout le before after controllers pads base physical Hcontrollers Hbase Hpad Hphysical Hstore.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 unfold playback_masked_buttons in Hstore. eexists.
 unfold playback_initial_normalization. cbn [P.f_run_demo_inputs fn_body]. physical_pad_stmt.
Qed.


Theorem generated_physical_playback_tail_eof_executes :
 forall ge (layout : playback_layout ge) le before controllers current pads stream record base,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 physical_pad_base_bounds base ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads (Ptrofs.repr base)) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some Vzero ->
 Mem.valid_access before Mint8signed pads (base+2) Writable ->
 Mem.valid_access before Mint8signed pads (base+3) Writable ->
 Mem.valid_access before Mint16unsigned pads base Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_record_tail (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mint8signed after pads (base+2) = Some Vzero /\
 Mem.load Mint8signed after pads (base+3) = Some Vzero /\
 Mem.load Mint16unsigned after pads base = Some (Vint (Int.repr 128)) /\
 (forall chunk b offset, playback_read_avoids chunk b offset pads base (base+4) ->
   Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
 intros ge layout le before controllers current pads stream record base
   Hcontrollers Hbase Hcurrent Hpc Hpg Hps Hpad Hpointer Htimer Hwx Hwy Hwb.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 destruct (Mem.valid_access_store before Mint8signed pads (base+2) Vzero Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8signed pads (base+3) Vzero ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned pads base (Vint (Int.repr 128)) ltac:(demo_access))
   as [after Hs3].
 exists after. eexists. split.
 - unfold playback_record_tail. cbn [P.f_run_demo_inputs fn_body]. physical_pad_stmt.
 - split; [playback_load |]. split; [playback_load |]. split; [playback_load |].
   intros chunk b offset Havoid.
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
    (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
    (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
    (unfold playback_read_avoids in Havoid; destruct Havoid as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]). reflexivity.
Qed.


Theorem generated_physical_playback_tail_nonadvancing_executes :
 forall ge (layout : playback_layout ge) le before controllers current pads stream record base
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 physical_pad_base_bounds base ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads (Ptrofs.repr base)) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.load Mint16unsigned before pads base = Some (Vint (playback_masked_buttons physical)) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Int.eq timer Int.zero = false -> Int.eq (playback_decrement timer) Int.zero = false ->
 Mem.valid_access before Mint8signed pads (base+2) Writable ->
 Mem.valid_access before Mint8signed pads (base+3) Writable ->
 Mem.valid_access before Mint16unsigned pads base Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_record_tail (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mint8signed after pads (base+2) = Some (Vint rawx) /\
 Mem.load Mint8signed after pads (base+3) = Some (Vint rawy) /\
 Mem.load Mint16unsigned after pads base = Some (Vint (playback_output_buttons physical mask)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer)) /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset pads base (base+4) ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
 intros ge layout le before controllers current pads stream record base physical timer rawx rawy mask
  Hcontrollers Hbase Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked Htimer Hrawx Hrawy Hmask
  Hpositive Hnotone Hwx Hwy Hwb Hwt.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 pose proof (Mem.load_cast _ _ _ _ _ Hrawx) as Hnormalx.
 pose proof (Mem.load_cast _ _ _ _ _ Hrawy) as Hnormaly.
 cbn in Hnormalx, Hnormaly.
 assert (Hcastx : Int.sign_ext 8 rawx = rawx) by congruence.
 assert (Hcasty : Int.sign_ext 8 rawy = rawy) by congruence.
 destruct (Mem.valid_access_store before Mint8signed pads (base+2) (Vint rawx) Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8signed pads (base+3) (Vint rawy) ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned pads base (Vint (playback_record_buttons_value mask))
   ltac:(demo_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mint16unsigned pads base (Vint (playback_output_buttons physical mask))
   ltac:(demo_access)) as [m4 Hs4].
 destruct (Mem.valid_access_store m4 Mint8unsigned stream (Ptrofs.unsigned record)
   (Vint (playback_decrement timer)) ltac:(demo_access)) as [after Hs5].
 assert (Hxread : Mem.load Mint8signed m1 pads (base+2) = Some (Vint rawx)).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1). cbn [Val.load_result]. rewrite Hcastx. reflexivity. }
 assert (Hyread : Mem.load Mint8signed m2 pads (base+3) = Some (Vint rawy)).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs2). cbn [Val.load_result]. rewrite Hcasty. reflexivity. }
 assert (Hdecoded : Mem.load Mint16unsigned m3 pads base = Some (Vint (playback_record_buttons_value mask))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs3). unfold playback_record_buttons_value.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Houtput : Mem.load Mint16unsigned m4 pads base = Some (Vint (playback_output_buttons physical mask))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs4). unfold playback_output_buttons.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Hdecrement : Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) =
   Some (Vint (playback_decrement timer))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs5). unfold playback_decrement.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 exists after. eexists. split.
 - unfold playback_field_offset in Hrawx, Hrawy, Hmask.
   unfold playback_masked_buttons, playback_record_buttons_value, playback_output_buttons,
    playback_start_button, playback_decrement in *.
   unfold playback_record_tail. cbn [P.f_run_demo_inputs fn_body]. physical_pad_stmt.
 - split; [playback_load |]. split; [playback_load |].
   split; [playback_load |]. split; [exact Hdecrement |].
   intros chunk b offset Hpads Hstream.
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by
    (unfold playback_read_avoids in Hstream; destruct Hstream as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]). reflexivity.
Qed.


Theorem generated_physical_playback_tail_advancing_executes :
 forall ge (layout : playback_layout ge) le before controllers current pads stream record base
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 physical_pad_base_bounds base ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads (Ptrofs.repr base)) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.load Mint16unsigned before pads base = Some (Vint (playback_masked_buttons physical)) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Int.eq timer Int.zero = false -> Int.eq (playback_decrement timer) Int.zero = true ->
 Mem.valid_access before Mint8signed pads (base+2) Writable ->
 Mem.valid_access before Mint8signed pads (base+3) Writable ->
 Mem.valid_access before Mint16unsigned pads base Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 Mem.valid_access before Mptr current 0 Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_record_tail (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mint8signed after pads (base+2) = Some (Vint rawx) /\
 Mem.load Mint8signed after pads (base+3) = Some (Vint rawy) /\
 Mem.load Mint16unsigned after pads base = Some (Vint (playback_output_buttons physical mask)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_decrement timer)) /\
 Mem.load Mptr after current 0 = Some (Vptr stream (playback_advance record)) /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset current 0 4 ->
  playback_read_avoids chunk b offset pads base (base+4) ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
 intros ge layout le before controllers current pads stream record base physical timer rawx rawy mask
  Hcontrollers Hbase Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked Htimer Hrawx Hrawy Hmask
  Hpositive Hlast Hwx Hwy Hwb Hwt Hwc.
 destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
  Hcontrollersize Hdata Hbutton Hx Hy Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
 pose proof (Mem.load_cast _ _ _ _ _ Hrawx) as Hnormalx.
 pose proof (Mem.load_cast _ _ _ _ _ Hrawy) as Hnormaly.
 cbn in Hnormalx, Hnormaly.
 assert (Hcastx : Int.sign_ext 8 rawx = rawx) by congruence.
 assert (Hcasty : Int.sign_ext 8 rawy = rawy) by congruence.
 destruct (Mem.valid_access_store before Mint8signed pads (base+2) (Vint rawx) Hwx) as [m1 Hs1].
 destruct (Mem.valid_access_store m1 Mint8signed pads (base+3) (Vint rawy) ltac:(demo_access)) as [m2 Hs2].
 destruct (Mem.valid_access_store m2 Mint16unsigned pads base (Vint (playback_record_buttons_value mask))
   ltac:(demo_access)) as [m3 Hs3].
 destruct (Mem.valid_access_store m3 Mint16unsigned pads base (Vint (playback_output_buttons physical mask))
   ltac:(demo_access)) as [m4 Hs4].
 destruct (Mem.valid_access_store m4 Mint8unsigned stream (Ptrofs.unsigned record)
   (Vint (playback_decrement timer)) ltac:(demo_access)) as [m5 Hs5].
 destruct (Mem.valid_access_store m5 Mptr current 0 (Vptr stream (playback_advance record))
   ltac:(demo_access)) as [after Hs6].
 assert (Hxread : Mem.load Mint8signed m1 pads (base+2) = Some (Vint rawx)).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs1). cbn [Val.load_result]. rewrite Hcastx. reflexivity. }
 assert (Hyread : Mem.load Mint8signed m2 pads (base+3) = Some (Vint rawy)).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs2). cbn [Val.load_result]. rewrite Hcasty. reflexivity. }
 assert (Hdecoded : Mem.load Mint16unsigned m3 pads base = Some (Vint (playback_record_buttons_value mask))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs3). unfold playback_record_buttons_value.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Houtput : Mem.load Mint16unsigned m4 pads base = Some (Vint (playback_output_buttons physical mask))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs4). unfold playback_output_buttons.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Hdecrement : Mem.load Mint8unsigned m5 stream (Ptrofs.unsigned record) =
   Some (Vint (playback_decrement timer))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hs5). unfold playback_decrement.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 exists after. eexists. split.
 - unfold playback_advance in Hs6.
   unfold playback_field_offset in Hrawx, Hrawy, Hmask.
   unfold playback_masked_buttons, playback_record_buttons_value, playback_output_buttons,
    playback_start_button, playback_decrement in *.
   unfold playback_record_tail. cbn [P.f_run_demo_inputs fn_body]. physical_pad_stmt.
 - split; [playback_load |]. split; [playback_load |].
   split; [playback_load |]. split; [playback_load |]. split; [playback_load |].
   intros chunk b offset Hcurrentrange Hpads Hstream.
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs6) by exact Hcurrentrange.
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs5) by
    (unfold playback_read_avoids in Hstream; destruct Hstream as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs4) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs3) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs2) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]).
   rewrite (Mem.load_store_other _ _ _ _ _ _ Hs1) by
    (unfold playback_read_avoids in Hpads; destruct Hpads as [H|[H|H]];
     first [left; exact H | right; left; cbn; lia | right; right; cbn; lia]). reflexivity.
Qed.


Theorem generated_physical_playback_tail_all_timers_executes :
 forall ge (layout : playback_layout ge) le before controllers current pads stream record base
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 physical_pad_base_bounds base ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads (Ptrofs.repr base)) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.load Mint16unsigned before pads base = Some (Vint (playback_masked_buttons physical)) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Mem.valid_access before Mint8signed pads (base+2) Writable ->
 Mem.valid_access before Mint8signed pads (base+3) Writable ->
 Mem.valid_access before Mint16unsigned pads base Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 Mem.valid_access before Mptr current 0 Writable ->
 exists after le',
 exec_stmt function_entry2 ge empty_env le before
  (playback_record_tail (fn_body P.f_run_demo_inputs)) E0 le' after Out_normal /\
 Mem.load Mptr after current 0 = Some (Vptr stream (playback_next_record timer record)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_next_timer timer)) /\
 Mem.load Mint8signed after pads (base+2) = Some (Vint (playback_next_stick timer rawx)) /\
 Mem.load Mint8signed after pads (base+3) = Some (Vint (playback_next_stick timer rawy)) /\
 Mem.load Mint16unsigned after pads base = Some (Vint (playback_next_buttons timer physical mask)) /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset current 0 4 ->
  playback_read_avoids chunk b offset pads base (base+4) ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset).
Proof.
 intros ge layout le before controllers current pads stream record base physical timer rawx rawy mask
  Hcontrollers Hbase Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked Htimer Hrawx Hrawy Hmask
  Hwx Hwy Hwb Hwt Hwc.
 unfold playback_next_record, playback_next_timer, playback_next_stick, playback_next_buttons.
 destruct (Int.eq timer Int.zero) eqn:Hzero.
 - pose proof (Int.eq_spec timer Int.zero) as Heq. rewrite Hzero in Heq. subst timer.
   destruct (generated_physical_playback_tail_eof_executes ge layout le before controllers current pads stream record base
     Hcontrollers Hbase Hcurrent Hpc Hpg Hps Hpad Hpointer Htimer Hwx Hwy Hwb)
     as (after & le' & Hexec & Hx & Hy & Hb & Hframe).
   exists after, le'. split; [exact Hexec |].
   split; [rewrite Hframe by (unfold playback_read_avoids; left; apply not_eq_sym; exact Hpg); exact Hpointer |].
   split; [rewrite Hframe by (unfold playback_read_avoids; left; apply not_eq_sym; exact Hps); exact Htimer |].
   split; [exact Hx |]. split; [exact Hy |]. split; [exact Hb |]. intros. apply Hframe. assumption.
 - destruct (Int.eq (playback_decrement timer) Int.zero) eqn:Hlast.
   + destruct (generated_physical_playback_tail_advancing_executes ge layout le before controllers current pads stream record base
       physical timer rawx rawy mask Hcontrollers Hbase Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked
       Htimer Hrawx Hrawy Hmask Hzero Hlast Hwx Hwy Hwb Hwt Hwc)
       as (after & le' & Hexec & Hx & Hy & Hb & Ht & Hp & Hframe).
     exists after, le'. repeat split; assumption.
   + destruct (generated_physical_playback_tail_nonadvancing_executes ge layout le before controllers current pads stream record base
       physical timer rawx rawy mask Hcontrollers Hbase Hcurrent Hpc Hpg Hps Hsc Hsg Hpad Hpointer Hmasked
       Htimer Hrawx Hrawy Hmask Hzero Hlast Hwx Hwy Hwb Hwt)
       as (after & le' & Hexec & Hx & Hy & Hb & Ht & Hframe).
     exists after, le'. split; [exact Hexec |]. split.
     * rewrite Hframe by (unfold playback_read_avoids; left; apply not_eq_sym; assumption). exact Hpointer.
     * split; [exact Ht |]. split; [exact Hx |]. split; [exact Hy |]. split; [exact Hb |].
       intros. apply Hframe; assumption.
Qed.


Definition demo_physical_connected_playback_claim (f : function) : Prop :=
 forall ge (layout : playback_layout ge) before controllers current pads stream record firstbase secondbase
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 physical_pad_base_bounds firstbase -> physical_pad_base_bounds secondbase ->
 firstbase + 4 <= secondbase ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads (Ptrofs.repr firstbase)) ->
 Mem.load Mptr before controllers 52 = Some (Vptr pads (Ptrofs.repr secondbase)) ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.valid_pointer before stream (Ptrofs.unsigned record) = true ->
 Mem.load Mint16unsigned before pads firstbase = Some (Vint physical) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Mem.valid_access before Mint16unsigned pads firstbase Writable ->
 Mem.valid_access before Mint8signed pads (firstbase+2) Writable ->
 Mem.valid_access before Mint8signed pads (firstbase+3) Writable ->
 Mem.valid_access before Mint8signed pads (secondbase+2) Writable ->
 Mem.valid_access before Mint8signed pads (secondbase+3) Writable ->
 Mem.valid_access before Mint16unsigned pads secondbase Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 Mem.valid_access before Mptr current 0 Writable ->
 exists after,
 eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef /\
 Mem.load Mptr after current 0 = Some (Vptr stream (playback_next_record timer record)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_next_timer timer)) /\
 Mem.load Mint8signed after pads (firstbase+2) = Some (Vint (playback_next_stick timer rawx)) /\
 Mem.load Mint8signed after pads (firstbase+3) = Some (Vint (playback_next_stick timer rawy)) /\
 Mem.load Mint16unsigned after pads firstbase = Some (Vint (playback_next_buttons timer physical mask)) /\
 Mem.load Mint8signed after pads (secondbase+2) = Some Vzero /\
 Mem.load Mint8signed after pads (secondbase+3) = Some Vzero /\
 Mem.load Mint16unsigned after pads secondbase = Some Vzero /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset current 0 4 ->
  playback_read_avoids chunk b offset pads firstbase (firstbase+4) ->
  playback_read_avoids chunk b offset pads secondbase (secondbase+4) ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset) /\
 (4 <= Ptrofs.unsigned record -> Mem.load Mint32 after stream 0 = Mem.load Mint32 before stream 0).

Theorem generated_physical_connected_playback_call :
 demo_physical_connected_playback_claim P.f_run_demo_inputs.
Proof.
 intros ge layout before controllers current pads stream record firstbase secondbase physical timer rawx rawy mask
   Hcontrollers Hcurrent Hfirstbase Hsecondbase Hgap Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
   Htimer Hrawx Hrawy Hmask Hwb Hwx Hwy Hw2x Hw2y Hw2b Hwt Hwc.
 destruct (Mem.valid_access_store before Mint16unsigned pads firstbase
   (Vint (playback_masked_buttons physical)) Hwb) as [masked Hstore].
 destruct (generated_physical_playback_normalization_executes ge layout
   (create_undef_temps (fn_temps P.f_run_demo_inputs)) before masked controllers pads firstbase physical
   Hcontrollers Hfirstbase Hpad Hphysical Hstore) as [lenorm Hnorm].
 assert (Hmasked : Mem.load Mint16unsigned masked pads firstbase = Some (Vint (playback_masked_buttons physical))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). unfold playback_masked_buttons.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Hvalid' : Mem.valid_pointer masked stream (Ptrofs.unsigned record) = true).
 { apply Mem.valid_pointer_nonempty_perm. eapply Mem.perm_store_1; [exact Hstore |].
   apply Mem.valid_pointer_nonempty_perm. exact Hvalid. }
 set (lecurrent := PTree.set P._t'2 (Vptr stream record) lenorm).
 destruct (generated_physical_second_pad_clear ge layout lecurrent masked controllers pads secondbase
   Hcontrollers Hpc Hsecondbase ltac:(playback_load)
   ltac:(demo_access) ltac:(demo_access) ltac:(demo_access))
   as (cleared & lecleared & Hclear & Hclearx & Hcleary & Hclearb & Hclearunchanged & Hclearframe & Hclearaccess).
 assert (Hprepared : forall chunk b offset,
   playback_read_avoids chunk b offset pads firstbase (firstbase+2) ->
   playback_read_avoids chunk b offset pads secondbase (secondbase+4) ->
   Mem.load chunk cleared b offset = Mem.load chunk before b offset).
 { abstract (intros chunk b offset Hfirst Hsecond; rewrite Hclearframe by exact Hsecond;
     apply (Mem.load_store_other _ _ _ _ _ _ Hstore); exact Hfirst). }
 assert (Hprepared_other : forall chunk b offset, b <> pads ->
   Mem.load chunk cleared b offset = Mem.load chunk before b offset).
 { abstract (intros; apply Hprepared; unfold playback_read_avoids; left; assumption). }
 assert (Hmasked' : Mem.load Mint16unsigned cleared pads firstbase = Some (Vint (playback_masked_buttons physical))).
 { rewrite Hclearframe by (unfold playback_read_avoids; right; left; cbn; lia). exact Hmasked. }
 destruct (generated_physical_playback_tail_all_timers_executes ge layout lecleared cleared controllers current pads stream record firstbase
   physical timer rawx rawy mask Hcontrollers Hfirstbase Hcurrent Hpc Hpg Hps Hsc Hsg
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hpc); exact Hpad)
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hpg); exact Hpointer)
   Hmasked'
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hps); exact Htimer)
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hps); exact Hrawx)
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hps); exact Hrawy)
   ltac:(rewrite Hprepared_other by (apply not_eq_sym; exact Hps); exact Hmask)
   ltac:(apply Hclearaccess; demo_access) ltac:(apply Hclearaccess; demo_access)
   ltac:(apply Hclearaccess; demo_access) ltac:(apply Hclearaccess; demo_access)
   ltac:(apply Hclearaccess; demo_access))
   as (after & le' & Htail & Hpointer' & Htimer' & Hx & Hy & Hb & Htailframe).
 assert (Hbody : exec_stmt function_entry2 ge empty_env
   (create_undef_temps (fn_temps P.f_run_demo_inputs)) before (fn_body P.f_run_demo_inputs)
   E0 le' after Out_normal).
 { destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
     Hcontrollersize Hdata Hbutton Hpadx Hpady Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
   unfold playback_initial_normalization in Hnorm.
   unfold playback_second_decision in Hclear. unfold playback_record_tail in Htail.
   cbn [P.f_run_demo_inputs fn_body] in Hnorm, Hclear, Htail |- *.
   eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hnorm |].
   eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
   - apply exec_Sset. playback_expr.
   - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
     + unfold lecurrent in Hclear. playback_expr.
     + reflexivity.
     + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hclear | exact Htail]. }
 assert (Hframe : forall chunk b offset,
   playback_read_avoids chunk b offset current 0 4 ->
   playback_read_avoids chunk b offset pads firstbase (firstbase+4) ->
   playback_read_avoids chunk b offset pads secondbase (secondbase+4) ->
   playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
   Mem.load chunk after b offset = Mem.load chunk before b offset).
 { abstract (intros chunk b offset Hc Hp Hp2 Hs; rewrite Htailframe by assumption;
     apply Hprepared; [unfold playback_read_avoids in Hp |- *; intuition lia | exact Hp2]). }
 exists after. split.
 - eapply eval_funcall_internal with (e := empty_env)
     (le1 := create_undef_temps (fn_temps P.f_run_demo_inputs))
     (le2 := le') (m1 := before) (m2 := after) (out := Out_normal).
   + constructor; try constructor; unfold list_disjoint; cbn; tauto.
   + exact Hbody.
   + reflexivity.
   + reflexivity.
 - split; [exact Hpointer' |]. split; [exact Htimer' |]. split; [exact Hx |]. split; [exact Hy |].
   split; [exact Hb |].
   do 3 (split; [rewrite Htailframe by (unfold playback_read_avoids;
      first [left; exact Hpg | right; right; cbn; lia | left; exact Hps]); assumption |]).
   split; [exact Hframe |]. intros Hfirst. apply Hframe; unfold playback_read_avoids;
    first [left; exact Hsg | left; apply not_eq_sym; exact Hps | right; left; cbn; exact Hfirst].
Qed.

Definition demo_physical_connected_playback_claim_us_jp : Prop :=
 demo_physical_connected_playback_claim P.f_run_demo_inputs /\
 demo_physical_connected_playback_claim jp_game_init.f_run_demo_inputs.

Theorem generated_physical_connected_playback_us_jp : demo_physical_connected_playback_claim_us_jp.
Proof. split; exact generated_physical_connected_playback_call. Qed.



Definition demo_physical_single_playback_claim (f : function) : Prop :=
 forall ge (layout : playback_layout ge) before controllers current pads stream record base
   physical timer rawx rawy mask,
 Genv.find_symbol ge P._gControllers = Some controllers ->
 Genv.find_symbol ge P._gCurrDemoInput = Some current ->
 physical_pad_base_bounds base ->
 pads <> controllers -> pads <> current -> pads <> stream ->
 stream <> controllers -> stream <> current ->
 Mem.load Mptr before controllers 24 = Some (Vptr pads (Ptrofs.repr base)) ->
 Mem.load Mptr before controllers 52 = Some Vzero ->
 Mem.load Mptr before current 0 = Some (Vptr stream record) ->
 Mem.valid_pointer before stream (Ptrofs.unsigned record) = true ->
 Mem.load Mint16unsigned before pads base = Some (Vint physical) ->
 Mem.load Mint8unsigned before stream (Ptrofs.unsigned record) = Some (Vint timer) ->
 Mem.load Mint8signed before stream (playback_field_offset record 1) = Some (Vint rawx) ->
 Mem.load Mint8signed before stream (playback_field_offset record 2) = Some (Vint rawy) ->
 Mem.load Mint8unsigned before stream (playback_field_offset record 3) = Some (Vint mask) ->
 Mem.valid_access before Mint16unsigned pads base Writable ->
 Mem.valid_access before Mint8signed pads (base+2) Writable ->
 Mem.valid_access before Mint8signed pads (base+3) Writable ->
 Mem.valid_access before Mint8unsigned stream (Ptrofs.unsigned record) Writable ->
 Mem.valid_access before Mptr current 0 Writable ->
 exists after,
 eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef /\
 Mem.load Mptr after current 0 = Some (Vptr stream (playback_next_record timer record)) /\
 Mem.load Mint8unsigned after stream (Ptrofs.unsigned record) = Some (Vint (playback_next_timer timer)) /\
 Mem.load Mint8signed after pads (base+2) = Some (Vint (playback_next_stick timer rawx)) /\
 Mem.load Mint8signed after pads (base+3) = Some (Vint (playback_next_stick timer rawy)) /\
 Mem.load Mint16unsigned after pads base = Some (Vint (playback_next_buttons timer physical mask)) /\
 (forall chunk b offset,
  playback_read_avoids chunk b offset current 0 4 ->
  playback_read_avoids chunk b offset pads base (base+4) ->
  playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
  Mem.load chunk after b offset = Mem.load chunk before b offset) /\
 (4 <= Ptrofs.unsigned record -> Mem.load Mint32 after stream 0 = Mem.load Mint32 before stream 0).

Theorem generated_physical_single_playback_call :
 demo_physical_single_playback_claim P.f_run_demo_inputs.
Proof.
 intros ge layout before controllers current pads stream record base physical timer rawx rawy mask
   Hcontrollers Hcurrent Hbase Hpc Hpg Hps Hsc Hsg Hpad Hpad2 Hpointer Hvalid Hphysical
   Htimer Hrawx Hrawy Hmask Hwb Hwx Hwy Hwt Hwc.
 destruct (Mem.valid_access_store before Mint16unsigned pads base
   (Vint (playback_masked_buttons physical)) Hwb) as [masked Hstore].
 destruct (generated_physical_playback_normalization_executes ge layout
   (create_undef_temps (fn_temps P.f_run_demo_inputs)) before masked controllers pads base physical
   Hcontrollers Hbase Hpad Hphysical Hstore) as [lenorm Hnorm].
 assert (Hmasked : Mem.load Mint16unsigned masked pads base = Some (Vint (playback_masked_buttons physical))).
 { rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). unfold playback_masked_buttons.
   cbn [Val.load_result]. rewrite Int.zero_ext_idem by lia. reflexivity. }
 assert (Hvalid' : Mem.valid_pointer masked stream (Ptrofs.unsigned record) = true).
 { apply Mem.valid_pointer_nonempty_perm. eapply Mem.perm_store_1; [exact Hstore |].
   apply Mem.valid_pointer_nonempty_perm. exact Hvalid. }
 set (lecurrent := PTree.set P._t'2 (Vptr stream record) lenorm).
 set (leabsent := PTree.set P._t'28 Vzero lecurrent).
 assert (Habsent : exec_stmt function_entry2 ge empty_env lecurrent masked
   (playback_second_decision (fn_body P.f_run_demo_inputs)) E0 leabsent masked Out_normal).
 { apply (generated_physical_second_absent ge layout lecurrent masked controllers);
     [exact Hcontrollers | playback_load]. }
 destruct (generated_physical_playback_tail_all_timers_executes ge layout leabsent masked
   controllers current pads stream record base physical timer rawx rawy mask
   Hcontrollers Hbase Hcurrent Hpc Hpg Hps Hsc Hsg
   ltac:(playback_load) ltac:(playback_load) Hmasked
   ltac:(playback_load) ltac:(playback_load) ltac:(playback_load) ltac:(playback_load)
   ltac:(demo_access) ltac:(demo_access) ltac:(demo_access) ltac:(demo_access) ltac:(demo_access))
   as (after & le' & Htail & Hpointer' & Htimer' & Hx & Hy & Hb & Htailframe).
 assert (Hbody : exec_stmt function_entry2 ge empty_env
   (create_undef_temps (fn_temps P.f_run_demo_inputs)) before (fn_body P.f_run_demo_inputs)
   E0 le' after Out_normal).
 { destruct layout as [controller_co pad_co record_co Hcontroller Hpadco Hrecord
     Hcontrollersize Hdata Hbutton Hpadx Hpady Hrecordtimer Hrecordx Hrecordy Hrecordbutton Hrecordsize].
   unfold playback_initial_normalization in Hnorm.
   unfold playback_second_decision in Habsent. unfold playback_record_tail in Htail.
   cbn [P.f_run_demo_inputs fn_body] in Hnorm, Habsent, Htail |- *.
   eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Hnorm |].
   eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
   - apply exec_Sset. playback_expr.
   - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
     + unfold lecurrent in Habsent. playback_expr.
     + reflexivity.
     + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [exact Habsent | exact Htail]. }
 assert (Hframe : forall chunk b offset,
   playback_read_avoids chunk b offset current 0 4 ->
   playback_read_avoids chunk b offset pads base (base+4) ->
   playback_read_avoids chunk b offset stream (Ptrofs.unsigned record) (Ptrofs.unsigned record+1) ->
   Mem.load chunk after b offset = Mem.load chunk before b offset).
 { abstract (intros chunk b offset Hc Hp Hs; rewrite Htailframe by assumption;
     apply (Mem.load_store_other _ _ _ _ _ _ Hstore);
     unfold playback_read_avoids in Hp |- *; cbn [size_chunk]; intuition lia). }
 exists after. split.
 - eapply eval_funcall_internal with (e := empty_env)
     (le1 := create_undef_temps (fn_temps P.f_run_demo_inputs))
     (le2 := le') (m1 := before) (m2 := after) (out := Out_normal).
   + constructor; try constructor; unfold list_disjoint; cbn; tauto.
   + exact Hbody.
   + reflexivity.
   + reflexivity.
 - split; [exact Hpointer' |]. split; [exact Htimer' |]. split; [exact Hx |]. split; [exact Hy |].
   split; [exact Hb |]. split; [exact Hframe |]. intros Hfirst.
   apply Hframe; unfold playback_read_avoids;
    first [left; exact Hsg | left; apply not_eq_sym; exact Hps | right; left; cbn; exact Hfirst].
Qed.

Definition demo_physical_single_playback_claim_us_jp : Prop :=
 demo_physical_single_playback_claim P.f_run_demo_inputs /\
 demo_physical_single_playback_claim jp_game_init.f_run_demo_inputs.

Theorem generated_physical_single_playback_us_jp : demo_physical_single_playback_claim_us_jp.
Proof. split; exact generated_physical_single_playback_call. Qed.

Definition demo_physical_playback_claim_us_jp : Prop :=
 demo_physical_connected_playback_claim_us_jp /\ demo_physical_single_playback_claim_us_jp.

Theorem generated_physical_playback_us_jp : demo_physical_playback_claim_us_jp.
Proof. split; [exact generated_physical_connected_playback_us_jp | exact generated_physical_single_playback_us_jp]. Qed.
