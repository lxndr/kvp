include ../../../common.mk


NAME=ooxml

SOURCES= \
		error.vala \
		utils.vala \
		cell-value.vala \
		cell.vala \
		sheet.vala \
		spreadsheet.vala \
		shareable-list.vala \
		reader.vala \
		writer.vala


PACKAGES= \
		--vapidir="../../vapi" \
		--pkg=gio-2.0 \
		--pkg=gee-0.8 \
		--pkg=libxml-2.0 \
		--pkg=archive


all: ../../lib/$(NAME).$(LIBEXT)
	


../../lib/$(NAME).$(LIBEXT): $(SOURCES)
	echo -e "\e[0;32mCompiling '$(NAME).$(LIBEXT)'\e[0m"
	valac $(PACKAGES) $(FLAGS) --library=$(NAME) --use-header --header=$(NAME).h  --Xcc="-I../../include" --compile $(SOURCES)
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
