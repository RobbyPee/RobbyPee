

#ifndef CV_LIBRARY_H
#define CV_LIBRARY_H



// from affine_render.c
/*
void init_model       ( Model_T *m);
void affine_matrix    ( Patch_T *pat, Model_T *m, int nc);
void grab_stripes     ( unsigned char *Y, unsigned char *u, unsigned char *v, Patch_T *patch,
			int width, int height);
			*/

// from add3.s

extern int add( int a, int b, int c);

#endif
