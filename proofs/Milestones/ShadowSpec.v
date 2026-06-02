(* ShadowSpec.v -- a "real world" functional-correctness theorem about an actual
 * SM64 function, proved against CompCert's Clight execution semantics.
 *
 * Target: dim_shadow_with_distance (vendor/sm64/src/game/shadow.c). Its job is to
 * fade a shadow as its object rises off the ground -- BUT the function's first
 * branch is `if (solidity < 121) return solidity;`. So a faint shadow (solidity
 * below 121) is returned completely unchanged, no matter the distance.
 *
 * We prove exactly that, semantically: running the generated f_dim_shadow_with_distance
 * on any solidity < 121 (and ANY distance) yields that same solidity and does not
 * touch memory. No float reasoning is needed -- the low-solidity path never
 * evaluates the float arithmetic.
 *
 * clightgen renders the parameters as temporaries (Etempvar), so the faithful
 * entry semantics here is function_entry2 (params bound in the temp env, fn_vars
 * empty => no stack allocation, no free_list work).
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep.
From compcert Require Archi.
From SM64.Generated Require Import shadow.

(* Archi.ptr64 is `Definition ptr64 := true` but marked Global Opaque, which stops
   cbn/unfold from reducing the classify_cast branches that switch on it. Opacity
   is only a reduction hint, so we re-enable reduction locally. *)
Local Transparent Archi.ptr64.

(* Inverting eval_expr of an rvalue (Ebinop/Etempvar/Econst_int) leaves a spurious
   eval_Elvalue case carrying eval_lvalue of that same (non-lvalue) expression,
   which has no constructor. This discharges every such dead goal. *)
Ltac kill_lvalue :=
  try (match goal with Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [inv Hlv] end).

Theorem dim_shadow_low_solidity_returns_solidity :
  forall ge m t m' vres i d,
    (* solidity is a genuine u8 ... *)
    Int.zero_ext 8 i = i ->
    (* ... and below the 121 dimming threshold. *)
    Int.lt i (Int.repr 121) = true ->
    eval_funcall function_entry2 ge m (Internal f_dim_shadow_with_distance)
      (Vint i :: d :: nil) t m' vres ->
    vres = Vint i /\ m' = m.
Proof.
  intros ge m t m' vres i d Hu8 Hlt Heval.
  inv Heval.
  (* function_entry2: fn_vars = nil => empty env, memory unchanged; bind temps. *)
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ => simpl in Hav; inv Hav end.
  (* Compute the temp env: solidity |-> Vint i. *)
  match goal with Hbp : bind_parameter_temps _ _ _ = Some _ |- _ =>
    simpl in Hbp; inv Hbp end.
  (* The body is the nested Sifthenelse; the outer condition is solidity < 121. *)
  match goal with Hexec : exec_stmt _ _ _ _ _ (fn_body f_dim_shadow_with_distance) _ _ _ _ |- _ =>
    simpl fn_body in Hexec; inv Hexec end.
  (* exec_Sifthenelse gave us: eval_expr cond v1, bool_val v1 = Some b, exec branch b.
     Pin v1 = Vtrue from i < 121, forcing the then-branch. *)
  match goal with He : eval_expr _ _ _ _ (Ebinop _ _ _ _) ?v1 |- _ => inv He end.
  (* operands: Etempvar _solidity -> Vint i ; Econst_int 121 -> Vint 121 *)
  repeat match goal with
  | He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv He
  | He : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv He
  end.
  all: kill_lvalue.
  (* le ! _solidity computes to Vint i (gso past _distFromFloor, then gss). *)
  match goal with Hte : (_ ! _solidity) = Some _ |- _ =>
    rewrite PTree.gso in Hte by discriminate; rewrite PTree.gss in Hte; inv Hte end.
  (* Force the condition value v1 = Vtrue from i < 121. With Archi.ptr64 reducible,
     the casts (tuchar/tint -> int) compute to Vint i / Vint 121 and the comparison
     becomes Int.lt i (Int.repr 121), which Hlt makes true. *)
  match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some ?v |- _ =>
    assert (v = Vtrue) by
      (revert Hsem;
       unfold sem_binary_operation, sem_cmp, sem_binarith, sem_cast; cbn;
       rewrite Hlt; intro HH; inv HH; reflexivity);
    subst end.
  (* bool_val Vtrue tint = Some true (vm_compute: cbn leaves Int.eq stuck). *)
  match goal with Hbool : bool_val _ _ _ = Some _ |- _ => vm_compute in Hbool; inv Hbool end.
  (* The taken branch is now `if true then Sreturn(solidity) else ...`; reduce
     to the Sreturn and invert. *)
  match goal with Hexec : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => cbn in Hexec; inv Hexec end.
  match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv He end.
  all: kill_lvalue.
  match goal with Hte : (_ ! _solidity) = Some _ |- _ =>
    rewrite PTree.gso in Hte by discriminate; rewrite PTree.gss in Hte; inv Hte end.
  (* outcome_result_value: sem_cast (Vint i) tuchar tuchar = Some (Vint (zero_ext 8 i)). *)
  match goal with Hout : outcome_result_value _ _ _ _ |- _ =>
    cbn in Hout; destruct Hout as [_ Hcast];
    unfold sem_cast in Hcast; cbn in Hcast; inv Hcast end.
  (* free_list over the empty env is the identity. *)
  match goal with Hfree : Mem.free_list _ _ = Some _ |- _ => cbn in Hfree; inv Hfree end.
  rewrite Hu8. split; reflexivity.
Qed.
