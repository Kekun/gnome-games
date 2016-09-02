SUBDIRS = data src

gameinfo_dir = $(top_srcdir)/tools/gameinfo
tmp_gameinfo_doc = $(gameinfo_dir)/out/playstation.gameinfo.xml.in.tmp
gameinfo_doc = $(srcdir)/data/playstation.gameinfo.xml.in

update-gameinfo:
	$(gameinfo_dir)/psxdatacenter-gameinfo.py
	$(gameinfo_dir)/sort.py $(gameinfo_doc)
	$(gameinfo_dir)/merge.py $(tmp_gameinfo_doc) $(gameinfo_doc) $(gameinfo_doc)

.PHONY: update-gameinfo

include $(top_srcdir)/git.mk
