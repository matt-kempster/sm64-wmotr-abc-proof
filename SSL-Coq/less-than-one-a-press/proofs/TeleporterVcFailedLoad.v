(** Local execution of the Virtual Console interpreter's failed LBU suffix.

    This file uses CompCert's existing PowerPC instruction semantics, rather
    than defining an SM64 emulator model.  The binary certificate below is
    checked separately against the supplied regional Wii executable images.

    Scope: the instructions after one read8 callback returns false, the
    interpreter's preceding nPC store, the callback's unconditional false
    return suffix, the final mode-bit gate, and the wrapper argument spill and
    reload instructions.  The callback's effects before that suffix, complete
    cpuExecuteUpdate, raw-address to CompCert-block mapping, dispatch to this
    handler, JIT code generation/fetch, and pending MIPS branch/delay-slot
    behavior remain separate execution obligations.
    In particular, a normal helper call is not assumed to preserve memory.
*)
From Coq Require Import List ZArith Lia.
From compcert Require Import AST Integers Values Memory Asm.
Import ListNotations.
Local Open Scope Z_scope.

(** Standard PPC operand fields.  The concrete opcode-to-AST correspondence
    concerns only real Pcmpwi/Pbt/Paddi/Pstw/Pmtlr/Pblr instructions.  CompCert
    numbers instruction positions rather than byte addresses; [label_pos]
    below explicitly supplies the branch-target translation. *)
Definition vc_ppc_opcode (word : Z) : Z := Z.shiftr word 26.
Definition vc_ppc_rt (word : Z) : Z := Z.land (Z.shiftr word 21) 31.
Definition vc_ppc_ra (word : Z) : Z := Z.land (Z.shiftr word 16) 31.
Definition vc_ppc_signed_immediate (word : Z) : Z :=
  let imm := Z.land word 65535 in
  if 32768 <=? imm then imm - 65536 else imm.
Definition vc_ppc_branch_displacement (word : Z) : Z :=
  let bd := Z.land word 65532 in
  if 32768 <=? bd then bd - 65536 else bd.

(** Authenticated common instruction words, JP at the addresses below and EU
    at those addresses plus 0x10.  These are exact matching fragments, rather
    than an assumption that the two entire emulator images are equivalent.
    [vc-image-check.py] records the per-region content SHA1, file offsets,
    virtual addresses and each matching word in [vc-supplied-images.json]. *)
Definition vc_read8_words : list Z :=
  [2485256176; 2080899750; 952107008; 2415984660; 939524096; 947978248;
   2550464512; 950009856; 2154662280; 2153971728; 1208162589; 2147549204;
   945815552; 2080900006; 941686800; 1317011488].

(** JP 0x80039FF4 .. 0x8003A054, EU +0x10. *)
Definition vc_lbu_words : list Z :=
  [1455453752; 1455686718; 2088370708; 950075404; 2147680332; 2088961844;
   2088960532; 1417708606; 2082144430; 1409290298; 2088501294; 2147680264;
   2172846092; 2089026068; 2153971716; 2106131366; 1317012513; 738394112;
   1099040856; 1455463992; 2290155532; 2088370708; 2424504396; 1207961668].

(** JP 0x8003664C .. 0x80036660, EU +0x10. *)
Definition vc_interpreter_pc_words : list Z :=
  [2155937816; 947191812; 2193883136; 1008096065; 2423914528].

(** JP 0x8000C58C .. 0x8000C5A0, EU +0x10. *)
Definition vc_read8_return_words : list Z :=
  [2147549204; 945815552; 2080900006; 941686800; 1317011488].

(** JP 0x80033C04 .. 0x80033C10, EU +0x10. *)
Definition vc_mode4_gate_words : list Z :=
  [2155610112; 1415579515; 1099038768].

Definition vc_mode4_gate_certificate : Prop :=
  (vc_ppc_opcode (nth 0 vc_mode4_gate_words 0),
   vc_ppc_rt (nth 0 vc_mode4_gate_words 0),
   vc_ppc_ra (nth 0 vc_mode4_gate_words 0),
   vc_ppc_signed_immediate (nth 0 vc_mode4_gate_words 0)) = (32, 3, 28, 0) /\
  (vc_ppc_opcode (nth 1 vc_mode4_gate_words 0),
   vc_ppc_rt (nth 1 vc_mode4_gate_words 0),
   vc_ppc_ra (nth 1 vc_mode4_gate_words 0),
   Z.land (Z.shiftr (nth 1 vc_mode4_gate_words 0) 11) 31,
   Z.land (Z.shiftr (nth 1 vc_mode4_gate_words 0) 6) 31,
   Z.land (Z.shiftr (nth 1 vc_mode4_gate_words 0) 1) 31,
   Z.land (nth 1 vc_mode4_gate_words 0) 1) = (21, 3, 0, 0, 29, 29, 1) /\
  (vc_ppc_opcode (nth 2 vc_mode4_gate_words 0),
   vc_ppc_rt (nth 2 vc_mode4_gate_words 0),
   vc_ppc_ra (nth 2 vc_mode4_gate_words 0),
   Z.land (nth 2 vc_mode4_gate_words 0) 3) = (16, 12, 2, 0) /\
  vc_ppc_branch_displacement (nth 2 vc_mode4_gate_words 0) = 48.

Theorem vc_mode4_gate_certificate_checked : vc_mode4_gate_certificate.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition vc_failed_lbu_instruction_certificate : Prop :=
  vc_ppc_opcode (nth 17 vc_lbu_words 0) = 11 /\
  vc_ppc_ra (nth 17 vc_lbu_words 0) = 3 /\
  vc_ppc_signed_immediate (nth 17 vc_lbu_words 0) = 0 /\
  vc_ppc_opcode (nth 18 vc_lbu_words 0) = 16 /\
  vc_ppc_rt (nth 18 vc_lbu_words 0) = 12 /\
  vc_ppc_ra (nth 18 vc_lbu_words 0) = 2 /\
  Z.land (nth 18 vc_lbu_words 0) 3 = 0 /\
  2147721276 + vc_ppc_branch_displacement (nth 18 vc_lbu_words 0) =
    2147723412 /\
  2147721292 + vc_ppc_branch_displacement (nth 18 vc_lbu_words 0) =
    2147723428 /\
  (vc_ppc_opcode (nth 22 vc_lbu_words 0),
   vc_ppc_rt (nth 22 vc_lbu_words 0),
   vc_ppc_ra (nth 22 vc_lbu_words 0),
   vc_ppc_signed_immediate (nth 22 vc_lbu_words 0)) = (36, 4, 3, 76) /\
  (vc_ppc_opcode (nth 1 vc_interpreter_pc_words 0),
   vc_ppc_rt (nth 1 vc_interpreter_pc_words 0),
   vc_ppc_ra (nth 1 vc_interpreter_pc_words 0),
   vc_ppc_signed_immediate (nth 1 vc_interpreter_pc_words 0)) =
    (14, 3, 21, 4) /\
  (vc_ppc_opcode (nth 4 vc_interpreter_pc_words 0),
   vc_ppc_rt (nth 4 vc_interpreter_pc_words 0),
   vc_ppc_ra (nth 4 vc_interpreter_pc_words 0),
   vc_ppc_signed_immediate (nth 4 vc_interpreter_pc_words 0)) =
    (36, 3, 26, 32) /\
  vc_read8_return_words = skipn 11 vc_read8_words /\
  (vc_ppc_opcode (nth 1 vc_read8_return_words 0),
   vc_ppc_rt (nth 1 vc_read8_return_words 0),
   vc_ppc_ra (nth 1 vc_read8_return_words 0),
   vc_ppc_signed_immediate (nth 1 vc_read8_return_words 0)) = (14, 3, 0, 0).

Theorem vc_failed_lbu_instruction_certificate_checked :
  vc_failed_lbu_instruction_certificate.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Execute the actual default read8 return suffix; entry, saved-LR load, and
    all effects of the preceding cpuGetXPC call remain explicit boundaries. *)
Fixpoint vc_run_ppc (ge : Asm.genv) (f : Asm.function)
    (instructions : list Asm.instruction) (rs : Asm.regset) (m : mem)
    : Asm.outcome :=
  match instructions with
  | [] => Asm.Next rs m
  | i :: rest =>
      match Asm.exec_instr ge f i rs m with
      | Asm.Next rs' m' => vc_run_ppc ge f rest rs' m'
      | Asm.Stuck => Asm.Stuck
      end
  end.

Definition vc_read8_return_code : list Asm.instruction :=
  [Asm.Plwz Asm.GPR0 (Asm.Cint (Int.repr 20)) Asm.GPR1;
   Asm.Paddi Asm.GPR3 Asm.GPR0 (Asm.Cint Int.zero);
   Asm.Pmtlr Asm.GPR0;
   Asm.Paddi Asm.GPR1 Asm.GPR1 (Asm.Cint (Int.repr 16));
   Asm.Pblr].

Theorem vc_default_read8_return_executes_false_without_memory_write :
  forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset)
    (m : mem) (saved_lr : val),
    Mem.loadv Mint32 m (Val.add (rs Asm.GPR1) (Vint (Int.repr 20))) =
      Some saved_lr ->
    exists returned,
      vc_run_ppc ge f vc_read8_return_code rs m = Asm.Next returned m /\
      returned Asm.GPR3 = Vint Int.zero /\
      returned Asm.PC = saved_lr.
Proof.
  intros ge f rs m saved_lr Hload.
  set (s0 := Asm.nextinstr (Asm.Pregmap.set Asm.GPR0 saved_lr rs)).
  set (s1 := Asm.nextinstr (Asm.Pregmap.set Asm.GPR3 (Vint Int.zero) s0)).
  set (s2 := Asm.nextinstr (Asm.Pregmap.set Asm.LR (s1 Asm.GPR0) s1)).
  set (s3 := Asm.nextinstr (Asm.Pregmap.set Asm.GPR1
    (Val.add (s2 Asm.GPR1) (Vint (Int.repr 16))) s2)).
  set (s4 := Asm.Pregmap.set Asm.PC (s3 Asm.LR) s3).
  assert (H0 : Asm.exec_instr ge f
      (Asm.Plwz Asm.GPR0 (Asm.Cint (Int.repr 20)) Asm.GPR1) rs m =
      Asm.Next s0 m).
  { cbn [Asm.exec_instr]. unfold Asm.load1, Asm.gpr_or_zero.
    simpl Asm.ireg_eq. cbn [Asm.const_low]. rewrite Hload. reflexivity. }
  assert (H1 : Asm.exec_instr ge f
      (Asm.Paddi Asm.GPR3 Asm.GPR0 (Asm.Cint Int.zero)) s0 m =
      Asm.Next s1 m) by reflexivity.
  assert (H2 : Asm.exec_instr ge f (Asm.Pmtlr Asm.GPR0) s1 m =
      Asm.Next s2 m) by reflexivity.
  assert (H3 : Asm.exec_instr ge f
      (Asm.Paddi Asm.GPR1 Asm.GPR1 (Asm.Cint (Int.repr 16))) s2 m =
      Asm.Next s3 m) by reflexivity.
  assert (H4 : Asm.exec_instr ge f Asm.Pblr s3 m =
      Asm.Next s4 m) by reflexivity.
  exists s4. split.
  - unfold vc_read8_return_code. cbn [vc_run_ppc].
    rewrite H0. cbn [vc_run_ppc]. rewrite H1. cbn [vc_run_ppc].
    rewrite H2. cbn [vc_run_ppc]. rewrite H3. cbn [vc_run_ppc].
    rewrite H4. reflexivity.
  - split.
    + unfold s4, s3, s2, s1, Asm.nextinstr.
      repeat rewrite Asm.Pregmap.gso by discriminate.
      apply Asm.Pregmap.gss.
    + unfold s4. rewrite Asm.Pregmap.gss.
      unfold s3, s2, s1, s0, Asm.nextinstr.
      repeat rewrite Asm.Pregmap.gso by discriminate.
      repeat rewrite Asm.Pregmap.gss.
      reflexivity.
Qed.

(** CompCert's [Prlwinm] lacks the hardware record-bit variant used by the
    following gate.  This small standard instruction extension records the
    signed comparison of the rotate/mask result in CR0, just as PowerPC Rc=1
    specifies.  As in CompCert comparison semantics, CR0_3 is abstracted as
    Vundef; this proof observes only CR0_2 (EQ).  For this actual zero-rotate/
    mask-4 instruction its modeled effect is proved equal to CompCert's
    existing [Pandi_] instruction below.
    Thus the extension introduces no callback or game-specific semantics. *)
Definition vc_exec_rlwinm_record (rd source : Asm.ireg) (amount mask : int)
    (rs : Asm.regset) (m : mem) : Asm.outcome :=
  let value := Val.rolm (rs source) amount mask in
  Asm.Next (Asm.nextinstr
    (Asm.compare_sint (Asm.Pregmap.set rd value rs) value Vzero)) m.

Theorem vc_mode4_record_rotate_matches_compcert_andi :
  forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset) (m : mem) mode,
    rs Asm.GPR3 = Vint mode ->
    vc_exec_rlwinm_record Asm.GPR0 Asm.GPR3 Int.zero (Int.repr 4) rs m =
    Asm.exec_instr ge f
      (Asm.Pandi_ Asm.GPR0 Asm.GPR3 (Asm.Cint (Int.repr 4))) rs m.
Proof.
  intros ge f rs m mode Hmode.
  unfold vc_exec_rlwinm_record.
  cbn [Asm.exec_instr Asm.const_low]. rewrite Hmode.
  cbn [Val.rolm Val.and]. rewrite Int.rolm_zero. reflexivity.
Qed.

Definition vc_mode4_zero_rs (rs : Asm.regset) : Asm.regset :=
  Asm.nextinstr (Asm.compare_sint
    (Asm.Pregmap.set Asm.GPR0 (Vint Int.zero) rs)
    (Vint Int.zero) (Vint Int.zero)).

Theorem vc_mode4_clear_gate_branches_without_pc_remap_call :
  forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset) (m : mem)
    mode code_block position done_position,
    rs Asm.GPR3 = Vint mode ->
    Int.and mode (Int.repr 4) = Int.zero ->
    rs Asm.PC = Vptr code_block (Ptrofs.repr position) ->
    Asm.label_pos 2%positive 0 (Asm.fn_code f) = Some done_position ->
    vc_exec_rlwinm_record Asm.GPR0 Asm.GPR3 Int.zero (Int.repr 4) rs m =
      Asm.Next (vc_mode4_zero_rs rs) m /\
    Asm.exec_instr ge f (Asm.Pbt Asm.CRbit_2 2%positive)
      (vc_mode4_zero_rs rs) m =
      Asm.Next
        (Asm.Pregmap.set Asm.PC
          (Vptr code_block (Ptrofs.repr done_position))
          (vc_mode4_zero_rs rs)) m.
Proof.
  intros ge f rs m mode code_block position done_position
    Hmode Hclear Hpc Hlabel. split.
  - unfold vc_exec_rlwinm_record, vc_mode4_zero_rs.
    rewrite Hmode. cbn [Val.rolm]. rewrite Int.rolm_zero, Hclear.
    reflexivity.
  - cbn [Asm.exec_instr Asm.reg_of_crbit].
    unfold vc_mode4_zero_rs, Asm.nextinstr, Asm.compare_sint.
    repeat rewrite Asm.Pregmap.gso by discriminate.
    rewrite Asm.Pregmap.gss.
    change (Asm.goto_label f 2%positive (vc_mode4_zero_rs rs) m =
      Asm.Next (Asm.Pregmap.set Asm.PC
        (Vptr code_block (Ptrofs.repr done_position))
        (vc_mode4_zero_rs rs)) m).
    unfold Asm.goto_label. rewrite Hlabel.
    unfold vc_mode4_zero_rs, Asm.nextinstr. rewrite Asm.Pregmap.gss.
    unfold Asm.compare_sint.
    repeat rewrite Asm.Pregmap.gso by discriminate.
    rewrite Hpc. reflexivity.
Qed.

Definition vc_cmp_false_rs (rs : Asm.regset) : Asm.regset :=
  Asm.nextinstr
    (Asm.compare_sint rs (Vint Int.zero) (Vint Int.zero)).

Definition vc_branch_false_rs
    (rs : Asm.regset) (code_block : block) (tail_position : Z) : Asm.regset :=
  Asm.Pregmap.set Asm.PC (Vptr code_block (Ptrofs.repr tail_position))
    (vc_cmp_false_rs rs).

(** This is an actual two-instruction execution result.  Its memory equality
    proves that the skipped load/rt-store path cannot change a guest register
    stored anywhere in memory.  It does not assert what the callback did. *)
Theorem vc_lbu_false_return_executes_without_guest_write :
  forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset)
    (m : mem) (code_block : block) (position tail_position : Z),
    rs Asm.GPR3 = Vint Int.zero ->
    rs Asm.PC = Vptr code_block (Ptrofs.repr position) ->
    Asm.label_pos 1%positive 0 (Asm.fn_code f) = Some tail_position ->
    Asm.exec_instr ge f (Asm.Pcmpwi Asm.GPR3 (Asm.Cint Int.zero)) rs m =
      Asm.Next (vc_cmp_false_rs rs) m /\
    Asm.exec_instr ge f (Asm.Pbt Asm.CRbit_2 1%positive)
      (vc_cmp_false_rs rs) m =
      Asm.Next (vc_branch_false_rs rs code_block tail_position) m /\
    (forall r : Asm.ireg,
      vc_branch_false_rs rs code_block tail_position r = rs r).
Proof.
  intros ge f rs m code_block position tail_position Hr3 Hpc Hlabel.
  split.
  - cbn [Asm.exec_instr]. rewrite Hr3. reflexivity.
  - split.
    + unfold vc_cmp_false_rs, vc_branch_false_rs.
      cbn [Asm.exec_instr Asm.reg_of_crbit].
      unfold Asm.nextinstr, Asm.compare_sint.
      repeat rewrite Asm.Pregmap.gso by discriminate.
      rewrite Asm.Pregmap.gss.
      change (Asm.goto_label f 1%positive
        (vc_cmp_false_rs rs) m =
        Asm.Next
          (Asm.Pregmap.set Asm.PC
             (Vptr code_block (Ptrofs.repr tail_position))
             (vc_cmp_false_rs rs)) m).
      unfold Asm.goto_label. rewrite Hlabel.
      unfold vc_cmp_false_rs, Asm.nextinstr.
      rewrite Asm.Pregmap.gss.
      unfold Asm.compare_sint.
      repeat rewrite Asm.Pregmap.gso by discriminate.
      rewrite Hpc. reflexivity.
    + intro r. unfold vc_branch_false_rs, vc_cmp_false_rs,
        Asm.nextinstr, Asm.compare_sint.
      repeat rewrite Asm.Pregmap.gso; try reflexivity; discriminate.
Qed.

(** A callback-frame premise is necessary: the callback can itself write guest
    registers.  The false suffix proves preservation from its *return* state;
    this theorem composes that result with an explicitly bounded callback. *)
Theorem vc_failed_read_preserves_guest_slot_given_callback_frame :
  forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset)
    (before returned : mem) (code_block cpu_block : block)
    (position tail_position guest_slot : Z) (value : val),
    rs Asm.GPR3 = Vint Int.zero ->
    rs Asm.PC = Vptr code_block (Ptrofs.repr position) ->
    Asm.label_pos 1%positive 0 (Asm.fn_code f) = Some tail_position ->
    Mem.load Mint32 before cpu_block guest_slot = Some value ->
    Mem.load Mint32 returned cpu_block guest_slot =
      Mem.load Mint32 before cpu_block guest_slot ->
    exists after_rs,
      Asm.exec_instr ge f (Asm.Pcmpwi Asm.GPR3 (Asm.Cint Int.zero))
        rs returned = Asm.Next (vc_cmp_false_rs rs) returned /\
      Asm.exec_instr ge f (Asm.Pbt Asm.CRbit_2 1%positive)
        (vc_cmp_false_rs rs) returned = Asm.Next after_rs returned /\
      Mem.load Mint32 returned cpu_block guest_slot = Some value.
Proof.
  intros ge f rs before returned code_block cpu_block position tail_position
    guest_slot value Hr3 Hpc Hlabel Hload Hframe.
  destruct (vc_lbu_false_return_executes_without_guest_write ge f rs returned
    code_block position tail_position Hr3 Hpc Hlabel)
    as [Hcmp [Hbranch Hregs]].
  exists (vc_branch_false_rs rs code_block tail_position).
  repeat split; auto. rewrite Hframe. exact Hload.
Qed.

(** The interpreter stores [guest PC + 4] at CPU offset 0x20 before dispatch.
    The concrete CPU low-word register slots are 0x4C + 8*r.  A store at
    +0x20 cannot overlap any such slot.  We deliberately do not conclude that
    this nPC value is the final continuation of a pending JAL delay slot. *)
Theorem vc_npc_store_preserves_all_guest_gpr_slots :
  forall (before after : mem) (cpu_block : block) (guest_pc : int),
    Mem.store Mint32 before cpu_block 32
      (Vint (Int.add guest_pc (Int.repr 4))) = Some after ->
    Mem.load Mint32 after cpu_block 32 =
      Some (Vint (Int.add guest_pc (Int.repr 4))) /\
    forall r : Z, 0 <= r < 32 ->
      Mem.load Mint32 after cpu_block (76 + 8 * r) =
      Mem.load Mint32 before cpu_block (76 + 8 * r).
Proof.
  intros before after cpu_block guest_pc Hstore. split.
  - exact (Mem.load_store_same _ _ _ _ _ _ Hstore).
  - intros r Hr. eapply Mem.load_store_other; [exact Hstore |].
    right. right. change (32 + 4 <= 76 + 8 * r). lia.
Qed.

Definition vc_add_guest_pc_rs (rs : Asm.regset) : Asm.regset :=
  Asm.nextinstr (Asm.Pregmap.set Asm.GPR3
    (Val.add (rs Asm.GPR21) (Vint (Int.repr 4))) rs).

Theorem vc_interpreter_pc_add_store_executes :
  forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset)
    (before after : mem) (cpu_block : block) (guest_pc : int),
    rs Asm.GPR21 = Vint guest_pc ->
    rs Asm.GPR26 = Vptr cpu_block Ptrofs.zero ->
    Mem.store Mint32 before cpu_block 32
      (Vint (Int.add guest_pc (Int.repr 4))) = Some after ->
    Asm.exec_instr ge f
      (Asm.Paddi Asm.GPR3 Asm.GPR21 (Asm.Cint (Int.repr 4))) rs before =
      Asm.Next (vc_add_guest_pc_rs rs) before /\
    Asm.exec_instr ge f
      (Asm.Pstw Asm.GPR3 (Asm.Cint (Int.repr 32)) Asm.GPR26)
      (vc_add_guest_pc_rs rs) before =
      Asm.Next (Asm.nextinstr (vc_add_guest_pc_rs rs)) after /\
    Mem.load Mint32 after cpu_block 32 =
      Some (Vint (Int.add guest_pc (Int.repr 4))) /\
    (forall r : Z, 0 <= r < 32 ->
      Mem.load Mint32 after cpu_block (76 + 8 * r) =
      Mem.load Mint32 before cpu_block (76 + 8 * r)).
Proof.
  intros ge f rs before after cpu_block guest_pc Hpc Hcpu Hstore.
  split; [reflexivity |]. split.
  - assert (H3 : vc_add_guest_pc_rs rs Asm.GPR3 =
        Vint (Int.add guest_pc (Int.repr 4))).
    { unfold vc_add_guest_pc_rs, Asm.nextinstr.
      rewrite Asm.Pregmap.gso by discriminate.
      rewrite Asm.Pregmap.gss, Hpc. reflexivity. }
    assert (H26 : vc_add_guest_pc_rs rs Asm.GPR26 =
        Vptr cpu_block Ptrofs.zero).
    { unfold vc_add_guest_pc_rs, Asm.nextinstr.
      repeat rewrite Asm.Pregmap.gso by discriminate. exact Hcpu. }
    cbn [Asm.exec_instr]. unfold Asm.store1, Asm.gpr_or_zero.
    simpl Asm.ireg_eq. rewrite H26, H3.
    cbn [Val.add Mem.storev Asm.const_low].
    change (match Mem.store Mint32 before cpu_block 32
      (Vint (Int.add guest_pc (Int.repr 4))) with
      | Some m' => Asm.Next
          (Asm.nextinstr (vc_add_guest_pc_rs rs)) m'
      | None => Asm.Stuck
      end = Asm.Next (Asm.nextinstr (vc_add_guest_pc_rs rs)) after).
    rewrite Hstore. reflexivity.
  - exact (vc_npc_store_preserves_all_guest_gpr_slots before after
      cpu_block guest_pc Hstore).
Qed.

(** The authenticated guest-register map used by the wrapper generator.
    JP data VA 0x8016D3B0; EU data VA 0x8016DCD0.  Values with bit 0x100 set
    are memory-resident; the four argument registers are register-resident. *)
Definition vc_wrapper_register_map : list Z :=
  [10; 11; 12; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23; 24; 25; 26;
   272; 273; 274; 275; 276; 277; 278; 279; 27; 28; 29; 30; 284; 31;
   286; 287].

(** These are words emitted by the actual generator, rather than static
    executable words already resident in the DOL.  Reaching generated code
    with these words still requires the explicit code-generation/fetch bridge. *)
Definition vc_emitted_argument_word (opcode guest : Z) : Z :=
  Z.lor (Z.shiftl opcode 26)
    (Z.lor (Z.shiftl (nth (Z.to_nat guest) vc_wrapper_register_map 0) 21)
      (Z.lor (Z.shiftl 3 16) (76 + 8 * guest))).

Definition vc_wrapper_argument_certificate : Prop :=
  map (fun guest => nth (Z.to_nat guest) vc_wrapper_register_map 0)
    [4; 5; 6; 7] = [15; 16; 17; 18] /\
  map (vc_emitted_argument_word 36) [5; 6] = [2449670260; 2451767420] /\
  map (vc_emitted_argument_word 32) [5; 6] = [2181234804; 2183331964].

Theorem vc_wrapper_argument_certificate_checked :
  vc_wrapper_argument_certificate.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** A concrete spill/reload execution interface for the wrapper's a1 or a2
    instructions.  The intervening helper frame is localized to the one CPU
    slot; we do not assume arbitrary C/host callbacks preserve guest state.
    The handler theorem above discharges this frame for its false suffix,
    while effects of other helpers and dispatch remain residual obligations. *)
Theorem vc_wrapper_argument_spill_reload_executes :
  forall (ge : Asm.genv) (f : Asm.function)
    (before_rs returned_rs : Asm.regset) (before spilled returned : mem)
    (cpu_block : block) (argument : int) (host : Asm.ireg) (slot : Z),
    (host = Asm.GPR16 /\ slot = 116 \/
     host = Asm.GPR17 /\ slot = 124) ->
    before_rs Asm.GPR3 = Vptr cpu_block Ptrofs.zero ->
    before_rs host = Vint argument ->
    returned_rs Asm.GPR3 = Vptr cpu_block Ptrofs.zero ->
    Mem.store Mint32 before cpu_block slot (Vint argument) = Some spilled ->
    Mem.load Mint32 returned cpu_block slot =
      Mem.load Mint32 spilled cpu_block slot ->
    Asm.exec_instr ge f (Asm.Pstw host (Asm.Cint (Int.repr slot)) Asm.GPR3)
      before_rs before = Asm.Next (Asm.nextinstr before_rs) spilled /\
    Asm.exec_instr ge f (Asm.Plwz host (Asm.Cint (Int.repr slot)) Asm.GPR3)
      returned_rs returned =
      Asm.Next
        (Asm.nextinstr (Asm.Pregmap.set host (Vint argument) returned_rs))
        returned /\
    Asm.nextinstr (Asm.Pregmap.set host (Vint argument) returned_rs) host =
      Vint argument.
Proof.
  intros ge f before_rs returned_rs before spilled returned cpu_block argument
    host slot Hwhich Hbase Harg Hreturned Hstore Hframe.
  assert (Hload : Mem.load Mint32 returned cpu_block slot = Some (Vint argument)).
  { rewrite Hframe. exact (Mem.load_store_same _ _ _ _ _ _ Hstore). }
  destruct Hwhich as [[-> ->] | [-> ->]]; split.
  - cbn [Asm.exec_instr]. unfold Asm.store1, Asm.gpr_or_zero.
    simpl Asm.ireg_eq. rewrite Hbase, Harg.
    change (match Mem.store Mint32 before cpu_block 116 (Vint argument) with
      | Some m' => Asm.Next (Asm.nextinstr before_rs) m'
      | None => Asm.Stuck end = Asm.Next (Asm.nextinstr before_rs) spilled).
    rewrite Hstore. reflexivity.
  - split.
    + cbn [Asm.exec_instr]. unfold Asm.load1, Asm.gpr_or_zero.
      simpl Asm.ireg_eq. rewrite Hreturned.
      change (match Mem.load Mint32 returned cpu_block 116 with
        | Some v => Asm.Next
            (Asm.nextinstr (Asm.Pregmap.set Asm.GPR16 v returned_rs)) returned
        | None => Asm.Stuck end = Asm.Next
          (Asm.nextinstr (Asm.Pregmap.set Asm.GPR16 (Vint argument) returned_rs))
          returned).
      rewrite Hload. reflexivity.
    + unfold Asm.nextinstr. rewrite Asm.Pregmap.gso by discriminate.
      apply Asm.Pregmap.gss.
  - cbn [Asm.exec_instr]. unfold Asm.store1, Asm.gpr_or_zero.
    simpl Asm.ireg_eq. rewrite Hbase, Harg.
    change (match Mem.store Mint32 before cpu_block 124 (Vint argument) with
      | Some m' => Asm.Next (Asm.nextinstr before_rs) m'
      | None => Asm.Stuck end = Asm.Next (Asm.nextinstr before_rs) spilled).
    rewrite Hstore. reflexivity.
  - split.
    + cbn [Asm.exec_instr]. unfold Asm.load1, Asm.gpr_or_zero.
      simpl Asm.ireg_eq. rewrite Hreturned.
      change (match Mem.load Mint32 returned cpu_block 124 with
        | Some v => Asm.Next
            (Asm.nextinstr (Asm.Pregmap.set Asm.GPR17 v returned_rs)) returned
        | None => Asm.Stuck end = Asm.Next
          (Asm.nextinstr (Asm.Pregmap.set Asm.GPR17 (Vint argument) returned_rs))
          returned).
      rewrite Hload. reflexivity.
    + unfold Asm.nextinstr. rewrite Asm.Pregmap.gso by discriminate.
      apply Asm.Pregmap.gss.
Qed.

(** Exported local boundary.  None of these fields asserts dispatch, callback
    frames, code generation, complete cpuExecuteUpdate, or a successful warp.
    It makes the proved instruction executions load-bearing without replacing
    those remaining machine-execution premises by the desired conclusion. *)
Record vc_failed_load_execution_boundary : Prop := {
  vc_boundary_failed_words : vc_failed_lbu_instruction_certificate;
  vc_boundary_mode_words : vc_mode4_gate_certificate;
  vc_boundary_argument_words : vc_wrapper_argument_certificate;
  vc_boundary_read8_return :
    forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset)
      (m : mem) (saved_lr : val),
      Mem.loadv Mint32 m (Val.add (rs Asm.GPR1) (Vint (Int.repr 20))) =
        Some saved_lr ->
      exists returned,
        vc_run_ppc ge f vc_read8_return_code rs m = Asm.Next returned m /\
        returned Asm.GPR3 = Vint Int.zero /\ returned Asm.PC = saved_lr;
  vc_boundary_false_branch :
    forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset)
      (m : mem) (code_block : block) (position tail_position : Z),
      rs Asm.GPR3 = Vint Int.zero ->
      rs Asm.PC = Vptr code_block (Ptrofs.repr position) ->
      Asm.label_pos 1%positive 0 (Asm.fn_code f) = Some tail_position ->
      Asm.exec_instr ge f (Asm.Pcmpwi Asm.GPR3 (Asm.Cint Int.zero)) rs m =
        Asm.Next (vc_cmp_false_rs rs) m /\
      Asm.exec_instr ge f (Asm.Pbt Asm.CRbit_2 1%positive)
        (vc_cmp_false_rs rs) m =
        Asm.Next (vc_branch_false_rs rs code_block tail_position) m /\
      (forall r : Asm.ireg,
        vc_branch_false_rs rs code_block tail_position r = rs r);
  vc_boundary_pc_store :
    forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset)
      (before after : mem) (cpu_block : block) (guest_pc : int),
      rs Asm.GPR21 = Vint guest_pc ->
      rs Asm.GPR26 = Vptr cpu_block Ptrofs.zero ->
      Mem.store Mint32 before cpu_block 32
        (Vint (Int.add guest_pc (Int.repr 4))) = Some after ->
      Asm.exec_instr ge f
        (Asm.Paddi Asm.GPR3 Asm.GPR21 (Asm.Cint (Int.repr 4))) rs before =
        Asm.Next (vc_add_guest_pc_rs rs) before /\
      Asm.exec_instr ge f
        (Asm.Pstw Asm.GPR3 (Asm.Cint (Int.repr 32)) Asm.GPR26)
        (vc_add_guest_pc_rs rs) before =
        Asm.Next (Asm.nextinstr (vc_add_guest_pc_rs rs)) after /\
      Mem.load Mint32 after cpu_block 32 =
        Some (Vint (Int.add guest_pc (Int.repr 4))) /\
      (forall r : Z, 0 <= r < 32 ->
        Mem.load Mint32 after cpu_block (76 + 8 * r) =
        Mem.load Mint32 before cpu_block (76 + 8 * r));
  vc_boundary_wrapper_arguments :
    forall (ge : Asm.genv) (f : Asm.function)
      (before_rs returned_rs : Asm.regset) (before spilled returned : mem)
      (cpu_block : block) (argument : int) (host : Asm.ireg) (slot : Z),
      (host = Asm.GPR16 /\ slot = 116 \/
       host = Asm.GPR17 /\ slot = 124) ->
      before_rs Asm.GPR3 = Vptr cpu_block Ptrofs.zero ->
      before_rs host = Vint argument ->
      returned_rs Asm.GPR3 = Vptr cpu_block Ptrofs.zero ->
      Mem.store Mint32 before cpu_block slot (Vint argument) = Some spilled ->
      Mem.load Mint32 returned cpu_block slot =
        Mem.load Mint32 spilled cpu_block slot ->
      Asm.exec_instr ge f (Asm.Pstw host (Asm.Cint (Int.repr slot)) Asm.GPR3)
        before_rs before = Asm.Next (Asm.nextinstr before_rs) spilled /\
      Asm.exec_instr ge f (Asm.Plwz host (Asm.Cint (Int.repr slot)) Asm.GPR3)
        returned_rs returned =
        Asm.Next
          (Asm.nextinstr (Asm.Pregmap.set host (Vint argument) returned_rs))
          returned /\
      Asm.nextinstr (Asm.Pregmap.set host (Vint argument) returned_rs) host =
        Vint argument;
  vc_boundary_mode4_gate :
    forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset) (m : mem)
      mode code_block position done_position,
      rs Asm.GPR3 = Vint mode ->
      Int.and mode (Int.repr 4) = Int.zero ->
      rs Asm.PC = Vptr code_block (Ptrofs.repr position) ->
      Asm.label_pos 2%positive 0 (Asm.fn_code f) = Some done_position ->
      vc_exec_rlwinm_record Asm.GPR0 Asm.GPR3 Int.zero (Int.repr 4) rs m =
        Asm.Next (vc_mode4_zero_rs rs) m /\
      Asm.exec_instr ge f (Asm.Pbt Asm.CRbit_2 2%positive)
        (vc_mode4_zero_rs rs) m =
        Asm.Next
          (Asm.Pregmap.set Asm.PC
            (Vptr code_block (Ptrofs.repr done_position))
            (vc_mode4_zero_rs rs)) m;
  vc_boundary_mode4_compcert_equivalence :
    forall (ge : Asm.genv) (f : Asm.function) (rs : Asm.regset) (m : mem) mode,
      rs Asm.GPR3 = Vint mode ->
      vc_exec_rlwinm_record Asm.GPR0 Asm.GPR3 Int.zero (Int.repr 4) rs m =
      Asm.exec_instr ge f
        (Asm.Pandi_ Asm.GPR0 Asm.GPR3 (Asm.Cint (Int.repr 4))) rs m
}.

Theorem vc_failed_load_execution_boundary_checked :
  vc_failed_load_execution_boundary.
Proof.
  constructor.
  - exact vc_failed_lbu_instruction_certificate_checked.
  - exact vc_mode4_gate_certificate_checked.
  - exact vc_wrapper_argument_certificate_checked.
  - exact vc_default_read8_return_executes_false_without_memory_write.
  - exact vc_lbu_false_return_executes_without_guest_write.
  - exact vc_interpreter_pc_add_store_executes.
  - exact vc_wrapper_argument_spill_reload_executes.
  - exact vc_mode4_clear_gate_branches_without_pc_remap_call.
  - exact vc_mode4_record_rotate_matches_compcert_andi.
Qed.
