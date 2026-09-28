#!/usr/bin/env bash
# Reproduce the original supplementary linkage for endpoint_update.py.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$PROJECT_ROOT/pipeline/generate-search-clight.sh" \
  main=src/game/main.c camera=src/game/camera.c game_init=src/game/game_init.c \
  sound_init=src/game/sound_init.c spawn_sound=src/game/spawn_sound.c \
  print=src/game/print.c hud=src/game/hud.c ingame_menu=src/game/ingame_menu.c \
  menu_file_select=src/menu/file_select.c menu_star_select=src/menu/star_select.c \
  goddard_renderer=src/goddard/renderer.c goddard_sfx=src/goddard/sfx.c \
  os_controller_read=lib/src/osContStartReadData.c \
  os_receive_message=lib/src/osRecvMesg.c os_send_message=lib/src/osSendMesg.c \
  os_create_message_queue=lib/src/osCreateMesgQueue.c \
  os_si_access=lib/src/__osSiCreateAccessQueue.c os_time=lib/src/osGetTime.c \
  profiler=src/game/profiler.c
