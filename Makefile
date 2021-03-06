include common.mk


NAME = kvp


SOURCES = \
	src/*.vala \
	src/widgets/*.vala \
	src/entities/*.vala \
	src/reports/*.vala

PACKAGES = \
	--pkg=gtk+-3.0 \
	--pkg=gee-0.8 \
	--pkg=sqlite3 \
	--pkg=libxml-2.0 \
	--pkg=db \
	--pkg=db-gtk \
	--pkg=ooxml

LIBS = \
	--Xcc="libs/lib/db.$(LIBEXT)" \
	--Xcc="libs/lib/db-gtk.$(LIBEXT)" \
	--Xcc="libs/lib/ooxml.$(LIBEXT)" \
	--Xcc="libs/lib/archive.$(LIBEXT)" \
	--Xcc="-lz"


ifeq ($(STATIC), yes)
	LDFLAGS += \
		/usr/i686-w64-mingw32/lib/libgee-0.8.a \
		/usr/i686-w64-mingw32/lib/libsqlite3.a \
		/usr/i686-w64-mingw32/lib/libxml2.a \
		`$(PKGCONFIG) --libs gtk+-3.0`
else
	LDFLAGS += \
		-lz \
		`$(PKGCONFIG) --libs gtk+-3.0 gee-0.8 sqlite3 libxml-2.0`

	ifeq ($(BUILD), win32)
		LDFLAGS += \
			-lintl \
			-mwindows
	else ifeq ($(BUILD), win64)
		LDFLAGS += \
			-lintl \
			-mwindows
	else
		LDFLAGS += \
			-lm
	endif
endif


all: build-libs $(NAME)$(BINEXT) po
	


build-libs:
	$(MAKE) -C libs/src/archive
	$(MAKE) -C libs/src/ooxml
	$(MAKE) -C libs/src/db
	$(MAKE) -C libs/src/db-gtk


$(NAME)$(BINEXT): resources $(SOURCES)
	rm -fr "build"
	mkdir -p "build"
	cp *.gresource.xml "build/"
	cp -r "ui" "build"
	cp src/*.c "build"
	cd "build" && \
		valac $(FLAGS) $(PACKAGES) --vapidir="../libs/vapi" --target-glib=2.38 --gresources=$(NAME).gresource.xml --header=$(NAME).h --use-header --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" --Xcc="-I../libs/include" --compile ../src/types/*.vala ../src/*.vala ../src/entities/*.vala ../src/widgets/*.vala ../src/reports/*.vala resources.c main.c
	$(CC) -o $(NAME)$(BINEXT) build/*.o libs/lib/db.$(LIBEXT) libs/lib/db-gtk.$(LIBEXT) libs/lib/ooxml.$(LIBEXT) libs/lib/archive.$(LIBEXT) $(LDFLAGS)


# Resources
resources: build/resources.c
	


build/resources.c: kvp.gresource.xml ui/*.ui
	glib-compile-resources --generate-source --target=src/resources.c kvp.gresource.xml


# Translation
po: kvp.pot
	msgfmt --output=ru.mo ru.po

kvp.pot: $(SOURCES)
	xgettext --output=kvp.pot \
			--keyword=_ --keyword=N_ --keyword=C_:1c,2 --keyword=NC_:1c,2 \
			$(SOURCES) "ui/main-window.ui" libs/src/db-gtk/*.vala \
			--msgid-bugs-address=lxndr87@users.sourceforge.net \
			--from-code=UTF-8
	msgmerge --update --quiet ru.po kvp.pot


# Packaging
PAKOUT = $(NAME)-$(BUILD)

ifeq ($(BUILD), win32)
	BINDIR = /usr/i686-w64-mingw32/bin
else ifeq ($(BUILD), win64)
	BINDIR = /usr/x86_64-w64-mingw32/bin
else
	
endif


pack: $(NAME)$(BINEXT)
	mkdir -p $(PAKOUT)/bin/out
	cp -f $(BINDIR)/{gspawn-win32-helper.exe,gspawn-win32-helper-console.exe,libatk-1.0-0.dll,libbz2-1.dll,libcairo-2.dll,libcairo-gobject-2.dll,libexpat-1.dll,libffi-6.dll,libfontconfig-1.dll,libfreetype-6.dll,libgcc_s_sjlj-1.dll,libgdk-3-0.dll,libgdk_pixbuf-2.0-0.dll,libgee-0.8-2.dll,libgio-2.0-0.dll,libglib-2.0-0.dll,libgmodule-2.0-0.dll,libgobject-2.0-0.dll,libgtk-3-0.dll,libharfbuzz-0.dll,libiconv-2.dll,libintl-8.dll,libpango-1.0-0.dll,libpangocairo-1.0-0.dll,libpangoft2-1.0-0.dll,libpangowin32-1.0-0.dll,libpixman-1-0.dll,libpng16-16.dll,libsqlite3-0.dll,libwinpthread-1.dll,libxml2-2.dll,zlib1.dll} $(PAKOUT)/bin
	cp -f {kvp.exe,kvartplata.db,style.css} $(PAKOUT)/bin
	cp -fr templates $(PAKOUT)/bin


# Clean
clean:
	$(MAKE) -C libs/src/archive clean
	$(MAKE) -C libs/src/ooxml clean
	$(MAKE) -C libs/src/db clean
	$(MAKE) -C libs/src/db-gtk clean

#	rm -f src/*.c
	rm -f src/widgets/*.c
	rm -f src/entities/*.c
	rm -f src/reports/*.c
	rm -fr build
	rm -f kvp kvp.exe
