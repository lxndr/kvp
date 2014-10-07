include ../../../common.mk


NAME = db


SOURCES = \
	database.vala \
	sqlite-database.vala \
	query-builder.vala \
	entity.vala \
	simple-entity.vala \


PACKAGES = \
	--pkg=gee-0.8 \
	--pkg=sqlite3


all: ../../lib/$(NAME).$(LIBEXT)
	


../../lib/$(NAME).$(LIBEXT): $(SOURCES)
	echo -e "\e[0;32mCompiling '$(NAME).a'\e[0m"
	valac $(FLAGS) $(PACKAGES) --library=$(NAME) --use-header --header=$(NAME).h --compile $(SOURCES)
	$(AR) rcs "../../lib/$(NAME).$(LIBEXT)" *.o
	mv $(NAME).h "../../include"
	mv $(NAME).vapi "../../vapi"
	rm -f *.o


clean:
	rm -f *.c
	rm -f *.o
	rm -f "$(NAME).vapi"
	rm -f "$(NAME).h"
	rm -f "../../include/$(NAME).h"
	rm -f "../../lib/$(NAME).$(LIBEXT)"
	rm -f "../../vapi/$(NAME).vapi"
