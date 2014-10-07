include ../../../common.mk


NAME = db-gtk


SOURCES = \
	cellrenderer-calendar.vala \
	view-table.vala \
	viewable.vala


PACKAGES = \
	--vapidir="../../vapi" \
	--pkg=gee-0.8 \
	--pkg=sqlite3 \
	--pkg=gtk+-3.0 \
	--pkg=db


../../lib/$(NAME).$(LIBEXT): ../../vapi/db.vapi $(SOURCES)
	echo -e "\e[0;32mCompiling '$(NAME).$(LIBEXT)'\e[0m"
	valac $(PACKAGES) $(FLAGS) --library=$(NAME) --use-header --header=$(NAME).h  --Xcc="-I../../include" --compile --Xcc="-DGETTEXT_PACKAGE=\"kvp\"" $(SOURCES)
	$(AR) rcs "../../lib/$(NAME).$(LIBEXT)" *.o
	mv "$(NAME).h" "../../include"
	mv "$(NAME).vapi" "../../vapi"
	rm -f *.o


clean:
	rm -f *.c
	rm -f *.o
	rm -f "$(NAME).vapi"
	rm -f "$(NAME).h"
	rm -f "../../include/$(NAME).h"
	rm -f "../../lib/$(NAME).$(LIBEXT)"
	rm -f "../../vapi/$(NAME).vapi"
