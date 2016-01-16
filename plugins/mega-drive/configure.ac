PKG_CHECK_MODULES(MEGA_DRIVE_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	tracker-sparql-1.0
], [enable_mega_drive_plugin=yes], [enable_mega_drive_plugin=no])

AM_CONDITIONAL(ENABLE_MEGA_DRIVE_PLUGIN, test x$enable_mega_drive_plugin != xno)

AC_CONFIG_FILES([
	plugins/mega-drive/Makefile
	plugins/mega-drive/data/Makefile
	plugins/mega-drive/src/Makefile
])
