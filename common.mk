ifeq ($(BUILD), win32)
	AR = i686-w64-mingw32-ar
	FLAGS = \
		--cc=i686-w64-mingw32-gcc \
		--pkg-config=i686-w64-mingw32-pkg-config \
		-D WINDOWS_BUILD
else
	AR = ar
endif


ifeq ($(DEBUG), yes)
	FLAGS = \
		-g \
		--save-temps \
		-D DEBUG
else
	FLAGS = \
		--Xcc="-w"
endif



