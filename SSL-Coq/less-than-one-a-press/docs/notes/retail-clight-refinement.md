# Retail Clight refinement status

This note records the current boundary between the source-owned cleaned Clight
programs and a semantics-preserving US/JP retail model. It does not claim that
the gameplay theorem, or even the complete cleaned-to-retail simulation, is
finished.

## What is now formalized

`USWholeASTTagRepair.v` defines a recursive US viewport-tag rewrite over every
Clight type position in expressions, statements, labeled statements, function
parameters, locals, temporaries, bodies, external declarations, global-variable
types, continuations, and all three Clight state constructors. Global identifiers,
initializer data, calling conventions, and control-flow constructors are not
changed. The fresh-tag and local layout certificates remain the source of the
layout facts. The repaired program construction and its execution simulation
are still obligations; defining the transformer is not a simulation proof.

`ClightGlobalMemoryRefinement.v` proves concrete US and JP membership agreement
for every strong source definition retained by the selector: internal function
bodies and definitive initialized globals occur verbatim in the corresponding
official cleaned link. Weak external declarations and tentative variables are
not falsely required to be literally equal. The file also proves:

- ordered global-definition equality implies pointwise `prog_defmap` equality;
- an actual CompCert `match_program_gen` witness gives identical initialized
  memories, with `Genv.initmem_inject` covering every initializer store,
  including `Init_addrof` relocations;
- any current `Mem.inject` transports a concrete loaded initializer or later
  pointer value to the mapped target block.

The exact US and JP normalized-to-official definition/public-name/initial-memory
records are named obligations. They are not inhabited yet because the official
cleaned links reorder and select declarations, so the simple ordered-program
lemma cannot be applied without a separate name-based initialization proof.

`ClightEndToEndRefinement.v` supplies the reusable state-simulation spine:

- injected local and temporary environments;
- a recursive continuation relation, including saved `Kcall` frames;
- a relation for `State`, `Callstate`, and `Returnstate`;
- injection-growth closure;
- mapped pointer loads, stores, and validity;
- injected `deref_loc` for value, reference, copy, and bitfield accesses;
- CompCert injection lemmas for unary operations, binary operations, and casts;
- a four-field lockstep component record and proofs that it yields a Clight
  forward simulation and transports initial-to-final executions.

This composes a completed simulation; it does not manufacture the missing
US/JP expression induction or internal-step proof.

`RetailExternalFrames.v` names the concrete writable state footprint for each
version: `gMarioStates`, `gObjectPool`, `gMarioObject`, `gControllers`, and
`gPlayer1Controller`. Recognized `EF_builtin` and `EF_runtime` calls preserve
the entire memory and therefore this footprint. CompCert leaves `EF_external`
semantics abstract, so per-external frames for that footprint remain explicit
US/JP obligations.

## Still required for end-to-end retail refinement

1. Prove the repaired US `make_program` result and the whole-expression,
   lvalue, argument-list, environment, continuation, and internal-step
   simulation for the viewport-tag rewrite.
2. Prove exact public-name agreement and a name-based initialized-memory
   injection for the concrete US and JP cleaned links, including allocation
   order and relocation pointer contents.
3. Maintain the current-memory injection through every internal allocation,
   free, store, and external step.
4. Prove reachable `EF_external` contracts for the concrete Mario/object/
   controller footprint, or import/replace those bodies with justified
   semantics.
5. Instantiate the lockstep component record for US and JP and connect its
   final Clight memories to the project's retail game-state projection.

Until all five items are discharged, the project has a sound compositional
refinement framework, not an end-to-end cleaned-execution-to-retail theorem.
