#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.68])
AC_INIT([smartsim], [1.4], [ashleynewson@smartsim.org.uk])
AC_CONFIG_SRCDIR([config.h.in])
AM_INIT_AUTOMAKE
AC_CONFIG_HEADERS([config.h])


# Checks for programs.
AC_PROG_CC

AC_PATH_PROG([tar])
AC_SUBST(TAR, tar)

# Checks for libraries.
PKG_CHECK_MODULES([GLIB], glib-2.0 gobject-2.0 gmodule-2.0)
AC_SUBST(GLIB_LIBS)
AC_SUBST(GLIB_CFLAGS)

PKG_CHECK_MODULES([GTK], gtk+-3.0)
AC_SUBST(GTK_LIBS)
AC_SUBST(GTK_CFLAGS)

PKG_CHECK_MODULES([CAIRO], cairo)
AC_SUBST(CAIRO_LIBS)
AC_SUBST(CAIRO_CFLAGS)

PKG_CHECK_MODULES([LIBRSVG], librsvg-2.0)
AC_SUBST(LIBRSVG_LIBS)
AC_SUBST(LIBRSVG_CFLAGS)

PKG_CHECK_MODULES([LIBXML], libxml-2.0)
AC_SUBST(LIBXML_LIBS)
AC_SUBST(LIBXML_CFLAGS)

# Checks for header files.
AC_CHECK_HEADERS([float.h stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CHECK_FUNCS([memset strstr])

AC_CONFIG_FILES([Makefile
                 ccode/Makefile
                 resources_tar/Makefile])
AC_OUTPUT
