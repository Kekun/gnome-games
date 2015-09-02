# hicolor icons
hicolor_icon16dir = $(datadir)/icons/hicolor/16x16/apps
hicolor_icon16_DATA = hicolor/16x16/apps/gnome-games.png
hicolor_icon22dir = $(datadir)/icons/hicolor/22x22/apps
hicolor_icon22_DATA = hicolor/22x22/apps/gnome-games.png
hicolor_icon24dir = $(datadir)/icons/hicolor/24x24/apps
hicolor_icon24_DATA = hicolor/24x24/apps/gnome-games.png
hicolor_icon32dir = $(datadir)/icons/hicolor/32x32/apps
hicolor_icon32_DATA = hicolor/32x32/apps/gnome-games.png
hicolor_icon48dir = $(datadir)/icons/hicolor/48x48/apps
hicolor_icon48_DATA = hicolor/48x48/apps/gnome-games.png
hicolor_icon256dir = $(datadir)/icons/hicolor/256x256/apps
hicolor_icon256_DATA = hicolor/256x256/apps/gnome-games.png
hicolor_iconscalabledir = $(datadir)/icons/hicolor/scalable/apps
hicolor_iconscalable_DATA = hicolor/scalable/apps/gnome-games-symbolic.svg
hicolor_icon_files = \
	$(hicolor_icon16_DATA) \
	$(hicolor_icon22_DATA) \
	$(hicolor_icon24_DATA) \
	$(hicolor_icon32_DATA) \
	$(hicolor_icon48_DATA) \
	$(hicolor_icon256_DATA) \
	$(hicolor_iconscalable_DATA) \
	icons/hicolor/gnome-games.svg

install-data-hook: update-icon-cache
uninstall-hook: update-icon-cache
update-icon-cache:
	@-if test -z "$(DESTDIR)"; then \
		echo "Updating Gtk hicolor icon cache."; \
		$(gtk_update_hicolor_icon_cache); \
	else \
		echo "*** Icon cache not updated.  After (un)install, run this:"; \
		echo "***   $(gtk_update_hicolor_icon_cache)"; \
	fi

EXTRA_DIST = \
	$(hicolor_icon_files) \
	$(NULL)

-include $(top_srcdir)/git.mk
