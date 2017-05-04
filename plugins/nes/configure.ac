PKG_CHECK_MODULES(NES_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
], [enable_nes_plugin=yes], [enable_nes_plugin=no])

AM_CONDITIONAL(ENABLE_NES_PLUGIN, test x$enable_nes_plugin != xno)

AC_CONFIG_FILES([
	plugins/nes/Makefile
	plugins/nes/data/Makefile
	plugins/nes/src/Makefile
])
