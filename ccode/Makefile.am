smartsimdir=$(bindir)
smartsim_PROGRAMS=smartsim
smartsim_SOURCES= \
	annotation.c \
	basicdialog.c \
	circuitinformation.c \
	compiledcircuit.c \
	componentdef.c \
	componentinst.c \
	componentstate.c \
	connection.c \
	customiser.c \
	designer.c \
	designerwindow.c \
	graphic.c \
	imageexporter.c \
	logic.c \
	path.c \
	pindef.c \
	pininst.c \
	project.c \
	propertiesquery.c \
	propertyitem.c \
	simulatorwindow.c \
	tag.c \
	timingdiagram.c \
	updatequeue.c \
	wireinst.c \
	wirestate.c \
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
	componentdef/def-reader.c \
	componentdef/def-t-flipflop.c \
	componentdef/def-toggle.c \
	componentdef/def-tristate.c \
	componentdef/def-xor.c \
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
	propertyitem/propertyitem-double.c \
	propertyitem/propertyitem-file.c \
	propertyitem/propertyitem-int.c \
	propertyitem/propertyitem-propertyset.c \
	propertyitem/propertyitem-selection.c \
	propertyitem/propertyitem-string.c

# Note that PACKAGE_DATADIR MUST have ending "/"

DEF_CFLAGS =                                 \
	-DPACKAGE_DATADIR=\"$(pkgdatadir)/\"    \
	-DPACKAGE_VERSION=\"$(VERSION)\"        

smartsim_LDADD= $(GLIB_LIBS) $(GTK_LIBS) $(CAIRO_LIBS) $(LIBRSVG_LIBS) $(LIBXML_LIBS)
smartsim_CFLAGS= $(GLIB_CFLAGS) $(GTK_CFLAGS) $(CAIRO_CFLAGS) $(LIBRSVG_CFLAGS) $(LIBXML_CFLAGS) $(DEF_CFLAGS)
