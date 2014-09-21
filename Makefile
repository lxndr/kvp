RESOURCES=ui/main-window.ui \
	data/init.sql

SOURCES=src/db/database.vala \
		src/db/sqlite-database.vala \
		src/db/entity.vala \
		src/db/simple-entity.vala \
		src/db/viewable.vala \
		src/db/table-view.vala \
		src/widgets/year-month.vala \
		src/application.vala \
		src/main-window.vala \
		src/utils.vala \
		src/types.vala \
		src/account-table.vala \
		src/people-table.vala \
		src/tax-table.vala \
		src/database.vala \
		src/entities/tax.vala \
		src/entities/person.vala \
		src/entities/account.vala \
		src/entities/account-period.vala \
		src/entities/service.vala \
		src/entities/price.vala \
		src/entities/relationship.vala \
		src/archive/zip.vala \
		src/ooxml/cell-value.vala \
		src/ooxml/shared-strings.vala \
		src/ooxml/cell.vala \
		src/ooxml/sheet.vala \
		src/ooxml/spreadsheet.vala \
		src/ooxml/utils.vala \
		src/ooxml/error.vala \
		src/report.vala \
		src/reports/report-001.vala \
		src/reports/report-002.vala \
		src/reports/report-003.vala

PACKAGES=--pkg=gtk+-3.0 \
		--pkg=gee-0.8 \
		--pkg=json-glib-1.0 \
		--pkg=sqlite3 \
		--pkg=libxml-2.0 \
		--pkg=zlib


all: kvp
	


kvp: resources $(SOURCES)
	valac $(SOURCES) src/resources.c --Xcc="-w" --Xcc="-lm" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" --target-glib=2.38 --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=json-glib-1.0 --pkg=sqlite3 --pkg=libxml-2.0 --pkg=zlib --gresources=kvartplata.gresource.xml -o kvp


debug: resources $(SOURCES)
	valac $(SOURCES) src/resources.c \
		-D KVP_DEBUG \
		--Xcc="-lm" \
		--Xcc="-DGETTEXT_PACKAGE=\"kvp\"" \
		--target-glib=2.38 \
		$(PACKAGES) \
		--gresources=kvartplata.gresource.xml \
		-g --save-temps \
		-o kvp


# win-launcher.exe: src/win-launcher.c
#	i686-w64-mingw32-gcc -o win-launcher.exe src/win-launcher.c

win32: resources $(SOURCES)
	valac --cc=i686-w64-mingw32-gcc --pkg-config=i686-w64-mingw32-pkg-config -D WINDOWS_BUILD --Xcc="-w" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" $(SOURCES) src/resources.c --target-glib=2.38 $(PACKAGES) --gresources=kvartplata.gresource.xml -o kvp-x86_32.exe

win64: resources $(SOURCES)
	valac --cc=x86_64-w64-mingw32-gcc --pkg-config=x86_64-w64-mingw32-pkg-config --Xcc="-w" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" $(SOURCES) src/resources.c --target-glib=2.38 $(PACKAGES) --gresources=kvartplata.gresource.xml -o kvp-x86_64.exe


resources: kvartplata.gresource.xml $(RESOURCES)
	glib-compile-resources --generate-source --target=src/resources.c kvartplata.gresource.xml


po: kvp.pot
	msgfmt --output=ru.mo ru.po

kvp.pot: $(SOURCES)
	xgettext --output=kvp.pot \
			--keyword=_ --keyword=N_ --keyword=C_:1c,2 --keyword=NC_:1c,2\
			$(SOURCES) \
			--msgid-bugs-address=lxndr87@users.sourceforge.net \
			--from-code=UTF-8
	msgmerge --update --quiet ru.po kvp.pot


clean:
	rm -f src/*.c
	rm -f src/db/*.c
	rm -f src/archive/*.c
	rm -f src/widgets/*.c
	rm -f src/entities/*.c
	rm -f src/ooxml/*.c
	rm -f src/reports/*.c
	rm -f kvp kvp-x86_32.exe kvp-x86_64.exe
