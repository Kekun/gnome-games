plugindir = $(libdir)/gnome-games/plugins
plugin_LTLIBRARIES = libgames-playstation-plugin.la

libgames_playstation_plugin_la_DEPENDENCIES = \
	$(top_builddir)/src/gnome-games.vapi \
	$(NULL)

libgames_playstation_plugin_la_SOURCES = \
	playstation-error.vala \
	playstation-header.vala \
	playstation-plugin.vala \
	playstation-uid.vala \
	$(NULL)

libgames_playstation_plugin_la_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--pkg gnome-games \
	--pkg gio-2.0 \
	--pkg glib-2.0 \
	--pkg gtk+-3.0 \
	--pkg tracker-sparql-1.0 \
	--vapidir $(top_builddir)/src \
	$(NULL)

libgames_playstation_plugin_la_CFLAGS = \
	$(PLAYSTATION_PLUGIN_CFLAGS) \
	$(GNOME_GAMES_CFLAGS) \
	-DG_LOG_DOMAIN=\"GamesPlayStation\" \
	-DLOCALEDIR=\"$(localedir)\" \
	$(NULL)

libgames_playstation_plugin_la_CPPFLAGS = \
	-I$(top_srcdir) \
	-I$(top_srcdir)/src \
	$(NULL)

libgames_playstation_plugin_la_LIBADD = \
	$(PLAYSTATION_PLUGIN_LIBS) \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

libgames_playstation_plugin_la_LDFLAGS = \
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
