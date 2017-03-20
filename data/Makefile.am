SUBDIRS = icons

appdatadir = $(datadir)/appdata
appdata_in_files = org.gnome.Games.appdata.xml.in
appdata_DATA = $(appdata_in_files:.appdata.xml.in=.appdata.xml)
@INTLTOOL_XML_RULE@

desktopdir = $(datadir)/applications
desktop_in_files = org.gnome.Games.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

gsettings_SCHEMAS = org.gnome.Games.gschema.xml
@GSETTINGS_RULES@

EXTRA_DIST = \
	$(appdata_in_files) \
	$(desktop_in_files) \
	$(gsettings_SCHEMAS) \
	appdata/games-collection.png \
	appdata/games-search.png \
	appdata/resume-game.png \
	appdata/retro-ingame.png \
	gamepads/gamecontrollerdb.txt \
	gtk/menus.ui \
	gtk-style.css \
	ui/application-window.ui \
	ui/collection-box.ui \
	ui/collection-header-bar.ui \
	ui/collection-icon-view.ui \
	ui/content-box.ui \
	ui/display-box.ui \
	ui/display-header-bar.ui \
	ui/dummy-display.ui \
	ui/empty-collection.ui \
	ui/error-display.ui \
	ui/error-info-bar.ui \
	ui/game-icon-view.ui \
	ui/media-menu-button.ui \
	ui/media-selector.ui \
	ui/preferences-page-plugins-item.ui \
	ui/preferences-page-plugins.ui \
	ui/preferences-page-video.ui \
	ui/preferences-switch-item.ui \
	ui/preferences-window.ui \
	ui/quit-dialog.ui \
	ui/remote-display.ui \
	ui/resume-dialog.ui \
	ui/resume-failed-dialog.ui \
	ui/search-bar.ui \
	$(NULL)

CLEANFILES = \
	$(appdata_DATA) \
	$(desktop_DATA) \
	$(NULL)

-include $(top_srcdir)/git.mk
