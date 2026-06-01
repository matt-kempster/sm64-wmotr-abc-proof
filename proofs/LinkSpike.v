(* LinkSpike.v -- DE-RISKING EXPERIMENT, RESULT RECORDED. *** DO NOT add to
 * _CoqProject and DO NOT `vm_compute` the link below: it OOMs the machine. ***
 *
 * THE QUESTION (asked 2026-05-31). The real per-frame Mario update is
 * interprocedural across translation units and CYCLIC: execute_mario_action
 * (mario.c) -> mario_execute_<group>_action (mario_actions_*.c) -> act_xxx
 * (same group TU) -> set_mario_action (mario.c). In each clightgen'd TU the other
 * TU's functions are `External`, so the true frame only makes sense in the LINKED
 * program. The plan to "instantiate step with the real loop" rested on:
 *
 *     does CompCert `link` GO THROUGH on two full ~12k/16k-line clightgen'd SM64
 *     TUs, and can we resolve a cross-TU call in the linked genv?
 *
 * THE RESULT: *** computing the link is INTRACTABLE on this hardware. ***
 * `Eval vm_compute`/`vm_compute; reflexivity` over `link mario.prog
 * mario_actions_airborne.prog` exhausted memory and OOM-restarted the machine.
 * Forcing the merged whole-program AST (thousands of globdefs + composite merge +
 * link_prog_check over every shared symbol) into normal form is the killer -- NOT
 * linking as a concept. So: never normalize a real whole-program link.
 *
 * THE PIVOT (architecture decision). Two OOM-FREE ways to get cross-TU frame
 * reasoning, both of which AVOID computing any linked program:
 *
 *  (B) Compositional step (no linking). Prove each group executor preserves
 *      action_sat IN ITS OWN single-TU genv (via
 *      ActionValueFrame.exec_stmt_value_preserves -- already built, no link, no
 *      vm_compute). Define the frame `step` as "some group executor ran"; the
 *      dispatcher's switch routing becomes a named faithfulness hypothesis. Trust
 *      cost: execute_mario_action's switch logic is assumed, not executed.
 *
 *  (S) Symbolic linking (lean on CompCert metatheory, never compute). Parameterize
 *      over an ABSTRACT linked program `lp` with `link mario.prog ... = Some lp` as
 *      a HYPOTHESIS (a Variable + a hypothesis, so `lp` is never normalized). Derive
 *      cross-TU find_symbol/find_funct resolution from CompCert's `link_linkorder`
 *      + the linkorder def-preservation lemmas. More faithful than (B) (the real
 *      dispatcher runs), and still OOM-free because the giant term is opaque.
 *
 * Both defer the same underlying fact -- cross-TU call transfer -- to a hypothesis;
 * (S) discharges it from CompCert's linking theory, (B) from a hand-stated
 * dispatcher spec. Neither ever calls `vm_compute` on a real linked program.
 *
 * This file is kept ONLY as the record of the negative result. It defines nothing
 * and is not built. See docs/r3-action-value-plan.md and memory milestone-status.
 *)
