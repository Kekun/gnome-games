// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-monitor.h"

#include <glib.h>
#include <glib-object.h>
#include "gamepad-mapping-error.h"
#include "gamepad-mappings-manager.h"
#include "linux/linux-raw-gamepad-monitor.h"
#include "raw-gamepad.h"
#include "raw-gamepad-monitor.h"

struct _GamesGamepadMonitor {
  GObject parent_instance;

  GHashTable *gamepads;
};

G_DEFINE_TYPE (GamesGamepadMonitor, games_gamepad_monitor, G_TYPE_OBJECT)

enum {
  SIGNAL_GAMEPAD_PLUGGED,
  SIGNAL_GAMEPAD_UNPLUGGED,
  LAST_SIGNAL,
};

static guint signals[LAST_SIGNAL] = { 0 };

static GamesGamepadMonitor *instance = NULL;

typedef struct {
  GamesGamepadCallback callback;
  gpointer target;
} ForeachGamepadData;

/* Private */

static void
on_gamepad_unplugged (GamesGamepad *sender,
                      gpointer data)
{
  GamesGamepadMonitor *self;

  self = GAMES_GAMEPAD_MONITOR (data);

  g_return_if_fail (self != NULL);
  g_return_if_fail (sender != NULL);

  g_hash_table_remove (self->gamepads, sender);
  g_signal_emit (self, signals[SIGNAL_GAMEPAD_UNPLUGGED], 0);
}

static GamesGamepad *
add_gamepad (GamesGamepadMonitor *self,
             GamesRawGamepad     *raw_gamepad)
{
  GamesGamepad *gamepad = NULL;
  GError *inner_error = NULL;
  const gchar *guid;
  gchar *mapping_string;
  GamesGamepadMappingsManager *mappings_manager;
  GamesGamepadMapping *mapping = NULL;

  g_return_val_if_fail (self != NULL, NULL);
  g_return_val_if_fail (raw_gamepad != NULL, NULL);

  gamepad = games_gamepad_new (raw_gamepad);

  mappings_manager = games_gamepad_mappings_manager_get_instance ();
  guid = games_raw_gamepad_get_guid (raw_gamepad);
  mapping_string = games_gamepad_mappings_manager_get_mapping (mappings_manager, guid);
  mapping = games_gamepad_mapping_new_from_sdl_string (mapping_string, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_debug ("%s", inner_error->message);
    g_clear_error (&inner_error);
  }
  games_gamepad_set_mapping (gamepad, mapping);

  if (mapping != NULL)
    g_object_unref (mapping);
  if (mapping_string != NULL)
    g_free (mapping_string);

  g_hash_table_add (self->gamepads, g_object_ref (gamepad));
  g_signal_connect_object (gamepad,
                           "unplugged",
                           (GCallback) on_gamepad_unplugged,
                           self,
                           0);

  return gamepad;
}

static void
on_raw_gamepad_plugged (GamesRawGamepadMonitor *sender,
                        GamesRawGamepad        *raw_gamepad,
                        gpointer                target)
{
  GamesGamepadMonitor *self;
  GamesGamepad *gamepad;

  self = GAMES_GAMEPAD_MONITOR (target);

  g_return_if_fail (self != NULL);
  g_return_if_fail (raw_gamepad != NULL);

  gamepad = add_gamepad (self, raw_gamepad);
  if (gamepad != NULL) {
    g_signal_emit (self, signals[SIGNAL_GAMEPAD_PLUGGED], 0, gamepad);
    g_object_unref (gamepad);
  }
}

static void
add_raw_gamepad (GamesRawGamepad *raw_gamepad,
                 gpointer         target)
{
  GamesGamepadMonitor *self;
  GamesGamepad *gamepad;

  self = GAMES_GAMEPAD_MONITOR (target);

  g_return_if_fail (self != NULL);
  g_return_if_fail (raw_gamepad != NULL);

  g_object_unref (add_gamepad (self, raw_gamepad));
}

static void
foreach_gamepad_do (gpointer key,
                    gpointer value,
                    gpointer data)
{
  ForeachGamepadData *callback_data;
  GamesGamepad *gamepad;

  callback_data = (ForeachGamepadData *) data;
  gamepad = (GamesGamepad *) value;

  g_return_if_fail (gamepad != NULL);

  callback_data->callback (gamepad, callback_data->target);
}

static GamesGamepadMonitor *
games_gamepad_monitor_new (void)
{
  GamesGamepadMonitor *self = NULL;
  GamesRawGamepadMonitor *raw_gamepad_monitor;

  self = (GamesGamepadMonitor*) g_object_new (GAMES_TYPE_GAMEPAD_MONITOR, NULL);
  self->gamepads = g_hash_table_new_full (g_direct_hash, g_direct_equal, NULL, g_object_unref);

#if ENABLE_LINUX_GAMEPADS
  raw_gamepad_monitor = GAMES_RAW_GAMEPAD_MONITOR (games_linux_raw_gamepad_monitor_get_instance ());
  g_signal_connect_object (raw_gamepad_monitor,
                           "gamepad-plugged",
                           (GCallback) on_raw_gamepad_plugged,
                           self,
                           0);
  games_raw_gamepad_monitor_foreach_gamepad (raw_gamepad_monitor,
                                             add_raw_gamepad,
                                             self);
  g_object_unref (raw_gamepad_monitor);
#endif /* ENABLE_LINUX_GAMEPADS */

  return self;
}

/* Public */

GamesGamepadMonitor *games_gamepad_monitor_get_instance (void) {
  if (instance == NULL)
    instance = games_gamepad_monitor_new ();

  return g_object_ref (instance);
}

void
games_gamepad_monitor_foreach_gamepad (GamesGamepadMonitor  *self,
                                       GamesGamepadCallback  callback,
                                       gpointer              target)
{
  ForeachGamepadData data;

  g_return_if_fail (self != NULL);
  g_return_if_fail (callback != NULL);

  data.callback = callback;
  data.target = target;
  g_hash_table_foreach (self->gamepads, foreach_gamepad_do, &data);
}

/* Type */

static void
finalize (GObject *object)
{
  GamesGamepadMonitor *self = GAMES_GAMEPAD_MONITOR (object);

  g_hash_table_unref (self->gamepads);

  G_OBJECT_CLASS (games_gamepad_monitor_parent_class)->finalize (object);
}

static void games_gamepad_monitor_class_init (GamesGamepadMonitorClass *klass) {
  games_gamepad_monitor_parent_class = g_type_class_peek_parent (klass);
  G_OBJECT_CLASS (klass)->finalize = finalize;

  /**
   * GamesGamepad::unplugged:
   *
   * Emitted when the gamepad is unplugged.
   */
  signals[SIGNAL_GAMEPAD_PLUGGED] =
    g_signal_new ("gamepad-plugged",
                  GAMES_TYPE_GAMEPAD_MONITOR,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__OBJECT,
                  G_TYPE_NONE, 1,
                  GAMES_TYPE_GAMEPAD);

  /**
   * GamesGamepad::unplugged:
   *
   * Emitted when a gamepad is unplugged.
   */
  signals[SIGNAL_GAMEPAD_UNPLUGGED] =
    g_signal_new ("gamepad-unplugged",
                  GAMES_TYPE_GAMEPAD_MONITOR,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__VOID,
                  G_TYPE_NONE, 0);
}

static void
games_gamepad_monitor_init (GamesGamepadMonitor *self)
{
}
