SUBDIRS = icons

appsdir = $(datadir)/applications
apps_DATA = org.gnome.Games.desktop

@INTLTOOL_DESKTOP_RULE@

EXTRA_DIST = \
	org.gnome.Games.desktop.in \
	$(NULL)

CLEANFILES = \
	$(apps_DATA) \
	$(NULL)

-include $(top_srcdir)/git.mk
