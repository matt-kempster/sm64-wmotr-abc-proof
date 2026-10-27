(* ====================================================================== *)
(* BoxCheck (GOAL 2, chunk B-xz): the syntactic check that an outcome of a *)
(* walk leaves Mario's pos x / z inside find_floor's s16 box               *)
(* (FfBox.s16box) WHEN the entry had them there, and what it means.        *)
(*                                                                        *)
(* A cell passes when the outcome's value for it carries the box fact     *)
(* kX [v].  The walks record that fact on every argument x/z of a         *)
(* find_floor call that returned a surface (FloorExec.c_ff, proved from   *)
(* the real find_floor: FfBox.ff_hit_box), and the start facts give it    *)
(* to the entry's cells; joins keep a fact both sides carry.              *)
(*                                                                        *)
(* CONDITIONAL (design B'', 2026-10-26).  The fact's meaning is: in the     *)
(* box, or the ENTRY was not (xboxo: ~ ebox).  So one walk proves: entry  *)
(* in the box => exit in the box, with no premise: the start facts hold  *)
(* at every entry (mario_entry_box), and a caller that knows the entry's  *)
(* box (ebox) reads the exit's box off the conclusion.  The box is not    *)
(* claimed unconditionally because pole / ledge / cannon handlers can     *)
(* leave it over phantom walls (wall pushes are unbounded without a world *)
(* fact); the real OOB guard in execute_mario_action (floor == NULL:      *)
(* return) then stops the next frame's dispatch.                          *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib AST Integers Values Memory Globalenvs Ctypes Clight.
From SM64.Generated Require level_update.
From SM64.Proofs Require Import Interp.SymExec2.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight FfBox.
Import ListNotations.

Section BX.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variable kX : positive.

Definition box_cell (g : gst) (k : positive * Z * memory_chunk) : bool :=
  let '(r, o, ch) := k in
  match sload nbase R0 kv g r o ch with
  | Some a => existsb (fbeq (Fuser kX [a])) (g_pc g)
  | None => false
  end.

Definition box_ok (cells : list (positive * Z * memory_chunk)) (g : gst) : bool :=
  forallb (box_cell g) cells.
End BX.

(* the cells meet Pbo (a property of the cell's load) at a memory, through
   a symbolic env *)
Definition cells_box (Pbo : option val -> Prop) (m : mem) (E : senv)
    (cells : list (positive * Z * memory_chunk)) : Prop :=
  forall r o ch, In (r, o, ch) cells -> Pbo (Mem.load ch m (e_blk E r) (addr E r o)).

(* Mario's position x / z (his state block, region rM) *)
Definition mario_box_cells (rM : positive) : list (positive * Z * memory_chunk) :=
  [(rM, 60, Mfloat32); (rM, 68, Mfloat32)].

(* ---- the meaning: Mario's entry position in the box (ebox), and a cell
   in the box, or the entry was not (xboxo) ---- *)
Definition ebox (g : genv) (m0 : mem) : Prop :=
  forall b, Genv.find_symbol g level_update._gMarioStates = Some b ->
    forall z, z = 60 \/ z = 68 -> exists v, Mem.load Mfloat32 m0 b z = Some v /\ s16box v.

Definition xboxo (g : genv) (m0 : mem) (o : option val) : Prop :=
  match o with
  | Some v => s16box v \/ ~ ebox g m0
  | None => ~ ebox g m0
  end.

Lemma s16box_dec : forall v, s16box v \/ ~ s16box v.
Proof.
  intros v. unfold s16box. destruct (ycast v) eqn:Y;
    try (right; intros (X & E & _); discriminate E).
  destruct (Z_lt_dec (-8192) (Int.signed i)) as [A | A];
    [destruct (Z_lt_dec (Int.signed i) 8192) as [B | B] |].
  - left. exists i. split; [reflexivity | lia].
  - right. intros (X & E & R). injection E as <-. lia.
  - right. intros (X & E & R). injection E as <-. lia.
Qed.

(* every entry meets xboxo: in the box, or the entry is not all in it *)
Lemma xboxo_entry : forall (g : genv) (m0 : mem) (b : block) (z : Z), Genv.find_symbol g level_update._gMarioStates = Some b ->
  z = 60 \/ z = 68 -> xboxo g m0 (Mem.load Mfloat32 m0 b z).
Proof.
  intros g m0 b z Hs Hz. destruct (Mem.load Mfloat32 m0 b z) as [v|] eqn:L; cbn [xboxo].
  - destruct (s16box_dec v) as [B | NB]; [left; exact B | right].
    intros EB. destruct (EB b Hs z Hz) as (v' & L' & B'). rewrite L in L'. injection L' as <-.
    exact (NB B').
  - intros EB. destruct (EB b Hs z Hz) as (v' & L' & _). rewrite L in L'. discriminate L'.
Qed.

(* ... read through a walk's env: Mario's region is gMarioStates' block,
   at base 0 (env_ok's global table) *)
Lemma mario_entry_box : forall ge nbase R0 gtab kv m0 gp E rM,
  env_ok ge nbase R0 gtab kv m0 gp E -> gfind gtab level_update._gMarioStates = Some rM ->
  cells_box (xboxo ge m0) m0 E (mario_box_cells rM).
Proof.
  intros ge nbase R0 gtab kv m0 gp E rM EO Hg r o ch Hin.
  destruct EO as (_ & _ & _ & GT & _). destruct (GT _ _ Hg) as (_ & Hb & Hs).
  cbn [mario_box_cells In] in Hin.
  destruct Hin as [Hin | [Hin | []]]; injection Hin as <- <- <-; unfold addr; rewrite Hb, Ptrofs.unsigned_zero;
    apply (xboxo_entry _ _ _ _ Hs); [left | right]; reflexivity.
Qed.

(* ... and a caller that knows the entry's box reads the exit's box *)
Lemma xboxo_box : forall (g : genv) (m0 : mem) (o : option val), ebox g m0 -> xboxo g m0 o -> exists v, o = Some v /\ s16box v.
Proof.
  intros g m0 [v|] EB X; cbn [xboxo] in X.
  - destruct X as [B | N]; [exists v; split; [reflexivity | exact B] | contradiction].
  - contradiction.
Qed.

Section SOUND.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (E : senv) (m : mem) (g : gst) (kX : positive) (Pbo : option val -> Prop).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HUX : forall vs, uf kX vs -> exists o, vs = [o] /\ Pbo o.

Theorem box_sound : forall cells, box_ok nbase R0 kv kX cells g = true -> cells_box Pbo m E cells.
Proof.
  intros cells H r o ch Hin. unfold box_ok in H. rewrite forallb_forall in H.
  specialize (H _ Hin). unfold box_cell in H.
  destruct (sload nbase R0 kv g r o ch) as [a|] eqn:L; [| discriminate H].
  apply existsb_exists in H as (f & Hf & Hb). unfold fbeq in Hb.
  destruct (fact_eq (Fuser kX [a]) f) as [<- |]; [| discriminate Hb].
  pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
  pose proof (proj2 (PC _ Hf)) as U. cbn [fact_holds map] in U.
  destruct (HUX _ U) as (ov & Ev & Bv). injection Ev as Ev.
  rewrite (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                    E m g r o ch a MM L)).
  rewrite Ev. exact Bv.
Qed.
End SOUND.

(* ---- the start facts: the box fact on the entry's cells ---- *)
Definition box_facts (kX : positive) (cells : list (positive * Z * memory_chunk)) : list fact :=
  map (fun c => let '(r, o, ch) := c in Fuser kX [Sinit r o ch]) cells.

Lemma box_facts_nlt : forall kX cells n, (forall r o ch, In (r, o, ch) cells -> Plt r n) ->
  forall f, In f (box_facts kX cells) -> fact_nlt n f.
Proof.
  intros kX cells n H f Hf. unfold box_facts in Hf. apply in_map_iff in Hf as ([[r o] ch] & <- & Hin).
  cbn [fact_nlt]. constructor; [exact (H _ _ _ Hin) | constructor].
Qed.

Section START.
Variables (ge : genv) (R0 : list (positive * Z)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (E : senv) (kX : positive) (Pbo : option val -> Prop).
Hypothesis HUXi : forall o, Pbo o -> uf kX [o].

Lemma box_facts_holds : forall cells, cells_box Pbo m0 E cells ->
  forall f, In f (box_facts kX cells) -> fact_holds ge R0 m0 uf E f.
Proof.
  intros cells H f Hf. unfold box_facts in Hf. apply in_map_iff in Hf as ([[r o] ch] & <- & Hin).
  pose proof (H _ _ _ Hin) as B. unfold addr in B.
  cbn [fact_holds map den]. exact (HUXi _ B).
Qed.

(* a walk's start facts, with the box facts appended *)
Lemma box_start : forall pc cells n,
  (forall f, In f pc -> fact_nlt n f /\ fact_holds ge R0 m0 uf E f) ->
  (forall r o ch, In (r, o, ch) cells -> Plt r n) -> cells_box Pbo m0 E cells ->
  forall f, In f (pc ++ box_facts kX cells) -> fact_nlt n f /\ fact_holds ge R0 m0 uf E f.
Proof.
  intros pc cells n P Hn B f Hf. apply in_app_or in Hf as [Hf | Hf]; [exact (P f Hf) |].
  split; [exact (box_facts_nlt kX cells n Hn f Hf) | exact (box_facts_holds cells B f Hf)].
Qed.
End START.
