PKG_CHECK_MODULES(LOVE_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	libarchive
	retro-gtk-0.12
], [enable_love_plugin=yes], [enable_love_plugin=no])

AM_CONDITIONAL(ENABLE_LOVE_PLUGIN, test x$enable_love_plugin != xno)

AC_CONFIG_FILES([
	plugins/love/Makefile
	plugins/love/data/Makefile
	plugins/love/src/Makefile
])
