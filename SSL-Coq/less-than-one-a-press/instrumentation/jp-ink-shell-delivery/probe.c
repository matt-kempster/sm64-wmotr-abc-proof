/* One disclosed shell-box action grant; all pickup/release pointers are native. */
#define M64P_PLUGIN_PROTOTYPES
#include <mupen64plus/m64p_plugin.h>
static void delivery_observe(int control,BUTTONS *keys);
#define WAFEL_PILOT_EXTRA_INPUT delivery_observe
#define PluginStartup delivery_base_startup
#include "../wafel-jp-pilot/capture.c"
#undef PluginStartup
static void (*delivery_write32)(unsigned int,unsigned int);
EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle core,void *ctx,void (*cb)(void *,int,const char *)) {
 m64p_error r=delivery_base_startup(core,ctx,cb);if(r!=M64ERR_SUCCESS)return r;
 delivery_write32=dlsym(core,"DebugMemWrite32");
 return delivery_write32?M64ERR_SUCCESS:M64ERR_INCOMPATIBLE;
}
static void delivery_observe(int control,BUTTONS *keys) {
 uint32_t obj=A_OBJECT_POOL+23*OBJECT_SIZE,box=A_OBJECT_POOL+32*OBJECT_SIZE;
 if(control||R16(A_CURR_AREA)!=1||pilot_slot(R32(A_MARIO_OBJECT))<0)return;
 if(keys->A_BUTTON)abort();
 fprintf(stderr,"SHELL_DELIVERY,{\"poll\":%llu,\"timer\":%u,\"used\":%d,\"held\":%d,\"ridden\":%d,\"shellBoxAction\":%u,\"slot23\":{\"active\":%u,\"flags\":%u,\"parent\":%d,\"posBits\":[%u,%u,%u],\"type\":%u,\"subtype\":%u,\"status\":%u,\"intangible\":%d,\"heldState\":%u,\"action\":%u,\"timer\":%u,\"radiusBits\":%u,\"heightBits\":%u},\"behaviorAddress\":%u,\"commandAddress\":%u}\n",
 (unsigned long long)gPoll,R32(A_GLOBAL_TIMER),pilot_slot(R32(A_MARIO_STATES+M_USED_OBJ)),pilot_slot(R32(A_MARIO_STATES+M_HELD_OBJ)),pilot_slot(R32(A_MARIO_STATES+0x84)),R32(box+O_ACTION),R16(obj+O_ACTIVE_FLAGS),R32(obj+O_FLAGS),pilot_slot(R32(obj+0x68)),R32(obj+O_POS_X),R32(obj+O_POS_Y),R32(obj+O_POS_Z),R32(obj+O_INTERACT_TYPE),R32(obj+0x190),R32(obj+0x134),(int32_t)R32(obj+0x9c),R32(obj+0x124),R32(obj+O_ACTION),R32(obj+O_TIMER),R32(obj+0x1f8),R32(obj+0x1fc),R32(obj+O_BEHAVIOR),R32(obj+0x1cc));
 if(gPoll==DELIVERY_GRANT_POLL){
  if(R32(box+O_ACTION)!=2)abort();
  fprintf(stderr,"SHELL_DELIVERY_WRITE,{\"poll\":%llu,\"slot\":32,\"field\":\"oAction\",\"before\":2,\"after\":4}\n",(unsigned long long)gPoll);
  delivery_write32(box+O_ACTION,4);
 }
}
