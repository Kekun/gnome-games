// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_GAMEPAD_MONITOR_H
#define GAMES_GAMEPAD_MONITOR_H

#include <glib-object.h>
#include "gamepad.h"

G_BEGIN_DECLS

typedef void (*GamesGamepadCallback) (GamesGamepad *gamepad,
                                      gpointer      target);

#define GAMES_TYPE_GAMEPAD_MONITOR (games_gamepad_monitor_get_type())

G_DECLARE_FINAL_TYPE (GamesGamepadMonitor, games_gamepad_monitor, GAMES, GAMEPAD_MONITOR, GObject)

GamesGamepadMonitor *games_gamepad_monitor_get_instance (void);
void games_gamepad_monitor_foreach_gamepad (GamesGamepadMonitor *self,
                                            GamesGamepadCallback callback,
                                            gpointer target);

G_END_DECLS

#endif /* GAMES_GAMEPAD_MONITOR_H */

