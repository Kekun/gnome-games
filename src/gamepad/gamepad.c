// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad.h"

#include <stdlib.h>
#include "../event/event.h"
#include "gamepad-mapping.h"
#include "gamepad-mappings-manager.h"

struct _GamesGamepad {
  GObject parent_instance;

  GamesRawGamepad *raw_gamepad;
  GamesGamepadMapping *mapping;
};

G_DEFINE_TYPE (GamesGamepad, games_gamepad, G_TYPE_OBJECT)

enum {
  SIGNAL_EVENT,
  SIGNAL_BUTTON_EVENT,
  SIGNAL_AXIS_EVENT,
  SIGNAL_UNPLUGGED,
  LAST_SIGNAL,
};

static guint signals[LAST_SIGNAL] = { 0 };

/* Private */

static void
on_button_event (GamesRawGamepad         *sender,
                 GamesEventGamepadButton *games_event,
                 gpointer                 data)
{
  GamesGamepad *self;
  GamesGamepadMappedEvent event;
  gboolean value;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  if (self->mapping == NULL)
    return;

  switch (games_event->type) {
  case GAMES_EVENT_GAMEPAD_BUTTON_PRESS:
    value = TRUE;

    break;
  case GAMES_EVENT_GAMEPAD_BUTTON_RELEASE:
    value = FALSE;

    break;
  default:
    g_assert_not_reached ();

    break;
  }
  games_gamepad_mapping_get_button_mapping (self->mapping,
                                            games_event->index,
                                            &event);

  switch (event.type) {
  case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
    g_signal_emit (self,
                   signals[SIGNAL_AXIS_EVENT],
                   0, event.axis, value ? 1 : 0);

    break;
  case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
    g_signal_emit (self,
                   signals[SIGNAL_BUTTON_EVENT],
                   0, event.button, value);
    break;
  default:
    break;
  }
}

static void
on_axis_event (GamesRawGamepad       *sender,
               GamesEventGamepadAxis *games_event,
               gpointer               data)
{
  GamesGamepad *self;
  GamesGamepadMappedEvent event;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  if (self->mapping == NULL)
    return;

  games_gamepad_mapping_get_axis_mapping (self->mapping, games_event->index, &event);
  switch (event.type) {
  case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
    g_signal_emit (self, signals[SIGNAL_AXIS_EVENT],
                   0, event.axis, games_event->value);
    break;
  case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
    g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                   0, event.button, games_event->value > 0.);

    break;
  default:
    break;
  }
}

static void
on_hat_event (GamesRawGamepad      *sender,
              GamesEventGamepadHat *games_event,
              gpointer              data)
{
  GamesGamepad *self;
  GamesGamepadMappedEvent event;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  if (self->mapping == NULL) {
    if (games_event->index != 0)
      return;

    switch (games_event->axis) {
    case 0:
      g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                     0, GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_LEFT, games_event->value < 0);
      g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                     0, GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_RIGHT, games_event->value > 0);

      break;
    case 1:
      g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                     0, GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_UP, games_event->value < 0);
      g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                     0, GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_DOWN, games_event->value > 0);

      break;
    default:
      g_debug ("Unexpected axis number: %d.", games_event->axis);

      break;
    }

    return;
  }

  games_gamepad_mapping_get_dpad_mapping (self->mapping, games_event->index, games_event->axis, games_event->value, &event);
  switch (event.type) {
  case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
    g_signal_emit (self, signals[SIGNAL_AXIS_EVENT],
                   0, event.axis, (gdouble) abs (games_event->value));

    break;
  case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
    g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                   0, event.button, (gboolean) abs (games_event->value));

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
  GamesGamepadMappedEvent mapped_event;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  g_signal_emit (self, signals[SIGNAL_EVENT], 0, event);

  if (self->mapping == NULL)
    return;

  switch (event->type) {
  case GAMES_EVENT_GAMEPAD_BUTTON_PRESS:
  case GAMES_EVENT_GAMEPAD_BUTTON_RELEASE:
    on_button_event (sender, &event->gamepad_button, data);

    break;
  case GAMES_EVENT_GAMEPAD_AXIS:
    on_axis_event (sender, &event->gamepad_axis, data);

    break;
  case GAMES_EVENT_GAMEPAD_HAT:
    on_hat_event (sender, &event->gamepad_hat, data);

    break;
  default:
    break;
  }
}

static void
on_unplugged (GamesRawGamepad *sender,
              gpointer         target)
{
  g_signal_emit (target, signals[SIGNAL_UNPLUGGED], 0);
}

/* Public */

// FIXME
GamesGamepad *
games_gamepad_new (GamesRawGamepad  *raw_gamepad,
                   GError          **error)
{
  GamesGamepad *self = NULL;
  const gchar *guid;
  GamesGamepadMappingsManager *mappings_manager;
  const gchar *mapping_string;
  GError *inner_error = NULL;

  g_return_val_if_fail (raw_gamepad != NULL, NULL);

  self = (GamesGamepad*) g_object_new (GAMES_TYPE_GAMEPAD, NULL);

  self->raw_gamepad = g_object_ref (raw_gamepad);
  guid = games_raw_gamepad_get_guid (raw_gamepad);
  mappings_manager = games_gamepad_mappings_manager_get_instance ();
  mapping_string = games_gamepad_mappings_manager_get_mapping (mappings_manager, guid);

  g_object_unref (mappings_manager);

  self->mapping = games_gamepad_mapping_new_from_sdl_string (mapping_string, &inner_error);
  if (G_UNLIKELY (inner_error != NULL)) {
    g_debug ("%s", inner_error->message);
    g_clear_error (&inner_error);
  }

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
   * GamesGamepad::axis-event:
   * @button: the code representing the button
   * @value: %TRUE if the button is pressed, %FALSE otherwise
   *
   * Emitted when a button is pressed/released.
   */
  signals[SIGNAL_BUTTON_EVENT] =
    g_signal_new ("button-event",
                  GAMES_TYPE_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  NULL,
                  G_TYPE_NONE, 2,
                  GAMES_TYPE_STANDARD_GAMEPAD_BUTTON,
                  G_TYPE_BOOLEAN);

  /**
   * GamesGamepad::axis-event:
   * @axis: the code representing the axis
   * @value: the value of the axis ranging from -1 to 1
   *
   * Emitted when a standard axis' value changes.
   */
  signals[SIGNAL_AXIS_EVENT] =
    g_signal_new ("axis-event",
                  GAMES_TYPE_GAMEPAD,
                  G_SIGNAL_RUN_LAST,
                  0, NULL, NULL,
                  NULL,
                  G_TYPE_NONE, 2,
                  GAMES_TYPE_STANDARD_GAMEPAD_AXIS,
                  G_TYPE_DOUBLE);

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
