// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef DISC_IMAGE_H
#define DISC_IMAGE_H

#include <gio/gio.h>
#include <glib.h>

#include "disc-file-info.h"
#include "disc-image-time.h"

G_BEGIN_DECLS

typedef struct _GamesDiscFrameMode1 GamesDiscFrameMode1;

struct _GamesDiscFrameMode1 {
  guint8 synchronization[12];
  guint8 header[12];
  guint8 content[2048];
  guint8 error_correction_code[280];
};

typedef struct _GamesDiscFrameMode2 GamesDiscFrameMode2;

struct _GamesDiscFrameMode2 {
  guint8 synchronization[12];
  guint8 content[2340];
};

typedef union _GamesDiscFrame GamesDiscFrame;

union _GamesDiscFrame {
  GamesDiscFrameMode1 mode1;
  GamesDiscFrameMode2 mode2;
};

typedef struct _GamesDiscImage GamesDiscImage;

struct _GamesDiscImage {
  GFileInputStream *input_stream;
};

void games_disc_image_open (GamesDiscImage  *disc,
                            const char      *filename,
                            GError         **error);
void games_disc_image_dispose (GamesDiscImage *disc);
gboolean games_disc_image_read_frame (GamesDiscImage            *disc,
                                      const GamesDiscImageTime  *time,
                                      GamesDiscFrame            *frame,
                                      GCancellable              *cancellable,
                                      GError                   **error);
gboolean games_disc_image_read_directory (GamesDiscImage      *disc,
                                          GamesDiscImageTime  *time,
                                          guint8              *dst,
                                          GCancellable        *cancellable,
                                          GError             **error);
gboolean games_disc_image_get_file (GamesDiscImage      *disc,
                                    GamesDiscFileInfo   *file_info,
                                    const gchar         *filename,
                                    GamesDiscImageTime  *time,
                                    GCancellable        *cancellable,
                                    GError             **error);

G_END_DECLS

#endif /* DISC_IMAGE_H */
