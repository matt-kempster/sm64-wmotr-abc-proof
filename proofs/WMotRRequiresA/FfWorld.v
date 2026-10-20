(* ====================================================================== *)
(* FfWorld (GOAL 2): what the act_freefall walk needs from the memory at   *)
(* its call, as a fact the frame carries (`ffw`, a conjunct of FrameSplit's *)
(* `fworld`).                                                              *)
(*                                                                         *)
(* The walk (FfRun.ff_move) runs the real act_freefall over ten regions:   *)
(* Mario's state block, his object, find_floor's three statics, the        *)
(* animation list gMarioAnimsBuf, its DMA buffer, and memory.c's three DMA  *)
(* globals.  Everything else it reads is "world": the collision partition, *)
(* m->floor, m->area and gSineTable.  `ffw` says, of a memory:             *)
(*   - it is pointer-closed: a pointer loaded from a valid block points to  *)
(*     a valid block (true of every memory a CompCert run produces);        *)
(*   - Mario's object, the animation list (&gMarioAnimsBuf, as             *)
(*     init_mario_from_save_file sets it) and its buffer are where the     *)
(*     walk's regions say, and the object and the buffer are blocks of     *)
(*     their own (a gObjectPool slot; a main_pool allocation);              *)
(*   - the collision partition is well-formed lists of WMotR surfaces, off *)
(*     the regions (FloorExec.Wff), and every floor height on it is a WMotR *)
(*     floor (AirMatch.floor_data, TRUST 0.8(d));                          *)
(*   - m->floor and m->area point at world objects off the regions;         *)
(*   - m->input has neither INPUT_A_PRESSED nor INPUT_A_DOWN (no-A);        *)
(*   - Mario's floorHeight is a floor refresh of his y                      *)
(*     (HeightMoveCatalog.FloorRefreshOK): -11000, or a WMotR floor at most *)
(*     STEP_UP above y.                                                     *)
(* Offsets and sizes are the generated AST's (pinned in FfRow on the link). *)
(* ffw survives the frame's two stores into Mario's object (ffw_keep).      *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight Globalenvs.
From SM64.Generated Require mario surface_collision memory.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight FloorExec AirMatch AirStart.
Import ListNotations.

(* the MarioState fields and struct sizes the walk reads (generated AST) *)
Definition FFW_OBJ : Z := 136.      (* marioObj *)
Definition FFW_FLOOR : Z := 104.    (* floor *)
Definition FFW_AREA : Z := 144.     (* area *)
Definition FFW_ANIM : Z := 160.     (* animList *)
Definition SZ_OBJECT : Z := 608.
Definition SZ_SURFACE : Z := 48.
Definition SZ_AREA : Z := 60.

(* pointer-closed *)
Definition lclosed (m : mem) : Prop :=
  forall ch b z b' o', Plt b (Mem.nextblock m) ->
    Mem.load ch m b z = Some (Vptr b' o') -> Plt b' (Mem.nextblock m).

(* the walk's ten regions as pointers, in FfRun.R0F's order *)
Definition ff_rl (bm bo : block) (oo : ptrofs) (bfi bmiss bcalls ab bt biom bmq brm : block)
  : list (option val) :=
  map Some [Vptr bm Ptrofs.zero; Vptr bo oo; Vptr bfi Ptrofs.zero; Vptr bmiss Ptrofs.zero;
            Vptr bcalls Ptrofs.zero; Vptr ab Ptrofs.zero; Vptr bt Ptrofs.zero;
            Vptr biom Ptrofs.zero; Vptr bmq Ptrofs.zero; Vptr brm Ptrofs.zero].

(* a world object: a valid block that is none of the regions *)
Definition wblk (m : mem) (rl : list (option val)) (v : val) (n : Z) : Prop :=
  exists b o, v = Vptr b o /\ Plt b (Mem.nextblock m) /\ 0 <= n
    /\ Ptrofs.unsigned o + n <= Ptrofs.modulus /\ ~ rblk rl b.

Section FFW.
Variable G : genv.
Variable bm : block.

Definition ffw (m : mem) : Prop :=
  lclosed m
  /\ Ple (Genv.genv_next G) (Mem.nextblock m)
  /\ (exists bfi bmiss bcalls bsin ab biom bmq brm bo oo bt ot fl ar inp,
      Genv.find_symbol G surface_collision._gFindFloorIncludeSurfaceIntangible = Some bfi
      /\ Genv.find_symbol G surface_collision._gNumFindFloorMisses = Some bmiss
      /\ Genv.find_symbol G surface_collision._gNumCalls = Some bcalls
      /\ Genv.find_symbol G mario._gSineTable = Some bsin
      /\ Genv.find_symbol G mario._gMarioAnimsBuf = Some ab
      /\ Genv.find_symbol G memory._gDmaIoMesg = Some biom
      /\ Genv.find_symbol G memory._gDmaMesgQueue = Some bmq
      /\ Genv.find_symbol G memory._gMainReceivedMesg = Some brm
      (* Mario's object; the animation list and its DMA buffer *)
      /\ Mem.load Mint32 m bm FFW_OBJ = Some (Vptr bo oo)
      /\ Ptrofs.unsigned oo + SZ_OBJECT <= Ptrofs.modulus
      /\ Mem.load Mint32 m bm FFW_ANIM = Some (Vptr ab Ptrofs.zero)
      /\ Mem.load Mint32 m ab 8 = Some (Vptr bt ot) /\ Ptrofs.unsigned ot + 24 <= Ptrofs.modulus
      (* the object and the buffer are blocks of their own *)
      /\ bo <> bm /\ bt <> bm /\ bt <> bo
      /\ (forall b, In b [bfi; bmiss; bcalls; bsin; ab; biom; bmq; brm] -> b <> bo /\ b <> bt)
      (* the collision partition *)
      /\ Wff G m (gpv m) SZ_SURFACE (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm)
      (* m->floor, m->area *)
      /\ Mem.load Mint32 m bm FFW_FLOOR = Some fl
      /\ wblk m (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm) fl SZ_SURFACE
      /\ Mem.load Mint32 m bm FFW_AREA = Some ar
      /\ wblk m (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm) ar SZ_AREA
      (* m->input: INPUT_A_PRESSED | INPUT_A_DOWN clear *)
      /\ Mem.load Mint16unsigned m bm 2 = Some (Vint inp) /\ Int.and inp (Int.repr 130) = Int.zero)
  /\ floor_data G m
  /\ (forall y fh, Mem.load Mfloat32 m bm OFS_POSY = Some (Vsingle y) ->
        Mem.load Mfloat32 m bm OFS_FLOORH = Some (Vsingle fh) ->
        FloorRefreshOK wmotr_floor (R2 y) (R2 fh)).

(* ---- transfer: a memory that differs from m only inside Mario's object ---- *)

Lemma rl_obj : forall bo oo bfi bmiss bcalls ab bt biom bmq brm,
  rblk (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm) bo.
Proof. intros. exists oo. cbn. auto 10. Qed.

Lemma lclosed_store : forall m m' ch b z v,
  Mem.store ch m b z v = Some m' -> lclosed m ->
  (forall b' o', v = Vptr b' o' -> ch = Mint16signed \/ Plt b' (Mem.nextblock m)) ->
  lclosed m'.
Proof.
  intros m m' ch b z v Hst HC Hv ch' b1 z1 b' o' Hp Hl.
  rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst) in *.
  destruct (Mem.load_pointer_store _ _ _ _ _ _ _ _ _ _ _ Hst Hl)
    as [(-> & Hcp & _ & _) | Hdis].
  - destruct (Hv b' o' eq_refl) as [-> | Hpl]; [| exact Hpl].
    destruct ch'; cbn in Hcp; contradiction.
  - apply (HC ch' b1 z1 b' o' Hp). rewrite <- (Mem.load_store_other _ _ _ _ _ _ Hst); [exact Hl |].
    destruct Hdis as [Hd | Hd]; [left; congruence | right; exact Hd].
Qed.

Section KEEP.
Variables (m m' : mem) (bo0 : block).
Hypothesis Hnb : Mem.nextblock m' = Mem.nextblock m.
Hypothesis Hperm : forall b ofs k p, Mem.perm m b ofs k p -> Mem.perm m' b ofs k p.
Hypothesis Hld : forall ch b z, b <> bo0 -> Mem.load ch m' b z = Mem.load ch m b z.

Lemma gpv_same : forall b, gpv m' b = gpv m b.
Proof. intros b. unfold gpv. rewrite Hnb. reflexivity. Qed.

Lemma wf_fwd : forall (A : block -> Prop) hd, (forall b, ~ A b -> b <> bo0) ->
  wf_list m A hd -> wf_list m' A hd.
Proof.
  intros A hd HA W. induction W as [| bn on nx Hv Hav Hl W IH]; [constructor |].
  apply wf_cons with nx; [unfold Mem.valid_block; rewrite Hnb; exact Hv | exact Hav | | exact IH].
  cbn [Mem.loadv] in *. rewrite (Hld _ _ _ (HA _ Hav)). exact Hl.
Qed.

Lemma part_back : forall rl hd, (forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
    ~ rblk rl bp) -> rblk rl bo0 ->
  part_head G m' hd -> part_head G m hd.
Proof.
  intros rl hd Hp Ho (id & bp & o & Hin & Hs & Hl). exists id, bp, o. split; [exact Hin |]. split; [exact Hs |].
  cbn [Mem.loadv] in *. rewrite Hld in Hl; [exact Hl |]. intros ->. exact (Hp _ _ Hin Hs Ho).
Qed.

Lemma floor_back : forall rl hd, (forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
    ~ rblk rl bp) -> rblk rl bo0 ->
  floor_head G m' hd -> floor_head G m hd.
Proof.
  intros rl hd Hp Ho (id & bp & z & x & Hin & Hs & Hz & Hx & Hl). exists id, bp, z, x.
  split; [exact Hin |]. split; [exact Hs |]. split; [exact Hz |]. split; [exact Hx |].
  cbn [Mem.loadv] in *. rewrite Hld in Hl; [exact Hl |]. intros ->. exact (Hp _ _ Hin Hs Ho).
Qed.

Lemma Wff_keep : forall rl, rblk rl bo0 -> Wff G m (gpv m) SZ_SURFACE rl -> Wff G m' (gpv m') SZ_SURFACE rl.
Proof.
  intros rl Ho (W1 & W2 & W3 & W4 & W5 & W6 & W7).
  assert (Hp : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp -> ~ rblk rl bp)
    by (intros id bp Hi Hs; exact (proj1 (proj2 (W2 id bp Hi Hs)))).
  assert (HA : forall b, ~ (is_static G b \/ rblk rl b) -> b <> bo0)
    by (intros b Hb ->; apply Hb; right; exact Ho).
  assert (OL : forall hd s, part_head G m' hd -> on_list m' hd s -> part_head G m hd /\ on_list m hd s).
  { intros hd s Hh Ho'. pose proof (part_back rl hd Hp Ho Hh) as Hh0. split; [exact Hh0 |].
    apply (ol_transfer m _ hd (W3 hd Hh0) m' s); [| exact Ho'].
    intros b z Hb. exact (Hld _ _ _ (HA b Hb)). }
  split; [| split; [| split; [| split; [| split; [| split]]]]].
  - intros id sz Hi. destruct (W1 id sz Hi) as (b & Hs & Hr). exists b. split; [exact Hs |].
    intros ofs Hofs. exact (Hperm _ _ _ _ (Hr ofs Hofs)).
  - intros id bp Hi Hs. rewrite Hnb. exact (W2 id bp Hi Hs).
  - intros hd Hh. exact (wf_fwd _ hd HA (W3 hd (part_back rl hd Hp Ho Hh))).
  - intros hd s Hh Ho'. destruct (OL hd s Hh Ho') as (Hh0 & Ho0).
    destruct (W4 hd s Hh0 Ho0) as (b & o & -> & Hpl & Hsz & Hr & Hg).
    exists b, o. rewrite Hnb, gpv_same. auto 10.
  - intros hd b o Hh Ho'. destruct (OL hd _ Hh Ho') as (Hh0 & Ho0).
    destruct (W5 hd b o Hh0 Ho0) as (t & Hl & Hin). exists t. split; [| exact Hin].
    rewrite Hld; [exact Hl |]. intros ->.
    destruct (W4 hd _ Hh0 Ho0) as (b' & o' & E & _ & _ & Hr & _). injection E as <- _. exact (Hr Ho).
  - intros hd b o Hh Ho'. destruct (OL hd _ Hh Ho') as (Hh0 & Ho0). exact (W6 hd b o Hh0 Ho0).
  - exact W7.
Qed.

Lemma floor_data_keep : forall rl, rblk rl bo0 -> Wff G m (gpv m) SZ_SURFACE rl ->
  floor_data G m -> floor_data G m'.
Proof.
  intros rl Ho (W1 & W2 & W3 & W4 & _) FD h (hd & s & xv & zv & Hh & Hol & Hhit).
  assert (Hp : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp -> ~ rblk rl bp)
    by (intros id bp Hi Hs; exact (proj1 (proj2 (W2 id bp Hi Hs)))).
  pose proof (floor_back rl hd Hp Ho Hh) as Hh0.
  assert (Hol0 : on_list m hd s).
  { apply (ol_transfer m _ hd (W3 hd (floor_head_part _ _ _ Hh0)) m' s); [| exact Hol].
    intros b z Hb. apply Hld. intros ->. apply Hb. right. exact Ho. }
  destruct (W4 hd s (floor_head_part _ _ _ Hh0) Hol0) as (b & o & -> & _ & _ & Hr & _).
  apply FD. exists hd, (Vptr b o), xv, zv. split; [exact Hh0 |]. split; [exact Hol0 |].
  apply (hit_transfer m' m b o xv zv h); [| exact Hhit].
  intros ch z. apply Hld. intros ->. exact (Hr Ho).
Qed.

Lemma wblk_keep : forall rl v n, wblk m rl v n -> wblk m' rl v n.
Proof. intros rl v n (b & o & -> & H). exists b, o. rewrite Hnb. auto. Qed.

(* bo0 is Mario's object: then ffw survives *)
Theorem ffw_keep : forall oo0,
  Mem.load Mint32 m bm FFW_OBJ = Some (Vptr bo0 oo0) -> bo0 <> bm ->
  (forall ab, Genv.find_symbol G mario._gMarioAnimsBuf = Some ab -> ab <> bo0) ->
  lclosed m' -> ffw m -> ffw m'.
Proof.
  intros oo0 Hmo Hne Hab HC' (_ & Hgn & EX & FD & FRO).
  destruct EX as (bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & bo & oo & bt & ot & fl & ar & inp &
                  S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                  W & Lf & Wf & Lar & War & Li & Ai).
  rewrite Hmo in Lo. injection Lo as <- <-.
  assert (Ho : rblk (ff_rl bm bo0 oo0 bfi bmiss bcalls ab bt biom bmq brm) bo0) by apply rl_obj.
  pose proof (Hab ab S5) as Hab0.
  split; [exact HC' |]. split; [rewrite Hnb; exact Hgn |].
  split; [| split].
  - exists bfi, bmiss, bcalls, bsin, ab, biom, bmq, brm, bo0, oo0, bt, ot, fl, ar, inp.
    rewrite !Hld by congruence.
    repeat (split; [assumption |]).
    split; [exact (Wff_keep _ Ho W) |].
    split; [exact Lf |]. split; [exact (wblk_keep _ _ _ Wf) |].
    split; [exact Lar |]. split; [exact (wblk_keep _ _ _ War) |].
    split; [exact Li | exact Ai].
  - exact (floor_data_keep _ Ho W FD).
  - intros y fh Hy Hf. rewrite Hld in Hy, Hf by congruence. exact (FRO y fh Hy Hf).
Qed.
End KEEP.
End FFW.
