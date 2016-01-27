PKG_CHECK_MODULES(AMIGA_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	tracker-sparql-1.0
], [enable_amiga_plugin=yes], [enable_amiga_plugin=no])

AM_CONDITIONAL(ENABLE_AMIGA_PLUGIN, test x$enable_amiga_plugin != xno)

AC_CONFIG_FILES([
	plugins/amiga/Makefile
	plugins/amiga/data/Makefile
	plugins/amiga/src/Makefile
])
