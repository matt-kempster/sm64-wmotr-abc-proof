# Daybreak eligibility and an offline TAS research method

Research date: 22 October 2026. This is a product-guidance and methodology
note for SSL/pyramid, not a proof result, gameplay experiment, eligibility
decision by OpenAI, or change to any route estimate.

## What the published program establishes

OpenAI's [Models and Trusted Access](https://learn.chatgpt.com/docs/cyber-safety)
describes Daybreak Blue as reduced-refusal access for approved defensive
workflows. It places controlled exploit validation and more advanced research
under separately approved Daybreak Red access. Approval depends on the actual
identity, workspace/project, model and product surface. Neither tier disables
all safeguards. The [Responses API guide](https://developers.openai.com/api/docs/guides/daybreak)
also makes clear that selecting an access-program parameter does not grant
access or guarantee that every request succeeds.

The sources checked do not provide a TAS/ABC-specific eligibility ruling.
Therefore **Blue eligibility for a project whose purpose is preserving and
using in-game ACE is unconfirmed**; the public defensive remit is insufficient
to assume approval. Red is closer to the requested technical capability, but
its separate approval is not evidence that speedrunning qualifies either.
This is our interpretation of the documentation, not an OpenAI decision.

Preserving a game glitch for a local speedrun is not inherently malicious,
and a researcher need not pretend to intend remediation. Program eligibility,
whether an individual request is permitted, and whether a particular model
will complete it are distinct questions. Describe the real objective rather
than relabeling exploit development as patching. A scope inquiry to OpenAI
could state: "Offline SM64 TAS research on a lawfully available local game
copy; controller-reachable in-game memory corruption/ACE for the ABC
challenge; no emulator escape or external targets; no intent to patch the
game. Does this purpose qualify for Blue, require Red, or fall outside the
program?" This note does not send that inquiry or apply for access.

For suspected false positives, the official guidance recommends reporting
Codex blocks through `/feedback` where available. The [API cybersecurity
checks guide](https://developers.openai.com/api/docs/guides/safety-checks/cybersecurity)
provides the access-appeal route. Do not conceal the target, split a blocked
request to defeat safeguards, or treat a model's refusal as proof that the
research itself is illegitimate.

## What normal models and conventional tools can contribute

The following is a proposed contained research workflow, subject to ordinary
request-level safeguards. It is not a claim that a specific ACE chain has been
found or that every future exploit-development request will be accepted.

1. Pin the original ROM hash, region, emulator/core version, accepted start
   state and A-button budget. Search controller sequences from replayed
   reachable states, recording RAM changes and object references. Keep any
   artificially patched-state experiment separate from gameplay evidence.
   [BizHawk's Lua API](https://tasvideos.org/Bizhawk/LuaFunctions) supplies
   input, savestate, RAM and event facilities; confirm callback support on the
   selected N64 core before relying on it.
2. Observe guest RAM and MIPS execution around suspected anomalies. Track
   logical object-slot generations and reference lifetimes. Generic host
   memory checking can miss logical reuse inside a permanently allocated
   game pool; instrumenting an emulator with ASan does not automatically
   validate its guest's object accesses.
3. Use a native C harness with [ASan](https://clang.llvm.org/docs/AddressSanitizer.html)
   and UBSan for candidate discovery, optionally guided by
   [libFuzzer](https://llvm.org/docs/LibFuzzer.html). Recompilation changes
   memory layout and undefined-behavior outcomes, so confirm candidates in
   the original ROM. The upstream [SM64 build options](https://github.com/n64decomp/sm64/blob/master/README.md)
   explicitly say `NON_MATCHING` avoids instances of undefined behavior; that
   setting is not suitable as retail corruption evidence.
4. Use [CBMC](https://www.cprover.org/cbmc/) or another bounded checker to
   investigate a small actual code path under explicit integer widths,
   starting-state constraints and frame/unwind bounds. A synthetic state or
   bounded source-level violation is a lead, not a controller-reachable ROM
   exploit. Model the concrete MIPS continuation separately if the source
   semantics becomes undefined.
5. Minimize and replay each candidate through the exact game binary. Report
   the evidence in stages: memory anomaly, reproducible guest behavior,
   controller reachability, ABC-valid behavior, and demonstrated ACE if it
   is actually established. A crash alone proves none of the later stages;
   a finite search with no finding is not a global exclusion.

## The proof boundary stays the same

The obstacle is the **current CompCert Clight execution model, not Coq as a
proof assistant**. As the existing [execution-scope report](../compcert-execution-scope.md)
explains, an invalid memory operation or invalid call has no successful next
Clight step. That prevents the present witnesses from expressing a successful
out-of-bounds overwrite or jump into data. It does not refute the retail route.
Coq can in principle formalize a concrete byte-addressed N64/MIPS machine;
the missing work includes instruction/device semantics and the connection to
the selected ROM. Ordinary defined aliases, logical slot reuse and defined
retargets to registered functions remain within the existing model.

No formal theorem was extended or checked in this research. No gameplay search,
corruption witness or ACE experiment was run. The SSL capstone, all ranked
summaries and subjective estimates retain their prior verdicts. Pedro and Demo
have separate project scopes and are not updated by this methodology note.
