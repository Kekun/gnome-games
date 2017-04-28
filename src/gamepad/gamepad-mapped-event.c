// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-mapped-event.h"

#include <string.h>

GamesGamepadMappedEvent *
games_gamepad_mapped_event_dup (const GamesGamepadMappedEvent *self)
{
  GamesGamepadMappedEvent *dup;

  dup = g_new0 (GamesGamepadMappedEvent, 1);
  memcpy (dup, self, sizeof (GamesGamepadMappedEvent));

  return dup;
}

void
games_gamepad_mapped_event_free (GamesGamepadMappedEvent *self)
{
  g_free (self);
}

GType
games_gamepad_mapped_event_get_type (void)
{
  static volatile gsize type_id = 0;

  if (g_once_init_enter (&type_id))
    g_once_init_leave (&type_id,
                       g_boxed_type_register_static ("GamesGamepadMappedEvent",
                                                     (GBoxedCopyFunc) games_gamepad_mapped_event_dup,
                                                     (GBoxedFreeFunc) games_gamepad_mapped_event_free));

  return type_id;
}
