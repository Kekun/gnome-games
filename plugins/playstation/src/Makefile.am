plugindir = $(libdir)/gnome-games/plugins
plugin_LTLIBRARIES = libgames-playstation-plugin.la

gameinfo_in_file = $(top_srcdir)/plugins/playstation/data/playstation.gameinfo.xml.in
gameinfo_file = $(builddir)/playstation.gameinfo.xml

$(gameinfo_file): $(gameinfo_in_file)
	sed -e 's/<_title>/<title>/' $^ | sed -e 's/<\/_title>/<\/title>/' > $@

gresource_file = $(top_srcdir)/plugins/playstation/data/org.gnome.Games.plugin.playstation.gresource.xml

resource_files = $(shell \
	$(GLIB_COMPILE_RESOURCES) \
	--generate-dependencies \
	--sourcedir=$(top_srcdir)/plugins/playstation/data \
	--sourcedir=$(builddir) \
	$(gresource_file) \
)

resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) \
	$(GLIB_COMPILE_RESOURCES) \
		--target=$@ \
		--sourcedir=$(top_srcdir)/plugins/playstation/data \
		--sourcedir=$(builddir) \
		--generate-source \
		$<

BUILT_SOURCES = \
	resources.c \
	$(NULL)

libgames_playstation_plugin_la_DEPENDENCIES = \
	$(top_builddir)/src/gnome-games.vapi \
	$(NULL)

libgames_playstation_plugin_la_SOURCES = \
	$(BUILT_SOURCES) \
	disc-file-info.c \
	disc-image.c \
	disc-image-time.c \
	playstation-disc-image.c \
	playstation-error.vala \
	playstation-game-factory.vala \
	playstation-header.vala \
	playstation-plugin.vala \
	playstation-uid.vala \
	$(NULL)

libgames_playstation_plugin_la_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--pkg gnome-games \
	--gresources $(gresource_file) \
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
	$(gresource_file) \
	disc-image.h \
	disc-file-info.h \
	disc-image-time.h \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(BUILT_SOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
