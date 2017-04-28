// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_GAMEPAD_MAPPING_H
#define GAMES_GAMEPAD_MAPPING_H

#include <glib-object.h>
#include "gamepad-mapped-event.h"

G_BEGIN_DECLS

#define GAMES_TYPE_GAMEPAD_MAPPING (games_gamepad_mapping_get_type())

G_DECLARE_FINAL_TYPE (GamesGamepadMapping, games_gamepad_mapping, GAMES, GAMEPAD_MAPPING, GObject)

GamesGamepadMapping *games_gamepad_mapping_new_from_sdl_string (const gchar  *mapping_string,
                                                                GError      **error);
void games_gamepad_mapping_get_dpad_mapping (GamesGamepadMapping     *self,
                                             gint                     dpad_index,
                                             gint                     dpad_axis,
                                             gint                     dpad_value,
                                             GamesGamepadMappedEvent *result);
void games_gamepad_mapping_get_axis_mapping (GamesGamepadMapping     *self,
                                             gint                     axis_number,
                                             GamesGamepadMappedEvent *result);
void games_gamepad_mapping_get_button_mapping (GamesGamepadMapping     *self,
                                               gint                     button_number,
                                               GamesGamepadMappedEvent *result);

G_END_DECLS

#endif /* GAMES_GAMEPAD_MAPPING_H */
