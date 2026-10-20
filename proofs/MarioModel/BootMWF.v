(* ====================================================================== *)
(* BOOT MEMORY satisfies the carried invariant (phantom-forall guard).      *)
(*                                                                        *)
(* The capstones quantify over memories satisfying mem_ok_lp (MWF_real +  *)
(* an untainted action cell).  A row that no real memory satisfies makes  *)
(* them vacuous -- exactly what happened with the SafeB iff (2026-10-19). *)
(* This file proves, from the generated Clight, that the twelve-TU boot   *)
(* image (Genv.init_mem lp) satisfies MWF_real for a concrete SafeB, and  *)
(* (Part 3) that the real init_mario_from_save_file keeps it.             *)
(*                                                                        *)
(* Part 1 is generic CompCert: what a load from init_mem can return.  A   *)
(* gvar's block holds exactly bytes_of_init_data_list of its initializer, *)
(* so a loaded pointer is one of its Init_addrof targets, and a load from *)
(* an all-Init_space gvar reads zero bytes.                               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib Maps AST Integers Values Memdata Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Errors.
From SM64.Generated Require mario level_update interaction mario_actions_moving.
From SM64.Proofs Require Import SymbolicLinking Taint AGates ActionValueFrame RealFrameLinked
  RealFrameValue CensusV2 MWFReal LinkedTwelve SpawnInit InitMemSat
  EngineV2Consumer RestSurface FloorsSurface ActWriterSurface LptBody.
Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* Part 1: loads from init_mem.                                            *)
(* ---------------------------------------------------------------------- *)

Lemma load_result_ptr : forall chunk v b o,
    Val.load_result chunk v = Vptr b o -> v = Vptr b o.
Proof.
  intros chunk v b o H.
  destruct chunk, v; cbn in H; try discriminate H; try exact H;
    try (unfold Val.norm_bool in H; destruct (Val.is_bool _); discriminate H);
    destruct Archi.ptr64; cbn in H; try discriminate H; exact H.
Qed.

Lemma proj_value_ptr : forall q bl b o,
    proj_value q bl = Vptr b o -> exists q' n, In (Fragment (Vptr b o) q' n) bl.
Proof.
  intros q bl b o H. unfold proj_value in H.
  destruct bl as [| [ | | v q' n] bl' ]; try discriminate H.
  destruct (check_value _ _ _ _); [ | discriminate H ].
  subst v. exists q', n. left. reflexivity.
Qed.

Lemma decode_ptr_frag : forall chunk bl b o,
    decode_val chunk bl = Vptr b o -> exists q n, In (Fragment (Vptr b o) q n) bl.
Proof.
  intros chunk bl b o H. unfold decode_val in H.
  destruct (proj_bytes bl).
  - destruct chunk; try discriminate H.
    unfold Val.norm_bool in H. destruct (Val.is_bool _); discriminate H.
  - destruct chunk; cbn -[Val.load_result] in H; try discriminate H;
      destruct Archi.ptr64; cbn -[Val.load_result] in H; try discriminate H;
      apply load_result_ptr in H; eapply proj_value_ptr; exact H.
Qed.

Lemma inj_value_frag : forall q v v' q' n,
    In (Fragment v' q' n) (inj_value q v) -> v' = v.
Proof.
  intros q v v' q' n. unfold inj_value.
  generalize (size_quantity_nat q) as k. induction k as [| k IH]; cbn.
  - intros [].
  - intros [H | H]; [ injection H as -> _ _; reflexivity | exact (IH H) ].
Qed.

Lemma bytes_ptr_inv : forall {F V : Type} (ge : Genv.t F V) l b o q n,
    In (Fragment (Vptr b o) q n) (Genv.bytes_of_init_data_list ge l) ->
    exists i, In (Init_addrof i o) l /\ Genv.find_symbol ge i = Some b.
Proof.
  intros F V ge l b o q n. induction l as [| d l IH]; cbn; [ intros [] | ].
  intros H. apply in_app_or in H as [H | H].
  - destruct d; cbn in H;
      try (unfold inj_bytes in H; apply in_map_iff in H;
           destruct H as (? & E & _); discriminate E).
    + apply repeat_spec in H. discriminate H.
    + destruct (Genv.find_symbol ge i) as [bi |] eqn:Fs.
      * apply inj_value_frag in H. injection H as -> ->.
        exists i. split; [ left; reflexivity | exact Fs ].
      * apply repeat_spec in H. discriminate H.
  - destruct (IH H) as (i & Hin & Hfs).
    exists i. split; [ right; exact Hin | exact Hfs ].
Qed.

(* THE CORE: a load from a gvar's block in init_mem reads a window of the
   gvar's initializer bytes (non-volatile, in range). *)
Lemma init_mem_load_window :
  forall (p : Clight.program) m id b v chunk ofs val,
    Genv.init_mem p = Some m ->
    Genv.find_symbol (Genv.globalenv p) id = Some b ->
    (prog_defmap p) ! id = Some (Gvar v) ->
    Mem.load chunk m b ofs = Some val ->
    exists pre bytes post,
      Genv.bytes_of_init_data_list (Genv.globalenv p) (gvar_init v)
        = pre ++ bytes ++ post
      /\ length pre = Z.to_nat ofs
      /\ length bytes = size_chunk_nat chunk
      /\ (align_chunk chunk | ofs) /\ 0 <= ofs
      /\ val = decode_val chunk bytes.
Proof.
  intros p m id b v chunk ofs val Hinit Hfs Hdm Hld.
  apply Genv.find_def_symbol in Hdm. destruct Hdm as (b0 & Hfs0 & Hfd).
  rewrite Hfs in Hfs0. injection Hfs0 as <-.
  assert (GI : Genv.globals_initialized (Genv.globalenv p) (Genv.globalenv p) m)
    by (apply Genv.init_mem_characterization_gen; exact Hinit).
  specialize (GI b (Gvar v) Hfd). destruct GI as (_ & Hperm & _ & Hbytes).
  pose proof (Mem.load_valid_access _ _ _ _ _ Hld) as [Hrp Hal].
  set (sz := init_data_list_size (gvar_init v)) in *.
  pose proof (size_chunk_pos chunk) as Hpos.
  assert (P0 : Mem.perm m b ofs Cur Readable) by (apply Hrp; lia).
  assert (P1 : Mem.perm m b (ofs + size_chunk chunk - 1) Cur Readable)
    by (apply Hrp; lia).
  destruct (Hperm _ _ _ P0) as (R0 & O0).
  destruct (Hperm _ _ _ P1) as (R1 & _).
  assert (Hnv : gvar_volatile v = false).
  { unfold Genv.perm_globvar in O0.
    destruct (gvar_volatile v); [ inversion O0 | reflexivity ]. }
  specialize (Hbytes Hnv).
  destruct (Mem.load_loadbytes _ _ _ _ _ Hld) as (bytes & Hlb & Hval).
  replace sz with (ofs + (size_chunk chunk + (sz - ofs - size_chunk chunk)))
    in Hbytes by lia.
  destruct (Mem.loadbytes_split _ _ _ _ _ _ Hbytes ltac:(lia) ltac:(lia))
    as (pre & rest & Hpre & Hrest & E1).
  destruct (Mem.loadbytes_split _ _ _ _ _ _ Hrest ltac:(lia) ltac:(lia))
    as (mid & post & Hmid & _ & E2).
  replace (0 + ofs) with ofs in Hmid by lia.
  rewrite Hmid in Hlb. injection Hlb as <-.
  exists pre, mid, post.
  split; [ rewrite E1, E2; reflexivity | ].
  split; [ rewrite (Mem.loadbytes_length _ _ _ _ _ Hpre); reflexivity | ].
  split; [ rewrite (Mem.loadbytes_length _ _ _ _ _ Hmid); reflexivity | ].
  split; [ exact Hal | split; [ lia | exact Hval ] ].
Qed.

(* a POINTER loaded from a gvar's block is one of its Init_addrof targets *)
Lemma init_mem_load_ptr :
  forall (p : Clight.program) m id b v chunk ofs b' o',
    Genv.init_mem p = Some m ->
    Genv.find_symbol (Genv.globalenv p) id = Some b ->
    (prog_defmap p) ! id = Some (Gvar v) ->
    Mem.load chunk m b ofs = Some (Vptr b' o') ->
    exists i, In (Init_addrof i o') (gvar_init v)
         /\ Genv.find_symbol (Genv.globalenv p) i = Some b'.
Proof.
  intros p m id b v chunk ofs b' o' Hinit Hfs Hdm Hld.
  destruct (init_mem_load_window p m id b v chunk ofs _ Hinit Hfs Hdm Hld)
    as (pre & bytes & post & E & _ & _ & _ & _ & Hval).
  symmetry in Hval. destruct (decode_ptr_frag _ _ _ _ Hval) as (q & n & Hin).
  eapply (bytes_ptr_inv (Genv.globalenv p) (gvar_init v) b' o' q n).
  rewrite E. apply in_or_app. right. apply in_or_app. left. exact Hin.
Qed.

(* all-Init_space initializers (BSS) *)
Definition all_space (l : list init_data) : bool :=
  forallb (fun d => match d with Init_space _ => true | _ => false end) l.

Lemma all_space_bytes : forall {F V : Type} (ge : Genv.t F V) l x,
    all_space l = true ->
    In x (Genv.bytes_of_init_data_list ge l) -> x = Byte Byte.zero.
Proof.
  intros F V ge l x. induction l as [| d l IH]; cbn; [ intros _ [] | ].
  intros Hs Hin. apply andb_prop in Hs as [Hd Hs].
  apply in_app_or in Hin as [Hin | Hin]; [ | exact (IH Hs Hin) ].
  destruct d; try discriminate Hd. cbn in Hin. exact (repeat_spec _ _ _ Hin).
Qed.

Lemma proj_bytes_zeros : forall bl,
    (forall x, In x bl -> x = Byte Byte.zero) ->
    proj_bytes bl = Some (List.repeat Byte.zero (length bl)).
Proof.
  induction bl as [| x bl IH]; intros H; [ reflexivity | ].
  rewrite (H x (or_introl eq_refl)). cbn.
  rewrite IH by (intros y Hy; exact (H y (or_intror Hy))). reflexivity.
Qed.

(* a load from an all-Init_space gvar reads all-zero bytes *)
Lemma init_mem_load_zero :
  forall (p : Clight.program) m id b v chunk ofs val,
    Genv.init_mem p = Some m ->
    Genv.find_symbol (Genv.globalenv p) id = Some b ->
    (prog_defmap p) ! id = Some (Gvar v) ->
    all_space (gvar_init v) = true ->
    Mem.load chunk m b ofs = Some val ->
    val = decode_val chunk (List.map Byte (List.repeat Byte.zero (size_chunk_nat chunk))).
Proof.
  intros p m id b v chunk ofs val Hinit Hfs Hdm Hsp Hld.
  destruct (init_mem_load_window p m id b v chunk ofs _ Hinit Hfs Hdm Hld)
    as (pre & bytes & post & E & _ & Hlen & _ & _ & Hval).
  subst val. f_equal.
  assert (Hz : forall x, In x bytes -> x = Byte Byte.zero).
  { intros x Hx. apply (all_space_bytes (Genv.globalenv p) (gvar_init v) x Hsp).
    rewrite E. apply in_or_app. right. apply in_or_app. left. exact Hx. }
  rewrite <- Hlen. clear -Hz. induction bytes as [| x bytes IH]; [ reflexivity | ].
  cbn. f_equal; [ exact (Hz x (or_introl eq_refl)) | ].
  apply IH. intros y Hy; exact (Hz y (or_intror Hy)).
Qed.

(* a function block holds no readable byte *)
Lemma init_mem_load_gfun :
  forall (p : Clight.program) m id b f chunk ofs val,
    Genv.init_mem p = Some m ->
    Genv.find_symbol (Genv.globalenv p) id = Some b ->
    (prog_defmap p) ! id = Some (Gfun f) ->
    Mem.load chunk m b ofs = Some val -> False.
Proof.
  intros p m id b f chunk ofs val Hinit Hfs Hdm Hld.
  apply Genv.find_def_symbol in Hdm. destruct Hdm as (b0 & Hfs0 & Hfd).
  rewrite Hfs in Hfs0. injection Hfs0 as <-.
  assert (GI : Genv.globals_initialized (Genv.globalenv p) (Genv.globalenv p) m)
    by (apply Genv.init_mem_characterization_gen; exact Hinit).
  specialize (GI b (Gfun f) Hfd). destruct GI as (_ & Hperm).
  pose proof (Mem.load_valid_access _ _ _ _ _ Hld) as [Hrp _].
  pose proof (size_chunk_pos chunk) as Hpos.
  assert (P0 : Mem.perm m b ofs Cur Readable) by (apply Hrp; lia).
  destruct (Hperm _ _ _ P0) as (_ & E). discriminate E.
Qed.

(* a symbol's block that a load succeeds on is a gvar of the program *)
Lemma init_mem_load_sym_gvar :
  forall (p : Clight.program) m id b chunk ofs val,
    Genv.init_mem p = Some m ->
    Genv.find_symbol (Genv.globalenv p) id = Some b ->
    Mem.load chunk m b ofs = Some val ->
    exists v, (prog_defmap p) ! id = Some (Gvar v).
Proof.
  intros p m id b chunk ofs val Hinit Hfs Hld.
  pose proof (Genv.find_symbol_inversion _ _ Hfs) as Hin.
  destruct (prog_defmap_dom _ _ Hin) as (g & Hg).
  destruct g as [f | v]; [ | exists v; exact Hg ].
  exfalso. exact (init_mem_load_gfun p m id b f chunk ofs val Hinit Hfs Hg Hld).
Qed.

(* ---------------------------------------------------------------------- *)
(* Part 2: the twelve-TU boot image satisfies MWF_real.                    *)
(*                                                                        *)
(* One decidable per-gvar check over the generated initializers, by       *)
(* identifier class, vm-certified over the fifteen TUs of the link:        *)
(*  - a gvar outside non_safeb_syms points only outside non_safeb_syms     *)
(*    (R7 for the boot SafeB: nothing points at Mario's block, the         *)
(*    controllers, the anim list, the stored globals, ...);               *)
(*  - gMarioState points only at gMarioStates[0] (R5);                    *)
(*  - sInteractionHandlers points only at the censused handlers (R9);     *)
(*  - the knockback/landing tables are pointer-free and every aligned      *)
(*    int32 window of their bytes is an untainted action (R10 -- incl.     *)
(*    the int16 header window of the LandingAction structs);              *)
(*  - gMarioStates / gControllers are BSS (R1-R4, R6, R11);               *)
(*  - gGlobalTimer / gMarioAnimsBuf are pointer-free (R8, R12, R13).       *)
(* ---------------------------------------------------------------------- *)

Definition addrof_free (l : list init_data) : bool :=
  forallb (fun d => match d with Init_addrof _ _ => false | _ => true end) l.

Definition addrof_all (P : ident -> ptrofs -> bool) (l : list init_data) : bool :=
  forallb (fun d => match d with Init_addrof i o => P i o | _ => true end) l.

Definition ok32 (v : val) : bool :=
  match v with
  | Vundef => true
  | Vint i => negb (is_tainted i)
  | _ => false
  end.

Fixpoint win_ok (l : list memval) : bool :=
  match l with
  | a :: b :: c :: d :: rest => ok32 (decode_val Mint32 [a; b; c; d]) && win_ok rest
  | _ => true
  end.

Definition boot_ge : Genv.t Clight.fundef type := Genv.empty_genv _ _ nil.

Definition boot_gvar_ok (id : ident) (v : globvar type) : bool :=
  let il := gvar_init v in
  (mem_id id non_safeb_syms
   || addrof_all (fun i _ => negb (mem_id i non_safeb_syms)) il)
  && (negb (Pos.eqb id mario._gMarioState)
      || addrof_all (fun i o => Pos.eqb i level_update._gMarioStates
                                && Ptrofs.eq o Ptrofs.zero) il)
  && (negb (Pos.eqb id interaction._sInteractionHandlers)
      || addrof_all (fun i o => mem_id i interaction_handler_ids
                                && Ptrofs.eq o Ptrofs.zero) il)
  && (negb (mem_id id knockback_table_ids)
      || (addrof_free il && win_ok (Genv.bytes_of_init_data_list boot_ge il)))
  && (negb (mem_id id [level_update._gMarioStates; mario._gControllers])
      || all_space il)
  && (negb (mem_id id [interaction._gGlobalTimer; mario._gMarioAnimsBuf])
      || addrof_free il).

Definition tu_boot_ok (q : Clight.program) : bool :=
  PTree_Properties.for_all (prog_defmap q)
    (fun id gd => match gd with Gvar v => boot_gvar_ok id v | _ => true end).

Lemma fifteen_boot_ok : forallb tu_boot_ok (mario.prog :: tu_rest) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma mario_boot_ok : tu_boot_ok mario.prog = true.
Proof.
  pose proof fifteen_boot_ok as H. cbn [forallb] in H.
  apply andb_prop in H as [H _]. exact H.
Qed.

Lemma rest_boot_ok : forall q, In q tu_rest -> tu_boot_ok q = true.
Proof.
  pose proof fifteen_boot_ok as H. cbn [forallb] in H.
  apply andb_prop in H as [_ H].
  intros q Hin. exact (proj1 (forallb_forall _ _) H q Hin).
Qed.

Lemma tu_boot_ok_gvar : forall q id v,
    tu_boot_ok q = true -> (prog_defmap q) ! id = Some (Gvar v) ->
    boot_gvar_ok id v = true.
Proof.
  intros q id v Hok Hdm. unfold tu_boot_ok in Hok.
  exact (proj1 (PTree_Properties.for_all_correct _ _) Hok id (Gvar v) Hdm).
Qed.

(* every gvar of a twelve-TU link passes (origin: it IS one TU's gvar) *)
Lemma linked12_boot_gvar : forall lp id v,
    linked12 lp -> (prog_defmap lp) ! id = Some (Gvar v) ->
    boot_gvar_ok id v = true.
Proof.
  intros lp id v H12 Hdm. unfold linked12 in H12.
  destruct (link_chain_gvar_origin tu_rest mario.prog lp id v H12 Hdm)
    as [Hm | (q & Hin & Hq)].
  - exact (tu_boot_ok_gvar _ _ _ mario_boot_ok Hm).
  - exact (tu_boot_ok_gvar _ _ _ (rest_boot_ok q Hin) Hq).
Qed.

(* ---- small reflection helpers ---- *)

Lemma impl_b : forall b c, negb b || c = true -> b = true -> c = true.
Proof. intros [] c H E; [ exact H | discriminate E ]. Qed.

Lemma mem_id_true_in : forall t l, mem_id t l = true -> In t l.
Proof.
  intros t l H. unfold mem_id in H. apply existsb_exists in H.
  destruct H as (x & Hx & E). apply Pos.eqb_eq in E. subst x. exact Hx.
Qed.

Lemma addrof_all_in : forall P l i o,
    addrof_all P l = true -> In (Init_addrof i o) l -> P i o = true.
Proof.
  intros P l i o H Hin. unfold addrof_all in H.
  exact (proj1 (forallb_forall _ _) H _ Hin).
Qed.

Lemma addrof_free_in : forall l i o,
    addrof_free l = true -> ~ In (Init_addrof i o) l.
Proof.
  intros l i o H Hin. unfold addrof_free in H.
  pose proof (proj1 (forallb_forall _ _) H _ Hin) as E. discriminate E.
Qed.

Lemma all_space_addrof_free : forall l, all_space l = true -> addrof_free l = true.
Proof.
  induction l as [| d l IH]; cbn; [ reflexivity | ].
  intros H. apply andb_prop in H as [Hd Hl].
  destruct d; try discriminate Hd. exact (IH Hl).
Qed.

Lemma bytes_addrof_free_ge : forall {F1 V1 F2 V2 : Type}
    (ge1 : Genv.t F1 V1) (ge2 : Genv.t F2 V2) l,
    addrof_free l = true ->
    Genv.bytes_of_init_data_list ge1 l = Genv.bytes_of_init_data_list ge2 l.
Proof.
  intros F1 V1 F2 V2 ge1 ge2 l. induction l as [| d l IH]; cbn; [ reflexivity | ].
  intros H. apply andb_prop in H as [Hd Hl].
  rewrite (IH Hl). destruct d; try discriminate Hd; reflexivity.
Qed.

Lemma decode_zero_vint : forall chunk v,
    decode_val chunk (List.map Byte (List.repeat Byte.zero (size_chunk_nat chunk)))
      = Vint v -> v = Int.zero.
Proof.
  intros chunk v H.
  destruct chunk; vm_compute in H; try discriminate H;
    injection H as <-; apply Int.same_if_eq; vm_compute; reflexivity.
Qed.

Lemma ok32_sound : forall v, ok32 v = true ->
    v = Vundef \/ exists vi, v = Vint vi /\ not_tainted vi.
Proof.
  intros v H. destruct v; try discriminate H; [ left; reflexivity | ].
  right. exists i. split; [ reflexivity | ].
  unfold not_tainted. cbn in H. destruct (is_tainted i); [ discriminate H | reflexivity ].
Qed.

Lemma win_ok_sound : forall n pre bytes post,
    length pre = (4 * n)%nat -> length bytes = 4%nat ->
    win_ok (pre ++ bytes ++ post) = true ->
    ok32 (decode_val Mint32 bytes) = true.
Proof.
  induction n as [| n IH]; intros pre bytes post Hp Hb Hw.
  - destruct pre; [ | discriminate Hp ].
    destruct bytes as [| a [| b [| c [| d [| x l]]]]]; try discriminate Hb.
    cbn [app win_ok] in Hw. apply andb_prop in Hw as [H _]. exact H.
  - destruct pre as [| a [| b [| c [| d pre']]]]; try (cbn in Hp; lia).
    cbn [app win_ok] in Hw. apply andb_prop in Hw as [_ Hw].
    apply (IH pre' bytes post); [ cbn in Hp; lia | exact Hb | exact Hw ].
Qed.

(* ---------------------------------------------------------------------- *)
(* The boot memory and the boot SafeB.                                     *)
(* ---------------------------------------------------------------------- *)

(* the boot chase set: every symbol block outside non_safeb_syms (the
   SpawnInit witness shape, with no runtime object blocks yet) *)
Definition SafeB_boot (lp : Clight.program) : block -> Prop :=
  SafeB_wit lp (fun _ => False) (fun id => mem_id id non_safeb_syms = false).

Lemma SafeB_boot_syms_ok : forall lp, SafeB_syms_ok lp (SafeB_boot lp).
Proof.
  intros lp. apply safeb_wit_sat; [ intros b [] | intros id H; exact H | exact gobj_not_nonsafe ].
Qed.

Lemma sfam_not_nonsafe :
  mem_id mario_actions_moving._sFloorAlignMatrix non_safeb_syms = false.
Proof. vm_compute. reflexivity. Qed.

Lemma SafeB_boot_sym : forall lp b, SafeB_boot lp b ->
    exists id, mem_id id non_safeb_syms = false
          /\ Genv.find_symbol (lp_ge lp) id = Some b.
Proof.
  intros lp b [[] | (id & [Hok | ->] & Hfs)].
  - exists id. split; [ exact Hok | exact Hfs ].
  - exists mario_actions_moving._sFloorAlignMatrix.
    split; [ exact sfam_not_nonsafe | exact Hfs ].
Qed.

Section Boot.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable m0 : mem.
  Hypothesis Hinit : Genv.init_mem lp = Some m0.
  Variables bm bc : block.
  Hypothesis Hbm : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.

  Let SafeB := SafeB_boot lp.

  (* a successful load from a symbol block reads a passing gvar's bytes *)
  Lemma boot_load : forall id b chunk ofs val,
      Genv.find_symbol (lp_ge lp) id = Some b ->
      Mem.load chunk m0 b ofs = Some val ->
      exists v, (prog_defmap lp) ! id = Some (Gvar v)
           /\ boot_gvar_ok id v = true.
  Proof.
    intros id b chunk ofs val Hfs Hld.
    destruct (init_mem_load_sym_gvar lp m0 id b chunk ofs val Hinit Hfs Hld)
      as (v & Hdm).
    exists v. split; [ exact Hdm | exact (linked12_boot_gvar lp id v H12 Hdm) ].
  Qed.

  Lemma boot_load_ptr : forall id b chunk ofs b' o',
      Genv.find_symbol (lp_ge lp) id = Some b ->
      Mem.load chunk m0 b ofs = Some (Vptr b' o') ->
      exists v i, boot_gvar_ok id v = true
             /\ In (Init_addrof i o') (gvar_init v)
             /\ Genv.find_symbol (lp_ge lp) i = Some b'.
  Proof.
    intros id b chunk ofs b' o' Hfs Hld.
    destruct (boot_load id b chunk ofs _ Hfs Hld) as (v & Hdm & Hok).
    destruct (init_mem_load_ptr lp m0 id b v chunk ofs b' o' Hinit Hfs Hdm Hld)
      as (i & Hin & Hfi).
    exists v, i. split; [ exact Hok | split; [ exact Hin | exact Hfi ] ].
  Qed.

  (* class projections of boot_gvar_ok *)
  Ltac boot_split H :=
    unfold boot_gvar_ok in H; cbv zeta in H;
    apply andb_prop in H as [H H6];
    apply andb_prop in H as [H H5];
    apply andb_prop in H as [H H4];
    apply andb_prop in H as [H H3];
    apply andb_prop in H as [H1 H2].

  Lemma boot_bss_zero : forall id b chunk ofs val,
      mem_id id [level_update._gMarioStates; mario._gControllers] = true ->
      Genv.find_symbol (lp_ge lp) id = Some b ->
      Mem.load chunk m0 b ofs = Some val ->
      val = decode_val chunk (List.map Byte (List.repeat Byte.zero (size_chunk_nat chunk))).
  Proof.
    intros id b chunk ofs val Hid Hfs Hld.
    destruct (boot_load id b chunk ofs _ Hfs Hld) as (v & Hdm & Hok).
    boot_split Hok.
    exact (init_mem_load_zero lp m0 id b v chunk ofs val Hinit Hfs Hdm
             (impl_b _ _ H5 Hid) Hld).
  Qed.

  Lemma boot_bss_noptr : forall id b chunk ofs b' o',
      mem_id id [level_update._gMarioStates; mario._gControllers;
                 interaction._gGlobalTimer; mario._gMarioAnimsBuf] = true ->
      Genv.find_symbol (lp_ge lp) id = Some b ->
      Mem.load chunk m0 b ofs = Some (Vptr b' o') -> False.
  Proof.
    intros id b chunk ofs b' o' Hid Hfs Hld.
    destruct (boot_load_ptr id b chunk ofs b' o' Hfs Hld) as (v & i & Hok & Hin & _).
    boot_split Hok.
    assert (Hfree : addrof_free (gvar_init v) = true).
    { apply mem_id_true_in in Hid.
      destruct Hid as [<- | [<- | [<- | [<- | []]]]];
        first [ apply all_space_addrof_free; apply (impl_b _ _ H5);
                vm_compute; reflexivity
              | apply (impl_b _ _ H6); vm_compute; reflexivity ]. }
    exact (addrof_free_in _ _ _ Hfree Hin).
  Qed.

  Lemma mem_id_lit : forall l id, In id l -> mem_id id l = true.
  Proof.
    intros l id Hin. unfold mem_id. apply existsb_exists.
    exists id. split; [ exact Hin | apply Pos.eqb_refl ].
  Qed.

  Lemma gms_bss :
    mem_id level_update._gMarioStates [level_update._gMarioStates; mario._gControllers] = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma ctl_bss :
    mem_id mario._gControllers [level_update._gMarioStates; mario._gControllers] = true.
  Proof. vm_compute. reflexivity. Qed.

  Ltac nonptr id b :=
    exfalso; eapply (boot_bss_noptr id b);
    [ vm_compute; reflexivity | eassumption | eassumption ].

  Lemma boot_valid : forall id b,
      Genv.find_symbol (lp_ge lp) id = Some b -> Mem.valid_block m0 b.
  Proof. intros id b Hfs. eapply Genv.find_symbol_not_fresh; [ exact Hinit | exact Hfs ]. Qed.

  Lemma boot_sym_ne : forall id1 id2 b1 b2,
      id1 <> id2 ->
      Genv.find_symbol (lp_ge lp) id1 = Some b1 ->
      Genv.find_symbol (lp_ge lp) id2 = Some b2 -> b1 <> b2.
  Proof.
    intros id1 id2 b1 b2 Hne H1 H2 E. subst b2. apply Hne.
    eapply Genv.genv_vars_inj; [ exact H1 | exact H2 ].
  Qed.

  Theorem boot_mwf : MWF_real lp bm bc Ptrofs.zero SafeB m0.
  Proof.
    unfold MWF_real.
    split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split; [ | split ] ] ] ] ] ] ] ] ] ] ] ] ].
    - (* R0 *)
      split; [ exact (boot_valid _ _ Hbm) | ].
      split; [ exact (boot_valid _ _ Hbc) | ].
      split; [ intros gb Hg; exact (boot_valid _ _ Hg) | ].
      split; [ intros b Hs; destruct (SafeB_boot_sym lp b Hs) as (id & _ & Hfs);
               exact (boot_valid _ _ Hfs) | ].
      split; [ intros gb Hg; exact (boot_valid _ _ Hg) | ].
      split; [ intros tb Hg; exact (boot_valid _ _ Hg) | ].
      split; [ intros gid kb _ Hg; exact (boot_valid _ _ Hg) | ].
      change (Genv.genv_next (lp_ge lp)) with (Genv.genv_next (Genv.globalenv lp)).
      rewrite (Genv.init_mem_genv_next _ Hinit). apply Ple_refl.
    - (* R1 *)
      intros v Hld.
      pose proof (boot_bss_zero _ _ _ _ _ gms_bss Hbm Hld) as E.
      symmetry in E. apply decode_zero_vint in E. subst v.
      apply Int.same_if_eq. vm_compute. reflexivity.
    - (* R2 *)
      intros b' o' Hld. nonptr level_update._gMarioStates bm.
    - (* R3 *)
      intros v Hld.
      pose proof (boot_bss_zero _ _ _ _ _
                    ctl_bss Hbc Hld) as E.
      symmetry in E. apply decode_zero_vint in E. subst v.
      apply Int.same_if_eq. vm_compute. reflexivity.
    - (* R4 *)
      intros av Hld.
      pose proof (boot_bss_zero _ _ _ _ _ gms_bss Hbm Hld) as E.
      right. rewrite E. eexists. reflexivity.
    - (* R5 *)
      intros gb b o Hg Hld. unfold Mem.loadv in Hld.
      destruct (boot_load_ptr _ _ _ _ _ _ Hg Hld) as (v & i & Hok & Hin & Hfi).
      boot_split Hok.
      pose proof (addrof_all_in _ _ _ _ (impl_b _ _ H2 (Pos.eqb_refl _)) Hin) as Hio.
      apply andb_prop in Hio as [Ei Eo]. apply Pos.eqb_eq in Ei. subst i.
      rewrite Hbm in Hfi. injection Hfi as <-.
      split; [ reflexivity | exact (Ptrofs.same_if_eq _ _ Eo) ].
    - (* R6 *)
      intros fld delta b' o' _ _ Hld. unfold Mem.loadv in Hld.
      nonptr level_update._gMarioStates bm.
    - (* R7 *)
      intros b ofs b' o' Hs Hld. unfold Mem.loadv in Hld.
      destruct (SafeB_boot_sym lp b Hs) as (id & Hns & Hfs).
      destruct (boot_load_ptr _ _ _ _ _ _ Hfs Hld) as (v & i & Hok & Hin & Hfi).
      boot_split Hok. rewrite Hns in H1. cbn [orb] in H1.
      pose proof (addrof_all_in _ _ _ _ H1 Hin) as Hi. apply negb_true_iff in Hi.
      right. exists i. split; [ left; exact Hi | exact Hfi ].
    - (* R8 *)
      intros gb v Hg Hld bb oo E. subst v. nonptr interaction._gGlobalTimer gb.
    - (* R9 *)
      intros tb ofs b o Hg Hld.
      destruct (boot_load_ptr _ _ _ _ _ _ Hg Hld) as (v & i & Hok & Hin & Hfi).
      boot_split Hok.
      pose proof (addrof_all_in _ _ _ _ (impl_b _ _ H3 (Pos.eqb_refl _)) Hin) as Hio.
      apply andb_prop in Hio as [Ei Eo].
      exists i. split; [ exact (mem_id_true_in _ _ Ei) | ].
      split; [ exact Hfi | exact (Ptrofs.same_if_eq _ _ Eo) ].
    - (* R10 *)
      intros gid kb ofs v Hk Hg Hld.
      destruct (boot_load _ _ _ _ _ Hg Hld) as (gv & Hdm & Hok).
      boot_split Hok.
      apply (impl_b _ _ H4) in Hk. apply andb_prop in Hk as [Hfree Hwin].
      destruct (init_mem_load_window lp m0 gid kb gv Mint32 ofs v Hinit Hg Hdm Hld)
        as (pre & bytes & post & E & Hpre & Hlen & Hal & Hofs & Hval).
      rewrite (bytes_addrof_free_ge (Genv.globalenv lp) boot_ge _ Hfree) in E.
      destruct Hal as (z & Hz). cbn [align_chunk] in Hz.
      apply ok32_sound. rewrite Hval.
      apply (win_ok_sound (Z.to_nat z) pre bytes post).
      + rewrite Hpre, Hz, Z2Nat.inj_mul by lia. cbn [Z.to_nat Pos.to_nat]. lia.
      + exact Hlen.
      + rewrite <- E. exact Hwin.
    - (* R11 *)
      intros ab b o _ Hld. nonptr level_update._gMarioStates bm.
    - (* R12 *)
      intros ab ofs b' o' Hab Hld. nonptr mario._gMarioAnimsBuf ab.
    - (* R13 *)
      intros ab bt ot mb mo Hab Hld _. nonptr mario._gMarioAnimsBuf ab.
    - (* R14 *)
      intros ab Hab.
      split; [ apply (boot_sym_ne mario._gMarioAnimsBuf level_update._gMarioStates);
               [ vm_compute; discriminate | exact Hab | exact Hbm ] | ].
      split; [ apply (boot_sym_ne mario._gMarioAnimsBuf mario._gControllers);
               [ vm_compute; discriminate | exact Hab | exact Hbc ] | ].
      split; [ | exact (boot_valid _ _ Hab) ].
      intros Hs. destruct (SafeB_boot_sym lp ab Hs) as (id & Hns & Hfs).
      assert (E : id = mario._gMarioAnimsBuf)
        by (eapply Genv.genv_vars_inj; [ exact Hfs | exact Hab ]).
      subst id. vm_compute in Hns. discriminate Hns.
  Qed.

  Theorem boot_nontainted : action_sat not_tainted m0 bm.
  Proof.
    intros v Hld.
    pose proof (boot_bss_zero _ _ _ _ _ gms_bss Hbm Hld) as E.
    symmetry in E. apply decode_zero_vint in E. subst v.
    vm_compute. reflexivity.
  Qed.
End Boot.

(* ---------------------------------------------------------------------- *)
(* Part 3: the real init_mario_from_save_file keeps the invariant.         *)
(*                                                                        *)
(* mario.c:1862-1891 -- a straight line of stores through gMarioState      *)
(* (window cells, action = 0, statusForCamera = &gPlayerCameraState[0],   *)
(* marioBodyState = &gBodyStates[0], controller = &gControllers[0],       *)
(* animList = &gMarioAnimsBuf), two gHudDisplay stores, and one call,      *)
(* save_file_get_total_star_count, through the capstone's existing         *)
(* object-external row.  Walked with LptBody's cw walker.                  *)
(* ---------------------------------------------------------------------- *)

(* value shapes of the stored right-hand sides *)
Lemma eval_glob_arr_add : forall ge le m g elt n a i ia pty v,
    eval_expr ge empty_env le m
      (Ebinop Oadd (Evar g (Tarray elt n a)) (Econst_int i (Tint I32 Signed ia)) pty) v ->
    exists gb o, Genv.find_symbol ge g = Some gb /\ v = Vptr gb o
            /\ (Int.eq i Int.zero = true -> o = Ptrofs.zero).
Proof.
  intros ge le m g elt n a i ia pty v H.
  inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end ].
  match goal with H1 : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv H1 end.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    inv Hl; [ rewrite PTree.gempty in *; discriminate | ] end.
  match goal with H2 : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H2 end;
    [ | match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end ].
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
    try (cbn in *; discriminate).
  match goal with Hb : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
    cbn in Hb; injection Hb as <- end.
  do 2 eexists. split; [ eassumption | split; [ reflexivity | ] ].
  intros Ei. apply Int.same_if_eq in Ei. subst i.
  assert (Z0 : Ptrofs.of_ints Int.zero = Ptrofs.zero)
    by (apply Ptrofs.same_if_eq; vm_compute; reflexivity).
  rewrite Z0, Ptrofs.mul_zero.
  apply Ptrofs.add_zero.
Qed.

Lemma eval_glob_addrof : forall ge le m g gty pty v,
    eval_expr ge empty_env le m (Eaddrof (Evar g gty) pty) v ->
    exists gb, Genv.find_symbol ge g = Some gb /\ v = Vptr gb Ptrofs.zero.
Proof.
  intros ge le m g gty pty v H.
  inv H; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    inv Hl; [ rewrite PTree.gempty in *; discriminate | ] end.
  eexists. split; [ eassumption | reflexivity ].
Qed.

Lemma eval_const_int : forall ge e le m i ty v,
    eval_expr ge e le m (Econst_int i ty) v -> v = Vint i.
Proof.
  intros ge e le m i ty v H. inv H; [ reflexivity | ].
  match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end.
Qed.

(* a cast of a pointer is that pointer or not a pointer at all *)
Lemma sem_cast_ptr : forall b o t1 t2 m v,
    sem_cast (Vptr b o) t1 t2 m = Some v ->
    v = Vptr b o \/ (forall b' o', v <> Vptr b' o').
Proof.
  intros b o t1 t2 m v H. unfold sem_cast in H.
  destruct (classify_cast t1 t2); cbn in H; try discriminate H;
    repeat match type of H with
      | context [ if ?c then _ else _ ] => destruct c
      end;
    try discriminate H; injection H as <-;
    first [ left; reflexivity | right; intros b' o' E; discriminate E ].
Qed.

(* a cast of an int is never a pointer *)
Lemma sem_cast_int : forall i t1 t2 m v,
    sem_cast (Vint i) t1 t2 m = Some v -> forall b' o', v <> Vptr b' o'.
Proof.
  intros i t1 t2 m v H. unfold sem_cast in H.
  destruct (classify_cast t1 t2); cbn in H; try discriminate H;
    repeat match type of H with
      | context [ if ?c then _ else _ ] => destruct c
      | context [ match ?x with _ => _ end ] => destruct x
      end;
    try discriminate H; injection H as <-; intros b' o' E; discriminate E.
Qed.

Lemma sem_cast_ptr_ptr : forall b o t1 a1 t2 a2 m v,
    sem_cast (Vptr b o) (Tpointer t1 a1) (Tpointer t2 a2) m = Some v -> v = Vptr b o.
Proof. intros b o t1 a1 t2 a2 m v H. cbn in H. injection H as <-. reflexivity. Qed.

Lemma sem_cast_int_uint : forall i ia m v,
    sem_cast (Vint i) (Tint I32 Signed ia) tuint m = Some v -> v = Vint i.
Proof.
  intros i ia m v H. unfold sem_cast in H. cbn in H.
  destruct Archi.ptr64; cbn in H; injection H as <-; reflexivity.
Qed.

Lemma sassign_inv : forall ge e le m a1 a2 t le' m' out,
    exec_stmt function_entry2 ge e le m (Sassign a1 a2) t le' m' out ->
    exists loc ofs bf v2 v,
      eval_lvalue ge e le m a1 loc ofs bf /\ eval_expr ge e le m a2 v2
      /\ sem_cast v2 (typeof a2) (typeof a1) m = Some v
      /\ assign_loc ge (typeof a1) m loc ofs bf v m'.
Proof.
  intros ge e le m a1 a2 t le' m' out H. inv H.
  do 5 eexists. split; [ eassumption | split; [ eassumption | split; eassumption ] ].
Qed.

(* the stores an assignment performs on a By_value / bitfield lvalue *)
Lemma assign_loc_store : forall ce ty m b ofs bf v m' ch0,
    access_mode ty = By_value ch0 ->
    assign_loc ce ty m b ofs bf v m' ->
    exists ch d vv, Mem.store ch m b d vv = Some m'.
Proof.
  intros ce ty m b ofs bf v m' ch0 Ham H. inv H.
  - do 3 eexists. exact H1.
  - congruence.
  - match goal with Hs : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hs end.
    do 3 eexists. eassumption.
Qed.

Definition ms_ty : type := Tstruct mario._MarioState noattr.

(* the temps init_mario_from_save_file loads gMarioState into *)
Definition gms_temps : list ident :=
  [ mario._t'2; mario._t'3; mario._t'4; mario._t'6; mario._t'7; mario._t'8;
    mario._t'9; mario._t'11; mario._t'12; mario._t'13; mario._t'14;
    mario._t'15; mario._t'16; mario._t'17; mario._t'18; mario._t'19 ].

Definition is_gms_evar (a : expr) : bool :=
  match a with
  | Evar g ty => Pos.eqb g mario._gMarioState && proj_sumbool (type_eq ty (tptr ms_ty))
  | _ => false
  end.

Definition init_set_ok (id : ident) (a : expr) : bool :=
  negb (mem_id id gms_temps) || is_gms_evar a.

(* &g[0]-style right-hand sides *)
Definition arr_add_glob (a : expr) : option (ident * int) :=
  match a with
  | Ebinop Oadd (Evar g (Tarray _ _ _)) (Econst_int i (Tint I32 Signed noattr))
      (Tpointer _ _) => Some (g, i)
  | _ => None
  end.

Lemma arr_add_glob_inv : forall a g i,
    arr_add_glob a = Some (g, i) ->
    exists elt n att ia pt pa,
      a = Ebinop Oadd (Evar g (Tarray elt n att)) (Econst_int i (Tint I32 Signed ia))
            (Tpointer pt pa).
Proof.
  intros a g i H. unfold arr_add_glob in H.
  repeat match type of H with
         | match ?x with _ => _ end = _ => destruct x; try discriminate H
         end.
  injection H as <- <-. do 6 eexists. reflexivity.
Qed.

Definition is_safe_rhs (a : expr) : bool :=
  match arr_add_glob a with
  | Some (g, _) => negb (mem_id g non_safeb_syms)
  | None => false
  end.

Definition is_ctl_rhs (a : expr) : bool :=
  match arr_add_glob a with
  | Some (g, i) => Pos.eqb g mario._gControllers && Int.eq i Int.zero
  | None => false
  end.

Definition is_anim_rhs (a : expr) : bool :=
  match a with
  | Eaddrof (Evar g _) (Tpointer _ _) => Pos.eqb g mario._gMarioAnimsBuf
  | _ => false
  end.

Definition is_tptr (t : type) : bool :=
  match t with Tpointer _ _ => true | _ => false end.

Definition is_act_rhs (a : expr) : bool :=
  match a with
  | Econst_int i (Tint I32 Signed noattr) => negb (is_tainted i)
  | _ => false
  end.

Definition ms_store_kind (fld : ident) (delta : Z) (ch : memory_chunk) (fty : type)
    (a2 : expr) : bool :=
  store_window_ok delta (size_chunk ch)
  || (Z.eqb delta 12 && proj_sumbool (type_eq fty tuint) && is_act_rhs a2)
  || (mem_id fld chase_root_fields && negb (Pos.eqb fld mario._marioObj)
      && proj_sumbool (chunk_eq ch Mptr) && is_safe_rhs a2)
  || (Z.eqb delta 156 && proj_sumbool (chunk_eq ch Mptr) && is_tptr fty && is_ctl_rhs a2)
  || (Z.eqb delta 160 && proj_sumbool (chunk_eq ch Mptr) && is_tptr fty && is_anim_rhs a2).

Definition init_store_ok (a1 a2 : expr) : bool :=
  match a1 with
  | Efield (Ederef (Etempvar t pty) sty) fld fty =>
      mem_id t gms_temps && proj_sumbool (type_eq pty (tptr ms_ty))
      && proj_sumbool (type_eq sty ms_ty)
      && match field_offset (prog_comp_env mario.prog) fld mario_state_members,
               access_mode fty with
         | OK (delta, Full), By_value ch => ms_store_kind fld delta ch fty a2
         | _, _ => false
         end
  | Efield (Evar g (Tstruct _ _)) _ fty =>
      mem_id g stored_globals
      && match access_mode fty with By_value _ => true | _ => false end
  | _ => false
  end.

Definition init_call_ok (o : option ident) (a : expr) (al : list expr) : bool :=
  match a with
  | Evar fid (Tfunction _ _ _) =>
      Pos.eqb fid mario._save_file_get_total_star_count
      && match o with Some t => negb (mem_id t gms_temps) | None => true end
  | _ => false
  end.

Lemma init_pin :
  (prog_defmap mario.prog) ! mario._init_mario_from_save_file
    = Some (Gfun (Internal mario.f_init_mario_from_save_file)).
Proof. vm_compute. reflexivity. Qed.

Lemma init_chk :
  cw_chk init_set_ok init_store_ok init_call_ok
    (fn_body mario.f_init_mario_from_save_file) = true.
Proof. vm_compute. reflexivity. Qed.

Section InitWalk.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable m0 : mem.
  Hypothesis Hinit : Genv.init_mem lp = Some m0.
  Variables bm bc : block.
  Hypothesis Hbm : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.

  Notation SB := (SafeB_boot lp).
  Notation MWF := (MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp)).

  (* the save-file star count: the capstone's object-external row *)
  Hypothesis Hsf : call_pres_ext lp bm (fun m => ctl_a_clear m bm) MWF
                     mario._save_file_get_total_star_count.

  Lemma Hspawn0 : spawn_ok lp m0 bm bc Ptrofs.zero.
  Proof. split; [ exact Hinit | split; [ exact Hbm | split; [ exact Hbc | reflexivity ] ] ]. Qed.

  Let LOm := linked12_LO_mario lp H12.
  Let Sy := SafeB_boot_syms_ok lp.
  Let D1 := spawn_Hbc_bm lp m0 bm bc Ptrofs.zero Hspawn0.
  Let D2 := safeb_not_bm lp m0 bm bc Ptrofs.zero SB Hspawn0 Sy.
  Let D3 := gms_blk lp m0 bm bc Ptrofs.zero SB Hspawn0 Sy.
  Let D4 := gtimer_blk lp m0 bm bc Ptrofs.zero SB Hspawn0 Sy.
  Let D5 := table_blk lp m0 bm bc Ptrofs.zero SB Hspawn0 Sy.
  Let D6 := ktab_blk lp m0 bm bc Ptrofs.zero SB Hspawn0 Sy.
  Let D7 := glob_blk lp m0 bm bc Ptrofs.zero SB Hspawn0 Sy.

  Definition initF (m : mem) : Prop :=
    Mem.valid_block m bm /\ action_sat not_tainted m bm /\ MWF m.

  Definition initG (le : temp_env) : Prop :=
    forall t b o, mem_id t gms_temps = true ->
      le ! t = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero.

  Lemma init_set_sound : forall id a le m v,
      init_set_ok id a = true -> initG le -> initF m ->
      eval_expr (lp_ge lp) empty_env le m a v -> initG (PTree.set id v le).
  Proof.
    intros id a le m v Hok HG (_ & _ & M) Hev t b o Ht Hle.
    destruct (Pos.eq_dec t id) as [-> | Hne].
    - rewrite PTree.gss in Hle. injection Hle as ->.
      unfold init_set_ok in Hok. rewrite Ht in Hok. cbn [negb orb] in Hok.
      destruct a as [ | | | | g ty | | | | | | | | | ]; try discriminate Hok.
      cbn [is_gms_evar] in Hok. apply andb_prop in Hok as [Eg Ety].
      apply Pos.eqb_eq in Eg. apply proj_sumbool_true in Ety. subst g ty.
      apply eval_expr_Evar_load in Hev as (loc & ofs & bf & Hlv & Hd).
      apply eval_lvalue_Evar_global_loc in Hlv as [Hfs ->]; [ | apply PTree.gempty ].
      inv Hd;
        try (match goal with H : access_mode _ = _ |- _ =>
               cbv [access_mode tptr ms_ty] in H; discriminate H end);
        try (match goal with H : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv H end).
      match goal with Ha : access_mode _ = By_value _ |- _ =>
        cbv [access_mode tptr ms_ty] in Ha; injection Ha as <- end.
      exact (mwf_real_pgms lp bm bc Ptrofs.zero SB m loc b o M Hfs ltac:(assumption)).
    - rewrite PTree.gso in Hle by exact Hne. exact (HG t b o Ht Hle).
  Qed.

  (* the Mario-field lvalue resolves to bm at the field offset *)
  Lemma init_mfield_lv : forall le m t fld fty delta loc ofs bf,
      initG le -> mem_id t gms_temps = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members = OK (delta, Full) ->
      eval_lvalue (lp_ge lp) empty_env le m
        (Efield (Ederef (Etempvar t (tptr ms_ty)) ms_ty) fld fty) loc ofs bf ->
      loc = bm /\ ofs = Ptrofs.repr delta /\ bf = Full.
  Proof.
    intros le m t fld fty delta loc ofs bf HG Ht Hfo Hlv.
    pose proof Hlv as Hlv0.
    apply eval_lvalue_Efield_base in Hlv0 as (o0 & Hb0).
    apply eval_expr_Ederef_load in Hb0 as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    destruct (HG _ _ _ Ht Hlvb) as [-> ->].
    exact (eval_mario_field_lvalue_lp lp LOm t fld fty delta _ _ _ bm loc ofs bf Hlv Hlvb Hfo).
  Qed.

  Lemma store_keeps_act : forall m m' ch d vv,
      d + size_chunk ch <= 12 \/ 16 <= d ->
      Mem.store ch m bm d vv = Some m' ->
      action_sat not_tainted m bm -> action_sat not_tainted m' bm.
  Proof.
    intros m m' ch d vv Hd Hst Hs v Hld. apply Hs.
    rewrite <- Hld. symmetry. eapply Mem.load_store_other; [ exact Hst | right ].
    change (size_chunk Mint32) with 4. lia.
  Qed.

  Lemma init_store_sound : forall a1 a2 le m t le' m' out,
      init_store_ok a1 a2 = true -> initG le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Sassign a1 a2) t le' m' out ->
      initF m -> initF m'.
  Proof.
    intros a1 a2 le m t le' m' out Hok HG Hx (Hv & Hs & M).
    destruct (sassign_inv _ _ _ _ _ _ _ _ _ _ Hx)
      as (loc & ofs & bf & v2 & v & Hlv & He2 & Hcast & Hasg).
    destruct a1 as [ | | | | | | | | | | | base fld fty | | ]; try discriminate Hok.
    destruct base as [ | | | | g gty | | p sty | | | | | | | ]; try discriminate Hok.
    - (* a global struct field: gHudDisplay.{coins,wedges} *)
      destruct gty as [ | | | | | | | sid satt | ]; try discriminate Hok.
      cbn [init_store_ok] in Hok. apply andb_prop in Hok as [Hg Ham].
      destruct (access_mode fty) as [ch0 | | | ] eqn:Eam; try discriminate Ham.
      pose proof Hlv as Hlv0.
      apply eval_lvalue_Efield_base in Hlv0 as (o0 & Hb0).
      apply eval_expr_Evar_load in Hb0 as (loc' & ofs' & bf' & Hlvg & Hd).
      apply eval_lvalue_Evar_global_loc in Hlvg as [Hfs ->]; [ | apply PTree.gempty ].
      apply deref_loc_aggregate_eq in Hd as [-> ->]; [ | right; reflexivity ].
      cbn [typeof] in Hasg.
      destruct (assign_loc_store _ _ _ _ _ _ _ _ _ Eam Hasg) as (ch & d & vv & Hst).
      destruct (mwf_real_glob lp bm bc Ptrofs.zero SB D1 D7 g Hg loc' Hfs) as (Hne & Hpres).
      split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hst _ Hv) | ].
      split; [ | exact (Hpres _ _ _ _ _ M Hst) ].
      intros v' Hld. apply Hs. rewrite <- Hld. symmetry.
      eapply Mem.load_store_other; [ exact Hst | left; exact (not_eq_sym Hne) ].
    - (* a Mario field through a gMarioState temp *)
      destruct p as [ | | | | | tv pty | | | | | | | | ]; try discriminate Hok.
      cbn [init_store_ok] in Hok.
      apply andb_prop in Hok as [Hok Hkind].
      apply andb_prop in Hok as [Hok Esty].
      apply andb_prop in Hok as [Ht Epty].
      apply proj_sumbool_true in Esty. apply proj_sumbool_true in Epty. subst sty pty.
      remember (field_offset (prog_comp_env mario.prog) fld mario_state_members) as FO eqn:Hfo.
      destruct FO as [[delta [ | ]] | ]; try discriminate Hkind.
      destruct (access_mode fty) as [ch | | | ] eqn:Eam; try discriminate Hkind.
      symmetry in Hfo.
      destruct (init_mfield_lv le m tv fld fty delta _ _ _ HG Ht Hfo Hlv) as (-> & -> & ->).
      cbn [typeof] in Hasg.
      inv Hasg; [ | congruence ].
      match goal with
      | Ham : access_mode fty = By_value ?c, Hs0 : Mem.storev ?c _ _ _ = Some _ |- _ =>
          rewrite Eam in Ham; injection Ham as <-; pose proof Hs0 as Hsv; clear Hs0
      end.
      unfold ms_store_kind in Hkind.
      apply orb_true_iff in Hkind as [Hkind | Hpin2].
      apply orb_true_iff in Hkind as [Hkind | Hpin1].
      apply orb_true_iff in Hkind as [Hkind | Hroot].
      apply orb_true_iff in Hkind as [Hwin | Hact].
      + (* window *)
        pose proof (store_window_ok_range _ _ Hwin) as Hr.
        cbn [Mem.storev] in Hsv. rewrite Ptrofs.unsigned_repr in Hsv by lia.
        split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hsv _ Hv) | ].
        split; [ | exact (mwf_real_window lp bm bc Ptrofs.zero SB D1 D2 D3 D4 D5 D6
                            _ _ _ _ _ M Hwin Hsv) ].
        eapply store_keeps_act; [ | exact Hsv | exact Hs ].
        unfold store_window_ok in Hwin.
        repeat (apply andb_prop in Hwin as [Hwin ?]).
        match goal with H : ((_ <=? 12) || (16 <=? _))%bool = true |- _ =>
          apply orb_true_iff in H as [H | H]; [ left | right ]; lia end.
      + (* action = untainted constant *)
        apply andb_prop in Hact as [Hact Hrhs]. apply andb_prop in Hact as [Ed Ety].
        apply Z.eqb_eq in Ed. apply proj_sumbool_true in Ety. subst delta fty.
        cbv [access_mode tuint] in Eam. injection Eam as <-.
        destruct a2 as [ i [ | [ | | | ] [ | ] [ ] | | | | | | | ] | | | | | | | | | | | | | ];
          try discriminate Hrhs.
        apply eval_const_int in He2. subst v2.
        cbn [typeof] in Hcast. apply (sem_cast_int_uint i _ m v) in Hcast. subst v.

        cbn [Mem.storev] in Hsv. rewrite Ptrofs.unsigned_repr in Hsv by (vm_compute; split; discriminate).
        assert (Hnp : forall bb oo, Vint i <> Vptr bb oo) by (intros bb oo E; discriminate E).

        split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hsv _ Hv) | ].
        split; [ | exact (mwf_real_act_store lp bm bc Ptrofs.zero SB D1 D2 D3 D4 D5 D6
                            _ _ _ M Hnp Hsv) ].
        intros w Hld. rewrite (Mem.load_store_same _ _ _ _ _ _ Hsv) in Hld.
        cbn in Hld. injection Hld as <-.
        cbn [is_act_rhs] in Hrhs. unfold not_tainted.
        destruct (is_tainted i); [ discriminate Hrhs | reflexivity ].
      + (* chase root := &g[i], g outside non_safeb_syms *)
        apply andb_prop in Hroot as [Hroot Hrhs]. apply andb_prop in Hroot as [Hroot Ech].
        apply andb_prop in Hroot as [Hmem Hnmo].
        apply proj_sumbool_true in Ech. subst ch.
        apply negb_true_iff in Hnmo. apply Pos.eqb_neq in Hnmo.
        assert (Hr : 120 <= delta /\ delta + 4 <= 156) by (eapply chase_root_below_156; eassumption).
        cbn [Mem.storev] in Hsv.
        rewrite Ptrofs.unsigned_repr in Hsv
          by (assert (Ptrofs.max_unsigned = 4294967295) by (vm_compute; reflexivity); lia).
        unfold is_safe_rhs in Hrhs.
        destruct (arr_add_glob a2) as [[g i] | ] eqn:Ea; [ | discriminate Hrhs ].
        destruct (arr_add_glob_inv _ _ _ Ea) as (elt & n & att & ia & pt & pa & ->).
        destruct (eval_glob_arr_add _ _ _ _ _ _ _ _ _ _ _ He2) as (gb & o & Hfs & -> & _).
        assert (Hsafe : forall bb oo, v = Vptr bb oo -> SB bb).
        { intros bb oo Ev. subst v.
          destruct (sem_cast_ptr _ _ _ _ _ _ Hcast) as [E | E];
            [ injection E as <- _ | exfalso; exact (E bb oo eq_refl) ].
          right. exists g. split; [ left; apply negb_true_iff; exact Hrhs | exact Hfs ]. }
        split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hsv _ Hv) | ].
        split; [ | exact (mwf_real_root_store lp bm bc Ptrofs.zero SB D1 D2 D3 D4 D5 D6
                            _ _ _ _ _ Hmem Hnmo Hfo Hsafe M Hsv) ].
        eapply store_keeps_act; [ | exact Hsv | exact Hs ].
        right. lia.
      + (* controller := &gControllers[0] *)
        apply andb_prop in Hpin1 as [Hpin1 Hrhs]. apply andb_prop in Hpin1 as [Hpin1 Hpt].
        apply andb_prop in Hpin1 as [Ed Ech].
        apply Z.eqb_eq in Ed. apply proj_sumbool_true in Ech. subst delta ch.
        cbn [Mem.storev] in Hsv. rewrite Ptrofs.unsigned_repr in Hsv by (vm_compute; split; discriminate).
        unfold is_ctl_rhs in Hrhs.
        destruct (arr_add_glob a2) as [[g i] | ] eqn:Ea; [ | discriminate Hrhs ].
        apply andb_prop in Hrhs as [Eg Ei]. apply Pos.eqb_eq in Eg. subst g.
        destruct (arr_add_glob_inv _ _ _ Ea) as (elt & n & att & ia & pt & pa & ->).
        destruct (eval_glob_arr_add _ _ _ _ _ _ _ _ _ _ _ He2) as (gb & o & Hfs & -> & Ho).
        rewrite Hbc in Hfs. injection Hfs as <-. rewrite (Ho Ei) in Hcast.
        destruct fty as [ | | | | ft fa | | | | ]; try discriminate Hpt.
        cbn [typeof] in Hcast. apply sem_cast_ptr_ptr in Hcast. subst v.
        split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hsv _ Hv) | ].
        split; [ | exact (mwf_real_pin_store lp bm bc Ptrofs.zero SB D1 D2 D3 D4 D5 D6
                            _ _ _ _ M (or_introl (conj eq_refl eq_refl)) Hsv) ].
        eapply store_keeps_act; [ | exact Hsv | exact Hs ]. right. lia.
      + (* animList := &gMarioAnimsBuf *)
        apply andb_prop in Hpin2 as [Hpin2 Hrhs]. apply andb_prop in Hpin2 as [Hpin2 Hpt].
        apply andb_prop in Hpin2 as [Ed Ech].
        apply Z.eqb_eq in Ed. apply proj_sumbool_true in Ech. subst delta ch.
        cbn [Mem.storev] in Hsv. rewrite Ptrofs.unsigned_repr in Hsv by (vm_compute; split; discriminate).
        destruct a2 as [ | | | | | | | x pty' | | | | | | ]; try discriminate Hrhs.
        destruct x as [ | | | | g gty | | | | | | | | | ]; try discriminate Hrhs.
        cbn [is_anim_rhs] in Hrhs.
        destruct pty' as [ | | | | pt pa | | | | ]; try discriminate Hrhs.
        apply Pos.eqb_eq in Hrhs. subst g.
        destruct (eval_glob_addrof _ _ _ _ _ _ _ He2) as (ab & Hfs & ->).
        destruct fty as [ | | | | ft fa | | | | ]; try discriminate Hpt.
        cbn [typeof] in Hcast. apply sem_cast_ptr_ptr in Hcast. subst v.
        split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hsv _ Hv) | ].
        split; [ | exact (mwf_real_pin_store lp bm bc Ptrofs.zero SB D1 D2 D3 D4 D5 D6
                            _ _ _ _ M (or_intror (conj eq_refl (ex_intro _ ab (conj Hfs eq_refl)))) Hsv) ].
        eapply store_keeps_act; [ | exact Hsv | exact Hs ]. right. lia.
  Qed.

  Lemma init_call_sound : forall o a al le m t le' m' out,
      init_call_ok o a al = true -> initG le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall o a al) t le' m' out ->
      initF m -> initF m' /\ initG le'.
  Proof.
    intros o a al le m t le' m' out Hok HG Hx (Hv & Hs & M).
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres cc | | ]; try discriminate Hok.
    cbn [init_call_ok] in Hok. apply andb_prop in Hok as [Ef Ho].
    apply Pos.eqb_eq in Ef. subst fid.
    destruct (scall_evar_inv_opt _ _ _ _ _ _ _ _ _ _ _ _ Hx (PTree.gempty _ _) eq_refl)
      as (b & fd & tyargs & tyres & cc' & vargs & vres & Hfs & Hff & _ & _ & Hevf & -> & _).
    destruct (Hsf fd m vargs t m' vres Hevf (ex_intro _ b (conj Hfs Hff))
                (mwf_real_ctl lp bm bc Ptrofs.zero SB m M) M Hv Hs)
      as (Hv' & Hs' & M' & _).
    split; [ exact (conj Hv' (conj Hs' M')) | ].
    intros tt bb oo Ht Hle.
    destruct o as [id | ]; cbn [set_opttemp] in Hle; [ | exact (HG tt bb oo Ht Hle) ].
    destruct (Pos.eq_dec tt id) as [-> | Hne].
    - rewrite Ht in Ho. discriminate Ho.
    - rewrite PTree.gso in Hle by exact Hne. exact (HG tt bb oo Ht Hle).
  Qed.

  (* THE FUNCTION: one real call of init_mario_from_save_file keeps
     valid / untainted / MWF. *)
  Theorem init_mario_keeps : forall fd m t m' vres,
      eval_funcall function_entry2 (lp_ge lp) m fd nil t m' vres ->
      resolves_lp lp mario._init_mario_from_save_file fd ->
      initF m -> initF m'.
  Proof.
    intros fd m t m' vres Hev Hres Hf.
    assert (Efd : fd = Internal mario.f_init_mario_from_save_file)
      by (eapply resolves_pin_fd; [ exact LOm | exact init_pin | exact Hres ]).
    subst fd. inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars mario.f_init_mario_from_save_file) with (@nil (ident * type)) in Ha;
      inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      change (fn_params mario.f_init_mario_from_save_file) with (@nil (ident * type)) in Hb;
      cbn [bind_parameter_temps] in Hb; injection Hb as <- end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hfr : Mem.free_list _ _ = Some _ |- _ => rename Hfr into Hfree end.
    assert (HG0 : initG (create_undef_temps (fn_temps mario.f_init_mario_from_save_file))).
    { intros tt bb oo _ Hg. apply undef_temps_get in Hg. discriminate Hg. }
    destruct (cw_walk (lp_ge lp) empty_env initF initG init_set_ok init_store_ok init_call_ok
                init_set_sound init_store_sound init_call_sound
                _ _ _ _ _ _ _ _ Hbody eq_refl init_chk HG0 Hf) as [Hf' _].
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    inv Hfree. exact Hf'.
  Qed.
End InitWalk.

(* ====================================================================== *)
(* BOOT + THE REAL init_mario_from_save_file: the memory the game hands   *)
(* to its first Mario frame (in this model: the 12-TU init_mem, then one  *)
(* real call of init_mario_from_save_file) is valid at gMarioStates,      *)
(* untainted, and satisfies MWF with SafeB := SafeB_boot.  The only row   *)
(* consumed is the save-file star-count external (Hsf), a capstone row.   *)
(* ====================================================================== *)

Theorem boot_init_ok : forall lp (H12 : linked12 lp) m0 bm bc,
    Genv.init_mem lp = Some m0 ->
    Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm ->
    Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc ->
    call_pres_ext lp bm (fun m => ctl_a_clear m bm)
      (MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp))
      mario._save_file_get_total_star_count ->
    forall fd t m1 vres,
      eval_funcall function_entry2 (lp_ge lp) m0 fd nil t m1 vres ->
      resolves_lp lp mario._init_mario_from_save_file fd ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF_real lp bm bc Ptrofs.zero (SafeB_boot lp) m1.
Proof.
  intros lp H12 m0 bm bc Hinit Hbm Hbc Hsf fd t m1 vres Hev Hres.
  refine (init_mario_keeps lp H12 m0 Hinit bm bc Hbm Hbc Hsf fd m0 t m1 vres Hev Hres _).
  split; [ exact (Genv.find_symbol_not_fresh _ _ Hinit Hbm) | ].
  split; [ exact (boot_nontainted lp H12 m0 Hinit bm Hbm)
         | exact (boot_mwf lp H12 m0 Hinit bm bc Hbm Hbc) ].
Qed.
