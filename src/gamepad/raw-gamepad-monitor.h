// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_RAW_GAMEPAD_MONITOR_H
#define GAMES_RAW_GAMEPAD_MONITOR_H

#include <glib-object.h>

#include "raw-gamepad.h"

G_BEGIN_DECLS

typedef void (*GamesRawGamepadCallback) (GamesRawGamepad *raw_gamepad,
                                         gpointer         target);

#define GAMES_TYPE_RAW_GAMEPAD_MONITOR (games_raw_gamepad_monitor_get_type ())

G_DECLARE_INTERFACE (GamesRawGamepadMonitor, games_raw_gamepad_monitor, GAMES, RAW_GAMEPAD_MONITOR, GObject)

struct _GamesRawGamepadMonitorInterface {
  GTypeInterface parent;

  void (*foreach_gamepad) (GamesRawGamepadMonitor  *self,
                           GamesRawGamepadCallback  callback,
                           gpointer                 callback_target);
};

void games_raw_gamepad_monitor_foreach_gamepad (GamesRawGamepadMonitor  *self,
                                                GamesRawGamepadCallback  callback,
                                                gpointer                 data);

G_END_DECLS

#endif /* GAMES_RAW_GAMEPAD_MONITOR_H */
