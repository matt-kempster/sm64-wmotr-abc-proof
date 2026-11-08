(* ======================================================================= *)
(* FieldWin.v -- the object fields no invariant reads (GOAL 2 objects,      *)
(* 2026-11-08).                                                             *)
(*                                                                          *)
(* The script commands' field stores (BhvStep's ghost keeps) write, at the  *)
(* reachable words (vm census, FieldWinCensus.win_fields_value), these    *)
(* rawData fields (byte offset 136 + 4 f):                                 *)
(*   1, 3, 10, 12, 16, 18-23, 26, 28-29, 38, 40-41, 47, 52, 55-59, 61, 67 *)
(* plus fields obj_w / PhiW DO read (5, 6-8, 27, 42; the hitbox).  ucl off *)
(* e: the bytes [off, e) of an object miss the windows of the first list.  *)
(* The objects phase's frames (ObjWorld.ccl for obj_w, RenderKeep.ccl_at   *)
(* for PhiW) exclude them, so a store into them is invisible to both --    *)
(* and the frames' own proofs check that no clause reads them (a clause    *)
(* reading a window field would not prove).                                *)
(* ======================================================================= *)
From Coq Require Import ZArith Lia List.
From SM64.Proofs.WMotRRequiresA Require FieldWinCensus.
Local Open Scope Z_scope.

Definition ucl (off e : Z) : Prop :=
  (e <= 140 \/ 144 <= off) /\ (e <= 148 \/ 152 <= off) /\ (e <= 176 \/ 180 <= off)
  /\ (e <= 184 \/ 188 <= off) /\ (e <= 200 \/ 204 <= off) /\ (e <= 208 \/ 232 <= off)
  /\ (e <= 240 \/ 244 <= off) /\ (e <= 248 \/ 256 <= off) /\ (e <= 288 \/ 292 <= off)
  /\ (e <= 296 \/ 304 <= off) /\ (e <= 324 \/ 328 <= off) /\ (e <= 344 \/ 348 <= off)
  /\ (e <= 356 \/ 376 <= off) /\ (e <= 380 \/ 384 <= off) /\ (e <= 404 \/ 408 <= off).

(* the windows, as a list (start, end) *)
Definition UWIN : list (Z * Z) :=
  ((140, 144) :: (148, 152) :: (176, 180) :: (184, 188) :: (200, 204) :: (208, 232) :: (240, 244)
   :: (248, 256) :: (288, 292) :: (296, 304) :: (324, 328) :: (344, 348) :: (356, 376) :: (380, 384)
   :: (404, 408) :: nil)%list.

Lemma ucl_eq : forall a b a' b', a = a' -> b = b' -> ucl a b -> ucl a' b'.
Proof. intros a b a' b' -> ->. exact (fun H => H). Qed.

(* bytes outside the rawData windows' span *)
Lemma ucl_lo : forall off e, e <= 140 -> ucl off e.
Proof. intros off e H. unfold ucl. lia. Qed.
Lemma ucl_hi : forall off e, 408 <= off -> ucl off e.
Proof. intros off e H. unfold ucl. lia. Qed.

(* a store inside a window misses every ucl range *)
Lemma ucl_gen : forall d n off e z0 s, (e <= d \/ n <= off) -> d <= z0 -> z0 + s <= n -> 0 <= s ->
  e <= z0 \/ z0 + s <= off.
Proof. intros. lia. Qed.

Lemma ucl_disj : forall d n off e, List.In (d, n) UWIN -> ucl off e ->
  forall z0 s, d <= z0 -> z0 + s <= n -> 0 <= s -> e <= z0 \/ z0 + s <= off.
Proof.
  intros d n off e Hin U z0 s A B C.
  destruct U as (U1 & U2 & U3 & U4 & U5 & U6 & U7 & U8 & U9 & U10 & U11 & U12 & U13 & U14 & U15).
  unfold UWIN in Hin. cbn in Hin.
  repeat (destruct Hin as [Hin | Hin];
    [ injection Hin as <- <-;
      first [ exact (ucl_gen _ _ _ _ _ _ U1 A B C) | exact (ucl_gen _ _ _ _ _ _ U2 A B C)
            | exact (ucl_gen _ _ _ _ _ _ U3 A B C) | exact (ucl_gen _ _ _ _ _ _ U4 A B C)
            | exact (ucl_gen _ _ _ _ _ _ U5 A B C) | exact (ucl_gen _ _ _ _ _ _ U6 A B C)
            | exact (ucl_gen _ _ _ _ _ _ U7 A B C) | exact (ucl_gen _ _ _ _ _ _ U8 A B C)
            | exact (ucl_gen _ _ _ _ _ _ U9 A B C) | exact (ucl_gen _ _ _ _ _ _ U10 A B C)
            | exact (ucl_gen _ _ _ _ _ _ U11 A B C) | exact (ucl_gen _ _ _ _ _ _ U12 A B C)
            | exact (ucl_gen _ _ _ _ _ _ U13 A B C) | exact (ucl_gen _ _ _ _ _ _ U14 A B C)
            | exact (ucl_gen _ _ _ _ _ _ U15 A B C) ] | ]).
  destruct Hin.
Qed.

(* ucl is exactly "misses every UWIN window" *)
Lemma ucl_uwin : forall off e, ucl off e <-> List.Forall (fun p => e <= fst p \/ snd p <= off) UWIN.
Proof.
  intros off e. unfold ucl, UWIN. rewrite !List.Forall_cons_iff. cbn [fst snd]. split.
  - intros (A1&A2&A3&A4&A5&A6&A7&A8&A9&A10&A11&A12&A13&A14&A15).
    repeat split; try assumption. constructor.
  - intros (A1&A2&A3&A4&A5&A6&A7&A8&A9&A10&A11&A12&A13&A14&A15&_). repeat split; assumption.
Qed.

(* the windows' bytes are exactly the census's window fields' bytes *)
Definition uwin_bytes : list Z :=
  List.flat_map (fun p => List.map (fun i => fst p + Z.of_nat i) (List.seq 0 (Z.to_nat (snd p - fst p)))) UWIN.
Definition field_bytes (l : list Z) : list Z :=
  List.flat_map (fun f => (136 + 4 * f :: 137 + 4 * f :: 138 + 4 * f :: 139 + 4 * f :: nil)%list) l.
Lemma uwin_census : uwin_bytes = field_bytes FieldWinCensus.win_fields.
Proof. rewrite FieldWinCensus.win_fields_value. vm_compute. reflexivity. Qed.
