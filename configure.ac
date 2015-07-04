AC_INIT([gnome-games], [3.17])
AM_INIT_AUTOMAKE([foreign])

AC_PROG_CC
AM_PROG_VALAC
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

PKG_CHECK_MODULES(GNOME_GAMES, [
  gtk+-3.0
])

AC_CONFIG_FILES([
  Makefile
  src/Makefile
])

AC_OUTPUT

