// This file is part of GNOME Games. License: GPL-3.0+.

#include <string.h>
#include <stdio.h>
#include "disc-image.h"

#define SYSTEM_CNF "SYSTEM.CNF;1"
#define PSX_EXE "PSX.EXE;1"

typedef struct _PlayStationGamesDiscInfo {
  gchar *label;
  gchar *exe;
} PlayStationGamesDiscInfo;

static gboolean
games_disc_image_get_playstation_info (GamesDiscImage            *disc,
                                       PlayStationGamesDiscInfo  *games_disc_image_info,
                                       GCancellable              *cancellable,
                                       GError                   **error)
{
  gchar label_buffer[33] = "";

  GamesDiscFileInfo *dir;
  GamesDiscImageTime time;
  guchar mdir[4096];
  gchar exe_buffer[256];
  gint i, len, c;
  gchar *ptr;
  GamesDiscFrame frame;
  gboolean success;
  GError *tmp_error = NULL;

  games_disc_image_time_set_minute_second_frame (&time, 0, 2, 0x10);
  success = games_disc_image_read_frame (disc, &time, &frame, cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  if (!success)
    return FALSE;

  memset (label_buffer, 0, sizeof (label_buffer));
  memset (exe_buffer, 0, sizeof (exe_buffer));

  strncpy (label_buffer, (const char *) frame.mode2.content + 52, 32);

  // Skip head and sub, and go to the root directory record
  dir = (GamesDiscFileInfo *) (frame.mode1.content + 156);

  games_disc_image_time_set_from_time_reference (&time, dir->extent);

  success = games_disc_image_read_directory (disc, &time, mdir, cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  if (!success)
    return FALSE;

  // Look for ststem configuration.

  success = games_disc_image_get_file (disc, (GamesDiscFileInfo *) mdir, SYSTEM_CNF, &time, cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  if (success) {
    if (!games_disc_image_read_frame (disc, &time, &frame, cancellable, &tmp_error))
      return FALSE;

    if (tmp_error != NULL) {
      g_propagate_error (error, tmp_error);

      return FALSE;
    }

    // Look of "BOOT = cdrom:\\"

    sscanf ((char *) frame.mode1.content, "BOOT = cdrom:\\%255s", exe_buffer);
    success = games_disc_image_get_file (disc, (GamesDiscFileInfo *) mdir, exe_buffer, &time, cancellable, &tmp_error);
    if (tmp_error != NULL) {
      g_propagate_error (error, tmp_error);

      return FALSE;
    }

    if (success) {
      if (games_disc_image_info != NULL) {
        games_disc_image_info->label = strndup (label_buffer, sizeof (label_buffer));
        games_disc_image_info->exe = strndup (exe_buffer, sizeof (exe_buffer));
      }

      return TRUE;
    }

    // Look of "BOOT = cdrom:"

    sscanf ((char *) frame.mode1.content, "BOOT = cdrom:%255s", exe_buffer);
    success = games_disc_image_get_file (disc, (GamesDiscFileInfo *) mdir, exe_buffer, &time, cancellable, &tmp_error);
    if (tmp_error != NULL) {
      g_propagate_error (error, tmp_error);

      return FALSE;
    }

    if (success) {
      if (games_disc_image_info != NULL) {
        games_disc_image_info->label = strndup (label_buffer, sizeof (label_buffer));
        games_disc_image_info->exe = strndup (exe_buffer, sizeof (exe_buffer));
      }

      return TRUE;
    }

    // Look of "cdrom:"

    ptr = strstr((gchar *) frame.mode1.content, "cdrom:"); // Possibly the executable is in some subdir.
    if (ptr == NULL)
      return FALSE;

    // Skip "cdrom:".
    ptr += 6;

    // Skip slashes.
    while (*ptr == '\\' || *ptr == '/')
      ptr++;

    strncpy (exe_buffer, ptr, 255);
    exe_buffer[255] = '\0';
    ptr = exe_buffer;

    // Keep only the first line.
    while (*ptr != '\0' && *ptr != '\r' && *ptr != '\n')
      ptr++;
    *ptr = '\0';

    success = games_disc_image_get_file (disc, (GamesDiscFileInfo *) mdir, exe_buffer, &time, cancellable, &tmp_error);
    if (tmp_error != NULL) {
      g_propagate_error (error, tmp_error);

      return FALSE;
    }

    if (success) {
      if (games_disc_image_info != NULL) {
        games_disc_image_info->label = strndup (label_buffer, sizeof (label_buffer));
        games_disc_image_info->exe = strndup (exe_buffer, sizeof (exe_buffer));
      }

      return TRUE;
    }

    return FALSE;
  }

  // Look for the default executable.

  success = games_disc_image_get_file (disc, (GamesDiscFileInfo *) mdir, PSX_EXE, &time, cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_propagate_error (error, tmp_error);

    return FALSE;
  }

  if (success) {
    if (games_disc_image_info != NULL) {
      games_disc_image_info->label = strndup (label_buffer, sizeof (label_buffer));
      games_disc_image_info->exe = strndup (PSX_EXE, sizeof (PSX_EXE));
    }

    return TRUE;
  }

  // SYSTEM.CNF and PSX.EXE not found.

  return FALSE;
}

gboolean
get_playstation_info (const gchar   *image_filename,
                      gchar        **label,
                      gchar        **exe,
                      GCancellable  *cancellable,
                      GError       **error)
{
  GamesDiscImage disc = { 0 };
  gboolean success;
  GError *tmp_error = NULL;

  games_disc_image_open (&disc, image_filename, &tmp_error);
  if (tmp_error != NULL) {
    g_debug ("%s", tmp_error->message);
    g_error_free (tmp_error);
    games_disc_image_dispose (&disc);

    return FALSE;
  }

  PlayStationGamesDiscInfo games_disc_image_info = { 0 };
  success = games_disc_image_get_playstation_info (&disc, &games_disc_image_info, cancellable, &tmp_error);
  if (tmp_error != NULL) {
    g_debug ("%s", tmp_error->message);
    g_error_free (tmp_error);
    games_disc_image_dispose (&disc);

    return FALSE;
  }

  games_disc_image_dispose (&disc);

  if (success) {
    *label = games_disc_image_info.label;
    *exe = games_disc_image_info.exe;

    return TRUE;
  }

  return FALSE;
}
