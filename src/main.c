#include "kvp.h"


#ifdef WIN32
#include <windows.h>

int CALLBACK
WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	gchar ** argv = g_win32_get_command_line ();
	gint argc = g_strv_length (argv);
	gint ret = kv_start (argv, argc);
	g_strfreev (argv);
	return ret;
}

#else

int
main (int argc, char **argv)
{
	return kv_start (argv, argc);
}

#endif
