SUBDIRS = \
	src \
	tests \
	$(NULL)

check: tests/run
	tests/run

MAINTAINERCLEANFILES = \
	$(GITIGNORE_MAINTAINERCLEANFILES_TOPLEVEL) \
	$(GITIGNORE_MAINTAINERCLEANFILES_MAKEFILE_IN) \
	$(NULL)

-include $(top_srcdir)/git.mk
