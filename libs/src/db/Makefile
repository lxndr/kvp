ifeq ($(WIN32), yes)
	AR=i686-w64-mingw32-ar
	PLATFORM_FLAGS = \
		--cc=i686-w64-mingw32-gcc \
		--pkg-config=i686-w64-mingw32-pkg-config \
		-D WINDOWS_BUILD
else
	AR=ar
endif


ifeq ($(DEBUG), yes)
	FLAGS = \
			-g \
			--save-temps
else
	FLAGS = \
		 --Xcc="-w"
endif


DB_SOURCES = \
		database.vala \
		sqlite-database.vala \
		query-builder.vala \
		entity.vala \
		simple-entity.vala \

DB_GTK_SOURCES = \
		view-table.vala \
		viewable.vala

DB_FLAGS = \
		-g \
		--save-temps

DB_PACKAGES = \
		--pkg=gee-0.8 \
		--pkg=sqlite3

DB_GTK_PACKAGES = \
		--vapidir="../../vapi" \
		$(DB_PACKAGES) \
		--pkg=gtk+-3.0 \
		--pkg=db


all: ../../lib/db.a ../../lib/db-gtk.a
	


../../lib/db.a: $(DB_SOURCES)
	echo -e "\e[0;32mCompiling 'db.a'\e[0m"
	valac $(PLATFORM_FLAGS) $(DB_PACKAGES) $(FLAGS) --library=db --use-header --header=db.h --compile $(DB_SOURCES)
	$(AR) rcs "../../lib/db.a" *.o
	mv db.h "../../include"
	mv db.vapi "../../vapi"
	rm -f *.o


../../lib/db-gtk.a: ../../lib/db.a $(DB_GTK_SOURCES)
	echo -e "\e[0;32mCompiling 'db-gtk.a'\e[0m"
	valac $(PLATFORM_FLAGS) $(DB_GTK_PACKAGES) $(FLAGS) --library=db-gtk --use-header --header=db-gtk.h --compile --Xcc="-I../../include" --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" $(DB_GTK_SOURCES)
	$(AR) rcs "../../lib/db-gtk.a" *.o
	mv db-gtk.h "../../include"
	mv db-gtk.vapi "../../vapi"
	rm -f *.o


clean:
	rm -f *.c
	rm -f *.o
	rm -f "db.vapi"
	rm -f "db-gtk.vapi"
	rm -f "db.h"
	rm -f "db-gtk.h"
	rm -f "../../include/db.h"
	rm -f "../../include/db-gtk.h"
	rm -f "../../lib/db.a"
	rm -f "../../lib/db-gtk.a"
	rm -f "../../vapi/db.vapi"
	rm -f "../../vapi/db-gtk.vapi"
