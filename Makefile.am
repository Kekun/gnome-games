# FIXME 'plugins' have to be after 'src' as the plugins depend on the
# produced VAPI file and dependency tracking doesn't work as expected.
SUBDIRS = data po src plugins

MAINTAINERCLEANFILES = \
	$(GITIGNORE_MAINTAINERCLEANFILES_TOPLEVEL) \
	$(GITIGNORE_MAINTAINERCLEANFILES_MAKEFILE_IN) \
	.flatpak-builder \
	$(NULL)

-include $(top_srcdir)/git.mk
