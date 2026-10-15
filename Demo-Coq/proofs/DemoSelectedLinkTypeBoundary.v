From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Linking Maps.
From Demo.Generated Require Import us_game_init us_area jp_game_init jp_area.
From Demo.Proofs Require Import DemoExternArrayCompletion.
Import ListNotations.

(** This certificate identifies a remaining strict type-link boundary. The
    tag correspondence below compares finite syntax and computed layouts;
    it does not rename any production program or prove a renaming simulation. *)
Definition demo_gfx_strict_type_link_boundary_claim_us_jp : Prop :=
  link us_game_init.v_gDisplayListHead us_area.v_gDisplayListHead = None /\
  link jp_game_init.v_gDisplayListHead jp_area.v_gDisplayListHead = None.

Theorem generated_demo_gfx_strict_type_link_boundary_us_jp :
  demo_gfx_strict_type_link_boundary_claim_us_jp.
Proof. split; vm_compute; reflexivity. Qed.

Lemma demo_array_normalization_preserves_pointer_globals :
  forall definitions public name target attributes init readonly volatile,
  let variable := {| gvar_info := Tpointer target attributes;
                    gvar_init := init; gvar_readonly := readonly;
                    gvar_volatile := volatile |} in
  demo_normalize_script_declaration_entry definitions public (name, Gvar variable) =
    (name, Gvar variable).
Proof.
  intros definitions public name target attributes init readonly volatile variable.
  subst variable.
  unfold demo_normalize_script_declaration_entry, demo_update_global_metadata,
    demo_normalize_empty_readonly_global, demo_complete_public_array_metadata,
    demo_derive_external_array_readonly.
  cbn [gvar_info gvar_init gvar_readonly gvar_volatile].
  destruct (existsb (Pos.eqb name) public), init; reflexivity.
Qed.

Definition demo_gfx_normalization_boundary_claim_us_jp : Prop :=
  forall definitions public,
  demo_normalize_script_declaration_entry definitions public
    (us_game_init._gDisplayListHead, Gvar us_game_init.v_gDisplayListHead) =
      (us_game_init._gDisplayListHead, Gvar us_game_init.v_gDisplayListHead) /\
  demo_normalize_script_declaration_entry definitions public
    (us_area._gDisplayListHead, Gvar us_area.v_gDisplayListHead) =
      (us_area._gDisplayListHead, Gvar us_area.v_gDisplayListHead) /\
  demo_normalize_script_declaration_entry definitions public
    (jp_game_init._gDisplayListHead, Gvar jp_game_init.v_gDisplayListHead) =
      (jp_game_init._gDisplayListHead, Gvar jp_game_init.v_gDisplayListHead) /\
  demo_normalize_script_declaration_entry definitions public
    (jp_area._gDisplayListHead, Gvar jp_area.v_gDisplayListHead) =
      (jp_area._gDisplayListHead, Gvar jp_area.v_gDisplayListHead).

Theorem generated_demo_gfx_normalization_boundary_us_jp :
  demo_gfx_normalization_boundary_claim_us_jp.
Proof.
  intros definitions public. repeat split;
    apply demo_array_normalization_preserves_pointer_globals.
Qed.

Definition demo_gfx_us_tag_pairs : list (ident * ident) :=
  [(us_game_init.__469, us_area.__533);
   (us_game_init.__510, us_area.__574);
   (us_game_init.__512, us_area.__576);
   (us_game_init.__514, us_area.__578);
   (us_game_init.__516, us_area.__580);
   (us_game_init.__518, us_area.__582);
   (us_game_init.__520, us_area.__584);
   (us_game_init.__522, us_area.__586);
   (us_game_init.__524, us_area.__588);
   (us_game_init.__526, us_area.__590);
   (us_game_init.__528, us_area.__592);
   (us_game_init.__530, us_area.__594);
   (us_game_init.__532, us_area.__596);
   (us_game_init.__534, us_area.__598);
   (us_game_init.__536, us_area.__600);
   (us_game_init.__538, us_area.__602);
   (us_game_init.__547, us_area.__611);
   (us_game_init.__549, us_area.__613)].

Definition demo_gfx_jp_tag_pairs : list (ident * ident) :=
  [(jp_game_init.__510, jp_area.__574);
   (jp_game_init.__512, jp_area.__576)].

Fixpoint demo_gfx_corresponding_tag pairs name :=
  match pairs with
  | [] => name
  | (old, new) :: rest =>
      if Pos.eqb old name then new else demo_gfx_corresponding_tag rest name
  end.

Fixpoint demo_gfx_rename_type (pairs : list (ident * ident)) (ty : type) : type :=
  match ty with
  | Tpointer target attributes => Tpointer (demo_gfx_rename_type pairs target) attributes
  | Tarray element extent attributes => Tarray (demo_gfx_rename_type pairs element) extent attributes
  | Tfunction arguments result convention =>
      Tfunction (map (demo_gfx_rename_type pairs) arguments)
        (demo_gfx_rename_type pairs result) convention
  | Tstruct name attributes => Tstruct (demo_gfx_corresponding_tag pairs name) attributes
  | Tunion name attributes => Tunion (demo_gfx_corresponding_tag pairs name) attributes
  | _ => ty
  end.

Definition demo_gfx_rename_member pairs member_ :=
  match member_ with
  | Member_plain name ty => Member_plain name (demo_gfx_rename_type pairs ty)
  | _ => member_
  end.

Definition demo_gfx_rename_composite pairs composite_ :=
  match composite_ with
  | Composite name kind members_ attributes =>
      Composite (demo_gfx_corresponding_tag pairs name) kind
        (map (demo_gfx_rename_member pairs) members_) attributes
  end.

Definition demo_gfx_find_composite (program_ : Clight.program) name :=
  find (fun definition => Pos.eqb (name_composite_def definition) name)
    (Ctypes.prog_types program_).

Definition demo_gfx_corresponding_definitions (first second : Clight.program) pairs : Prop :=
  map (fun pair => option_map (demo_gfx_rename_composite pairs)
    (demo_gfx_find_composite first (fst pair))) pairs =
  map (fun pair => demo_gfx_find_composite second (snd pair)) pairs.

Definition demo_gfx_layout_header (program_ : Clight.program) name :=
  match PTree.get name (Ctypes.prog_comp_env program_) with
  | None => None
  | Some composite_ => Some
      (co_su composite_, co_attr composite_, co_sizeof composite_,
       co_alignof composite_, co_rank composite_)
  end.

Definition demo_gfx_corresponding_layouts (first second : Clight.program) pairs : Prop :=
  map (fun pair => demo_gfx_layout_header first (fst pair)) pairs =
  map (fun pair => demo_gfx_layout_header second (snd pair)) pairs.

Definition demo_gfx_correspondence_present (first second : Clight.program) pairs : Prop :=
  forallb (fun pair =>
    match demo_gfx_find_composite first (fst pair),
          demo_gfx_find_composite second (snd pair),
          demo_gfx_layout_header first (fst pair),
          demo_gfx_layout_header second (snd pair) with
    | Some _, Some _, Some _, Some _ => true
    | _, _, _, _ => false
    end) pairs = true.

Definition demo_gfx_composite_correspondence_claim_us_jp : Prop :=
  demo_gfx_correspondence_present us_game_init.prog us_area.prog demo_gfx_us_tag_pairs /\
  demo_gfx_correspondence_present jp_game_init.prog jp_area.prog demo_gfx_jp_tag_pairs /\
  demo_gfx_corresponding_definitions us_game_init.prog us_area.prog demo_gfx_us_tag_pairs /\
  demo_gfx_corresponding_definitions jp_game_init.prog jp_area.prog demo_gfx_jp_tag_pairs /\
  demo_gfx_corresponding_layouts us_game_init.prog us_area.prog demo_gfx_us_tag_pairs /\
  demo_gfx_corresponding_layouts jp_game_init.prog jp_area.prog demo_gfx_jp_tag_pairs.

Theorem generated_demo_gfx_composite_correspondence_us_jp :
  demo_gfx_composite_correspondence_claim_us_jp.
Proof. repeat split; vm_compute; reflexivity. Qed.

Definition demo_selected_link_type_boundary_claim_us_jp : Prop :=
  demo_extern_array_completion_boundary_claim_us_jp /\
  demo_gfx_strict_type_link_boundary_claim_us_jp /\
  demo_gfx_normalization_boundary_claim_us_jp /\
  demo_gfx_composite_correspondence_claim_us_jp.

Theorem generated_demo_selected_link_type_boundary_us_jp :
  demo_selected_link_type_boundary_claim_us_jp.
Proof.
  exact (conj generated_demo_extern_array_completion_boundary_us_jp
    (conj generated_demo_gfx_strict_type_link_boundary_us_jp
      (conj generated_demo_gfx_normalization_boundary_us_jp
        generated_demo_gfx_composite_correspondence_us_jp))).
Qed.
