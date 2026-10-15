# Demo headers and the actual script dispatch table

The full gameplay claim remains **OPEN**. This note corrects the finite script
coverage domain; it supplies no reachable mismatch or global no-desync result.

The authenticated US stream stored as `assets/demos/bitdw.bin` has header level
**30**, as recorded in [the ROM metadata receipt](demo-data.json). In the actual
generated dispatch table, level 30 selects the **Bowser 1 arena**, through
`script_exec_bowser_1` and `level_bowser_1_entry`. The BITDW course uses level
**17**, `script_exec_bitdw` and `level_bitdw_entry`. Treating the asset filename
as its selected gameplay level omitted the Bowser 1 script from the intended
US demo domain. The corrected script inventory includes that arena; BITDW
course scripts can remain as additional conservative coverage. JP's demo
table omits the stream named `bitdw`; its generated level dispatch table
nevertheless contains both level routes.

`DemoScriptDispatchFacts.v` proves the following generated routes for both
translation configurations:

| Header | Dispatch script | `EXECUTE` entry |
| --- | --- | --- |
| 4 | `script_exec_bbh` | `level_bbh_entry` |
| 5 | `script_exec_ccm` | `level_ccm_entry` |
| 7 | `script_exec_hmc` | `level_hmc_entry` |
| 12 | `script_exec_jrb` | `level_jrb_entry` |
| 24 | `script_exec_wf` | `level_wf_entry` |
| 27 | `script_exec_pss` | `level_pss_entry` |
| 30 | `script_exec_bowser_1` | `level_bowser_1_entry` |

The theorem also checks level 17's BITDW route and proves that its dispatch
and entry symbols differ from Bowser 1's.

The checker looks up `script_exec_level_table` by its exact identifier in the
generated `global_definitions` list. It parses the entire initializer as:

- One `GET_OR_SET` command: opcode `0x3C`, byte length 4, `OP_GET = 1`, and
  `VAR_CURR_LEVEL_NUM = 3`.
- Equality-jump commands: opcode `0x0C`, byte length 12, `OP_EQ = 2`, zero
  padding, one signed integer comparison argument, and one target relocation
  whose offset is zero.
- A terminal `EXIT`: opcode `0x02`, byte length 4, zero argument bytes.

It selects the first equality arm matching the supplied header, looks up that
arm's exact generated global, and requires its complete initializer to be
`EXECUTE` followed by `RETURN`. The `EXECUTE` has opcode `0x00`, byte length
16, segment `0x0E`, two ROM-range relocations with zero offsets, and the entry
relocation in its fourth word with zero offset. `RETURN` has opcode `0x07`,
byte length 4 and zero argument bytes. An unrelated occurrence of an entry
address elsewhere in a script cannot satisfy these checks.

The capstone consumes `demo_script_dispatch_routes_claim_us_jp`, proved by
`generated_demo_script_dispatch_routes_us_jp`. Its targeted pipeline build
passed, and `Print Assumptions` reported **Closed under the global context**.

This is a finite certificate about generated initializer syntax. It does not
execute the table's commands, connect initializer relocations to runtime
memory, prove segmented-address conversion or loading, establish the command
interpreter's route from startup, or prove that loaded gameplay remains in
the selected level. The separate conditional execution of the complete
`level_cmd_call` and its actual level-selection callee is described in
[the execution note](gameplay-execution.md); composing those local executions
with this dispatch certificate remains required.
