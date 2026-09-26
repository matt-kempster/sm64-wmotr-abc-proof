(* OCaml extraction of the proved-sound Clight interpreter plus the twelve-TU
   link, for running the model on RECORDED real-game states in bulk
   (experiments/oracle, TRUST.md 5.1).  A test harness: nothing in proofs/
   depends on it, and extraction is not trusted by any theorem. *)
From Coq Require Extraction ExtrOcamlBasic ExtrOcamlNatInt ExtrOcamlString.
From compcert Require Import Coqlib Maps Integers Floats Values AST Memory
  Globalenvs Ctypes Clight.
From compcert Require Ctypesdefs.
From SM64.Proofs Require Interp.ClightInterp Interp.LinkGenv Interp.MemBuild Interp.CMem.

Extraction Language OCaml.
Set Extraction Output Directory "experiments/oracle/extract/ml".

Separate Extraction
  SM64.Proofs.Interp.ClightInterp.ex_call
  SM64.Proofs.Interp.LinkGenv.ge12
  SM64.Proofs.Interp.LinkGenv.ast12
  SM64.Proofs.Interp.MemBuild.alloc_globs
  SM64.Proofs.Interp.CMem.load
  SM64.Proofs.Interp.CMem.loadbytes
  SM64.Proofs.Interp.CMem.store
  SM64.Proofs.Interp.CMem.storebytes
  Mem.empty Mem.alloc Mem.nextblock
  Genv.find_symbol Genv.find_funct_ptr Genv.find_def
  Ctypes.sizeof Ctypes.alignof Ctypes.field_offset
  Ctypesdefs.string_of_ident Ctypesdefs.ident_of_string
  Int.repr Int.unsigned Int.signed Ptrofs.repr Ptrofs.unsigned Byte.repr Byte.unsigned
  Float32.to_bits Float32.of_bits Float.to_bits Float.of_bits
  Memdata.encode_val Memdata.decode_val.
