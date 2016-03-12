PKG_CHECK_MODULES(NEO_GEO_POCKET_PLUGIN, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	tracker-sparql-1.0
], [enable_neo_geo_pocket_plugin=yes], [enable_neo_geo_pocket_plugin=no])

AM_CONDITIONAL(ENABLE_NEO_GEO_POCKET_PLUGIN, test x$enable_neo_geo_pocket_plugin != xno)

AC_CONFIG_FILES([
	plugins/neo-geo-pocket/Makefile
	plugins/neo-geo-pocket/data/Makefile
	plugins/neo-geo-pocket/src/Makefile
])
