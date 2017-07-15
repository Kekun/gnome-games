PKG_CHECK_MODULES(DESKTOP_PLUGIN, [
	gio-2.0
	gio-unix-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
	tracker-sparql-2.0
], [enable_desktop_plugin=yes], [enable_desktop_plugin=no])

AM_CONDITIONAL(ENABLE_DESKTOP_PLUGIN, test x$enable_desktop_plugin != xno)

AC_CONFIG_FILES([
	plugins/desktop/Makefile
	plugins/desktop/data/Makefile
	plugins/desktop/src/Makefile
])
