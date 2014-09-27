RESOURCES=ui/main-window.ui \
	data/init.sql

SOURCES=\
		src/widgets/year-month.vala \
		src/widgets/central-year-month.vala \
		src/application.vala \
		src/main-window.vala \
		src/utils.vala \
		src/types.vala \
		src/account-table.vala \
		src/people-table.vala \
		src/tax-table.vala \
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

PACKAGES= \
		--vapidir="libs/vapi" \
		--pkg=gtk+-3.0 \
		--pkg=gee-0.8 \
		--pkg=sqlite3 \
		--pkg=libxml-2.0 \
		--pkg=db \
		--pkg=db-gtk \
		--pkg=ooxml

LIBS= \
	--Xcc="libs/lib/db.a" \
	--Xcc="libs/lib/db-gtk.a" \
	--Xcc="libs/lib/ooxml.a" \
	--Xcc="libs/lib/archive.a" \
	--Xcc="-lz"


all: kvp
	


kvp: resources $(SOURCES)
	valac $(SOURCES) src/resources.c --Xcc="-w" --Xcc="-lm" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" --Xcc="-Ilibs/include" $(LIBS) --target-glib=2.38 $(PACKAGES) --gresources=kvartplata.gresource.xml -o kvp


debug: resources $(SOURCES)
	valac $(SOURCES) src/resources.c -D KVP_DEBUG --Xcc="-lm" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" --Xcc="-Ilibs/include" $(LIBS) --target-glib=2.38 $(PACKAGES) --gresources=kvartplata.gresource.xml -g --save-temps -o kvp


win32: resources $(SOURCES)
	valac --cc=i686-w64-mingw32-gcc --pkg-config=i686-w64-mingw32-pkg-config -D WINDOWS_BUILD --Xcc="-Ilibs/include" --Xcc="-w" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" $(SOURCES) src/resources.c --target-glib=2.38 --gresources=kvartplata.gresource.xml -o kvp-x86_32.exe --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=sqlite3 --pkg=libxml-2.0 --pkg=zlib libs/src/archive/zip.vala libs/src/db/database.vala libs/src/db/entity.vala libs/src/db/query-builder.vala libs/src/db/simple-entity.vala libs/src/db/sqlite-database.vala libs/src/db/view-table.vala libs/src/db/viewable.vala libs/src/ooxml/cell.vala libs/src/ooxml/cell-value.vala libs/src/ooxml/error.vala libs/src/ooxml/shared-strings.vala libs/src/ooxml/sheet.vala libs/src/ooxml/spreadsheet.vala libs/src/ooxml/utils.vala 


win64: resources $(SOURCES)
	valac --cc=x86_64-w64-mingw32-gcc --pkg-config=x86_64-w64-mingw32-pkg-config --Xcc="-w" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" $(SOURCES) src/resources.c --target-glib=2.38 $(PACKAGES) --gresources=kvartplata.gresource.xml -o kvp-x86_64.exe


resources: kvartplata.gresource.xml $(RESOURCES)
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
	rm -f src/*.c
	rm -f src/widgets/*.c
	rm -f src/entities/*.c
	rm -f src/reports/*.c
	rm -f kvp kvp-x86_32.exe kvp-x86_64.exe
