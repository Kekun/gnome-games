noinst_PROGRAMS = run

run_SOURCES = \
	libgnome-games-core/test-game.vala \
	run.vala \
	$(NULL)

run_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	$(top_builddir)/src/libgnome-games-core/libgnome-games-core.vapi \
	$(NULL)

run_CFLAGS = \
	$(LIBGNOME_GAMES_CFLAGS) \
	$(GNOME_GAMES_TESTS_CFLAGS) \
	-I$(top_srcdir)/src/libgnome-games-core
	$(NULL)

run_LDADD = \
	$(LIBGNOME_GAMES_LIBS) \
	$(GNOME_GAMES_TESTS_LIBS) \
	$(top_builddir)/src/libgnome-games-core/libgnome-games-core.la \
	$(NULL)

-include $(top_srcdir)/git.mk
