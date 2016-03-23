top_pluginsrcdir = ..

gresource_file = $(top_pluginsrcdir)/data/mame.gresource.xml

resource_files = $(shell \
	$(GLIB_COMPILE_RESOURCES) \
	--generate-dependencies \
	--sourcedir=$(top_pluginsrcdir)/data \
	$(gresource_file) \
)

resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) \
	$(GLIB_COMPILE_RESOURCES) \
		--target=$@ \
		--sourcedir=$(top_pluginsrcdir)/data \
		--generate-source \
		$<

BUILT_SOURCES = \
	resources.c \
	$(NULL)

plugindir = $(libdir)/gnome-games/plugins
plugin_LTLIBRARIES = libgames-mame-plugin.la

libgames_mame_plugin_la_DEPENDENCIES = \
	$(top_builddir)/src/gnome-games.vapi \
	$(NULL)

libgames_mame_plugin_la_SOURCES = \
	mame-error.vala \
	mame-game.vala \
	mame-game-info.vala \
	mame-plugin.vala \
	$(BUILT_SOURCES) \
	$(NULL)

libgames_mame_plugin_la_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--pkg gnome-games \
	--pkg gio-2.0 \
	--pkg glib-2.0 \
	--pkg gtk+-3.0 \
	--pkg tracker-sparql-1.0 \
	--vapidir $(top_builddir)/src \
	--gresources $(gresource_file) \
	$(NULL)

libgames_mame_plugin_la_CFLAGS = \
	$(MAME_PLUGIN_CFLAGS) \
	$(GNOME_GAMES_CFLAGS) \
	-DG_LOG_DOMAIN=\"GamesMame\" \
	-DLOCALEDIR=\"$(localedir)\" \
	$(NULL)

libgames_mame_plugin_la_CPPFLAGS = \
	-I$(top_srcdir) \
	-I$(top_srcdir)/src \
	$(NULL)

libgames_mame_plugin_la_LIBADD = \
	$(MAME_PLUGIN_LIBS) \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

libgames_mame_plugin_la_LDFLAGS = \
	-no-undefined \
	-module \
	-avoid-version \
	$(NULL)

EXTRA_DIST = \
	$(plugin_DATA) \
	$(gresource_file) \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(BUILT_SOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
