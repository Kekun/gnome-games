PKG_CHECK_MODULES(NINTENDO_64_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
], [enable_nintendo_64_plugin=yes], [enable_nintendo_64_plugin=no])

AM_CONDITIONAL(ENABLE_NINTENDO_64_PLUGIN, test x$enable_nintendo_64_plugin != xno)

AC_CONFIG_FILES([
	plugins/nintendo-64/Makefile
	plugins/nintendo-64/data/Makefile
	plugins/nintendo-64/src/Makefile
])
