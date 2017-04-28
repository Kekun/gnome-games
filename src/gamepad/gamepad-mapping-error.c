// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-mapping-error.h"

GQuark
games_gamepad_mapping_error_quark (void)
{
  return g_quark_from_static_string ("games-gamepad-mapping-error-quark");
}
