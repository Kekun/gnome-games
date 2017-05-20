// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_RAW_GAMEPAD_H
#define GAMES_RAW_GAMEPAD_H

#include <glib-object.h>

G_BEGIN_DECLS

#define GAMES_TYPE_RAW_GAMEPAD (games_raw_gamepad_get_type ())

G_DECLARE_INTERFACE (GamesRawGamepad, games_raw_gamepad, GAMES, RAW_GAMEPAD, GObject)

struct _GamesRawGamepadInterface {
  GTypeInterface parent;

  const gchar *(*get_guid) (GamesRawGamepad *self);
  const gchar *(*get_name) (GamesRawGamepad *self);
};

const gchar *games_raw_gamepad_get_guid (GamesRawGamepad *self);
const gchar *games_raw_gamepad_get_name (GamesRawGamepad *self);

G_END_DECLS

#endif /* GAMES_RAW_GAMEPAD_H */
