// This file is part of GNOME Games. License: GPL-3.0+.

#include "linux-raw-gamepad-monitor.h"

#include <gudev/gudev.h>
#include "linux-raw-gamepad.h"
#include "../raw-gamepad-monitor.h"

struct _GamesLinuxRawGamepadMonitor {
  GObject parent_instance;

  GUdevClient *client;
  GHashTable *raw_gamepads;
};

static void games_raw_gamepad_monitor_interface_init (GamesRawGamepadMonitorInterface *interface);

G_DEFINE_TYPE_WITH_CODE (GamesLinuxRawGamepadMonitor, games_linux_raw_gamepad_monitor, G_TYPE_OBJECT,
                         G_IMPLEMENT_INTERFACE (GAMES_TYPE_RAW_GAMEPAD_MONITOR,
                                                games_raw_gamepad_monitor_interface_init))

typedef struct {
  GamesRawGamepadCallback callback;
  gpointer target;
} ForeachGamepadData;

/* Private */

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

static GamesRawGamepad *
add_gamepad (GamesLinuxRawGamepadMonitor *self,
             GUdevDevice                 *device)
{
  gchar *identifier;
  GamesLinuxRawGamepad *raw_gamepad;
  GError *error = NULL;

  g_return_val_if_fail (self != NULL, NULL);
  g_return_val_if_fail (device != NULL, NULL);

  identifier = g_strdup (g_udev_device_get_device_file (device));
  if (g_hash_table_contains (self->raw_gamepads, identifier)) {
    g_free (identifier);

    return NULL;
  }

  raw_gamepad = games_linux_raw_gamepad_new (identifier, &error);
  if (G_UNLIKELY (error != NULL)) {
    g_free (identifier);
    g_assert (raw_gamepad == NULL);
    g_debug ("%s", error->message);
    g_error_free (error);

    return NULL;
  }

  g_assert (raw_gamepad != NULL);

  g_hash_table_insert (self->raw_gamepads,
                       identifier,
                       g_object_ref (raw_gamepad));

  return GAMES_RAW_GAMEPAD (raw_gamepad);
}

static GamesRawGamepad *
remove_gamepad (GamesLinuxRawGamepadMonitor *self,
                GUdevDevice                 *device)
{
  const gchar *identifier;
  GamesRawGamepad *raw_gamepad;

  g_return_val_if_fail (self != NULL, NULL);
  g_return_val_if_fail (device != NULL, NULL);

  identifier = g_udev_device_get_device_file (device);
  if (!g_hash_table_contains (self->raw_gamepads, identifier))
    return NULL;

  raw_gamepad = g_object_ref (GAMES_RAW_GAMEPAD (g_hash_table_lookup (self->raw_gamepads, identifier)));
  g_hash_table_remove (self->raw_gamepads, identifier);

  return raw_gamepad;
}

static gboolean
device_property_is (GUdevDevice *device,
                    const gchar *property,
                    const gchar *value)
{
  return g_udev_device_has_property (device, property) &&
         (g_strcmp0 (g_udev_device_get_property (device, property), value) == 0);
}

static gboolean
is_gamepad (GUdevDevice *device)
{
  g_return_val_if_fail (device != NULL, FALSE);

  return device_property_is (device, "ID_INPUT_JOYSTICK", "1") ||
         device_property_is (device, ".INPUT_CLASS", "joystick");
}

static void
handle_udev_client_callback (GUdevClient *sender,
                             const gchar *action,
                             GUdevDevice *device,
                             gpointer     data)
{
  GamesLinuxRawGamepadMonitor *self;

  self = GAMES_LINUX_RAW_GAMEPAD_MONITOR (data);

  g_return_if_fail (self != NULL);
  g_return_if_fail (action != NULL);
  g_return_if_fail (device != NULL);

  if (g_udev_device_get_device_file (device) == NULL)
    return;

  if (!is_gamepad (device))
    return;

  if (g_strcmp0 (action, "add") == 0) {
    GamesRawGamepad *raw_gamepad;

    raw_gamepad = add_gamepad (self, device);
    if (raw_gamepad != NULL) {
      g_signal_emit_by_name (GAMES_RAW_GAMEPAD_MONITOR (self), "gamepad-plugged", raw_gamepad);
      g_object_unref (raw_gamepad);
    }
  }
  else if (g_strcmp0 (action, "remove") == 0) {
    GamesRawGamepad *raw_gamepad;

    raw_gamepad = remove_gamepad (self, device);
    if (raw_gamepad != NULL) {
      g_signal_emit_by_name (raw_gamepad, "unplugged");
      g_object_unref (raw_gamepad);
    }
  }
}

static GamesLinuxRawGamepadMonitor *
games_linux_raw_gamepad_monitor_new (void)
{
  static const gchar *subsystems[] = { "input" };
  GamesLinuxRawGamepadMonitor *self = NULL;
  GList *initial_devices_list;
  GList *device_it = NULL;
  GUdevDevice *device = NULL;
  GamesRawGamepad *gamepad;

  self = g_object_new (GAMES_TYPE_LINUX_RAW_GAMEPAD_MONITOR, NULL);
  self->client = g_udev_client_new (subsystems);
  g_signal_connect_object (self->client,
                           "uevent",
                           (GCallback) handle_udev_client_callback,
                           self,
                           0);
  self->raw_gamepads = g_hash_table_new_full (g_str_hash,
                                              g_str_equal,
                                              g_free,
                                              g_object_unref);
  initial_devices_list = g_udev_client_query_by_subsystem (self->client,
                                                           "input");

  for (device_it = initial_devices_list;
       device_it != NULL;
       device_it = device_it->next) {
    device = G_UDEV_DEVICE (device_it->data);
    if (g_udev_device_get_device_file (device) == NULL)
      continue;

    if (!is_gamepad (device))
      continue;

    gamepad = add_gamepad (self, device);
    if (gamepad != NULL)
      g_object_unref (gamepad);
  }

  g_list_free_full (initial_devices_list, g_object_unref);

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

  if (self->client != NULL)
    g_object_unref (self->client);
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
