#include "../nab/src/nab.h"

#include <stdio.h>
#include <stdlib.h>

static NabProgram *P = NULL;
static int inited = 0;

static void init(void) {
    if (inited) return;
    inited = 1;
    P = nab_read_bc("langs/part.nabc");
    if (!P) fprintf(stderr, "nab_part: failed to load part.nabc\n");
}

double nab_part(int op, double a, double b) {
    init();
    if (!P) return 0.0;
    NabValue args[3] = { nab_mk_int(op), nab_mk_flt(a), nab_mk_flt(b) };
    NabValue out = nab_mk_nil();
    NabStatus st = nab_call_function(P, "nab_part", args, 3, &out);
    if (st != NAB_OK) {
        fprintf(stderr, "nab_part: call failed (%d)\n", st);
        return 0.0;
    }
    return nab_as_float(out);
}
