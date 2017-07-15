// This file is part of GNOME Games. License: GPL-3.0+.

#include "disc-file-info.h"

#include <string.h>
#include <stdio.h>
#include <gio/gio.h>

/* Private */

static gboolean
games_disc_file_info_is_valid (const GamesDiscFileInfo *file_info)
{
  // FIXME Magic number, I have no idea what it is but it works.
  const gsize MAGIC_SIZE = 47;

  g_return_val_if_fail (file_info != NULL, FALSE);

  return file_info->length >= MAGIC_SIZE + file_info->name_length;
}

static gchar *
games_disc_file_info_get_name (GamesDiscFileInfo *file_info)
{
  g_return_val_if_fail (file_info != NULL, NULL);

  return g_strndup (games_disc_file_info_access_name (file_info), file_info->name_length);
}

static GamesDiscFileInfo *
games_disc_file_info_get_next (const GamesDiscFileInfo *file_info)
{
  g_return_val_if_fail (file_info != NULL, NULL);

  if (!games_disc_file_info_is_valid (file_info))
    return NULL;

  return (GamesDiscFileInfo *) ((gpointer) file_info + file_info->length);
}

/* Public */

gboolean
games_disc_file_info_is_directory (GamesDiscFileInfo *file_info)
{
  g_return_val_if_fail (file_info != NULL, FALSE);

  return file_info->flags & 0x2;
}

gchar *
games_disc_file_info_access_name (GamesDiscFileInfo *file_info)
{
  g_return_val_if_fail (file_info != NULL, NULL);

  return (gchar *) file_info + sizeof (GamesDiscFileInfo);
}

void
games_disc_file_info_foreach_file (GamesDiscFileInfo                *file_info,
                                   gsize                             size,
                                   GamesDiscFileInfoForeachCallback  callback,
                                   gpointer                          user_data)
{
  GamesDiscFileInfo *current;
  GamesDiscFileInfo *next;

  g_return_if_fail (file_info != NULL);

  for (current = file_info; current != NULL && games_disc_file_info_is_valid (current); current = games_disc_file_info_get_next (current)) {
    // The file info should never go beyond the end of the buffer.
    if ((gpointer) current - (gpointer) file_info + sizeof (GamesDiscFileInfo) >= size ||
        (gpointer) current - (gpointer) file_info + current->length >= size)
      break;

    if (!callback (current, user_data))
      break;
  }
}
