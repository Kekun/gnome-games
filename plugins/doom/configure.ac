PKG_CHECK_MODULES(DOOM_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
	tracker-sparql-1.0
], [enable_doom_plugin=yes], [enable_doom_plugin=no])

AM_CONDITIONAL(ENABLE_DOOM_PLUGIN, test x$enable_doom_plugin != xno)

AC_CONFIG_FILES([
	plugins/doom/Makefile
	plugins/doom/data/Makefile
	plugins/doom/src/Makefile
])
