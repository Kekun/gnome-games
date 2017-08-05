// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-mappings-manager.h"

#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>
#include <gio/gio.h>

struct _GamesGamepadMappingsManager {
  GObject parent_instance;

  GHashTable *names;
  GHashTable *mappings;
};

G_DEFINE_TYPE (GamesGamepadMappingsManager, games_gamepad_mappings_manager, G_TYPE_OBJECT);

static GamesGamepadMappingsManager *instance = NULL;

#define MAPPINGS_FILE_NAME "gamecontrollerdb.txt"

// FIXME The gamepad module shouldn't have a hidden dependency on the
// application.
gchar *games_application_get_config_dir (void);

/* Private */

static void
add_mapping (GamesGamepadMappingsManager *self,
             const gchar                 *mapping_string)
{
  const gchar *platform;
  gchar **split;

  g_return_if_fail (self != NULL);
  g_return_if_fail (mapping_string != NULL);

  if (mapping_string[0] == '\0' || mapping_string[0] == '#')
    return;

  platform = g_strstr_len (mapping_string, -1, "platform");
  if (platform != NULL && !g_str_has_prefix (platform, "platform:Linux"))
    return;

  split = g_strsplit (mapping_string, ",", 3);
  g_hash_table_insert (self->names,
                       g_strdup (split[0]),
                       g_strdup (split[1]));
  g_hash_table_insert (self->mappings,
                       g_strdup (split[0]),
                       g_strdup (split[2]));
  g_strfreev (split);
}

static void
add_from_input_stream (GamesGamepadMappingsManager  *self,
                       GInputStream                 *input_stream,
                       GError                      **error)
{
  GDataInputStream *data_stream;
  gchar *mapping_string;
  GError *inner_error = NULL;

  g_return_if_fail (self != NULL);
  g_return_if_fail (input_stream != NULL);

  data_stream = g_data_input_stream_new (input_stream);
  while (TRUE) {
    mapping_string = g_data_input_stream_read_line (data_stream,
                                                    NULL, NULL,
                                                    &inner_error);
    if (G_UNLIKELY (inner_error != NULL)) {
      g_assert (mapping_string == NULL);
      g_propagate_error (error, inner_error);
      g_object_unref (data_stream);

      return;
    }

    if (mapping_string == NULL)
      break;

    add_mapping (self, mapping_string);
    g_free (mapping_string);
  }
  g_object_unref (data_stream);
}

static void
add_from_resource (GamesGamepadMappingsManager  *self,
                   const gchar                  *path,
                   GError                      **error)
{
  GInputStream *stream;
  GError *inner_error = NULL;

  g_return_if_fail (self != NULL);
  g_return_if_fail (path != NULL);

  stream = g_resources_open_stream (path,
                                    G_RESOURCE_LOOKUP_FLAGS_NONE,
                                    &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_propagate_error (error, inner_error);

    return;
  }

  add_from_input_stream (self, G_INPUT_STREAM (stream), &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_propagate_error (error, inner_error);
    g_object_unref (stream);

    return;
  }

  g_object_unref (stream);
}

static void
add_from_file (GamesGamepadMappingsManager  *self,
               const gchar                  *file_name,
               GError                      **error)
{
  GFile *file;
  GFileInputStream *stream;
  GError *inner_error = NULL;

  g_return_if_fail (self != NULL);
  g_return_if_fail (file_name != NULL);

  file = g_file_new_for_path (file_name);
  stream = g_file_read (file, NULL, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_propagate_error (error, inner_error);
    g_object_unref (file);

    return;
  }

  add_from_input_stream (self, G_INPUT_STREAM (stream), &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_propagate_error (error, inner_error);
    g_object_unref (stream);
    g_object_unref (file);

    return;
  }

  g_object_unref (stream);
  g_object_unref (file);
}

static GamesGamepadMappingsManager *
games_gamepad_mappings_manager_new (void)
{
  GamesGamepadMappingsManager *self = NULL;
  gchar *dir;
  gchar *path;
  GError *inner_error = NULL;

  self = (GamesGamepadMappingsManager*) g_object_new (GAMES_TYPE_GAMEPAD_MAPPINGS_MANAGER, NULL);

  if (self->names == NULL)
    self->names = g_hash_table_new_full (g_str_hash, g_str_equal, g_free, g_free);

  if (self->mappings == NULL)
    self->mappings = g_hash_table_new_full (g_str_hash, g_str_equal, g_free, g_free);

  add_from_resource (self,
                     "/org/gnome/Games/gamepads/gamecontrollerdb.txt",
                     &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_warning ("GamepadMappingsManager: Can’t find resource gamecontrollerdb.txt: %s",
               inner_error->message);
    g_clear_error (&inner_error);
  }

  // FIXME The gamepad module shouldn't have a hidden dependency on the
  // application.
  dir = games_application_get_config_dir ();
  path = g_build_filename (dir, MAPPINGS_FILE_NAME, NULL);

  g_free (dir);

  if (!g_file_test (path, G_FILE_TEST_EXISTS)) {
    g_free (path);

    return self;
  }

  add_from_file (self, path, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_warning ("GamepadMappingsManager: Can’t add from user’s config dir’s %s: %s",
               MAPPINGS_FILE_NAME,
               inner_error->message);
    g_clear_error (&inner_error);
  }

  g_free (path);

  return self;
}

/* Public */

GamesGamepadMappingsManager *
games_gamepad_mappings_manager_get_instance (void)
{
  if (instance == NULL)
    instance = games_gamepad_mappings_manager_new ();

  return g_object_ref (instance);
}

gchar *
games_gamepad_mappings_manager_get_mapping (GamesGamepadMappingsManager *self,
                                            const gchar                 *guid)
{
  const gchar *mapping;

  g_return_val_if_fail (self != NULL, NULL);
  g_return_val_if_fail (guid != NULL, NULL);

  mapping = g_hash_table_lookup (self->mappings, guid);

  return g_strdup (mapping);
}

/* Type */

static void
finalize (GObject *object)
{
  GamesGamepadMappingsManager *self = GAMES_GAMEPAD_MAPPINGS_MANAGER (object);

  g_hash_table_unref (self->names);
  g_hash_table_unref (self->mappings);

  G_OBJECT_CLASS (games_gamepad_mappings_manager_parent_class)->finalize (object);
}

static void
games_gamepad_mappings_manager_class_init (GamesGamepadMappingsManagerClass *klass)
{
  games_gamepad_mappings_manager_parent_class = g_type_class_peek_parent (klass);
  G_OBJECT_CLASS (klass)->finalize = finalize;
}

static void
games_gamepad_mappings_manager_init (GamesGamepadMappingsManager *self)
{
}
