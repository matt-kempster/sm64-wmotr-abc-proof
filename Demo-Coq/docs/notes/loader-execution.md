# Executing the first demo loader call

The full gameplay claim remains **OPEN**. `DemoLoaderExecution.v` executes the
complete generated `load_patchable_table` function on its first-entry cache
miss path. This replaces a whole-loader execution obligation with the exact
remaining `dma_read` call and explicit memory conditions; it does not prove
DMA correctness or boot reachability.

The function starts with index zero and a null cached `currentAddr`. The
theorem reads the handler's table pointer, the table count, source pointer,
first entry's offset and size, cache pointer and destination buffer. It
checks the actual unsigned index/count comparison, computes the source
address using the entry's unsigned offset, checks that it differs from the
null cache, calls the actual generated `dma_read`, stores that source address
in `handler.currentAddr`, and returns one. Function entry, parameters, body,
return conversion and the empty stack-freeing list are constructed. The
loader and DMA function definitions are checked identical in US and JP.

The generated layout proof establishes these field offsets:

| Composite | Fields and byte offsets |
| --- | --- |
| `DmaHandlerList` | `dmaTable = 0`, `currentAddr = 4`, `bufTarget = 8` |
| `DmaTable` | `count = 0`, `srcAddr = 4`, `anim = 8` |
| `OffsetSizePair` | `offset = 0`, `size = 4`, record size 8 |

The source pointer comparison needs a valid pointer in CompCert's memory
semantics. The theorem also requires a nonzero table count, the listed
readable values, exact symbol/function resolution for `dma_read`, and a
writable cache cell after that call. Its remaining call premise is
specifically the generated `dma_read` with destination buffer, computed
source address and computed source end, returning `Vundef` with trace `E0`.
The source end uses the size as a signed integer, exactly as the generated
loader does. No size-range or ROM-address refinement is inferred from this
conditional execution theorem.

The exact final cache store is returned as an execution receipt. A separate
frame theorem proves that this store preserves the handler's table pointer
and buffer pointer, table count, first demo-buffer byte and demo-index value,
provided those reads hold immediately after DMA and the handler is separate
from the table, buffer and index blocks. Its same-block handler-field
disjointness is proved using the actual four-byte store at offset 4. These
are the post-loader reads needed by title startup.

The DMA call must still establish the post-DMA metadata reads and buffer
contents. The theorem does not assert that DMA changes only its destination
buffer: the actual DMA code also uses queue and I/O state. Allocation,
`setup_dma_table_list`, authenticated ROM bytes in CompCert memory, later
indices, cache hits and arbitrary gameplay remain separate obligations.

The capstone boundary is `demo_loader_execution_boundary_claim_us_jp`, proved
by `generated_demo_loader_execution_boundary_us_jp`. The loader's complete
execution and its metadata-store frame are distinct from the all-frame
stream/level invariant required for the requested result.
