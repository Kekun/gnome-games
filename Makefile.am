# FIXME 'plugins' have to be after 'src' as the plugins depend on the
# produced VAPI file and dependency tracking doesn't work as expected.
SUBDIRS = data po src plugins

MAINTAINERCLEANFILES = \
	$(GITIGNORE_MAINTAINERCLEANFILES_TOPLEVEL) \
	$(GITIGNORE_MAINTAINERCLEANFILES_MAKEFILE_IN) \
	$(NULL)

gameinfo-deduplicate-titles:
	python3 $(top_srcdir)/tools/gameinfo/gameinfo-deduplicate-titles `find $(top_srcdir) -name gameinfo.ini`

gameinfo-sort:
	python3 $(top_srcdir)/tools/gameinfo/gameinfo-sort `find $(top_srcdir) -name gameinfo.ini`

gameinfo-update:
	python3 $(top_srcdir)/tools/gameinfo/gameinfo-update `find $(top_srcdir) -name gameinfo.ini`

.PHONY: gameinfo-deduplicate-titles gameinfo-sort gameinfo-update

-include $(top_srcdir)/git.mk
