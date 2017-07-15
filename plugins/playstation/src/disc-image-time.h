// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef DISC_IMAGE_TIME_H
#define DISC_IMAGE_TIME_H

#include <glib.h>

G_BEGIN_DECLS

typedef struct _GamesDiscImageTime GamesDiscImageTime;

struct _GamesDiscImageTime {
  guint8 minute;
  guint8 second;
  guint8 frame;
};

void games_disc_image_time_set_minute_second_frame (GamesDiscImageTime *time,
                                                    guint8              minute,
                                                    guint8              second,
                                                    guint8              frame);
void
games_disc_image_time_set_from_time_reference (GamesDiscImageTime *time,
                                               guint8             *time_reference);
gint games_disc_image_time_get_sector (const GamesDiscImageTime *time);
void games_disc_image_time_increment (GamesDiscImageTime *time);

G_END_DECLS

#endif /* DISC_IMAGE_TIME_H */
