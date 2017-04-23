// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_LINUX_RAW_GAMEPAD_MONITOR_H
#define GAMES_LINUX_RAW_GAMEPAD_MONITOR_H

#include <glib-object.h>

G_BEGIN_DECLS

#define GAMES_TYPE_LINUX_RAW_GAMEPAD_MONITOR (games_linux_raw_gamepad_monitor_get_type())

G_DECLARE_FINAL_TYPE (GamesLinuxRawGamepadMonitor, games_linux_raw_gamepad_monitor, GAMES, LINUX_RAW_GAMEPAD_MONITOR, GObject)

GamesLinuxRawGamepadMonitor *games_linux_raw_gamepad_monitor_get_instance (void);

G_END_DECLS

#endif /* GAMES_LINUX_RAW_GAMEPAD_MONITOR_H */

