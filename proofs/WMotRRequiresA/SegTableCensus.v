(* spine-root: GOAL 1/2 frame -- the census behind the set_segment_base_addr
   identity shim (pipeline/proof_n64.h, TRUST 2.2, approved 2026-11-02). *)
(* ====================================================================== *)
(* WHO READS sSegmentTable?                                                *)
(*                                                                        *)
(* The ROM's set_segment_base_addr stores `(uintptr_t) addr & 0x1FFFFFFF` *)
(* (memory.c:69): stuck on a pointer in CompCert, so select_gfx_pool      *)
(* (every frame) had no execution (FOUND 2026-11-02).  The proof's body   *)
(* stores the address unmasked.  That changes only the table's cells.     *)
(* This file shows, on the generated code of the whole link, where those *)
(* cells can go:                                                          *)
(*  (1) the functions naming sSegmentTable are exactly the setter (proof  *)
(*      and renamed ROM body), get_segment_base_addr,                     *)
(*      move_segment_table_to_dmem and the renamed ROM                    *)
(*      segmented_to_virtual / virtual_to_segmented (seg_readers);        *)
(*  (2) get_segment_base_addr and the ROM segmented_to_virtual /         *)
(*      virtual_to_segmented are never called and their address is never *)
(*      taken (seg_dead);                                                 *)
(*  (3) every call of either setter (the renamed ROM body is still called *)
(*      by memory.c's own load_segment*, boot / level load) discards its  *)
(*      result (setter_results_discarded).                                *)
(* So a table cell is read only by move_segment_table_to_dmem, which      *)
(* writes it into gSPSegment display-list words for the RSP (memory.c:95, *)
(* called by init_rcp only): no game-state value depends on the mask.     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Maps AST Integers Ctypes Clight.
From SM64.Generated Require memory game_init.
From SM64.Proofs.WMotRRequiresA Require Import ObjTable RoCensus ActWriterCensus.
Import ListNotations.

Definition seg_expected : list ident :=
  [memory._set_segment_base_addr; memory._rom_set_segment_base_addr;
   memory._get_segment_base_addr; memory._move_segment_table_to_dmem;
   memory._rom_segmented_to_virtual; memory._rom_virtual_to_segmented].

Definition same_set (a b : list ident) : bool :=
  forallb (fun x => memi x b) a && forallb (fun x => memi x a) b.

(* (1) *)
Lemma seg_readers : same_set (readers memory._sSegmentTable) seg_expected = true.
Proof. vm_compute. reflexivity. Qed.

Definition dead_fns : list ident :=
  [memory._get_segment_base_addr;
   memory._rom_segmented_to_virtual; memory._rom_virtual_to_segmented].

(* (2) no direct call anywhere in the link, address never taken *)
Lemma seg_dead :
  forallb (fun g => forallb (fun '(_, _, f) => Nat.eqb (List.length (calls_to g (fn_body f))) 0) all_fns
                    && negb (memi g addr_taken)) dead_fns = true.
Proof. vm_compute. reflexivity. Qed.

(* the result slot of every direct call of g *)
Fixpoint call_rets (g : ident) (s : statement) : list (option ident) :=
  match s with
  | Scall o (Evar h _) _ => if Pos.eqb g h then [o] else nil
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => call_rets g s1 ++ call_rets g s2
  | Slabel _ s1 => call_rets g s1
  | Sswitch _ sl => call_rets_ls g sl
  | _ => nil
  end
with call_rets_ls (g : ident) (sl : labeled_statements) : list (option ident) :=
  match sl with LSnil => nil | LScons _ s sl' => call_rets g s ++ call_rets_ls g sl' end.

(* (3) *)
Lemma setter_results_discarded :
  forallb (fun g => forallb (fun '(_, _, f) => forallb (fun o => match o with None => true | Some _ => false end)
                               (call_rets g (fn_body f))) all_fns)
    [memory._set_segment_base_addr; memory._rom_set_segment_base_addr] = true
  /\ negb (memi memory._set_segment_base_addr addr_taken) = true
  /\ List.length (flat_map (fun '(_, _, f) => call_rets memory._set_segment_base_addr (fn_body f)) all_fns)
     <> 0%nat.
Proof. vm_compute. split; [ reflexivity | split; [ reflexivity | discriminate ] ]. Qed.
