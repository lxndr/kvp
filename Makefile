include common.mk


NAME = kvp


RESOURCES = \
	ui/main-window.ui \
	data/init.sql

SOURCES = \
	src/widgets/year-month.vala \
	src/widgets/central-year-month.vala \
	src/application.vala \
	src/main-window.vala \
	src/utils.vala \
	src/types.vala \
	src/account-table.vala \
	src/people-table.vala \
	src/tax-table.vala \
	src/service-table.vala \
	src/service-window.vala \
	src/building-table.vala \
	src/building-window.vala \
	src/database.vala \
	src/entities/building.vala \
	src/entities/tax.vala \
	src/entities/person.vala \
	src/entities/account.vala \
	src/entities/account-period.vala \
	src/entities/service.vala \
	src/entities/price.vala \
	src/entities/relationship.vala \
	src/report.vala \
	src/reports/report-001.vala \
	src/reports/report-002.vala \
	src/reports/report-003.vala

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


ifeq ($(BUILD), win32)
else ifeq ($(BUILD), win64)
else
endif


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
			-lintl
	else ifeq ($(BUILD), win64)
		LDFLAGS += \
			-lintl
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
	cd "build" && \
		valac $(FLAGS) $(PACKAGES) --vapidir="../libs/vapi" --target-glib=2.38 --gresources=kvartplata.gresource.xml --header=kvp.h --use-header --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" --Xcc="-I../libs/include" --compile ../src/*.vala ../src/entities/*.vala ../src/widgets/*.vala ../src/reports/*.vala ../src/resources.c
	$(CC) -o $(NAME)$(BINEXT) build/*.o libs/lib/db.$(LIBEXT) libs/lib/db-gtk.$(LIBEXT) libs/lib/ooxml.$(LIBEXT) libs/lib/archive.$(LIBEXT) $(LDFLAGS)


resources: build/resources.c
	


build/resources.c: kvartplata.gresource.xml $(RESOURCES)
	glib-compile-resources --generate-source --target=src/resources.c kvartplata.gresource.xml


po: kvp.pot
	msgfmt --output=ru.mo ru.po

kvp.pot: $(SOURCES)
	xgettext --output=kvp.pot \
			--keyword=_ --keyword=N_ --keyword=C_:1c,2 --keyword=NC_:1c,2 \
			$(SOURCES) "ui/main-window.ui" \
			--msgid-bugs-address=lxndr87@users.sourceforge.net \
			--from-code=UTF-8
	msgmerge --update --quiet ru.po kvp.pot


clean:
	$(MAKE) -C libs/src/archive clean
	$(MAKE) -C libs/src/ooxml clean
	$(MAKE) -C libs/src/db clean
	$(MAKE) -C libs/src/db-gtk clean

	rm -f src/*.c
	rm -f src/widgets/*.c
	rm -f src/entities/*.c
	rm -f src/reports/*.c
	rm -fr build
	rm -f kvp kvp.exe
