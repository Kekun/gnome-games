// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_EVENT_H
#define GAMES_EVENT_H

#include <glib-object.h>

G_BEGIN_DECLS

#define GAMES_TYPE_EVENT (games_event_get_type())

typedef struct _GamesEventAny GamesEventAny;
typedef struct _GamesEventGamepad GamesEventGamepad;
typedef struct _GamesEventGamepadButton GamesEventGamepadButton;
typedef struct _GamesEventGamepadAxis GamesEventGamepadAxis;
typedef struct _GamesEventGamepadHat GamesEventGamepadHat;

typedef union  _GamesEvent GamesEvent;

typedef enum
{
  GAMES_EVENT_NOTHING = -1,
  GAMES_EVENT_GAMEPAD_BUTTON_PRESS = 0,
  GAMES_EVENT_GAMEPAD_BUTTON_RELEASE = 1,
  GAMES_EVENT_GAMEPAD_AXIS = 2,
  GAMES_EVENT_GAMEPAD_HAT = 3,
  GAMES_LAST_EVENT,
} GamesEventType;

struct _GamesEventAny {
  GamesEventType type;
  guint32 time;
};

struct _GamesEventGamepad {
  GamesEventType type;
  guint32 time;
  guint16 hardware_type;
  guint16 hardware_code;
  gint32 hardware_value;
  guint8 hardware_index;
};

struct _GamesEventGamepadButton {
  GamesEventType type;
  guint32 time;
  guint16 hardware_type;
  guint16 hardware_code;
  gint32 hardware_value;
  guint8 hardware_index;
  guint16 button;
};

struct _GamesEventGamepadAxis {
  GamesEventType type;
  guint32 time;
  guint16 hardware_type;
  guint16 hardware_code;
  gint32 hardware_value;
  guint8 hardware_index;
  guint16 axis;
  gdouble value;
};

struct _GamesEventGamepadHat {
  GamesEventType type;
  guint32 time;
  guint16 hardware_type;
  guint16 hardware_code;
  gint32 hardware_value;
  guint8 hardware_index;
  guint16 axis;
  gint8 value;
};

union _GamesEvent {
  GamesEventType type;
  GamesEventAny any;
  GamesEventGamepad gamepad;
  GamesEventGamepadButton gamepad_button;
  GamesEventGamepadAxis gamepad_axis;
  GamesEventGamepadHat gamepad_hat;
};

GType games_event_get_type (void) G_GNUC_CONST;

GamesEvent *games_event_new (void);
GamesEvent *games_event_copy (GamesEvent *self);
void games_event_free (GamesEvent *self);

G_DEFINE_AUTOPTR_CLEANUP_FUNC (GamesEvent, games_event_free)

G_END_DECLS

#endif /* GAMES_EVENT_H */
