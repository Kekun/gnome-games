plugindir = $(libdir)/gnome-games/plugins
plugin_LTLIBRARIES = libgames-sega-cd-plugin.la

libgames_sega_cd_plugin_la_DEPENDENCIES = \
	$(top_builddir)/src/gnome-games.vapi \
	$(NULL)

libgames_sega_cd_plugin_la_SOURCES = \
	sega-cd-header.vala \
	sega-cd-plugin.vala \
	sega-cd-system.vala \
	$(NULL)

libgames_sega_cd_plugin_la_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--pkg gnome-games \
	--vapidir $(top_builddir)/src \
	$(NULL)

libgames_sega_cd_plugin_la_CFLAGS = \
	$(SEGA_CD_PLUGIN_CFLAGS) \
	$(GNOME_GAMES_CFLAGS) \
	-DG_LOG_DOMAIN=\"GamesSegaCD\" \
	-DLOCALEDIR=\"$(localedir)\" \
	$(NULL)

libgames_sega_cd_plugin_la_CPPFLAGS = \
	-I$(top_srcdir) \
	-I$(top_srcdir)/src \
	$(NULL)

libgames_sega_cd_plugin_la_LIBADD = \
	$(SEGA_CD_PLUGIN_LIBS) \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

libgames_sega_cd_plugin_la_LDFLAGS = \
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
