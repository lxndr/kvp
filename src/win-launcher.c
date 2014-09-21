#include <stdio.h>
#include <windows.h>


int
main (int argc, char **argv)
{
	if (argc < 2 || argv[1] == NULL)
		return 1;

	printf ("Lunching %s\n", argv[1]);

	LPCTSTR fname = argv[1];
	int ret = (int) ShellExecute (NULL, "open", fname, NULL, NULL, SW_SHOWNORMAL);
	if (ret <= 32)
		printf ("ShellExecute error: code %d", (int) ret);

	return 0;
}
