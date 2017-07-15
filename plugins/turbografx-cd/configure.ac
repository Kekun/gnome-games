PKG_CHECK_MODULES(TURBOGRAFX_CD_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_turbografx_cd_plugin=yes], [enable_turbografx_cd_plugin=no])

AM_CONDITIONAL(ENABLE_TURBOGRAFX_CD_PLUGIN, test x$enable_turbografx_cd_plugin != xno)

AC_CONFIG_FILES([
	plugins/turbografx-cd/Makefile
	plugins/turbografx-cd/data/Makefile
	plugins/turbografx-cd/src/Makefile
])
