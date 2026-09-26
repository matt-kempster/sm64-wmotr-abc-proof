(* Print the twelve-TU link's boundary: external functions (with C return
   type class) and global variables (with footprint), one per line. *)
open Util

let () =
  let ge = get LinkGenv.ge12 in
  let p = get LinkGenv.ast12 in
  Stdlib.List.iter (fun (i, g) ->
      match g with
      | AST.Gfun (Ctypes.External (AST.EF_external (n, _), _, tres, _)) ->
          let k = match tres with
            | Ctypes.Tvoid -> "void" | Ctypes.Tfloat (Ctypes.F32, _) -> "f32"
            | Ctypes.Tfloat (Ctypes.F64, _) -> "f64" | Ctypes.Tpointer _ -> "ptr"
            | Ctypes.Tlong _ -> "i64" | _ -> "int" in
          Printf.printf "extfun %s %s\n" (str n) k
      | AST.Gfun (Ctypes.External (ef, _, _, _)) ->
          Printf.printf "extother %s %s\n" (name i) (str (ClightInterp.ef_label ef))
      | AST.Gfun (Ctypes.Internal _) -> Printf.printf "fun %s\n" (name i)
      | AST.Gvar v ->
          Printf.printf "var %s %d init=%d\n" (name i)
            (z_to_int (MemBuild.glob_size ge (fun _ -> None) i g))
            (z_to_int (AST.init_data_list_size v.AST.gvar_init)))
    p.AST.prog_defs
