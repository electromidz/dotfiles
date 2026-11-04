/* Each block needs its own signal number: dwm uses it to send clicks to the
 * right script, and `pkill -RTMIN+N dwmblocks` refreshes block N. */
static const Block blocks[] = {
	/* icon	command			interval	signal */
	{"",	"blocks/BTC_COIN",	300,	1},
	{"",	"blocks/sb-nettraf",	5,	2},
	{"",	"blocks/wifi",		30,	3},
	// {"",	"blocks/musicplaying",	60,	0},
	// {"",	"blocks/sb-cpu",	60,	0},
	// {"",	"blocks/sb-memory",	60,	0},
	{"",	"blocks/disks",		60,	4},
	{"",	"blocks/systemstat",	30,	5},
	{"",	"blocks/volume",	1,	6},
	{"",	"blocks/kbd-layout",	1,	7},
	{"",	"blocks/sb-clock",	30,	8},
	{"",	"blocks/battery",	60,	10},	/* signal 10: refreshed by battery-care */
};

static char *delim = " | ";
