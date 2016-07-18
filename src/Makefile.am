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
	command/command-error.vala \
	command/command-runner.vala \
	\
	core/cover.vala \
	core/game.vala \
	core/game-source.vala \
	core/icon.vala \
	core/plugin.vala \
	core/plugin-register.vala \
	core/plugin-registrar.vala \
	core/runner.vala \
	core/title.vala \
	core/uid.vala \
	\
	dummy/dummy-cover.vala \
	dummy/dummy-game.vala \
	dummy/dummy-game-source.vala \
	dummy/dummy-icon.vala \
	dummy/dummy-runner.vala \
	\
	gamepad/gamepad-callbacks.vala \
	gamepad/linux/linux-raw-gamepad.vala \
	gamepad/linux/linux-raw-gamepad-monitor.vala \
	gamepad/raw-gamepad.vala \
	gamepad/raw-gamepad-monitor.vala \
	\
	grilo/grilo-cover.vala \
	grilo/grilo-media.vala \
	\
	retro/retro-error.vala \
	retro/retro-log.vala \
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
	ui/empty-collection.vala \
	ui/error-info-bar.vala \
	ui/game-icon-view.vala \
	ui/game-thumbnail.vala \
	ui/header-bar.vala \
	ui/preferences-page.vala \
	ui/preferences-page-plugins.vala \
	ui/preferences-page-plugins-item.vala \
	ui/preferences-window.vala \
	ui/quit-dialog.vala \
	ui/remote-display.vala \
	ui/resume-dialog.vala \
	ui/search-bar.vala \
	ui/ui-state.vala \
	\
	utils/filename-title.vala \
	utils/fingerprint.vala \
	utils/generic-game.vala \
	utils/generic-title.vala \
	utils/generic-uid.vala \
	utils/grep.vala \
	\
	config.vala \
	credits.vala \
	main.vala \
	$(BUILT_SOURCES) \
	$(NULL)

gnome_games_VALAFLAGS = \
	--target-glib=@GLIB_MIN_VERSION@ \
	--vapidir=gamepad/linux/ \
	--pkg gio-2.0 \
	--pkg glib-2.0 \
	--pkg grilo-0.3 \
	--pkg gtk+-3.0 \
	--pkg tracker-sparql-1.0 \
	--pkg retro-gobject-0.6 \
	--pkg retro-gtk-0.6 \
	--pkg gudev-1.0 \
	--pkg libevdev \
	--pkg linux \
	--pkg posix \
	--gresources $(gresource_file) \
	--vapi $(vapi_file) \
	-H $(header_file) \
	$(NULL)

gnome_games_CFLAGS = \
	$(GNOME_GAMES_CFLAGS) \
	-DGNOMELOCALEDIR=\""$(datadir)/locale"\" \
	-DGAMES_PLUGINS_DIR=\"$(libdir)/gnome-games/plugins\" \
	$(NULL)

gnome_games_CPPFLAGS = \
	-DRETRO_GOBJECT_USE_UNSTABLE_API \
	-DRETRO_GTK_USE_UNSTABLE_API \
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
