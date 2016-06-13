PKG_CHECK_MODULES(PSX_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	tracker-sparql-1.0
], [enable_playstation_plugin=yes], [enable_playstation_plugin=no])

AM_CONDITIONAL(ENABLE_PLAYSTATION_PLUGIN, test x$enable_playstation_plugin != xno)

AC_CONFIG_FILES([
	plugins/playstation/Makefile
	plugins/playstation/data/Makefile
	plugins/playstation/src/Makefile
])
