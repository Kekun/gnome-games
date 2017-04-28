// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-dpad.h"

#include <string.h>

GamesGamepadDPad *
games_gamepad_dpad_dup (const GamesGamepadDPad *self)
{
  GamesGamepadDPad *dup;

  dup = g_new0 (GamesGamepadDPad, 1);
  memcpy (dup, self, sizeof (GamesGamepadDPad));

  return dup;
}

void
games_gamepad_dpad_free (GamesGamepadDPad *self)
{
  g_free (self);
}

GType
games_gamepad_dpad_get_type (void)
{
  static volatile gsize type_id = 0;

  if (g_once_init_enter (&type_id))
    g_once_init_leave (&type_id,
                       g_boxed_type_register_static ("GamesGamepadDPad",
                                                     (GBoxedCopyFunc) games_gamepad_dpad_dup,
                                                     (GBoxedFreeFunc) games_gamepad_dpad_free));

  return type_id;
}
