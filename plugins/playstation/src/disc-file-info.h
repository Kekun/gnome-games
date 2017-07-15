// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef DISC_FILE_INFO_H
#define DISC_FILE_INFO_H

#include <glib.h>

G_BEGIN_DECLS

typedef struct _GamesDiscFileInfo GamesDiscFileInfo;

struct _GamesDiscFileInfo {
  guint8 length;
  guint8 ext_attr_length;
  guint8 extent[8];
  guint8 size[8];
  guint8 date[7];
  guint8 flags;
  guint8 file_unit_size;
  guint8 interleave;
  guint8 volume_sequence_number[4];
  guint8 name_length;
};

typedef gboolean (*GamesDiscFileInfoForeachCallback) (GamesDiscFileInfo *file_info, gpointer user_data);

gboolean games_disc_file_info_is_directory (GamesDiscFileInfo *file_info);
gchar *games_disc_file_info_access_name (GamesDiscFileInfo *file_info);
void games_disc_file_info_foreach_file (GamesDiscFileInfo                *file_info,
                                        gsize                             size,
                                        GamesDiscFileInfoForeachCallback  callback,
                                        gpointer                          user_data);

G_END_DECLS

#endif /* DISC_FILE_INFO_H */
