// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_GAMEPAD_MAPPING_ERROR_H
#define GAMES_GAMEPAD_MAPPING_ERROR_H

#include <glib.h>

G_BEGIN_DECLS

#define GAMES_GAMEPAD_MAPPING_ERROR games_gamepad_mapping_error_quark ()

typedef enum {
  GAMES_GAMEPAD_MAPPING_ERROR_NOT_A_MAPPING,
} GamesGamepadMappingError;

GQuark games_gamepad_mapping_error_quark (void);

G_END_DECLS

#endif /* GAMES_GAMEPAD_MAPPING_ERROR_H */
