NOTHING=

if ENABLE_PLUGINS



pkglib_LTLIBRARIES=libgpiopin.la

plugin_LIBADD= \
	$(NOTHING)
plugin_CFLAGS= \
	$(GLIB_CFLAGS) \
	$(GTK_CFLAGS) \
	$(CAIRO_CFLAGS) \
	$(LIBRSVG_CFLAGS) \
	$(LIBXML_CFLAGS) \
	$(DEF_CFLAGS) \
	$(NOTHING)
plugin_LDFLAGS= \
	-module \
	$(NOTHING)

libgpiopin_la_SOURCES= \
	plugin-def-gpiopin.c \
	plugin-state-gpiopin.c \
	$(NOTHING)

libgpiopin_la_LIBADD= \
	$(plugin_LIBADD) \
	$(NOTHING)
libgpiopin_la_CFLAGS= \
	$(plugin_CFLAGS) \
	$(NOTHING)
libgpiopin_la_LDFLAGS= \
	$(plugin_LDFLAGS) \
	$(NOTHING)



endif
