From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From Demo.Generated Require Import us_level_scripts jp_level_scripts
 us_bbh_level_script jp_bbh_level_script us_ccm_level_script jp_ccm_level_script
 us_hmc_level_script jp_hmc_level_script us_jrb_level_script jp_jrb_level_script
 us_wf_level_script jp_wf_level_script us_pss_level_script jp_pss_level_script
 us_bowser_1_level_script jp_bowser_1_level_script.
From Demo.Proofs Require Import DemoScriptDispatchFacts DemoScriptNumericImage.
Import ListNotations.
Local Open Scope Z_scope.

(** SOURCE INVENTORY ONLY. Owner keys are resolved through the actual generated
    level-dispatch table. No demo input/header is consulted, and no fact here
    identifies a raw geometry relocation with an allocated GraphNodeRoot.
    Runtime script-image placement, command activation, segmented conversion,
    scene construction and subsequent preservation remain separate work. *)
Record scene_source_area : Type := SceneSourceArea {
 scene_source_owner : Z;
 scene_source_entry : ident;
 scene_source_index : Z;
 scene_source_area_byte_offset : Z;
 scene_source_geo_symbol : ident;
 scene_source_geo_relocation : ptrofs;
 scene_source_terrain_byte_offset : Z;
 scene_source_terrain_symbol : ident;
 scene_source_terrain_relocation : ptrofs
}.

Record scene_source_command : Type := SceneSourceCommand {
 scene_command_word_offset : nat;
 scene_command_words : list init_data
}.
Definition scene_command_byte_offset command : Z :=
 4 * Z.of_nat (scene_command_word_offset command).
Definition scene_word datum : bool :=
 match datum with Init_int32 _ | Init_addrof _ _ => true | _ => false end.
Definition scene_header_opcode word : Z := Z.shiftr (Int.unsigned word) 24.
Definition scene_header_size word : Z := Z.land (Z.shiftr (Int.unsigned word) 16) 255.
Definition scene_good_command words : bool :=
 match words with
 | Init_int32 word :: _ =>
   (scene_header_opcode word <=? 60) && (4 <=? scene_header_size word) &&
   Z.eqb (scene_header_size word mod 4) 0 &&
   Nat.eqb (List.length words) (Z.to_nat (scene_header_size word / 4)) &&
   forallb scene_word words
 | _ => false
 end.

Fixpoint scene_parse_commands fuel position words : option (list scene_source_command) :=
 match words with
 | [] => Some []
 | Init_int32 word :: _ =>
   match fuel with
   | O => None
   | S remaining =>
     let count := Z.to_nat (scene_header_size word / 4) in
     let command := firstn count words in
     if scene_good_command command then
       match scene_parse_commands remaining (position + List.length command)%nat (skipn count words) with
       | Some rest => Some (SceneSourceCommand position command :: rest)
       | None => None
       end
     else None
   end
 | _ => None
 end.

Inductive scene_command_partition : nat -> list init_data -> list scene_source_command -> Prop :=
| scene_partition_nil : forall position, scene_command_partition position [] []
| scene_partition_cons : forall position command rest commands,
 scene_good_command command = true ->
 scene_command_partition (position + List.length command)%nat rest commands ->
 scene_command_partition position (command ++ rest)
   (SceneSourceCommand position command :: commands).

Theorem scene_parse_commands_sound : forall fuel position words commands,
 scene_parse_commands fuel position words = Some commands ->
 scene_command_partition position words commands.
Proof.
 induction fuel as [|fuel IH]; intros position words commands Hparse;
   destruct words as [|datum rest].
 - inversion Hparse; constructor.
 - destruct datum; discriminate.
 - inversion Hparse; constructor.
 - destruct datum; try discriminate. cbn [scene_parse_commands] in Hparse.
   set (count := Z.to_nat (scene_header_size i / 4)) in *.
   set (command := firstn count (Init_int32 i :: rest)) in *.
   destruct (scene_good_command command) eqn:Hgood; [|discriminate].
   destruct (scene_parse_commands fuel (position + List.length command)%nat
     (skipn count (Init_int32 i :: rest))) as [remaining|] eqn:Hremaining; [|discriminate].
   inversion Hparse; subst commands.
   replace (Init_int32 i :: rest) with (command ++ skipn count (Init_int32 i :: rest))
     by (unfold command; apply firstn_skipn).
   constructor; [exact Hgood | eapply IH; exact Hremaining].
Qed.

Definition scene_source_command_at words position command : Prop :=
 exists prefix suffix,
 words = prefix ++ scene_command_words command ++ suffix /\
 scene_command_word_offset command = (position + List.length prefix)%nat /\
 scene_good_command (scene_command_words command) = true.

Theorem scene_partition_has_exact_command : forall position words commands,
 scene_command_partition position words commands ->
 forall command, In command commands -> scene_source_command_at words position command.
Proof.
 intros position words commands Hpartition. induction Hpartition; intros selected Hin.
 - contradiction.
 - destruct Hin as [Heq|Hin].
   + subst selected. exists [], rest. cbn. repeat split; auto; lia.
   + destruct (IHHpartition selected Hin) as (prefix & suffix & Hwords & Hoffset & Hgood).
     exists (command ++ prefix), suffix. cbn in *. split.
     * rewrite Hwords. repeat rewrite app_assoc. reflexivity.
     * split; [rewrite app_length; lia | exact Hgood].
Qed.

Lemma scene_word_has_four_bytes : forall datum,
 scene_word datum = true -> init_data_size datum = 4.
Proof. destruct datum; cbn [scene_word init_data_size]; intros; try discriminate; reflexivity. Qed.

Lemma scene_word_list_has_exact_bytes : forall words,
 forallb scene_word words = true -> init_data_list_size words = 4 * Z.of_nat (List.length words).
Proof.
 induction words as [|word words IH]; intros Hwords; [reflexivity |].
 apply Bool.andb_true_iff in Hwords as [Hword Hwords].
 cbn [init_data_list_size List.length]. rewrite (scene_word_has_four_bytes word Hword), (IH Hwords).
 rewrite Nat2Z.inj_succ. lia.
Qed.

Lemma scene_partition_contains_only_words : forall position words commands,
 scene_command_partition position words commands -> forallb scene_word words = true.
Proof.
 intros position words commands Hpartition. induction Hpartition; [reflexivity |].
 rewrite forallb_app. apply Bool.andb_true_iff. split; [|exact IHHpartition].
 destruct command as [|datum operands]; [discriminate |]. destruct datum; try discriminate.
 unfold scene_good_command in H. apply Bool.andb_true_iff in H as [_ Hwords]. exact Hwords.
Qed.

Theorem scene_partition_command_byte_location : forall words commands command,
 scene_command_partition O words commands -> In command commands ->
 exists prefix suffix,
 words = prefix ++ scene_command_words command ++ suffix /\
 scene_command_byte_offset command = init_data_list_size prefix.
Proof.
 intros words commands command Hpartition Hin.
 destruct (scene_partition_has_exact_command _ _ _ Hpartition command Hin)
   as (prefix & suffix & Hwords & Hoffset & Hgood).
 pose proof (scene_partition_contains_only_words _ _ _ Hpartition) as Hall.
 rewrite Hwords, forallb_app in Hall. apply Bool.andb_true_iff in Hall as [Hprefix _].
 exists prefix, suffix. split; [exact Hwords |].
 unfold scene_command_byte_offset. rewrite Hoffset. cbn [Nat.add].
 symmetry. apply scene_word_list_has_exact_bytes. exact Hprefix.
Qed.

Definition scene_opcode command : Z :=
 match scene_command_words command with Init_int32 word :: _ => scene_header_opcode word | _ => -1 end.
Definition scene_nonstructural command : Prop :=
 scene_opcode command <> 31 /\ scene_opcode command <> 32 /\ scene_opcode command <> 46.
Definition scene_decode_area command : option (Z * ident * ptrofs) :=
 match scene_command_words command with
 | [Init_int32 word; Init_addrof geometry offset] =>
   let index := Z.land (Z.shiftr (Int.unsigned word) 8) 255 in
   if dispatch_header_is word 31 8 index 0 then Some (index,geometry,offset) else None
 | _ => None
 end.
Definition scene_decode_terrain command : option (ident * ptrofs) :=
 match scene_command_words command with
 | [Init_int32 word; Init_addrof terrain offset] =>
   if dispatch_header_is word 46 8 0 0 then Some (terrain,offset) else None
 | _ => None
 end.
Definition scene_decode_end command : bool :=
 match scene_command_words command with
 | [Init_int32 word] => dispatch_header_is word 32 4 0 0
 | _ => false
 end.

Fixpoint scene_find_area_end commands : option (scene_source_command * list scene_source_command) :=
 match commands with
 | [] => None
 | command :: rest =>
   if Z.eqb (scene_opcode command) 32 then
     if scene_decode_end command then Some (command,rest) else None
   else if Z.eqb (scene_opcode command) 31 || Z.eqb (scene_opcode command) 46 then None
   else scene_find_area_end rest
 end.

Record scene_area_body := SceneAreaBody {
 scene_body_terrain_command : scene_source_command;
 scene_body_terrain_symbol : ident;
 scene_body_terrain_relocation : ptrofs;
 scene_body_end_command : scene_source_command;
 scene_body_remaining : list scene_source_command
}.

Fixpoint scene_find_area_terrain commands : option scene_area_body :=
 match commands with
 | [] => None
 | command :: rest =>
   if Z.eqb (scene_opcode command) 46 then
     match scene_decode_terrain command, scene_find_area_end rest with
     | Some (terrain,offset), Some (ending,suffix) =>
       Some (SceneAreaBody command terrain offset ending suffix)
     | _, _ => None
     end
   else if Z.eqb (scene_opcode command) 31 || Z.eqb (scene_opcode command) 32 then None
   else scene_find_area_terrain rest
 end.

Record scene_area_clause := SceneAreaClause {
 scene_clause_area_command : scene_source_command;
 scene_clause_index : Z;
 scene_clause_geo_symbol : ident;
 scene_clause_geo_relocation : ptrofs;
 scene_clause_terrain_command : scene_source_command;
 scene_clause_terrain_symbol : ident;
 scene_clause_terrain_relocation : ptrofs;
 scene_clause_end_command : scene_source_command
}.

Fixpoint scene_parse_area_clauses fuel commands : option (list scene_area_clause) :=
 match commands with
 | [] => Some []
 | command :: rest =>
   match fuel with
   | O => None
   | S remaining =>
     if Z.eqb (scene_opcode command) 31 then
       match scene_decode_area command, scene_find_area_terrain rest with
       | Some (index,geometry,offset), Some body =>
         match scene_parse_area_clauses remaining (scene_body_remaining body) with
         | Some suffix => Some (SceneAreaClause command index geometry offset
             (scene_body_terrain_command body) (scene_body_terrain_symbol body)
             (scene_body_terrain_relocation body) (scene_body_end_command body) :: suffix)
         | None => None
         end
       | _, _ => None
       end
     else if Z.eqb (scene_opcode command) 32 || Z.eqb (scene_opcode command) 46 then None
     else scene_parse_area_clauses remaining rest
   end
 end.

Definition scene_clause_descriptor owner entry clause : scene_source_area :=
 SceneSourceArea owner entry (scene_clause_index clause)
   (scene_command_byte_offset (scene_clause_area_command clause))
   (scene_clause_geo_symbol clause) (scene_clause_geo_relocation clause)
   (scene_command_byte_offset (scene_clause_terrain_command clause))
   (scene_clause_terrain_symbol clause) (scene_clause_terrain_relocation clause).

Definition scene_dispatch_definitions (us : bool) :=
 if us then us_level_scripts.global_definitions else jp_level_scripts.global_definitions.
Definition scene_selected_definitions (us : bool) : list (ident * globdef Clight.fundef type) :=
 if us then us_bbh_level_script.global_definitions ++ us_ccm_level_script.global_definitions ++
   us_hmc_level_script.global_definitions ++ us_jrb_level_script.global_definitions ++
   us_wf_level_script.global_definitions ++ us_pss_level_script.global_definitions ++
   us_bowser_1_level_script.global_definitions
 else jp_bbh_level_script.global_definitions ++ jp_ccm_level_script.global_definitions ++
   jp_hmc_level_script.global_definitions ++ jp_jrb_level_script.global_definitions ++
   jp_wf_level_script.global_definitions ++ jp_pss_level_script.global_definitions ++
   jp_bowser_1_level_script.global_definitions.

Definition checked_scene_source_areas us owner : option (list scene_source_area) :=
 match checked_level_dispatch_route (scene_dispatch_definitions us) owner with
 | Some (_,entry) =>
   match lookup_script_initializer entry (scene_selected_definitions us) with
   | Some words =>
     match scene_parse_commands (List.length words) O words with
     | Some commands =>
       match scene_parse_area_clauses (List.length commands) commands with
       | Some clauses => Some (map (scene_clause_descriptor owner entry) clauses)
       | None => None
       end
     | None => None
     end
   | None => None
   end
 | None => None
 end.

Definition scene_source_area_checked us descriptor : Prop :=
 exists rows, checked_scene_source_areas us (scene_source_owner descriptor) = Some rows /\
   In descriptor rows.

Lemma scene_find_area_end_sound : forall commands ending suffix,
 scene_find_area_end commands = Some (ending,suffix) ->
 exists middle, commands = middle ++ ending :: suffix /\
   Forall scene_nonstructural middle /\ scene_decode_end ending = true.
Proof.
 induction commands as [|command commands IH]; intros ending suffix Hparse; [discriminate |].
 cbn [scene_find_area_end] in Hparse.
 destruct (Z.eqb (scene_opcode command) 32) eqn:H32.
 - destruct (scene_decode_end command) eqn:Hend; [|discriminate].
   inversion Hparse; subst ending suffix. exists []. cbn. repeat split; auto.
 - destruct (Z.eqb (scene_opcode command) 31 || Z.eqb (scene_opcode command) 46) eqn:Hother;
     [discriminate |].
   destruct (IH ending suffix Hparse) as (middle & Hcommands & Hmiddle & Hend).
   exists (command :: middle). cbn. split; [rewrite Hcommands; reflexivity |].
   split; [|exact Hend]. constructor; [|exact Hmiddle].
   apply Bool.orb_false_iff in Hother as [H31 H46].
   apply Z.eqb_neq in H31, H32, H46. unfold scene_nonstructural. auto.
Qed.

Lemma scene_find_area_terrain_sound : forall commands body,
 scene_find_area_terrain commands = Some body ->
 exists before after,
 commands = before ++ scene_body_terrain_command body ::
   (after ++ scene_body_end_command body :: scene_body_remaining body) /\
 Forall scene_nonstructural before /\ Forall scene_nonstructural after /\
 scene_decode_terrain (scene_body_terrain_command body) =
   Some (scene_body_terrain_symbol body,scene_body_terrain_relocation body) /\
 scene_decode_end (scene_body_end_command body) = true.
Proof.
 induction commands as [|command commands IH]; intros body Hparse; [discriminate |].
 cbn [scene_find_area_terrain] in Hparse.
 destruct (Z.eqb (scene_opcode command) 46) eqn:H46.
 - destruct (scene_decode_terrain command) as [[terrain offset]|] eqn:Hterrain; [|discriminate].
   destruct (scene_find_area_end commands) as [[ending suffix]|] eqn:Hending; [|discriminate].
   inversion Hparse; subst body.
   destruct (scene_find_area_end_sound commands ending suffix Hending) as (middle & Hmiddle & Hnormal & Hend).
   exists [], middle. cbn. split; [rewrite Hmiddle; reflexivity |]. repeat split; auto.
 - destruct (Z.eqb (scene_opcode command) 31 || Z.eqb (scene_opcode command) 32) eqn:Hother;
     [discriminate |].
   destruct (IH body Hparse) as (before & after & Hcommands & Hbefore & Hafter & Hterrain & Hend).
   exists (command :: before), after. cbn. split; [rewrite Hcommands; reflexivity |].
   split.
   + constructor; [|exact Hbefore]. apply Bool.orb_false_iff in Hother as [H31 H32].
     apply Z.eqb_neq in H31, H32, H46. unfold scene_nonstructural. auto.
   + auto.
Qed.

(** This describes declaration syntax and its enclosing AREA/END_AREA scope,
    not control-flow reachability or execution of called scripts. *)
Definition scene_area_clause_in commands clause : Prop :=
 exists before middle1 middle2 after,
 commands = before ++ scene_clause_area_command clause ::
   (middle1 ++ scene_clause_terrain_command clause ::
     (middle2 ++ scene_clause_end_command clause :: after)) /\
 scene_decode_area (scene_clause_area_command clause) =
   Some (scene_clause_index clause,scene_clause_geo_symbol clause,scene_clause_geo_relocation clause) /\
 scene_decode_terrain (scene_clause_terrain_command clause) =
   Some (scene_clause_terrain_symbol clause,scene_clause_terrain_relocation clause) /\
 scene_decode_end (scene_clause_end_command clause) = true /\
 Forall scene_nonstructural middle1 /\ Forall scene_nonstructural middle2.

Theorem scene_parse_area_clauses_sound : forall fuel commands clauses,
 scene_parse_area_clauses fuel commands = Some clauses ->
 forall clause, In clause clauses -> scene_area_clause_in commands clause.
Proof.
 induction fuel as [|fuel IH]; intros commands clauses Hparse clause Hin;
   destruct commands as [|command commands].
 - inversion Hparse; subst clauses; contradiction.
 - discriminate.
 - inversion Hparse; subst clauses; contradiction.
 - { cbn [scene_parse_area_clauses] in Hparse.
 destruct (Z.eqb (scene_opcode command) 31) eqn:H31.
 - destruct (scene_decode_area command) as [[[index geometry] offset]|] eqn:Harea; [|discriminate].
   destruct (scene_find_area_terrain commands) as [body|] eqn:Hbody; [|discriminate].
   destruct (scene_parse_area_clauses fuel (scene_body_remaining body)) as [remaining|] eqn:Hremaining;
     [|discriminate].
   inversion Hparse; subst clauses. destruct Hin as [Hequal|Hin].
   + subst clause. destruct (scene_find_area_terrain_sound commands body Hbody)
       as (middle1 & middle2 & Hcommands & Hnormal1 & Hnormal2 & Hterrain & Hend).
     exists [], middle1, middle2, (scene_body_remaining body). cbn.
     split; [rewrite Hcommands; reflexivity |]. repeat split; auto.
   + destruct (IH _ _ Hremaining clause Hin) as (before & middle1 & middle2 & after &
       Hsuffix & Hbegin & Hterrain & Hend & Hnormal1 & Hnormal2).
     destruct (scene_find_area_terrain_sound commands body Hbody)
       as (body1 & body2 & Hcommands & Hbody1 & Hbody2 & Hbodyterrain & Hbodyend).
     exists (command :: (body1 ++ scene_body_terrain_command body ::
       (body2 ++ scene_body_end_command body :: before))), middle1, middle2, after.
     split.
     * rewrite Hcommands, Hsuffix. cbn. repeat (rewrite <- app_assoc; cbn). reflexivity.
     * auto.
 - destruct (Z.eqb (scene_opcode command) 32 || Z.eqb (scene_opcode command) 46);
     [discriminate |].
   destruct (IH _ _ Hparse clause Hin) as (before & middle1 & middle2 & after &
     Hcommands & Hbegin & Hterrain & Hend & Hnormal1 & Hnormal2).
   exists (command :: before), middle1, middle2, after. cbn. split.
   + rewrite Hcommands. reflexivity.
   + auto.
 }
Qed.

Lemma scene_area_clause_commands_in : forall commands clause,
 scene_area_clause_in commands clause ->
 In (scene_clause_area_command clause) commands /\
 In (scene_clause_terrain_command clause) commands /\
 In (scene_clause_end_command clause) commands.
Proof.
 intros commands clause (before & middle1 & middle2 & after & Hcommands & Hrest).
 rewrite Hcommands. repeat first [rewrite in_app_iff | progress cbn]. tauto.
Qed.

Definition scene_source_area_evidence us descriptor : Prop :=
 exists dispatch words commands clause,
 checked_level_dispatch_route (scene_dispatch_definitions us) (scene_source_owner descriptor) =
   Some (dispatch,scene_source_entry descriptor) /\
 lookup_script_initializer (scene_source_entry descriptor) (scene_selected_definitions us) = Some words /\
 scene_command_partition O words commands /\
 scene_area_clause_in commands clause /\
 descriptor = scene_clause_descriptor (scene_source_owner descriptor) (scene_source_entry descriptor) clause /\
 scene_source_command_at words O (scene_clause_area_command clause) /\
 scene_source_command_at words O (scene_clause_terrain_command clause) /\
 scene_source_command_at words O (scene_clause_end_command clause).

Theorem checked_scene_source_area_has_source_evidence : forall us descriptor,
 scene_source_area_checked us descriptor -> scene_source_area_evidence us descriptor.
Proof.
 intros us descriptor (rows & Hchecked & Hin).
 unfold checked_scene_source_areas in Hchecked.
 destruct (checked_level_dispatch_route (scene_dispatch_definitions us) (scene_source_owner descriptor))
   as [[dispatch entry]|] eqn:Hdispatch; [|discriminate].
 destruct (lookup_script_initializer entry (scene_selected_definitions us)) as [words|] eqn:Hwords;
   [|discriminate].
 destruct (scene_parse_commands (List.length words) O words) as [commands|] eqn:Hcommands;
   [|discriminate].
 destruct (scene_parse_area_clauses (List.length commands) commands) as [clauses|] eqn:Hclauses;
   [|discriminate].
 inversion Hchecked; subst rows. apply in_map_iff in Hin as (clause & Hdescriptor & Hin).
 assert (Hentry : scene_source_entry descriptor = entry).
 { rewrite <- Hdescriptor. reflexivity. }
 pose proof (scene_parse_commands_sound _ _ _ _ Hcommands) as Hpartition.
 pose proof (scene_parse_area_clauses_sound _ _ _ Hclauses clause Hin) as Hclause.
 destruct (scene_area_clause_commands_in _ _ Hclause) as [Hbegin [Hterrain Hend]].
 exists dispatch, words, commands, clause. rewrite Hentry. split; [exact Hdispatch |].
 split; [exact Hwords |]. split; [exact Hpartition |]. split; [exact Hclause |]. split.
 - symmetry. exact Hdescriptor.
 - repeat split; eapply scene_partition_has_exact_command; eassumption.
Qed.

Lemma scene_decode_area_has_exact_relocation : forall command index geometry offset,
 scene_decode_area command = Some (index,geometry,offset) ->
 exists word, scene_command_words command = [Init_int32 word;Init_addrof geometry offset] /\
   dispatch_header_is word 31 8 index 0 = true.
Proof.
 intros command index geometry offset Hdecode. unfold scene_decode_area in Hdecode.
  destruct (scene_command_words command) as [|a [|b [|c rest]]] eqn:Hwords.
 all: repeat match type of Hdecode with
 | context [match ?datum with _ => _ end] =>
   is_var datum; destruct datum; cbn -[dispatch_header_is] in Hdecode; try discriminate
 end.
 all: try discriminate.
 all: match type of Hdecode with
 | context [if ?test then _ else _] => destruct test eqn:Hheader
 end; try discriminate.
 all: inversion Hdecode; subst; eexists; split; first [reflexivity | eassumption].
Qed.

Lemma scene_decode_terrain_has_exact_relocation : forall command terrain offset,
 scene_decode_terrain command = Some (terrain,offset) ->
 exists word, scene_command_words command = [Init_int32 word;Init_addrof terrain offset] /\
   dispatch_header_is word 46 8 0 0 = true.
Proof.
 intros command terrain offset Hdecode. unfold scene_decode_terrain in Hdecode.
  destruct (scene_command_words command) as [|a [|b [|c rest]]] eqn:Hwords.
 all: repeat match type of Hdecode with
 | context [match ?datum with _ => _ end] =>
   is_var datum; destruct datum; cbn -[dispatch_header_is] in Hdecode; try discriminate
 end.
 all: try discriminate.
 all: match type of Hdecode with
 | context [if ?test then _ else _] => destruct test eqn:Hheader
 end; try discriminate.
 all: inversion Hdecode; subst; eexists; split; first [reflexivity | eassumption].
Qed.

(** Explicit complete results for the selected entries. All names below are
    generated relocation identifiers; the checker above first independently
    resolves each owner's dispatch entry. There are nine areas per version. *)
Definition scene_selected_owner_keys : list Z := [4;5;7;12;24;27;30].
Definition scene_expected_source_areas : list scene_source_area :=
 [SceneSourceArea 4 us_level_scripts._level_bbh_entry 1 224
   us_bbh_level_script._geo_bbh_000F00 Ptrofs.zero 312
   us_bbh_level_script._bbh_seg7_collision_level Ptrofs.zero;
  SceneSourceArea 5 us_level_scripts._level_ccm_entry 1 244
   us_ccm_level_script._ccm_geo_00051C Ptrofs.zero 428
   us_ccm_level_script._ccm_seg7_area_1_collision Ptrofs.zero;
  SceneSourceArea 5 us_level_scripts._level_ccm_entry 2 464
   us_ccm_level_script._ccm_geo_0005E8 Ptrofs.zero 536
   us_ccm_level_script._ccm_seg7_area_2_collision Ptrofs.zero;
  SceneSourceArea 7 us_level_scripts._level_hmc_entry 1 220
   us_hmc_level_script._hmc_geo_000B90 Ptrofs.zero 340
   us_hmc_level_script._hmc_seg7_collision_level Ptrofs.zero;
  SceneSourceArea 12 us_level_scripts._level_jrb_entry 1 252
   us_jrb_level_script._jrb_geo_000A18 Ptrofs.zero 352
   us_jrb_level_script._jrb_seg7_area_1_collision Ptrofs.zero;
  SceneSourceArea 12 us_level_scripts._level_jrb_entry 2 384
   us_jrb_level_script._jrb_geo_000AFC Ptrofs.zero 456
   us_jrb_level_script._jrb_seg7_area_2_collision Ptrofs.zero;
  SceneSourceArea 24 us_level_scripts._level_wf_entry 1 400
   us_wf_level_script._wf_geo_000BF8 Ptrofs.zero 552
   us_wf_level_script._wf_seg7_collision_070102D8 Ptrofs.zero;
  SceneSourceArea 27 us_level_scripts._level_pss_entry 1 108
   us_pss_level_script._pss_geo_000100 Ptrofs.zero 172
   us_pss_level_script._pss_seg7_collision Ptrofs.zero;
  SceneSourceArea 30 us_level_scripts._level_bowser_1_entry 1 84
   us_bowser_1_level_script._bowser_1_geo_0000D0 Ptrofs.zero 140
   us_bowser_1_level_script._bowser_1_seg7_collision_level Ptrofs.zero].

Definition scene_expected_owner_areas owner : list scene_source_area :=
 filter (fun area => Z.eqb (scene_source_owner area) owner) scene_expected_source_areas.
Definition scene_source_inventory_claim_us_jp : Prop :=
 map (checked_scene_source_areas true) scene_selected_owner_keys =
   map (fun owner => Some (scene_expected_owner_areas owner)) scene_selected_owner_keys /\
 map (checked_scene_source_areas false) scene_selected_owner_keys =
   map (fun owner => Some (scene_expected_owner_areas owner)) scene_selected_owner_keys /\
 checked_scene_source_areas true 17 = None /\ checked_scene_source_areas false 17 = None.

Theorem generated_scene_source_inventory_us_jp : scene_source_inventory_claim_us_jp.
Proof. vm_compute. repeat split; reflexivity. Qed.

(* BEGIN CHECKED SCENE NATIVE FIXTURE *)
(** Mechanically checked against docs/notes/script-images.json and
    each actual generated AREA/TERRAIN operand. ROM/ELF authentication
    precedes this check externally; no native execution is asserted. *)
Definition scene_us_native_relocations : list (ident * int) :=
 [(us_bbh_level_script._geo_bbh_000F00,Int.repr 234884864);
  (us_bbh_level_script._bbh_seg7_collision_level,Int.repr 117573536);
  (us_ccm_level_script._ccm_geo_00051C,Int.repr 234882348);
  (us_ccm_level_script._ccm_seg7_area_1_collision,Int.repr 117520616);
  (us_ccm_level_script._ccm_geo_0005E8,Int.repr 234882552);
  (us_ccm_level_script._ccm_seg7_area_2_collision,Int.repr 117573760);
  (us_hmc_level_script._hmc_geo_000B90,Int.repr 234883984);
  (us_hmc_level_script._hmc_seg7_collision_level,Int.repr 117593492);
  (us_jrb_level_script._jrb_geo_000A18,Int.repr 234883608);
  (us_jrb_level_script._jrb_seg7_area_1_collision,Int.repr 117485656);
  (us_jrb_level_script._jrb_geo_000AFC,Int.repr 234883836);
  (us_jrb_level_script._jrb_seg7_area_2_collision,Int.repr 117507512);
  (us_wf_level_script._wf_geo_000BF8,Int.repr 234884088);
  (us_wf_level_script._wf_seg7_collision_070102D8,Int.repr 117506776);
  (us_pss_level_script._pss_geo_000100,Int.repr 234881280);
  (us_pss_level_script._pss_seg7_collision,Int.repr 117499024);
  (us_bowser_1_level_script._bowser_1_geo_0000D0,Int.repr 234881232);
  (us_bowser_1_level_script._bowser_1_seg7_collision_level,Int.repr 117450808)].
Definition scene_jp_native_relocations : list (ident * int) :=
 [(jp_bbh_level_script._geo_bbh_000F00,Int.repr 234884864);
  (jp_bbh_level_script._bbh_seg7_collision_level,Int.repr 117573536);
  (jp_ccm_level_script._ccm_geo_00051C,Int.repr 234882332);
  (jp_ccm_level_script._ccm_seg7_area_1_collision,Int.repr 117520616);
  (jp_ccm_level_script._ccm_geo_0005E8,Int.repr 234882536);
  (jp_ccm_level_script._ccm_seg7_area_2_collision,Int.repr 117573760);
  (jp_hmc_level_script._hmc_geo_000B90,Int.repr 234883984);
  (jp_hmc_level_script._hmc_seg7_collision_level,Int.repr 117593492);
  (jp_jrb_level_script._jrb_geo_000A18,Int.repr 234883608);
  (jp_jrb_level_script._jrb_seg7_area_1_collision,Int.repr 117485656);
  (jp_jrb_level_script._jrb_geo_000AFC,Int.repr 234883836);
  (jp_jrb_level_script._jrb_seg7_area_2_collision,Int.repr 117507512);
  (jp_wf_level_script._wf_geo_000BF8,Int.repr 234884088);
  (jp_wf_level_script._wf_seg7_collision_070102D8,Int.repr 117506776);
  (jp_pss_level_script._pss_geo_000100,Int.repr 234881280);
  (jp_pss_level_script._pss_seg7_collision,Int.repr 117499024);
  (jp_bowser_1_level_script._bowser_1_geo_0000D0,Int.repr 234881232);
  (jp_bowser_1_level_script._bowser_1_seg7_collision_level,Int.repr 117450808)].
Definition scene_source_native_operand (us : bool) (descriptor : scene_source_area) (is_geometry : bool) : option int :=
 demo_numeric_initializer_word
   (if us then scene_us_native_relocations else scene_jp_native_relocations)
   (if is_geometry then Init_addrof (scene_source_geo_symbol descriptor)
      (scene_source_geo_relocation descriptor)
    else Init_addrof (scene_source_terrain_symbol descriptor)
      (scene_source_terrain_relocation descriptor)).
Definition scene_us_expected_native_operands : list (option int * option int) :=
 [(Some (Int.repr 234884864),Some (Int.repr 117573536));
  (Some (Int.repr 234882348),Some (Int.repr 117520616));
  (Some (Int.repr 234882552),Some (Int.repr 117573760));
  (Some (Int.repr 234883984),Some (Int.repr 117593492));
  (Some (Int.repr 234883608),Some (Int.repr 117485656));
  (Some (Int.repr 234883836),Some (Int.repr 117507512));
  (Some (Int.repr 234884088),Some (Int.repr 117506776));
  (Some (Int.repr 234881280),Some (Int.repr 117499024));
  (Some (Int.repr 234881232),Some (Int.repr 117450808))].
Definition scene_jp_expected_native_operands : list (option int * option int) :=
 [(Some (Int.repr 234884864),Some (Int.repr 117573536));
  (Some (Int.repr 234882332),Some (Int.repr 117520616));
  (Some (Int.repr 234882536),Some (Int.repr 117573760));
  (Some (Int.repr 234883984),Some (Int.repr 117593492));
  (Some (Int.repr 234883608),Some (Int.repr 117485656));
  (Some (Int.repr 234883836),Some (Int.repr 117507512));
  (Some (Int.repr 234884088),Some (Int.repr 117506776));
  (Some (Int.repr 234881280),Some (Int.repr 117499024));
  (Some (Int.repr 234881232),Some (Int.repr 117450808))].
Definition scene_source_native_operand_claim_us_jp : Prop :=
 map (fun descriptor => (scene_source_native_operand true descriptor true,
   scene_source_native_operand true descriptor false)) scene_expected_source_areas =
   scene_us_expected_native_operands /\
 map (fun descriptor => (scene_source_native_operand false descriptor true,
   scene_source_native_operand false descriptor false)) scene_expected_source_areas =
   scene_jp_expected_native_operands.
Theorem generated_scene_source_native_operands_us_jp : scene_source_native_operand_claim_us_jp.
Proof. vm_compute. split; reflexivity. Qed.
(* END CHECKED SCENE NATIVE FIXTURE *)
