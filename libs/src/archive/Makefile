ifeq ($(WIN32), yes)
	AR=i686-w64-mingw32-ar
	PLATFORM_FLAGS = \
		--cc=i686-w64-mingw32-gcc
		--pkg-config=i686-w64-mingw32-pkg-config \
		-D WINDOWS_BUILD
else
	AR=ar
endif



NAME=archive

SOURCES= \
		zip.vala

PACKAGES= \
		--pkg=gio-2.0 \
		--pkg=gee-0.8 \
		--pkg=zlib


all: ../../lib/$(NAME).a
	


../../lib/$(NAME).a: $(SOURCES)
	echo -e "\e[0;32mCompiling '$(NAME).a'\e[0m"
	valac $(PLATFORM_FLAGS) $(PACKAGES) --library=$(NAME) --use-header --header=$(NAME).h --Xcc="-w" --compile $(SOURCES)
	$(AR) rcs ../../lib/$(NAME).a *.o
	mv $(NAME).h ../../include
	mv $(NAME).vapi ../../vapi
	rm -f *.o


clean:
	rm -f *.c
	rm -f *.o
	rm -f "$(NAME).vapi"
	rm -f "$(NAME).h"
	rm -f "../../include/$(NAME).h"
	rm -f "../../lib/$(NAME).a"
	rm -f "../../vapi/$(NAME).vapi"
