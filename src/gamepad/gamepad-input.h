// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_GAMEPAD_INPUT_H
#define GAMES_GAMEPAD_INPUT_H

#include <glib-object.h>

G_BEGIN_DECLS

#define GAMES_TYPE_GAMEPAD_INPUT (games_gamepad_input_get_type ())

typedef struct {
  guint16 type;
  guint16 code;
} GamesGamepadInput;

GType games_gamepad_input_get_type (void) G_GNUC_CONST;
GamesGamepadInput *games_gamepad_input_dup (const GamesGamepadInput *self);
void games_gamepad_input_free (GamesGamepadInput *self);

G_END_DECLS

#endif /* GAMES_GAMEPAD_INPUT_H */
