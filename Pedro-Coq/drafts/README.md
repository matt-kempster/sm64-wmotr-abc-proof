# Unverified proof drafts

Files in this directory preserve unfinished proof work for later development.
They are intentionally absent from `_CoqProject`, are not compiled by the
project pipeline, and must not be cited as checked results until moved into
`proofs/` and validated by the full audit.

`DustSpawnParticleExecution.v` and `SegmentedPointerBoundary.v` are retained
here as archival promotion snapshots. Their canonical modules (including the
separate JP spawn-particle companion) are compiled from `proofs/`, scanned for
proof holes, and audited through the main capstone. Only the canonical copies
may be cited as checked results.
