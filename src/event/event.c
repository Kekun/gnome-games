// This file is part of GNOME Games. License: GPL-3.0+.

#include "event.h"

#include <string.h>

G_DEFINE_BOXED_TYPE (GamesEvent, games_event, games_event_copy, games_event_free)

GamesEvent *
games_event_new (void)
{
  GamesEvent *self;

  self = g_slice_new0 (GamesEvent);

  return self;
}

GamesEvent *
games_event_copy (GamesEvent *self)
{
  GamesEvent *copy;

  g_return_val_if_fail (self, NULL);

  copy = games_event_new ();

  memcpy(copy, self, sizeof (GamesEvent));

  return copy;
}

void
games_event_free (GamesEvent *self)
{
  g_return_if_fail (self);

  g_slice_free (GamesEvent, self);
}
