/* Pywal dwm color template - ~/.config/wal/templates/colors-wal-dwm.h */
static const char normbgcolor[] = "{{color0}}";
static const char normfgcolor[] = "{{color7}}";
static const char selbgcolor[]  = "{{color1}}";
static const char selfgcolor[]  = "{{color7}}";
static const char bordercolor[] = "{{color0}}";
static const char focuscolor[]  = "{{color1}}";

static const char *colors[][3] = {
    /*               fg         bg         border */
    [SchemeNorm] = { "{{color7}}", "{{color0}}", "{{color0}}" },
    [SchemeSel]  = { "{{color7}}", "{{color1}}", "{{color1}}" },
};

/* Tag colors */
static const char *tagsel[][2] = {
    { "{{color7}}", "{{color0}}" },  /* unselected tags */
    { "{{color7}}", "{{color1}}" },  /* selected tag */
};
