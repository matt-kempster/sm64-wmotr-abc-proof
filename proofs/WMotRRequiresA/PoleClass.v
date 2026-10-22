(* ====================================================================== *)
(* PoleClass (GOAL 2): each outcome of a walk of the real act_grab_pole_   *)
(* slow / _fast is ONE HeightMoveCatalog S_attach of Phi's cells, to the   *)
(* low pole's window (pos[1] <= top + POLE_UP = -1759).                    *)
(*                                                                        *)
(* set_pole_position (mario_actions_automatic.c) puts pos[1] at           *)
(*   Y0 = usedObj->oPosY + oMarioPolePos + 0    (polePos clamped to 720), *)
(*   then C - 160 when a ceiling C is below Y0 + 160,                     *)
(*   then the floor F when F is above that (ACT_IDLE),                    *)
(*   or the pole base -2739 when polePos < 0 (ACT_FREEFALL).              *)
(* pole_ok checks, on an outcome, that pos[1] is one of these terms with  *)
(* the path facts that bound it (posb), that gfx.pos[1] = pos[1], vel[1]  *)
(* and floorHeight are the entry's, the action is one set_pole_position / *)
(* the handler can set, and, in a pole action, that usedObj and the pole  *)
(* are untouched and oMarioPolePos stays a finite float >= -1000 (ppb).   *)
(* pole_sound turns it into read_cells + a RangedMove + those facts.      *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Cop Clight.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import FloorHeight AirMatch FfClass WMotRWorld.
Import ListNotations.

Definition tfl : type := Tfloat Ctypes.F32 noattr.
Definition f32i (z : Z) : float32 := Float32.of_int (Int.repr z).
Definition fsc (k : float32) : sval := Sconst (Vsingle k).

(* a finite float constant within [lo, hi] *)
Definition fin_in (k : float32) (lo hi : Z) : bool :=
  Binary.is_finite 24 128 k && Float32.cmp Cge k (f32i lo) && Float32.cmp Cle k (f32i hi).
Definition cfin (s : sval) (lo hi : Z) : bool :=
  match s with Sconst (Vsingle k) => fin_in k lo hi | _ => false end.
Definition is_pz (s : sval) : bool :=
  match s with Sconst (Vsingle k) => Float32.cmp Ceq k Float32.zero | _ => false end.

Definition POLE_ACTS3 : list Z := [1049409; 1049410; 135267136].
(* the actions an outcome may end in: the two grabs, HOLDING_POLE, and
   set_pole_position's ACT_IDLE / ACT_FREEFALL / ACT_SOFT_BONK *)
Definition POLE_OUT : list Z := POLE_ACTS3 ++ [205521409; 16779404; 16910518].

Section CLS.
Variables (nbase : positive) (R0 : list (positive * Z)) (kv : list (positive * Z * memory_chunk * sval)).
Variables (rM rO rU kP kC kH kL : positive).
Local Notation ic := (init_cell kv).

(* Mario's oMarioPolePos at the entry *)
Definition sP : sval := ic rO POLEPOS_OFF Mfloat32.

Definition hasf (pc : list fact) (f : fact) : bool := existsb (fbeq f) pc.

(* the fact "!(P > k)", k a constant <= 720 *)
Definition le720 (pc : list fact) : bool :=
  existsb (fun f => match f with
    | Fbool (Sbinop Ogt a t1 k t2) ty false =>
        sveqb a sP && is_tf t1 && is_tf t2 && cfin k (-100000) 720 && tyeqb ty ti32
    | _ => false end) pc.

(* tight: in [-3741, -2018] *)
Definition tb (pc : list fact) (s : sval) : bool :=
  cfin s (-3741) (-2018)
  || match s with
     | Sbinop Oadd (Sbinop Oadd ka t1 a t2) t3 kz t4 =>
         cfin ka (-2739) (-2739) && sveqb a sP && is_pz kz
         && is_tf t1 && is_tf t2 && is_tf t3 && is_tf t4
         && hasf pc (Fuser kP [sP]) && le720 pc
     | _ => false
     end.

(* vec3f_find_ceil's search height pos[1] + 80.0f, as the walker builds it
   (SymExec2.mk_bin folds a constant pos[1]) *)
Definition f80 : float32 := Float32.of_bits (Int.repr 1117782016).   (* 80.0f *)
Definition plus80 (y : sval) : sval :=
  match y with
  | Sconst (Vsingle a) => Sconst (Vsingle (Float32.add a f80))
  | _ => Sbinop Oadd y tfl (Sconst (Vsingle f80)) tfl
  end.

(* below a ceiling: C - 160 < Y (tight), C passed find_ceil's test at Y + 80 *)
Definition cb (pc : list fact) (s : sval) : bool :=
  match s with
  | Sbinop Osub c t1 k160 t2 =>
      is_tf t1 && is_tf t2 && cfin k160 160 160
      && existsb (fun f => match f with
           | Fbool (Sbinop Ogt y t3 x t4) ty true =>
               sveqb x s && is_tf t3 && is_tf t4 && tyeqb ty ti32 && tb pc y
               && hasf pc (Fuser kC [c; plus80 y])
           | _ => false end) pc
  | _ => false
  end.

(* a floor above Y (tight or below a ceiling), found by find_floor at Y *)
Definition db (pc : list fact) (s : sval) : bool :=
  existsb (fun f => match f with
    | Fbool (Sbinop Olt y t1 x t2) ty true =>
        sveqb x s && is_tf t1 && is_tf t2 && tyeqb ty ti32 && (tb pc y || cb pc y)
        && (hasf pc (Fuser kH [s; y]) || hasf pc (Fuser kL [s; y]))
    | _ => false end) pc.

Definition posb (pc : list fact) (s : sval) : bool :=
  cfin s (-11000) (-1759) || tb pc s || cb pc s || db pc s.

(* oMarioPolePos after the frame: the entry's, a constant >= -1000, or
   (C - 160) - oPosY with the fact !(that < 0) *)
Definition ppb (pc : list fact) (s : sval) : bool :=
  (sveqb s sP && hasf pc (Fuser kP [sP]))
  || cfin s (-1000) 100000
  || match s with
     | Sbinop Osub x t1 k t2 =>
         is_tf t1 && is_tf t2 && cfin k (-2739) (-2739) && cb pc x
         && existsb (fun f => match f with
              | Fbool (Sbinop Olt a t3 z t4) ty false =>
                  sveqb a s && is_tf t3 && is_tf t4 && is_pz z && tyeqb ty ti32
              | _ => false end) pc
     | _ => false
     end.

Definition zin (z : Z) (l : list Z) : bool := existsb (Z.eqb z) l.

Definition pole_ok (g : gst) : bool :=
  let LD := sload nbase R0 kv g in
  match LD rM oMO Mint32, LD rM oA Mint32, LD rM oS Mint16unsigned, LD rM oT Mint16unsigned,
        LD rM oY Mfloat32, LD rM oV Mfloat32, LD rM oF Mfloat32, LD rO oG Mfloat32 with
  | Some (Sptr r0 z0), Some (Sconst (Vint a)), Some ss, Some st, Some sy, Some sv, Some sf, Some sg =>
      Pos.eqb r0 rO && Ptrofs.eq z0 Ptrofs.zero
      && zin (Int.unsigned a) POLE_OUT
      && int_sv (ic rM oS Mint16unsigned) ss && int_sv (ic rM oT Mint16unsigned) st
      && sveqb sv (ic rM oV Mfloat32) && sveqb sf (ic rM oF Mfloat32) && sveqb sg sy
      && posb (g_pc g) sy
      && (negb (zin (Int.unsigned a) POLE_ACTS3)
          || (match LD rM USED_OFF Mint32 with
              | Some u => sveqb u (ic rM USED_OFF Mint32) | None => false end
              && match LD rU O_POSY Mfloat32, LD rU HITBOX_DOWN_OFF Mfloat32, LD rU HITBOX_H_OFF Mfloat32 with
                 | Some a1, Some a2, Some a3 =>
                     sveqb a1 (ic rU O_POSY Mfloat32) && sveqb a2 (ic rU HITBOX_DOWN_OFF Mfloat32)
                     && sveqb a3 (ic rU HITBOX_H_OFF Mfloat32)
                 | _, _, _ => false end
              && match LD rO POLEPOS_OFF Mfloat32 with
                 | Some p => ppb (g_pc g) p | None => false end))
  | _, _, _, _, _, _, _, _ => false
  end.
End CLS.
