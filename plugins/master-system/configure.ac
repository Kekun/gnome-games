PKG_CHECK_MODULES(MASTER_SYSTEM_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.10
], [enable_master_system_plugin=yes], [enable_master_system_plugin=no])

AM_CONDITIONAL(ENABLE_MASTER_SYSTEM_PLUGIN, test x$enable_master_system_plugin != xno)

AC_CONFIG_FILES([
	plugins/master-system/Makefile
	plugins/master-system/data/Makefile
	plugins/master-system/src/Makefile
])
