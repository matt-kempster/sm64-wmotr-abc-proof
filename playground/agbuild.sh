#!/bin/bash
# locked full build (agent wrapper; not committed)
SP=/tmp/claude-1000/-home-matt-git-sm64-wmotr-abc-proof/f0124733-2e75-4dab-ad6d-167a032f749d/scratchpad
cd /home/matt/git/sm64-wmotr-abc-proof/.claude/worktrees/agent-ac22c1b002eed319f || exit 9
flock "$SP/build.lock" timeout 14400 env SM64_VO_CACHE=/home/matt/.cache/sm64-vo bash pipeline/build.sh -j4 proofs > "$SP/build_$1.log" 2>&1
rc=$?
echo "RC=$rc" >> "$SP/build_$1.log"
echo "RC=$rc"
