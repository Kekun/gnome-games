AC_INIT([gnome-games], [3.20.0])
AM_INIT_AUTOMAKE([foreign subdir-objects])

# i18 support
IT_PROG_INTLTOOL(0.40.0)
GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE",[The name of the gettext domain])

AC_PROG_CC
AM_PROG_VALAC

# GResource
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

# GSettings support
GLIB_GSETTINGS

GLIB_MIN_VERSION=2.38.0
AC_SUBST(GLIB_MIN_VERSION)

LT_INIT

# Plugins
m4_include([plugins/amiga/configure.ac])
m4_include([plugins/atari-2600/configure.ac])
m4_include([plugins/desktop/configure.ac])
m4_include([plugins/doom/configure.ac])
m4_include([plugins/dreamcast/configure.ac])
m4_include([plugins/nes/configure.ac])
m4_include([plugins/game-boy/configure.ac])
m4_include([plugins/game-boy-advance/configure.ac])
m4_include([plugins/game-cube/configure.ac])
m4_include([plugins/love/configure.ac])
m4_include([plugins/mame/configure.ac])
m4_include([plugins/master-system/configure.ac])
m4_include([plugins/mega-drive/configure.ac])
m4_include([plugins/neo-geo-pocket/configure.ac])
m4_include([plugins/nintendo-64/configure.ac])
m4_include([plugins/nintendo-ds/configure.ac])
m4_include([plugins/pc-engine/configure.ac])
m4_include([plugins/sega-saturn/configure.ac])
m4_include([plugins/snes/configure.ac])
m4_include([plugins/steam/configure.ac])
m4_include([plugins/wii/configure.ac])
m4_include([plugins/wii-ware/configure.ac])

PKG_CHECK_MODULES(GNOME_GAMES, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	gtk+-3.0
	retro-gobject-0.6
	retro-gtk-0.6
	tracker-sparql-1.0
])

AC_CONFIG_FILES([
	Makefile
	data/Makefile
	data/icons/Makefile
	plugins/Makefile
	po/Makefile.in
	src/Makefile
])

AC_OUTPUT
