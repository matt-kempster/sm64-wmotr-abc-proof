From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Clightdefs Coqlib Cop Ctypes Errors
 Integers Maps Memory Values.
From Demo.Proofs Require Import DemoConcreteMemoryTransport.
From Demo.Generated Require Import us_memory jp_memory.
From Demo.Proofs Require Import DemoNumericAddressExecution DemoSceneAddressBoundary.
Import ListNotations.
Local Open Scope Z_scope.

(** Candidate numeric-address expression semantics over UNCHANGED Clight.expr.
    This is neither Clight.eval_expr nor an additional Clight.step rule.
    Runtime symbol placement, initial contexts, statement execution and retail
    MIPS adequacy are separate unproved obligations. No load oracle is supplied. *)
Record demo_concrete_expression_context := ConcreteExpressionContext {
 concrete_expression_cenv : composite_env;
 concrete_expression_globals : PTree.t int;
 concrete_expression_locals : PTree.t (int * type);
 concrete_expression_temps : temp_env;
 concrete_expression_memory : mem;
 concrete_expression_ram_block : block
}.

Definition demo_concrete_symbol_address context id ty : option int :=
 match (concrete_expression_locals context) ! id with
 | Some (address, declared) => if type_eq declared ty then Some address else None
 | None => (concrete_expression_globals context) ! id
 end.

(** By-copy/by-reference expressions expose their numeric address. All actual
    value loads go through the concrete flat CompCert Mem/KSEG0 operation.
    Bitfields, volatile accesses and By_nothing are explicitly unsupported. *)
Definition demo_concrete_read_typed context ty address : option val :=
 if type_is_volatile ty then None else
 match access_mode ty with
 | By_value chunk => demo_concrete_ram_load (concrete_expression_memory context)
     (concrete_expression_ram_block context) chunk address
 | By_reference | By_copy => Some (Vint address)
 | By_nothing => None
 end.

Definition demo_concrete_field_address context ty field base : option int :=
 match ty with
 | Tstruct tag _ =>
   match (concrete_expression_cenv context) ! tag with
   | Some co =>
     match field_offset (concrete_expression_cenv context) field (co_members co) with
     | OK (delta, Full) => Some (Int.add base (Int.repr delta))
     | _ => None
     end
   | None => None
   end
 | Tunion tag _ =>
   match (concrete_expression_cenv context) ! tag with
   | Some co =>
     match union_field_offset (concrete_expression_cenv context) field (co_members co) with
     | OK (delta, Full) => Some (Int.add base (Int.repr delta))
     | _ => None
     end
   | None => None
   end
 | _ => None
 end.

(** The pair consists of the rvalue and numeric lvalue projections. Computing
    both by structural recursion avoids fuel and does not add game transitions.
    None explicitly denotes an unsupported/undefined evaluation: missing temp
    or symbol, ill-matched local type, nonnumeric address, unsupported bitfield
    or volatile access, failed standard Cop operation, or failed concrete load.
    Existing Vptr temporaries can pass through scalar Cop operations; they can
    never be used as numeric dereference/field addresses in this evaluator. *)
Fixpoint demo_concrete_expression (context : demo_concrete_expression_context)
    (expression : expr) : option val * option int :=
 match expression with
 | Econst_int integer _ => (Some (Vint integer), None)
 | Econst_float number _ => (Some (Vfloat number), None)
 | Econst_single number _ => (Some (Vsingle number), None)
 | Econst_long integer _ => (Some (Vlong integer), None)
 | Etempvar id _ => ((concrete_expression_temps context) ! id, None)
 | Evar id ty =>
   let location := demo_concrete_symbol_address context id ty in
   (match location with Some address => demo_concrete_read_typed context ty address
                        | None => None end, location)
 | Ederef pointer ty =>
   let location := match fst (demo_concrete_expression context pointer) with
                   | Some (Vint address) => Some address | _ => None end in
   (match location with Some address => demo_concrete_read_typed context ty address
                        | None => None end, location)
 | Eaddrof lvalue _ =>
   (match snd (demo_concrete_expression context lvalue) with
    | Some address => Some (Vint address) | None => None end, None)
 | Eunop operator argument _ =>
   (match fst (demo_concrete_expression context argument) with
    | Some value => sem_unary_operation operator value (typeof argument)
                     (concrete_expression_memory context)
    | None => None end, None)
 | Ebinop operator left_expr right_expr _ =>
   (match fst (demo_concrete_expression context left_expr),
          fst (demo_concrete_expression context right_expr) with
    | Some first, Some second => sem_binary_operation
        (concrete_expression_cenv context) operator first (typeof left_expr)
        second (typeof right_expr) (concrete_expression_memory context)
    | _, _ => None end, None)
 | Ecast argument ty =>
   (match fst (demo_concrete_expression context argument) with
    | Some value => sem_cast value (typeof argument) ty (concrete_expression_memory context)
    | None => None end, None)
 | Esizeof argument _ =>
   (Some (Vptrofs (Ptrofs.repr (sizeof (concrete_expression_cenv context) argument))), None)
 | Ealignof argument _ =>
   (Some (Vptrofs (Ptrofs.repr (alignof (concrete_expression_cenv context) argument))), None)
 | Efield record field ty =>
   let location := match fst (demo_concrete_expression context record) with
    | Some (Vint base) => demo_concrete_field_address context (typeof record) field base
    | _ => None end in
   (match location with Some address => demo_concrete_read_typed context ty address
                        | None => None end, location)
 end.

Definition demo_concrete_eval_expr context expression :=
 fst (demo_concrete_expression context expression).
Definition demo_concrete_eval_lvalue context expression :=
 snd (demo_concrete_expression context expression).

(** This scalar fragment has no address reinterpretation or memory access.
    Its operations are precisely ordinary CompCert Cop operations. *)
Inductive demo_concrete_scalar_expr : expr -> Prop :=
| ConcreteScalarInt : forall integer ty,
    demo_concrete_scalar_expr (Econst_int integer ty)
| ConcreteScalarFloat : forall number ty,
    demo_concrete_scalar_expr (Econst_float number ty)
| ConcreteScalarSingle : forall number ty,
    demo_concrete_scalar_expr (Econst_single number ty)
| ConcreteScalarLong : forall integer ty,
    demo_concrete_scalar_expr (Econst_long integer ty)
| ConcreteScalarTemp : forall id ty,
    demo_concrete_scalar_expr (Etempvar id ty)
| ConcreteScalarUnary : forall operator argument ty,
    demo_concrete_scalar_expr argument ->
    demo_concrete_scalar_expr (Eunop operator argument ty)
| ConcreteScalarBinary : forall operator left right ty,
    demo_concrete_scalar_expr left -> demo_concrete_scalar_expr right ->
    demo_concrete_scalar_expr (Ebinop operator left right ty)
| ConcreteScalarCast : forall argument ty,
    demo_concrete_scalar_expr argument -> demo_concrete_scalar_expr (Ecast argument ty)
| ConcreteScalarSizeof : forall argument ty,
    demo_concrete_scalar_expr (Esizeof argument ty)
| ConcreteScalarAlignof : forall argument ty,
    demo_concrete_scalar_expr (Ealignof argument ty).

Lemma demo_concrete_scalar_cannot_be_lvalue :
 forall ge environment locals memory expression b offset bf,
 demo_concrete_scalar_expr expression ->
 ~ eval_lvalue ge environment locals memory expression b offset bf.
Proof. intros ge environment locals memory expression b offset bf Hscalar Hvalue.
 inversion Hvalue; subst; inversion Hscalar. Qed.

Theorem demo_concrete_scalar_sound :
 forall expression, demo_concrete_scalar_expr expression ->
 forall context (ge : Clight.genv) environment value,
 concrete_expression_cenv context = genv_cenv ge ->
 demo_concrete_eval_expr context expression = Some value ->
 eval_expr ge environment (concrete_expression_temps context)
   (concrete_expression_memory context) expression value.
Proof.
 intros expression Hscalar. induction Hscalar; intros context ge environment value Hce Heval;
 unfold demo_concrete_eval_expr in Heval; cbn [demo_concrete_expression] in Heval.
 all: try solve [inversion Heval; subst; constructor].
 - constructor. exact Heval.
 - destruct (fst (demo_concrete_expression context argument)) as [first|] eqn:Hfirst;
     try discriminate. eapply eval_Eunop; [eapply IHHscalar; eassumption|exact Heval].
 - destruct (fst (demo_concrete_expression context left)) as [first|] eqn:Hfirst;
     try discriminate.
   destruct (fst (demo_concrete_expression context right)) as [second|] eqn:Hsecond;
     try discriminate.
   eapply eval_Ebinop; [eapply IHHscalar1; eassumption|eapply IHHscalar2; eassumption|].
   rewrite <- Hce. exact Heval.
 - destruct (fst (demo_concrete_expression context argument)) as [first|] eqn:Hfirst;
     try discriminate. eapply eval_Ecast; [eapply IHHscalar; eassumption|exact Heval].
 - rewrite Hce in Heval. inversion Heval; subst. constructor.
 - rewrite Hce in Heval. inversion Heval; subst. constructor.
Qed.

Lemma demo_concrete_numeric_deref_load : forall context pointer ty chunk address,
 demo_concrete_eval_expr context pointer = Some (Vint address) ->
 type_is_volatile ty = false -> access_mode ty = By_value chunk ->
 demo_concrete_eval_expr context (Ederef pointer ty) =
 demo_concrete_ram_load (concrete_expression_memory context)
   (concrete_expression_ram_block context) chunk address.
Proof.
 intros context pointer ty chunk address Hpointer Hvolatile Haccess.
 unfold demo_concrete_eval_expr in *. cbn [demo_concrete_expression].
 rewrite Hpointer. cbn. unfold demo_concrete_read_typed. rewrite Hvolatile,Haccess. reflexivity.
Qed.

Theorem demo_concrete_geometry_opcode_load : forall context address,
 (concrete_expression_temps context) ! SG._t'3 = Some (Vint address) ->
 demo_concrete_eval_expr context scene_geometry_opcode_expression =
 demo_concrete_ram_load (concrete_expression_memory context)
   (concrete_expression_ram_block context) Mint8unsigned address.
Proof.
 intros context address Htemp. unfold scene_geometry_opcode_expression.
 eapply demo_concrete_numeric_deref_load; [|reflexivity|reflexivity].
 unfold demo_concrete_eval_expr. cbn [demo_concrete_expression]. rewrite Htemp.
 change (Some (Vint (Int.add address Int.zero)) = Some (Vint address)).
 rewrite Int.add_zero. reflexivity.
Qed.

Theorem demo_concrete_terrain_type_load : forall context address,
 (concrete_expression_temps context) ! ST._t'10 = Some (Vint address) ->
 demo_concrete_eval_expr context scene_terrain_type_expression =
 demo_concrete_ram_load (concrete_expression_memory context)
   (concrete_expression_ram_block context) Mint16signed address.
Proof.
 intros context address Htemp. unfold scene_terrain_type_expression.
 eapply demo_concrete_numeric_deref_load; [exact Htemp|reflexivity|reflexivity].
Qed.

(** These equations evaluate the operand selected from each unchanged actual
    generated Sset, not a separate transcription or a statement-step relation. *)
Theorem demo_concrete_generated_scene_operands_us_jp :
 forall us context geometry terrain,
 (concrete_expression_temps context) ! SG._t'3 = Some (Vint geometry) ->
 (concrete_expression_temps context) ! ST._t'10 = Some (Vint terrain) ->
 (match scene_geometry_opcode_statement (fn_body (scene_geometry_function us)) with
  | Sset _ operand => demo_concrete_eval_expr context operand | _ => None end =
  demo_concrete_ram_load (concrete_expression_memory context)
   (concrete_expression_ram_block context) Mint8unsigned geometry) /\
 (match scene_terrain_type_statement (fn_body (scene_terrain_function us)) with
  | Sset _ operand => demo_concrete_eval_expr context operand | _ => None end =
  demo_concrete_ram_load (concrete_expression_memory context)
   (concrete_expression_ram_block context) Mint16signed terrain).
Proof.
 intros us context geometry terrain Hgeometry Hterrain.
 rewrite generated_scene_geometry_opcode_us_jp, generated_scene_terrain_type_read_us_jp.
 split; [apply demo_concrete_geometry_opcode_load|apply demo_concrete_terrain_type_load]; assumption.
Qed.
