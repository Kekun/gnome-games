bin_PROGRAMS = gnome-games

resource_file = $(top_srcdir)/data/org.gnome.Games.gresource.xml
resource_file_deps = $(shell $(GLIB_COMPILE_RESOURCES) \
                             --generate-dependencies \
                             --sourcedir=$(top_srcdir)/data \
                             $(resource_file))

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
	$(BUILT_SOURCES) \
	main.vala \
	$(NULL)

gnome_games_VALAFLAGS = \
	--pkg gtk+-3.0 \
	--gresources $(resource_file) \
	$(NULL)

gnome_games_CFLAGS = \
	$(GNOME_GAMES_CFLAGS) \
	$(NULL)

gnome_games_LDADD = \
	$(GNOME_GAMES_LIBS) \
	$(NULL)

-include $(top_srcdir)/git.mk
