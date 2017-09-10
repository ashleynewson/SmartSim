#Makefile for SmartSim.

#Note, the windows make does not work as is. A lengthy manual process is currently used in c/Makefile.

NOTHING=

VALAC=valac

VAPIDIR=/usr/share/vala-0.16/vapi/

WINCC=i586-mingw32msvc-cc

WINCC_PATH_FLAGS= \
	-I/usr/i586-mingw32msvc/include/glib-2.0 \
	-I/usr/i586-mingw32msvc/lib/glib-2.0/include \
	-I/usr/i586-mingw32msvc/include/gtk-2.0 \
	-I/usr/i586-mingw32msvc/lib/gtk-2.0/include \
	-I/usr/i586-mingw32msvc/include/atk-1.0 \
	-I/usr/i586-mingw32msvc/include/cairo \
	-I/usr/i586-mingw32msvc/include/pango-1.0 \
	-I/usr/i586-mingw32msvc/include/freetype2 \
	-I/usr/i586-mingw32msvc/include \
	-I/usr/i586-mingw32msvc/include/libpng14 \
	-I/usr/i586-mingw32msvc/include/librsvg-2.0 \
	-L/usr/i586-mingw32msvc/lib \
	$(NOTHING)

C_FILES_ROOT= \
	main.c \
	annotation.c \
	basicdialog.c \
	circuitinformation.c \
	compiledcircuit.c \
	componentdef.c \
	componentstate.c \
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
	simulatorwindow.c \
	tag.c \
	wireinst.c \
	wirestate.c \
	timingdiagram.c \
	uicommon.c \
	updatequeue.c \
	$(NOTHING)

C_FILES_COMPONENTDEF= \
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
	$(NOTHING)

C_FILES_COMPONENTSTATE= \
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
	$(NOTHING)

C_FILES_PROPERTYITEM= \
	propertyitem/propertyitem-double.c \
	propertyitem/propertyitem-file.c \
	propertyitem/propertyitem-int.c \
	propertyitem/propertyitem-propertyset.c \
	propertyitem/propertyitem-selection.c \
	propertyitem/propertyitem-string.c \
	$(NOTHING)

C_FILES= \
	$(C_FILES_ROOT) \
	$(C_FILES_COMPONENTDEF) \
	$(C_FILES_COMPONENTSTATE) \
	$(C_FILES_PLUGINDEF) \
	$(C_FILES_PLUGINSTATE) \
	$(C_FILES_PROPERTYITEM) \
	$(NOTHING)

SOURCE_FILES= \
	main.vala \
	annotation.vala \
	basicdialog.vala \
	circuitinformation.vala \
	compiledcircuit.vala \
	componentdef.vala \
	componentdef/def-and.vala \
	componentdef/def-basic-ss-display.vala \
	componentdef/def-buffer.vala \
	componentdef/def-clock.vala \
	componentdef/def-constant.vala \
	componentdef/def-custom.vala \
	componentdef/def-memory.vala \
	componentdef/def-multiplexer.vala \
	componentdef/def-or.vala \
	componentdef/def-pe-d-flipflop.vala \
	componentdef/def-plugin.vala \
	componentdef/def-reader.vala \
	componentdef/def-t-flipflop.vala \
	componentdef/def-toggle.vala \
	componentdef/def-tristate.vala \
	componentdef/def-xor.vala \
	componentstate.vala \
	componentstate/state-and.vala \
	componentstate/state-basic-ss-display.vala \
	componentstate/state-buffer.vala \
	componentstate/state-clock.vala \
	componentstate/state-constant.vala \
	componentstate/state-memory.vala \
	componentstate/state-multiplexer.vala \
	componentstate/state-or.vala \
	componentstate/state-pe-d-flipflop.vala \
	componentstate/state-reader.vala \
	componentstate/state-t-flipflop.vala \
	componentstate/state-toggle.vala \
	componentstate/state-tristate.vala \
	componentstate/state-xor.vala \
	componentinst.vala \
	connection.vala \
	customiser.vala \
	designer.vala \
	designerwindow.vala \
	graphic.vala \
	imageexporter.vala \
	path.vala \
	pindef.vala \
	pininst.vala \
	plugincomponentmanager.vala \
	project.vala \
	propertiesquery.vala \
	propertyitem.vala \
	propertyitem/propertyitem-double.vala \
	propertyitem/propertyitem-file.vala \
	propertyitem/propertyitem-int.vala \
	propertyitem/propertyitem-propertyset.vala \
	propertyitem/propertyitem-selection.vala \
	propertyitem/propertyitem-string.vala \
	simulatorwindow.vala \
	tag.vala \
	wireinst.vala \
	wirestate.vala \
	timingdiagram.vala \
	uicommon.vala \
	updatequeue.vala \
	$(NOTHING)

PLUGIN_COMMON_CFLAGS= \
	-I/usr/include/glib-2.0 \
	-I/usr/lib/i386-linux-gnu/glib-2.0/include \
	`pkg-config --cflags glib-2.0 gtk+-3.0 cairo librsvg-2.0 libxml-2.0 gmodule-2.0` \
	$(NOTHING)

PLUGIN_COMMON_LIBS= \
	`pkg-config --libs glib-2.0 gtk+-3.0 cairo librsvg-2.0 libxml-2.0 gmodule-2.0` \
	$(NOTHING)

PLUGIN_OUTPUT_PREFIX= "plugincomponents/lib"
PLUGIN_OUTPUT_SUFFIX= ".so"

# Plugin AltAnd (unused)

PLUGIN_ALTAND_C_FILES= \
	plugincomponents/plugin-def-altand.c \
	plugincomponents/plugin-state-altand.c \
	$(NOTHING)

PLUGIN_ALTAND_SOURCE_FILES= \
	plugincomponents/plugin-def-altand.vala \
	plugincomponents/plugin-state-altand.vala \
	$(NOTHING)

PLUGIN_ALTAND_CFLAGS=
PLUGIN_ALTAND_LIBS=

PLUGIN_ALTAND_OUTPUT_NAME= $(PLUGIN_OUTPUT_PREFIX)"altand"$(PLUGIN_OUTPUT_SUFFIX)

# Plugin GPIO Pin

PLUGIN_GPIOPIN_C_FILES= \
	plugincomponents/plugin-def-gpiopin.c \
	plugincomponents/plugin-state-gpiopin.c \
	$(NOTHING)

PLUGIN_GPIOPIN_SOURCE_FILES= \
	plugincomponents/plugin-def-gpiopin.vala \
	plugincomponents/plugin-state-gpiopin.vala \
	$(NOTHING)

PLUGIN_GPIOPIN_CFLAGS=
PLUGIN_GPIOPIN_LIBS=

PLUGIN_GPIOPIN_OUTPUT_NAME= $(PLUGIN_OUTPUT_PREFIX)"gpiopin"$(PLUGIN_OUTPUT_SUFFIX)

# Combine

PLUGIN_SOURCE_FILES= \
	$(PLUGIN_GPIOPIN_SOURCE_FILES) \
	$(NOTHING)

PLUGIN_C_FILES= \
	$(PLUGIN_GPIOPIN_C_FILES) \
	$(NOTHING)

# End plugins

CONFIG_FILES= \
	--vapidir ./ \
	--pkg config \
	-X -I./ \
	$(NOTHING)

VALA_PACKAGES= \
	--pkg gtk+-3.0 \
	--pkg librsvg-2.0 \
	--pkg libxml-2.0 \
	--pkg gee-0.8 \
	--pkg gmodule-2.0 \
	$(NOTHING)


all: native plugins

native:
	$(VALAC) $(SOURCE_FILES) $(CONFIG_FILES) -o smartsim --verbose $(VALA_PACKAGES)

plugin_altand:
	$(VALAC) $(SOURCE_FILES) $(PLUGIN_ALTAND_SOURCE_FILES) $(CONFIG_FILES) -C --verbose $(VALA_PACKAGES)
	$(CC) -shared -fPIC $(PLUGIN_COMMON_CFLAGS) $(PLUGIN_COMMON_LIBS) $(PLUGIN_ALTAND_CFLAGS) $(PLUGIN_ALTAND_LIBS) -o $(PLUGIN_ALTAND_OUTPUT_NAME) $(PLUGIN_ALTAND_C_FILES)

plugin_gpiopin:
	$(VALAC) $(SOURCE_FILES) $(PLUGIN_GPIOPIN_SOURCE_FILES) $(CONFIG_FILES) -C --verbose $(VALA_PACKAGES)
	$(CC) -shared -fPIC $(PLUGIN_COMMON_CFLAGS) $(PLUGIN_COMMON_LIBS) $(PLUGIN_GPIOPIN_CFLAGS) $(PLUGIN_GPIOPIN_LIBS) -o $(PLUGIN_GPIOPIN_OUTPUT_NAME) $(PLUGIN_GPIOPIN_C_FILES)


nativeO3:
	$(VALAC) $(SOURCE_FILES) $(CONFIG_FILES) -o smartsim --verbose $(VALA_PACKAGES) -X -O3

debug:
	$(VALAC) $(SOURCE_FILES) $(CONFIG_FILES) -o smartsim --verbose $(VALA_PACKAGES) -X -g -X -O0

cfiles:
	$(VALAC) $(SOURCE_FILES) $(CONFIG_FILES) -C --verbose $(VALA_PACKAGES)

plugins_cfiles:
	$(VALAC) $(SOURCE_FILES) $(PLUGIN_SOURCE_FILES) $(CONFIG_FILES) -C --verbose $(VALA_PACKAGES)

plugins: plugins_cfiles
	$(CC) -shared -fPIC $(PLUGIN_COMMON_CFLAGS) $(PLUGIN_COMMON_LIBS) $(PLUGIN_GPIOPIN_CFLAGS) $(PLUGIN_GPIOPIN_LIBS) -o $(PLUGIN_GPIOPIN_OUTPUT_NAME) $(PLUGIN_GPIOPIN_C_FILES)

update_ccode: cfiles
	mv $(C_FILES_ROOT) ../ccode/
	mv $(C_FILES_COMPONENTDEF) ../ccode/componentdef/
	mv $(C_FILES_COMPONENTSTATE) ../ccode/componentstate/
	mv $(C_FILES_PROPERTYITEM) ../ccode/propertyitem/
	-mv $(PLUGIN_C_FILES) ../ccode/plugincomponents/

win32: cfiles
	$(WINCC) -I./ -o smartsim.exe c/*.c c/componentdef/*.c c/componentstate/*.c c/propertyitem/*.c -mms-bitfields $(WINCC_PATH_FLAGS) -lgtk-win32-2.0 -latk-1.0 -lgdk-win32-2.0 -lpangowin32-1.0 -lgdi32 -lpangocairo-1.0 -lpango-1.0 -lrsvg-2 -lm -lgio-2.0 -lgdk_pixbuf-2.0 -lcairo -lgobject-2.0 -lgmodule-2.0 -lgthread-2.0 -lglib-2.0 -lintl -llibxml2

win32O3: cfiles
	$(WINCC) -I./ -o smartsim.exe c/*.c c/componentdef/*.c c/componentstate/*.c c/propertyitem/*.c -mms-bitfields $(WINCC_PATH_FLAGS) -lgtk-win32-2.0 -latk-1.0 -lgdk-win32-2.0 -lpangowin32-1.0 -lgdi32 -lpangocairo-1.0 -lpango-1.0 -lrsvg-2 -lm -lgio-2.0 -lgdk_pixbuf-2.0 -lcairo -lgobject-2.0 -lgmodule-2.0 -lgthread-2.0 -lglib-2.0 -lintl -llibxml2 -O3

win32final: cfiles
	$(WINCC) -I./ -o smartsim.exe c/*.c c/componentdef/*.c c/componentstate/*.c c/propertyitem/*.c -mms-bitfields $(WINCC_PATH_FLAGS) -lgtk-win32-2.0 -latk-1.0 -lgdk-win32-2.0 -lpangowin32-1.0 -lgdi32 -lpangocairo-1.0 -lpango-1.0 -lrsvg-2 -lm -lgio-2.0 -lgdk_pixbuf-2.0 -lcairo -lgobject-2.0 -lgmodule-2.0 -lgthread-2.0 -lglib-2.0 -lintl -llibxml2 -O3 -mwindows

doc:
	valadoc $(SOURCE_FILES) $(CONFIG_FILES) -o doc --vapidir=$(VAPIDIR) --force --private --internal --pkg gtk+-2.0 --pkg librsvg-2.0 --pkg libxml-2.0 --verbose --package-name="SmartSim"
	./printable\ script.sh

clean:
	-rm smartsim
	-rm smartsim.exe
	-rm $(C_FILES)
	-rm $(PLUGIN_C_FILES)



.PHONY : all
.PHONY : clean
.PHONY : cfiles
.PHONY : linux
.PHONY : linuxO3
.PHONY : win32
.PHONY : win32O3
.PHONY : debug
.PHONY : doc
.PHONY : plugins
.PHONY : plugins_cfiles
.PHONY : plugin_altand
.PHONY : plugin_gpiopin
.PHONY : update_ccode
