PKG_CHECK_MODULES(ATARI_LYNX_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
], [enable_atari_lynx_plugin=yes], [enable_atari_lynx_plugin=no])

AM_CONDITIONAL(ENABLE_ATARI_LYNX_PLUGIN, test x$enable_atari_lynx_plugin != xno)

AC_CONFIG_FILES([
	plugins/atari-lynx/Makefile
	plugins/atari-lynx/data/Makefile
	plugins/atari-lynx/src/Makefile
])
