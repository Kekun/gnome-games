PKG_CHECK_MODULES(GAME_CUBE_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_game_cube_plugin=yes], [enable_game_cube_plugin=no])

AM_CONDITIONAL(ENABLE_GAME_CUBE_PLUGIN, test x$enable_game_cube_plugin != xno)

AC_CONFIG_FILES([
	plugins/game-cube/Makefile
	plugins/game-cube/data/Makefile
	plugins/game-cube/src/Makefile
])
