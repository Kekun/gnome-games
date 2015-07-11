AC_INIT([gnome-games], [3.17])
AM_INIT_AUTOMAKE([foreign subdir-objects])

AC_PROG_CC
AM_PROG_VALAC

# Libtool
LT_INIT

# GResource
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

# GSettings support
GLIB_GSETTINGS

GLIB_MIN_VERSION=2.38.0
AC_SUBST(GLIB_MIN_VERSION)

PKG_CHECK_MODULES(GNOME_GAMES, [
	glib-2.0 >= $GLIB_MIN_VERSION
	gio-unix-2.0
	gtk+-3.0
	tracker-sparql-1.0
])

AC_CONFIG_FILES([
  Makefile
  src/Makefile
  tests/Makefile
])

AC_OUTPUT

