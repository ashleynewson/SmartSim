smartsimdatadir=$(pkgdatadir)
RESOURCES_TAR= resources.tar
smartsimdata_DATA= $(RESOURCES_TAR)

install-data-hook:
	cd $(DESTDIR)$(pkgdatadir); \
    cat $(RESOURCES_TAR) | $(TAR) --list > uninstall_manifest.txt; \
    cat $(RESOURCES_TAR) | $(TAR) --no-same-owner --extract; \
    rm --force $(RESOURCES_TAR); \
    cat uninstall_manifest.txt | sed --expression='s/^\|$$/"/g' | xargs chmod a=rX,u+w
