PKG_CHECK_MODULES(PC_ENGINE_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	tracker-sparql-1.0
], [enable_pc_engine_plugin=yes], [enable_pc_engine_plugin=no])

AM_CONDITIONAL(ENABLE_PC_ENGINE_PLUGIN, test x$enable_pc_engine_plugin != xno)

AC_CONFIG_FILES([
	plugins/pc-engine/Makefile
	plugins/pc-engine/data/Makefile
	plugins/pc-engine/src/Makefile
])
