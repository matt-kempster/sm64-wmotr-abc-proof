(* ====================================================================== *)
(* AnimWorld (GOAL 2): the animation state the frame world carries         *)
(* (2026-10-23), so the top-of-pole walks read Mario's REAL handstand data *)
(* instead of a phantom buffer.                                            *)
(*                                                                        *)
(* The game's animation list gMarioAnimsBuf (game_init.c:627,             *)
(* setup_dma_table_list, memory.c) holds                                  *)
(*   dmaTable    -> a copy of gMarioAnims' header (count; srcAddr =        *)
(*                  &gMarioAnims; entries (offset, size)), DMA'd at boot;  *)
(*   currentAddr  = the gMarioAnims address last DMA'd (NULL at boot);    *)
(*   bufTarget   -> the 0x4000-byte buffer the animation is DMA'd into.   *)
(* load_patchable_table (memory.c:567) is the only writer of currentAddr  *)
(* and of the buffer, and it writes both together: so the buffer always   *)
(* holds the animation currentAddr names (the DMA copies the ROM bytes,   *)
(* OsDmaFloor.pi_dma_anim_spec, TRUST 0.8(f)).                            *)
(*                                                                        *)
(* anim_w states:                                                          *)
(*   - ALWAYS: the table (count 209, srcAddr, the pole animations'        *)
(*     entries), gMarioAnims' cells the walks read (AnimData.ga_cells),   *)
(*     the buffer's range / alignment / permissions, and that the table   *)
(*     and the buffer are blocks of their own (not a global's, not Mario's *)
(*     object's; main_pool_alloc'd in the game);                           *)
(*   - in HOLDING_POLE / CLIMBING_POLE / TOP_OF_POLE_TRANSITION /          *)
(*     TOP_OF_POLE: the animation state, either                           *)
(*       no handstand animation is set and currentAddr names none, or     *)
(*       handstand animation k (9, 11, 12) is loaded: currentAddr names   *)
(*       it, animID = k, curAnim = the buffer, no acceleration, the frame *)
(*       in [-1, loopEnd_k], and the buffer holds k's relocated header,   *)
(*       index table and y samples.                                        *)
(* The grabs are not in that list: interact_pole enters them from any     *)
(* airborne state, and both grabs set their own animation before they    *)
(* switch to HOLDING_POLE (the grab walks prove the state then).          *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool Lia.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Clight.
From SM64.Generated Require mario game_init graph_node level_update platform_displacement.
From SM64.Proofs.WMotRRequiresA Require Import AnimData FloorList FloorExec FfWorld.
From SM64.Proofs.WMotRRequiresA Require RenderAnim.
Import ListNotations.
Local Open Scope Z_scope.

Definition TABSZ : Z := 8 + 8 * ANIM_COUNT.        (* the DMA table: 1680 bytes *)
Definition BUFSZ : Z := 16384.                     (* main_pool_alloc(0x4000) *)

(* the pole actions after the grab *)
Definition anim_acts : list Z := [135267136; 1049411; 1049412; 1049413].

(* the handstand animations' offsets in gMarioAnims, and their loopEnd *)
Definition hs_off (k : Z) : Z :=
  if Z.eqb k 9 then 27632 else if Z.eqb k 11 then 33780 else 33804.
Definition hs_le (k : Z) : Z := if Z.eqb k 9 then 52 else 17.
Definition hs_offs : list Z := map hs_off hs_ids.
Definition buf_cells (k : Z) : list (Z * memory_chunk * bcv) :=
  if Z.eqb k 9 then buf_cells_9 else if Z.eqb k 11 then buf_cells_11 else buf_cells_12.

Definition bval (bt : block) (ot : ptrofs) (v : bcv) : val :=
  match v with
  | BI z => Vint (Int.repr z)
  | BP r => Vptr bt (Ptrofs.add ot (Ptrofs.repr r))
  end.

Section AW.
Variable ge : genv.
Variable bm : block.

(* the DMA table: count, srcAddr, the pole animations' entries *)
Definition tab_ok (m : mem) (btab : block) (otab : ptrofs) (bga : block) : Prop :=
  Mem.load Mint32 m btab (Ptrofs.unsigned otab) = Some (Vint (Int.repr ANIM_COUNT))
  /\ Mem.load Mint32 m btab (Ptrofs.unsigned otab + 4) = Some (Vptr bga Ptrofs.zero)
  /\ forall j o s, In (j, o, s) anim_ent ->
       Mem.load Mint32 m btab (Ptrofs.unsigned otab + 8 + 8 * j) = Some (Vint (Int.repr o))
       /\ Mem.load Mint32 m btab (Ptrofs.unsigned otab + 12 + 8 * j) = Some (Vint (Int.repr s)).

(* gMarioAnims: the cells the walks read, readable *)
Definition ga_ok (m : mem) (bga : block) : Prop :=
  (forall o ch z, In (o, ch, z) ga_cells -> Mem.load ch m bga o = Some (Vint (Int.repr z)))
  /\ Mem.range_perm m bga 0 GA_SIZE Cur Readable.

(* the DMA table's block is off the surface partition: no list node and no
   surface lives in it (in the game they are separate main_pool_alloc
   allocations).  Together with FfWorld.ffw's world fact this is the world
   fact over the regions and the table, which the pole walks' floor and
   ceiling contracts check *)
Definition tab_apart (m : mem) (btab : block) : Prop :=
  forall hd, part_head ge m hd ->
    wf_list m (fun b => b = btab) hd /\ forall b o, on_list m hd (Vptr b o) -> b <> btab.

(* the buffer holds animation k's cells *)
Definition buf_ok (m : mem) (bt : block) (ot : ptrofs) (k : Z) : Prop :=
  forall rel ch v, In (rel, ch, v) (buf_cells k) ->
    Mem.load ch m bt (Ptrofs.unsigned ot + rel) = Some (bval bt ot v).

(* handstand animation k is loaded *)
Definition loaded (m : mem) (ab bga bt : block) (ot : ptrofs) (mb : block) (mo : ptrofs) (k : Z) : Prop :=
  Mem.load Mint32 m ab 4 = Some (Vptr bga (Ptrofs.repr (hs_off k)))
  /\ Mem.load Mint16signed m mb (Ptrofs.unsigned mo + 56) = Some (Vint (Int.repr k))
  /\ Mem.load Mint32 m mb (Ptrofs.unsigned mo + 60) = Some (Vptr bt ot)
  /\ Mem.load Mint32 m mb (Ptrofs.unsigned mo + 72) = Some (Vint Int.zero)
  /\ (exists f, -1 <= f <= hs_le k
        /\ Mem.load Mint16signed m mb (Ptrofs.unsigned mo + 64) = Some (Vint (Int.repr f)))
  /\ buf_ok m bt ot k.

(* no handstand animation: animID is none of them, and currentAddr is
   NULL or names no handstand animation *)
Definition nstate (m : mem) (ab bga : block) (mb : block) (mo : ptrofs) : Prop :=
  (exists i, Mem.load Mint16signed m mb (Ptrofs.unsigned mo + 56) = Some (Vint i)
             /\ ~ In (Int.signed i) hs_ids)
  /\ (Mem.load Mint32 m ab 4 = Some (Vint Int.zero)
      \/ exists o, Mem.load Mint32 m ab 4 = Some (Vptr bga o)
           /\ Ptrofs.unsigned o <= GA_SIZE /\ ~ In (Ptrofs.unsigned o) hs_offs).

Definition anim_st (m : mem) (ab bga bt : block) (ot : ptrofs) (mb : block) (mo : ptrofs) : Prop :=
  nstate m ab bga mb mo \/ exists k, In k hs_ids /\ loaded m ab bga bt ot mb mo k.

(* the six render globals (rendering_graph_node.c's gCurrAnimType / Frame /
   Enabled / Attribute / Data / TranslationMultiplier, which the real
   geo_set_animation_globals writes for every drawn object) are blocks
   apart from Mario's object and off the surface partition (2026-10-23, for
   the render flank's Phi carry, RenderKeep).  In the game they are
   statically allocated globals, while Mario's object is a gObjectPool slot
   and the partition's nodes and surfaces are main_pool_alloc'd.  FOUND
   (phantom forall): without it a frame-world memory could keep a partition
   node, or Mario's animation cells, in one of those globals' blocks, and
   one real render call rewrote them.  Since 2026-10-23 the list also
   names platform_displacement.c's D_8032FEC0, the one global the real
   apply_mario_platform_displacement writes (PlatformKeep): together, the
   flanks' globals. *)
Definition flank_gvars : list ident :=
  RenderAnim.render_gvars ++ [platform_displacement._D_8032FEC0].

Definition rg_apart (m : mem) (mb : block) : Prop :=
  forall id b, In id flank_gvars -> Genv.find_symbol ge id = Some b ->
    b <> mb /\ tab_apart m b.

(* what holds in every action: the list, the table, gMarioAnims' cells,
   the buffer's placement and the blocks apart *)
Definition anim_base (m : mem) (ab bga bauc btab : block) (otab : ptrofs) (bt : block) (ot : ptrofs)
    (mb : block) (mo : ptrofs) : Prop :=
  Genv.find_symbol ge mario._gMarioAnimsBuf = Some ab
  /\ Genv.find_symbol ge game_init._gMarioAnims = Some bga
  /\ Genv.find_symbol ge graph_node._gAreaUpdateCounter = Some bauc
  /\ Mem.load Mint32 m ab 0 = Some (Vptr btab otab)
  /\ Mem.load Mint32 m ab 8 = Some (Vptr bt ot)
  /\ Mem.load Mint32 m bm 136 = Some (Vptr mb mo)
  /\ (forall id b, Genv.find_symbol ge id = Some b -> b <> btab /\ b <> bt)
  /\ btab <> bt /\ btab <> mb /\ bt <> mb /\ mb <> bga /\ (mb <> bauc /\ rg_apart m mb)
  /\ Ptrofs.unsigned otab + TABSZ <= Ptrofs.modulus
  /\ Ptrofs.unsigned ot + BUFSZ < Ptrofs.modulus /\ Z.modulo (Ptrofs.unsigned ot) 4 = 0
  /\ Mem.range_perm m bt (Ptrofs.unsigned ot) (Ptrofs.unsigned ot + BUFSZ) Cur Readable
  /\ tab_ok m btab otab bga /\ ga_ok m bga /\ tab_apart m btab
  (* m->area (144) and m->controller (156) are not the table's block *)
  /\ (forall off b o, (off = 144 \/ off = 156) -> Mem.load Mint32 m bm off = Some (Vptr b o) -> b <> btab)
  /\ Genv.find_symbol ge level_update._gMarioStates = Some bm.

Definition anim_w (m : mem) : Prop :=
  exists ab bga bauc btab otab bt ot mb mo,
    anim_base m ab bga bauc btab otab bt ot mb mo
    /\ (forall a, Mem.load Mint32 m bm 12 = Some (Vint a) -> In (Int.unsigned a) anim_acts ->
          anim_st m ab bga bt ot mb mo).

(* ---- keeping it ---- *)

(* outside the pole actions it is the base *)
Lemma anim_w_other : forall m a ab bga bauc btab otab bt ot mb mo,
  anim_base m ab bga bauc btab otab bt ot mb mo ->
  Mem.load Mint32 m bm 12 = Some (Vint a) -> ~ In (Int.unsigned a) anim_acts -> anim_w m.
Proof.
  intros m a ab bga bauc btab otab bt ot mb mo B La N.
  exists ab, bga, bauc, btab, otab, bt, ot, mb, mo. split; [exact B |].
  intros a' La' I. rewrite La in La'. injection La' as <-. contradiction.
Qed.

(* ---- the world fact over more blocks ---- *)
Lemma Wff_mono : forall m gp sz vs vs', (forall b, rblk vs' b -> rblk vs b) ->
  Wff ge m gp sz vs -> Wff ge m gp sz vs'.
Proof.
  intros m gp sz vs vs' Hr (W1 & W2 & W3 & W4 & W5 & W6 & W7).
  refine (conj W1 (conj _ (conj _ (conj _ (conj W5 (conj W6 W7)))))).
  - intros id bp Hin Hs. destruct (W2 id bp Hin Hs) as (A & B & C). split; [exact A |].
    split; [intros H; exact (B (Hr _ H)) | exact C].
  - intros hd Hh. apply (wf_list_mono m (fun b => is_static ge b \/ rblk vs b) _ hd); [| exact (W3 hd Hh)].
    intros b [A | A]; [left; exact A | right; exact (Hr _ A)].
  - intros hd s' Hh Ho. destruct (W4 hd s' Hh Ho) as (b & o & E1 & A & B & C & D).
    exists b, o. repeat split; try assumption. intros H; exact (C (Hr _ H)).
Qed.

Lemma rblk_app : forall vs b o b', rblk (vs ++ [Some (Vptr b o)]) b' -> rblk vs b' \/ b' = b.
Proof.
  intros vs b o b' (o' & Hin). apply in_app_or in Hin as [Hin | [Hin | []]].
  - left. exists o'. exact Hin.
  - right. injection Hin as <- _. reflexivity.
Qed.

(* the frame's world fact, extended by the table's block *)
Lemma Wff_tab : forall m gp sz vs btab otab,
  (forall id b, Genv.find_symbol ge id = Some b -> b <> btab) ->
  tab_apart m btab -> Wff ge m gp sz vs -> Wff ge m gp sz (vs ++ [Some (Vptr btab otab)]).
Proof.
  intros m gp sz vs btab otab Sy TA (W1 & W2 & W3 & W4 & W5 & W6 & W7).
  refine (conj W1 (conj _ (conj _ (conj _ (conj W5 (conj W6 W7)))))).
  - intros id bp Hin Hs. destruct (W2 id bp Hin Hs) as (A & B & C). split; [exact A |].
    split; [| exact C]. intros H. destruct (rblk_app _ _ _ _ H) as [H' | ->];
      [exact (B H') | exact (Sy id btab Hs eq_refl)].
  - intros hd Hh. destruct (TA hd Hh) as (T1 & _).
    apply (wf_list_mono m (fun b => (is_static ge b \/ rblk vs b) \/ b = btab)).
    + intros b [A | A]; [left; left; exact A |].
      destruct (rblk_app _ _ _ _ A) as [A' | A']; [left; right; exact A' | right; exact A'].
    + exact (wf_list_or m _ _ hd (W3 hd Hh) T1).
  - intros hd s' Hh Ho. destruct (W4 hd s' Hh Ho) as (b & o & E1 & A & B & C & D).
    exists b, o. split; [exact E1 |]. split; [exact A |]. split; [exact B |]. split; [| exact D].
    intros H. destruct (rblk_app _ _ _ _ H) as [H' | E2]; [exact (C H') |].
    subst s' b. exact (proj2 (TA hd Hh) btab o Ho eq_refl).
Qed.

(* ... by any block off the partition that is not a partition array's *)
Lemma Wff_blk : forall m gp sz vs bx ox,
  (forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp -> bp <> bx) ->
  tab_apart m bx -> Wff ge m gp sz vs -> Wff ge m gp sz (vs ++ [Some (Vptr bx ox)]).
Proof.
  intros m gp sz vs bx ox Sy TA (W1 & W2 & W3 & W4 & W5 & W6 & W7).
  refine (conj W1 (conj _ (conj _ (conj _ (conj W5 (conj W6 W7)))))).
  - intros id bp Hin Hs. destruct (W2 id bp Hin Hs) as (A & B & C). split; [exact A |].
    split; [| exact C]. intros H. destruct (rblk_app _ _ _ _ H) as [H' | ->];
      [exact (B H') | exact (Sy id bx Hin Hs eq_refl)].
  - intros hd Hh. destruct (TA hd Hh) as (T1 & _).
    apply (wf_list_mono m (fun b => (is_static ge b \/ rblk vs b) \/ b = bx)).
    + intros b [A | A]; [left; left; exact A |].
      destruct (rblk_app _ _ _ _ A) as [A' | A']; [left; right; exact A' | right; exact A'].
    + exact (wf_list_or m _ _ hd (W3 hd Hh) T1).
  - intros hd s' Hh Ho. destruct (W4 hd s' Hh Ho) as (b & o & E1 & A & B & C & D).
    exists b, o. split; [exact E1 |]. split; [exact A |]. split; [exact B |]. split; [| exact D].
    intros H. destruct (rblk_app _ _ _ _ H) as [H' | E2]; [exact (C H') |].
    subst s' b. exact (proj2 (TA hd Hh) bx o Ho eq_refl).
Qed.

Lemma tab_of_Wff : forall m gp sz vs btab otab,
  Wff ge m gp sz (vs ++ [Some (Vptr btab otab)]) -> tab_apart m btab.
Proof.
  intros m gp sz vs btab otab (W1 & W2 & W3 & W4 & W5 & W6 & W7) hd Hh. split.
  - apply (wf_list_mono m (fun b => is_static ge b \/ rblk (vs ++ [Some (Vptr btab otab)]) b) _ hd);
      [| exact (W3 hd Hh)].
    intros b ->. right. exists otab. apply in_or_app. right. left. reflexivity.
  - intros b o Ho Eb. subst b. destruct (W4 hd _ Hh Ho) as (b' & o' & E1 & _ & _ & C & _).
    injection E1 as <- <-. apply C. exists otab. apply in_or_app. right. left. reflexivity.
Qed.

(* design B (2026-10-25): a global's block is off every partition list,
   since Wff's lists are dynamic blocks (FloorExec.dyn_list) *)
Lemma tab_apart_global : forall m gp sz vs bx,
  Plt bx (Genv.genv_next ge) -> Wff ge m gp sz vs -> tab_apart m bx.
Proof.
  intros m gp sz vs bx Hx (_ & _ & _ & _ & _ & W6 & _) hd Hh.
  destruct (W6 hd Hh) as (D1 & D2). split.
  - apply (wf_list_mono m (fun b => Plt b (Genv.genv_next ge)) _ hd); [| exact D1].
    intros b ->. exact Hx.
  - intros b o Ho ->. pose proof (D2 bx o Ho) as L. unfold Plt, Ple in *. lia.
Qed.

(* ... so the world fact extends over any global that is not a partition
   array (no flank-specific apartness fact needed) *)
Lemma Wff_global : forall m gp sz vs id bx ox,
  Genv.find_symbol ge id = Some bx -> ~ In id part_ids ->
  Wff ge m gp sz vs -> Wff ge m gp sz (vs ++ [Some (Vptr bx ox)]).
Proof.
  intros m gp sz vs id bx ox Hs Hn W.
  apply Wff_blk; [| exact (tab_apart_global m gp sz vs bx (Genv.genv_symb_range _ _ Hs) W) | exact W].
  intros id' bp Hin Hs' E. subst bp.
  assert (id' = id) by (eapply Genv.genv_vars_inj; [ exact Hs' | exact Hs ]). subst id'.
  exact (Hn Hin).
Qed.

(* no partition array is a flank global *)
Lemma part_not_rg : forall id, In id part_ids -> In id flank_gvars -> False.
Proof.
  intros id H1 H2. unfold part_ids in H1.
  destruct H1 as [<- | [<- | []]]; unfold flank_gvars, RenderAnim.render_gvars in H2; cbn [app] in H2;
    repeat (destruct H2 as [H2 | H2]; [vm_compute in H2; discriminate H2 |]); exact H2.
Qed.

(* a block off the partition stays off it through a memory change confined
   to the blocks rl, over which the frame's world fact holds *)
Lemma tab_apart_keep : forall m m' gp rl bx,
  Wff ge m gp SZ_SURFACE rl ->
  (forall id bp, In id part_ids -> Genv.find_symbol ge id = Some bp -> bp <> bx) ->
  tab_apart m bx ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p) ->
  (forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk rl b -> Mem.load ch m' b z = Mem.load ch m b z) ->
  tab_apart m' bx.
Proof.
  intros m m' gp rl bx W Sy TA Hnb KP Hld.
  assert (W1 : Wff ge m gp SZ_SURFACE (rl ++ [Some (Vptr bx Ptrofs.zero)]))
    by exact (Wff_blk m gp SZ_SURFACE rl bx Ptrofs.zero Sy TA W).
  assert (Hld' : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (rl ++ [Some (Vptr bx Ptrofs.zero)]) b ->
            Mem.load ch m' b z = Mem.load ch m b z).
  { intros ch b z Hv Hr. apply Hld; [exact Hv |]. intros (o & Ho). apply Hr. exists o.
    apply in_or_app. left. exact Ho. }
  exact (tab_of_Wff m' gp SZ_SURFACE rl bx Ptrofs.zero
           (Wff_keep2 ge m m' _ Hnb KP Hld' gp gp (fun b H => H) W1)).
Qed.

(* the base survives a memory change confined to the blocks rl, over which
   the frame's world fact holds, that keeps marioObj and the list's table
   and buffer pointers *)
Lemma anim_base_keep : forall m m' gp rl ab bga bauc btab otab bt ot mb mo,
  anim_base m ab bga bauc btab otab bt ot mb mo ->
  Wff ge m gp SZ_SURFACE rl ->
  ~ rblk rl btab -> ~ rblk rl bga ->
  Ple (Mem.nextblock m) (Mem.nextblock m') ->
  (forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p) ->
  (forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk rl b -> Mem.load ch m' b z = Mem.load ch m b z) ->
  Mem.load Mint32 m' bm 136 = Mem.load Mint32 m bm 136 ->
  Mem.load Mint32 m' ab 0 = Mem.load Mint32 m ab 0 ->
  Mem.load Mint32 m' ab 8 = Mem.load Mint32 m ab 8 ->
  Mem.load Mint32 m' bm 144 = Mem.load Mint32 m bm 144 ->
  Mem.load Mint32 m' bm 156 = Mem.load Mint32 m bm 156 ->
  anim_base m' ab bga bauc btab otab bt ot mb mo.
Proof.
  intros m m' gp rl ab bga bauc btab otab bt ot mb mo
    (S1 & S2 & S3 & L0 & L8 & Lm & Sy & D1 & D2 & D3 & D4 & (D5 & RG) & Z1 & Z2 & Z3 & P & T & GA & TA & AC & SM)
    W Ntab Nga Hnb KP Hld K136 K0 K8 K144 K156.
  assert (Vtab : Plt btab (Mem.nextblock m)).
  { destruct T as (T1 & _). eapply Mem.valid_access_valid_block.
    eapply Mem.valid_access_implies; [eapply Mem.load_valid_access; exact T1 | constructor]. }
  assert (Vga : Plt bga (Mem.nextblock m)).
  { destruct GA as (_ & G2). apply (Mem.perm_valid_block m bga 0 Cur Readable). apply G2.
    unfold GA_SIZE. lia. }
  assert (Kt : forall ch o, Mem.load ch m' btab o = Mem.load ch m btab o)
    by (intros ch o; exact (Hld ch btab o Vtab Ntab)).
  assert (Kg : forall ch o, Mem.load ch m' bga o = Mem.load ch m bga o)
    by (intros ch o; exact (Hld ch bga o Vga Nga)).
  refine (conj S1 (conj S2 (conj S3 (conj _ (conj _ (conj _ (conj Sy (conj D1 (conj D2 (conj D3 (conj D4
           (conj (conj D5 _) (conj Z1 (conj Z2 (conj Z3 (conj _ (conj _ (conj _ (conj _ (conj _ SM)))))))))))))))))))).
  - rewrite K0. exact L0.
  - rewrite K8. exact L8.
  - rewrite K136. exact Lm.
  - (* the render globals stay off the partition *)
    intros id b Hin Hs. destruct (RG id b Hin Hs) as (Ne & TAb). split; [exact Ne |].
    apply (tab_apart_keep m m' gp rl b W); [| exact TAb | exact Hnb | exact KP | exact Hld].
    intros id' bp Hin' Hs' E. subst bp.
    assert (Hne : id' <> id) by (intros ->; exact (part_not_rg id Hin' Hin)).
    exact (Genv.global_addresses_distinct ge Hne Hs' Hs eq_refl).
  - intros i Hi. apply KP; [| exact (P i Hi)].
    apply (Mem.perm_valid_block m bt i Cur Readable). exact (P i Hi).
  - destruct T as (T1 & T2 & T3). unfold tab_ok. rewrite !Kt.
    refine (conj T1 (conj T2 _)). intros j o s' Hj. rewrite !Kt. exact (T3 j o s' Hj).
  - destruct GA as (G1 & G2). split.
    + intros o ch z Hin. rewrite Kg. exact (G1 o ch z Hin).
    + intros i Hi. apply KP; [| exact (G2 i Hi)].
      apply (Mem.perm_valid_block m bga i Cur Readable). exact (G2 i Hi).
  - (* the table's block stays off the partition *)
    assert (W1 : Wff ge m gp SZ_SURFACE (rl ++ [Some (Vptr btab otab)])).
    { apply Wff_tab; [intros id b Hs E0; exact (proj1 (Sy id b Hs) E0) | exact TA | exact W]. }
    assert (Hld' : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk (rl ++ [Some (Vptr btab otab)]) b ->
              Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z Hv Hr. apply Hld; [exact Hv |]. intros (o & Ho). apply Hr. exists o.
      apply in_or_app. left. exact Ho. }
    exact (tab_of_Wff m' gp SZ_SURFACE rl btab otab
             (Wff_keep2 ge m m' _ Hnb KP Hld' gp gp (fun b H => H) W1)).
  - intros off b o Hoff Hl. apply (AC off b o Hoff).
    destruct Hoff as [-> | ->]; [rewrite <- K144 | rewrite <- K156]; exact Hl.
Qed.

(* the animation state survives a change that keeps currentAddr, the
   object's animation cells and the buffer block *)
Lemma anim_st_keep : forall m m' ab bga bt ot mb mo,
  anim_st m ab bga bt ot mb mo ->
  Mem.load Mint32 m' ab 4 = Mem.load Mint32 m ab 4 ->
  (forall o ch, In (o, ch) [(56, Mint16signed); (60, Mint32); (64, Mint16signed); (72, Mint32)] ->
     Mem.load ch m' mb (Ptrofs.unsigned mo + o) = Mem.load ch m mb (Ptrofs.unsigned mo + o)) ->
  (forall k rel ch v, In k hs_ids -> In (rel, ch, v) (buf_cells k) ->
     Mem.load ch m' bt (Ptrofs.unsigned ot + rel) = Mem.load ch m bt (Ptrofs.unsigned ot + rel)) ->
  anim_st m' ab bga bt ot mb mo.
Proof.
  intros m m' ab bga bt ot mb mo H K4 Km Kb.
  assert (K56 := Km 56 Mint16signed ltac:(cbn; auto)).
  assert (K60 := Km 60 Mint32 ltac:(cbn; auto)).
  assert (K64 := Km 64 Mint16signed ltac:(cbn; auto)).
  assert (K72 := Km 72 Mint32 ltac:(cbn; auto)).
  destruct H as [((i & Li & Ni) & C) | (k & Hk & (A1 & A2 & A3 & A4 & (f & Rf & A5) & A6))].
  - left. split; [exists i; rewrite K56; split; assumption |].
    rewrite K4. exact C.
  - right. exists k. split; [exact Hk |].
    split; [rewrite K4; exact A1 |].
    split; [rewrite K56; exact A2 |].
    split; [rewrite K60; exact A3 |].
    split; [rewrite K72; exact A4 |].
    split; [exists f; split; [exact Rf | rewrite K64; exact A5] |].
    intros rel ch v Hin. rewrite (Kb k rel ch v Hk Hin). exact (A6 rel ch v Hin).
Qed.

End AW.
