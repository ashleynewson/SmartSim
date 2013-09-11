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

SOURCE_FILES= \
	main.vala \
	designerwindow.vala \
	designer.vala \
	project.vala \
	graphic.vala \
	componentinst.vala \
	pindef.vala \
	pininst.vala \
	wireinst.vala \
	path.vala \
	tag.vala \
	annotation.vala \
	propertiesquery.vala \
	compiledcircuit.vala \
	connection.vala \
	wirestate.vala \
	simulatorwindow.vala \
	customiser.vala \
	circuitinformation.vala \
	timingdiagram.vala \
	updatequeue.vala \
	imageexporter.vala \
	basicdialog.vala \
	componentdef.vala \
	componentdef/*.vala \
	componentstate.vala \
	componentstate/*.vala \
	propertyitem.vala \
	propertyitem/*.vala \
	$(NOTHING)

CONFIG_FILES= \
	--vapidir ./ \
	--pkg config \
	-X -I./ \
	$(NOTHING)

VALA_PACKAGES= \
	--pkg gtk+-3.0 \
	--pkg librsvg-2.0 \
	--pkg libxml-2.0 \
	$(NOTHING)


all: linux

linux:
	$(VALAC) $(SOURCE_FILES) $(CONFIG_FILES) -o smartsim --verbose $(VALA_PACKAGES)

linuxO3:
	$(VALAC) $(SOURCE_FILES) $(CONFIG_FILES) -o smartsim --verbose $(VALA_PACKAGES) -X -O3

debug:
	$(VALAC) $(SOURCE_FILES) $(CONFIG_FILES) -o smartsim --verbose $(VALA_PACKAGES) -X -g

cfiles:
	$(VALAC) $(SOURCE_FILES) $(CONFIG_FILES) -C $(VALA_PACKAGES)
	mv main.c c/
	mv designerwindow.c c/
	mv designer.c c/
	mv project.c c/
	mv graphic.c c/
	mv componentinst.c c/
	mv pindef.c c/
	mv pininst.c c/
	mv wireinst.c c/
	mv path.c c/
	mv tag.c c/
	mv annotation.c c/
	mv propertiesquery.c c/
	mv compiledcircuit.c c/
	mv connection.c c/
	mv wirestate.c c/
	mv simulatorwindow.c c/
	mv customiser.c c/
	mv circuitinformation.c c/
	mv timingdiagram.c c/
	mv updatequeue.c c/
	mv imageexporter.c c/
	mv basicdialog.c c/
	mv componentdef.c c/
	mv componentstate.c c/
	mv propertyitem.c c/
	mv componentdef/*.c c/componentdef/
	mv componentstate/*.c c/componentstate/
	mv propertyitem/*.c c/propertyitem/

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
	-rm c/*.c
	-rm c/componentdef/*.c
	-rm c/componentstate/*.c
	-rm c/propertyitem/*.c



.PHONY : all
.PHONY : clean
.PHONY : cfiles
.PHONY : linux
.PHONY : linuxO3
.PHONY : win32
.PHONY : win32O3
.PHONY : debug
.PHONY : doc



#linux:
#	valac logic.vala designerwindow.vala designer.vala project.vala graphic.vala componentinst.vala pindef.vala pininst.vala wireinst.vala path.vala tag.vala annotation.vala propertyset.vala propertiesquery.vala compiledcircuit.vala connection.vala wirestate.vala simulatorwindow.vala customiser.vala componentdef.vala componentdef.vala componentdef/*.vala componentstate.vala componentstate/*.vala -o logic --pkg gtk+-2.0 --pkg librsvg-2.0 --pkg libxml-2.0
#windows:
#	wine valac logic.vala designerwindow.vala designer.vala project.vala graphic.vala componentinst.vala pindef.vala pininst.vala wireinst.vala path.vala tag.vala annotation.vala propertyset.vala propertiesquery.vala compiledcircuit.vala connection.vala wirestate.vala simulatorwindow.vala customiser.vala componentdef.vala componentdef/*.vala componentstate.vala componentstate/*.vala -o logic --verbose --pkg gtk+-2.0 --pkg librsvg-2.0 --pkg libxml-2.0
#all:
#	valac logic.vala designerwindow.vala designer.vala project.vala graphic.vala componentinst.vala pindef.vala wireinst.vala path.vala tag.vala annotation.vala componentdef.vala componentdef/custom.vala componentdef/buffer.vala componentdef/and.vala componentdef/or.vala componentdef/xor.vala componentdef/tristate.vala -o logic --verbose --pkg gtk+-2.0 --pkg librsvg-2.0 --pkg libxml-2.0
#linux:
#	valac logic.vala designerwindow.vala designer.vala project.vala graphic.vala componentinst.vala pindef.vala wireinst.vala path.vala tag.vala annotation.vala componentdef.vala componentdef/custom.vala componentdef/buffer.vala componentdef/and.vala componentdef/or.vala componentdef/xor.vala componentdef/tristate.vala -o logic --pkg gtk+-2.0 --pkg librsvg-2.0 --pkg libxml-2.0
#windows:
#	wine valac logic.vala designerwindow.vala designer.vala project.vala graphic.vala componentinst.vala pindef.vala wireinst.vala path.vala tag.vala annotation.vala componentdef.vala componentdef/custom.vala componentdef/buffer.vala componentdef/and.vala componentdef/or.vala componentdef/xor.vala componentdef/tristate.vala -o logic --pkg gtk+-2.0 --pkg librsvg-2.0 --pkg libxml-2.0
#cfiles:
#	valac logic.vala designerwindow.vala designer.vala project.vala graphic.vala componentinst.vala pindef.vala wireinst.vala path.vala tag.vala annotation.vala componentdef.vala componentdef/custom.vala componentdef/buffer.vala componentdef/and.vala componentdef/or.vala componentdef/xor.vala componentdef/tristate.vala -C --pkg gtk+-2.0 --pkg librsvg-2.0 --pkg libxml-2.0
