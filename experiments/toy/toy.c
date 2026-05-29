/*
 * Milestone-0 toy input for the clightgen -> Rocq pipeline.
 *
 * This is NOT SM64 code. It is the smallest self-contained file that exercises the
 * shapes we care about (a global array of object pointers, a pointer out-param write,
 * and a direct global write) so we can validate the whole spine:
 *
 *     toy.c --clightgen--> generated/toy.v --Rocq--> proofs/ToyFrame.v (machine-checked)
 *
 * The two functions below are a positive/negative control pair for a syntactic
 * "does this function assign to global g?" analysis:
 *
 *   - clobber()   DOES assign to the global gUnrelated   -> analysis must say `true`
 *   - set_timer() does NOT assign to gUnrelated          -> analysis must say `false`
 */

struct Object {
    int timer;
    int other;
};

/* A global array of object pointers, echoing SM64's gObjects-style state. */
struct Object *gObjects[10];

/* A scalar global we will reason about preserving. */
int gUnrelated;

/* Writes only through its pointer parameter; never touches gUnrelated. */
void set_timer(struct Object *o) {
    o->timer = 0;
}

/* Directly clobbers the global. The positive control for the analysis. */
void clobber(void) {
    gUnrelated = 7;
}
