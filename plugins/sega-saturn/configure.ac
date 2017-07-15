PKG_CHECK_MODULES(SEGA_SATURN_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_sega_saturn_plugin=yes], [enable_sega_saturn_plugin=no])

AM_CONDITIONAL(ENABLE_SEGA_SATURN_PLUGIN, test x$enable_sega_saturn_plugin != xno)

AC_CONFIG_FILES([
	plugins/sega-saturn/Makefile
	plugins/sega-saturn/data/Makefile
	plugins/sega-saturn/src/Makefile
])
