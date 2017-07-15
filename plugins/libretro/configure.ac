PKG_CHECK_MODULES(LIBRETRO_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_libretro_plugin=yes], [enable_libretro_plugin=no])

AM_CONDITIONAL(ENABLE_LIBRETRO_PLUGIN, test x$enable_libretro_plugin != xno)

AC_CONFIG_FILES([
	plugins/libretro/Makefile
	plugins/libretro/data/Makefile
	plugins/libretro/src/Makefile
])
