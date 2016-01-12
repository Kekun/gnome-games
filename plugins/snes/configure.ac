PKG_CHECK_MODULES(SNES_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	tracker-sparql-1.0
], [enable_snes_plugin=yes], [enable_snes_plugin=no])

AM_CONDITIONAL(ENABLE_SNES_PLUGIN, test x$enable_snes_plugin != xno)

AC_CONFIG_FILES([
	plugins/snes/Makefile
	plugins/snes/data/Makefile
	plugins/snes/src/Makefile
])
