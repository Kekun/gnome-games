// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_STANDARD_GAMEPAD_AXIS_H
#define GAMES_STANDARD_GAMEPAD_AXIS_H

#include <glib-object.h>

G_BEGIN_DECLS

#define GAMES_TYPE_STANDARD_GAMEPAD_AXIS (games_standard_gamepad_axis_get_type ())

/**
 * GamesStandardGamepadAxis:
 * @GAMES_STANDARD_GAMEPAD_AXIS_UNKNOWN: an unknown axis
 * @GAMES_STANDARD_GAMEPAD_AXIS_LEFT_X: the horizontal axis of the left stick
 * @GAMES_STANDARD_GAMEPAD_AXIS_LEFT_Y: the vertical axis of the left stick
 * @GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_X: the horizontal axis of the right stick
 * @GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_Y: the vertical axis of the right stick
 *
 * The axes of a standard gamepad.
 *
 * For horizontal axes, left is -1 and right is 1; for vertical axes,
 * top is -1 and bottom is 1.
 **/
typedef enum {
  GAMES_STANDARD_GAMEPAD_AXIS_UNKNOWN,
  GAMES_STANDARD_GAMEPAD_AXIS_LEFT_X,
  GAMES_STANDARD_GAMEPAD_AXIS_LEFT_Y,
  GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_X,
  GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_Y,
} GamesStandardGamepadAxis;

GType games_standard_gamepad_axis_get_type (void) G_GNUC_CONST;

G_END_DECLS

#endif /* GAMES_STANDARD_GAMEPAD_AXIS_H */
