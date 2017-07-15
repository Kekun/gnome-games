PKG_CHECK_MODULES(DREAMCAST_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_dreamcast_plugin=yes], [enable_dreamcast_plugin=no])

AM_CONDITIONAL(ENABLE_DREAMCAST_PLUGIN, test x$enable_dreamcast_plugin != xno)

AC_CONFIG_FILES([
	plugins/dreamcast/Makefile
	plugins/dreamcast/data/Makefile
	plugins/dreamcast/src/Makefile
])
