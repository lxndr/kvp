include ../../../common.mk


NAME=archive

SOURCES= \
		zip.vala

PACKAGES= \
		--pkg=gio-2.0 \
		--pkg=gee-0.8 \
		--pkg=zlib


all: ../../lib/$(NAME).$(LIBEXT)
	


../../lib/$(NAME).$(LIBEXT): $(SOURCES)
	echo -e "\e[0;32mCompiling '$(NAME).$(LIBEXT)'\e[0m"
	valac $(FLAGS) $(PACKAGES) --library=$(NAME) --use-header --header=$(NAME).h --compile $(SOURCES)
	$(AR) rcs ../../lib/$(NAME).$(LIBEXT) *.o
	mv $(NAME).h ../../include
	mv $(NAME).vapi ../../vapi
	rm -f *.o


clean:
	rm -f *.c
	rm -f *.o
	rm -f "$(NAME).vapi"
	rm -f "$(NAME).h"
	rm -f "../../include/$(NAME).h"
	rm -f "../../lib/$(NAME).$(LIBEXT)"
	rm -f "../../vapi/$(NAME).vapi"
