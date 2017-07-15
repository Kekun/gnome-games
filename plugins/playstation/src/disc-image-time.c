// This file is part of GNOME Games. License: GPL-3.0+.

#include "disc-image-time.h"

/* Private */

#define GAMES_DISC_IMAGE_FRAMES_PER_SECOND 75

static void
games_disc_image_time_get_minute_second_frame (const GamesDiscImageTime *time,
                                               guint8                   *minute,
                                               guint8                   *second,
                                               guint8                   *frame)
{
  *minute = time->minute;
  *second = time->second;
  *frame = time->frame;
}

/* Public */

void
games_disc_image_time_set_minute_second_frame (GamesDiscImageTime *time,
                                               guint8              minute,
                                               guint8              second,
                                               guint8              frame)
{
  time->minute = minute;
  time->second = second;
  time->frame = frame;
}

void
games_disc_image_time_set_from_time_reference (GamesDiscImageTime *time,
                                               guint8             *time_reference)
{
  gint32 block; // The value of the clock containing the target time
  int minute, second, frame;

  block = GINT32_FROM_LE (*((gint32 *) time_reference));

  block += 2 * GAMES_DISC_IMAGE_FRAMES_PER_SECOND;
  minute = block / (60 * GAMES_DISC_IMAGE_FRAMES_PER_SECOND);
  block = block - minute * (60 * GAMES_DISC_IMAGE_FRAMES_PER_SECOND);
  second = block / GAMES_DISC_IMAGE_FRAMES_PER_SECOND;
  frame = block - second * GAMES_DISC_IMAGE_FRAMES_PER_SECOND;

  games_disc_image_time_set_minute_second_frame (time, minute, second, frame);
}

gint
games_disc_image_time_get_sector (const GamesDiscImageTime *time)
{
  guint8 minute, second, frame;
  games_disc_image_time_get_minute_second_frame (time, &minute, &second, &frame);

  return (minute * 60 + second - 2) * GAMES_DISC_IMAGE_FRAMES_PER_SECOND + frame;
}

void
games_disc_image_time_increment (GamesDiscImageTime *time)
{
  guint8 minute, second, frame;
  games_disc_image_time_get_minute_second_frame (time, &minute, &second, &frame);

  frame++;
  if (frame == GAMES_DISC_IMAGE_FRAMES_PER_SECOND) {
    frame = 0;
    second++;
    if (second == 60) {
      second = 0;
      minute++;
    }
  }

  games_disc_image_time_set_minute_second_frame (time, minute, second, frame);
}
