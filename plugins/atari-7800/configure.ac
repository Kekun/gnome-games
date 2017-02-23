PKG_CHECK_MODULES(ATARI_7800_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
	tracker-sparql-1.0
], [enable_atari_7800_plugin=yes], [enable_atari_7800_plugin=no])

AM_CONDITIONAL(ENABLE_ATARI_7800_PLUGIN, test x$enable_atari_7800_plugin != xno)

AC_CONFIG_FILES([
	plugins/atari-7800/Makefile
	plugins/atari-7800/data/Makefile
	plugins/atari-7800/src/Makefile
])
