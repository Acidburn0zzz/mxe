# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := gnutls
$(PKG)_WEBSITE  := https://www.gnu.org/software/gnutls/
$(PKG)_DESCR    := GnuTLS
$(PKG)_VERSION  := 3.5.15
$(PKG)_CHECKSUM := 046081108b8b1fe455a13a4c5a4eaa0368e185b678f1670fe09a11a2d7ecfad5
$(PKG)_SUBDIR   := gnutls-$($(PKG)_VERSION)
$(PKG)_FILE     := gnutls-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://gnupg.org/ftp/gcrypt/gnutls/v3.5/$($(PKG)_FILE)
$(PKG)_URL_2    := ftp://ftp.gnutls.org/gcrypt/gnutls/v3.5/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc gettext gmp libgnurx libidn2 libunistring nettle zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- https://gnupg.org/ftp/gcrypt/gnutls/v3.5/ | \
    $(SED) -n 's,.*gnutls-\([1-9]\+\.[0-9]\+.[0-9]\+\)\..*,\1,p' | \
    $(SORT) -V | \
    tail -1
endef

define $(PKG)_BUILD
    # AI_ADDRCONFIG referenced by src/serv.c but not provided by mingw.
    # Value taken from https://msdn.microsoft.com/en-us/library/windows/desktop/ms737530%28v=vs.85%29.aspx
    cd '$(1)' && autoreconf -fi && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --disable-rpath \
        --disable-nls \
        --disable-guile \
        --disable-doc \
        --disable-tests \
        --enable-local-libopts \
        --with-included-libtasn1 \
        --with-libregex-libs="-lgnurx" \
        --without-p11-kit \
        --disable-silent-rules \
        CPPFLAGS='-DWINVER=0x0501 -DAI_ADDRCONFIG=0x0400 -DIPV6_V6ONLY=27' \
        LIBS='-lws2_32' \
        ac_cv_prog_AR='$(TARGET)-ar'
    $(MAKE) -C '$(1)' -j '$(JOBS)' install

    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-gnutls.exe' \
        `'$(TARGET)-pkg-config' gnutls --cflags --libs`
endef
