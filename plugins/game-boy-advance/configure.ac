PKG_CHECK_MODULES(GAME_BOY_ADVANCE_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	tracker-sparql-1.0
], [enable_game_boy_advance_plugin=yes], [enable_game_boy_advance_plugin=no])

AM_CONDITIONAL(ENABLE_GAME_BOY_ADVANCE_PLUGIN, test x$enable_game_boy_advance_plugin != xno)

AC_CONFIG_FILES([
	plugins/game-boy-advance/Makefile
	plugins/game-boy-advance/data/Makefile
	plugins/game-boy-advance/src/Makefile
])
