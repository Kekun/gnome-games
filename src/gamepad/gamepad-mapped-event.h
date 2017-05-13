// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_GAMEPAD_MAPPED_EVENT_H
#define GAMES_GAMEPAD_MAPPED_EVENT_H

#include <glib-object.h>

G_BEGIN_DECLS

#define GAMES_TYPE_GAMEPAD_MAPPED_EVENT (games_gamepad_mapped_event_get_type ())

typedef struct {
  guint16 type;
  guint16 axis;
  guint16 button;
} GamesGamepadMappedEvent;

GType games_gamepad_mapped_event_get_type (void) G_GNUC_CONST;
GamesGamepadMappedEvent *games_gamepad_mapped_event_dup (const GamesGamepadMappedEvent *self);
void games_gamepad_mapped_event_free (GamesGamepadMappedEvent *self);

G_END_DECLS

#endif /* GAMES_GAMEPAD_MAPPED_EVENT_H */
