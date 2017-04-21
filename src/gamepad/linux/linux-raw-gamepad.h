// This file is part of GNOME Games. License: GPL-3.0+.

#ifndef GAMES_LINUX_RAW_GAMEPAD_H
#define GAMES_LINUX_RAW_GAMEPAD_H

#include <glib-object.h>

G_BEGIN_DECLS

#define GAMES_TYPE_LINUX_RAW_GAMEPAD (games_linux_raw_gamepad_get_type())

G_DECLARE_FINAL_TYPE (GamesLinuxRawGamepad, games_linux_raw_gamepad, GAMES, LINUX_RAW_GAMEPAD, GObject)

/*GamesLinuxRawGamepad *games_linux_raw_gamepad_new (void);*/
GamesLinuxRawGamepad *games_linux_raw_gamepad_new (const gchar *file_name,
                                                   GError **error);

G_END_DECLS

#endif /* GAMES_LINUX_RAW_GAMEPAD_H */
