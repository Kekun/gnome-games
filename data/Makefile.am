SUBDIRS = icons

desktopdir = $(datadir)/applications
desktop_in_files = org.gnome.Games.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

EXTRA_DIST = \
	$(desktop_in_files) \
	$(NULL)

CLEANFILES = \
	$(desktop_DATA) \
	$(NULL)

-include $(top_srcdir)/git.mk
