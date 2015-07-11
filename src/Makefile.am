lib_LTLIBRARIES = libgnome-games.la

libgnome_games_la_SOURCES = \
	core/game-source.vala \
	core/game.vala \
	\
	desktop/desktop-game-source.vala \
	\
	ui/application.vala \
	ui/app-window.vala \
	$(NULL)

libgnome_games_la_VALAFLAGS = \
	--target-glib=$GLIB_MIN_VERSION \
	--pkg gio-unix-2.0 \
	--pkg gtk+-3.0 \
	--pkg tracker-sparql-1.0 \
	--header=libgnome-games.h \
	--vapi=libgnome-games.vapi \
	$(NULL)

libgnome_games_la_CFLAGS = \
	$(GNOME_GAMES_CFLAGS) \
	$(NULL)

libgnome_games_la_LIBADD = \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

#libgnome-games.vapi libgnome-games.h: libgnome_games_la_vala.stamp

bin_PROGRAMS = gnome-games

resource_file = $(top_srcdir)/data/org.gnome.Games.gresource.xml
resource_file_deps = $(shell $(GLIB_COMPILE_RESOURCES) \
                             --generate-dependencies \
                             --sourcedir=$(top_srcdir)/data \
                             $(resource_file))

resources.c: $(resource_file) $(resource_file_deps)
	$(GLIB_COMPILE_RESOURCES) \
		--target=$@ \
		--sourcedir=$(top_srcdir)/data \
		--generate-source \
		$<

BUILT_SOURCES = \
	resources.c \
	$(NULL)

gnome_games_SOURCES = \
	main.vala \
	$(BUILT_SOURCES) \
	$(NULL)

gnome_games_VALAFLAGS = \
	--target-glib=$GLIB_MIN_VERSION \
	--pkg gio-unix-2.0 \
	--pkg gtk+-3.0 \
	--pkg tracker-sparql-1.0 \
	--gresources $(resource_file) \
	$(top_builddir)/src/libgnome-games.vapi \
	$(NULL)

gnome_games_CFLAGS = \
	$(GNOME_GAMES_CFLAGS) \
	$(NULL)

gnome_games_LDADD = \
	$(GNOME_GAMES_LIBS) \
	libgnome-games.la \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(BUILT_SOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
