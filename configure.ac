AC_INIT([gnome-games], [3.17])
AM_INIT_AUTOMAKE([foreign subdir-objects])

AC_PROG_CC
AM_PROG_VALAC
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

# Libtool
LT_INIT

# GResource
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

# GSettings support
GLIB_GSETTINGS

GLIB_MIN_VERSION=2.38.0
AC_SUBST(GLIB_MIN_VERSION)

PKG_CHECK_MODULES(LIBGNOME_GAMES, [
	glib-2.0 >= $GLIB_MIN_VERSION
])

PKG_CHECK_MODULES(GNOME_GAMES, [
  gtk+-3.0
])

PKG_CHECK_MODULES(GNOME_GAMES_TESTS, [
	gobject-2.0
])

AC_CONFIG_FILES([
  Makefile
  src/gnome-games/Makefile
  src/libgnome-games-core/Makefile
  src/Makefile
  tests/Makefile
])

AC_OUTPUT

