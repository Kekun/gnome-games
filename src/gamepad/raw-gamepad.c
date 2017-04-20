// This file is part of GNOME Games. License: GPL-3.0+.

#include "raw-gamepad.h"

#include "standard-gamepad-axis.h"
#include "standard-gamepad-button.h"

/**
 * SECTION:raw-gamepad
 * @Short_description: Low-level representation of a gamepad
 * @Title: GamesRawGamepad
 */

G_DEFINE_INTERFACE (GamesRawGamepad, games_raw_gamepad, G_TYPE_OBJECT)

/* Signals */
enum {
  SIGNAL_STANDARD_BUTTON_EVENT,
  SIGNAL_BUTTON_EVENT,
  SIGNAL_STANDARD_AXIS_EVENT,
  SIGNAL_AXIS_EVENT,
  SIGNAL_DPAD_EVENT,
  SIGNAL_UNPLUGGED,
  LAST_SIGNAL,
};

static guint signals[LAST_SIGNAL] = { 0 };

/* Public */

/**
 * games_raw_gamepad_get_guid:
 * @self: a #GamesRawGamepad
 *
 * Returns the GUID reprensenting this gamepad for SDL2 mappings.
 *
 * Return value: %TRUE if a menu is displayed, %FALSE otherwise
 **/
const gchar *
games_raw_gamepad_get_guid (GamesRawGamepad *self)
{
  g_return_val_if_fail (self != NULL, NULL);

  return GAMES_RAW_GAMEPAD_GET_IFACE (self)->get_guid (self);
}

/* Type */

static void
games_raw_gamepad_default_init (GamesRawGamepadInterface *iface)
{
  static gboolean initialized = FALSE;

  if (initialized)
    return;

  initialized = TRUE;

  /**
   * GamesRawGamepad::standard-button-event:
   * @button: the standard button emitting the event
   * @value: %TRUE if the button is pressed, %FALSE otherwise
   *
   * Emitted when a standard button is pressed/released.
   **/
  signals[SIGNAL_STANDARD_BUTTON_EVENT] =
    g_signal_new ("standard-button-event",
                  GAMES_TYPE_RAW_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  NULL,
                  G_TYPE_NONE, 2,
                  GAMES_TYPE_STANDARD_GAMEPAD_BUTTON,
                  G_TYPE_BOOLEAN);

  /**
   * GamesRawGamepad::button-event:
   * @button: the code representing the button
   * @value: %TRUE if the button is pressed, %FALSE otherwise
   *
   * Emitted when a button is pressed/released.
   **/
  signals[SIGNAL_BUTTON_EVENT] =
    g_signal_new ("button-event",
                  GAMES_TYPE_RAW_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  NULL,
                  G_TYPE_NONE, 2,
                  G_TYPE_INT,
                  G_TYPE_BOOLEAN);

  /**
   * GamesRawGamepad::standard-axis-event:
   * @axis: the standard axis emitting the event
   * @value: the value of the axis ranging from -1 to 1
   *
   * Emitted when a standard axis' value changes.
   **/
  signals[SIGNAL_STANDARD_AXIS_EVENT] =
    g_signal_new ("standard-axis-event",
                  GAMES_TYPE_RAW_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  NULL,
                  G_TYPE_NONE, 2,
                  GAMES_TYPE_STANDARD_GAMEPAD_AXIS,
                  G_TYPE_DOUBLE);

  /**
   * GamesRawGamepad::axis-event:
   * @axis: the code representing the axis
   * @value: the value of the axis ranging from -1 to 1
   *
   * Emitted when an axis' value changes.
   **/
  signals[SIGNAL_AXIS_EVENT] =
    g_signal_new ("axis-event",
                  GAMES_TYPE_RAW_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  NULL,
                  G_TYPE_NONE, 2,
                  G_TYPE_INT,
                  G_TYPE_DOUBLE);

  /**
   * GamesRawGamepad::dpad-event:
   * @dpad: the code representing the dpad
   * @axis: the axis: 0 for X, 1 for Y
   * @value: the value of the axis ranging from -1 to 1
   *
   * Emitted when a dpad's axis value changes.
   **/
  signals[SIGNAL_DPAD_EVENT] =
    g_signal_new ("dpad-event",
                  GAMES_TYPE_RAW_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  NULL,
                  G_TYPE_NONE, 3,
                  G_TYPE_INT,
                  G_TYPE_INT,
                  G_TYPE_INT);

  /**
   * GamesRawGamepad::unplugged:
   *
   * Emitted when the gamepad is unplugged.
   **/
  signals[SIGNAL_UNPLUGGED] =
    g_signal_new ("unplugged",
                  GAMES_TYPE_RAW_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__VOID,
                  G_TYPE_NONE, 0);
}
