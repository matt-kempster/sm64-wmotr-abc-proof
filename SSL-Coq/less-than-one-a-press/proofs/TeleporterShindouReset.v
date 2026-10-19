(** Authenticated finite Shindou ROM instruction evidence.

  [instrumentation/teleporter-wrong-warp/check_sh_rom.py] checks every literal
  below against the SHA1/SHA256-gated stock Shindou ROM. This is an instruction
  certificate and local successful-store effect, not a full MIPS interpreter.
  The memory bridge from raw address 0x80310564 to a CompCert block, ordinary
  call/return and destination-load execution, preservation after the checked
  stores, and VC failed-load behavior are deliberately not claimed here.
  In particular, a pre-latch area change can reuse [usedObj]; the latched source
  ID is not automatically the original stock fading-teleporter ID.
*)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Integers Memory Values.
Import ListNotations.
Local Open Scope Z_scope.

Definition sh_mips_opcode (word : Z) : Z := Z.shiftr word 26.
Definition sh_mips_rs (word : Z) : Z := Z.land (Z.shiftr word 21) 31.
Definition sh_mips_rt (word : Z) : Z := Z.land (Z.shiftr word 16) 31.
Definition sh_mips_signed_immediate (word : Z) : Z :=
  let immediate := Z.land word 65535 in
  if 32768 <=? immediate then immediate - 65536 else immediate.
Definition sh_mips_jump_target (pc word : Z) : Z :=
  Z.lor (Z.land (pc + 4) 4026531840)
        (Z.shiftl (Z.land word 67108863) 2).
Definition sh_word_at (start : Z) (words : list Z) (pc : Z) : Z :=
  nth (Z.to_nat ((pc - start) / 4)) words 0.

(** ROM VA range 0x802B1950 .. 0x802B195C, end exclusive. *)
Definition sh_clear_platform_words : list Z :=
  [1006731313; 65011720; 2887779684].

(** ROM VA range 0x802B1900 .. 0x802B1950, end exclusive. *)
Definition sh_apply_platform_words : list Z :=
  [1007583282; 2379150912; 666763240; 1006993457; 835649600; 2948530196;
   367001609; 2359625060; 1008238644; 2400727832; 1392508934; 2411659284;
   1352663044; 2411659284; 202032567; 604241921; 2411659284; 666697752;
   65011720; 0].

(** ROM VA range 0x8028ECF0 .. 0x8028EE9C, end exclusive. *)
Definition sh_spawn_objects_words : list Z :=
  [1007583284; 666763216; 634270760; 1006731316; 2888708776; 1006731314;
   2887841344; 1006731316; 2753573922; 2948530220; 2947612696; 1006731316;
   10520613; 2947874856; 2947809316; 2947743776; 2947678236; 2947547156;
   2946760752; 202032724; 2753573924; 1007648818; 2247090970; 604045314;
   1006796852; 367067140; 608318492; 2220359680; 924385281; 2757296128;
   304087105; 1008042036; 649409304; 605290497; 873725696; 201967124;
   2384723988; 2384986128; 4231205; 822738688; 1382613045; 2385575964;
   202033451; 4202533; 2385117200; 640548880; 4227109; 2890531208;
   2385182736; 2891055628; 2889875912; 746498; 831324415; 2890727748;
   2756968950; 2890793564; 2385444880; 4202533; 838336513; 1392508932;
   33562661; 202239325; 2929852416; 33562661; 202239516; 35661861;
   2251882496; 1150885888; 0; 1182802336; 3859153056; 2250768386;
   1149779968; 0; 1182810784; 3859415204; 2250833924; 1149861888;
   0; 1182827680; 3859939496; 2250899462; 2919891152; 2250965000;
   2919956692; 2251030538; 2920022232; 2251096070; 2920087748; 2251161608;
   2920153288; 2251227146; 2920218828; 2385575964; 371261380; 0;
   2411659308; 2410676244; 2410741784; 2410807324; 2410872864; 2410938404;
   2411003944; 65011720; 666697776; 65011720; 0].

(** ROM VA range 0x80273BBC .. 0x80273C28, end exclusive. *)
Definition sh_load_mario_area_words : list Z :=
  [666763240; 2948530196; 202112227; 0; 1007583281; 2379142384;
   201969317; 2177105932; 1006862385; 610522352; 1006796849; 2353190140;
   2356084736; 2153316352; 2180513804; 1461256200; 2411659284; 2152202241;
   8229; 889782273; 2689138689; 201997116; 2355429376; 2411659284;
   666697752; 65011720; 0].

(** ROM VA range 0x80255A48 .. 0x80255D84, end exclusive. *)
Definition sh_init_mario_words : list Z :=
  [666763208; 2947547160; 1007714353; 1006731314; 638636136; 2887834320;
   2383282176; 2948530204; 604111103; 2780823578; 2383347712; 2715942952;
   2383937536; 2734817321; 2384003072; 201968757; 2803892262; 1006698511;
   4276260; 1358954501; 2383085568; 2382954496; 268435460; 2904555524;
   2383085568; 604635153; 2909405188; 1149239296; 2383151104; 1006796849;
   3850371156; 2383216640; 2711617716; 2383282176; 2713714866; 2383347712;
   2715812019; 2383937536; 2801795254; 2384003072; 3877634240; 2382888960;
   2902458492; 2382954496; 2904555652; 2383020032; 2906652800; 2353190128;
   2219507712; 2219573252; 1149968384; 1150038016; 1182802720; 202243868;
   1182806944; 1174405645; 2383347712; 1008238641; 1007190068; 1141784576;
   604700671; 1006993457; 2783838326; 2384003072; 2400769276; 2939682960;
   2382954496; 2366124824; 2905079944; 2383085568; 2372665480; 2777284664;
   2359678192; 2382626816; 614793222; 202236473; 612630572; 2382626816;
   10277; 12325; 14373; 202236484; 612630578; 2382626816;
   1006993457; 2359678192; 202236546; 612630588; 1149239296; 2382626816;
   1141178368; 1141243904; 1141309440; 202236427; 612630600; 2382561280;
   3295412284; 3295543360; 2355494980; 202243727; 610730088; 2383216640;
   1007160384; 1008285696; 3852468336; 2382561280; 926491328; 889717249;
   3294756928; 3295412336; 1175195708; 0; 1157758981; 2356019336;
   3832283200; 2382561280; 3294756928; 2356019336; 3854696484; 2382561280;
   2221867126; 3295805504; 637075356; 1150832640; 0; 1182815264;
   1175490622; 0; 1157758980; 2892496908; 268435458; 2893611020;
   2892496908; 201938198; 2382626816; 201938171; 2382626816; 2382954496;
   2368405656; 2707423243; 2382561280; 3294887996; 2355757192; 3846439072;
   2382561280; 3295019072; 2355888264; 3850764452; 2382561280; 3295150148;
   2355953800; 3852992680; 2382561280; 2221801516; 2356084872; 2918056132;
   2382561280; 2222456878; 2356740232; 2939683016; 2382561280; 2221408304;
   2355691656; 2905080012; 2382561280; 2355363976; 610598972; 202236416;
   612630560; 2382561280; 10277; 14373; 2355363976; 2221277230;
   202236484; 612630554; 201968911; 665059376; 272629783; 604307592;
   2383085568; 1007031040; 616971768; 201998494; 2372141192; 2276065328;
   1149915136; 0; 1182815264; 3830448288; 2276196402; 1150062592;
   0; 1182830880; 3829661860; 2276261940; 2889875640; 2889875656;
   1150103552; 0; 1182806560; 3829924008; 2411659292; 2410676248;
   666697784; 65011720; 0].

(** ROM VA range 0x8024D25C .. 0x8024D630, end exclusive. *)
Definition sh_init_after_warp_words : list Z :=
  [666763224; 2948530204; 1006927922; 201969190; 2424625827; 2353266692;
   201969144; 2946629668; 1007583281; 2379141224; 2946629664; 2409824292;
   2379153420; 299892801; 0; 2356674564; 1006927922; 612687104;
   3338928288; 604045313; 1006993458; 1174413709; 1141387264; 0;
   2760376320; 2355691524; 3307733156; 1174422157; 1141592064; 0;
   2760572930; 2355888132; 3314548904; 2759852038; 1174439053; 1141805056;
   0; 2760769540; 2356084740; 2381840584; 2759852042; 339804167;
   2761424904; 2359679652; 201929681; 2946695204; 1006927922; 612687104;
   2409824292; 1006796850; 2420300448; 604045313; 1008304178; 272695299;
   604045314; 339804166; 0; 2470042274; 2946695204; 201969391;
   2694381580; 2409824292; 201938578; 2946695204; 1006927921; 1007058994;
   2361842340; 2357514344; 201929749; 2409955360; 2409824292; 1007255601;
   2368327784; 2355625988; 1007386673; 2905079928; 2372653160; 2355757060;
   2909405312; 1007452209; 2374817020; 201979291; 2374238244; 2410479648;
   1006731314; 2686507680; 1006731314; 2753616554; 632225791; 767623207;
   270532664; 946304; 1006731313; 3016737; 2351855484; 29360136;
   0; 604241928; 604307472; 12325; 14373; 201969496;
   2946498576; 268435505; 0; 604241930; 604307472; 12325;
   14373; 201969496; 2946498576; 268435497; 0; 604963071;
   2947481616; 8229; 604307476; 604373247; 201969496; 604438783;
   268435488; 0; 605552895; 2948071440; 8229; 604307482;
   604373247; 201969496; 604438783; 268435479; 0; 604241930;
   604307472; 12325; 14373; 201969496; 2946498576; 268435471;
   0; 8229; 604307472; 12325; 14373; 201969496;
   2946498576; 268435463; 0; 604241928; 604307472; 12325;
   14373; 201969496; 2946498576; 1008304177; 2402929952; 1006796849;
   1461715029; 2411659292; 2353190140; 12325; 2487484470; 201928755;
   2487550008; 1007190065; 2366165096; 2365718532; 810090500; 1361051655;
   810221578; 201928872; 604242959; 1007321137; 2370490472; 2369912836;
   810221578; 291504131; 0; 201928872; 604242958; 1007452209;
   2240599336; 604045321; 360775693; 0; 202112630; 0;
   604046345; 272695304; 1007517746; 2175654582; 8229; 604308489;
   295698435; 0; 202112395; 12325; 1006862386; 2422463137;
   604045318; 1007583282; 1415643155; 604045328; 2446252706; 604045313;
   1006796850; 1438711822; 604045328; 2420300451; 604045343; 1006923805;
   272695299; 881111169; 604045344; 339804165; 1006993457; 202109195;
   614816832; 1006862386; 2422463137; 604045328; 341901332; 1007648818;
   2448415394; 604045313; 1006796850; 1440808976; 2411659292; 2420300451;
   604045319; 1006923805; 272695303; 881111169; 604045322; 272695300;
   604045332; 272695298; 604045342; 339804163; 1006993457; 202109195;
   614816832; 2411659292; 666697768; 65011720; 0].

(** ROM VA range 0x80273898 .. 0x802738D8, end exclusive. *)
Definition sh_area_get_warp_node_words : list Z :=
  [1007648817; 2381305084; 2946760704; 814612735; 2380464148; 29364261;
   274726919; 0; 2423783424; 274202628; 0; 2355298312;
   1415643132; 2423783424; 65011720; 6295589].

(** ROM VA range 0x8024E3FC .. 0x8024E42C, end exclusive. *)
Definition sh_delayed_warp_suffix_words : list Z :=
  [201969190; 2424625839; 2946629660; 2420375553; 1007124530; 2364005040;
   814350463; 678912; 730115; 2420506627; 201930424; 2420441090].

Definition sh_clear_platform_store_word : Z :=
  sh_word_at 2150308176 sh_clear_platform_words 2150308184.
Definition sh_init_held_store_word : Z :=
  sh_word_at 2149931592 sh_init_mario_words 2149931760.
Definition sh_init_ridden_store_word : Z :=
  sh_word_at 2149931592 sh_init_mario_words 2149931768.
Definition sh_init_used_store_word : Z :=
  sh_word_at 2149931592 sh_init_mario_words 2149931776.
Definition sh_delayed_source_mask_word : Z :=
  sh_word_at 2149901308 sh_delayed_warp_suffix_words 2149901332.

Definition sh_store_fields (word : Z) : Z * Z * Z * Z :=
  (sh_mips_opcode word, sh_mips_rs word,
   sh_mips_rt word, sh_mips_signed_immediate word).

(** These are instruction fields, exact direct-call targets, and the address
    calculated by the LUI / return-delay-slot SW pair. The finite certificate
    does not turn their presence into an end-to-end execution theorem. *)
Definition shindou_reset_instruction_certificate : Prop :=
  sh_clear_platform_words = [1006731313; 65011720; 2887779684] /\
  sh_store_fields sh_clear_platform_store_word = (43, 1, 0, 1380) /\
  Z.shiftl (Z.land (hd 0 sh_clear_platform_words) 65535) 16 +
    sh_mips_signed_immediate sh_clear_platform_store_word = 2150696292 /\
  map sh_store_fields
    [sh_init_held_store_word; sh_init_ridden_store_word; sh_init_used_store_word] =
    [(43, 8, 0, 124); (43, 9, 0, 132); (43, 10, 0, 128)] /\
  map (fun entry => sh_mips_jump_target (fst entry) (snd entry))
    [(2150165820, sh_word_at 2150165744 sh_spawn_objects_words 2150165820);
     (2150054928, sh_word_at 2150054844 sh_load_mario_area_words 2150054928);
     (2149897032, sh_word_at 2149896796 sh_init_after_warp_words 2149897032);
     (2149897044, sh_word_at 2149896796 sh_init_after_warp_words 2149897044)] =
    [2150308176; 2150165744; 2150054844; 2149931592] /\
  map (fun entry => sh_mips_opcode (snd entry))
    [(2150165820, sh_word_at 2150165744 sh_spawn_objects_words 2150165820);
     (2150054928, sh_word_at 2150054844 sh_load_mario_area_words 2150054928);
     (2149897032, sh_word_at 2149896796 sh_init_after_warp_words 2149897032);
     (2149897044, sh_word_at 2149896796 sh_init_after_warp_words 2149897044)] =
    [3; 3; 3; 3] /\
  (sh_mips_opcode sh_delayed_source_mask_word,
   sh_mips_rs sh_delayed_source_mask_word,
   sh_mips_rt sh_delayed_source_mask_word,
   Z.land sh_delayed_source_mask_word 65535) = (12, 4, 10, 127).

Theorem shindou_reset_instruction_certificate_checked :
  shindou_reset_instruction_certificate.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Standard SW reads register zero as the integer zero. This definition only
    supplies its source value; it supplies no fetch, PC, exception, register-file,
    or raw-address-to-memory-block semantics. *)
Definition sh_sw_source_value (word : Z) (registers : Z -> val) : val :=
  if sh_mips_rt word =? 0 then Vint Int.zero
  else registers (sh_mips_rt word).

(** Once the actual clear instruction's successful store is supplied at its
    resolved CompCert address, reading that address returns zero. Establishing
    that the machine reaches this store and preserves it remains separate. *)
Theorem shindou_clear_platform_successful_store_reads_zero :
  forall (m after : mem) (platform_block : block) (offset : Z) registers,
    Mem.store Mint32 m platform_block offset
      (sh_sw_source_value sh_clear_platform_store_word registers) = Some after ->
    Mem.load Mint32 after platform_block offset = Some (Vint Int.zero).
Proof.
  intros m after platform_block offset registers Hstore.
  change (Mem.store Mint32 m platform_block offset (Vint Int.zero) = Some after)
    in Hstore.
  exact (Mem.load_store_same _ _ _ _ _ _ Hstore).
Qed.

Theorem shindou_init_held_successful_store_reads_zero :
  forall (m after : mem) (mario_block : block) (offset : Z) registers,
    Mem.store Mint32 m mario_block offset
      (sh_sw_source_value sh_init_held_store_word registers) = Some after ->
    Mem.load Mint32 after mario_block offset = Some (Vint Int.zero).
Proof.
  intros m after mario_block offset registers Hstore.
  change (Mem.store Mint32 m mario_block offset (Vint Int.zero) = Some after)
    in Hstore.
  exact (Mem.load_store_same _ _ _ _ _ _ Hstore).
Qed.

(** The actual ANDI immediate is 127. Equating its input with the latched source
    ID additionally needs the missing VC failed-load/no-register-write bridge. *)
Theorem shindou_delayed_source_mask_checked :
  forall latched_source,
    Z.land latched_source (Z.land sh_delayed_source_mask_word 65535) =
      Z.land latched_source 127.
Proof. intros. reflexivity. Qed.

Definition shindou_reset_instruction_boundary : Prop :=
  shindou_reset_instruction_certificate /\
  (forall (m after : mem) (platform_block : block) (offset : Z) registers,
    Mem.store Mint32 m platform_block offset
      (sh_sw_source_value sh_clear_platform_store_word registers) = Some after ->
    Mem.load Mint32 after platform_block offset = Some (Vint Int.zero)) /\
  (forall (m after : mem) (mario_block : block) (offset : Z) registers,
    Mem.store Mint32 m mario_block offset
      (sh_sw_source_value sh_init_held_store_word registers) = Some after ->
    Mem.load Mint32 after mario_block offset = Some (Vint Int.zero)).

Theorem shindou_reset_instruction_boundary_checked :
  shindou_reset_instruction_boundary.
Proof.
  split; [exact shindou_reset_instruction_certificate_checked |].
  split; [exact shindou_clear_platform_successful_store_reads_zero |
          exact shindou_init_held_successful_store_reads_zero].
Qed.
