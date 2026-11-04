/* Print the active keyboard layout index (0 = first layout, 1 = second, ...).
 * "xkb-group next" switches to the next layout first.
 * Build: cc -O2 -o xkb-group xkb-group.c -lX11 */
#include <stdio.h>
#include <string.h>
#include <X11/XKBlib.h>

int main(int argc, char *argv[])
{
	Display *dpy = XOpenDisplay(NULL);
	XkbStateRec state;
	XkbDescPtr desc;
	int count = 1;

	if (!dpy)
		return 1;
	if (XkbGetState(dpy, XkbUseCoreKbd, &state) != Success)
		return 1;

	if (argc > 1 && strcmp(argv[1], "next") == 0) {
		desc = XkbAllocKeyboard();
		if (desc && XkbGetControls(dpy, XkbGroupsWrapMask, desc) == Success && desc->ctrls)
			count = desc->ctrls->num_groups;
		if (count < 1)
			count = 1;
		state.group = (state.group + 1) % count;
		XkbLockGroup(dpy, XkbUseCoreKbd, state.group);
		XSync(dpy, False);
	}

	printf("%d\n", state.group);
	XCloseDisplay(dpy);
	return 0;
}
