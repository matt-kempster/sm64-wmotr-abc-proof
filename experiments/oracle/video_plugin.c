/* Headless video plugin: draws nothing, but completes every display list the
   way real hardware does, by raising the DP interrupt.  Without it the game
   thread waits forever for its graphics task (the core's dummy plugin never
   signals completion). */
#include <stdint.h>
#include <stddef.h>
#define M64P_PLUGIN_PROTOTYPES 1
#include "m64p_types.h"
#include "m64p_plugin.h"

static GFX_INFO gfx;

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle h, void *ctx,
                                     void (*dbg)(void *, int, const char *)) {
  return M64ERR_SUCCESS;
}
EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }
EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *t, int *v, int *api,
                                        const char **name, int *caps) {
  if (t) *t = M64PLUGIN_GFX;
  if (v) *v = 0x010000;
  if (api) *api = 0x020200;
  if (name) *name = "oracle-video";
  if (caps) *caps = 0;
  return M64ERR_SUCCESS;
}
static void dp_done(void) {
  *gfx.MI_INTR_REG |= 0x20; /* MI_INTR_DP */
  gfx.CheckInterrupts();
}
EXPORT int CALL InitiateGFX(GFX_INFO info) { gfx = info; return 1; }
EXPORT void CALL ProcessDList(void) { dp_done(); }
EXPORT void CALL ProcessRDPList(void) {
  *gfx.DPC_CURRENT_REG = *gfx.DPC_END_REG;
  dp_done();
}
EXPORT void CALL ChangeWindow(void) {}
EXPORT void CALL MoveScreen(int x, int y) {}
EXPORT int CALL RomOpen(void) { return 1; }
EXPORT void CALL RomClosed(void) {}
EXPORT void CALL ShowCFB(void) {}
EXPORT void CALL UpdateScreen(void) {}
EXPORT void CALL ViStatusChanged(void) {}
EXPORT void CALL ViWidthChanged(void) {}
EXPORT void CALL ReadScreen2(void *dest, int *w, int *h, int front) {
  if (w) *w = 0;
  if (h) *h = 0;
}
EXPORT void CALL SetRenderingCallback(void (*cb)(int)) {}
EXPORT void CALL ResizeVideoOutput(int w, int h) {}
EXPORT void CALL FBRead(unsigned int addr) {}
EXPORT void CALL FBWrite(unsigned int addr, unsigned int size) {}
EXPORT void CALL FBGetFrameBufferInfo(void *p) {}
