# Qt

QTSVG_VERSION := 5.11.0
QTSVG_URL := https://download.qt.io/new_archive/qt/5.11/$(QTSVG_VERSION)/submodules/qtsvg-everywhere-src-$(QTSVG_VERSION).tar.xz

DEPS_qtsvg += qt $(DEPS_qt)

ifdef HAVE_WIN32
PKGS += qtsvg
endif

ifeq ($(call need_pkg,"Qt5Svg"),)
PKGS_FOUND += qtsvg
endif

$(TARBALLS)/qtsvg-$(QTSVG_VERSION).tar.xz:
	$(call download,$(QTSVG_URL))

.sum-qtsvg: qtsvg-$(QTSVG_VERSION).tar.xz

qtsvg: qtsvg-$(QTSVG_VERSION).tar.xz .sum-qtsvg
	$(UNPACK)
	mv qtsvg-everywhere-src-$(QTSVG_VERSION) qtsvg-$(QTSVG_VERSION)
	$(APPLY) $(SRC)/qtsvg/0001-Force-the-usage-of-QtZlib-header.patch
	$(MOVE)

.qtsvg: qtsvg
ifdef HAVE_CROSS_COMPILE
	cd $< && $(PREFIX)/bin/qmake
else
	cd $< && ../qt/bin/qmake
endif
	# Make && Install libraries
	cd $< && $(MAKE)
	cd $< && $(MAKE) -C src sub-plugins-install_subtargets sub-svg-install_subtargets
	mv $(PREFIX)/plugins/iconengines/libqsvgicon.a $(PREFIX)/lib/
	mv $(PREFIX)/plugins/imageformats/libqsvg.a $(PREFIX)/lib/
	cd $(PREFIX)/lib/pkgconfig; sed -i.orig \
		-e 's/d\.a/.a/g' \
		-e 's/-lQt\([^ ]*\)d/-lQt\1/g' \
		-e '/Libs:/  s/-lQt5Svg/-lqsvg -lqsvgicon -lQt5Svg/ ' \
		Qt5Svg.pc
	touch $@
