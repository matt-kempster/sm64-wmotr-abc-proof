From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Integers
  Linking Maps Values.
From SSLPyramid.Generated Require Import area audio_external graph_node
  level_update mario object_list_processor spawn_object.

Module A := area.
Module AU := audio_external.
Module G := graph_node.
Module L := level_update.
Module M := mario.
Module O := object_list_processor.
Module S := spawn_object.

Lemma linkorder_resolves_internal :
  forall (linked member : Clight.program) (id : ident) (function : Clight.function),
    linkorder member linked ->
    (prog_defmap member) ! id = Some (Gfun (Internal function)) ->
    exists block,
      Genv.find_symbol (globalenv linked) id = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal function).
Proof.
  intros linked member id function Horder Hdefmap.
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in Horder.
  destruct Horder as [Hast _].
  destruct
    (prog_defmap_linkorder _ _ _ _ Hast Hdefmap)
    as (definition & Hlinked_defmap & Hdefinition_order).
  clear Hast.
  inv Hdefinition_order.
  match goal with H : linkorder _ _ |- _ => inv H end.
  apply (proj1 (Genv.find_def_symbol _ _ _)) in Hlinked_defmap.
  destruct Hlinked_defmap as (block & Hsymbol & Hdefinition).
  exists block.
  split.
  - exact Hsymbol.
  - apply (proj2 (Genv.find_funct_ptr_iff _ _ _)).
    exact Hdefinition.
Qed.

Lemma linkorder_resolves_funct :
  forall (linked member : Clight.program) (id : ident) (function : Clight.function),
    linkorder member linked ->
    (prog_defmap member) ! id = Some (Gfun (Internal function)) ->
    exists block,
      Genv.find_symbol (globalenv linked) id = Some block /\
      Genv.find_funct (globalenv linked) (Vptr block Ptrofs.zero) =
      Some (Internal function).
Proof.
  intros linked member id function Horder Hdefmap.
  destruct
    (linkorder_resolves_internal linked member id function Horder Hdefmap)
    as (block & Hsymbol & Hfunction).
  exists block.
  split; [exact Hsymbol |].
  unfold Genv.find_funct.
  destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero) as [_ | Hneq].
  - exact Hfunction.
  - exfalso.
    apply Hneq.
    reflexivity.
Qed.

Record transition_link_members (linked : Clight.program) : Prop := {
  links_level_update : linkorder L.prog linked;
  links_area : linkorder A.prog linked;
  links_object_list_processor : linkorder O.prog linked;
  links_spawn_object : linkorder S.prog linked;
  links_graph_node : linkorder G.prog linked;
  links_mario : linkorder M.prog linked;
  links_audio_external : linkorder AU.prog linked
}.

Lemma level_update_defmap_warp_area :
  (prog_defmap L.prog) ! L._warp_area =
  Some (Gfun (Internal L.f_warp_area)).
Proof. vm_compute; reflexivity. Qed.

Lemma area_defmap_unload_mario_area :
  (prog_defmap A.prog) ! A._unload_mario_area =
  Some (Gfun (Internal A.f_unload_mario_area)).
Proof. vm_compute; reflexivity. Qed.

Lemma area_defmap_unload_area :
  (prog_defmap A.prog) ! A._unload_area =
  Some (Gfun (Internal A.f_unload_area)).
Proof. vm_compute; reflexivity. Qed.

Lemma object_list_defmap_unload_objects_from_area :
  (prog_defmap O.prog) ! O._unload_objects_from_area =
  Some (Gfun (Internal O.f_unload_objects_from_area)).
Proof. vm_compute; reflexivity. Qed.

Lemma spawn_defmap_unload_object :
  (prog_defmap S.prog) ! S._unload_object =
  Some (Gfun (Internal S.f_unload_object)).
Proof. vm_compute; reflexivity. Qed.

Lemma spawn_defmap_deallocate_object :
  (prog_defmap S.prog) ! S._deallocate_object =
  Some (Gfun (Internal S.f_deallocate_object)).
Proof. vm_compute; reflexivity. Qed.

Lemma graph_defmap_geo_remove_child :
  (prog_defmap G.prog) ! G._geo_remove_child =
  Some (Gfun (Internal G.f_geo_remove_child)).
Proof. vm_compute; reflexivity. Qed.

Lemma graph_defmap_geo_add_child :
  (prog_defmap G.prog) ! G._geo_add_child =
  Some (Gfun (Internal G.f_geo_add_child)).
Proof. vm_compute; reflexivity. Qed.

Lemma audio_defmap_stop_sounds_from_source :
  (prog_defmap AU.prog) ! AU._stop_sounds_from_source =
  Some (Gfun (Internal AU.f_stop_sounds_from_source)).
Proof. vm_compute; reflexivity. Qed.

Lemma mario_defmap_init_mario :
  (prog_defmap M.prog) ! M._init_mario =
  Some (Gfun (Internal M.f_init_mario)).
Proof. vm_compute; reflexivity. Qed.

Section TransitionLinkedResolution.

  Variable linked : Clight.program.
  Hypothesis Hmembers : transition_link_members linked.

  Theorem linked_resolves_warp_area :
    exists block,
      Genv.find_symbol (globalenv linked) L._warp_area = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal L.f_warp_area).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_level_update linked Hmembers).
    - exact level_update_defmap_warp_area.
  Qed.

  Theorem linked_resolves_unload_mario_area :
    exists block,
      Genv.find_symbol (globalenv linked) A._unload_mario_area = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal A.f_unload_mario_area).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_area linked Hmembers).
    - exact area_defmap_unload_mario_area.
  Qed.

  Theorem linked_resolves_unload_area :
    exists block,
      Genv.find_symbol (globalenv linked) A._unload_area = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal A.f_unload_area).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_area linked Hmembers).
    - exact area_defmap_unload_area.
  Qed.

  Theorem linked_resolves_unload_objects_from_area :
    exists block,
      Genv.find_symbol (globalenv linked) O._unload_objects_from_area =
      Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal O.f_unload_objects_from_area).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_object_list_processor linked Hmembers).
    - exact object_list_defmap_unload_objects_from_area.
  Qed.

  Theorem linked_resolves_unload_object :
    exists block,
      Genv.find_symbol (globalenv linked) S._unload_object = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal S.f_unload_object).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_spawn_object linked Hmembers).
    - exact spawn_defmap_unload_object.
  Qed.

  Theorem linked_resolves_deallocate_object :
    exists block,
      Genv.find_symbol (globalenv linked) S._deallocate_object = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal S.f_deallocate_object).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_spawn_object linked Hmembers).
    - exact spawn_defmap_deallocate_object.
  Qed.

  Theorem linked_resolves_geo_remove_child :
    exists block,
      Genv.find_symbol (globalenv linked) G._geo_remove_child = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal G.f_geo_remove_child).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_graph_node linked Hmembers).
    - exact graph_defmap_geo_remove_child.
  Qed.

  Theorem linked_resolves_geo_add_child :
    exists block,
      Genv.find_symbol (globalenv linked) G._geo_add_child = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal G.f_geo_add_child).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_graph_node linked Hmembers).
    - exact graph_defmap_geo_add_child.
  Qed.

  Theorem linked_resolves_stop_sounds_from_source :
    exists block,
      Genv.find_symbol (globalenv linked) AU._stop_sounds_from_source =
      Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal AU.f_stop_sounds_from_source).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_audio_external linked Hmembers).
    - exact audio_defmap_stop_sounds_from_source.
  Qed.

  Theorem linked_resolves_non_deallocate_cleanup_helpers :
    (exists block,
      Genv.find_symbol (globalenv linked) AU._stop_sounds_from_source =
      Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal AU.f_stop_sounds_from_source)) /\
    (exists block,
      Genv.find_symbol (globalenv linked) G._geo_remove_child = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal G.f_geo_remove_child)) /\
    (exists block,
      Genv.find_symbol (globalenv linked) G._geo_add_child = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal G.f_geo_add_child)).
  Proof.
    split.
    - apply linked_resolves_stop_sounds_from_source.
    - split.
      + apply linked_resolves_geo_remove_child.
      + apply linked_resolves_geo_add_child.
  Qed.

  Theorem linked_resolves_init_mario :
    exists block,
      Genv.find_symbol (globalenv linked) M._init_mario = Some block /\
      Genv.find_funct_ptr (globalenv linked) block =
      Some (Internal M.f_init_mario).
  Proof.
    eapply linkorder_resolves_internal.
    - exact (links_mario linked Hmembers).
    - exact mario_defmap_init_mario.
  Qed.

End TransitionLinkedResolution.
