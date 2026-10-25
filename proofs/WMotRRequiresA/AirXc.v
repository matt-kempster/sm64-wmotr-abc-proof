(* ====================================================================== *)
(* AirXc (unwired, GOAL 2): the contract table for the value walk of the    *)
(* real perform_air_step, with SymExec2's xc_sound PROVED for it.           *)
(*                                                                          *)
(* Every call perform_air_step makes is either inlined by the executor or  *)
(* answered here:                                                          *)
(*   find_floor              FloorExec.c_ff    (c_ff_sound)                 *)
(*   find_ceil               CeilExec.c_fc     (c_fc_sound)                 *)
(*   find_wall_collisions    WallExec.c_fwc    (c_fwc_sound)                *)
(*   find_water_level, atan2s, mario_get_terrain_sound_addend               *)
(*                           xc_fresh          (their value contracts:      *)
(*                           memory unchanged, a non-pointer result)        *)
(*                                                                          *)
(* What is left is plain genv facts (each callee's symbol resolves to its  *)
(* generated body, the composite env, the gtab entry for gNumCalls) and    *)
(* the world fact's meaning (HU, a frame invariant to carry) and the       *)
(* height fact's (HUH: the consumer's uf must accept what ff_height       *)
(* proves).  No trust.                                                     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario surface_collision math_util.
From SM64.Proofs Require Import Interp.SymExec2 MarioModel.MathGeomGated MarioModel.MathBodies
  Generic.SymbolicLinking
  WMotRRequiresA.FloorList WMotRRequiresA.FloorHeight WMotRRequiresA.FloorExec
  WMotRRequiresA.CeilList WMotRRequiresA.CeilExec
  WMotRRequiresA.WallFind WMotRRequiresA.WallExec
  WMotRRequiresA.TerrainSound.
Import ListNotations.

Section AX.
Variable ge : genv.
Variable nbase : positive.
Variable R0 : list (positive * Z).
Variable gtab : list (ident * positive).
Variable kv : list (positive * Z * memory_chunk * sval).
Variable m0 : mem.
Variable uf : positive -> list (option val) -> Prop.
Variable gp : meminj.
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables rFI rMS rCL kW kH kS : positive.
Variable szS : Z.

(* THE TABLE *)
Definition air_xc (id : ident) : option xcontract :=
  if Pos.eqb id mario._find_floor then Some (c_ff nbase R0 rFI rMS rCL kW kH kS szS)
  else if Pos.eqb id mario._find_ceil then Some (c_fc nbase R0 rCL kW szS)
  else if Pos.eqb id mario._find_water_level then Some xc_fresh
  else if Pos.eqb id mario._atan2s then Some xc_fresh
  else if Pos.eqb id mario._mario_get_terrain_sound_addend then Some xc_fresh
  else if Pos.eqb id mario._find_wall_collisions then Some (c_fwc nbase R0 rCL kW kS szS)
  else None.

(* the genv facts *)
Hypothesis HC : cenv_has ge.
Hypothesis Hffl : ffl_pinned ge.
Hypothesis Hfcl : fcl_pinned ge.
Hypothesis Hwfl : wfl_pinned ge.
Hypothesis Hat : resolves_to ge math_util._atan2_lookup math_util.f_atan2_lookup.
Hypothesis Rff : resolves_to ge mario._find_floor surface_collision.f_find_floor.
Hypothesis Rfc : resolves_to ge mario._find_ceil surface_collision.f_find_ceil.
Hypothesis Rwl : resolves_to ge mario._find_water_level surface_collision.f_find_water_level.
Hypothesis Ra2 : resolves_to ge mario._atan2s math_util.f_atan2s.
Hypothesis Rts : resolves_to ge mario._mario_get_terrain_sound_addend mario.f_mario_get_terrain_sound_addend.
Hypothesis Rfw : resolves_to ge mario._find_wall_collisions surface_collision.f_find_wall_collisions.
Hypothesis HgFI : gfind gtab surface_collision._gFindFloorIncludeSurfaceIntangible = Some rFI.
Hypothesis HgMS : gfind gtab surface_collision._gNumFindFloorMisses = Some rMS.
Hypothesis HgCL : gfind gtab surface_collision._gNumCalls = Some rCL.
(* the world fact's meaning *)
Hypothesis HU : forall vs, uf kW vs -> Wff ge m0 gp szS vs.
(* the height fact's meaning (proved by c_ff_sound from find_floor's body) *)
Hypothesis HUH : forall h yv, HPi (Hit_at ge m0) (ycast yv) h -> Hit_at ge m0 h ->
  uf kH [Some (Vsingle h); Some yv].
(* the surface fact's meaning *)
Hypothesis HUS : forall vs, surf_on ge m0 vs -> uf kS vs.

Lemma lookup_res : forall id f fd, resolves_to ge id f -> sfun_lookup ge id = Some fd -> fd = Internal f.
Proof.
  intros id f fd R H. unfold sfun_lookup in H.
  destruct (Genv.find_symbol ge id) as [b |] eqn:Hs; [| discriminate H].
  exact (R b fd Hs H).
Qed.

(* THE SOUNDNESS: SymExec2's xc_sound for this table *)
Theorem air_xc_sound : forall id k args g cps fd E m vargs t m' vres,
  air_xc id = Some k -> k args g = Some cps -> sfun_lookup ge id = Some fd ->
  MMg ge nbase R0 gtab kv m0 uf gp E m g ->
  Forall2 (fun a v => den ge m0 E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 ge m fd vargs t m' vres ->
  exists c, In c cps /\ CM ge nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros id k args g cps fd E m vargs t m' vres Hx Hk Hl MMh HF Hev.
  unfold air_xc in Hx.
  destruct (Pos.eqb_spec id mario._find_floor) as [-> | N1].
  { injection Hx as <-. rewrite (lookup_res _ _ _ Rff Hl) in Hev.
    exact (c_ff_sound ge nbase R0 gtab kv m0 uf gp gp_old rFI rMS rCL kW kH kS szS HC Hffl HgFI HgMS HgCL HU HUS HUH
             _ _ _ _ _ _ _ _ _ Hk MMh HF Hev). }
  destruct (Pos.eqb_spec id mario._find_ceil) as [-> | N2].
  { injection Hx as <-. rewrite (lookup_res _ _ _ Rfc Hl) in Hev.
    exact (c_fc_sound ge nbase R0 gtab kv m0 uf gp gp_old rCL kW szS HC Hfcl HgCL HU
             _ _ _ _ _ _ _ _ _ Hk MMh HF Hev). }
  destruct (Pos.eqb_spec id mario._find_water_level) as [-> | N3].
  { injection Hx as <-. rewrite (lookup_res _ _ _ Rwl Hl) in Hev.
    destruct (find_water_level_value_contract _ _ _ _ _ _ Hev) as (-> & x & ->).
    exact (xc_fresh_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m g (Vsingle x) args cps Hk MMh I). }
  destruct (Pos.eqb_spec id mario._atan2s) as [-> | N4].
  { injection Hx as <-. rewrite (lookup_res _ _ _ Ra2 Hl) in Hev.
    destruct (atan2s_value_contract _ Hat _ _ _ _ _ Hev) as (-> & i & ->).
    exact (xc_fresh_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m g (Vint i) args cps Hk MMh I). }
  destruct (Pos.eqb_spec id mario._mario_get_terrain_sound_addend) as [-> | N5].
  { injection Hx as <-. rewrite (lookup_res _ _ _ Rts Hl) in Hev.
    destruct (terrain_sound_value_contract _ _ _ _ _ _ Hev) as (-> & i & ->).
    exact (xc_fresh_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp E m g (Vint i) args cps Hk MMh I). }
  destruct (Pos.eqb_spec id mario._find_wall_collisions) as [-> | N6]; [| discriminate Hx].
  injection Hx as <-. rewrite (lookup_res _ _ _ Rfw Hl) in Hev.
  exact (c_fwc_sound ge nbase R0 gtab kv m0 uf gp gp_old rCL kW szS HC Hwfl HgCL HU kS HUS
           _ _ _ _ _ _ _ _ _ Hk MMh HF Hev).
Qed.

End AX.

(* ---- the genv facts, on any link that contains the three TUs ---- *)

Lemma cenv_has_link : forall lp : Clight.program,
  linkorder surface_collision.prog lp -> cenv_has (globalenv lp).
Proof.
  intros lp LO id co H.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in LO. destruct LO as [_ HCo].
  exact (HCo id co H).
Qed.

Lemma res_link : forall (lp q : Clight.program) id f, linkorder q lp ->
  (prog_defmap q) ! id = Some (Gfun (Internal f)) -> resolves_to (globalenv lp) id f.
Proof.
  intros lp q id f LO Hdm bf fd Hs Hf.
  destruct (SymbolicLinking.linkorder_resolves_internal lp q id f LO Hdm) as (b & Hs' & Hf').
  rewrite Hs in Hs'. injection Hs' as <-. congruence.
Qed.

(* the per-TU defmap entries (bounded, single-TU lookups) *)
Lemma dm_ffl : (prog_defmap surface_collision.prog) ! surface_collision._find_floor_from_list
  = Some (Gfun (Internal surface_collision.f_find_floor_from_list)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_fcl : (prog_defmap surface_collision.prog) ! surface_collision._find_ceil_from_list
  = Some (Gfun (Internal surface_collision.f_find_ceil_from_list)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_wfl : (prog_defmap surface_collision.prog) ! surface_collision._find_wall_collisions_from_list
  = Some (Gfun (Internal surface_collision.f_find_wall_collisions_from_list)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ff : (prog_defmap surface_collision.prog) ! mario._find_floor
  = Some (Gfun (Internal surface_collision.f_find_floor)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_fc : (prog_defmap surface_collision.prog) ! mario._find_ceil
  = Some (Gfun (Internal surface_collision.f_find_ceil)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_wl : (prog_defmap surface_collision.prog) ! mario._find_water_level
  = Some (Gfun (Internal surface_collision.f_find_water_level)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_fw : (prog_defmap surface_collision.prog) ! mario._find_wall_collisions
  = Some (Gfun (Internal surface_collision.f_find_wall_collisions)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_al : (prog_defmap math_util.prog) ! math_util._atan2_lookup
  = Some (Gfun (Internal math_util.f_atan2_lookup)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_a2 : (prog_defmap math_util.prog) ! mario._atan2s
  = Some (Gfun (Internal math_util.f_atan2s)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ts : (prog_defmap mario.prog) ! mario._mario_get_terrain_sound_addend
  = Some (Gfun (Internal mario.f_mario_get_terrain_sound_addend)).
Proof. vm_compute. reflexivity. Qed.

Section LP.
Variable lp : Clight.program.
Hypothesis LOs : linkorder surface_collision.prog lp.
Hypothesis LOm : linkorder math_util.prog lp.
Hypothesis LOr : linkorder mario.prog lp.

(* THE TABLE IS SOUND on the real link: only the gtab entries (the consumer's
   own region table) and the world fact's meaning remain *)
Theorem air_xc_sound_link : forall nbase R0 gtab kv m0 uf gp rFI rMS rCL kW kH kS szS,
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  gfind gtab surface_collision._gFindFloorIncludeSurfaceIntangible = Some rFI ->
  gfind gtab surface_collision._gNumFindFloorMisses = Some rMS ->
  gfind gtab surface_collision._gNumCalls = Some rCL ->
  (forall vs, uf kW vs -> Wff (globalenv lp) m0 gp szS vs) ->
  (forall h yv, HPi (Hit_at (globalenv lp) m0) (ycast yv) h -> Hit_at (globalenv lp) m0 h ->
     uf kH [Some (Vsingle h); Some yv]) ->
  (forall vs, surf_on (globalenv lp) m0 vs -> uf kS vs) ->
  forall id k args g cps fd E m vargs t m' vres,
  air_xc nbase R0 rFI rMS rCL kW kH kS szS id = Some k -> k args g = Some cps ->
  sfun_lookup (globalenv lp) id = Some fd ->
  MMg (globalenv lp) nbase R0 gtab kv m0 uf gp E m g ->
  Forall2 (fun a v => den (globalenv lp) m0 E a = Some v /\ sok nbase (g_nx g) a) args vargs ->
  eval_funcall function_entry2 (globalenv lp) m fd vargs t m' vres ->
  exists c, In c cps /\ CM (globalenv lp) nbase R0 gtab kv m0 uf gp E (g_nx g) (g_loc g) m' vres c.
Proof.
  intros nbase R0 gtab kv m0 uf gp rFI rMS rCL kW kH kS szS Hgp HgFI HgMS HgCL HU HUH HUS.
  exact (air_xc_sound (globalenv lp) nbase R0 gtab kv m0 uf gp Hgp rFI rMS rCL kW kH kS szS
           (cenv_has_link lp LOs)
           (res_link lp _ _ _ LOs dm_ffl) (res_link lp _ _ _ LOs dm_fcl) (res_link lp _ _ _ LOs dm_wfl)
           (res_link lp _ _ _ LOm dm_al)
           (res_link lp _ _ _ LOs dm_ff) (res_link lp _ _ _ LOs dm_fc) (res_link lp _ _ _ LOs dm_wl)
           (res_link lp _ _ _ LOm dm_a2) (res_link lp _ _ _ LOr dm_ts) (res_link lp _ _ _ LOs dm_fw)
           HgFI HgMS HgCL HU HUH HUS).
Qed.

End LP.
