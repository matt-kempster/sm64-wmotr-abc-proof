#!/usr/bin/env bash
# discipline_check.sh -- "Did you actually prove it, and is it hooked in?"
#
# The mechanical half of proof discipline (see SKILL.md for the judgement half).
# Run it after ANY proof work and before claiming progress. It answers four
# questions that an LLM in la-la-land gets wrong:
#
#   1. BUILDS      -- does the tree actually compile? (a real check, not a claim)
#   2. NO admit    -- any Admitted/Axiom/sorry/Abort vernacular? (= you didn't prove it)
#   3. AXIOMS      -- does each goal capstone rest ONLY on the standard CompCert
#                     axioms (classical logic + CompCert's external-call model)?
#                     (Print Assumptions; a stray PROJECT axiom/admit = a hole)
#   4. HOOKED IN   -- structure check: nothing in the spine depends on Unwired/,
#                     and no orphan sits outside Unwired/ unmarked.
#
# It also PRINTS the residual-hypothesis surface (abstract `reach_*`/`*_avoids`
# Prop parameters that are ASSUMED, not proved) so you can see what is still
# disconnected from the real program -- the thing to discharge, not to pile onto.
#
# Usage (from repo root):
#   bash .claude/skills/proof-discipline/discipline_check.sh
#   bash .claude/skills/proof-discipline/discipline_check.sh SM64.Proofs.X.Y thm [More.Mod thm2 ...]
#
# Default target = the GOAL-1 capstone. Pass "Module.Path theorem" pairs to audit
# others (e.g. a new capstone you just wired in). Exit 0 = clean, 1 = a hole.
set -uo pipefail
cd "$(dirname "$0")/../../.." || exit 2
# shellcheck disable=SC1091
source pipeline/env.sh >/dev/null 2>&1 || true

# default capstone(s): "Module.Logical.Path theorem"
if [ "$#" -eq 0 ]; then
  set -- SM64.Proofs.NoAImpliesNoFly.NoAImpliesNoFlyLinked noA_no_spawn_never_flying_lp
fi

# The standard, sound axioms a CompCert proof of the REAL program legitimately
# rests on. TWO groups:
#   (a) classical logic + functional extensionality + proof irrelevance (Coq
#       stdlib / CompCert lib/Axioms.v). proof_irr surfaces the moment the
#       capstone touches Ctypes composite-env / linkorder metatheory (composite
#       records carry proof-irrelevant well-formedness proofs; field_offset_stable
#       and linkorder reasoning use it). It is a standard sound CompCert axiom,
#       used pervasively in CompCert's own memory model -- NOT a project Axiom.
#   (b) CompCert's abstract external-call model (common/Events.v Parameters/Axioms):
#       external_functions_sem/properties, inline_assembly_sem/properties. These
#       appear the moment the capstone references the REAL eval_funcall (the
#       clightgen'd frame can reach an external/builtin call), so they are a
#       TETHERING signal, not a hole -- every whole-program CompCert proof rests
#       on them. They are NOT project Axioms and NOT Admitted lemmas.
ALLOWED='Classical_Prop.classic
FunctionalExtensionality.functional_extensionality_dep
Axioms.proof_irr
ClassicalDedekindReals.sig_not_dec
ClassicalDedekindReals.sig_forall_dec
Events.external_functions_sem
Events.external_functions_properties
Events.inline_assembly_sem
Events.inline_assembly_properties'

fail=0
line() { printf '%s\n' "------------------------------------------------------------"; }

# 1. BUILDS ---------------------------------------------------------------
line; echo "[1/4] BUILD (does it actually compile?)"
if bash pipeline/build.sh proofs >/tmp/_disc_build.log 2>&1; then
  echo "  OK -- tree compiles."
else
  echo "  FAIL -- tree does not compile. Last lines:"; tail -5 /tmp/_disc_build.log | sed 's/^/    /'
  fail=1
fi

# 2. NO admit/axiom/sorry vernacular -------------------------------------
line; echo "[2/4] NO HOLES (Admitted / Axiom / sorry / Abort vernacular)"
holes=$(git grep -nE '^[[:space:]]*(Admitted|Axiom|Conjecture|Parameter|Abort)\b|\b(sorry|admit|give_up)\b' -- 'proofs/**/*.v' \
        | grep -vE ':[[:space:]]*\*|\(\*' || true)
if [ -z "$holes" ]; then
  echo "  OK -- no admit/axiom/sorry in the proof source."
else
  echo "  FAIL -- found incomplete-proof vernacular:"; echo "$holes" | sed 's/^/    /'
  fail=1
fi

# 3. AXIOMS of each capstone ---------------------------------------------
line; echo "[3/4] AXIOM FOOTPRINT (capstones rest only on the standard CompCert axioms)"
while [ "$#" -ge 2 ]; do
  mod="$1"; thm="$2"; shift 2
  out=$(bash pipeline/assumptions.sh "$mod" "$thm" 2>&1)
  if echo "$out" | grep -q 'Closed under the global context'; then
    echo "  OK  $mod.$thm -- closed (no axioms)."
    continue
  fi
  # parse only the region AFTER the "Axioms:" header (skip env.sh's banner);
  # axiom NAMES start at column 0 (the type wraps to indented lines)
  names=$(echo "$out" | awk '/^Axioms:/{f=1;next} f' | grep -E '^[A-Za-z_]' | sed -E 's/[[:space:]]*:.*//')
  bad=""
  while IFS= read -r n; do
    [ -z "$n" ] && continue
    echo "$ALLOWED" | grep -qxF "$n" || bad="$bad $n"
  done <<< "$names"
  if [ -z "$bad" ]; then
    echo "  OK  $mod.$thm -- only standard CompCert axioms (classical + external-call model)."
  else
    echo "  FAIL  $mod.$thm -- NON-STANDARD axiom(s):$bad"
    echo "        (a project Axiom or an Admitted lemma surfaces here -- it is a hole.)"
    fail=1
  fi
done

# 4. HOOKED IN (structure) -----------------------------------------------
line; echo "[4/4] HOOKED IN (firewall + no orphans)"
if python3 pipeline/check_unwired.py | sed 's/^/  /'; then :; else fail=1; fi

# INFO: residual-hypothesis surface (assumed, not proved -- the discharge targets)
line; echo "[info] RESIDUAL HYPOTHESES still ASSUMED (discharge these; don't pile onto them):"
git grep -nE 'Definition (reach_[a-z_]+|[a-z_]*(avoids|preserves)|[a-z_]*_ok) .*: Prop' -- 'proofs/**/*.v' \
  | sed 's/^/  /' || true
echo "  -> a lemma whose statement merely ASSUMES one of these (e.g. \`reach_body_avoids P ge ->\`)"
echo "     is NOT progress on the theorem until that hypothesis is itself proved for the REAL program."

line
if [ "$fail" -eq 0 ]; then
  echo "VERDICT: clean -- but clean is the FLOOR, not progress. This says the tree is"
  echo "hygienic and hooked in; it does NOT say the bottom line moved. Progress = a"
  echo "residual above proved for, or sharpened toward, the REAL program (tethering)."
  echo "See SKILL.md 'Did you advance the bottom line?'."
else
  echo "VERDICT: FAIL -- fix the holes above before claiming the proof advanced."
fi
exit "$fail"
