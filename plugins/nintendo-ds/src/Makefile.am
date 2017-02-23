plugindir = $(libdir)/gnome-games/plugins
plugin_LTLIBRARIES = libgames-nintendo-ds-plugin.la

libgames_nintendo_ds_plugin_la_DEPENDENCIES = \
	$(top_builddir)/src/gnome-games.vapi \
	$(NULL)

libgames_nintendo_ds_plugin_la_SOURCES = \
	nintendo-ds-icon.vala \
	nintendo-ds-icon-extract.c \
	nintendo-ds-plugin.vala \
	$(NULL)

libgames_nintendo_ds_plugin_la_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--pkg gnome-games \
	--vapidir $(top_builddir)/src \
	$(NULL)

libgames_nintendo_ds_plugin_la_CFLAGS = \
	$(NINTENDO_DS_PLUGIN_CFLAGS) \
	$(GNOME_GAMES_CFLAGS) \
	-DG_LOG_DOMAIN=\"GamesDesktop\" \
	-DLOCALEDIR=\"$(localedir)\" \
	$(NULL)

libgames_nintendo_ds_plugin_la_CPPFLAGS = \
	-I$(top_srcdir) \
	-I$(top_srcdir)/src \
	$(NULL)

libgames_nintendo_ds_plugin_la_LIBADD = \
	$(NINTENDO_DS_PLUGIN_LIBS) \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

libgames_nintendo_ds_plugin_la_LDFLAGS = \
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
