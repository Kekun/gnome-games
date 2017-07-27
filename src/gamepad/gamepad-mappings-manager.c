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
  GHashTable *default_mappings;
  GHashTable *user_mappings;
  gchar *user_mappings_uri;
};

G_DEFINE_TYPE (GamesGamepadMappingsManager, games_gamepad_mappings_manager, G_TYPE_OBJECT);

static GamesGamepadMappingsManager *instance = NULL;

#define MAPPINGS_FILE_NAME "gamecontrollerdb.txt"
#define DEFAULT_MAPPINGS_URI "resource:///org/gnome/Games/gamepads/gamecontrollerdb.txt"

// FIXME The gamepad module shouldn't have a hidden dependency on the
// application.
gchar *games_application_get_config_dir (void);

/* Private */

static void
add_mapping (GamesGamepadMappingsManager *self,
             const gchar                 *mapping_string,
             GHashTable                  *mappings)
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
  g_hash_table_insert (mappings,
                       g_strdup (split[0]),
                       g_strdup (split[2]));
  g_strfreev (split);
}

static void
add_from_input_stream (GamesGamepadMappingsManager  *self,
                       GInputStream                 *input_stream,
                       GHashTable                   *mappings,
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

    add_mapping (self, mapping_string, mappings);
    g_free (mapping_string);
  }
  g_object_unref (data_stream);
}

static void
add_from_file_uri (GamesGamepadMappingsManager  *self,
                   const gchar                  *file_uri,
                   GHashTable                   *mappings,
                   GError                      **error)
{
  GFile *file;
  GFileInputStream *stream;
  GError *inner_error = NULL;

  g_return_if_fail (self != NULL);
  g_return_if_fail (file_uri != NULL);

  file = g_file_new_for_uri (file_uri);
  stream = g_file_read (file, NULL, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_propagate_error (error, inner_error);
    g_object_unref (file);

    return;
  }

  add_from_input_stream (self, G_INPUT_STREAM (stream), mappings, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_propagate_error (error, inner_error);
    g_object_unref (stream);
    g_object_unref (file);

    return;
  }

  g_object_unref (stream);
  g_object_unref (file);
}

static void
save_user_mappings (GamesGamepadMappingsManager  *self,
                    GError                      **error)
{
  GHashTableIter iter;
  gpointer key, value;
  gchar *guid;
  const gchar *name;
  gchar *sdl_string;
  gchar *mapping_string;

  GFile *file;
  GFileOutputStream *stream;
  GDataOutputStream *data_stream;
  GError *inner_error = NULL;

  g_return_if_fail (self != NULL);

  file = g_file_new_for_uri (self->user_mappings_uri);
  stream = g_file_replace (file, NULL, FALSE, G_FILE_CREATE_NONE, NULL, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_propagate_error (error, inner_error);
    g_object_unref (file);

    return;
  }
  data_stream = g_data_output_stream_new (G_FILE_OUTPUT_STREAM (stream));

  g_hash_table_iter_init (&iter, self->user_mappings);
  while (g_hash_table_iter_next (&iter, &key, &value)) {
    guid = (gchar *) key;
    name = g_hash_table_lookup (self->names, guid);
    sdl_string = (gchar *) value;

    mapping_string = g_strdup_printf ("%s,%s,%s\n", guid, name, sdl_string);

    g_data_output_stream_put_string (data_stream, mapping_string, NULL, &inner_error);
    if (G_UNLIKELY (inner_error != NULL)) {
      g_propagate_error (error, inner_error);
      g_free (mapping_string);
      g_object_unref (file);
      g_object_unref (stream);
      g_object_unref (data_stream);

      return;
    }

    g_free (mapping_string);
  }

  g_object_unref (file);
  g_object_unref (stream);
  g_object_unref (data_stream);
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

  if (self->default_mappings == NULL)
    self->default_mappings = g_hash_table_new_full (g_str_hash, g_str_equal, g_free, g_free);
  if (self->user_mappings == NULL)
    self->user_mappings = g_hash_table_new_full (g_str_hash, g_str_equal, g_free, g_free);

  add_from_file_uri (self, DEFAULT_MAPPINGS_URI, self->default_mappings, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_critical ("GamepadMappingsManager: Can’t add mappings from %s: %s"
                DEFAULT_MAPPINGS_URI,
                inner_error->message);
    g_clear_error (&inner_error);
  }

  // FIXME The gamepad module shouldn't have a hidden dependency on the
  // application.
  dir = games_application_get_config_dir ();
  path = g_build_filename (dir, MAPPINGS_FILE_NAME, NULL);

  g_free (dir);

  self->user_mappings_uri = g_filename_to_uri (path, NULL, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_debug ("GamepadMappingsManager: Can't build path for user config: %s",
             inner_error->message);
    g_free (path);
    g_clear_error (&inner_error);

    return self;
  }

  g_free (path);

  add_from_file_uri (self, self->user_mappings_uri, self->user_mappings, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_debug ("GamepadMappingsManager: Can’t add mappings from %s: %s",
             self->user_mappings_uri,
             inner_error->message);
    g_clear_error (&inner_error);
  }

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
games_gamepad_mappings_manager_get_default_mapping (GamesGamepadMappingsManager *self,
                                                    const gchar                 *guid)
{
  const gchar *mapping;

  g_return_val_if_fail (self != NULL, NULL);
  g_return_val_if_fail (guid != NULL, NULL);

  mapping = g_hash_table_lookup (self->default_mappings, guid);

  return g_strdup (mapping);
}

gchar *
games_gamepad_mappings_manager_get_user_mapping (GamesGamepadMappingsManager *self,
                                                 const gchar                 *guid)
{
  const gchar *mapping;

  g_return_val_if_fail (self != NULL, NULL);
  g_return_val_if_fail (guid != NULL, NULL);

  mapping = g_hash_table_lookup (self->user_mappings, guid);

  return g_strdup (mapping);
}

gchar *
games_gamepad_mappings_manager_get_mapping (GamesGamepadMappingsManager *self,
                                            const gchar                 *guid)
{
  gchar *mapping;

  g_return_val_if_fail (self != NULL, NULL);
  g_return_val_if_fail (guid != NULL, NULL);

  mapping = games_gamepad_mappings_manager_get_user_mapping (self, guid);
  if (mapping == NULL)
    mapping = games_gamepad_mappings_manager_get_default_mapping (self, guid);

  return mapping;
}

void
games_gamepad_mappings_manager_save_mapping (GamesGamepadMappingsManager *self,
                                             const gchar                 *guid,
                                             const gchar                 *name,
                                             const gchar                 *mapping)
{
  GError *inner_error = NULL;

  g_return_if_fail (self != NULL);
  g_return_if_fail (guid != NULL);
  g_return_if_fail (name != NULL);
  g_return_if_fail (mapping != NULL);

  g_hash_table_insert (self->user_mappings, g_strdup (guid), g_strdup (mapping));
  g_hash_table_insert (self->names, g_strdup (guid), g_strdup (name));

  save_user_mappings (self, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_critical ("GamepadMappingsManager: Can’t save user mappings: %s", inner_error->message);
    g_clear_error (&inner_error);
  }
}

void
games_gamepad_mappings_manager_delete_mapping (GamesGamepadMappingsManager *self,
                                               const gchar                 *guid)
{
  GError *inner_error = NULL;

  g_return_if_fail (self != NULL);
  g_return_if_fail (guid != NULL);

  g_hash_table_remove (self->user_mappings, guid);
  g_hash_table_remove (self->names, guid);

  save_user_mappings (self, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_critical ("GamepadMappingsManager: Can’t save user mappings: %s", inner_error->message);
    g_clear_error (&inner_error);
  }
}

/* Type */

static void
finalize (GObject *object)
{
  GamesGamepadMappingsManager *self = GAMES_GAMEPAD_MAPPINGS_MANAGER (object);

  g_hash_table_unref (self->names);
  g_hash_table_unref (self->default_mappings);
  g_hash_table_unref (self->user_mappings);
  g_free (self->user_mappings_uri);

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
