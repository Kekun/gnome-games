PKG_CHECK_MODULES(MS_DOS_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
], [enable_ms_dos_plugin=yes], [enable_ms_dos_plugin=no])

AM_CONDITIONAL(ENABLE_MS_DOS_PLUGIN, test x$enable_ms_dos_plugin != xno)

AC_CONFIG_FILES([
	plugins/ms-dos/Makefile
	plugins/ms-dos/data/Makefile
	plugins/ms-dos/src/Makefile
])
