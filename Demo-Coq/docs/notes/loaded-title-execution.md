# Composing the loader and complete first-title body

The gameplay verdict remains **OPEN**. The capstone now consumes a composed
startup theorem, rather than only a conjunction of the loader and title lemmas.

`DemoLoadedTitleExecution.v` proves `generated_dma_to_first_title_us_jp`.
It constructs the complete generated title-body execution on the first-demo
path from the **actual `dma_read` execution** and explicit readable/writable
memory conditions. It invokes the proved loader execution, frames that
loader's final cache store over the five post-load reads, constructs the
next-index store, and applies the complete title-body execution. The result
installs `buffer + 4` and returns the signed first byte from that same buffer.

This replaces the earlier whole-`load_patchable_table` execution premise on
this composed startup path. Its remaining call premise names the generated
internal `dma_read`, with exactly the destination, computed source and source
end supplied by the actual loader. Queue/I/O execution, authentic ROM byte
transfer and its metadata effects remain unproved. The theorem explicitly
requires the handler table/target, table count, header and index reads after
DMA; it does not assume that DMA changes only the destination buffer.

The initial pointer-clear and countdown stores remain explicit equations.
The theorem constructs the cache store, next-index store and installation
stores. It requires the actual composite layouts, symbol/function resolutions,
pointer validity and separation used by these concrete operations. The table
count must be nonzero and unequal to one, matching the first index increment
without wrap. It covers index zero and an initially null cache, not later
indices or cache hits.

The conclusion is a whole-body `exec_stmt` at explicit locals and memory,
not an initialized-game execution witness or a complete caller/interpreter
trace. It does not establish authentic buffer allocation, normal-boot
reachability, all-frame preservation, or the retail/hardware refinement.
Those obligations remain in the main checklist.
