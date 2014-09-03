RESOURCES=ui/main-window.ui \
	data/init.sql

SOURCES=src/application.vala \
	src/main-window.vala \
	src/utils.vala \
	src/table-view.vala \
	src/account-table.vala \
	src/people-table.vala \
	src/tax-table.vala \
	src/entity.vala \
	src/database.vala \
	src/entities/tax.vala \
	src/entities/person.vala \
	src/entities/account.vala \
	src/entities/service.vala


all: kvartplata
	


kvartplata: resources $(SOURCES)
	valac $(SOURCES) src/resources.c --target-glib=2.38 --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=json-glib-1.0 --pkg=sqlite3 --gresources=kvartplata.gresource.xml -o kvartplata


debug: resources $(SOURCES)
	valac $(SOURCES) src/resources.c --target-glib=2.38 --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=json-glib-1.0 --pkg=sqlite3 --gresources=kvartplata.gresource.xml -g --save-temps -D TES_SAVE_DEBUG -o kvartplata


win32: resources $(SOURCES)
	valac --cc=i686-w64-mingw32-gcc --pkg-config=i686-w64-mingw32-pkg-config $(SOURCES) src/resources.c --target-glib=2.38 --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=json-glib-1.0 --pkg=sqlite3 --gresources=kvartplata.gresource.xml -o kvartplata-x86_32.exe

win64: resources $(SOURCES)
	valac --cc=x86_64-w64-mingw32-gcc --pkg-config=x86_64-w64-mingw32-pkg-config $(SOURCES) src/resources.c --target-glib=2.38 --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=json-glib-1.0 --pkg=sqlite3 --gresources=kvartplata.gresource.xml -o kvartplata-x86_64.exe


resources: kvartplata.gresource.xml $(RESOURCES)
	glib-compile-resources --generate-source --target=src/resources.c kvartplata.gresource.xml


clean:
	rm -f src/*.c
	rm -f src/entities/*.c
	rm -f kvartplata kvartplata-x86_32.exe kvartplata-x86_64.exe
