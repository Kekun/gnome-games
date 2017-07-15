PKG_CHECK_MODULES(STEAM_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
	tracker-sparql-2.0
], [enable_steam_plugin=yes], [enable_steam_plugin=no])

AM_CONDITIONAL(ENABLE_STEAM_PLUGIN, test x$enable_steam_plugin != xno)

AC_CONFIG_FILES([
	plugins/steam/Makefile
	plugins/steam/data/Makefile
	plugins/steam/src/Makefile
])
