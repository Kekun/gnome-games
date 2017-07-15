PKG_CHECK_MODULES(WII_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_wii_plugin=yes], [enable_wii_plugin=no])

AM_CONDITIONAL(ENABLE_WII_PLUGIN, test x$enable_wii_plugin != xno)

AC_CONFIG_FILES([
	plugins/wii/Makefile
	plugins/wii/data/Makefile
	plugins/wii/src/Makefile
])
