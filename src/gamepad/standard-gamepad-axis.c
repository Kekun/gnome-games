// This file is part of GNOME Games. License: GPL-3.0+.

#include "standard-gamepad-axis.h"

GType
games_standard_gamepad_axis_get_type (void)
{
  static volatile gsize type_id = 0;
  static const GEnumValue values[] = {
    { GAMES_STANDARD_GAMEPAD_AXIS_UNKNOWN, "GAMES_STANDARD_GAMEPAD_AXIS_UNKNOWN", "unknown" },
    { GAMES_STANDARD_GAMEPAD_AXIS_LEFT_X, "GAMES_STANDARD_GAMEPAD_AXIS_LEFT_X", "left-x" },
    { GAMES_STANDARD_GAMEPAD_AXIS_LEFT_Y, "GAMES_STANDARD_GAMEPAD_AXIS_LEFT_Y", "left-y" },
    { GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_X, "GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_X", "right-x" },
    { GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_Y, "GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_Y", "right-y" },
    { 0, NULL, NULL },
  };

  if (g_once_init_enter (&type_id))
    g_once_init_leave (&type_id,
                       g_enum_register_static ("GamesStandardGamepadAxis",
                                               values));

  return type_id;
}
