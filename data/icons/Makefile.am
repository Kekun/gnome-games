# hicolor icons
hicolor_icon16dir = $(datadir)/icons/hicolor/16x16/apps
hicolor_icon16_DATA = hicolor/16x16/apps/org.gnome.Games.png
hicolor_icon22dir = $(datadir)/icons/hicolor/22x22/apps
hicolor_icon22_DATA = hicolor/22x22/apps/org.gnome.Games.png
hicolor_icon24dir = $(datadir)/icons/hicolor/24x24/apps
hicolor_icon24_DATA = hicolor/24x24/apps/org.gnome.Games.png
hicolor_icon32dir = $(datadir)/icons/hicolor/32x32/apps
hicolor_icon32_DATA = hicolor/32x32/apps/org.gnome.Games.png
hicolor_icon48dir = $(datadir)/icons/hicolor/48x48/apps
hicolor_icon48_DATA = hicolor/48x48/apps/org.gnome.Games.png
hicolor_icon256dir = $(datadir)/icons/hicolor/256x256/apps
hicolor_icon256_DATA = hicolor/256x256/apps/org.gnome.Games.png
hicolor_icon512dir = $(datadir)/icons/hicolor/512x512/apps
hicolor_icon512_DATA = hicolor/512x512/apps/org.gnome.Games.png
hicolor_iconscalabledir = $(datadir)/icons/hicolor/scalable/apps
hicolor_iconscalable_DATA = hicolor/scalable/apps/org.gnome.Games-symbolic.svg
hicolor_icon_files = \
	$(hicolor_icon16_DATA) \
	$(hicolor_icon22_DATA) \
	$(hicolor_icon24_DATA) \
	$(hicolor_icon32_DATA) \
	$(hicolor_icon48_DATA) \
	$(hicolor_icon256_DATA) \
	$(hicolor_icon512_DATA) \
	$(hicolor_iconscalable_DATA) \
	hicolor/org.gnome.Games.svg

hicontrast_icon16dir = $(datadir)/icons/HighContrast/16x16/apps
hicontrast_icon16_DATA = HighContrast/16x16/apps/org.gnome.Games.png
hicontrast_icon22dir = $(datadir)/icons/HighContrast/22x22/apps
hicontrast_icon22_DATA = HighContrast/22x22/apps/org.gnome.Games.png
hicontrast_icon24dir = $(datadir)/icons/HighContrast/24x24/apps
hicontrast_icon24_DATA = HighContrast/24x24/apps/org.gnome.Games.png
hicontrast_icon32dir = $(datadir)/icons/HighContrast/32x32/apps
hicontrast_icon32_DATA = HighContrast/32x32/apps/org.gnome.Games.png
hicontrast_icon48dir = $(datadir)/icons/HighContrast/48x48/apps
hicontrast_icon48_DATA = HighContrast/48x48/apps/org.gnome.Games.png
hicontrast_icon256dir = $(datadir)/icons/HighContrast/256x256/apps
hicontrast_icon256_DATA = HighContrast/256x256/apps/org.gnome.Games.png
hicontrast_icon512dir = $(datadir)/icons/HighContrast/512x512/apps
hicontrast_icon512_DATA = HighContrast/512x512/apps/org.gnome.Games.png
hicontrast_icon_files = \
	$(hicontrast_icon16_DATA) \
	$(hicontrast_icon22_DATA) \
	$(hicontrast_icon24_DATA) \
	$(hicontrast_icon32_DATA) \
	$(hicontrast_icon48_DATA) \
	$(hicontrast_icon256_DATA) \
	$(hicontrast_icon512_DATA) \
	HighContrast/org.gnome.Games.svg

gtk_update_hicontrast_icon_cache = gtk-update-icon-cache -f -t $(datadir)/icons/HighContrast

install-data-hook: update-icon-cache
uninstall-hook: update-icon-cache
update-icon-cache:
	@-if test -z "$(DESTDIR)"; then \
		echo "Updating Gtk hicolor icon cache."; \
		$(gtk_update_hicolor_icon_cache); \
		echo "Updating Gtk highcontrast icon cache."; \
		$(gtk_update_hicontrast_icon_cache); \
	else \
		echo "*** Icon cache not updated.  After (un)install, run this:"; \
		echo "***   $(gtk_update_hicolor_icon_cache)"; \
		echo "***   $(gtk_update_hicontrast_icon_cache)"; \
	fi

EXTRA_DIST = \
	$(hicolor_icon_files) \
	$(hicontrast_icon_files) \
	$(NULL)

-include $(top_srcdir)/git.mk
