(* Small conversions between extracted Coq data and OCaml. *)
open BinNums

let rec pos_to_int = function
  | Coq_xH -> 1
  | Coq_xO p -> 2 * pos_to_int p
  | Coq_xI p -> 2 * pos_to_int p + 1

let z_to_int = function Z0 -> 0 | Zpos p -> pos_to_int p | Zneg p -> - pos_to_int p

let rec int_to_pos n =
  if n = 1 then Coq_xH else if n land 1 = 0 then Coq_xO (int_to_pos (n lsr 1)) else Coq_xI (int_to_pos (n lsr 1))

let int_to_z n = if n = 0 then Z0 else if n > 0 then Zpos (int_to_pos n) else Zneg (int_to_pos (-n))

let str (l : char list) = Stdlib.String.of_seq (Stdlib.List.to_seq l)
let chars (s : string) : char list = Stdlib.List.of_seq (Stdlib.String.to_seq s)
let name i = str (Ctypesdefs.string_of_ident i)
let ident s = Ctypesdefs.ident_of_string (chars s)

let get = function Some x -> x | None -> failwith "None"
