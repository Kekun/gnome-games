PKG_CHECK_MODULES(SEGA_CD_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gtk-0.12
], [enable_sega_cd_plugin=yes], [enable_sega_cd_plugin=no])

AM_CONDITIONAL(ENABLE_SEGA_CD_PLUGIN, test x$enable_sega_cd_plugin != xno)

AC_CONFIG_FILES([
	plugins/sega-cd/Makefile
	plugins/sega-cd/data/Makefile
	plugins/sega-cd/src/Makefile
])
