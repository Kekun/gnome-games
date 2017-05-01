// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_GAMEPAD_H
#define GAMES_GAMEPAD_H

#include <glib-object.h>
#include "raw-gamepad.h"

G_BEGIN_DECLS

#define GAMES_TYPE_GAMEPAD (games_gamepad_get_type())

G_DECLARE_FINAL_TYPE (GamesGamepad, games_gamepad, GAMES, GAMEPAD, GObject)

GamesGamepad *games_gamepad_new (GamesRawGamepad  *raw_gamepad,
                                 GError          **error);

G_END_DECLS

#endif /* GAMES_GAMEPAD_H */
