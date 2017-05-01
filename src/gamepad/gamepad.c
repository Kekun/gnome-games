// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad.h"

#include <stdlib.h>
#include "gamepad-mapping.h"
#include "gamepad-mappings-manager.h"

struct _GamesGamepad {
  GObject parent_instance;

  GamesRawGamepad *raw_gamepad;
  GamesGamepadMapping *mapping;
};

G_DEFINE_TYPE (GamesGamepad, games_gamepad, G_TYPE_OBJECT)

enum {
  SIGNAL_BUTTON_EVENT,
  SIGNAL_AXIS_EVENT,
  SIGNAL_UNPLUGGED,
  LAST_SIGNAL,
};

static guint signals[LAST_SIGNAL] = { 0 };

/* Private */

static void
on_standard_button_event (GamesRawGamepad            *sender,
                          GamesStandardGamepadButton  button,
                          gboolean                    value,
                          gpointer                    data)
{
  GamesGamepad *self;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  if (self->mapping != NULL)
    return;

  g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                 0, button, value);
}

static void
on_raw_button_event (GamesRawGamepad *sender,
                     gint             button,
                     gboolean         value,
                     gpointer         data)
{
  GamesGamepad *self;
  GamesGamepadMappedEvent event;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  if (self->mapping == NULL)
    return;

  games_gamepad_mapping_get_button_mapping (self->mapping,
                                            button,
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
on_standard_axis_event (GamesRawGamepad          *sender,
                        GamesStandardGamepadAxis  axis,
                        gdouble                   value,
                        gpointer                  data)
{
  GamesGamepad *self;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  if (self->mapping != NULL)
    return;

  g_signal_emit (self, signals[SIGNAL_AXIS_EVENT],
                 0, axis, value);
}

static void
on_raw_axis_event (GamesRawGamepad *sender,
                   gint             axis,
                   gdouble          value,
                   gpointer         data)
{
  GamesGamepad *self;
  GamesGamepadMappedEvent event;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  if (self->mapping == NULL)
    return;

  games_gamepad_mapping_get_axis_mapping (self->mapping, axis, &event);
  switch (event.type) {
  case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
    g_signal_emit (self, signals[SIGNAL_AXIS_EVENT],
                   0, event.axis, value);
    break;
  case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
    g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                   0, event.button, value > 0.);

    break;
  default:
    break;
  }
}

static void
on_raw_dpad_event (GamesRawGamepad *sender,
                   gint             dpad_index,
                   gint             axis,
                   gint             value,
                   gpointer         data)
{
  GamesGamepad *self;
  GamesGamepadMappedEvent event;

  self = GAMES_GAMEPAD (data);

  g_return_if_fail (self != NULL);

  if (self->mapping == NULL) {
    if (dpad_index != 0)
      return;

    switch (axis) {
    case 0:
      g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                     0, GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_LEFT, value < 0);
      g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                     0, GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_RIGHT, value > 0);

      break;
    case 1:
      g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                     0, GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_UP, value < 0);
      g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                     0, GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_DOWN, value > 0);

      break;
    default:
      g_debug ("Unexpected axis number: %d.", axis);

      break;
    }

    return;
  }

  games_gamepad_mapping_get_dpad_mapping (self->mapping, dpad_index, axis, value, &event);
  switch (event.type) {
  case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
    g_signal_emit (self, signals[SIGNAL_AXIS_EVENT],
                   0, event.axis, (gdouble) abs (value));

    break;
  case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
    g_signal_emit (self, signals[SIGNAL_BUTTON_EVENT],
                   0, event.button, (gboolean) abs (value));

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
                           "standard-button-event",
                           (GCallback) on_standard_button_event,
                           self,
                           0);
  g_signal_connect_object (raw_gamepad,
                           "button-event",
                           (GCallback) on_raw_button_event,
                           self,
                           0);
  g_signal_connect_object (raw_gamepad,
                           "standard-axis-event",
                           (GCallback) on_standard_axis_event,
                           self,
                           0);
  g_signal_connect_object (raw_gamepad,
                           "axis-event",
                           (GCallback) on_raw_axis_event,
                           self,
                           0);
  g_signal_connect_object (raw_gamepad,
                           "dpad-event",
                           (GCallback) on_raw_dpad_event,
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
