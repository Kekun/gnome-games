check_PROGRAMS = run

run_SOURCES = \
	core/game-test.vala \
	\
	test-case.vala \
	run.vala \
	$(NULL)

run_VALAFLAGS = \
	--target-glib=$GLIB_MIN_VERSION \
	--pkg gio-unix-2.0 \
	--pkg gtk+-3.0 \
	--pkg tracker-sparql-1.0 \
	$(top_builddir)/src/libgnome-games.vapi \
	$(NULL)

-include $(top_srcdir)/git.mk

