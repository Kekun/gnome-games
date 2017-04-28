// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-input-type.h"

GType
games_gamepad_input_type_get_type (void)
{
  static volatile gsize type_id = 0;
  static const GEnumValue values[] = {
    { GAMES_GAMEPAD_INPUT_TYPE_INVALID, "GAMES_GAMEPAD_INPUT_TYPE_INVALID", "invalid" },
    { GAMES_GAMEPAD_INPUT_TYPE_AXIS, "GAMES_GAMEPAD_INPUT_TYPE_AXIS", "axis" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "GAMES_GAMEPAD_INPUT_TYPE_BUTTON", "button" },
    { 0, NULL, NULL },
  };

  if (g_once_init_enter (&type_id))
    g_once_init_leave (&type_id,
                       g_enum_register_static ("GamesGamepadInputType",
                                               values));

  return type_id;
}
