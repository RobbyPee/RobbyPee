/*=============================================================================

Robin Plowman
2004
DSP Computer Vision Library

=============================================================================*/


/* Project level */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <vc/hardware.h>

/******************************************************************************
Functions in other modules accessed by this file.
Specify through module public interface files.
******************************************************************************/

#include "vc_image.h"
#include <vc/vcore.h>
#include "univ.h"
#include "vclib.h"
#include "C:\VideoCore\VC02DK\Projects\vmcs\camplus\camplus_api.h"

#include "cv_library.h"


/******************************************************************************
Public functions contained in this file.
******************************************************************************/

/******************************************************************************
Private typedefs, macros and constants. May also be defined just before a
function or group of functions that use the declaration.
******************************************************************************/
#define SIZEX 240
#define SIZEY 320

/******************************************************************************
Private functions in this file.
Declare as static.
******************************************************************************/

/******************************************************************************
NAME
  main

SYNOPSIS
   int main ( int argc , char *argv[] )

FUNCTION
   Runs the loopback demonstration

RETURNS
   -
******************************************************************************/
typedef struct
{
  int ordering[16];
  int autosolve;
} PUZZLE_GAME_T;

typedef struct rob_RGB565_t {
	unsigned blue:	5;
	unsigned green: 6;
	unsigned red:	5;
} rob_RGB565_t;

rob_RGB565_t       getRGB565( unsigned short int intPixel );
unsigned short int putRGB565( rob_RGB565_t rgbPixel);

void yuv2gray( VC_IMAGE_T *source_yuv_image );
void yuv_copy( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image );
void yuv_transpose( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image );
void yuv_distance( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image );
void yuv_brightness( VC_IMAGE_T *source_yuv_image, int multiplier );
void yuv2bw( VC_IMAGE_T *source_yuv_image, int threshold );
void yuv_subtract( VC_IMAGE_T *yuv_image1, VC_IMAGE_T *yuv_image2 );

void close_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height);
void close_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height);
void close_h_gray(VC_IMAGE_T *source_yuv_image, int SE_width);

void open_gray( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height);
void open_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height);
void open_h_gray(VC_IMAGE_T *source_yuv_image, int SE_width);


void dilate_h_gray( VC_IMAGE_T *source_yuv_image, int SE_width );
void dilate_v_gray( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height );
void dilate_gray( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height );

void erode_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height);
void erode_h_gray( VC_IMAGE_T *source_yuv_image, int SE_width );
void erode_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height );

void yuv2binary( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *dest_bin_image, int threshold );
void binary2yuv(VC_IMAGE_T *source_bin_image, VC_IMAGE_T *dest_yuv_image );
void yuv_AND_binary( VC_IMAGE_T *yuv_image, VC_IMAGE_T *binary_image );
void erode_h_binary( VC_IMAGE_T *binary_image, int SE_width );
void dilate_h_binary( VC_IMAGE_T *binary_image, int SE_width );
void open_h_binary( VC_IMAGE_T *binary_image, int SE_width );
void close_h_binary( VC_IMAGE_T *binary_image, int SE_width );

int  xy2int( int a, int b);
int u=0;
int v=0;

// Assembler functions (in add3.s)
void dilate_h_gray_a(unsigned short int *src, unsigned short int *dest, int SE_width, int im_height, int im_width);
void dilate_h_gray_in_place_a(unsigned short int *src, int SE_width, int im_width);
void erode_h_gray_a(unsigned short int *src, unsigned short int *dest, int SE_width, int im_height, int im_width);
void yuv_transpose_a(unsigned short *src, unsigned short *dest, int src_pitch_bytes, int dest_pitch_bytes, int nblocks);
void yuv_copy_a(unsigned short int *src, unsigned short int *dest, unsigned int size );
void yuv2gray_a(unsigned short int *src, int y_size, int uv_size );
void yuv_dist_a(unsigned short int *src, unsigned short int *dest, int size );
void yuv_brightness_a(unsigned short int *src, int multiplier, int size );
void yuv2bw_a(unsigned short int *src, int size, int threshold );
void yuv_sub_a(unsigned short int *img1, unsigned short int *img2, int size );


void yuv2binary_0row240_a(unsigned short int *dest,int num_rows );
void yuv2binary_row240_a(unsigned short int *src, unsigned short int *dest, int threshold );
void binary2yuv_row240_a(unsigned short int *src, unsigned short int *dest );
void yuv_AND_binary_a(unsigned short int *src, unsigned short int *dest, int size );
void erode_h_bin_in_place_a(unsigned short int *src, short int SE_width);
void dilate_h_bin_in_place_a(unsigned short int *src, short int SE_width);


/*

typedef struct VC_IMAGE_T {
   VC_IMAGE_TYPE_T type;
   long width;           // width in pixels
   long height;          // height in pixels
   long pitch;           // pitch of image_data array in *bytes*
   long size;            // number of *bytes* available in the image_data arry
   void *image_data;     // pixel data
} VC_IMAGE_T;
*/

int main( int argc , char *argv[] )
{
   unsigned char *datay; /* Y input camera buffer */
   unsigned char *datau; /* U input camera buffer */
   unsigned char *datav; /* V input camera buffer */
      //robRGB_T rob_data[SIZEX][SIZEY];
   unsigned short int  *impointer1, *impointer2;

   DISP_MODES_T dispmode = univ_getsafedisplaymode();

   /* The picture is put into the view_img first */
   VC_IMAGE_T *view_img  = vc_image_malloc( VC_IMAGE_RGB565, univ_dispwidth(dispmode), univ_dispheight(dispmode), 0 );

   /* Selected portions are copied to the final lcd image */
   VC_IMAGE_T *lcd_img   = vc_image_malloc( VC_IMAGE_RGB565, univ_dispwidth(dispmode), univ_dispheight(dispmode), 0 );
   VC_IMAGE_T *cam_img;
   VC_IMAGE_T *view_img2 = vc_image_malloc( VC_IMAGE_RGB565, univ_dispwidth(dispmode), univ_dispheight(dispmode), 0 );

   int delay=0;
   int x,y, intPixel1, intPixel2;
   int mirror=0, rotate=(univ_getorientation(dispmode)==DISP_PORTRAIT);

   int maskwidth=48;
   int maskheight=48;
   int xoffset=0;
   int yoffset=0;

   cam_img = vc_image_malloc( VC_IMAGE_YUV420, (~15&univ_dispwidth(dispmode)), (~15&univ_dispheight(dispmode)), rotate );
   VC_IMAGE_T *temp_img = vc_image_malloc( VC_IMAGE_YUV420, (~15&univ_dispwidth(dispmode)), (~15&univ_dispheight(dispmode)), rotate );
   VC_IMAGE_T *temp_img2 = vc_image_malloc( VC_IMAGE_YUV420, (~15&univ_dispwidth(dispmode)), (~15&univ_dispheight(dispmode)), rotate );
   VC_IMAGE_T *cam_img2 = vc_image_malloc( VC_IMAGE_YUV420, (~15&univ_dispwidth(dispmode)), (~15&univ_dispheight(dispmode)), rotate );
   VC_IMAGE_T *orig_img = vc_image_malloc( VC_IMAGE_YUV420, (~15&univ_dispwidth(dispmode)), (~15&univ_dispheight(dispmode)), rotate );


   datay   = vc_image_get_y( cam_img );
   datau   = vc_image_get_u( cam_img );
   datav   = vc_image_get_v( cam_img );

   /* generic initialisation */
   univ_init();
   camplus_init();

   univ_powercontrol("lcd0", 2);
   univ_powercontrol("backlight0", 2);
   univ_lcdcontrol("contrast0", 80);

   camplus_start(cam_img->width, cam_img->height, 2, CAMPLUS_DEFAULT);

   vc_image_present( view_img, dispmode );

	camplus_grab_sync(datay, datau, datav);
	yuv_copy( cam_img, cam_img2);
u=1;
	while(1)  // Never leaves here
   {
      // First capture an image

      /* Grab a frame */
      camplus_grab_sync(datay, datau, datav);

      /*look at buttons*/
      if ((univ_button_pressed(UNIV_UP)) && (u<40))
	  {
         u++;
      }
      if ((univ_button_pressed(UNIV_DOWN)) && (u>0))
	  {
	     u--;
      }
/*      if (univ_button_pressed(UNIV_LEFT)) //&& (v<240))
	  {
         u=4;
      }
      if ( univ_button_pressed(UNIV_RIGHT)) //&& (v>0))
	  {
         u=2;
      }
*/

		//Copy cam_img to cam_img2

		yuv_copy( cam_img, cam_img2);
		yuv_copy( cam_img, orig_img);

		if( u > 1 )
			close_gray( cam_img, temp_img, 5, 6);
		if( u > 2 )
    	    yuv_subtract( cam_img, cam_img2); //cam_img=cam_img-cam_img2
		if(u==3)
			yuv_brightness(cam_img, 3);
		if( u > 3 )
			yuv2bw( cam_img, 35 );
		if( u > 4 )
			//close up gaps between characters
//			close_h_gray(cam_img, 8 );						//USE A RECTANGLE HERE??
			close_gray( cam_img, temp_img, 8, 1);
		if( u > 5) {
			//remove objects smaller than min character height
			open_v_gray(cam_img, temp_img, 3);
			yuv_copy( cam_img, cam_img2 );
		}
		if( u > 6 ) {
			//remove things smaller than max character height
			open_v_gray(cam_img, temp_img, 12);
			yuv_distance( cam_img2, cam_img);
		}
		if( u > 7 )
/*			yuv2binary( cam_img, cam_img2, 148);
			open_h_binary(cam_img2, 20);
			binary2yuv( cam_img2, cam_img);
*/
			open_h_gray(cam_img, 15);			//opening, SE = min plate width USE BINARY
												// then need to DILATE to get true plate size
		if( u > 8 ) {
			yuv_AND_binary( orig_img, cam_img);
			yuv_copy( orig_img, cam_img); }




/******************************************************
//Matlab detector

se = strel('rectangle',[12 26]); %max character size
se2 = strel('rectangle',[2 15]);  %max space between characters
se3 = strel('line',10,90); %min character height
se4 = strel('line',24,90); %max character height
se5 = strel('line',70,0); %max plate width or something height

VLPgray = rgb2gray( VLPin );

I1 = imclose(VLPgray,se)-VLPgray;
I2 = im2bw(I1);
I3 = imclose(I2,se2);
							%I3 = imopen(I3,se3);
I4 = imopen(I3,se3); %
I4=  imopen( I4 - imopen(I3,se4) ,se5);
******************************************************/


/******************************************************
//MOTION DETECTOR
		yuv_copy( cam_img, temp_img);
 		yuv_distance( cam_img2, cam_img);
 		yuv2bw( cam_img, 20 );
 		dilate_gray( cam_img, temp_img2, 15, 15);
		erode_gray( cam_img, temp_img2, 8, 8);
******************************************************/

/*

		yuv2binary( cam_img, cam_img2, 148);
		open_h_binary(cam_img2, u);
		binary2yuv( cam_img2, cam_img);
*/

/*MOTION DETECTOR
		yuv_copy( cam_img, temp_img);
 		yuv_distance( cam_img2, cam_img);
 		yuv2bw( cam_img, 20 );
 		dilate_gray( cam_img, temp_img2, 15, 15);
		erode_gray( cam_img, temp_img2, 8, 8);
*/

		vc_image_convert(view_img,cam_img,mirror,rotate);

      	vc_image_present(view_img , dispmode );

//		yuv_copy( temp_img, cam_img2);

   }

   return 0;
}

/* Gets the RGB data from an unsigned short integer type */
rob_RGB565_t getRGB565( unsigned short int intPixel )
{
	rob_RGB565_t rgbPixel;
	rgbPixel.red   = (intPixel & 0xF800) >> 11;
	rgbPixel.green = (intPixel & 0x07E0) >> 5;
	rgbPixel.blue  = (intPixel & 0x001F);

	return rgbPixel;
}

/*Puts RGB data into an unsigned short integer variable*/
unsigned short int putRGB565( rob_RGB565_t rgbPixel)
{
	unsigned short int intPixel;
	intPixel = (intPixel & 0x07FF) | (rgbPixel.red  << 11);
    intPixel = (intPixel & 0xF81F) | (rgbPixel.green << 5 );
    intPixel = (intPixel & 0xFFE0) | (rgbPixel.blue );

    return intPixel;
}

int                xy2int( int a, int b)
{
	return (SIZEX*b)+a;
}

/******************************************************************************
NAME
   Opening and Closing

	Designed for gray Y componenet

void dilate_h_gray( VC_IMAGE_T *source_yuv_image, int SE_width )
	Main functions. Carries out horizontal dilation

void dilate_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height )
	Carries out transpose, then horizontal dilation, then  transpose
	temp_yuv_image is needed for the transpose as it can not work 'in place'

void dilate_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height)
	Carries out horozontal and vertical dilation

	All return void
******************************************************************************/
// Opening
void open_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height)
{
	erode_gray(source_yuv_image,temp_yuv_image, SE_width, SE_height);
	dilate_gray(source_yuv_image, temp_yuv_image, SE_width, SE_height);
}
void open_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height)
{
	erode_v_gray(  source_yuv_image, temp_yuv_image, SE_height );
	dilate_v_gray( source_yuv_image, temp_yuv_image, SE_height );
}
void open_h_gray(VC_IMAGE_T *source_yuv_image, int SE_width)
{
	erode_h_gray(  source_yuv_image, SE_width );
	dilate_h_gray( source_yuv_image, SE_width );
}
// Closing
void close_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height)
{
	dilate_gray(source_yuv_image, temp_yuv_image, SE_width, SE_height);
	erode_gray(source_yuv_image,temp_yuv_image, SE_width, SE_height);
}
void close_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height)
{
	dilate_v_gray( source_yuv_image, temp_yuv_image, SE_height );
	erode_v_gray(  source_yuv_image, temp_yuv_image, SE_height );
}
void close_h_gray(VC_IMAGE_T *source_yuv_image, int SE_width)
{
	dilate_h_gray( source_yuv_image, SE_width );
	erode_h_gray(  source_yuv_image, SE_width );
}


/******************************************************************************
NAME
   Dilation

   Dilates the Y component of a YUV420 image
   Designed to work on greyscale. Quicker methods exist for binary images

void dilate_h_gray( VC_IMAGE_T *source_yuv_image, int SE_width )
	Main functions. Carries out horizontal dilation

void dilate_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height )
	Carries out transpose, then horizontal dilation, then  transpose
	temp_yuv_image is needed for the transpose as it can not work 'in place'

void dilate_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height)
	Carries out horozontal and vertical dilation

	All return void
******************************************************************************/
void dilate_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height)
{

	dilate_h_gray( source_yuv_image, SE_width );

	dilate_v_gray( source_yuv_image, temp_yuv_image, SE_height );

}
void dilate_h_gray( VC_IMAGE_T *source_yuv_image, int SE_width )
{
	int i;
	unsigned short int *impointer = source_yuv_image->image_data;
	int width =  source_yuv_image -> width;
	int height = source_yuv_image -> height;

	for( i=0; i < height; i+=1, impointer += (width/2)) {
		dilate_h_gray_in_place_a(impointer, SE_width, width);
	}
}

void dilate_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height )
{

   yuv_transpose(source_yuv_image, temp_yuv_image );

   dilate_h_gray(temp_yuv_image, SE_height );

   yuv_transpose(temp_yuv_image, source_yuv_image );

}

/******************************************************************************
NAME
   Erosion

   Erodes the Y component of a YUV420 image
   Designed to work on greyscale. Quicker methods exist for binary images

void erode_h_gray( VC_IMAGE_T *source_yuv_image, int SE_width )
	Main functions. Carries out horizontal Erosion

void erode_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height )
	Carries out transpose, then horizontal Erosion, then  transpose
	temp_yuv_image is needed for the transpose as it can not work 'in place'

void erode_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height)
	Carries out horozontal and vertical Erosion

	All return void
******************************************************************************/
void erode_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_width, int SE_height)
{

	erode_h_gray( source_yuv_image, SE_width );

	erode_v_gray( source_yuv_image, temp_yuv_image, SE_height );

}
void erode_h_gray( VC_IMAGE_T *source_yuv_image, int SE_width )
{
	int i;
	unsigned short int *impointer = source_yuv_image->image_data;
	int width =  source_yuv_image -> width;
	int height = source_yuv_image -> height;

	for( i=0; i < height; i+=1, impointer += (width/2)) {
		erode_h_gray_in_place_a(impointer, SE_width, width);
	}
}

void erode_v_gray(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image, int SE_height )
{

   yuv_transpose(source_yuv_image, temp_yuv_image );

   erode_h_gray(temp_yuv_image, SE_height );

   yuv_transpose(temp_yuv_image, source_yuv_image );

}



/******************************************************************************
NAME
	YUV2Gray

void yuv2gray( VC_IMAGE_T *source_yuv_image )

   	Sets U and V compenents to 128 so image displayed as greyscale.

	Has no efect of dilation and erosion operations as these only work on Y component

	Returns void
******************************************************************************/
void yuv2gray( VC_IMAGE_T *source_yuv_image )
{
	int i;
	unsigned short int *impointer = source_yuv_image->image_data;
	int width =  source_yuv_image -> width;
	int height = source_yuv_image -> height;

	int y_size = height*width;
	int uv_size = y_size/2;

	yuv2gray_a(impointer, y_size, uv_size);
}

/******************************************************************************
NAME
	yuv_transpose

void yuv_transpose(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image )

	Transpose an image and output into destination.

	Can not work in place as transpose a column at a time.
	This would overwrite the next piece of data to be read.

	returns void
******************************************************************************/
void yuv_transpose(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image )
{

   	int width =  source_yuv_image -> width;
	int height = source_yuv_image -> height;
	unsigned short int *src_ptr= source_yuv_image->image_data;
	unsigned short int *dest_ptr= destination_yuv_image->image_data;

	int i;
	int num_blocks = (width>>4);

// Take a column of source and convert to row of dest.

   	for (i = 0; i < height; i += 16, src_ptr += (width<<3), dest_ptr+=8	 ) {
		//                       src pitch     dest pitch
		yuv_transpose_a(src_ptr, dest_ptr, width, height, num_blocks);
		}
     destination_yuv_image -> height = width;
     destination_yuv_image -> width = height;

}
/******************************************************************************
NAME
	YUV copy

void yuv_copy( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image)
	Copies image data and size to destination

	returns void
******************************************************************************/
void yuv_copy( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image)
{
	int width =  source_yuv_image -> width;
	int height = source_yuv_image -> height;
	int size = (width*height)*1.5;
	yuv_copy_a( source_yuv_image->image_data, destination_yuv_image->image_data, size );
	destination_yuv_image -> height = height;
	destination_yuv_image -> width = width;
}
/******************************************************************************
NAME
	YUV_distance

void yuv_distance( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image)
	Store distance between source and destination in destination

	returns void
******************************************************************************/
void yuv_distance( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image )
{
	int width =  source_yuv_image -> width;
	int height = source_yuv_image -> height;
	int size = (width*height);
	yuv_dist_a( source_yuv_image->image_data, destination_yuv_image->image_data, size );
}

/******************************************************************************
NAME
	YUV_brightness

void yuv_brightness( VC_IMAGE_T *source_yuv_image, int multiplier )
	Multiply intensity by 'multiplier'

	returns void
******************************************************************************/
void yuv_brightness( VC_IMAGE_T *source_yuv_image, int multiplier )
{
	int width =  source_yuv_image -> width;
	int height = source_yuv_image -> height;
	int size = (width*height);
	yuv_brightness_a( source_yuv_image->image_data, multiplier, size );
}

/******************************************************************************
NAME
	YUV2bw

void YUV2bw( VC_IMAGE_T *source_yuv_image, int threshold)
	Convert image to bw.
	Threshold is 0-255

	returns void
******************************************************************************/
void yuv2bw( VC_IMAGE_T *source_yuv_image, int threshold )
{
	int width =  source_yuv_image -> width;
	int height = source_yuv_image -> height;
	int size = (width*height);
	yuv2bw_a( source_yuv_image->image_data, size, threshold );
}
/******************************************************************************
NAME
	YUV_subtract

void yuv_subtract( VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *destination_yuv_image)
	Calculate source-destination and store in destination

	returns void
******************************************************************************/
void yuv_subtract( VC_IMAGE_T *yuv_image1, VC_IMAGE_T *yuv_image2 )
{
	int width =  yuv_image1 -> width;
	int height = yuv_image1 -> height;
	int size = (width*height);
	yuv_sub_a( yuv_image1->image_data, yuv_image2->image_data, size );
}
/******************************************************************************
NAME
	yuv2binary

void yuv2binary(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *temp_yuv_image)

	Converts Y part of image to binary
	128 bits padded all around
	256 bits written at a time. Remaining bits of each 256 row that are not image
	data are set to zero

	eg. 240. 128 zeros, (240 data, 16 zeros), then 128 zeros = 512 bits
		320	 128 zeros, 256 data, (64 data, 192 zeros) 128 zeros = 768 bits

	ONLY WORKS FOR WIDTH 240 and HEIGHT 320!!!!!!!!!!

	returns void
******************************************************************************/
void yuv2binary(VC_IMAGE_T *source_yuv_image, VC_IMAGE_T *dest_bin_image, int threshold)
{

	int i;
	unsigned short int *yuv  = source_yuv_image->image_data;
	unsigned short int *bin = dest_bin_image->image_data;

	for( i = 0; i < 320; yuv += 120, bin += 16, i++) {
		yuv2binary_row240_a( yuv, bin, threshold);
	}
}

void binary2yuv(VC_IMAGE_T *source_bin_image, VC_IMAGE_T *dest_yuv_image )
{

	int i;
	unsigned short int *bin  = source_bin_image->image_data;
	unsigned short int *yuv = dest_yuv_image->image_data;

//	bin +=3072;

	for( i = 0; i < 320; yuv += 120, bin += 16, i++) {
		binary2yuv_row240_a( bin, yuv);
	}

}


/******************************************************************************
NAME
	yuv_AND_binary

void yuv_AND_binary( VC_IMAGE_T *yuv_image, VC_IMAGE_T *binary_image )

	Performs AND operation
******************************************************************************/
void yuv_AND_binary( VC_IMAGE_T *yuv_image, VC_IMAGE_T *binary_image )
{

	unsigned short int *yuv = yuv_image->image_data;
	unsigned short int *bin = binary_image->image_data;
	int size = ( yuv_image->width * yuv_image->height );

	yuv_AND_binary_a( yuv, bin, size );
}

void erode_h_binary( VC_IMAGE_T *binary_image, int SE_width )
{
	int i=160*120;
	unsigned short int *bin = binary_image->image_data;


	for( i = 0; i < 320; bin += 16, i++) {
		erode_h_bin_in_place_a(bin, SE_width);
	}

}

void dilate_h_binary( VC_IMAGE_T *binary_image, int SE_width )
{
	int i=160*120;
	unsigned short int *bin = binary_image->image_data;


	for( i = 0; i < 320; bin += 16, i++) {
		dilate_h_bin_in_place_a(bin, SE_width);
	}

}

void open_h_binary( VC_IMAGE_T *binary_image, int SE_width )
{
	erode_h_binary(  binary_image,  SE_width );
	dilate_h_binary( binary_image,  SE_width );
}

void close_h_binary( VC_IMAGE_T *binary_image, int SE_width )
{
	dilate_h_binary( binary_image,  SE_width );
	erode_h_binary(  binary_image,  SE_width );
}

/* The End */






