"""Headless Mupen64Plus driven from Python (ctypes), for recording the real game.

    from m64 import Emu
    emu = Emu(rom, mapfile)
    emu.on_vi = lambda emu: ...          # called once per VI (frame), inputs go here
    emu.run()                            # blocks until emu.stop()

- No video or audio plugin (the core substitutes dummies). HLE RSP. Scripted input
  through oracle-input.so (`emu.keys = ...`).
- Debugger API: breakpoints on PC with a Python handler, register and RDRAM access.
- RDRAM is exposed big-endian (N64 byte order) through read/write helpers.
"""
import ctypes as C
import os
import re
import struct
import tempfile

import numpy as np

ORACLE = os.path.expanduser("~/sm64-oracle")
CORE = f"{ORACLE}/mupen64plus-core/projects/unix/libmupen64plus.so.2"
RSP = f"{ORACLE}/mupen64plus-rsp-hle/projects/unix/mupen64plus-rsp-hle.so"
INPUT = f"{ORACLE}/oracle-input.so"
VIDEO = f"{ORACLE}/oracle-video.so"

M64TYPE_INT, M64TYPE_BOOL = 1, 3
M64PLUGIN_RSP, M64PLUGIN_GFX, M64PLUGIN_INPUT = 1, 2, 4
CMD_ROM_OPEN, CMD_EXECUTE, CMD_STOP, CMD_STATE_LOAD, CMD_STATE_SAVE = 1, 5, 6, 10, 11
CMD_CORE_STATE_SET, M64CORE_SPEED_LIMITER = 17, 5
RUNSTATE_PAUSED, RUNSTATE_STEPPING, RUNSTATE_RUNNING = 0, 1, 2
DBG_PTR_RDRAM = 1
CPU_PC, CPU_REG_REG, CPU_REG_COP1_SIMPLE_PTR = 1, 2, 7
BKP_CMD_ADD_ADDR, BKP_CMD_REMOVE_ADDR = 1, 3
RDRAM_SIZE = 0x400000  # SM64 uses 4 MB

# buttons (BUTTONS union bit order, low 16 bits)
R_DPAD, L_DPAD, D_DPAD, U_DPAD = 1, 2, 4, 8
START, Z, B, A = 0x10, 0x20, 0x40, 0x80
R_CBTN, L_CBTN, D_CBTN, U_CBTN, R_TRIG, L_TRIG = 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000


def pad(buttons=0, x=0, y=0):
    return (buttons & 0xFFFF) | ((x & 0xFF) << 16) | ((y & 0xFF) << 24)


def load_map(path):
    """GNU ld map -> {symbol: address} for KSEG0 symbols."""
    syms = {}
    pat = re.compile(r"^\s+0x([0-9a-fA-F]{8,16})\s+([A-Za-z_][A-Za-z0-9_]*)\s*$")
    with open(path) as f:
        for line in f:
            m = pat.match(line)
            if m:
                a = int(m.group(1), 16) & 0xFFFFFFFF
                if 0x80000000 <= a < 0x80800000:
                    syms[m.group(2)] = a
    return syms


DEBUGCB = C.CFUNCTYPE(None, C.c_void_p, C.c_int, C.c_char_p)
STATECB = C.CFUNCTYPE(None, C.c_void_p, C.c_int, C.c_int)
DBG_INIT = C.CFUNCTYPE(None)
DBG_UPDATE = C.CFUNCTYPE(None, C.c_uint)
DBG_VI = C.CFUNCTYPE(None)


class Emu:
    def __init__(self, rom, mapfile=None, verbose=False):
        self.verbose = verbose
        self.syms = load_map(mapfile) if mapfile else {}
        self.core = C.CDLL(CORE, mode=os.RTLD_NOW | C.RTLD_GLOBAL)
        self._cbs = []  # keep ctypes callbacks alive
        self.on_vi = None
        self.bp_handlers = {}  # pc -> fn(emu, pc)
        self.on_step = None    # fn(emu, pc) for every instruction while stepping
        self.stepping = False
        self.frame = 0
        self.keys = 0
        cfg = tempfile.mkdtemp(prefix="m64cfg")

        def dbg(ctx, level, msg):
            if self.verbose or level <= 2:
                print(f"[core {level}] {msg.decode(errors='replace')}")

        self._dbg = DEBUGCB(dbg)
        self._state = STATECB(lambda c, p, v: None)
        rc = self.core.CoreStartup(0x020106, cfg.encode(), cfg.encode(), None, self._dbg,
                                   None, self._state)
        assert rc == 0, f"CoreStartup {rc}"
        sec = C.c_void_p()
        self.core.ConfigOpenSection(b"Core", C.byref(sec))
        self.core.ConfigSetParameter(sec, b"R4300Emulator", M64TYPE_INT, C.byref(C.c_int(1)))
        self.core.ConfigSetParameter(sec, b"EnableDebugger", M64TYPE_BOOL, C.byref(C.c_int(1)))
        self.core.ConfigSetParameter(sec, b"OnScreenDisplay", M64TYPE_BOOL, C.byref(C.c_int(0)))
        data = open(rom, "rb").read()
        buf = C.create_string_buffer(data, len(data))
        rc = self.core.CoreDoCommand(CMD_ROM_OPEN, len(data), buf)
        assert rc == 0, f"ROM_OPEN {rc}"
        self.vid = C.CDLL(VIDEO)
        self.inp = C.CDLL(INPUT)
        self.rsp = C.CDLL(RSP)
        for lib, kind in ((self.vid, M64PLUGIN_GFX), (self.inp, M64PLUGIN_INPUT),
                          (self.rsp, M64PLUGIN_RSP)):
            rc = lib.PluginStartup(C.c_void_p(self.core._handle), None, self._dbg)
            assert rc == 0, f"PluginStartup {rc}"
            rc = self.core.CoreAttachPlugin(kind, C.c_void_p(lib._handle))
            assert rc == 0, f"CoreAttachPlugin {kind}: {rc}"
        self._keys = C.c_uint.in_dll(self.inp, "oracle_keys")
        self._init = DBG_INIT(lambda: None)
        self._update = DBG_UPDATE(self._on_update)
        self._vi = DBG_VI(self._on_vi)
        self.core.DebugSetCallbacks(self._init, self._update, self._vi)
        self.core.DebugMemGetPointer.restype = C.c_void_p
        self.core.DebugGetCPUDataPtr.restype = C.c_void_p
        self._rdram = None
        self._regs = None
        self._fprs = None

    # ---------------- memory (N64 byte order) ----------------
    def _ram(self):
        if self._rdram is None:
            p = self.core.DebugMemGetPointer(DBG_PTR_RDRAM)
            self._rdram = (C.c_uint32 * (RDRAM_SIZE // 4)).from_address(p)
        return self._rdram

    @staticmethod
    def _phys(addr):
        return addr & 0x1FFFFFFF

    def read32(self, addr):
        return self._ram()[self._phys(addr) >> 2]

    def write32(self, addr, v):
        self._ram()[self._phys(addr) >> 2] = v & 0xFFFFFFFF

    def read(self, addr, n):
        """n bytes starting at addr, big-endian (as the N64 sees them)."""
        a = self._phys(addr)
        w0, w1 = a >> 2, (a + n + 3) >> 2
        words = self._ram()[w0:w1]
        raw = struct.pack(f">{len(words)}I", *words)
        return raw[a & 3:(a & 3) + n]

    def read16(self, addr):
        return struct.unpack(">H", self.read(addr, 2))[0]

    def write16(self, addr, v):
        w = addr & ~3
        cur = self.read32(w)
        sh = 16 if (addr & 2) == 0 else 0
        self.write32(w, (cur & ~(0xFFFF << sh)) | ((v & 0xFFFF) << sh))

    def readf(self, addr):
        return struct.unpack(">f", struct.pack(">I", self.read32(addr)))[0]

    def dump(self):
        """All of RDRAM as N64-order bytes."""
        return np.ctypeslib.as_array(self._ram()).astype(">u4").tobytes()

    def sym(self, name):
        return self.syms[name]

    # ---------------- CPU ----------------
    def reg(self, i):
        if self._regs is None:
            self._regs = (C.c_int64 * 32).from_address(self.core.DebugGetCPUDataPtr(CPU_REG_REG))
        return self._regs[i] & 0xFFFFFFFF

    def fpr_bits(self, i):
        """Raw 32 bits of single-precision FPR i (e.g. f0, f12, f14)."""
        if self._fprs is None:
            self._fprs = (C.c_void_p * 32).from_address(self.core.DebugGetCPUDataPtr(CPU_REG_COP1_SIMPLE_PTR))
        return C.c_uint32.from_address(self._fprs[i]).value

    # ---------------- breakpoints ----------------
    def add_bp(self, pc, fn):
        self.bp_handlers[pc] = fn
        self.core.DebugBreakpointCommand(BKP_CMD_ADD_ADDR, pc, None)

    def del_bp(self, pc):
        self.bp_handlers.pop(pc, None)
        self.core.DebugBreakpointCommand(BKP_CMD_REMOVE_ADDR, pc, None)

    def _on_update(self, pc):
        """Called on a breakpoint hit (core paused) and, while stepping, on every
        instruction (core not paused).  Breakpoints are checked in both states."""
        hit = pc in self.bp_handlers
        try:
            if hit:
                self.bp_handlers[pc](self, pc)
            if self.stepping and self.on_step:
                self.on_step(self, pc)
        finally:
            self.core.DebugSetRunState(RUNSTATE_STEPPING if self.stepping else RUNSTATE_RUNNING)
            if hit:
                self.core.DebugStep()

    def _on_vi(self):
        if self.frame == 0:  # unthrottle once running
            self.core.CoreDoCommand(CMD_CORE_STATE_SET, M64CORE_SPEED_LIMITER, C.byref(C.c_int(0)))
        self.frame += 1
        if self.on_vi:
            self.on_vi(self)
        self._keys.value = self.keys

    # ---------------- control ----------------
    def run(self):
        self.core.DebugSetRunState(RUNSTATE_RUNNING)
        return self.core.CoreDoCommand(CMD_EXECUTE, 0, None)

    def stop(self):
        self.core.CoreDoCommand(CMD_STOP, 0, None)

    def save_state(self, path):
        return self.core.CoreDoCommand(CMD_STATE_SAVE, 1, os.path.abspath(path).encode())

    def load_state(self, path):
        return self.core.CoreDoCommand(CMD_STATE_LOAD, 0, os.path.abspath(path).encode())
