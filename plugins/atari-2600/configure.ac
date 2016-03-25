PKG_CHECK_MODULES(ATARI_2600_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	tracker-sparql-1.0
], [enable_atari_2600_plugin=yes], [enable_atari_2600_plugin=no])

AM_CONDITIONAL(ENABLE_ATARI_2600_PLUGIN, test x$enable_atari_2600_plugin != xno)

AC_CONFIG_FILES([
	plugins/atari-2600/Makefile
	plugins/atari-2600/data/Makefile
	plugins/atari-2600/src/Makefile
])
