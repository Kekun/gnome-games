PKG_CHECK_MODULES(NINTENDO_DS_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_nintendo_ds_plugin=yes], [enable_nintendo_ds_plugin=no])

AM_CONDITIONAL(ENABLE_NINTENDO_DS_PLUGIN, test x$enable_nintendo_ds_plugin != xno)

AC_CONFIG_FILES([
	plugins/nintendo-ds/Makefile
	plugins/nintendo-ds/data/Makefile
	plugins/nintendo-ds/src/Makefile
])
