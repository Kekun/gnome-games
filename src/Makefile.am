bin_PROGRAMS = gnome-games

gresource_file = $(top_srcdir)/data/org.gnome.Games.gresource.xml

resource_files = $(shell \
	$(GLIB_COMPILE_RESOURCES) \
	--generate-dependencies \
	--sourcedir=$(top_srcdir)/data \
	$(gresource_file) \
)

resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) \
	$(GLIB_COMPILE_RESOURCES) \
		--target=$@ \
		--sourcedir=$(top_srcdir)/data \
		--generate-source \
		$<

BUILT_SOURCES = \
	resources.c \
	$(NULL)

EXTRA_DIST = \
	$(gresource_file) \
	$(NULL)

header_file = libgnome-games.h

vapi_file = gnome-games.vapi

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = $(vapi_file)

gnome_games_SOURCES = \
	command/command-runner.vala \
	\
	commodore/amiga-game.vala \
	commodore/amiga-tracker-query.vala \
	\
	core/game.vala \
	core/game-source.vala \
	core/runner.vala \
	\
	doom/doom-game.vala \
	doom/doom-tracker-query.vala \
	\
	dummy/dummy-game.vala \
	dummy/dummy-game-source.vala \
	dummy/dummy-runner.vala \
	\
	love/love-game.vala \
	love/love-tracker-query.vala \
	\
	desktop/desktop-game.vala \
	desktop/desktop-tracker-query.vala \
	\
	nec/pc-engine-game.vala \
	nec/pc-engine-tracker-query.vala \
	\
	nintendo/game-boy-game.vala \
	nintendo/game-boy-header.vala \
	nintendo/game-boy-tracker-query.vala \
	nintendo/game-boy-advance-game.vala \
	nintendo/game-boy-advance-tracker-query.vala \
	nintendo/game-cube-game.vala \
	nintendo/game-cube-header.vala \
	nintendo/game-cube-tracker-query.vala \
	nintendo/game-cube-uid.vala \
	nintendo/nes-game.vala \
	nintendo/nes-tracker-query.vala \
	nintendo/nintendo-64-game.vala \
	nintendo/nintendo-64-tracker-query.vala \
	nintendo/nintendo-ds-game.vala \
	nintendo/nintendo-ds-tracker-query.vala \
	nintendo/snes-game.vala \
	nintendo/snes-tracker-query.vala \
	nintendo/wii-game.vala \
	nintendo/wii-header.vala \
	nintendo/wii-tracker-query.vala \
	nintendo/wii-uid.vala \
	nintendo/wii-ware-game.vala \
	nintendo/wii-ware-tracker-query.vala \
	\
	retro/retro-log.vala \
	retro/retro-runner.vala \
	\
	sega/dreamcast-game.vala \
	sega/dreamcast-header.vala \
	sega/dreamcast-tracker-query.vala \
	sega/dreamcast-uid.vala \
	sega/master-system-game.vala \
	sega/master-system-header.vala \
	sega/master-system-tracker-query.vala \
	sega/mega-drive-game.vala \
	sega/mega-drive-header.vala \
	sega/mega-drive-tracker-query.vala \
	sega/sega-saturn-game.vala \
	sega/sega-saturn-header.vala \
	sega/sega-saturn-tracker-query.vala \
	sega/sega-saturn-uid.vala \
	\
	steam/steam-game.vala \
	steam/steam-game-source.vala \
	steam/steam-registry.vala \
	steam/steam-runner.vala \
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
	ui/empty-collection.vala \
	ui/error-info-bar.vala \
	ui/game-icon-view.vala \
	ui/game-thumbnail.vala \
	ui/header-bar.vala \
	ui/remote-display.vala \
	ui/resume-dialog.vala \
	ui/search-bar.vala \
	ui/ui-state.vala \
	\
	utils/fingerprint.vala \
	utils/grep.vala \
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
	--pkg libarchive \
	--pkg tracker-sparql-1.0 \
	--pkg retro-gobject-0.4 \
	--pkg retro-gtk-0.4 \
	--gresources $(gresource_file) \
	--vapi $(vapi_file) \
	-H $(header_file) \
	$(NULL)

gnome_games_CFLAGS = \
	$(GNOME_GAMES_CFLAGS) \
	$(NULL)

gnome_games_LDADD = \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

gnome_gamesincludedir = $(includedir)
gnome_gamesinclude_HEADERS = \
	$(header_file) \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(BUILT_SOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
