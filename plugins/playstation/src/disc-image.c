// This file is part of GNOME Games. License: GPL-3.0+.

#include "disc-image.h"

#include <string.h>
#include "disc-file-info.h"
#include "disc-image-time.h"

/* Private */

#define GAMES_DISC_IMAGE_ERROR games_disc_image_error_quark ()

#define GAMES_DISC_IMAGE_FRAME_SIZE           2352
#define GAMES_DISC_IMAGE_FRAME_HEADER_SIZE    12

enum GamesDiscImageError {
  GAMES_DISC_IMAGE_ERROR_INVALID_SECTOR,
};

typedef struct {
  const gchar        *filename;
  GamesDiscImageTime *time;
  gboolean            is_dir;
  gboolean            found;
} GetFileData;

static gboolean
get_file_co (GamesDiscFileInfo *file_info,
             gpointer           user_data)
{
  GetFileData *data = (GetFileData *) user_data;

  if (games_disc_file_info_is_directory (file_info)) {
    if (g_ascii_strncasecmp (games_disc_file_info_access_name (file_info), data->filename, file_info->name_length) == 0) {
      if (data->filename[file_info->name_length] != '\\')
        return TRUE;

      data->filename += file_info->name_length + 1;

      games_disc_image_time_set_from_time_reference (data->time, file_info->extent);
      data->is_dir = TRUE;
      data->found = TRUE;

      return FALSE;
    }
  }
  else {
    if (g_ascii_strncasecmp (games_disc_file_info_access_name (file_info), data->filename, strlen (data->filename)) == 0) {
      games_disc_image_time_set_from_time_reference (data->time, file_info->extent);
      data->is_dir = FALSE;
      data->found = TRUE;

      return FALSE;
    }
  }

  return TRUE;
}

static GQuark
games_disc_image_error_quark (void)
{
  return g_quark_from_static_string ("games-disc-image-error-quark");
}

/* Public */

void
games_disc_image_open (GamesDiscImage  *disc,
                       const char      *filename,
                       GError         **error)
{
  GFile *file;
  GError *tmp_error = NULL;

  file = g_file_new_for_path (filename);
  g_clear_object (&disc->input_stream);
  disc->input_stream = g_file_read (file, NULL, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);
    g_object_unref(file);

    return;
  }

  g_object_unref(file);
}

void
games_disc_image_dispose (GamesDiscImage *disc)
{
  g_clear_object (&disc->input_stream);
}

gboolean
games_disc_image_read_frame (GamesDiscImage            *disc,
                             const GamesDiscImageTime  *time,
                             GamesDiscFrame            *frame,
                             GCancellable              *cancellable,
                             GError                   **error)
{
  gssize read;
  gint sector;
  gsize offset;
  GError *tmp_error = NULL;

  g_return_val_if_fail (disc != NULL, FALSE);
  g_return_val_if_fail (time != NULL, FALSE);
  g_return_val_if_fail (frame != NULL, FALSE);

  sector = games_disc_image_time_get_sector (time);
  if (sector < 0) {
    g_set_error (error,
                 GAMES_DISC_IMAGE_ERROR,
                 GAMES_DISC_IMAGE_ERROR_INVALID_SECTOR,
                 "The sector index %d is inferior to 0 and hence is invalid.",
                 sector);

    return FALSE;
  }

  if (!g_size_checked_mul (&offset, sector, sizeof (GamesDiscFrame))) {
    g_set_error (error,
                 GAMES_DISC_IMAGE_ERROR,
                 GAMES_DISC_IMAGE_ERROR_INVALID_SECTOR,
                 "The sector index %d is too big to be usable and hence is invalid.",
                 sector);

    return FALSE;
  }

  g_seekable_seek (G_SEEKABLE (disc->input_stream),
                   offset, G_SEEK_SET,
                   cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  read = g_input_stream_read (G_INPUT_STREAM (disc->input_stream),
                              frame, sizeof (GamesDiscFrame),
                              cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  return read == sizeof (GamesDiscFrame);
}

gboolean
games_disc_image_read_directory (GamesDiscImage      *disc,
                                 GamesDiscImageTime  *time,
                                 guint8              *dst,
                                 GCancellable        *cancellable,
                                 GError             **error)
{
  gssize read;
  gint sector;
  GError *tmp_error = NULL;

  sector = games_disc_image_time_get_sector(time);
  g_seekable_seek (G_SEEKABLE (disc->input_stream),
                   sector * GAMES_DISC_IMAGE_FRAME_SIZE + GAMES_DISC_IMAGE_FRAME_HEADER_SIZE + 12,
                   G_SEEK_SET, cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  read = g_input_stream_read (G_INPUT_STREAM (disc->input_stream),
                              dst, 2048,
                              cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  if (read == -1)
    return FALSE;

  games_disc_image_time_increment (time);

  sector = games_disc_image_time_get_sector(time);
  g_seekable_seek (G_SEEKABLE (disc->input_stream),
                   sector * GAMES_DISC_IMAGE_FRAME_SIZE + GAMES_DISC_IMAGE_FRAME_HEADER_SIZE + 12,
                   G_SEEK_SET, cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  read = g_input_stream_read (G_INPUT_STREAM (disc->input_stream),
                              dst + 2048, 2048,
                              cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  if (read == -1)
    return FALSE;

  return TRUE;
}

gboolean
games_disc_image_get_file (GamesDiscImage      *disc,
                           GamesDiscFileInfo   *file_info,
                           const gchar         *filename,
                           GamesDiscImageTime  *time,
                           GCancellable        *cancellable,
                           GError             **error)
{
  guint8 ddir[4096];
  GetFileData data = { 0 };
  gboolean success;
  GError *tmp_error = NULL;

  g_return_val_if_fail (filename != NULL, FALSE);

  data.filename = filename;
  data.time = time;
  data.is_dir = TRUE;
  data.found = FALSE;

  while (data.is_dir) {
    data.filename = filename;
    data.time = time;
    data.is_dir = FALSE;
    data.found = FALSE;

    games_disc_file_info_foreach_file (file_info, 4096, get_file_co, &data);

    if (data.found && data.is_dir) {
      success = games_disc_image_read_directory (disc, time, ddir, cancellable, &tmp_error);
      if (tmp_error != NULL) {
        g_propagate_error (error, tmp_error);

        return FALSE;
      }

      if (!success)
        return FALSE;

      file_info = (GamesDiscFileInfo *) ddir;

      break; // Parse the sub directory.
    }
  }

  return data.found;
}
