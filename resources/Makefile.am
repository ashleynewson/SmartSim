NOTHING=

smartsimdatadir=$(pkgdatadir)

componentsdir=$(smartsimdatadir)/components
componentsgraphicsdir=$(componentsdir)/graphics
componentsiconsdir=$(componentsdir)/icons
componentsinfodir=$(componentsdir)/info

imagesdir=$(smartsimdatadir)/images
imagesgraphicsdir=$(imagesdir)/graphics
imagesiconsdir=$(imagesdir)/icons
imagestoolbardir=$(imagesdir)/toolbar

pluginsdir=$(smartsimdatadir)/plugins

smartsimdata_DATA= \
	./COPYING \
	./smartsim.ico \
	$(NOTHING)

if ENABLE_PLUGINS
plugins_DATA= \
	./plugins/gpiopin.info \
	./plugins/gpiopin.ssx \
	./plugins/gpiopin.svg \
	$(NOTHING)
else
plugins_DATA=
endif

componentsgraphics_DATA= \
	./components/graphics/and.info \
	./components/graphics/and.svg \
	./components/graphics/buffer.info \
	./components/graphics/buffer.svg \
	./components/graphics/or.info \
	./components/graphics/or.svg \
	./components/graphics/reader.info \
	./components/graphics/reader.svg \
	./components/graphics/ss-display.info \
	./components/graphics/ss-display.svg \
	./components/graphics/toggle.info \
	./components/graphics/toggle.svg \
	./components/graphics/tristate.info \
	./components/graphics/tristate.svg \
	./components/graphics/xor.info \
	./components/graphics/xor.svg \
	$(NOTHING)

componentsicons_DATA= \
	./components/icons/and.png \
	./components/icons/buffer.png \
	./components/icons/clock.png \
	./components/icons/constant.png \
	./components/icons/memory.png \
	./components/icons/multiplexer.png \
	./components/icons/or.png \
	./components/icons/pe-d-flipflop.png \
	./components/icons/reader.png \
	./components/icons/ss-display.png \
	./components/icons/t-flipflop.png \
	./components/icons/toggle.png \
	./components/icons/tristate.png \
	./components/icons/xor.png \
	$(NOTHING)

componentsinfo_DATA= \
	./components/info/and.xml \
	./components/info/basic-ss-display.xml \
	./components/info/buffer.xml \
	./components/info/clock.xml \
	./components/info/constant.xml \
	./components/info/memory.xml \
	./components/info/multiplexer.xml \
	./components/info/or.xml \
	./components/info/pe-d-flipflop.xml \
	./components/info/reader.xml \
	./components/info/t-flipflop.xml \
	./components/info/toggle.xml \
	./components/info/tristate.xml \
	./components/info/xor.xml \
	$(NOTHING)

imagesgraphics_DATA= \
	./images/graphics/placeholder.info \
	./images/graphics/placeholder.svg \
	$(NOTHING)

imagesicons_DATA= \
	./images/icons/smartsim16.png \
	./images/icons/smartsim64.png \
	$(NOTHING)

imagestoolbar_DATA= \
	./images/toolbar/adjust.png \
	./images/toolbar/annotate.png \
	./images/toolbar/bind.png \
	./images/toolbar/context.png \
	./images/toolbar/cursor.png \
	./images/toolbar/custom.png \
	./images/toolbar/cycledelay.png \
	./images/toolbar/delete.png \
	./images/toolbar/explore.png \
	./images/toolbar/fastest.png \
	./images/toolbar/interact.png \
	./images/toolbar/invert.png \
	./images/toolbar/move.png \
	./images/toolbar/multistep.png \
	./images/toolbar/orientate.png \
	./images/toolbar/pin.png \
	./images/toolbar/plugin.png \
	./images/toolbar/run.png \
	./images/toolbar/scroll.png \
	./images/toolbar/shrink.png \
	./images/toolbar/singlestep.png \
	./images/toolbar/tag.png \
	./images/toolbar/watch.png \
	./images/toolbar/wire.png \
	./images/toolbar/zoom.png \
	$(NOTHING)

# install-data-hook:
# 	cd $(DESTDIR)$(pkgdatadir); \
# 	cat $(RESOURCES_TAR) | $(TAR) --list > uninstall_manifest.txt; \
# 	cat $(RESOURCES_TAR) | $(TAR) --no-same-owner --extract; \
# 	rm --force $(RESOURCES_TAR); \
# 	cat uninstall_manifest.txt | sed --expression='s/^\|$$/"/g' | xargs chmod a=rX,u+w
