(* ======================================================================= *)
(* FieldWinCensus.v -- which rawData fields the reachable script commands  *)
(* write (GOAL 2 objects, 2026-11-08).                                      *)
(*                                                                          *)
(* A vm census over BhvVM.vm_tab (every reachable behavior-script word of  *)
(* the real WMotR closure, read from the generated ROM data):              *)
(*  - vm_written: the fields the byte2-addressed commands write            *)
(*    (BhvVM.fields_of: SET/ADD/OR/... FLOAT/INT, SUM_*, ...), pinned;      *)
(*  - vm_ops: the reachable opcodes, pinned -- they include the two        *)
(*    fixed-field handlers SET_HOME (0x2D: fields 55-57) and               *)
(*    SET_OBJ_PHYSICS (0x30: fields 23, 40, 41, 52, 58, 59), whose field   *)
(*    sets are read off their generated handler bodies (behavior_script.c) *)
(*    and checked by the keep proofs;                                       *)
(*  - win_fields: the written fields minus the six the invariant READS     *)
(*    (5, 6-8 = pos, 27, 42: obj_w's clauses read them);                *)
(*    pinned.  FieldWin.uwin_census shows FieldWin's windows are exactly   *)
(*    these fields' bytes -- the frames' window list is not a hand list.   *)
(* A read field wrongly put in win_fields would make the frame proofs      *)
(* (ObjWorld.ccl / RenderKeep.ccl_at clauses) fail, so soundness is        *)
(* checked by Coq; the census pins exactness (no window is unwritten).     *)
(* ======================================================================= *)
From Coq Require Import ZArith List Bool.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM.
Import ListNotations.
Local Open Scope Z_scope.

(* sorted, duplicate-free insertion *)
Fixpoint zins (x : Z) (l : list Z) : list Z :=
  match l with
  | nil => [x]
  | y :: r => if x <? y then x :: l else if x =? y then l else y :: zins x r
  end.
Definition zset (l : list Z) : list Z := fold_right zins nil l.

Definition vm_written : list Z := zset (flat_map fields_of vm_tab).
Lemma vm_written_value :
  vm_written = [1; 3; 5; 6; 7; 8; 10; 12; 16; 18; 19; 20; 21; 22; 26; 27; 28; 29; 38; 42; 47; 61; 67].
Proof. vm_compute. reflexivity. Qed.

Definition vm_ops : list Z := zset (map opc vm_tab).
Lemma vm_ops_value :
  vm_ops = [0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 12; 13; 14; 15; 16; 17; 19; 20; 21;
            28; 29; 30; 31; 33; 35; 37; 39; 40; 42; 43; 45; 47; 48; 50; 51; 52; 53; 55].
Proof. vm_compute. reflexivity. Qed.

(* SET_HOME (0x2D = 45) and SET_OBJ_PHYSICS (0x30 = 48) are reachable *)
Lemma fixed_ops_reached : In 45 vm_ops /\ In 48 vm_ops.
Proof. rewrite vm_ops_value. cbn. split; tauto. Qed.

Definition fixed_written : list Z := [55; 56; 57; 23; 40; 41; 52; 58; 59].
Definition read_fields : list Z := [5; 6; 7; 8; 27; 42].

Definition win_fields : list Z :=
  filter (fun f => negb (existsb (Z.eqb f) read_fields)) (zset (vm_written ++ fixed_written)).
Lemma win_fields_value :
  win_fields = [1; 3; 10; 12; 16; 18; 19; 20; 21; 22; 23; 26; 28; 29; 38; 40; 41; 47; 52;
                55; 56; 57; 58; 59; 61; 67].
Proof. unfold win_fields. rewrite vm_written_value. vm_compute. reflexivity. Qed.
