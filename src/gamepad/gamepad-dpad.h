// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_GAMEPAD_DPAD_H
#define GAMES_GAMEPAD_DPAD_H

#include <glib-object.h>
#include "gamepad-input.h"

G_BEGIN_DECLS

#define GAMES_TYPE_GAMEPAD_DPAD (games_gamepad_dpad_get_type ())

typedef struct {
  GamesGamepadInput inputs[4];
  gint32 axis_values[2];
} GamesGamepadDPad;

GType games_gamepad_dpad_get_type (void) G_GNUC_CONST;
GamesGamepadDPad *games_gamepad_dpad_dup (const GamesGamepadDPad *self);
void games_gamepad_dpad_free (GamesGamepadDPad *self);

G_END_DECLS

#endif /* GAMES_GAMEPAD_DPAD_H */
