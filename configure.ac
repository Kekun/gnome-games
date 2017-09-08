AC_INIT([gnome-games], [3.26.0])
AM_INIT_AUTOMAKE([foreign subdir-objects tar-ustar no-dist-gzip dist-xz])

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
m4_include([plugins/desktop/configure.ac])
m4_include([plugins/dreamcast/configure.ac])
m4_include([plugins/game-cube/configure.ac])
m4_include([plugins/libretro/configure.ac])
m4_include([plugins/love/configure.ac])
m4_include([plugins/mame/configure.ac])
m4_include([plugins/nintendo-ds/configure.ac])
m4_include([plugins/playstation/configure.ac])
m4_include([plugins/sega-cd/configure.ac])
m4_include([plugins/sega-saturn/configure.ac])
m4_include([plugins/steam/configure.ac])
m4_include([plugins/turbografx-cd/configure.ac])
m4_include([plugins/wii/configure.ac])

PKG_CHECK_MODULES(GNOME_GAMES, [
	gio-2.0
	glib-2.0 >= $GLIB_MIN_VERSION
	grilo-0.3
	gtk+-3.0
	librsvg-2.0
	libsoup-2.4
	libxml-2.0
	retro-gtk-0.12
	sqlite3
	tracker-sparql-2.0
])

PKG_CHECK_MODULES(GAMEPADS, [
	libevdev
], [enable_gamepads=yes], [enable_gamepads=no])
AM_CONDITIONAL([ENABLE_GAMEPADS], [test x$enable_gamepads != xno])

enable_udev=no
if test x$enable_gamepads = xyes ; then
	PKG_CHECK_MODULES(UDEV, [
		gudev-1.0
	], [enable_udev=yes], [enable_udev=no])
fi
AM_CONDITIONAL([ENABLE_UDEV], [test x$enable_udev = xyes])

AC_CONFIG_FILES([
	Makefile
	data/Makefile
	data/icons/Makefile
	plugins/Makefile
	po/Makefile.in
	src/Makefile
])

AC_OUTPUT
