// This file is part of GNOME Games. License: GPL-3.0+.

#include "raw-gamepad.h"

#include "../event/event.h"

/**
 * SECTION:raw-gamepad
 * @Short_description: Low-level representation of a gamepad
 * @Title: GamesRawGamepad
 */

G_DEFINE_INTERFACE (GamesRawGamepad, games_raw_gamepad, G_TYPE_OBJECT)

/* Signals */
enum {
  SIGNAL_EVENT,
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

const gchar *
games_raw_gamepad_get_name (GamesRawGamepad *self)
{
  g_return_val_if_fail (self != NULL, NULL);

  return GAMES_RAW_GAMEPAD_GET_IFACE (self)->get_name (self);
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
   * GamesRawGamepad::event:
   * @event: the event emitted by the gamepad
   **/
  signals[SIGNAL_EVENT] =
    g_signal_new ("event",
                  GAMES_TYPE_RAW_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__BOXED,
                  G_TYPE_NONE, 1,
                  GAMES_TYPE_EVENT | G_SIGNAL_TYPE_STATIC_SCOPE);

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
