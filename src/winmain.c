#include <windows.h>
#include "kvp.h"


static int CALLBACK
WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	gchar ** argv = g_win32_get_command_line ();
	gint argc = g_strv_length (argv);
	gint ret = kv_application_main (argv, argc);
	g_strfreev (argv);
	return ret;
}
