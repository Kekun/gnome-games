// This file is part of GNOME Games. License: GPL-3.0+.

#include "gamepad-mapping.h"

#include <glib/gi18n-lib.h>
#include <linux/input-event-codes.h>
#include <stdlib.h>
#include "gamepad-dpad.h"
#include "gamepad-mapping-error.h"

struct _GamesGamepadMapping {
  GObject parent_instance;

  GArray *buttons;
  GArray *axes;
  GArray *dpads;
};

G_DEFINE_TYPE (GamesGamepadMapping, games_gamepad_mapping, G_TYPE_OBJECT)

/* Private */

static void
parse_dpad_source (GamesGamepadMapping *self,
                   const gchar         *source_string,
                   GamesGamepadInput    destination)
{
  const gchar *source_number;
  gchar **dpad_parse_array;
  gint dpad_index;
  gint dpad_position_2pow;
  gint dpad_position;

  g_return_if_fail (self != NULL);
  g_return_if_fail (source_string != NULL);
  g_return_if_fail (*source_string == 'h');

  source_number = source_string + 1;

  g_return_if_fail (source_number != NULL);
  g_return_if_fail (*source_number != '\0');

  dpad_parse_array = g_strsplit (source_number, ".", 0);
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
  g_array_index (self->dpads, GamesGamepadDPad, dpad_index).inputs[dpad_position] = destination;
}

static void
parse_button_source (GamesGamepadMapping *self,
                     const gchar         *source_string,
                     GamesGamepadInput    destination)
{
  // g_array_append_val() requires a l-value.
  const gchar *source_number;
  gint button;

  g_return_if_fail (self != NULL);
  g_return_if_fail (source_string != NULL);
  g_return_if_fail (*source_string == 'b');

  source_number = source_string + 1;

  g_return_if_fail (source_number != NULL);
  g_return_if_fail (*source_number != '\0');

  button = atoi (source_number);

  if (self->buttons->len <= button)
    g_array_set_size (self->buttons, button + 1);
  g_array_index (self->buttons, GamesGamepadInput, button) = destination;
}

static void
parse_axis_source (GamesGamepadMapping *self,
                   const gchar         *source_string,
                   GamesGamepadInput    destination)
{
  const gchar *source_number;
  gint axis;

  g_return_if_fail (self != NULL);
  g_return_if_fail (source_string != NULL);
  g_return_if_fail (*source_string == 'a');

  source_number = source_string + 1;

  g_return_if_fail (source_number != NULL);
  g_return_if_fail (*source_number != '\0');

  axis = atoi (source_number);

  if (self->axes->len <= axis)
    g_array_set_size (self->axes, axis + 1);
  g_array_index (self->axes, GamesGamepadInput, axis) = destination;
}

static void
parse_destination (const gchar       *destination_string,
                   GamesGamepadInput *destination)
{
  const static struct {
    GamesGamepadInput enum_value;
    const gchar *string_value;
  } values[] = {
    { { EV_ABS, ABS_X }, "leftx" },
    { { EV_ABS, ABS_Y }, "lefty" },
    { { EV_ABS, ABS_RX }, "rightx" },
    { { EV_ABS, ABS_RY }, "righty" },
    { { EV_KEY, BTN_A }, "a" },
    { { EV_KEY, BTN_B }, "b" },
    { { EV_KEY, BTN_DPAD_DOWN }, "dpdown" },
    { { EV_KEY, BTN_DPAD_LEFT }, "dpleft" },
    { { EV_KEY, BTN_DPAD_RIGHT }, "dpright" },
    { { EV_KEY, BTN_DPAD_UP }, "dpup" },
    { { EV_KEY, BTN_MODE }, "guide" },
    { { EV_KEY, BTN_SELECT }, "back" },
    { { EV_KEY, BTN_TL }, "leftshoulder" },
    { { EV_KEY, BTN_TR }, "rightshoulder" },
    { { EV_KEY, BTN_START }, "start" },
    { { EV_KEY, BTN_THUMBL }, "leftstick" },
    { { EV_KEY, BTN_THUMBR }, "rightstick" },
    { { EV_KEY, BTN_TL2 }, "lefttrigger" },
    { { EV_KEY, BTN_TR2 }, "righttrigger" },
    { { EV_KEY, BTN_Y }, "x" },
    { { EV_KEY, BTN_X }, "y" },
  };
  const gint length = sizeof (values) / sizeof (values[0]);
  gint i;

  for (i = 0; i < length; i++)
    if (g_strcmp0 (destination_string, values[i].string_value) == 0) {
      *destination = values[i].enum_value;

      return;
    }
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
  gchar *destination_string;
  gchar *source_string;
  GamesGamepadInput destination = { EV_MAX, 0 };

  mappings = g_strsplit (mapping_string, ",", 0);
  mappings_length = g_strv_length (mappings);
  for (i = 0; i < mappings_length; i++) {

    splitted_mapping = g_strsplit (mappings[i], ":", 0);

    if (g_strv_length (splitted_mapping) != 2) {
      g_strfreev (splitted_mapping);

      continue;
    }

    destination_string = g_strdup (splitted_mapping[0]);
    source_string = g_strdup (splitted_mapping[1]);
    parse_destination (destination_string, &destination);

    g_strfreev (splitted_mapping);

    if  (destination.type == EV_MAX) {
      if (g_strcmp0 (destination_string, "platform") != 0)
        g_debug ("Invalid token: %s", destination_string);

      g_free (source_string);
      g_free (destination_string);

      continue;
    }

    g_free (destination_string);

    switch (*source_string) {
    case 'h':
      parse_dpad_source (self, source_string, destination);

      break;
    case 'b':
      parse_button_source (self, source_string, destination);

      break;
    case 'a':
      parse_axis_source (self, source_string, destination);

      break;
    default:
      break;
    }

    g_free (source_string);
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

  self->buttons = g_array_new (FALSE, TRUE, sizeof (GamesGamepadInput));
  self->axes = g_array_new (FALSE, TRUE, sizeof (GamesGamepadInput));
  self->dpads = g_array_new (FALSE, TRUE, sizeof (GamesGamepadDPad));

  set_from_sdl_string (self, mapping_string);

  return self;
}

void
games_gamepad_mapping_get_dpad_mapping (GamesGamepadMapping *self,
                                        gint                 dpad_index,
                                        gint                 dpad_axis,
                                        gint                 dpad_value,
                                        GamesGamepadInput   *destination)
{
  GamesGamepadDPad *dpad;
  GamesGamepadInput *dpad_input;

  gint dpad_changed_value;
  gint dpad_position;

  g_return_if_fail (self != NULL);
  g_return_if_fail (destination != NULL);

  memset (destination, 0, sizeof (GamesGamepadInput));

  destination->type = EV_MAX;
  if (dpad_index >= self->dpads->len)
    return;

  dpad = &g_array_index (self->dpads, GamesGamepadDPad, dpad_index);
  if (dpad == NULL)
    return;

  dpad_changed_value = (dpad_value == 0) ?
    dpad->axis_values[dpad_axis] :
    dpad_value;
  // We add 4 so that the remainder is always positive.
  dpad_position = (dpad_changed_value + dpad_axis + 4) % 4;
  dpad->axis_values[dpad_axis] = dpad_value;
  if (dpad_position >= 4)
    return;

  dpad_input = &dpad->inputs[dpad_position];
  if (dpad_input != NULL)
    *destination = *dpad_input;
}

void
games_gamepad_mapping_get_axis_mapping (GamesGamepadMapping *self,
                                        gint                 axis_number,
                                        GamesGamepadInput   *destination)
{
  g_return_if_fail (self != NULL);
  g_return_if_fail (destination != NULL);

  memset (destination, 0, sizeof (GamesGamepadInput));

  destination->type = EV_MAX;
  if (axis_number >= self->axes->len)
    return;

  *destination = g_array_index (self->axes, GamesGamepadInput, axis_number);
}

void
games_gamepad_mapping_get_button_mapping (GamesGamepadMapping *self,
                                          gint                 button_number,
                                          GamesGamepadInput   *destination)
{
  g_return_if_fail (self != NULL);
  g_return_if_fail (destination != NULL);

  memset (destination, 0, sizeof (GamesGamepadInput));

  destination->type = EV_MAX;
  if (button_number >= self->buttons->len)
    return;

  *destination = g_array_index (self->buttons, GamesGamepadInput, button_number);
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
