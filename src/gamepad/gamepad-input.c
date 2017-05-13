// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-input.h"

#include <string.h>

GamesGamepadInput *
games_gamepad_input_dup (const GamesGamepadInput *self)
{
  GamesGamepadInput *dup;

  dup = g_new0 (GamesGamepadInput, 1);
  memcpy (dup, self, sizeof (GamesGamepadInput));

  return dup;
}

void
games_gamepad_input_free (GamesGamepadInput *self)
{
  g_free (self);
}

GType
games_gamepad_input_get_type (void)
{
  static volatile gsize type_id = 0;

  if (g_once_init_enter (&type_id))
    g_once_init_leave (&type_id,
                       g_boxed_type_register_static ("GamesGamepadInput",
                                                     (GBoxedCopyFunc) games_gamepad_input_dup,
                                                     (GBoxedFreeFunc) games_gamepad_input_free));

  return type_id;
}
