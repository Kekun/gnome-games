// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad.h"

#include <linux/input-event-codes.h>
#include <stdlib.h>
#include "../event/event.h"

struct _GamesGamepad {
  GObject parent_instance;

  GamesRawGamepad *raw_gamepad;
  GamesGamepadMapping *mapping;
};

G_DEFINE_TYPE (GamesGamepad, games_gamepad, G_TYPE_OBJECT)

enum {
  SIGNAL_EVENT,
  SIGNAL_BUTTON_PRESS_EVENT,
  SIGNAL_BUTTON_RELEASE_EVENT,
  SIGNAL_AXIS_EVENT,
  SIGNAL_HAT_EVENT,
  SIGNAL_UNPLUGGED,
  LAST_SIGNAL,
};

static guint signals[LAST_SIGNAL] = { 0 };

/* Private */

static void
forward_event (GamesGamepad *self,
               GamesEvent   *event)
{
  switch (event->type) {
  case GAMES_EVENT_GAMEPAD_BUTTON_PRESS:
    g_signal_emit (self, signals[SIGNAL_BUTTON_PRESS_EVENT], 0, event);

    return;
  case GAMES_EVENT_GAMEPAD_BUTTON_RELEASE:
    g_signal_emit (self, signals[SIGNAL_BUTTON_RELEASE_EVENT], 0, event);

    return;
  case GAMES_EVENT_GAMEPAD_AXIS:
    g_signal_emit (self, signals[SIGNAL_AXIS_EVENT], 0, event);

    return;
  case GAMES_EVENT_GAMEPAD_HAT:
    g_signal_emit (self, signals[SIGNAL_HAT_EVENT], 0, event);

    return;
  default:
    return;
  }
}

static void
map_button_event (GamesGamepad            *self,
                  GamesEventGamepadButton *games_event)
{
  GamesGamepadInput destination;
  GamesEvent *mapped_event;
  guint signal;
  gboolean pressed;

  mapped_event = games_event_copy ((GamesEvent *) games_event);
  games_gamepad_mapping_get_button_mapping (self->mapping,
                                            games_event->hardware_index,
                                            &destination);

  pressed = games_event->type == GAMES_EVENT_GAMEPAD_BUTTON_PRESS;

  switch (destination.type) {
  case EV_ABS:
    signal = SIGNAL_AXIS_EVENT;
    mapped_event->gamepad_axis.axis = destination.code;
    mapped_event->gamepad_axis.value = pressed ? 1 : 0;

    break;
  case EV_KEY:
    signal = pressed ? SIGNAL_BUTTON_PRESS_EVENT : SIGNAL_BUTTON_RELEASE_EVENT;
    mapped_event->gamepad_button.button = destination.code;

    break;
  default:
    games_event_free (mapped_event);

    return;
  }

  g_signal_emit (self, signals[signal], 0, mapped_event);

  games_event_free (mapped_event);
}

static void
map_axis_event (GamesGamepad          *self,
                GamesEventGamepadAxis *games_event)
{
  GamesGamepadInput destination;
  GamesEvent *mapped_event;
  guint signal;
  gboolean pressed;

  mapped_event = games_event_copy ((GamesEvent *) games_event);
  games_gamepad_mapping_get_axis_mapping (self->mapping, games_event->hardware_index, &destination);

  pressed = games_event->value > 0.;

  switch (destination.type) {
  case EV_ABS:
    signal = SIGNAL_AXIS_EVENT;
    mapped_event->gamepad_axis.axis = destination.code;

    break;
  case EV_KEY:
    signal = pressed ? SIGNAL_BUTTON_PRESS_EVENT : SIGNAL_BUTTON_RELEASE_EVENT;
    mapped_event->gamepad_button.button = destination.code;

    break;
  default:
    games_event_free (mapped_event);

    return;
  }

  g_signal_emit (self, signals[signal], 0, mapped_event);

  games_event_free (mapped_event);
}

static void
map_hat_event (GamesGamepad         *self,
               GamesEventGamepadHat *games_event)
{
  GamesGamepadInput destination;
  GamesEvent *mapped_event;
  guint signal;
  gboolean pressed;

  mapped_event = games_event_copy ((GamesEvent *) games_event);
  games_gamepad_mapping_get_dpad_mapping (self->mapping,
                                          games_event->hardware_index / 2,
                                          games_event->hardware_index % 2,
                                          games_event->value,
                                          &destination);

  pressed = abs (games_event->value);

  switch (destination.type) {
  case EV_ABS:
    signal = SIGNAL_AXIS_EVENT;
    mapped_event->gamepad_axis.axis = destination.code;
    mapped_event->gamepad_axis.value = abs (games_event->value);

    break;
  case EV_KEY:
    signal = pressed ? SIGNAL_BUTTON_PRESS_EVENT : SIGNAL_BUTTON_RELEASE_EVENT;
    mapped_event->gamepad_button.button = destination.code;

    break;
  default:
    games_event_free (mapped_event);

    return;
  }

  g_signal_emit (self, signals[signal], 0, mapped_event);

  games_event_free (mapped_event);
}

static void
map_event (GamesGamepad *self,
           GamesEvent   *event)
{
  switch (event->type) {
  case GAMES_EVENT_GAMEPAD_BUTTON_PRESS:
  case GAMES_EVENT_GAMEPAD_BUTTON_RELEASE:
    map_button_event (self, &event->gamepad_button);

    break;
  case GAMES_EVENT_GAMEPAD_AXIS:
    map_axis_event (self, &event->gamepad_axis);

    break;
  case GAMES_EVENT_GAMEPAD_HAT:
    map_hat_event (self, &event->gamepad_hat);

    break;
  default:
    break;
  }
}

static void
on_event (GamesRawGamepad *sender,
          GamesEvent      *event,
          gpointer         data)
{
  GamesGamepad *self;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  g_signal_emit (self, signals[SIGNAL_EVENT], 0, event);

  if (self->mapping == NULL)
    forward_event (self, event);
  else
    map_event (self, event);
}

static void
on_unplugged (GamesRawGamepad *sender,
              gpointer         target)
{
  g_signal_emit (target, signals[SIGNAL_UNPLUGGED], 0);
}

/* Public */

const gchar *
games_gamepad_get_guid (GamesGamepad *self)
{
  return games_raw_gamepad_get_guid (self->raw_gamepad);
}

const gchar *
games_gamepad_get_name (GamesGamepad *self)
{
  return games_raw_gamepad_get_name (self->raw_gamepad);
}

void
games_gamepad_set_mapping (GamesGamepad        *self,
                           GamesGamepadMapping *mapping)
{
  if (self->mapping != NULL)
    g_object_unref (self->mapping);

  self->mapping = mapping ? g_object_ref (mapping) : NULL;
}

GamesGamepad *
games_gamepad_new (GamesRawGamepad *raw_gamepad)
{
  GamesGamepad *self = NULL;

  g_return_val_if_fail (raw_gamepad != NULL, NULL);

  self = (GamesGamepad*) g_object_new (GAMES_TYPE_GAMEPAD, NULL);

  self->raw_gamepad = g_object_ref (raw_gamepad);

  g_signal_connect_object (raw_gamepad,
                           "event",
                           (GCallback) on_event,
                           self,
                           0);
  g_signal_connect_object (raw_gamepad,
                           "unplugged",
                           (GCallback) on_unplugged,
                           self,
                           0);

  return self;
}

/* Type */

static void finalize (GObject *obj) {
  GamesGamepad *self;
  self = G_TYPE_CHECK_INSTANCE_CAST (obj, GAMES_TYPE_GAMEPAD, GamesGamepad);
  g_object_unref (self->raw_gamepad);
  g_object_unref (self->mapping);
  G_OBJECT_CLASS (games_gamepad_parent_class)->finalize (obj);
}

static void games_gamepad_class_init (GamesGamepadClass *klass) {
  games_gamepad_parent_class = g_type_class_peek_parent (klass);
  G_OBJECT_CLASS (klass)->finalize = finalize;

  /**
   * GamesGamepad::event:
   * @event: the event emitted by the gamepad
   **/
  signals[SIGNAL_EVENT] =
    g_signal_new ("event",
                  GAMES_TYPE_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__BOXED,
                  G_TYPE_NONE, 1,
                  GAMES_TYPE_EVENT | G_SIGNAL_TYPE_STATIC_SCOPE);

  /**
   * GamesGamepad::button-press-event:
   * @event: the event emitted by the gamepad
   *
   * Emitted when a button is pressed.
   */
  signals[SIGNAL_BUTTON_PRESS_EVENT] =
    g_signal_new ("button-press-event",
                  GAMES_TYPE_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__BOXED,
                  G_TYPE_NONE, 1,
                  GAMES_TYPE_EVENT | G_SIGNAL_TYPE_STATIC_SCOPE);

  /**
   * GamesGamepad::button-release-event:
   * @event: the event emitted by the gamepad
   *
   * Emitted when a button is released.
   */
  signals[SIGNAL_BUTTON_RELEASE_EVENT] =
    g_signal_new ("button-release-event",
                  GAMES_TYPE_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__BOXED,
                  G_TYPE_NONE, 1,
                  GAMES_TYPE_EVENT | G_SIGNAL_TYPE_STATIC_SCOPE);

  /**
   * GamesGamepad::axis-event:
   * @event: the event emitted by the gamepad
   *
   * Emitted when a axis' value changes.
   */
  signals[SIGNAL_AXIS_EVENT] =
    g_signal_new ("axis-event",
                  GAMES_TYPE_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__BOXED,
                  G_TYPE_NONE, 1,
                  GAMES_TYPE_EVENT | G_SIGNAL_TYPE_STATIC_SCOPE);

  /**
   * GamesGamepad::hat-event:
   * @event: the event emitted by the gamepad
   *
   * Emitted when a axis from a hat's value changes.
   */
  signals[SIGNAL_HAT_EVENT] =
    g_signal_new ("hat-event",
                  GAMES_TYPE_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__BOXED,
                  G_TYPE_NONE, 1,
                  GAMES_TYPE_EVENT | G_SIGNAL_TYPE_STATIC_SCOPE);

  /**
   * GamesGamepad::unplugged:
   *
   * Emitted when the gamepad is unplugged.
   */
  signals[SIGNAL_UNPLUGGED] =
    g_signal_new ("unplugged",
                  GAMES_TYPE_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  g_cclosure_marshal_VOID__VOID,
                  G_TYPE_NONE, 0);
}

static void games_gamepad_init (GamesGamepad *self) {
}
