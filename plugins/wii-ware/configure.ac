PKG_CHECK_MODULES(WII_WARE_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
], [enable_wii_ware_plugin=yes], [enable_wii_ware_plugin=no])

AM_CONDITIONAL(ENABLE_WII_WARE_PLUGIN, test x$enable_wii_ware_plugin != xno)

AC_CONFIG_FILES([
	plugins/wii-ware/Makefile
	plugins/wii-ware/data/Makefile
	plugins/wii-ware/src/Makefile
])
