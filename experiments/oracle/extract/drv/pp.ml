(* Compact C-like printing of Clight expressions/statements, for Stuck reports. *)
open Util
open Clight
open Cop
open Ctypes

let rec ty = function
  | Tvoid -> "void" | Tint (I8, Signed, _) -> "s8" | Tint (I8, _, _) -> "u8"
  | Tint (I16, Signed, _) -> "s16" | Tint (I16, _, _) -> "u16"
  | Tint (I32, Signed, _) -> "s32" | Tint (I32, _, _) -> "u32" | Tint (IBool, _, _) -> "bool"
  | Tlong _ -> "s64" | Tfloat (F32, _) -> "f32" | Tfloat (F64, _) -> "f64"
  | Tpointer (t, _) -> ty t ^ "*" | Tarray (t, n, _) -> Printf.sprintf "%s[%d]" (ty t) (z_to_int n)
  | Tfunction _ -> "fn" | Tstruct (i, _) -> "struct " ^ name i | Tunion (i, _) -> "union " ^ name i

let bop = function
  | Oadd -> "+" | Osub -> "-" | Omul -> "*" | Odiv -> "/" | Omod -> "%" | Oand -> "&"
  | Oor -> "|" | Oxor -> "^" | Oshl -> "<<" | Oshr -> ">>" | Oeq -> "==" | One -> "!="
  | Olt -> "<" | Ogt -> ">" | Ole -> "<=" | Oge -> ">="

let rec ex = function
  | Econst_int (i, _) -> string_of_int (z_to_int i)
  | Econst_float _ -> "<f64>" | Econst_single _ -> "<f32>" | Econst_long _ -> "<s64>"
  | Evar (i, _) -> name i | Etempvar (i, _) -> "$" ^ name i
  | Ederef (e, _) -> "*(" ^ ex e ^ ")" | Eaddrof (e, _) -> "&(" ^ ex e ^ ")"
  | Eunop (Onotbool, e, _) -> "!" ^ ex e | Eunop (Onotint, e, _) -> "~" ^ ex e
  | Eunop (Oneg, e, _) -> "-" ^ ex e | Eunop (Oabsfloat, e, _) -> "fabs(" ^ ex e ^ ")"
  | Ebinop (o, a, b, _) -> "(" ^ ex a ^ " " ^ bop o ^ " " ^ ex b ^ ")"
  | Ecast (e, t) -> "(" ^ ty t ^ ")" ^ ex e
  | Efield (e, f, _) -> ex e ^ "." ^ name f
  | Esizeof (t, _) -> "sizeof(" ^ ty t ^ ")" | Ealignof (t, _) -> "alignof(" ^ ty t ^ ")"

let st = function
  | Sassign (a, b) -> ex a ^ " = " ^ ex b
  | Sset (i, e) -> "$" ^ name i ^ " = " ^ ex e
  | Scall (_, f, args) -> ex f ^ "(" ^ Stdlib.String.concat ", " (Stdlib.List.map ex args) ^ ")"
  | Sifthenelse (e, _, _) -> "if (" ^ ex e ^ ")"
  | Sreturn (Some e) -> "return " ^ ex e
  | Sswitch (e, _) -> "switch (" ^ ex e ^ ")"
  | Sskip -> "skip" | _ -> "<stmt>"
