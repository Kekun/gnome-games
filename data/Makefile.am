SUBDIRS = icons

appdatadir = $(datadir)/appdata
appdata_in_files = org.gnome.Games.appdata.xml.in
appdata_DATA = $(appdata_in_files:.appdata.xml.in=.appdata.xml)
@INTLTOOL_XML_RULE@

desktopdir = $(datadir)/applications
desktop_in_files = org.gnome.Games.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

EXTRA_DIST = \
	$(appdata_in_files) \
	$(desktop_in_files) \
	gtk/menus.ui \
	ui/dummy-display.ui \
	ui/empty-collection.ui \
	ui/header-bar.ui \
	ui/quit-dialog.ui \
	ui/remote-display.ui \
	ui/resume-dialog.ui \
	$(NULL)

CLEANFILES = \
	$(appdata_DATA) \
	$(desktop_DATA) \
	$(NULL)

-include $(top_srcdir)/git.mk
