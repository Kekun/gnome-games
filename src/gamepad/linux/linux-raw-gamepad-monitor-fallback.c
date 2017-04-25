// This file is part of GNOME Games. License: GPL-3.0+.

#include "linux-raw-gamepad-monitor.h"

#include "linux-raw-gamepad.h"
#include "../raw-gamepad-monitor.h"

struct _GamesLinuxRawGamepadMonitor {
  GObject parent_instance;

  GHashTable *raw_gamepads;
};

static void games_raw_gamepad_monitor_interface_init (GamesRawGamepadMonitorInterface *interface);

G_DEFINE_TYPE_WITH_CODE (GamesLinuxRawGamepadMonitor, games_linux_raw_gamepad_monitor, G_TYPE_OBJECT,
                         G_IMPLEMENT_INTERFACE (GAMES_TYPE_RAW_GAMEPAD_MONITOR,
                                                games_raw_gamepad_monitor_interface_init))

/* Private */

typedef struct {
  GamesRawGamepadCallback callback;
  gpointer target;
} ForeachGamepadData;

static void
foreach_gamepad_do (gpointer key,
                    gpointer value,
                    gpointer data)
{
  ForeachGamepadData *callback_data;
  GamesRawGamepad *raw_gamepad;

  callback_data = (ForeachGamepadData *) data;
  raw_gamepad = (GamesRawGamepad *) value;

  g_return_if_fail (raw_gamepad != NULL);

  callback_data->callback (raw_gamepad, callback_data->target);
}

static void
foreach_gamepad (GamesRawGamepadMonitor  *base,
                 GamesRawGamepadCallback  callback,
                 gpointer                 target)
{
  GamesLinuxRawGamepadMonitor *self;
  ForeachGamepadData data;

  self = GAMES_LINUX_RAW_GAMEPAD_MONITOR (base);

  g_return_if_fail (base != NULL);
  g_return_if_fail (callback != NULL);

  data.callback = callback;
  data.target = target;
  g_hash_table_foreach (self->raw_gamepads, foreach_gamepad_do, &data);
}

static GamesLinuxRawGamepadMonitor *
games_linux_raw_gamepad_monitor_new (void)
{
  GamesLinuxRawGamepadMonitor *self = NULL;
  GError *error = NULL;
  static const gchar *directory = "/dev/input";
  GDir *dir;
  const gchar *name = NULL;
  gchar *path;
  GamesLinuxRawGamepad *raw_gamepad = NULL;


  self = (GamesLinuxRawGamepadMonitor *) g_object_new (GAMES_TYPE_LINUX_RAW_GAMEPAD_MONITOR, NULL);
  self->raw_gamepads = g_hash_table_new_full (g_str_hash, g_str_equal, g_free, g_object_unref);

  // Coldplug gamepads
  dir = g_dir_open (directory, (guint) 0, &error);
  if (G_UNLIKELY (error != NULL)) {
    g_debug ("%s", error->message);
    g_error_free (error);

    return self;
  }

  while ((name = g_dir_read_name (dir)) != NULL) {
    path = g_build_filename (directory, name, NULL);
    raw_gamepad = games_linux_raw_gamepad_new (path, &error);
    if (G_UNLIKELY (error != NULL)) {
      if (!g_error_matches (error, G_FILE_ERROR, G_FILE_ERROR_NXIO))
        g_debug ("Failed to open gamepad %s: %s", path, error->message);

      g_error_free (error);
      g_free (path);
      error = NULL;

      continue;
    }

    g_free (path);

    g_assert (raw_gamepad != NULL);

    g_hash_table_insert (self->raw_gamepads, g_strdup (name), raw_gamepad);
    g_signal_emit_by_name (self, "gamepad-plugged", raw_gamepad);
  }

  g_dir_close (dir);

  return self;
}

/* Public */

GamesLinuxRawGamepadMonitor *
games_linux_raw_gamepad_monitor_get_instance (void)
{
  static GamesLinuxRawGamepadMonitor *instance = NULL;

  if (instance == NULL)
    instance = games_linux_raw_gamepad_monitor_new ();

  return g_object_ref (instance);
}

/* Type */

static void
games_linux_raw_gamepad_monitor_finalize (GObject *object)
{
  GamesLinuxRawGamepadMonitor *self = GAMES_LINUX_RAW_GAMEPAD_MONITOR (object);

  if (self->raw_gamepads != NULL)
    g_hash_table_unref (self->raw_gamepads);

  G_OBJECT_CLASS (games_linux_raw_gamepad_monitor_parent_class)->finalize (object);
}

static void
games_linux_raw_gamepad_monitor_class_init (GamesLinuxRawGamepadMonitorClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);

  object_class->finalize = games_linux_raw_gamepad_monitor_finalize;
}

static void
games_raw_gamepad_monitor_interface_init (GamesRawGamepadMonitorInterface *interface)
{
  interface->foreach_gamepad = foreach_gamepad;
}

static void
games_linux_raw_gamepad_monitor_init (GamesLinuxRawGamepadMonitor *self)
{
}
