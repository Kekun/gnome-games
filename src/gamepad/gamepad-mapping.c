// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-mapping.h"

#include <glib/gi18n-lib.h>
#include <stdlib.h>
#include "gamepad-dpad.h"
#include "gamepad-mapping-error.h"

typedef struct {
  GamesGamepadInputType type;
  gint value;
} input_t;

struct _GamesGamepadMapping {
  GObject parent_instance;

  GArray *buttons;
  GArray *axes;
  GArray *dpads;
};

G_DEFINE_TYPE (GamesGamepadMapping, games_gamepad_mapping, G_TYPE_OBJECT)

/* Private */

static void
parse_dpad_value (GamesGamepadMapping *self,
                  const gchar         *mapping_value,
                  input_t              input)
{
  const gchar *mapping_value_number;
  gchar **dpad_parse_array;
  gint dpad_index;
  gint dpad_position_2pow;
  gint dpad_position;

  g_return_if_fail (self != NULL);
  g_return_if_fail (mapping_value != NULL);
  g_return_if_fail (*mapping_value == 'h');

  mapping_value_number = mapping_value + 1;

  g_return_if_fail (mapping_value_number != NULL);
  g_return_if_fail (*mapping_value_number != '\0');

  dpad_parse_array = g_strsplit (mapping_value_number, ".", 0);
  if (g_strv_length (dpad_parse_array) != 2) {
    g_strfreev (dpad_parse_array);
    g_debug ("Unexpected D-Pad mapping format.");

    return;
  }

  dpad_index = atoi (dpad_parse_array[0]);
  dpad_position_2pow = atoi (dpad_parse_array[1]);
  dpad_position = 0;

  g_strfreev (dpad_parse_array);

  while (dpad_position_2pow > 1) {
    dpad_position_2pow >>= 1;
    dpad_position++;
  }

  if (self->dpads->len <= dpad_index)
    g_array_set_size (self->dpads, dpad_index + 1);
  g_array_index (self->dpads, GamesGamepadDPad, dpad_index).types[dpad_position] = input.type;
  g_array_index (self->dpads, GamesGamepadDPad, dpad_index).values[dpad_position] = input.value;
}

static void
parse_button_value (GamesGamepadMapping *self,
                    const gchar         *mapping_value,
                    input_t              input)
{
  // g_array_append_val() requires a l-value.
  const gchar *mapping_value_number;
  gint button;

  g_return_if_fail (self != NULL);
  g_return_if_fail (mapping_value != NULL);
  g_return_if_fail (*mapping_value == 'b');

  mapping_value_number = mapping_value + 1;

  g_return_if_fail (mapping_value_number != NULL);
  g_return_if_fail (*mapping_value_number != '\0');

  button = atoi (mapping_value_number);

  if (self->buttons->len <= button)
    g_array_set_size (self->buttons, button + 1);
  g_array_index (self->buttons, input_t, button) = input;
}

static void
parse_axis_value (GamesGamepadMapping *self,
                  const gchar         *mapping_value,
                  input_t              input)
{
  const gchar *mapping_value_number;
  gint axis;

  g_return_if_fail (self != NULL);
  g_return_if_fail (mapping_value != NULL);
  g_return_if_fail (*mapping_value == 'a');

  mapping_value_number = mapping_value + 1;

  g_return_if_fail (mapping_value_number != NULL);
  g_return_if_fail (*mapping_value_number != '\0');

  axis = atoi (mapping_value_number);

  if (self->axes->len <= axis)
    g_array_set_size (self->axes, axis + 1);
  g_array_index (self->axes, input_t, axis) = input;
}

static GamesGamepadInputType
parse_input_type (const gchar *mapping_string)
{
  const static struct {
    GamesGamepadInputType enum_value;
    const gchar *string_value;
  } values[] = {
    { GAMES_GAMEPAD_INPUT_TYPE_AXIS, "leftx" },
    { GAMES_GAMEPAD_INPUT_TYPE_AXIS, "lefty" },
    { GAMES_GAMEPAD_INPUT_TYPE_AXIS, "rightx" },
    { GAMES_GAMEPAD_INPUT_TYPE_AXIS, "righty" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "a" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "b" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "back" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "dpdown" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "dpleft" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "dpright" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "dpup" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "guide" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "leftshoulder" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "leftstick" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "lefttrigger" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "rightshoulder" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "rightstick" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "righttrigger" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "start" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "x" },
    { GAMES_GAMEPAD_INPUT_TYPE_BUTTON, "y" },
  };
  const gint length = sizeof (values) / sizeof (values[0]);
  gint i;

  for (i = 0; i < length; i++)
    if (g_strcmp0 (mapping_string, values[i].string_value) == 0)
      return values[i].enum_value;

  return GAMES_GAMEPAD_INPUT_TYPE_INVALID;
}

static GamesStandardGamepadAxis
parse_axis (const gchar *mapping_string)
{
  const static struct {
    GamesStandardGamepadAxis enum_value;
    const gchar *string_value;
  } values[] = {
    { GAMES_STANDARD_GAMEPAD_AXIS_LEFT_X, "leftx" },
    { GAMES_STANDARD_GAMEPAD_AXIS_LEFT_Y, "lefty" },
    { GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_X, "rightx" },
    { GAMES_STANDARD_GAMEPAD_AXIS_RIGHT_Y, "righty" },
  };
  const gint length = sizeof (values) / sizeof (values[0]);
  gint i;

  for (i = 0; i < length; i++)
    if (g_strcmp0 (mapping_string, values[i].string_value) == 0)
      return values[i].enum_value;

  return GAMES_STANDARD_GAMEPAD_AXIS_UNKNOWN;
}

static GamesStandardGamepadButton
parse_button (const gchar *mapping_string)
{
  const static struct {
    GamesStandardGamepadButton enum_value;
    const gchar *string_value;
  } values[] = {
    { GAMES_STANDARD_GAMEPAD_BUTTON_A, "a" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_B, "b" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_DOWN, "dpdown" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_LEFT, "dpleft" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_RIGHT, "dpright" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_DPAD_UP, "dpup" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_HOME, "guide" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_SELECT, "back" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_SHOULDER_L, "leftshoulder" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_SHOULDER_R, "rightshoulder" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_START, "start" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_STICK_L, "leftstick" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_STICK_R, "rightstick" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_TRIGGER_L, "lefttrigger" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_TRIGGER_R, "righttrigger" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_X, "x" },
    { GAMES_STANDARD_GAMEPAD_BUTTON_Y, "y" },
  };
  const gint length = sizeof (values) / sizeof (values[0]);
  gint i;

  for (i = 0; i < length; i++)
    if (g_strcmp0 (mapping_string, values[i].string_value) == 0)
      return values[i].enum_value;

  return GAMES_STANDARD_GAMEPAD_BUTTON_UNKNOWN;
}

// This function doesn't take care of cleaning up the object's state before
// setting it.
static void
set_from_sdl_string (GamesGamepadMapping *self,
                     const gchar         *mapping_string)
{
  gchar **mappings;
  guint mappings_length;
  guint i = 0;
  gchar **splitted_mapping;
  gchar *mapping_key;
  gchar *mapping_value;
  input_t input;
  gint parsed_key;

  mappings = g_strsplit (mapping_string, ",", 0);
  mappings_length = g_strv_length (mappings);
  for (i = 0; i < mappings_length; i++) {

    splitted_mapping = g_strsplit (mappings[i], ":", 0);

    if (g_strv_length (splitted_mapping) != 2) {
      g_strfreev (splitted_mapping);

      continue;
    }

    mapping_key = g_strdup (splitted_mapping[0]);
    mapping_value = g_strdup (splitted_mapping[1]);
    input.type = parse_input_type (mapping_key);

    g_strfreev (splitted_mapping);

    switch (input.type) {
    case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
      input.value = (gint) parse_button (mapping_key);

      break;
    case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
      input.value = (gint) parse_axis (mapping_key);

      break;
    case GAMES_GAMEPAD_INPUT_TYPE_INVALID:
      if (g_strcmp0 (mapping_key, "platform") != 0)
        g_debug ("Invalid token: %s", mapping_key);

      g_free (mapping_value);
      g_free (mapping_key);

      continue;
    default:
      g_free (mapping_value);
      g_free (mapping_key);

      continue;
    }

    g_free (mapping_key);

    switch (*mapping_value) {
    case 'h':
      parse_dpad_value (self, mapping_value, input);

      break;
    case 'b':
      parse_button_value (self, mapping_value, input);

      break;
    case 'a':
      parse_axis_value (self, mapping_value, input);

      break;
    default:
      break;
    }

    g_free (mapping_value);
  }

  g_strfreev (mappings);
}

/* Public */

GamesGamepadMapping *
games_gamepad_mapping_new_from_sdl_string (const gchar  *mapping_string,
                                           GError      **error)
{
  GamesGamepadMapping *self = NULL;

  if (mapping_string == NULL) {
    g_set_error_literal (error,
                         GAMES_GAMEPAD_MAPPING_ERROR,
                         GAMES_GAMEPAD_MAPPING_ERROR_NOT_A_MAPPING,
                         _("The mapping string can’t be null."));

    return NULL;
  }

  if (mapping_string[0] == '\0') {
    g_set_error_literal (error,
                         GAMES_GAMEPAD_MAPPING_ERROR,
                         GAMES_GAMEPAD_MAPPING_ERROR_NOT_A_MAPPING,
                         _("The mapping string can’t be empty."));

    return NULL;
  }

  self = (GamesGamepadMapping*) g_object_new (GAMES_TYPE_GAMEPAD_MAPPING, NULL);

  self->buttons = g_array_new (FALSE, TRUE, sizeof (input_t));
  self->axes = g_array_new (FALSE, TRUE, sizeof (input_t));
  self->dpads = g_array_new (FALSE, TRUE, sizeof (GamesGamepadDPad));

  set_from_sdl_string (self, mapping_string);

  return self;
}

void
games_gamepad_mapping_get_dpad_mapping (GamesGamepadMapping     *self,
                                        gint                     dpad_index,
                                        gint                     dpad_axis,
                                        gint                     dpad_value,
                                        GamesGamepadMappedEvent *event)
{
  GamesGamepadDPad *dpad;
  gint dpad_changed_value;
  gint dpad_position;

  g_return_if_fail (self != NULL);
  g_return_if_fail (event != NULL);

  memset (event, 0, sizeof (GamesGamepadMappedEvent));

  dpad = &g_array_index (self->dpads, GamesGamepadDPad, dpad_index);
  dpad_changed_value = (dpad_value == 0) ?
    dpad->axis_values[dpad_axis] :
    dpad_value;
  // We add 4 so that the remainder is always positive.
  dpad_position = (dpad_changed_value + dpad_axis + 4) % 4;
  dpad->axis_values[dpad_axis] = dpad_value;
  event->type = dpad->types[dpad_position];

  switch (event->type) {
  case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
    event->axis = (GamesStandardGamepadAxis) dpad->values[dpad_position];

    break;
  case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
    event->button = (GamesStandardGamepadButton) dpad->values[dpad_position];

    break;
  default:
    break;
  }
}

void
games_gamepad_mapping_get_axis_mapping (GamesGamepadMapping     *self,
                                        gint                     axis_number,
                                        GamesGamepadMappedEvent *event)
{
  g_return_if_fail (self != NULL);
  g_return_if_fail (event != NULL);

  memset (event, 0, sizeof (GamesGamepadMappedEvent));

  event->type = (axis_number < self->axes->len) ?
    g_array_index (self->axes, input_t, axis_number).type :
    GAMES_GAMEPAD_INPUT_TYPE_INVALID;

  switch (event->type) {
  case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
    event->axis = (GamesStandardGamepadAxis) g_array_index (self->axes, input_t, axis_number).value;

    break;
  case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
    event->button = (GamesStandardGamepadButton) g_array_index (self->axes, input_t, axis_number).value;

    break;
  default:
    break;
  }
}

void
games_gamepad_mapping_get_button_mapping (GamesGamepadMapping     *self,
                                          gint                     button_number,
                                          GamesGamepadMappedEvent *event)
{
  g_return_if_fail (self != NULL);
  g_return_if_fail (event != NULL);

  memset (event, 0, sizeof (GamesGamepadMappedEvent));

  event->type = (button_number < self->buttons->len) ?
    g_array_index (self->buttons, input_t, button_number).type :
    GAMES_GAMEPAD_INPUT_TYPE_INVALID;

  switch (event->type) {
  case GAMES_GAMEPAD_INPUT_TYPE_AXIS:
    event->axis = (GamesStandardGamepadAxis) g_array_index (self->buttons, input_t, button_number).value;

    break;
  case GAMES_GAMEPAD_INPUT_TYPE_BUTTON:
    event->button = (GamesStandardGamepadButton) g_array_index (self->buttons, input_t, button_number).value;

    break;
  default:
    break;
  }
}

/* Type */

static void
finalize (GObject *obj)
{
  GamesGamepadMapping *self;

  self = G_TYPE_CHECK_INSTANCE_CAST (obj, GAMES_TYPE_GAMEPAD_MAPPING, GamesGamepadMapping);

  if (self->buttons != NULL)
    g_array_free (self->buttons, TRUE);
  if (self->axes != NULL)
    g_array_free (self->axes, TRUE);
  if (self->dpads != NULL)
    g_array_free (self->dpads, TRUE);

  G_OBJECT_CLASS (games_gamepad_mapping_parent_class)->finalize (obj);
}

static void
games_gamepad_mapping_class_init (GamesGamepadMappingClass *klass)
{
  games_gamepad_mapping_parent_class = g_type_class_peek_parent (klass);
  G_OBJECT_CLASS (klass)->finalize = finalize;
}

static void
games_gamepad_mapping_init (GamesGamepadMapping *self)
{
}
