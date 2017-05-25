PKG_CHECK_MODULES(WONDERSWAN_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
], [enable_wonderswan_plugin=yes], [enable_wonderswan_plugin=no])

AM_CONDITIONAL(ENABLE_WONDERSWAN_PLUGIN, test x$enable_wonderswan_plugin != xno)

AC_CONFIG_FILES([
	plugins/wonderswan/Makefile
	plugins/wonderswan/data/Makefile
	plugins/wonderswan/src/Makefile
])
