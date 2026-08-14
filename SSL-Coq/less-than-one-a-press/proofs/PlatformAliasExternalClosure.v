(** Official US/JP specialization of the generic platform-alias origin
    classifier.  No live reachability is asserted here. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import
  us_platform_displacement jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms LinkedPlatformLineageSyntax
  PlatformExternalGapSemantics PlatformPointerProvenance.

Import ListNotations.

Module PAEC_USPlatform := us_platform_displacement.
Module PAEC_JPPlatform := jp_platform_displacement.

(** Ordinary internal address-taking and static initializer relocations are
    impossible in both official programs.  Thus any complete alias-origin
    classifier reduces to one of four semantic cases: pre-existing,
    external-produced, integer-fabricated, or out-of-bounds. *)
Theorem official_platform_alias_origins_reduce_to_semantic_escapes :
  (forall origin : PlatformCellAliasOrigin
      us_official_cleaned_slice PAEC_USPlatform._gMarioPlatform,
    exists escape,
      semantic_platform_alias_escape origin = Some escape) /\
  (forall origin : PlatformCellAliasOrigin
      jp_official_cleaned_slice PAEC_JPPlatform._gMarioPlatform,
    exists escape,
      semantic_platform_alias_escape origin = Some escape).
Proof.
  split.
  - eapply no_ordinary_platform_alias_source_leaves_semantic_escape.
    + exact (proj1 official_links_have_no_direct_platform_cell_address_site).
    + exact us_official_initializer_has_no_platform_global_relocation.
  - eapply no_ordinary_platform_alias_source_leaves_semantic_escape.
    + exact (proj2 official_links_have_no_direct_platform_cell_address_site).
    + exact jp_official_initializer_has_no_platform_global_relocation.
Qed.
