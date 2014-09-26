DB_SOURCES= \
		database.vala \
		sqlite-database.vala \
		entity.vala \
		simple-entity.vala \

DB_GTK_SOURCES= \
		table-view.vala \
		viewable.vala

DB_PACKAGES= \
		--pkg=gee-0.8 \
		--pkg=sqlite3

DB_GTK_PACKAGES= \
		--vapidir="../../vapi" \
		$(DB_PACKAGES) \
		--pkg=gtk+-3.0 \
		--pkg=db


all: ../../lib/libdb.a ../../lib/libdb-gtk.a
	


../../lib/libdb.a: $(DB_SOURCES)
	echo -e "\e[0;32mCompiling 'libdb.a'\e[0m"
	valac $(DB_PACKAGES) --library=db --use-header --header=db.h --compile --Xcc="-w" $(DB_SOURCES)
	ar rcs ../../lib/libdb.a *.o
	mv db.h ../../include
	mv db.vapi ../../vapi
	rm -f *.o


../../lib/libdb-gtk.a: $(DB_GTK_SOURCES)
	echo -e "\e[0;32mCompiling 'libdb-gtk.a'\e[0m"
	valac $(DB_GTK_PACKAGES) --library=db-gtk --use-header --header=db-gtk.h --compile --Xcc="-I../../include" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" $(DB_GTK_SOURCES)
	ar rcs ../../lib/libdb-gtk.a *.o
	mv db-gtk.h ../../include
	mv db-gtk.vapi ../../vapi
	rm -f *.o


clean:
	rm -f *.c
	rm -f *.o
	rm -f "../../include/db.h"
	rm -f "../../include/db-gtk.h"
	rm -f "../../lib/libdb.a"
	rm -f "../../lib/libdb-gtk.a"
	rm -f "../../vapi/db.vapi"
	rm -f "../../vapi/db-gtk.vapi"
