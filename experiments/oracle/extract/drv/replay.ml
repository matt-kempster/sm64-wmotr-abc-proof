(* Run ONE recorded real frame through the model and compare.

     replay DIR        (DIR from export_frame.py: entry.bin exit.bin calls.txt addrs.txt frame.txt)

   1. Memory: every global of the twelve-TU link gets its block (alloc_globs, genv
      order), then its bytes are overwritten with the real RAM at its real address.
      All of RAM is also one extra "rest" block, for pointers into heap memory.
   2. Pointers: 32-bit words in pointer-typed slots (walking the C types of the
      globals, and of heap objects they point to) become CompCert pointers to the
      block holding that address.  Unions: pointer-looking words become pointers.
   3. Run execute_mario_action with the proved-sound interpreter.  Calls to
      functions outside the link are REPLAYED from the real game's call log: the
      callee name and arguments must match, the real memory effects are applied,
      and the real return value is returned.
   4. Compare the model's final memory with the real RAM at the function's return,
      over every placed global. *)

open Util
open BinNums
open Values
open Memdata
open AST
open Ctypes

module String = Stdlib.String
module List = Stdlib.List

let dir = Sys.argv.(1)
let ram_base = 0x80000000
let ram_size = 0x400000

(* ---------------- inputs ---------------- *)
let read_file p = In_channel.with_open_bin p In_channel.input_all
let entry = Bytes.of_string (read_file (dir ^ "/entry.bin"))
let exit_ = Bytes.of_string (read_file (dir ^ "/exit.bin"))
let img = Bytes.copy entry          (* the real RAM as replayed so far *)
let lines p = Stdlib.String.split_on_char '\n' (read_file p) |> Stdlib.List.filter (( <> ) "")
let words l = Stdlib.String.split_on_char ' ' l

type call = { cname : string; regs : int array; diffs : (int * string) list; post : (int * string) list }

let calls =
  let rec go acc = function
    | [] -> Stdlib.List.rev acc
    | l :: rest ->
        let w = Array.of_list (words l) in
        let n = int_of_string w.(Array.length w - 2) in
        let np = int_of_string w.(Array.length w - 1) in
        let regs = Array.map int_of_string (Array.sub w 2 (Array.length w - 4)) in
        let rec take k acc2 r =
          if k = 0 then (Stdlib.List.rev acc2, r)
          else match r with
            | d :: r' -> (match words d with
                | [ ("D" | "P"); a; hex ] -> take (k - 1) ((int_of_string a, hex) :: acc2) r'
                | _ -> failwith "bad D/P line")
            | [] -> failwith "short diff" in
        let diffs, rest' = take n [] rest in
        let post, rest' = take np [] rest' in
        go ({ cname = w.(1); regs; diffs; post } :: acc) rest'
  in
  Array.of_list (go [] (lines (dir ^ "/calls.txt")))
(* regs layout: ra sp a0 a1 a2 a3 f12 f14 s0..s7 v0 v1 f0 *)
let r_a k c = c.regs.(2 + k)
let r_f12 c = c.regs.(6)
let r_f14 c = c.regs.(7)
let r_stack k c = c.regs.(8 + k)
let r_v0 c = c.regs.(16)
let r_v1 c = c.regs.(17)
let r_f0 c = c.regs.(18)

let addrs = Hashtbl.create 2048
let () = Stdlib.List.iter (fun l -> match words l with
    | [ "A"; n; a; sz ] -> Hashtbl.replace addrs n (int_of_string a, int_of_string sz)
    | _ -> ()) (lines (dir ^ "/addrs.txt"))
let a0_real = match words (Stdlib.List.hd (lines (dir ^ "/frame.txt"))) with
  | _ :: a0 :: _ -> int_of_string a0 | _ -> failwith "frame.txt"

let u8 b a = Char.code (Bytes.get b (a - ram_base))
let u32 b a = (u8 b a lsl 24) lor (u8 b (a + 1) lsl 16) lor (u8 b (a + 2) lsl 8) lor u8 b (a + 3)
let in_ram a = a >= ram_base && a < ram_base + ram_size

(* ---------------- program ---------------- *)
let ge = get LinkGenv.ge12
let prog = get LinkGenv.ast12
let cenv = ge.Clight.genv_cenv
let genv = ge.Clight.genv_genv
let defs = prog.prog_defs
let def_of = Hashtbl.create 4096
let () = Stdlib.List.iter (fun (i, g) -> Hashtbl.replace def_of (name i) (i, g)) defs
let zi = z_to_int and iz = int_to_z
let sizeof t = zi (Ctypes.sizeof cenv t)
let blk_int b = pos_to_int b

(* ---------------- initial memory ---------------- *)
let size_of_extern i =
  match Hashtbl.find_opt addrs (name i) with
  | Some (_, hint) -> (
      match Hashtbl.find_opt def_of (name i) with
      | Some (_, Gvar v) when sizeof v.gvar_info = 0 && hint > 0 -> Some (iz hint)
      | _ -> None)
  | None -> None

let t_start = Unix.gettimeofday ()
let tick msg = if Sys.getenv_opt "TIMING" <> None then Printf.printf "[t] %6.2fs %s\n%!" (Unix.gettimeofday () -. t_start) msg
let () = tick "inputs read"
let m0 = get (MemBuild.alloc_globs ge size_of_extern Memory.Mem.empty defs)
let () = tick "alloc_globs"
let m1, rest = Memory.Mem.alloc m0 Z0 (iz ram_size)

(* placed globals: (start, size, block), sorted; functions by exact address *)
let placed, fun_at, addr_of_blk =
  let pl = ref [] and fa = Hashtbl.create 1024 and ab = Hashtbl.create 1024 in
  Hashtbl.replace ab (blk_int rest) ram_base;
  Stdlib.List.iter (fun (i, g) ->
      match Hashtbl.find_opt addrs (name i), Globalenvs.Genv.find_symbol genv i with
      | Some (a, _), Some b ->
          Hashtbl.replace ab (blk_int b) a;
          (match g with
           | Gfun _ -> Hashtbl.replace fa a b
           | Gvar _ ->
               let sz = zi (MemBuild.glob_size ge size_of_extern i g) in
               if sz > 0 then pl := (a, sz, b, name i) :: !pl)
      | _ -> ()) defs;
  (Array.of_list (Stdlib.List.sort compare !pl), fa, ab)

let max_size = Array.fold_left (fun m (_, sz, _, _) -> max m sz) 0 placed

(* every placed global containing a (they can overlap, e.g. a table and a symbol inside it) *)
let find_all a =
  (* rightmost start <= a, then scan left while a start could still reach a *)
  let lo = ref 0 and hi = ref (Array.length placed - 1) and r = ref (-1) in
  while !lo <= !hi do
    let mid = (!lo + !hi) / 2 in
    let s, _, _, _ = placed.(mid) in
    if s <= a then (r := mid; lo := mid + 1) else hi := mid - 1
  done;
  let acc = ref [] and k = ref !r in
  while !k >= 0 && (let s, _, _, _ = placed.(!k) in a - s < max_size) do
    let (s, sz, _, _) as p = placed.(!k) in
    if a < s + sz then acc := p :: !acc;
    decr k
  done;
  !acc

(* the canonical one: the innermost (latest start) *)
let find_placed a = match Stdlib.List.rev (find_all a) with p :: _ -> Some p | [] -> None

(* where an address lives in the model: a placed global, else the rest block *)
let loc a = match find_placed a with
  | Some (s, _, b, _) -> Some (b, a - s)
  | None -> if in_ram a then Some (rest, a - ram_base) else None

let bytev = Array.init 256 (fun i -> Byte (iz i))
let mem = ref m1

let store_raw b ofs (s : string) =
  let l = Stdlib.List.init (Stdlib.String.length s) (fun k -> bytev.(Char.code s.[k])) in
  mem := CMem.store_raw !mem b (iz ofs) l

(* write real bytes at a real address: the rest block, and any placed global *)
(* real bytes written by replayed calls (so a match there proves nothing about the model) *)
let replayed_bytes : (int, unit) Hashtbl.t = Hashtbl.create 4096

let write_real a (s : string) =
  let n = Stdlib.String.length s in
  Bytes.blit_string s 0 img (a - ram_base) n;
  store_raw rest (a - ram_base) s;
  let seen = Hashtbl.create 8 in
  for k = 0 to n - 1 do
    Stdlib.List.iter (fun (st, sz, b, _) ->
        if not (Hashtbl.mem seen st) then begin
          Hashtbl.replace seen st ();
          let lo = max a st and hi = min (a + n) (st + sz) in
          store_raw b (lo - st) (Stdlib.String.sub s (lo - a) (hi - lo))
        end) (find_all (a + k))
  done

let () =
  tick "placed";
  (* The rest block's contents, built bottom-up in one pass: ZMap keys are
     index(0) = 1 and index(z > 0) = 2z, and a PTree node reached by path bits c
     at depth d holds key 2^d + c (left child: bit d = 0). *)
  let maxkey = 2 * (ram_size - 1) in
  let value k = if k = 1 then Some bytev.(Char.code (Bytes.get entry 0))
    else if k land 1 = 0 then Some bytev.(Char.code (Bytes.get entry (k / 2))) else None in
  let rec build d c =
    let k = (1 lsl d) + c in
    if k > maxkey then Maps.PTree.Empty
    else Maps.PTree.coq_Node (build (d + 1) c) (value k) (build (d + 1) (c + (1 lsl d))) in
  let contents = (Undef, build 0 0) in
  let m = !mem in
  mem := { m with Memory.Mem.mem_contents = Maps.PMap.set rest contents m.Memory.Mem.mem_contents };
  tick "rest block filled";
  Array.iter (fun (s, sz, b, _) -> store_raw b 0 (Bytes.sub_string entry (s - ram_base) sz)) placed;
  tick "globals filled"

(* ---------------- pointers ---------------- *)
let resolve v =
  if v = 0 then None
  else match Hashtbl.find_opt fun_at v with
    | Some b -> Some (b, 0)
    | None -> loc v

let n_ptr = ref 0 and n_heur = ref 0

(* Model-local objects passed by address to the CURRENT external call, bound to
   the real address the game passed: blk -> (real base, size, pointee type).
   Cleared after each call. *)
let bindings : (int, int * int * coq_type) Hashtbl.t = Hashtbl.create 16

let bound_targets a =
  Hashtbl.fold (fun blk (ra, sz, _) acc ->
      if a >= ra && a < ra + sz then (int_to_pos blk, a - ra) :: acc else acc) bindings []

let store_ptr a v =
  match resolve v with
  | None -> false
  | Some (tb, to_) ->
      let targets = bound_targets a @ (match find_all a with
        | [] -> if in_ram a then [ (rest, a - ram_base) ] else []
        | l -> (rest, a - ram_base) :: Stdlib.List.map (fun (s, _, b, _) -> (b, a - s)) l) in
      Stdlib.List.fold_left (fun ok (b, o) ->
          match CMem.store Mint32 !mem b (iz o) (Vptr (tb, iz to_)) with
          | Some m -> mem := m; ok
          | None -> false) (targets <> []) targets

let has_ptr_memo = Hashtbl.create 256
let rec has_ptr t = match t with
  | Tpointer _ -> true
  | Tarray (t', _, _) -> has_ptr t'
  | Tstruct (id, _) | Tunion (id, _) -> (
      let k = blk_int id in
      match Hashtbl.find_opt has_ptr_memo k with
      | Some r -> r
      | None ->
          Hashtbl.replace has_ptr_memo k false;
          let r = match Maps.PTree.get id cenv with
            | Some co -> Stdlib.List.exists (function Member_plain (_, t') -> has_ptr t' | _ -> false) co.co_members
            | None -> false in
          Hashtbl.replace has_ptr_memo k r; r)
  | _ -> false

(* pointer slots discovered, for re-walking after replayed writes *)
let slots : (int, coq_type) Hashtbl.t = Hashtbl.create 65536
let visited = Hashtbl.create 65536
let plausible v = v >= 0x80000400 && in_ram v

(* heap objects reached by typed pointers (not placed globals): compared too *)
let heap_regions : (int, int) Hashtbl.t = Hashtbl.create 1024

let rec walk a t =
  if not (has_ptr t) then ()
  else match t with
    | Tpointer (pt, _) ->
        Hashtbl.replace slots a t;
        let v = u32 img a in
        if v <> 0 && store_ptr a v then begin
          incr n_ptr;
          (match pt, loc v with
           | (Tstruct _ | Tarray _ | Tpointer _), Some (b, _) when b == rest || find_placed v = None ->
               let key = (v, pt) in
               (match pt with
                | Tstruct _ -> Hashtbl.replace heap_regions v (max (sizeof pt) (Option.value ~default:0 (Hashtbl.find_opt heap_regions v)))
                | _ -> ());
               if not (Hashtbl.mem visited key) then (Hashtbl.replace visited key (); walk v pt)
           | _ -> ())
        end
    | Tarray (et, n, _) ->
        let es = sizeof et in
        for k = 0 to zi n - 1 do walk (a + k * es) et done
    | Tstruct (id, _) -> (
        match Maps.PTree.get id cenv with
        | Some co ->
            Stdlib.List.iter (function
                | Member_plain (fid, ft) when has_ptr ft -> (
                    match Ctypes.field_offset cenv fid co.co_members with
                    | Errors.OK (o, _) -> walk (a + zi o) ft
                    | _ -> ())
                | _ -> ()) co.co_members
        | None -> ())
    | Tunion (id, _) -> (
        match Maps.PTree.get id cenv with
        | Some co ->
            let sz = zi co.co_sizeof in
            let k = ref 0 in
            while !k + 4 <= sz do
              let wa = a + !k in
              Hashtbl.replace slots wa (Tpointer (Tvoid, { attr_volatile = false; attr_alignas = None }));
              let v = u32 img wa in
              if plausible v && store_ptr wa v then incr n_heur;
              k := !k + 4
            done
        | None -> ())
    | _ -> ()

let () =
  Stdlib.List.iter (fun (i, g) -> match g with
      | Gvar v -> (match Hashtbl.find_opt addrs (name i) with
          | Some (a, _) when find_placed a <> None ->
              (* an incomplete `extern T x[]` walks as many elements as its placed size *)
              let t = match v.gvar_info with
                | Tarray (et, Z0, at) when sizeof et > 0 ->
                    let sz = zi (MemBuild.glob_size ge size_of_extern i g) in
                    Tarray (et, iz (sz / sizeof et), at)
                | t -> t in
              walk a t
          | _ -> ())
      | _ -> ()) defs;
  tick "pointers walked";
  (match Sys.getenv_opt "BLK" with
   | Some k -> Array.iter (fun (s, sz, b, n) -> if blk_int b = int_of_string k then
       Printf.printf "blk%s = %s @%08x size %d type %s\n" k n s sz
         (match Hashtbl.find def_of n with (_, Gvar v) -> Pp.ty v.gvar_info | _ -> "fun")) placed
   | None -> ());
  Printf.printf "memory: %d globals placed, %d typed pointers, %d union-heuristic pointers\n%!"
    (Array.length placed) !n_ptr !n_heur

(* PROBE=struct:field,... debugging: follow a pointer chain from a placed global *)
let () = match Sys.getenv_opt "PROBE" with
  | None -> ()
  | Some spec ->
      let g, rest_ = match Stdlib.String.split_on_char ':' spec with [ g; r ] -> (g, r) | _ -> failwith "PROBE" in
      let a, _ = Hashtbl.find addrs g in
      let (_, gd) = Hashtbl.find def_of g in
      let t0 = match gd with Gvar v -> v.gvar_info | _ -> failwith "var" in
      let t0 = match t0 with Tarray (t, _, _) -> t | t -> t in
      let cur = ref (loc a, t0) in
      Stdlib.List.iter (fun fld ->
          match !cur with
          | Some (b, o), Tstruct (sid, _) -> (
              let co = get (Maps.PTree.get sid cenv) in
              let ft = Stdlib.List.find_map (function Member_plain (i, t) when name i = fld -> Some t | _ -> None) co.co_members |> get in
              let fo = match Ctypes.field_offset cenv (ident fld) co.co_members with Errors.OK (o, _) -> zi o | _ -> failwith "fo" in
              let v = CMem.load Mint32 !mem b (iz (o + fo)) in
              Printf.printf "PROBE %s @blk%d+0x%x: %s\n" fld (blk_int b) (o + fo)
                (match v with Some (Vptr (b', o')) -> Printf.sprintf "Vptr blk%d+0x%x" (blk_int b') (zi o')
                            | Some (Vint i) -> Printf.sprintf "Vint %x" (zi i) | Some _ -> "other" | None -> "load failed");
              match ft, v with
              | Tpointer (pt, _), Some (Vptr (b', o')) -> cur := (Some (b', zi o'), pt)
              | _ -> cur := (None, Tvoid))
          | _ -> ()) (Stdlib.String.split_on_char ',' rest_)

(* ---------------- the replay oracle ---------------- *)
let cursor = ref 0
let why : string option ref = ref None
let fail s = (if !why = None then why := Some s); None

let real_of_val = function
  | Vint i -> Some (zi i land 0xFFFFFFFF)
  | Vsingle f -> Some (zi (Floats.Float32.to_bits f) land 0xFFFFFFFF)
  | Vptr (b, o) -> (
      (* 32-bit wraparound: proof_n64.h's VIRTUAL_TO_PHYSICAL makes offsets like o - 0x80000000 *)
      let w x = x land 0xFFFFFFFF in
      match Hashtbl.find_opt addr_of_blk (blk_int b) with
      | Some a -> Some (w (a + zi o))
      | None -> (match Hashtbl.find_opt bindings (blk_int b) with Some (a, _, _) -> Some (w (a + zi o)) | None -> None))
  | _ -> None

let is_float = function Tfloat _ -> true | _ -> false

(* o32: word slot k, float args in f12/f14 only while every earlier arg is float *)
let real_arg c k all_float_before t =
  if is_float t && all_float_before && k < 2 then Some (if k = 0 then r_f12 c else r_f14 c)
  else if k < 4 then Some (r_a k c)
  else if k - 4 < 8 then Some (r_stack (k - 4) c)
  else None

let check_args c targs vargs =
  let rec go k afb ts vs =
    match ts, vs with
    | [], [] -> None
    | t :: ts', v :: vs' -> (
        let real = real_arg c k afb t in
        let afb' = afb && is_float t in
        match v, real with
        | Vptr (b, o), Some r when not (Hashtbl.mem addr_of_blk (blk_int b)) && not (Hashtbl.mem bindings (blk_int b)) ->
            (* a model-local object passed by address: bind it to the real one *)
            let pt = match t with Tpointer (pt, _) -> pt | _ -> Tvoid in
            (* extent: the pointee, but at least the 64-byte post window, since array
               arguments decay to element pointers (vec3f_copy(nextPos, ..) is f32 * ) *)
            let sz = max 64 (sizeof pt) in
            Hashtbl.replace bindings (blk_int b) (r - zi o, zi o + sz, pt); go (k + 1) afb' ts' vs'
        | _, Some r -> (
            match real_of_val v with
            | Some mv when mv <> r -> Some (Printf.sprintf "arg %d: model %08x real %08x" k mv r)
            | Some _ -> go (k + 1) afb' ts' vs'
            | None -> Some (Printf.sprintf "arg %d: model value not a word" k))
        | _, None -> go (k + 1) afb' ts' vs')
    | _ -> Some "arity"
  in
  go 0 true targs vargs

(* apply the call's real memory effects, then re-type pointer slots inside them *)
let apply_diffs c =
  Stdlib.List.iter (fun (a, hex) ->
      let n = Stdlib.String.length hex / 2 in
      let s = Stdlib.String.init n (fun k -> Char.chr (int_of_string ("0x" ^ Stdlib.String.sub hex (2 * k) 2))) in
      write_real a s;
      for k = 0 to n - 1 do Hashtbl.replace replayed_bytes (a + k) () done;
      (* model-local objects bound to real addresses: raw bytes, then their pointers *)
      Hashtbl.iter (fun blk (ra, sz, pt) ->
          if a < ra + sz && ra < a + n then begin
            let lo = max a ra in
            let b = int_to_pos blk in
            for k = 0 to min (a + n) (ra + sz) - lo - 1 do
              match CMem.storebytes !mem b (iz (lo - ra + k)) [ bytev.(Char.code s.[lo - a + k]) ] with
              | Some m -> mem := m
              | None -> ()
            done;
            walk ra pt
          end) bindings;
      for k = (a - 3) to a + n - 1 do
        match Hashtbl.find_opt slots k with
        | Some t -> Hashtbl.remove visited (u32 img k, t); walk k t
        | None -> ()
      done) c.diffs

(* a bound model-local gets the real bytes at its real address after the call *)
let fill_bound c =
  Hashtbl.iter (fun blk (ra, sz, pt) ->
      let b = int_to_pos blk in
      Stdlib.List.iter (fun (pa, hex) ->
          let n = Stdlib.String.length hex / 2 in
          let lo = max pa ra and hi = min (pa + n) (ra + sz) in
          if lo < hi then begin
            for k = 0 to hi - lo - 1 do
              let byte = bytev.(int_of_string ("0x" ^ Stdlib.String.sub hex (2 * (lo - pa + k)) 2)) in
              match CMem.storebytes !mem b (iz (lo - ra + k)) [ byte ] with Some m -> mem := m | None -> ()
            done;
            (* pointers inside it: read words from the post bytes *)
            let rec ptrs a t = match t with
              | Tpointer _ ->
                  if a >= lo && a + 4 <= hi then begin
                    let o = 2 * (a - pa) in
                    let v = int_of_string ("0x" ^ Stdlib.String.sub hex o 8) in
                    (match resolve v with
                     | Some (tb, to_) when v <> 0 -> (
                         match CMem.store Mint32 !mem b (iz (a - ra)) (Vptr (tb, iz to_)) with
                         | Some m -> mem := m | None -> ())
                     | _ -> ())
                  end
              | Tarray (et, n, _) -> for k = 0 to zi n - 1 do ptrs (a + k * sizeof et) et done
              | Tstruct (id, _) -> (match Maps.PTree.get id cenv with
                  | Some co -> Stdlib.List.iter (function
                      | Member_plain (fid, ft) -> (match Ctypes.field_offset cenv fid co.co_members with
                          | Errors.OK (o, _) -> ptrs (a + zi o) ft | _ -> ())
                      | _ -> ()) co.co_members
                  | None -> ())
              | _ -> () in
            ptrs ra pt
          end) c.post) bindings

let sext bits v = let m = 1 lsl (bits - 1) in ((v land ((1 lsl bits) - 1)) lxor m) - m

let ret_val c tres =
  let v0 = r_v0 c in
  match tres with
  | Tvoid -> Some Vundef
  | Tint (I8, Signed, _) -> Some (Vint (iz (sext 8 v0)))
  | Tint (I8, Unsigned, _) -> Some (Vint (iz (v0 land 0xFF)))
  | Tint (I16, Signed, _) -> Some (Vint (iz (sext 16 v0)))
  | Tint (I16, Unsigned, _) -> Some (Vint (iz (v0 land 0xFFFF)))
  | Tint (IBool, _, _) -> Some (Vint (iz (v0 land 1)))
  | Tint (I32, _, _) -> Some (Vint (Integers.Int.repr (iz v0)))
  | Tpointer _ -> (match resolve v0 with
      | Some (b, o) -> Some (Vptr (b, iz o))
      | None -> Some (Vint (Integers.Int.repr (iz v0))))
  | Tfloat (F32, _) -> Some (Vsingle (Floats.Float32.of_bits (iz (r_f0 c))))
  | Tlong _ -> Some (Vlong (Integers.Int64.repr (iz ((v0 lsl 32) lor r_v1 c))))
  | _ -> None

let extcall ef vargs m =
  mem := m;
  match ef with
  | EF_external (n, _) -> (
      let n = str n in
      if !cursor >= Array.length calls then fail ("model calls " ^ n ^ " but the real frame made no more external calls")
      else
        let c = calls.(!cursor) in
        if c.cname <> n then fail (Printf.sprintf "call #%d: model calls %s, real game called %s" !cursor n c.cname)
        else
          match Hashtbl.find_opt def_of n with
          | Some (_, Gfun (External (_, targs, tres, _))) -> (
              match check_args c targs vargs with
              | Some e -> fail (Printf.sprintf "call #%d %s: %s" !cursor n e)
              | None ->
                  incr cursor;
                  apply_diffs c;
                  fill_bound c;
                  Hashtbl.reset bindings;
                  match ret_val c tres with
                  | Some v -> Some (([], v), !mem)
                  | None -> fail ("unsupported return type of " ^ n))
          | _ -> fail ("no external declaration for " ^ n))
  | EF_memcpy (sz, _) -> (
      match vargs with
      | [ Vptr (bd, od); Vptr (bs, os) ] -> (
          match CMem.loadbytes m bs os sz with
          | Some bytes -> (match CMem.storebytes m bd od bytes with
              | Some m' -> mem := m'; Some (([], Vundef), m')
              | None -> fail "memcpy store")
          | None -> fail "memcpy load")
      | _ -> fail "memcpy args")
  | ef -> fail ("unsupported builtin " ^ str (ClightInterp.ef_label ef))

(* ---------------- run ---------------- *)
let () =
  let fb = get (Globalenvs.Genv.find_symbol genv (ident "execute_mario_action")) in
  let f = get (Globalenvs.Genv.find_funct_ptr genv fb) in
  let arg = match resolve a0_real with Some (b, o) -> Vptr (b, iz o) | None -> failwith "a0" in
  let t0 = Unix.gettimeofday () in
  let r = ClightInterp.ex_call ge extcall 10_000_000 !mem f [ arg ] in
  Printf.printf "run: %.2fs, %d/%d external calls replayed\n%!" (Unix.gettimeofday () -. t0) !cursor (Array.length calls);
  match r with
  | ClightInterp.Stuck (stk, st, w) ->
      Printf.printf "STUCK: %s at: %s\n  stack: %s\n  oracle: %s\n" (str w) (Pp.st st)
        (Stdlib.String.concat " <- " (Stdlib.List.map name stk))
        (match !why with Some s -> s | None -> "-");
      exit 2
  | ClightInterp.Done ((_, m_final), vres) ->
      Printf.printf "DONE: returned %s\n%!" (match vres with Vint i -> string_of_int (zi i) | _ -> "?");
      if !cursor <> Array.length calls then
        Printf.printf "NOTE: real frame made %d external calls, model made %d\n" (Array.length calls) !cursor;
      (* compare every placed global, byte by byte *)
      let byte_of mv = match mv with
        | Byte z -> Some (zi z)
        | Fragment (v, _, n) -> (
            match real_of_val v with Some w -> Some ((w lsr (8 * n)) land 0xFF) | None -> None)
        | Undef -> None in
      let contents = m_final.Memory.Mem.mem_contents in
      let bad = ref 0 and undef = ref 0 and total = ref 0 in
      let changed = ref 0 and changed_by_model = ref 0 in
      let reports = ref [] in
      Array.iter (fun (s, sz, b, nm) ->
          let c = Maps.PMap.get b contents in
          let run = ref None in
          let flush () = match !run with
            | Some (st, en) -> reports := (nm, st - s, en - st) :: !reports; run := None
            | None -> () in
          for k = 0 to sz - 1 do
            incr total;
            let real = u8 exit_ (s + k) in
            if real <> u8 entry (s + k) then begin
              incr changed;
              if not (Hashtbl.mem replayed_bytes (s + k)) then incr changed_by_model
            end;
            match byte_of (Maps.ZMap.get (iz k) c) with
            | Some v when v = real -> flush ()
            | Some _ -> incr bad; (match !run with Some (st, _) -> run := Some (st, s + k + 1) | None -> run := Some (s + k, s + k + 1))
            | None -> incr undef; flush ()
          done;
          flush ()) placed;
      (* heap objects (Mario's Object, surfaces, camera, ...) via the rest block *)
      let rc = Maps.PMap.get rest contents in
      let hb = ref 0 and hbad = ref 0 and hchanged = ref 0 and hmodel = ref 0 in
      let seen = Hashtbl.create 65536 in
      Hashtbl.iter (fun a sz ->
          for k = 0 to sz - 1 do
            let x = a + k in
            if in_ram x && not (Hashtbl.mem seen x) then begin
              Hashtbl.replace seen x ();
              incr hb;
              let real = u8 exit_ x in
              if real <> u8 entry x then (incr hchanged; if not (Hashtbl.mem replayed_bytes x) then incr hmodel);
              match byte_of (Maps.ZMap.get (iz (x - ram_base)) rc) with
              | Some v when v = real -> ()
              | Some v ->
                  incr hbad;
                  if !hbad <= 20 then Printf.printf "  HEAP DIFF %08x (object @%08x+0x%x): model %02x real %02x (entry %02x)\n" x a k v real (u8 entry x)
              | None -> ()
            end
          done) heap_regions;
      Printf.printf "heap:    %d bytes over %d typed heap objects, %d differ; real frame changed %d, model computed %d of those\n"
        !hb (Hashtbl.length heap_regions) !hbad !hchanged !hmodel;
      if !hbad > 0 then bad := !bad + !hbad;
      Printf.printf "compare: %d bytes over placed globals, %d differ, %d undefined in model\n" !total !bad !undef;
      Printf.printf "         the real frame changed %d of them; %d of those were computed by the model (not written by a replayed call)\n" !changed !changed_by_model;
      Stdlib.List.iter (fun (nm, o, n) ->
          let s, _, _, _ = Array.to_list placed |> Stdlib.List.find (fun (_, _, _, x) -> x = nm) in
          let hex b a n = Stdlib.String.concat "" (Stdlib.List.init n (fun k -> Printf.sprintf "%02x" (u8 b (a + k)))) in
          Printf.printf "  DIFF %s+0x%x (%d bytes): entry %s real-exit %s\n" nm o n
            (hex entry (s + o) (min n 16)) (hex exit_ (s + o) (min n 16))) (Stdlib.List.rev !reports);
      if !bad > 0 then exit 1
