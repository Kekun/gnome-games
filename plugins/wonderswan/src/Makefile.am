plugindir = $(libdir)/gnome-games/plugins
plugin_LTLIBRARIES = libgames-wonderswan-plugin.la

libgames_wonderswan_plugin_la_DEPENDENCIES = \
	$(top_builddir)/src/gnome-games.vapi \
	$(NULL)

libgames_wonderswan_plugin_la_SOURCES = \
	wonderswan-plugin.vala \
	$(NULL)

libgames_wonderswan_plugin_la_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--pkg gnome-games \
	--vapidir $(top_builddir)/src \
	$(NULL)

libgames_wonderswan_plugin_la_CFLAGS = \
	$(WONDERSWAN_PLUGIN_CFLAGS) \
	$(GNOME_GAMES_CFLAGS) \
	-DG_LOG_DOMAIN=\"GamesWonderSwan\" \
	-DLOCALEDIR=\"$(localedir)\" \
	$(NULL)

libgames_wonderswan_plugin_la_CPPFLAGS = \
	-I$(top_srcdir) \
	-I$(top_srcdir)/src \
	$(NULL)

libgames_wonderswan_plugin_la_LIBADD = \
	$(WONDERSWAN_PLUGIN_LIBS) \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

libgames_wonderswan_plugin_la_LDFLAGS = \
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
