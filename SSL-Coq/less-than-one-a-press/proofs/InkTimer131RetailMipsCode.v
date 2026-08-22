(**
  Complete retail-JP instruction manifest for the three pre-entry routines
  that remain abstract in the selected Clight translation.

  This file deliberately reasons about the authenticated IDO-produced MIPS
  bytes, not about a CompCert reconstruction.  The companion instrumentation
  verifier hash-gates the original-JP ROM and compares every word in these
  eight ranges.  Scanning the complete ranges (rather than an observed path)
  proves that every store and every possible call/control escape is present
  in the finite manifests below.
*)

From Coq Require Import Bool List ZArith.

Import ListNotations.
Local Open Scope Z_scope.

Record JPMipsCodeRange : Type := {
  jp_mips_range_start : Z;
  jp_mips_range_end : Z;
  jp_mips_range_words : list Z
}.

Fixpoint jp_enumerate_words (pc : Z) (words : list Z) : list (Z * Z) :=
  match words with
  | [] => []
  | word :: rest => (pc, word) :: jp_enumerate_words (pc + 4) rest
  end.

Definition jp_mips_opcode (word : Z) : Z := Z.shiftr word 26.
Definition jp_mips_rs (word : Z) : Z := Z.land (Z.shiftr word 21) 31.
Definition jp_mips_rt (word : Z) : Z := Z.land (Z.shiftr word 16) 31.
Definition jp_mips_funct (word : Z) : Z := Z.land word 63.

(** VR4300 memory-store opcodes: integer stores [0x28..0x2e] and the
    conditional/COP/doubleword stores [0x38..0x3f].  [cache] and the load
    opcodes between those intervals are intentionally not classified as RAM
    stores. *)
Definition jp_mips_is_store (word : Z) : bool :=
  let opcode := jp_mips_opcode word in
  ((40 <=? opcode) && (opcode <=? 46)) ||
  ((56 <=? opcode) && (opcode <=? 63)).

Definition jp_mips_is_jal (word : Z) : bool :=
  jp_mips_opcode word =? 3.

Definition jp_mips_is_plain_jump (word : Z) : bool :=
  jp_mips_opcode word =? 2.

Definition jp_mips_is_jalr (word : Z) : bool :=
  (jp_mips_opcode word =? 0) && (jp_mips_funct word =? 9).

Definition jp_mips_is_jr (word : Z) : bool :=
  (jp_mips_opcode word =? 0) && (jp_mips_funct word =? 8).

Definition jp_mips_is_linking_branch (word : Z) : bool :=
  (jp_mips_opcode word =? 1) &&
  ((16 <=? jp_mips_rt word) && (jp_mips_rt word <=? 19)).

Definition jp_mips_is_relative_branch (word : Z) : bool :=
  let opcode := jp_mips_opcode word in
  (opcode =? 1) ||
  ((4 <=? opcode) && (opcode <=? 7)) ||
  ((20 <=? opcode) && (opcode <=? 23)) ||
  ((opcode =? 17) && (jp_mips_rs word =? 8)).

Definition jp_mips_sign_extend_16 (word : Z) : Z :=
  let immediate := Z.land word 65535 in
  if 32768 <=? immediate then immediate - 65536 else immediate.

Definition jp_mips_relative_target (pc word : Z) : Z :=
  pc + 4 + 4 * jp_mips_sign_extend_16 word.

Definition jp_mips_jump_target (pc word : Z) : Z :=
  Z.lor (Z.land (pc + 4) 4026531840)
        (Z.shiftl (Z.land word 67108863) 2).

Definition jp_sqrtf_words : list Z :=
  [65011720; 1174429700].

Definition jp_stop_sounds_from_source_words : list Z :=
  [666763208; 2947940396; 2948005936; 2947874856; 2947809316;
   2947743776; 2947678236; 1008107574; 8429605; 2948530228;
   2947612696; 2947547156; 651562056; 36901; 605225215;
   605356060; 605488224; 39256089; 1228992; 51560481; 1622144;
   51560483; 1622336; 47745057; 28690; 47085601; 2447704091;
   1382350862; 642908161; 11862041; 51218; 37322785; 2382888960;
   1451753477; 2449801243; 202143801; 843317503; 2919235604;
   2449801243; 375783413; 0; 642908161; 843645183; 690028554;
   337706980; 18911269; 2411659316; 2410676244; 2410741784;
   2410807324; 2410872864; 2410938404; 2411003944; 2411069484;
   2411135024; 65011720; 666697784].

Definition jp_stop_sounds_in_bank_words : list Z :=
  [666763216; 2947612700; 814809343; 1142976; 30502945; 946304;
   30502947; 1007648822; 636423240; 946496; 2948530220; 2947809320;
   2947743780; 2947678240; 2947547160; 2946760752; 30392353;
   2467299355; 605225215; 1165504; 309329936; 53594145; 1689728;
   53594147; 1689920; 53448737; 605290524; 841220351; 202143801;
   839188735; 34865177; 16402; 38277153; 2421162011; 2889875476;
   1450246136; 841220351; 2411659308; 2410676248; 2410741788;
   2410807328; 2410872868; 2410938408; 65011720; 666697776].

Definition jp_stop_sounds_in_continuous_banks_words : list Z :=
  [666763240; 2948530196; 202146295; 604241921; 202146295; 604241924;
   202146295; 604241926; 2411659284; 666697752; 65011720; 0].

Definition jp_update_background_music_after_sound_words : list Z :=
  [814088447; 424128; 816709887; 31881249; 1013888; 966848; 51298339;
   31881251; 1014080; 1622144; 33081377; 1007190070; 18432033;
   2366114908; 666763240; 2948530196; 822673424; 2946760728;
   287309835; 2946826268; 1006796851; 608313616; 2487877632;
   604700673; 13328388; 965607423; 21852196; 2756575232;
   202145849; 604241970; 2411659284; 666697752; 65011720; 0].

Definition jp_begin_background_music_fade_words : list Z :=
  [1007190067; 2433228956; 666763232; 604569855; 2948530196;
   2946760736; 814088191; 287834116; 604373247; 604045338;
   352387075; 1007124514; 268435528; 604111103; 619129368;
   3303407648; 1149247488; 1006796854; 1008238646; 1174806578;
   1008304179; 1157627909; 0; 278921219; 0; 3303538712;
   3840409632; 2420258834; 272629764; 0; 4206629; 818806911;
   29372453; 1006796851; 2420252956; 272629765; 810483839;
   31852586; 270532610; 0; 837157119; 2467837971; 683737129;
   318767108; 0; 337641474; 0; 604373032; 2537103632;
   683737109; 1394606085; 2364145664; 1411383299; 2364145664;
   604373012; 2364145664; 604045313; 679874; 1432420378;
   12587045; 287703046; 1007452211; 8229; 202143246; 2745565215;
   268435474; 2477129759; 25714721; 2441879672; 1006718848;
   1150046208; 92340228; 1182815264; 1149341696; 0; 1175618560;
   1006715646; 1149313024; 8229; 2745565215; 1174700419;
   202143212; 3840278560; 2477129759; 12587045; 2411659284;
   666697760; 65011720; 0].

Definition jp_fade_helper_restore_words : list Z :=
  [292992; 31750177; 1008238626; 655895064; 1014144; 33034273;
   2421751810; 2946826244; 816775167; 604045313; 320929813;
   29370405; 364904452; 2755657742; 3292790816; 65011720;
   3829661720; 3292921888; 3293052952; 1149599744; 1006718848;
   1174942337; 77660164; 1182827680; 1149313024; 0; 1174705280;
   1175605635; 604504066; 2689073154; 2755985422; 3829792796;
   65011720; 0].

Definition jp_fade_helper_to_zero_words : list Z :=
  [311424; 50642977; 1008304162; 658057752; 1622400; 51974177;
   2420637698; 2946826244; 816775167; 2946891784; 818872575;
   604045313; 31469605; 285278251; 29370405; 364904463;
   2755657742; 1149640704; 1006718848; 98631684; 1182802336;
   1149321216; 0; 1174942080; 1006731316; 3559949176;
   1174418081; 1177572483; 1176539424; 65011720; 3829661720;
   1149648896; 1006718848; 79757316; 1182810528; 1149325312;
   0; 1175073152; 1006731316; 3560080256; 1174418465;
   3293184024; 1177714947; 1149599744; 1006718848; 1182827680;
   1176511008; 77660164; 1175077249; 1149313024; 0; 1174705280;
   1175597571; 604569604; 2689138690; 2755985422; 3829923868;
   65011720; 0].

Definition jp_sqrtf_range : JPMipsCodeRange :=
  {| jp_mips_range_start := 2150771488;
     jp_mips_range_end := 2150771496;
     jp_mips_range_words := jp_sqrtf_words |}.

Definition jp_stop_sounds_from_source_range : JPMipsCodeRange :=
  {| jp_mips_range_start := 2150762232;
     jp_mips_range_end := 2150762460;
     jp_mips_range_words := jp_stop_sounds_from_source_words |}.

Definition jp_stop_sounds_in_bank_range : JPMipsCodeRange :=
  {| jp_mips_range_start := 2150762460;
     jp_mips_range_end := 2150762640;
     jp_mips_range_words := jp_stop_sounds_in_bank_words |}.

Definition jp_stop_sounds_in_continuous_banks_range : JPMipsCodeRange :=
  {| jp_mips_range_start := 2150762640;
     jp_mips_range_end := 2150762688;
     jp_mips_range_words := jp_stop_sounds_in_continuous_banks_words |}.

Definition jp_update_background_music_after_sound_range : JPMipsCodeRange :=
  {| jp_mips_range_start := 2150752484;
     jp_mips_range_end := 2150752620;
     jp_mips_range_words := jp_update_background_music_after_sound_words |}.

Definition jp_begin_background_music_fade_range : JPMipsCodeRange :=
  {| jp_mips_range_start := 2150760676;
     jp_mips_range_end := 2150761032;
     jp_mips_range_words := jp_begin_background_music_fade_words |}.

Definition jp_fade_helper_restore_range : JPMipsCodeRange :=
  {| jp_mips_range_start := 2150750128;
     jp_mips_range_end := 2150750264;
     jp_mips_range_words := jp_fade_helper_restore_words |}.

Definition jp_fade_helper_to_zero_range : JPMipsCodeRange :=
  {| jp_mips_range_start := 2150750264;
     jp_mips_range_end := 2150750500;
     jp_mips_range_words := jp_fade_helper_to_zero_words |}.

Definition jp_external_code_ranges : list JPMipsCodeRange :=
  [jp_sqrtf_range;
   jp_stop_sounds_from_source_range;
   jp_stop_sounds_in_bank_range;
   jp_stop_sounds_in_continuous_banks_range;
   jp_update_background_music_after_sound_range;
   jp_begin_background_music_fade_range;
   jp_fade_helper_restore_range;
   jp_fade_helper_to_zero_range].

Definition jp_range_code (range : JPMipsCodeRange) : list (Z * Z) :=
  jp_enumerate_words (jp_mips_range_start range)
    (jp_mips_range_words range).

Definition jp_external_code : list (Z * Z) :=
  flat_map jp_range_code jp_external_code_ranges.

Definition jp_scanned_store_words : list (Z * Z) :=
  filter (fun entry => jp_mips_is_store (snd entry)) jp_external_code.

Definition jp_expected_store_words : list (Z * Z) :=
  [(2150762236, 2947940396); (2150762240, 2948005936);
   (2150762244, 2947874856); (2150762248, 2947809316);
   (2150762252, 2947743776); (2150762256, 2947678236);
   (2150762268, 2948530228); (2150762272, 2947612696);
   (2150762276, 2947547156); (2150762380, 2919235604);
   (2150762464, 2947612700); (2150762500, 2948530220);
   (2150762504, 2947809320); (2150762508, 2947743780);
   (2150762512, 2947678240); (2150762516, 2947547160);
   (2150762520, 2946760752); (2150762596, 2889875476);
   (2150762644, 2948530196); (2150752544, 2948530196);
   (2150752552, 2946760728); (2150752560, 2946826268);
   (2150752592, 2756575232); (2150760692, 2948530196);
   (2150760696, 2946760736); (2150760780, 3840409632);
   (2150760932, 2745565215); (2150760992, 2745565215);
   (2150761004, 3840278560); (2150750156, 2946826244);
   (2150750180, 2755657742); (2150750192, 3829661720);
   (2150750244, 2689073154); (2150750248, 2755985422);
   (2150750252, 3829792796); (2150750292, 2946826244);
   (2150750300, 2946891784); (2150750328, 2755657742);
   (2150750384, 3829661720); (2150750480, 2689138690);
   (2150750484, 2755985422); (2150750488, 3829923868)].

Definition jp_scanned_direct_calls : list (Z * Z) :=
  map (fun entry =>
         (fst entry, jp_mips_jump_target (fst entry) (snd entry)))
      (filter (fun entry => jp_mips_is_jal (snd entry)) jp_external_code).

Definition jp_expected_direct_calls : list (Z * Z) :=
  [(2150762372, 2150752484); (2150762572, 2150752484);
   (2150762648, 2150762460); (2150762656, 2150762460);
   (2150762664, 2150762460); (2150752596, 2150760676);
   (2150760928, 2150750264); (2150761000, 2150750128)].

Definition jp_scanned_indirect_calls : list (Z * Z) :=
  filter (fun entry => jp_mips_is_jalr (snd entry)) jp_external_code.

Definition jp_scanned_linking_branches : list (Z * Z) :=
  filter (fun entry => jp_mips_is_linking_branch (snd entry))
    jp_external_code.

Definition jp_scanned_plain_jumps : list (Z * Z) :=
  filter (fun entry => jp_mips_is_plain_jump (snd entry)) jp_external_code.

Definition jp_scanned_register_returns : list (Z * Z) :=
  filter (fun entry => jp_mips_is_jr (snd entry)) jp_external_code.

Definition jp_range_size_matches_words (range : JPMipsCodeRange) : bool :=
  (jp_mips_range_end range - jp_mips_range_start range =?
     4 * Z.of_nat (length (jp_mips_range_words range))).

Definition jp_range_relative_branches_closed (range : JPMipsCodeRange) : bool :=
  forallb
    (fun entry =>
       let target := jp_mips_relative_target (fst entry) (snd entry) in
       (jp_mips_range_start range <=? target) &&
       (target <? jp_mips_range_end range))
    (filter (fun entry => jp_mips_is_relative_branch (snd entry))
      (jp_range_code range)).

Definition jp_retail_external_code_manifest_claim : Prop :=
  length jp_external_code = 332%nat /\
  forallb jp_range_size_matches_words jp_external_code_ranges = true /\
  jp_scanned_store_words = jp_expected_store_words /\
  length jp_scanned_store_words = 42%nat /\
  jp_scanned_direct_calls = jp_expected_direct_calls /\
  jp_scanned_indirect_calls = [] /\
  jp_scanned_linking_branches = [] /\
  jp_scanned_plain_jumps = [] /\
  forallb jp_range_relative_branches_closed jp_external_code_ranges = true /\
  length jp_scanned_register_returns = 10%nat /\
  forallb (fun entry => snd entry =? 65011720)
    jp_scanned_register_returns = true.

Theorem jp_retail_external_code_manifest_checked :
  jp_retail_external_code_manifest_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** [sqrtf] is exactly [jr ra; sqrt.s f0,f12].  This unconditional result is
    stronger than a frame: there is no store or transitive call on any path. *)
Theorem jp_retail_sqrtf_is_store_and_call_free :
  filter (fun entry => jp_mips_is_store (snd entry))
    (jp_range_code jp_sqrtf_range) = [] /\
  filter (fun entry => jp_mips_is_jal (snd entry) ||
                       jp_mips_is_jalr (snd entry) ||
                       jp_mips_is_linking_branch (snd entry))
    (jp_range_code jp_sqrtf_range) = [].
Proof. vm_compute. split; reflexivity. Qed.
