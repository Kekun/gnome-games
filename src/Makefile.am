bin_PROGRAMS = gnome-games

resource_file = $(top_srcdir)/data/org.gnome.Games.gresource.xml
resource_file_deps = $(shell \
	$(GLIB_COMPILE_RESOURCES) \
	--generate-dependencies \
	--sourcedir=$(top_srcdir)/data \
	$(resource_file) \
)

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
	core/game.vala \
	core/game-source.vala \
	core/runner.vala \
	\
	dummy/dummy-game.vala \
	dummy/dummy-game-source.vala \
	dummy/dummy-runner.vala \
	\
	desktop/desktop-game.vala \
	desktop/desktop-runner.vala \
	desktop/desktop-tracker-query.vala \
	\
	nintendo/game-boy-game.vala \
	nintendo/game-boy-tracker-query.vala \
	nintendo/game-boy-advance-game.vala \
	nintendo/game-boy-advance-tracker-query.vala \
	nintendo/nes-game.vala \
	nintendo/nes-tracker-query.vala \
	nintendo/snes-game.vala \
	nintendo/snes-tracker-query.vala \
	\
	retro/retro-runner.vala \
	\
	tracker/mime-type-tracker-query.vala \
	tracker/tracker-game-source.vala \
	tracker/tracker-query.vala \
	\
	ui/application.vala \
	ui/application-window.vala \
	ui/collection-icon-view.vala \
	ui/content-box.vala \
	ui/dummy-display.vala \
	ui/error-info-bar.vala \
	ui/game-icon-view.vala \
	ui/game-thumbnail.vala \
	ui/header-bar.vala \
	ui/remote-display.vala \
	ui/resume-dialog.vala \
	ui/ui-state.vala \
	\
	main.vala \
	$(BUILT_SOURCES) \
	$(NULL)

gnome_games_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--pkg gio-2.0 \
	--pkg gio-unix-2.0 \
	--pkg glib-2.0 \
	--pkg gtk+-3.0 \
	--pkg tracker-sparql-1.0 \
	--pkg retro-gobject-0.3 \
	--pkg retro-gtk-0.1 \
	--gresources $(resource_file) \
	$(NULL)

gnome_games_CFLAGS = \
	$(GNOME_GAMES_CFLAGS) \
	$(NULL)

gnome_games_LDADD = \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(BUILT_SOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
