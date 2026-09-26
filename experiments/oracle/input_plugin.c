/* Scripted input plugin for Mupen64Plus: controller 1 reports whatever the
   frontend last wrote into `oracle_keys` (the BUTTONS union, low 16 bits =
   buttons, then signed X and Y bytes).  The Python frontend sets it through
   ctypes before each frame. */
#include <stdint.h>
#define M64P_PLUGIN_PROTOTYPES 1
#include "m64p_types.h"
#include "m64p_plugin.h"

__attribute__((visibility("default"))) volatile unsigned int oracle_keys = 0;

EXPORT m64p_error CALL PluginStartup(m64p_dynlib_handle h, void *ctx,
                                     void (*dbg)(void *, int, const char *)) {
  return M64ERR_SUCCESS;
}
EXPORT m64p_error CALL PluginShutdown(void) { return M64ERR_SUCCESS; }
EXPORT m64p_error CALL PluginGetVersion(m64p_plugin_type *t, int *v, int *api,
                                        const char **name, int *caps) {
  if (t) *t = M64PLUGIN_INPUT;
  if (v) *v = 0x010000;
  if (api) *api = 0x020101;
  if (name) *name = "oracle-input";
  if (caps) *caps = 0;
  return M64ERR_SUCCESS;
}
EXPORT void CALL InitiateControllers(CONTROL_INFO info) {
  info.Controls[0].Present = 1;
  info.Controls[0].Plugin = PLUGIN_NONE;
}
EXPORT void CALL GetKeys(int ctl, BUTTONS *keys) {
  keys->Value = ctl == 0 ? oracle_keys : 0;
}
EXPORT void CALL ControllerCommand(int ctl, unsigned char *cmd) {}
EXPORT void CALL ReadController(int ctl, unsigned char *cmd) {}
EXPORT int CALL RomOpen(void) { return 1; }
EXPORT void CALL RomClosed(void) {}
EXPORT void CALL SDL_KeyDown(int keymod, int keysym) {}
EXPORT void CALL SDL_KeyUp(int keymod, int keysym) {}
EXPORT void CALL RenderCallback(void) {}
