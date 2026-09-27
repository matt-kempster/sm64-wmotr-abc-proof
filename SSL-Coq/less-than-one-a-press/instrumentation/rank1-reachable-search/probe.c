/* Read-only exact checkpoints layered on the validated controller replay.
 * No state setup: all gameplay is produced by capture.c's controller inputs.
 * Return values are read from f0, not from the caller's old floor-height cell.
 */
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_plugin.h>
static void search_debug(unsigned int pc);
static void search_input(int control, BUTTONS *keys);
static void search_close(void);
#define WARP_ACCEPT_DEBUG_OBSERVER search_debug
#define WARP_ACCEPT_CLOSE_OBSERVER search_close
#define WAFEL_PILOT_EXTRA_INPUT search_input
#include "../wafel-jp-pilot/capture.c"

enum { SEARCH_QUERY1 = 0x802538a0, SEARCH_QUERY2 = 0x802538e4 };
static unsigned searchArmed, searchFirst, searchEnd, searchFailures;
static unsigned searchQueries, searchMisses, searchRetries, searchFinalQueries;
static unsigned searchAccepted, searchSamples, searchWrites, searchFirstArea2;
static unsigned searchFirstArea2Complete;
static uint32_t searchPlatformFloor;
static uint32_t searchPlatformHeight;
static uint32_t searchQueryReturn, searchQueryArgs[3], searchQueryOutput;
static int searchPendingWarp;

/* The inherited Rank-5 observer does not initialize Rank-1's node-pool cache.
 * Read the live pool here; never interpret an uninitialized cache as no list.
 * This inspects membership only, not a replacement implementation of selection.
 */
static int search_membership(uint32_t partition, uint32_t selected) {
    int16_t x = (int16_t)(int32_t)rank1_float_from_bits(searchQueryArgs[0]);
    int16_t z = (int16_t)(int32_t)rank1_float_from_bits(searchQueryArgs[2]);
    uint32_t base = R32(A_SURFACE_NODE_POOL_CELL), node;
    unsigned steps = 0;
    int matches = 0;
    if (!selected || x <= -8192 || x >= 8192 || z <= -8192 || z >= 8192) return 0;
    node = R32(partition + ((((z+8192)/1024)*16+(x+8192)/1024)*3)*8);
    while(node && steps++ < SURFACE_NODE_CAPACITY) {
        if (node < base || node >= base+SURFACE_NODE_BYTES || (node-base)%SURFACE_NODE_SIZE) return -1;
        matches += R32(node+4) == selected;
        node = R32(node);
    }
    return node ? -1 : matches;
}

static uint32_t search_fpr(unsigned n) {
    float **regs = DGetCPUDataPtr(M64P_CPU_REG_COP1_SIMPLE_PTR);
    uint32_t word;
    if (regs == NULL || regs[n] == NULL) { searchFailures++; return 0; }
    memcpy(&word,regs[n],sizeof(word));
    return word;
}

static void search_sample(const char *stage, uint32_t pc, uint32_t floor,
                          uint32_t height) {
    unsigned i;
    uint32_t o = R32(A_MARIO_OBJECT), owner = 0;
    int surface = floor == 0 ? -1 : rank1_surface_index(floor);
    uint32_t live = 0;
    int live_count = strcmp(stage,"accepted-return") == 0 ? (int)wa_live_tops(&live) : -1;
    if (pilot_slot(o) < 0 || (floor != 0 && surface < 0)) {
        searchFailures++;
        return;
    }
    if (floor != 0) owner = R32(floor + SURFACE_OBJECT);
    if (owner != 0 && pilot_slot(owner) < 0) searchFailures++;
    fprintf(stderr, "R1_SEARCH,{\"stage\":\"%s\",\"pc\":%u,\"poll\":%llu,"
        "\"timer\":%u,\"area\":%u,\"action\":%u,\"actionTimer\":%u,"
        "\"depth\":%u,\"positions\":[", stage, pc, (unsigned long long)gPoll,
        R32(A_GLOBAL_TIMER), R16(A_CURR_AREA), R32(A_MARIO_STATES+M_ACTION),
        R16(A_MARIO_STATES+M_ACTION_TIMER), R32(A_MARIO_STATES+0xc0));
    for(i=0;i<3;i++) fprintf(stderr,"%s%u",i?",":"",R32(A_MARIO_STATES+M_POS_X+4*i));
    for(i=0;i<3;i++) fprintf(stderr,",%u",R32(o+O_POS_X+4*i));
    for(i=0;i<3;i++) fprintf(stderr,",%u",R32(o+GFX_POS_X+4*i));
    fprintf(stderr,"],\"floor\":%u,\"floorIndex\":%d,\"height\":%u,"
        "\"owner\":%d,\"platform\":%d,\"objectPlatform\":%d,"
        "\"topBehavior\":%u,\"topActive\":%u,\"topTimer\":%u,\"topAction\":%u,\"liveTopCount\":%d}\n",
        floor,surface,height,pilot_slot(owner),pilot_slot(R32(A_MARIO_PLATFORM)),
        pilot_slot(R32(o+0x214)),R32(pool_pointer(61)+O_BEHAVIOR),
        R16(pool_pointer(61)+O_ACTIVE_FLAGS),R32(pool_pointer(61)+O_TIMER),
        R32(pool_pointer(61)+O_ACTION),live_count);
    searchSamples++;
}

static void search_debug(unsigned int pc) {
    uint64_t *r = DGetCPUDataPtr(M64P_CPU_REG_REG);
    uint32_t floor, height, flags = 0, accessed = 0;
    const char *stage = NULL;
    if (!searchArmed || gPoll < searchFirst || gPoll >= searchEnd) return;
    if (r == NULL) { searchFailures++; return; }
    if (R16(A_CURR_AREA) == 2 && pc == A_APPLY_MARIO_PLATFORM_DISPLACEMENT && !searchFirstArea2) {
        searchFirstArea2++;
        search_sample("first-area2-apply-entry",pc,0,0);
        return;
    }
    if (R16(A_CURR_AREA) == 2 && pc == A_POST_APPLY_MARIO_PLATFORM
        && searchFirstArea2 && !searchFirstArea2Complete) {
        searchFirstArea2Complete++;
        search_sample("first-area2-apply-return",pc,0,0);
        return;
    }
    if (R16(A_CURR_AREA) != 1 || pilot_slot(R32(A_MARIO_OBJECT)) < 0) return;
    if (pc == A_FIND_FLOOR && ((uint32_t)r[31] == SEARCH_QUERY1
        || (uint32_t)r[31] == SEARCH_QUERY2 || (uint32_t)r[31] == A_POST_PLATFORM_FIND_FLOOR)) {
        if (searchQueryReturn) searchFailures++;
        searchQueryReturn = (uint32_t)r[31];
        searchQueryArgs[0] = search_fpr(12);
        searchQueryArgs[1] = search_fpr(14);
        searchQueryArgs[2] = (uint32_t)r[6];
        searchQueryOutput = (uint32_t)r[7];
        return;
    }
    floor = R32(A_MARIO_STATES+M_FLOOR);
    height = R32(A_MARIO_STATES+M_FLOOR_HEIGHT);
    if (pc == SEARCH_QUERY1 || pc == SEARCH_QUERY2) {
        stage = pc == SEARCH_QUERY1 ? "geometry-query1-return" : "geometry-query2-return";
        searchQueries++;
        searchMisses += floor == 0;
        searchRetries += pc == SEARCH_QUERY2;
        height = search_fpr(0);
    } else if (pc == A_POST_PLATFORM_FIND_FLOOR) {
        stage = "final-query-return";
        floor = R32((uint32_t)r[29]+60);
        height = search_fpr(0);
        searchPlatformFloor = floor;
        searchPlatformHeight = height;
        searchFinalQueries++;
    } else if (pc == A_POST_MARIO_PLATFORM) {
        stage = "final-platform-return";
        floor = searchPlatformFloor;
        height = searchPlatformHeight;
    } else if (pc == A_DETECT_OBJECT_COLLISIONS) stage = "collision-entry";
    else if (pc == A_POST_APPLY_MARIO_PLATFORM) stage = "platform-phase-return";
    else if (pc == R13_POST_INPUTS) stage = "geometry-complete";
    else if (pc == R13_INTERACTIONS) stage = "interactions-entry";
    else if (pc == A_POST_COPY_MARIO_STATE_TO_OBJECT) stage = "ordinary-copy-return";
    else if (pc == R13_HANDLER_CALL && (uint32_t)r[25] == R13_WARP_HANDLER
             && (uint32_t)r[6] == gUpperWarp) {
        stage = "upper-handler-entry";
        searchPendingWarp = 1;
    } else if (pc == R13_HANDLER_RETURN && searchPendingWarp) {
        searchPendingWarp = 0;
        if ((uint32_t)r[2] == 1 && R32(A_MARIO_STATES+M_ACTION) == ACT_DISAPPEARED
            && R32(A_MARIO_STATES+0x1c) == 0x00040002) {
            stage = "accepted-return";
            searchAccepted++;
        } else stage = "upper-handler-rejected";
    }
    if (pc == SEARCH_QUERY1 || pc == SEARCH_QUERY2 || pc == A_POST_PLATFORM_FIND_FLOOR) {
        int sm, dm;
        if (searchQueryReturn != pc || !searchQueryOutput || R32(searchQueryOutput) != floor)
            searchFailures++;
        sm = search_membership(A_STATIC_SURFACE_PARTITION,floor);
        dm = search_membership(A_DYNAMIC_SURFACE_PARTITION,floor);
        fprintf(stderr,"R1_SEARCH_QUERY,{\"poll\":%llu,\"timer\":%u,\"returnPC\":%u,\"arguments\":[%u,%u,%u],\"floor\":%u,\"height\":%u,\"staticMembership\":%d,\"dynamicMembership\":%d}\n",
            (unsigned long long)gPoll,R32(A_GLOBAL_TIMER),pc,searchQueryArgs[0],searchQueryArgs[1],searchQueryArgs[2],floor,height,sm,dm);
        searchQueryReturn = 0;
    }
    if (stage) search_sample(stage,pc,floor,height);
    DBreakpointTriggeredBy(&flags,&accessed);
    if (flags & M64P_BKP_FLAG_WRITE) {
        uint32_t target = rank1_effective_address(R32(pc),r);
        uint32_t o = R32(A_MARIO_OBJECT);
        if ((target>=A_MARIO_STATES+M_POS_X && target<A_MARIO_STATES+M_POS_X+12)
            || (target>=o+O_POS_X && target<o+O_POS_X+12)
            || (target>=o+GFX_POS_X && target<o+GFX_POS_X+12)) {
            fprintf(stderr,"R1_SEARCH_WRITE,{\"poll\":%llu,\"timer\":%u,\"pc\":%u,\"target\":%u,\"before\":%u}\n",
                (unsigned long long)gPoll,R32(A_GLOBAL_TIMER),pc,target,R32(target));
            searchWrites++;
        }
    }
}

static void search_input(int control, BUTTONS *keys) {
    (void)keys;
    if (control != 0 || searchArmed || !waArmed) return;
    searchFirst = getenv("RANK1_SEARCH_FIRST") ? (unsigned)strtoul(getenv("RANK1_SEARCH_FIRST"),NULL,10) : 2500;
    searchEnd = getenv("RANK1_SEARCH_END") ? (unsigned)strtoul(getenv("RANK1_SEARCH_END"),NULL,10) : 2851;
    if (searchFirst >= searchEnd || R32(SEARCH_QUERY1-8) != 0x0c0e0640
        || R32(SEARCH_QUERY2-8) != 0x0c0e0640) abort();
    if (!add_exec_breakpoint(SEARCH_QUERY1) || !add_exec_breakpoint(SEARCH_QUERY2)
        || !add_exec_breakpoint(A_POST_PLATFORM_FIND_FLOOR) || !add_exec_breakpoint(A_FIND_FLOOR)
        || !add_write_breakpoint(A_SLOT67+GFX_POS_X,12)) abort();
    searchArmed = 1;
}

static void search_close(void) {
    fprintf(stderr,"R1_SEARCH_RESULT,{\"armed\":%u,\"firstPoll\":%u,\"endPollExclusive\":%u,"
        "\"queries\":%u,\"misses\":%u,\"retries\":%u,\"finalQueries\":%u,"
        "\"accepted\":%u,\"samples\":%u,\"positionWrites\":%u,\"firstArea2Apply\":%u,\"firstArea2ApplyComplete\":%u,\"failures\":%u}\n",
        searchArmed,searchFirst,searchEnd,searchQueries,searchMisses,searchRetries,
        searchFinalQueries,searchAccepted,searchSamples,searchWrites,searchFirstArea2,searchFirstArea2Complete,searchFailures);
}
