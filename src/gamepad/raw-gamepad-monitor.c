// This file is part of GNOME Games. License: GPL-3.0+.

#include "raw-gamepad-monitor.h"

G_DEFINE_INTERFACE (GamesRawGamepadMonitor, games_raw_gamepad_monitor, G_TYPE_OBJECT)

/**
 * SECTION:raw-gamepad-monitor
 * @Short_description: Monitor the plugged gamepads
 * @Title: GamesRawGamepadMonitor
 */

/* Signals */
enum {
  SIGNAL_GAMEPAD_PLUGGED,
  LAST_SIGNAL,
};

static guint signals[LAST_SIGNAL] = { 0 };

/* Public */

/**
 * games_raw_gamepad_monitor_foreach_gamepad:
 * @self: a #GamesRawGamepadMonitor
 * @callback: the callback handling each #RawGamepad
 * @data: the data to pass to the callback
 *
 * Iterates through the available gamepads.
 **/
void
games_raw_gamepad_monitor_foreach_gamepad (GamesRawGamepadMonitor  *self,
                                           GamesRawGamepadCallback  callback,
                                           gpointer                 data)
{
  g_return_if_fail (self != NULL);

  GAMES_RAW_GAMEPAD_MONITOR_GET_IFACE (self)->foreach_gamepad (self, callback, data);
}

/* Type */

static void
games_raw_gamepad_monitor_default_init (GamesRawGamepadMonitorInterface *iface)
{
  static gboolean initialized = FALSE;

  if (initialized)
    return;

  initialized = TRUE;

  /**
   * GamesRawGamepadMonitor::gamepad-plugged:
   * @gamepad: the gamepad which got plugged in
   *
   * Emitted when a gamepad is plugged in.
   **/
  signals[SIGNAL_GAMEPAD_PLUGGED] =
    g_signal_new ("gamepad-plugged",
                  GAMES_TYPE_RAW_GAMEPAD_MONITOR,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__OBJECT,
                  G_TYPE_NONE, 1,
                  GAMES_TYPE_RAW_GAMEPAD);
}
