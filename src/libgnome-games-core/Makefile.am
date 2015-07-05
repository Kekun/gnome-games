lib_LTLIBRARIES = libgnome-games-core.la

libgnome_games_core_la_SOURCES = \
	game.vala \
	dummy-game-source.vala \
	$(NULL)

libgnome_games_core_la_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--header=libgnome-games-core.h \
	--vapi=libgnome-games-core.vapi \
	$(NULL)

libgnome_games_core_la_CFLAGS = \
	$(LIBGNOME_GAMES_CFLAGS) \
	$(NULL)

libgnome_games_core_la_LIBADD = \
	$(LIBGNOME_GAMES_LIBS) \
	$(NULL)

MAINTAINERCLEANFILES = \
	libgnome-games-core.h \
	libgnome-games-core.vapi \
	$(NULL)

-include $(top_srcdir)/git.mk
