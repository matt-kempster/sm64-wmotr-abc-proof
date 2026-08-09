# Retail `find_floor` signed-short cast receipt

This note records the target-code evidence for the one concrete
Parallel-Universe floor-query sample used by `PyramidTopSurface.v`.  It closes
the original IDO/MIPS conversion question for these three inputs only.  It does
not prove a live pyramid-top surface, `find_floor` selection, gameplay
reachability, or a route to either target.

## Binaries and source revision

- Decomp source revision:
  `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Canonical US ROM SHA-1:
  `9bef1128717f958171a4afac3ed78ee2bb4e86ce`.
- Canonical JP ROM SHA-1:
  `8a20a5c83d6ceb0f0506cfc9fa20d8f438cafe51`.

The JP loader maps engine ROM interval `[0x0F4210, 0x1076A0)` at virtual
address `0x80378800`.  The US loader maps
`[0x0F5580, 0x118A10)` at the same virtual address.  In both retail binaries,
`find_floor` begins at virtual address `0x80381900`:

- JP ROM offset `0x0FD310`;
- US ROM offset `0x0FE680`.

A nonmatching development build placed a similarly named function at a
different address.  That map is not evidence about either retail ROM and is
deliberately not used here.

## Byte-identical coordinate-conversion sequence

At virtual address `0x80381934`, both authenticated ROMs contain:

```text
80381930: c7a80040  lwc1      $f8,64($sp)
80381934: 4600428d  trunc.w.s $f10,$f8
80381938: 440f5000  mfc1      $t7,$f10
8038193c: 00000000  nop
80381940: a7af0026  sh        $t7,38($sp)
...
80381974: 87ab0026  lh        $t3,38($sp)
```

The Y and Z inputs immediately use the same pattern with distinct stack
halfwords:

```text
80381944: c7b00044  lwc1      $f16,68($sp)
80381948: 4600848d  trunc.w.s $f18,$f16
8038194c: 44199000  mfc1      $t9,$f18
80381954: a7b90024  sh        $t9,36($sp)

80381958: c7a40048  lwc1      $f4,72($sp)
8038195c: 4600218d  trunc.w.s $f6,$f4
80381960: 44093000  mfc1      $t1,$f6
80381968: a7a90022  sh        $t1,34($sp)
```

## Concrete result

The candidate X value `63488.0f` is exactly represented by binary32 bits
`0x47780000` and lies inside the signed-32 range.  Therefore:

```text
trunc.w.s  63488.0f  = 0x0000F800
sh/lh      0x0000F800 = 0xFFFFF800 = -2048
```

The corresponding Y and Z samples are:

```text
1791.0f   (0x44DFE000) ->  1791
-1024.0f  (0xC4800000) -> -1024
```

`concrete_retail_cast_fragment_arithmetic` checks these three
`trunc.w.s`-then-signed-halfword results in Rocq.  The theorem uses
`Float32.to_int` for the finite exact truncation and `Int.sign_ext 16` for the
value-level effect of `sh` followed by `lh`.  The separate ROM receipt above
establishes that both target binaries execute that instruction shape at
`find_floor`.

Thus the concrete X alias from `63488` to `-2048` is real in both target ROMs.

The arbitrary out-of-signed-32 question is now separated in
[`area1-nonlocal-endpoints.md`](area1-nonlocal-endpoints.md).  The target game
threads enable the VR4300 Invalid Operation exception; infinity and the checked
signed-word-overflow samples therefore trap, while a NaN conversion is also in
the processor's trapping unimplemented-operation class.  The stock exception
path stops rather than resumes the thread, so none reaches `mfc1` or the
signed-halfword store.  That newer result does not affect finite
signed-32 values such as `63488`; those still execute the verified aliasing
sequence above.

## Reproduction

With legally obtained canonical ROMs, first verify their SHA-1 hashes.  The
following disassembly commands use the loader-derived ROM-to-virtual-address
bases:

```sh
sha1sum baserom.us.z64 baserom.jp.z64

mips-linux-gnu-objdump -D -b binary -m mips:4300 -EB \
  --adjust-vma=0x802845f0 \
  --start-address=0x80381920 --stop-address=0x803819a0 \
  baserom.jp.z64

mips-linux-gnu-objdump -D -b binary -m mips:4300 -EB \
  --adjust-vma=0x80283280 \
  --start-address=0x80381920 --stop-address=0x803819a0 \
  baserom.us.z64
```

The disassembled instruction words in the interval above are byte-identical
between the two versions.
