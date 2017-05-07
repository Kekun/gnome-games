plugindir = $(libdir)/gnome-games/plugins
plugin_LTLIBRARIES = libgames-libretro-plugin.la

libgames_libretro_plugin_la_DEPENDENCIES = \
	$(top_builddir)/src/gnome-games.vapi \
	$(NULL)

libgames_libretro_plugin_la_SOURCES = \
	libretro-error.vala \
	libretro-icon.vala \
	libretro-plugin.vala \
	libretro-title.vala \
	libretro-uid.vala \
	libretro-uri-iterator.vala \
	libretro-uri-source.vala \
	$(NULL)

libgames_libretro_plugin_la_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--pkg gnome-games \
	--vapidir $(top_builddir)/src \
	$(NULL)

libgames_libretro_plugin_la_CFLAGS = \
	$(LIBRETRO_PLUGIN_CFLAGS) \
	$(GNOME_GAMES_CFLAGS) \
	-DG_LOG_DOMAIN=\"GamesLibretro\" \
	-DLOCALEDIR=\"$(localedir)\" \
	$(NULL)

libgames_libretro_plugin_la_CPPFLAGS = \
	-I$(top_srcdir) \
	-I$(top_srcdir)/src \
	$(NULL)

libgames_libretro_plugin_la_LIBADD = \
	$(LIBRETRO_PLUGIN_LIBS) \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

libgames_libretro_plugin_la_LDFLAGS = \
	-no-undefined \
	-module \
	-avoid-version \
	$(NULL)

EXTRA_DIST = \
	$(plugin_DATA) \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(BUILT_SOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
