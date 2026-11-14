/* Original JP conditional native fake pickup; time-stop retains old box triangles. */
#define SEARCH_MODE 12
#define GetKeys clean_get_keys
#define PluginStartup clean_plugin_startup
#include "../jp-clean-gap-search/jp_clean_gap_search_probe.c"
#undef PluginStartup
#undef GetKeys
enum { BOX_CAMERA=0x802876d0, BOX_ACTOR=A_OBJECT_POOL+13*OBJECT_SIZE };
static void (*box_write32)(unsigned int,unsigned int);
static void (*box_write16)(unsigned int,unsigned short);
static int box_armed,box_started,box_step;
static void bw32(uint32_t a,uint32_t v,const char *field) {
    fprintf(stderr,"BOX_WRITE,step=%d,width=32,address=%08x,before=%08x,after=%08x,field=%s\n",box_step,a,R32(a),v,field);box_write32(a,v);
}
static void bw16(uint32_t a,uint16_t v,const char *field) {
    fprintf(stderr,"BOX_WRITE,step=%d,width=16,address=%08x,before=%04x,after=%04x,field=%s\n",box_step,a,R16(a),v,field);box_write16(a,v);
}
static void bwf(uint32_t a,float v,const char *field) {uint32_t b;memcpy(&b,&v,4);bw32(a,b,field);}
static void bv(uint32_t a,float x,float y,float z,const char *field) {bwf(a,x,field);bwf(a+4,y,field);bwf(a+8,z,field);}
static void box_pose(float x,float y,float z,uint32_t action) {
    uint32_t m=R32(A_MARIO_OBJECT);
    bv(A_MARIO_STATES+M_POS_X,x,y,z,"movement");bv(m+O_POS_X,x,y,z,"collision");bv(m+GFX_POS_X,x,y,z,"storedGraphics");
    bw32(A_MARIO_STATES+M_ACTION,action,"action");bw16(A_MARIO_STATES+0x18,0,"actionState");bw16(A_MARIO_STATES+0x1a,0,"actionTimer");
    bv(A_MARIO_STATES+M_VEL_X,0,0,0,"velocity");bwf(A_MARIO_STATES+M_FORWARD_VEL,0,"forwardVel");
    bw16(A_MARIO_STATES+0x2c,0,"facePitch");bw16(A_MARIO_STATES+0x2e,0,"faceYaw");bw16(A_MARIO_STATES+0x30,0,"faceRoll");
}
static void box_log(void) {
    uint32_t m=R32(A_MARIO_OBJECT),f=R32(A_MARIO_STATES+M_FLOOR),h=R32(A_MARIO_STATES+0x98)+0x18;
    uint32_t base=R32(A_SURFACE_POOL_CELL),end=R32(A_SURFACES_ALLOCATED),count=0,cmd=R32(BOX_ACTOR+0x1cc);
    for(uint32_t i=R32(A_NUM_STATIC_SURFACES);i<end;i++)if(R32(base+i*48+0x2c)==BOX_ACTOR)count++;
    fprintf(stderr,"BOX_STATE,step=%d,timer=%u,area=%u,timeStop=%u,topTimer=%u,topAction=%u,action=%08x,actionState=%u,actionTimer=%u,input=%u,held=%08x,used=%08x,platform=%08x,floorOwner=%08x,floorY=%.9g,M=(%.9g,%.9g,%.9g),C=(%.9g,%.9g,%.9g),G=(%.9g,%.9g,%.9g),HOLP=(%.9g,%.9g,%.9g),boxXYZ=(%.9g,%.9g,%.9g),boxFlags=%u,boxHeld=%u,boxAction=%u,boxTimer=%u,boxActive=%u,boxType=%u,boxSubtype=%u,boxStatus=%u,boxBehavior=%08x,collisionData=%08x,parent=%08x,command=%08x,opcode=%08x,stack=%u,throwMatrix=%08x,transform=(%.9g,%.9g,%.9g),surfaceCount=%u,totalAllocated=%u,staticAllocated=%u,nodesAllocated=%u,staticNodes=%u\n",
      box_step,R32(A_GLOBAL_TIMER),R16(A_CURR_AREA),R32(A_TIME_STOP_STATE),R32(gTop+O_TIMER),R32(gTop+O_ACTION),
      R32(A_MARIO_STATES+M_ACTION),R16(A_MARIO_STATES+0x18),R16(A_MARIO_STATES+0x1a),R16(A_MARIO_STATES+M_INPUT),
      R32(A_MARIO_STATES+M_HELD_OBJ),R32(A_MARIO_STATES+M_USED_OBJ),R32(A_MARIO_PLATFORM),f?R32(f+0x2c):0,rfloat(A_MARIO_STATES+M_FLOOR_HEIGHT),
      rfloat(A_MARIO_STATES+M_POS_X),rfloat(A_MARIO_STATES+M_POS_Y),rfloat(A_MARIO_STATES+M_POS_Z),rfloat(m+O_POS_X),rfloat(m+O_POS_Y),rfloat(m+O_POS_Z),rfloat(m+GFX_POS_X),rfloat(m+GFX_POS_Y),rfloat(m+GFX_POS_Z),
      rfloat(h),rfloat(h+4),rfloat(h+8),rfloat(BOX_ACTOR+O_POS_X),rfloat(BOX_ACTOR+O_POS_Y),rfloat(BOX_ACTOR+O_POS_Z),
      R32(BOX_ACTOR+O_FLAGS),R32(BOX_ACTOR+0x124),R32(BOX_ACTOR+O_ACTION),R32(BOX_ACTOR+O_TIMER),R16(BOX_ACTOR+O_ACTIVE_FLAGS),R32(BOX_ACTOR+O_INTERACT_TYPE),R32(BOX_ACTOR+0x190),R32(BOX_ACTOR+0x134),R32(BOX_ACTOR+O_BEHAVIOR),R32(BOX_ACTOR+O_COLLISION_DATA),R32(BOX_ACTOR+0x68),cmd,cmd?R32(cmd):0,R32(BOX_ACTOR+0x1d0),R32(BOX_ACTOR+0x50),rfloat(BOX_ACTOR+0x24c),rfloat(BOX_ACTOR+0x250),rfloat(BOX_ACTOR+0x254),count,end,R32(A_NUM_STATIC_SURFACES),R32(A_SURFACE_NODES_ALLOCATED),R32(A_NUM_STATIC_SURFACE_NODES));
    for(uint32_t i=R32(A_NUM_STATIC_SURFACES);i<end;i++) {
      uint32_t s=base+i*48;if(R32(s+0x2c)!=BOX_ACTOR)continue;
      fprintf(stderr,"BOX_SURFACE,step=%d,index=%u,type=%d,force=%d,flags=%u,room=%u,lowerY=%d,upperY=%d,vertex1=(%d,%d,%d),vertex2=(%d,%d,%d),vertex3=(%d,%d,%d),normal=(%.9g,%.9g,%.9g),originOffset=%.9g\n",box_step,i,(int16_t)R16(s),(int16_t)R16(s+2),R16(s+4)>>8,R16(s+4)&255,(int16_t)R16(s+6),(int16_t)R16(s+8),(int16_t)R16(s+10),(int16_t)R16(s+12),(int16_t)R16(s+14),(int16_t)R16(s+16),(int16_t)R16(s+18),(int16_t)R16(s+20),(int16_t)R16(s+22),(int16_t)R16(s+24),(int16_t)R16(s+26),rfloat(s+28),rfloat(s+32),rfloat(s+36),rfloat(s+40));
    }
    for(uint32_t c=0;c<16*16*3;c++) {
      uint32_t n=R32(A_DYNAMIC_SURFACE_PARTITION+c*8),walk=0;
      while(n&&walk++<7000){uint32_t s=R32(n+4);if(s&&R32(s+0x2c)==BOX_ACTOR)fprintf(stderr,"BOX_LINK,step=%d,cellZ=%u,cellX=%u,kind=%u,surface=%u\n",box_step,c/48,(c/3)%16,c%3,(s-base)/48);n=R32(n);}
    }
}
static void box_update(unsigned int pc) {
    if(pc!=BOX_CAMERA){debugger_update_callback(pc);return;}
    if(box_started&&box_step<=48){box_log();}
    resume_from_breakpoint();
}
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core,void *ctx,void (*cb)(void *,int,const char *)) {
    m64p_error r=clean_plugin_startup(core,ctx,cb);if(r!=M64ERR_SUCCESS)return r;
    box_write32=dlsym(core,"DebugMemWrite32");box_write16=dlsym(core,"DebugMemWrite16");return box_write32&&box_write16?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;
}
EXPORT void CALL GetKeys(int control,BUTTONS *keys) {
    clean_get_keys(control,keys);if(control||!gTop)return;
    if(!box_started&&(R16(A_CURR_AREA)!=1||R32(gTop+O_PYRAMID_PILLARS_TOUCHED)!=4))return;
    memset(keys,0,sizeof(*keys));
    if(!box_armed){if(DSetCallbacks(debugger_init_callback,box_update,debugger_vi_callback)!=M64ERR_SUCCESS||!add_exec_breakpoint(BOX_CAMERA)){fprintf(stderr,"BOX_ERROR,arm\n");return;}box_armed=1;}
    if(!box_started){if(R32(gTop+O_ACTION)!=1||R32(gTop+O_TIMER)!=129)return;box_started=1;fprintf(stderr,"BOX_START,timer=%u,poll=%llu\n",R32(A_GLOBAL_TIMER),(unsigned long long)gPoll);}
    if(box_step==0){box_pose(5900,51,3380,0x0c400201);bv(BOX_ACTOR+O_POS_X,6100,51,3380,"boxPosition");keys->B_BUTTON=1;}
    if(box_step==4){if(R32(A_MARIO_STATES+M_ACTION)!=0x383||R32(A_MARIO_STATES+M_USED_OBJ)!=A_OBJECT_POOL+23*OBJECT_SIZE||R32(A_MARIO_STATES+M_HELD_OBJ)){fprintf(stderr,"BOX_ERROR,native-pickup-entry\n");return;}bw32(A_MARIO_STATES+M_USED_OBJ,BOX_ACTOR,"usedReference");}
    if(box_step==6){if(R32(A_MARIO_STATES+M_HELD_OBJ)!=BOX_ACTOR){fprintf(stderr,"BOX_ERROR,native-grab\n");return;}bw32(A_TIME_STOP_STATE,66,"timeStop");}
    if(box_step==18){if(R32(A_MARIO_STATES+M_ACTION)!=0x08000207){fprintf(stderr,"BOX_ERROR,hold-idle\n");return;}keys->B_BUTTON=1;}
    if(box_step==24){if(R32(A_MARIO_STATES+M_ACTION)!=0x80000588u||R16(A_MARIO_STATES+M_ACTION_TIMER)!=6){fprintf(stderr,"BOX_ERROR,throw-phase\n");return;}bv(R32(A_MARIO_STATES+0x98)+0x18,-1849,24800,-971,"highHOLP");}
    if(box_step==42)box_pose(6100,331,3380,0x0100088c);
    if(box_step==43)box_pose(-1849,25080,-939,0x0100088c);
    if(box_step==44)bw32(A_TIME_STOP_STATE,0,"timeStop");
    if(box_step<48)fprintf(stderr,"BOX_INPUT,step=%d,buttons=%u,x=%d,y=%d,A=0\n",box_step+1,keys->B_BUTTON?16384:0,keys->X_AXIS,keys->Y_AXIS);
    ++box_step;
}
