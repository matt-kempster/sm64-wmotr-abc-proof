(* kept: P5 slices 0-2 -- the init-grounding PRODUCER for the twelve-TU
   bucket-B runtime-layout rows.  Grounds the CHEAP bucket-B hypotheses of
   NoAImpliesNoFlyTwelve (the bc/bm/global-block DISTINCTNESS content, plus
   bm/bc validity and the Hglob_valid discharge path) in Genv.init_mem +
   find_symbol facts about the LINKED program, under an explicit, faithful
   spawn condition `spawn_ok` (design memo: docs/p5-init-grounding-design.md,
   Candidate A).

   Load-bearing status (honest): NOT yet consumed by the capstone.  Each
   capstone distinctness row bundles a `~ SafeB _` conjunct with the
   `<> bm /\ <> bc` conjuncts this file proves; SafeB is concretized in the
   director's slices 3-5, and only then can these lemmas be combined into the
   full rows and swapped in.  What this file establishes is that the bucket-B
   distinctness content is a COROLLARY of the linked AST's symbol table (via
   Genv.global_addresses_distinct + genv_symb_range), not a standalone
   assumption -- and that the spawn condition is non-vacuous modulo the single
   named residual `exists init, Genv.init_mem lp = Some init` (the abstract
   link's init-data well-formedness; not computable from `linked12` alone).

   FAITHFULNESS of spawn_ok's symbol choices:
    - the MarioState array is `level_update._gMarioStates` (a DEFINED 200-byte
      static, generated/level_update.v; mario.v carries only the extern
      pointer `_gMarioState`).  Under `linked12` it wins the varinit merge, so
      `bm` = its symbol block is the faithful choice (memo section 0, R5).
    - the controller struct `bc` is NOT symbol-addressed inside MWF_real (R2/R3
      reach it only through Mario's `controller` pointer cell bm@156).  But the
      real game sets `m->controller = &gControllers[0]`, and
      `mario._gControllers` IS a genuine defined static (generated/mario.v),
      so `bc` = its symbol block, `oc0 = 0`, is the faithful run-consistent
      choice.  This makes Hbc_bm / Hbc_sym provable. *)

From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Clight Linking.
From SM64.Generated Require mario level_update interaction mario_actions_moving.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked CensusV2 MWFReal
  LinkedTwelve.
Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* Slice 0a: the symbol-resolution primitive.  Any TU q with linkorder q lp *)
(* contributes each of its defined symbols (gvar OR gfun) to lp's genv --   *)
(* the gvar analogue of SymbolicLinking.linkorder_resolves_internal.  lp    *)
(* stays abstract; the only computation is the caller's per-TU defmap       *)
(* lookup.                                                                  *)
(* ---------------------------------------------------------------------- *)

Lemma linkorder_resolves_symbol :
  forall (lp q : Clight.program) (id : ident) (gd : globdef Clight.fundef type),
    linkorder q lp ->
    (prog_defmap q) ! id = Some gd ->
    exists b, Genv.find_symbol (globalenv lp) id = Some b.
Proof.
  intros lp q id gd LOq Hdm.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LOq.
  destruct LOq as [LOast _].
  destruct (prog_defmap_linkorder _ _ _ _ LOast Hdm) as (gd' & Hgd' & _).
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hgd'.
  destruct Hgd' as (b & Hsym & _). exists b. exact Hsym.
Qed.

(* the two per-TU defmap lookups (the only vm computations here) *)
Lemma lvl_defmap_gMarioStates :
  (prog_defmap level_update.prog) ! level_update._gMarioStates
    = Some (Gvar level_update.v_gMarioStates).
Proof. vm_compute. reflexivity. Qed.

Lemma mario_defmap_gControllers :
  (prog_defmap mario.prog) ! mario._gControllers
    = Some (Gvar mario.v_gControllers).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* Slice 0b: the spawn condition (memo Candidate A), decomposed -- three    *)
(* find_symbol equations over the LINKED genv + one init_mem anchor + the   *)
(* controller offset pin.  None of the bucket-B rows appears in it; each is *)
(* DERIVED below.                                                           *)
(* ---------------------------------------------------------------------- *)

Definition spawn_ok (lp : Clight.program) (init : mem)
                    (bm bc : block) (oc0 : ptrofs) : Prop :=
  Genv.init_mem lp = Some init
  /\ Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm
  /\ Genv.find_symbol (lp_ge lp) mario._gControllers        = Some bc
  /\ oc0 = Ptrofs.zero.

(* ---------------------------------------------------------------------- *)
(* Slice 2 (anchor): the symbols resolve, and spawn_ok is satisfiable       *)
(* modulo init_mem success.                                                 *)
(* ---------------------------------------------------------------------- *)

Section SpawnSat.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.

  (* the find_symbol part of spawn_ok holds for EVERY twelve-TU link,
     purely from linkorder (no init_mem needed). *)
  Lemma spawn_symbols_resolve :
    exists bm bc,
      Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm
      /\ Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Proof.
    destruct (linkorder_resolves_symbol lp level_update.prog
                level_update._gMarioStates _
                (linked12_LO_lvl lp H12) lvl_defmap_gMarioStates) as (bm & Hbm).
    destruct (linkorder_resolves_symbol lp mario.prog
                mario._gControllers _
                (linked12_LO_mario lp H12) mario_defmap_gControllers) as (bc & Hbc).
    exists bm, bc. unfold lp_ge. split; assumption.
  Qed.

  (* non-vacuity: the ONLY residual is that the abstract link has an init
     memory.  `exists init, init_mem lp = Some init` is not derivable from
     `linked12` (init_mem of an abstract lp is not computable, and
     init_mem_exists needs the init-data well-formedness of lp's whole
     defmap) -- so it is discharged as an explicit premise, kept honest. *)
  Lemma spawn_ok_sat :
    (exists init, Genv.init_mem lp = Some init) ->
    exists init bm bc oc0, spawn_ok lp init bm bc oc0.
  Proof.
    intros (init & Hinit).
    destruct spawn_symbols_resolve as (bm & bc & Hbm & Hbc).
    exists init, bm, bc, Ptrofs.zero.
    unfold spawn_ok. repeat split; assumption.
  Qed.
End SpawnSat.

(* ---------------------------------------------------------------------- *)
(* Slice 1 + slice-2 validity: the CHEAP injectivity rows and bm/bc         *)
(* validity, for any lp with spawn_ok.  The `~ SafeB _` conjuncts of the    *)
(* capstone distinctness rows are DELIBERATELY absent (slices 3-5).         *)
(* ---------------------------------------------------------------------- *)

Section SpawnRows.
  Variable lp : Clight.program.
  Variable init : mem.
  Variable bm bc : block.
  Variable oc0 : ptrofs.
  Hypothesis Hspawn : spawn_ok lp init bm bc oc0.

  (* ---- pure injectivity (no SafeB): fully discharges capstone rows ---- *)

  Lemma spawn_Hbc_bm : bc <> bm.
  Proof.
    destruct Hspawn as (_ & Hbm & Hbc & _).
    eapply Genv.global_addresses_distinct; [ | exact Hbc | exact Hbm ].
    vm_compute; discriminate.
  Qed.

  Lemma spawn_Hbc_sym :
    exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.
  Proof.
    destruct Hspawn as (_ & _ & Hbc & _).
    exists mario._gControllers. exact Hbc.
  Qed.

  (* ---- the <> bm /\ <> bc conjuncts of the five distinctness rows ---- *)

  (* Hgms_blk (fixed symbol mario._gMarioState -- the extern POINTER, distinct
     from the level_update array bm and from the controller bc). *)
  Lemma spawn_Hgms_neq : forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc.
  Proof.
    destruct Hspawn as (_ & Hbm & Hbc & _). intros gb Hs. split.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbm ];
        vm_compute; discriminate.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbc ];
        vm_compute; discriminate.
  Qed.

  Lemma spawn_Hgtimer_neq : forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc.
  Proof.
    destruct Hspawn as (_ & Hbm & Hbc & _). intros gb Hs. split.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbm ];
        vm_compute; discriminate.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbc ];
        vm_compute; discriminate.
  Qed.

  Lemma spawn_Htable_neq : forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc.
  Proof.
    destruct Hspawn as (_ & Hbm & Hbc & _). intros tb Hs. split.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbm ];
        vm_compute; discriminate.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbc ];
        vm_compute; discriminate.
  Qed.

  (* Hglob_blk: gid quantified over the censused stored_globals list.  gid
     cannot BE the array/controller symbol (neither is in the list -- vm), so
     global_addresses_distinct applies per conjunct. *)
  Lemma spawn_Hglob_neq : forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc.
  Proof.
    destruct Hspawn as (_ & Hbm & Hbc & _). intros gid bg Hmem Hs. split.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbm ].
      intro Heq; subst gid; vm_compute in Hmem; discriminate.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbc ].
      intro Heq; subst gid; vm_compute in Hmem; discriminate.
  Qed.

  (* Hktab_blk: gid quantified over knockback_table_ids (MWFReal). *)
  Lemma spawn_Hktab_neq : forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc.
  Proof.
    destruct Hspawn as (_ & Hbm & Hbc & _). intros gid kb Hmem Hs. split.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbm ].
      intro Heq; subst gid; vm_compute in Hmem; discriminate.
    - eapply Genv.global_addresses_distinct; [ | exact Hs | exact Hbc ].
      intro Heq; subst gid; vm_compute in Hmem; discriminate.
  Qed.

  (* ---- bm/bc validity at the init memory (find_symbol_not_fresh) ---- *)

  Lemma spawn_bm_valid : Mem.valid_block init bm.
  Proof.
    destruct Hspawn as (Hinit & Hbm & _ & _).
    eapply Genv.find_symbol_not_fresh; [ exact Hinit | exact Hbm ].
  Qed.

  Lemma spawn_bc_valid : Mem.valid_block init bc.
  Proof.
    destruct Hspawn as (Hinit & _ & Hbc & _).
    eapply Genv.find_symbol_not_fresh; [ exact Hinit | exact Hbc ].
  Qed.

  (* Hglob_valid AT INIT: every symbol block is valid in the initial memory.
     (The capstone's Hglob_valid ranges over all m with MWF m -- see the
     conditional glob_valid_of_nextbound below and the report's residual.) *)
  Lemma spawn_glob_valid_init : forall gid bg,
      Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block init bg.
  Proof.
    destruct Hspawn as (Hinit & _ & _ & _). intros gid bg Hs.
    eapply Genv.find_symbol_not_fresh; [ exact Hinit | exact Hs ].
  Qed.

End SpawnRows.

(* ---------------------------------------------------------------------- *)
(* The Hglob_valid discharge path for an ARBITRARY run memory (not just     *)
(* init).  The capstone states Hglob_valid as `forall m, MWF m -> ...`, but *)
(* MWF_real R0 only carries validity for the SPECIFIC symbols it reads.     *)
(* The general fact needs a `genv_next <= nextblock m` bound (true at init  *)
(* by init_mem_genv_next, run-monotone because every step only grows        *)
(* nextblock).  Stated here as an explicit premise so the discharge path is *)
(* on record; wiring it requires the MWF_real R0 strengthening flagged in   *)
(* the memo (docs/p5-init-grounding-design.md section 5, MEDIUM tier).      *)
(* ---------------------------------------------------------------------- *)

Lemma glob_valid_of_nextbound :
  forall (lp : Clight.program) (m : mem),
    Ple (Genv.genv_next (lp_ge lp)) (Mem.nextblock m) ->
    forall gid bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
                   Mem.valid_block m bg.
Proof.
  intros lp m Hple gid bg Hs. red.
  eapply Plt_Ple_trans; [ eapply Genv.genv_symb_range; exact Hs | exact Hple ].
Qed.

(* the init memory satisfies that nextblock bound (the base case of the
   run-monotone argument), so glob_valid_of_nextbound instantiated at init
   agrees with spawn_glob_valid_init. *)
Lemma init_genv_next_bound :
  forall (lp : Clight.program) (init : mem),
    Genv.init_mem lp = Some init ->
    Ple (Genv.genv_next (lp_ge lp)) (Mem.nextblock init).
Proof.
  intros lp init Hinit.
  rewrite <- (Genv.init_mem_genv_next _ Hinit). apply Ple_refl.
Qed.

(* ---------------------------------------------------------------------- *)
(* P5 SLICE 3: the consolidated SafeB honest-boundary characterization.     *)
(*                                                                          *)
(* THE FULCRUM FACT (docs/p5-safeb-design.md).  Among the LINKED symbol      *)
(* blocks, the object-system pointer graph credits exactly ONE --           *)
(* sFloorAlignMatrix.  Every other SafeB member is a runtime / external      *)
(* (spawn_object) block, never a mario.prog-family symbol (the object pool   *)
(* gObjectPool/gObjectLists is ABSENT from the twelve TUs; gMarioObject /    *)
(* gCurrentObject are null Object* cells; spawn_object is EF_external).      *)
(* So the intersection of SafeB with the linked symbol table is the         *)
(* singleton {sFloorAlignMatrix}.  This is the ONE honest-boundary row that  *)
(* REPLACES the eight scattered capstone SafeB rows -- from it the seven     *)
(* negative rows and the one positive (Hsfam_safe) are DERIVED below.        *)
(*                                                                          *)
(* NON-VACUITY (satisfiability): the row is satisfied by the concrete SafeB  *)
(* the game realizes -- SafeB_wit lp objblks := objblks-blocks (all runtime  *)
(* returns, >= genv_next) UNION {the sFloorAlignMatrix symbol block}.  An    *)
(* objblks block is >= genv_next so is never `find_symbol id` (which is <    *)
(* genv_next by genv_symb_range); the lone symbol in the set is             *)
(* sFloorAlignMatrix.  So SafeB CAN hold object blocks while the iff pins    *)
(* only the symbol part -- the row is NOT the empty predicate and NOT the    *)
(* conclusion.  See safeb_wit_sat below for the Qed'd certificate.          *)
(* ---------------------------------------------------------------------- *)

(* Standalone (NOT sectioned) so that ALL exports share a UNIFORM explicit
   telescope (lp init bm bc oc0 SafeB) + Hspawn + Hiff -- a section would drop
   the variables an individual lemma does not use, giving each a different
   arity and breaking the capstone's `exact` applications. *)

Notation SafeB_iff lp SafeB :=
  (forall id b,
     Genv.find_symbol (lp_ge lp) id = Some b ->
     (SafeB b <-> id = mario_actions_moving._sFloorAlignMatrix)).

(* the ~SafeB micro-brick: any symbol whose ident is NOT sFloorAlignMatrix
   is not SafeB (forward direction of the iff, closed by ident-distinctness). *)
Lemma safeb_of_nonfam_sym :
  forall (lp : Clight.program) (SafeB : block -> Prop),
    SafeB_iff lp SafeB ->
    forall id b,
      Genv.find_symbol (lp_ge lp) id = Some b ->
      id <> mario_actions_moving._sFloorAlignMatrix ->
      ~ SafeB b.
Proof.
  intros lp SafeB Hiff id b Hs Hne HS.
  apply (proj1 (Hiff _ _ Hs)) in HS. contradiction.
Qed.

(* ---- the eight rows, each in the EXACT shape of the capstone row it
   replaces, with a uniform (lp init bm bc oc0 SafeB) + Hspawn + Hiff
   telescope. ---- *)

Lemma safeb_not_bm :
  forall (lp : Clight.program) (init : mem) (bm bc : block) (oc0 : ptrofs)
         (SafeB : block -> Prop),
    spawn_ok lp init bm bc oc0 -> SafeB_iff lp SafeB ->
    forall b, SafeB b -> b <> bm.
Proof.
  intros lp init bm bc oc0 SafeB Hspawn Hiff.
  destruct Hspawn as (_ & Hbm & _ & _).
  intros b HS Heq. subst b.
  apply (proj1 (Hiff _ _ Hbm)) in HS.
  vm_compute in HS; discriminate.
Qed.

Lemma safeb_not_bc :
  forall (lp : Clight.program) (init : mem) (bm bc : block) (oc0 : ptrofs)
         (SafeB : block -> Prop),
    spawn_ok lp init bm bc oc0 -> SafeB_iff lp SafeB ->
    ~ SafeB bc.
Proof.
  intros lp init bm bc oc0 SafeB Hspawn Hiff.
  destruct Hspawn as (_ & _ & Hbc & _).
  apply (safeb_of_nonfam_sym lp SafeB Hiff mario._gControllers).
  - exact Hbc.
  - vm_compute; discriminate.
Qed.

Lemma sfam_safe :
  forall (lp : Clight.program) (init : mem) (bm bc : block) (oc0 : ptrofs)
         (SafeB : block -> Prop),
    spawn_ok lp init bm bc oc0 -> SafeB_iff lp SafeB ->
    forall gb,
      Genv.find_symbol (lp_ge lp) mario_actions_moving._sFloorAlignMatrix
        = Some gb -> SafeB gb.
Proof.
  intros lp init bm bc oc0 SafeB Hspawn Hiff gb Hs.
  apply (proj2 (Hiff _ _ Hs)). reflexivity.
Qed.

Lemma gms_blk :
  forall (lp : Clight.program) (init : mem) (bm bc : block) (oc0 : ptrofs)
         (SafeB : block -> Prop),
    spawn_ok lp init bm bc oc0 -> SafeB_iff lp SafeB ->
    forall gb,
      Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
Proof.
  intros lp init bm bc oc0 SafeB Hspawn Hiff gb Hs.
  destruct (spawn_Hgms_neq lp init bm bc oc0 Hspawn gb Hs) as (Hnbm & Hnbc).
  split; [exact Hnbm | split; [exact Hnbc | ]].
  eapply safeb_of_nonfam_sym; [ exact Hiff | exact Hs | vm_compute; discriminate ].
Qed.

Lemma gtimer_blk :
  forall (lp : Clight.program) (init : mem) (bm bc : block) (oc0 : ptrofs)
         (SafeB : block -> Prop),
    spawn_ok lp init bm bc oc0 -> SafeB_iff lp SafeB ->
    forall gb,
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      gb <> bm /\ gb <> bc /\ ~ SafeB gb.
Proof.
  intros lp init bm bc oc0 SafeB Hspawn Hiff gb Hs.
  destruct (spawn_Hgtimer_neq lp init bm bc oc0 Hspawn gb Hs) as (Hnbm & Hnbc).
  split; [exact Hnbm | split; [exact Hnbc | ]].
  eapply safeb_of_nonfam_sym; [ exact Hiff | exact Hs | vm_compute; discriminate ].
Qed.

Lemma table_blk :
  forall (lp : Clight.program) (init : mem) (bm bc : block) (oc0 : ptrofs)
         (SafeB : block -> Prop),
    spawn_ok lp init bm bc oc0 -> SafeB_iff lp SafeB ->
    forall tb,
      Genv.find_symbol (lp_ge lp) interaction._sInteractionHandlers = Some tb ->
      tb <> bm /\ tb <> bc /\ ~ SafeB tb.
Proof.
  intros lp init bm bc oc0 SafeB Hspawn Hiff tb Hs.
  destruct (spawn_Htable_neq lp init bm bc oc0 Hspawn tb Hs) as (Hnbm & Hnbc).
  split; [exact Hnbm | split; [exact Hnbc | ]].
  eapply safeb_of_nonfam_sym; [ exact Hiff | exact Hs | vm_compute; discriminate ].
Qed.

Lemma glob_blk :
  forall (lp : Clight.program) (init : mem) (bm bc : block) (oc0 : ptrofs)
         (SafeB : block -> Prop),
    spawn_ok lp init bm bc oc0 -> SafeB_iff lp SafeB ->
    forall gid bg,
      mem_id gid stored_globals = true ->
      Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\ bg <> bc /\ ~ SafeB bg.
Proof.
  intros lp init bm bc oc0 SafeB Hspawn Hiff gid bg Hmem Hs.
  destruct (spawn_Hglob_neq lp init bm bc oc0 Hspawn gid bg Hmem Hs)
    as (Hnbm & Hnbc).
  split; [exact Hnbm | split; [exact Hnbc | ]].
  intro HS. apply (proj1 (Hiff _ _ Hs)) in HS.
  subst gid. vm_compute in Hmem; discriminate.
Qed.

Lemma ktab_blk :
  forall (lp : Clight.program) (init : mem) (bm bc : block) (oc0 : ptrofs)
         (SafeB : block -> Prop),
    spawn_ok lp init bm bc oc0 -> SafeB_iff lp SafeB ->
    forall gid kb,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      kb <> bm /\ kb <> bc /\ ~ SafeB kb.
Proof.
  intros lp init bm bc oc0 SafeB Hspawn Hiff gid kb Hmem Hs.
  destruct (spawn_Hktab_neq lp init bm bc oc0 Hspawn gid kb Hmem Hs)
    as (Hnbm & Hnbc).
  split; [exact Hnbm | split; [exact Hnbc | ]].
  intro HS. apply (proj1 (Hiff _ _ Hs)) in HS.
  subst gid. vm_compute in Hmem; discriminate.
Qed.

(* ---------------------------------------------------------------------- *)
(* NON-VACUITY CERTIFICATE for HSafeB_sym_iff: the concrete SafeB the game   *)
(* realizes (object graph UNION the sFloorAlignMatrix symbol block)         *)
(* satisfies the iff.  Witnesses that the row is jointly satisfiable and is  *)
(* NOT the empty predicate -- objblks blocks (>= genv_next) are held by      *)
(* SafeB_wit yet the iff pins only the symbol part.                          *)
(* ---------------------------------------------------------------------- *)

Definition SafeB_wit (lp : Clight.program) (objblks : block -> Prop)
  : block -> Prop :=
  fun b => objblks b
        \/ Genv.find_symbol (lp_ge lp) mario_actions_moving._sFloorAlignMatrix
             = Some b.

Lemma safeb_wit_sat :
  forall (lp : Clight.program) (objblks : block -> Prop),
    (forall b, objblks b -> Plt (Genv.genv_next (lp_ge lp)) b) ->
    forall id b,
      Genv.find_symbol (lp_ge lp) id = Some b ->
      (SafeB_wit lp objblks b <-> id = mario_actions_moving._sFloorAlignMatrix).
Proof.
  intros lp objblks Hfresh id b Hs. unfold SafeB_wit. split.
  - intros [Hobj | Hfam].
    + (* objblks b => b >= genv_next, but Hs gives b < genv_next: impossible *)
      exfalso. apply (Plt_strict b).
      eapply Plt_trans; [ eapply Genv.genv_symb_range; exact Hs | apply Hfresh; exact Hobj ].
    + (* b is the sFloorAlignMatrix symbol block => id = sFloorAlignMatrix by inj *)
      eapply Genv.genv_vars_inj; [ exact Hs | exact Hfam ].
  - intro Hid. subst id. right. exact Hs.
Qed.
