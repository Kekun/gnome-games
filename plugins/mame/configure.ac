PKG_CHECK_MODULES(MAME_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_mame_plugin=yes], [enable_mame_plugin=no])

AM_CONDITIONAL(ENABLE_MAME_PLUGIN, test x$enable_mame_plugin != xno)

AC_CONFIG_FILES([
	plugins/mame/Makefile
	plugins/mame/data/Makefile
	plugins/mame/src/Makefile
])
