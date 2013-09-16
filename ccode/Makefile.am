NOTHING=

smartsimdir=$(bindir)
smartsim_PROGRAMS=smartsim

smartsim_SOURCES= \
	main.c \
	annotation.c \
	basicdialog.c \
	circuitinformation.c \
	compiledcircuit.c \
	componentdef.c \
	componentdef/def-and.c \
	componentdef/def-basic-ss-display.c \
	componentdef/def-buffer.c \
	componentdef/def-clock.c \
	componentdef/def-constant.c \
	componentdef/def-custom.c \
	componentdef/def-memory.c \
	componentdef/def-multiplexer.c \
	componentdef/def-or.c \
	componentdef/def-pe-d-flipflop.c \
	componentdef/def-plugin.c \
	componentdef/def-reader.c \
	componentdef/def-t-flipflop.c \
	componentdef/def-toggle.c \
	componentdef/def-tristate.c \
	componentdef/def-xor.c \
	componentstate.c \
	componentstate/state-and.c \
	componentstate/state-basic-ss-display.c \
	componentstate/state-buffer.c \
	componentstate/state-clock.c \
	componentstate/state-constant.c \
	componentstate/state-memory.c \
	componentstate/state-multiplexer.c \
	componentstate/state-or.c \
	componentstate/state-pe-d-flipflop.c \
	componentstate/state-reader.c \
	componentstate/state-t-flipflop.c \
	componentstate/state-toggle.c \
	componentstate/state-tristate.c \
	componentstate/state-xor.c \
	componentinst.c \
	connection.c \
	customiser.c \
	designer.c \
	designerwindow.c \
	graphic.c \
	imageexporter.c \
	path.c \
	pindef.c \
	pininst.c \
	plugincomponentmanager.c \
	project.c \
	propertiesquery.c \
	propertyitem.c \
	propertyitem/propertyitem-double.c \
	propertyitem/propertyitem-file.c \
	propertyitem/propertyitem-int.c \
	propertyitem/propertyitem-propertyset.c \
	propertyitem/propertyitem-selection.c \
	propertyitem/propertyitem-string.c \
	simulatorwindow.c \
	tag.c \
	wireinst.c \
	wirestate.c \
	timingdiagram.c \
	updatequeue.c \
	$(NOTHING)

# Note that PACKAGE_DATADIR MUST have ending "/"

DEF_CFLAGS= \
	-DPACKAGE_DATADIR=\"$(pkgdatadir)/\" \
	-DPACKAGE_LIBDIR=\"$(pkglibdir)/\" \
	-DPACKAGE_VERSION=\"$(VERSION)\" \
	$(NOTHING)

smartsim_LDADD= \
	$(GLIB_LIBS) \
	$(GTK_LIBS) \
	$(CAIRO_LIBS) \
	$(LIBRSVG_LIBS) \
	$(LIBXML_LIBS) \
	$(NOTHING)
smartsim_CFLAGS= \
	$(GLIB_CFLAGS) \
	$(GTK_CFLAGS) \
	$(CAIRO_CFLAGS) \
	$(LIBRSVG_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(DEF_CFLAGS) \
	$(NOTHING)
