NOTHING=

if ENABLE_PLUGINS



pkglib_LTLIBRARIES=gpiopin.la

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

gpiopin_la_SOURCES= \
	plugin-def-gpiopin.c \
	plugin-state-gpiopin.c \
	$(NOTHING)

gpiopin_la_LIBADD= \
	$(plugin_LIBADD) \
	$(NOTHING)
gpiopin_la_CFLAGS= \
	$(plugin_CFLAGS) \
	$(NOTHING)
gpiopin_la_LDFLAGS= \
	$(plugin_LDFLAGS) \
	$(NOTHING)



endif
