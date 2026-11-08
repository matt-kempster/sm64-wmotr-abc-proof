/* engine/level_script.c with one proof-only rewrite (TRUST.md 2.2, the
 * act-0 place_object row; pipeline/proof_n64.h, PROOF_LEVEL_SCRIPT_C).
 *
 * level_cmd_place_object's first line, `u8 val7 = 1 << (gCurrActNum - 1);`,
 * shifts by -1 when gCurrActNum is 0 (a real entry: census B1).  Undefined in
 * C, so in CompCert that OBJECT command had no execution.  The ROM computes
 * it with sllv, which takes the shift amount mod 32: 1 << 31 = 0x80000000,
 * and the u8 store keeps the low byte, 0.  The rewrite below spells out that
 * mod 32 (`& 31`); it computes the ROM's bits for every gCurrActNum (acts
 * 1..6 unchanged; act 0 gives 0, so only mask-0x1F commands are placed, as
 * on the console).
 *
 * The vendor file is #included verbatim.  proof_n64.h renames its
 * definition of level_cmd_place_object to rom_level_cmd_place_object (a
 * function-like macro, so only the definition is renamed; the jump table's
 * entry still names level_cmd_place_object); nothing calls the rom_ one,
 * an unreferenced static that clightgen leaves out of the AST.
 * The body below is the vendor body (level_script.c:435-464) with only the
 * first line changed. */
#include "engine/level_script.c"

#undef level_cmd_place_object
static void level_cmd_place_object(void) {
    u8 val7 = 1 << ((gCurrActNum - 1) & 31);   /* ROM: 1 << (gCurrActNum - 1) */
    u16 model;
    struct SpawnInfo *spawnInfo;

    if (sCurrAreaIndex != -1 && ((CMD_GET(u8, 2) & val7) || CMD_GET(u8, 2) == 0x1F)) {
        model = CMD_GET(u8, 3);
        spawnInfo = alloc_only_pool_alloc(sLevelPool, sizeof(struct SpawnInfo));

        spawnInfo->startPos[0] = CMD_GET(s16, 4);
        spawnInfo->startPos[1] = CMD_GET(s16, 6);
        spawnInfo->startPos[2] = CMD_GET(s16, 8);

        spawnInfo->startAngle[0] = CMD_GET(s16, 10) * 0x8000 / 180;
        spawnInfo->startAngle[1] = CMD_GET(s16, 12) * 0x8000 / 180;
        spawnInfo->startAngle[2] = CMD_GET(s16, 14) * 0x8000 / 180;

        spawnInfo->areaIndex = sCurrAreaIndex;
        spawnInfo->activeAreaIndex = sCurrAreaIndex;

        spawnInfo->behaviorArg = CMD_GET(u32, 16);
        spawnInfo->behaviorScript = CMD_GET(void *, 20);
        spawnInfo->model = gLoadedGraphNodes[model];
        spawnInfo->next = gAreas[sCurrAreaIndex].objectSpawnInfos;

        gAreas[sCurrAreaIndex].objectSpawnInfos = spawnInfo;
    }

    sCurrentCmd = CMD_NEXT;
}
