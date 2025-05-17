;*****************************************************************************
;
;NAME yuv_AND_binary_a
;   
;
;INPUT_PARAMS
;   r0 -> YUV image   (8bit) 
;   r1 -> Binary Image (8bit) - output
;   
;
;FUNCTION
;                                   r0                   r1
; void yuv_AND_binary_a(unsigned short *yuv, unsigned short *bin, int size );
;
;SYNOPSIS
;   
;  Perform and AND operation.
;
;******************************************************************************
; r0		YUV
; r1 		Binary  - output image
; r2		Image Size (bytes/pixels)

.globl yuv_AND_binary_a
yuv_AND_binary_a:
		vld H(0,0), r0
		vld H(1,0), r1
		vand H(2,0), H(1,0), H(0,0)
		vst H(2,0), r0
		sub r2, 16
		add r0, 16
		add r1, 16
		cmp r2, 0
		bgt yuv_AND_binary_a
		b lr

;*****************************************************************************
;
;NAME yuv_transpose_a
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> output image
;   r2 -> se radius, ie if 2, width = 2+1+2 = 5.
;
;
;FUNCTION
;                                   r0                   r1         r2                   r3                    r4
; void yuv_transpose_a(unsigned short *src, unsigned short *dest, int src_pitch_bytes, int dest_pitch_bytes, int nblocks);
;
;SYNOPSIS
;   
;  Transpose a 16-deep stripe from src into dest.
;
;******************************************************************************
; r0		Source
; r1 		Destination
; r2 		SRC pitch
; r3     DEST pitch
; r4 		number of repeats

.globl yuv_transpose_a
yuv_transpose_a:
		mov r5, r3								;Writing destination column
		shl r5, 4								;Increment pointer by pitch*16
yuv_transpose1:			
		vld H(0++,0), (r0+=r2) REP 16	;Read source column
		add r0, 16
		vst V(0,0++), (r1+=r3) REP 16	;Write destination column
		add r1, r5
		sub r4, 1
		cmp r4, 0
		bne yuv_transpose1
		b lr
;*****************************************************************************
;
;NAME yuv_copy
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> output image  (8bit)
;   r2 -> size (bytes)
;
;FUNCTION	
; 
;  void yuv_copy_a(unsigned short int *src, unsigned short int *dest, int size );
;
;******************************************************************************
.globl yuv_copy_a
yuv_copy_a:
	  vld H(0,0), r0
	vst H(0,0), r1
	add r0, 16
	add r1, 16
	sub r2, 16
	cmp r2, 0
	bgt yuv_copy_a
	b lr

;*****************************************************************************
;
;NAME yuv_dist_a
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> output image  (8bit)
;   r2 -> size (bytes)
;
;FUNCTION
; 
;  void yuv_dist_a(unsigned short int *src, unsigned short int *dest, int size );
;
;	Distance between src and dst is stored in dst
;
;******************************************************************************
.globl yuv_dist_a
yuv_dist_a:
   vld H(0,0), r0
   vld H(1,0), r1
	vdist H(0,0), H(1,0), H(0,0)
	vst H(0,0), r1
	add r0, 16
	add r1, 16
	sub r2, 16
	cmp r2, 0
	bgt yuv_dist_a
	b lr	

;*****************************************************************************
;
;NAME yuv_brightness_a
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> multiplier
;   r2 -> size (bytes)
;
;FUNCTION
; 
;	void yuv_brightness_a(unsigned short int *src, int multiplier, int size );
;
;	Multiply intensity by r1
;
;******************************************************************************
.globl yuv_brightness_a
yuv_brightness_a:
   vld H(0,0), r0
   vmuls H(1,0), H(0,0), r1
	vst H(1,0), r0
	add r0, 16
	sub r2, 16
	cmp r2, 0
	bgt yuv_brightness_a
	b lr	
;*****************************************************************************
;
;NAME yuv2gray_a
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> y_size (bytes) (eg 320*240 = 76800)
;   r2 -> size of u+v in bytes (eg for 320*240, (160*120)+(160*120)
;
;FUNCTION
; 
;  void yuv2gray_a(unsigned short int *src, unsigned short int *dest, int y_size, int uv_size );
;
;******************************************************************************
.globl yuv2gray_a
yuv2gray_a:
   add r0, r1
   y2g_loop:
   vmov H(0,0), 128
	vst H(0,0), r0
	add r0, 16
	sub r2, 16
	cmp r2, 0
	bgt y2g_loop
	b lr	

;*****************************************************************************
;
;NAME yuv2bw_a
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> size (pixels)
;   r2 -> threshold
;
;FUNCTION
; 
;  void yuv2bw_a(unsigned short int *src, int size, int threshold );
;
;******************************************************************************
.globl yuv2bw_a
yuv2bw_a:
   vld H(0,0), r0
   vsubs H(1,0), H(0,0), r2
   vmuls H(2,0), H(1,0), 255
	vst H(2,0), r0
	add r0, 16
	sub r1, 16
	cmp r1, 0
	bgt yuv2bw_a
	b lr	
;*****************************************************************************
;
;NAME yuv_sub_a
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> output image  (8bit)
;   r2 -> size (bytes)
;
;FUNCTION
; 
;  void yuv_sub_a(unsigned short int *img1, unsigned short int *img2, int size );
;
;	Img1=Img1-Img2
;
;******************************************************************************
.globl yuv_sub_a
yuv_sub_a:
   vld H(0,0), r0
   vld H(1,0), r1
	vsubs H(0,0), H(0,0), H(1,0)
	vst H(0,0), r0
	add r0, 16
	add r1, 16
	sub r2, 16
	cmp r2, 0
	bgt yuv_sub_a
	b lr	

;*****************************************************************************
;
;NAME binary2yuv_row240_a
;   
;
;INPUT_PARAMS
;   r0 -> input pointer   
;   r1 -> output pointer	(8bit) 
;
;FUNCTION
; 
;  void binary2yuv_row240_a(unsigned short int *src, unsigned short int *dest );
;
;	128 bits padding, 240 bits data 16 bits padding, 128 bits padding.
;	16 bytes				32 bytes									16 bytes
;
;******************************************************************************
.globl binary2yuv_row240_a
binary2yuv_row240_a:

;	add r0,16		;r0 now points to start of data
	
	;Load data
	vld VX(16,0), r0	;load 16 deep column of 32 bit data (256 bits)
	;eg. 0110 1010 & 0100 0000 (0x40) = 0100 0000 or 0000 0000
	
	vand V(0,0), V(16,0), 0x80
	vand V(0,1), V(16,0), 0x40
	vand V(0,2), V(16,0), 0x20
	vand V(0,3), V(16,0), 0x10
	vand V(0,4), V(16,0), 0x08
	vand V(0,5), V(16,0), 0x04
	vand V(0,6), V(16,0), 0x02
	vand V(0,7), V(16,0), 0x01


	vand V(0,8),  V(16,16), 0x80
	vand V(0,9),  V(16,16), 0x40
	vand V(0,10), V(16,16), 0x20
	vand V(0,11), V(16,16), 0x10
	vand V(0,12), V(16,16), 0x08
	vand V(0,13), V(16,16), 0x04
	vand V(0,14), V(16,16), 0x02
	vand V(0,15), V(16,16), 0x01

	;last row should be zero
	vmov H(15,0), 0
	
	;convert 0010 0000 's to 1111 1111's
	vmuls H(0++,0), H(0++,0), 255 REP 16
	
	mov r5, 16
	
	vst H(0++,0), (r1+=r5) REP 16
	
	b lr	
	
;*****************************************************************************
;
;NAME yuv2binary_row240_a
;   
;
;INPUT_PARAMS
;   r0 -> input pointer   (8bit) 
;   r1 -> output pointer
;   r2 -> threshold
;
;FUNCTION
; 
;  void yuv2binary_row240_a(unsigned short int *src, unsigned short int *dest, int threshold );
;
;	Work on 32 bytes, ie get 256 pixels at a time from r0
;
;******************************************************************************
.globl yuv2binary_row240_a
yuv2binary_row240_a:

	mov r5, 16

	vld H(0++,0), (r0+=r5) REP 16				;read 256 bytes/pixels
	vmov H(15,0), 0								;put 0 at last 256 bytes as only need 240 for a row
	vsubs H(0++,0), H(0++,0), r2 REP 16		;subtract the threshold value

.if 1
	vmuls H(0++,0), H(0++,0), 255 REP 16	;mltiply by 255 to saturate the value if not 0 to 11111111


	vand V(0,0), V(0,0), 0x80			;10000000	0x80
	vand V(0,1), V(0,1), 0x40			;01000000	0x40
	vand V(0,2), V(0,2), 0x20			;00100000	0x20
	vand V(0,3), V(0,3), 0x10			;00010000	0x10
	vand V(0,4), V(0,4), 0x08			;00001000	0x08
	vand V(0,5), V(0,5), 0x04			;00000100	0x04
	vand V(0,6), V(0,6), 0x02			;00000010	0x02
	vand V(0,7), V(0,7), 0x01			;00000001	0x01

	vand V(0,8),  V(0,8),  0x80			;10000000	0x80
	vand V(0,9),  V(0,9),  0x40			;01000000	0x40
	vand V(0,10), V(0,10), 0x20			;00100000	0x20
	vand V(0,11), V(0,11), 0x10			;00010000	0x10
	vand V(0,12), V(0,12), 0x08			;00001000	0x08
	vand V(0,13), V(0,13), 0x04			;00000100	0x04
	vand V(0,14), V(0,14), 0x02			;00000010	0x02
	vand V(0,15), V(0,15), 0x01			;00000001	0x01

	;perform an AND on 8 horizontal bytes an store

	vmov V(16,0), 0
	vor V(16,0), V(16,0), V(0,0++) REP 8

	vmov V(16,16), 0
	vor V(16,16), V(16,16), V(0,8++) REP 8
	
.else
	vclip H(0++,0), H(0++,0), 1 REP 16 ; replaces the vmuls, gives 0 or 1
	
	vshl  -, V(0,0), 15 CLRA ACC
	vshl  -, V(0,1), 14 ACC
	vshl  -, V(0,2), 13 ACC
	vshl  -, V(0,3), 12 ACC
	vshl  -, V(0,4), 11 ACC
	vshl  -, V(0,5), 10 ACC
	vshl  -, V(0,6), 9 ACC
	vshl  -, V(0,7), 8 ACC
	vshl  -, V(0,8), 7 ACC
	vshl  -, V(0,9), 6 ACC
	vshl  -, V(0,10), 5 ACC
	vshl  -, V(0,11), 4 ACC
	vshl  -, V(0,12), 3 ACC
	vshl  -, V(0,13), 2 ACC
	vshl  -, V(0,14), 1 ACC
	vshl  VX(16,0), V(0,15), 0 ACC
	

.endif

	;First write out 128 pixels (16 bytes) worth of zero data to pad image
;	vmov H(0,0), 0
;	vst H(0,0), r1
;	add r1,16

	vst VX(16,0), r1						;write 32 bytes = 32*16 bits = 256 pixels
;	add r1, 32								;add 32 to destination pointer 32 BIT ALGNED!!!

;	vmov H(0,0), 0							;write 16 bits of zeros/128 pixels as padding
;	vst H(0,0), r1
;	add r1,16

	b lr	
;*****************************************************************************
;
;NAME yuv2binary_0row240_a
;   
;INPUT_PARAMS
;   r0 -> output pointer
;   r1 -> number of rows
;
;FUNCTION
;  void yuv2binary_0row240_a(unsigned short int *dest,int num_rows );
; 
;	Writes out 128+256+128 zero bits. 512->64 bytes
;
;******************************************************************************
.globl yuv2binary_0row240_a
yuv2binary_0row240_a:

	;Write out 128 pixels (16 bytes) worth of zero data to pad image
	mov r2, 16
	vmov H(0,0), 0
	
	y2bin_0row_loop:
		vst H(0,0), (r0+=r2) REP 4 		;write out 64 bytes = 1 row
		sub r1, 1
		add r0, 240
		cmp r1, 0
		bgt y2bin_0row_loop

	b lr	

;*****************************************************************************
;
;NAME dilate_h_gray_in_place_a
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> se radius, ie if 2, width = 2+1+2 = 5.
;   r2 -> image width
;
;FUNCTION
; 
;  extern int dilate_h_gray_a(unsigned short int *src, short int SE_width, im_width);
;
;SYNOPSIS
;  
;   
;
;******************************************************************************
; r0		Source
; r1 		Structuring element width (horizontal)
; r2 		width

.globl dilate_h_gray_in_place_a
dilate_h_gray_in_place_a:

	stm r6-r12,lr,(--sp)   		; free up a few registers

   mov r12, r2						; r12 image width
   sub r12, 32
   
	mov r6, r1						; r6 = radius of SE
	add r7, r6, r6					; r7 = 2*radius of SE

	mov r2, r0						; updated source pointer
	mov r3, r0						; updated destination pointer
  
   mov r8, 0						; x counter
   
   vmov H(0,32), 0
   vld  H(0,48), r2
   add r2, 16						; read in 16 source pixels
   
   dhgip_loop1:

		vmov H(0,0), H(0,32)		; move last 32 pixels to beginnning of VRF row
		vmov H(0,16), H(0,48) 
		
		vld H(0,32), (r2)			; load in next 32 pixels and place at end of VRF
		add r2, 16
		vld H(0,48), (r2)
		add r2, 16
		
		add r8, 32					; add 32 to x position
		
		vmov H(1,0), H(0,0)
		vmov H(1,16), H(0,16)
		vmov H(1,32), H(0,32)
		vmov H(1,48), H(0,48)
		

		mov r4, 1					; loop counter

		dhgip_loop2:					; Calculate the maximum over the SE width
			vmax H(1,0),  H(0,0)+r4,  H(1,0)
			vmax H(1,16), H(0,16)+r4, H(1,16)
			vmax H(1,32), H(0,32)+r4, H(1,32)
			vmax H(1,48), H(0,48)+r4, H(1,48)
			
			add r4, 1
			cmp r4, r7
		ble dhgip_loop2
		
	   mov r4, 64					; Shift the pixels in the VRF 'w' (r6) pixels to the right
	   sub r4, r6
		
		vadd H(2,0),   H(1,0)+r4,  0
		vadd H(2,16),  H(1,16)+r4,  0
		vadd H(2,32),  H(1,32)+r4,  0
		vadd H(2,48),  H(1,48)+r4,  0
		
		vst H(2,16),  (r3)				;save out 32 pixels (32 bytes)
		add r3, 16
		vst H(2,32), (r3)
		add r3, 16

		cmp r8, r12 ;208					  if less than (width-32=240-32=208) then repeat.
	blt dhgip_loop1							; else it is the last row! - go to last row function
	
	;*******************************last row****************************
	; 2 options 
	; a. 32 bytes still to write and r2 is 16 pixels from edge of image (16 bytes to read)
	; b. 16 bytes still to write and r2 is at edge of image (0 bytes to read)
	
	cmp r8, r12 ;208
	beq dhgip_32_left
	b dhgip_16_left
	
	dhgip_next_row:
		
   ldm r6-r12,pc,(sp++)   	; fish the stuff back into r6 etc.

   b lr

; FINSHED ***************************

dhgip_32_left:

	vmov H(0,0), H(0,32)
	vmov H(0,16), H(0,48) 
	
	vld H(0,32), (r2)
	vmov H(0,48), 0
		
	vmov H(1,0), H(0,0)
	vmov H(1,16), H(0,16)
	vmov H(1,32), H(0,32)
	vmov H(1,48), H(0,48)

	mov r4, 1					; loop counter

	dhgip_loop3:
		vmax H(1,0),  H(0,0)+r4,  H(1,0)
		vmax H(1,16), H(0,16)+r4, H(1,16)
		vmax H(1,32), H(0,32)+r4, H(1,32)
		vmax H(1,48), H(0,48)+r4, H(1,48)
			
		add r4, 1
		cmp r4, r7
	ble dhgip_loop3
		
   mov r4, 64
   sub r4, r6
		
	vadd H(2,0),   H(1,0)+r4,  0
	vadd H(2,16),  H(1,16)+r4,  0
	vadd H(2,32),  H(1,32)+r4,  0
	vadd H(2,48),  H(1,48)+r4,  0
		
	vst H(2,16),  (r3)				;save out 32 pixels (32 bytes)
	add r3, 16
	vst H(2,32), (r3)
	
b dhgip_next_row

dhgip_16_left:

	vmov H(0,0), H(0,32)
	vmov H(0,16), H(0,48) 
	vmov H(0,32), 0
		
	vmov H(1,0), H(0,0)
	vmov H(1,16), H(0,16)
	vmov H(1,32), H(0,32)

	mov r4, 1					; loop counter

	dhgip_loop4:
		vmax H(1,0),  H(0,0)+r4,  H(1,0)
		vmax H(1,16), H(0,16)+r4, H(1,16)
		vmax H(1,32), H(0,32)+r4, H(1,32)
			
		add r4, 1
		cmp r4, r7
	ble dhgip_loop4
		
   mov r4, 64
   sub r4, r6
		
	vadd H(2,0),   H(1,0)+r4,  0
	vadd H(2,16),  H(1,16)+r4,  0
	vadd H(2,32),  H(1,32)+r4,  0
	
	vst H(2,16),  (r3)				;save out 16 pixels (16 bytes)

b dhgip_next_row


;*****************************************************************************
;
;NAME erode_h_gray_in_place_a
;   
;
;INPUT_PARAMS
;   r0 -> input image   (8bit)
;   r1 -> se radius, ie if 2, width = 2+1+2 = 5.
;   r2 -> image width
;
;FUNCTION
; 
;  extern int dilate_h_gray_a(unsigned short int *src, short int SE_width, im_width);
;
;SYNOPSIS
;  
;   
;
;******************************************************************************
; r0		Source
; r1 		Structuring element width (horizontal)
; r2 		width

.globl erode_h_gray_in_place_a
erode_h_gray_in_place_a:

	stm r6-r12,lr,(--sp)   		; free up a few registers

   mov r12, r2						; r12 image width
   sub r12, 32
   
	mov r6, r1						; r6 = radius of SE
	add r7, r6, r6					; r7 = 2*radius of SE

	mov r2, r0						; updated source pointer
	mov r3, r0						; updated destination pointer
  
   mov r8, 0						; x counter
   
   vmov H(0,32), 255
   vld  H(0,48), r2
   add r2, 16						; read in 16 source pixels
   
   ehgip_loop1:

		vmov H(0,0), H(0,32)		; move last 32 pixels to beginnning of VRF row
		vmov H(0,16), H(0,48) 
		
		vld H(0,32), (r2)			; load in next 32 pixels and place at end of VRF
		add r2, 16
		vld H(0,48), (r2)
		add r2, 16
		
		add r8, 32					; add 32 to x position
		
		vmov H(1,0), H(0,0)
		vmov H(1,16), H(0,16)
		vmov H(1,32), H(0,32)
		vmov H(1,48), H(0,48)
		

		mov r4, 1					; loop counter

		ehgip_loop2:					; Calculate the minimum over the SE width
			vmin H(1,0),  H(0,0)+r4,  H(1,0)
			vmin H(1,16), H(0,16)+r4, H(1,16)
			vmin H(1,32), H(0,32)+r4, H(1,32)
			vmin H(1,48), H(0,48)+r4, H(1,48)
			
			add r4, 1
			cmp r4, r7
		ble ehgip_loop2
		
	   mov r4, 64					; Shift the pixels in the VRF 'w' (r6) pixels to the right
	   sub r4, r6
		
		vadd H(2,0),   H(1,0)+r4,  0
		vadd H(2,16),  H(1,16)+r4,  0
		vadd H(2,32),  H(1,32)+r4,  0
		vadd H(2,48),  H(1,48)+r4,  0
		
		vst H(2,16),  (r3)				;save out 32 pixels (32 bytes)
		add r3, 16
		vst H(2,32), (r3)
		add r3, 16

		cmp r8, r12 ;208					  if less than (width-32=240-32=208) then repeat.
	blt ehgip_loop1							; else it is the last row! - go to last row function
	
	;*******************************last row****************************
	; 2 options 
	; a. 32 bytes still to write and r2 is 16 pixels from edge of image (16 bytes to read)
	; b. 16 bytes still to write and r2 is at edge of image (0 bytes to read)
	
	cmp r8, r12 ;208
	beq ehgip_32_left
	b ehgip_16_left
	
	ehgip_next_row:
		
   ldm r6-r12,pc,(sp++)   	; fish the stuff back into r6 etc.

   b lr

; FINSHED ***************************

ehgip_32_left:

	vmov H(0,0), H(0,32)
	vmov H(0,16), H(0,48) 
	
	vld H(0,32), (r2)
	vmov H(0,48), 255
		
	vmov H(1,0), H(0,0)
	vmov H(1,16), H(0,16)
	vmov H(1,32), H(0,32)
	vmov H(1,48), H(0,48)

	mov r4, 1					; loop counter

	ehgip_loop3:
		vmin H(1,0),  H(0,0)+r4,  H(1,0)
		vmin H(1,16), H(0,16)+r4, H(1,16)
		vmin H(1,32), H(0,32)+r4, H(1,32)
		vmin H(1,48), H(0,48)+r4, H(1,48)
			
		add r4, 1
		cmp r4, r7
	ble ehgip_loop3
		
   mov r4, 64
   sub r4, r6
		
	vadd H(2,0),   H(1,0)+r4,  0
	vadd H(2,16),  H(1,16)+r4,  0
	vadd H(2,32),  H(1,32)+r4,  0
	vadd H(2,48),  H(1,48)+r4,  0
		
	vst H(2,16),  (r3)				;save out 32 pixels (32 bytes)
	add r3, 16
	vst H(2,32), (r3)
	
b ehgip_next_row

ehgip_16_left:

	vmov H(0,0), H(0,32)
	vmov H(0,16), H(0,48) 
	vmov H(0,32), 255
		
	vmov H(1,0), H(0,0)
	vmov H(1,16), H(0,16)
	vmov H(1,32), H(0,32)

	mov r4, 1					; loop counter

	ehgip_loop4:
		vmin H(1,0),  H(0,0)+r4,  H(1,0)
		vmin H(1,16), H(0,16)+r4, H(1,16)
		vmin H(1,32), H(0,32)+r4, H(1,32)
			
		add r4, 1
		cmp r4, r7
	ble ehgip_loop4
		
   mov r4, 64
   sub r4, r6
		
	vadd H(2,0),   H(1,0)+r4,  0
	vadd H(2,16),  H(1,16)+r4,  0
	vadd H(2,32),  H(1,32)+r4,  0
	
	vst H(2,16),  (r3)				;save out 16 pixels (16 bytes)

b ehgip_next_row

;*****************************************************************************
;
;NAME erode_h_bin_in_place_a
;   
;
;INPUT_PARAMS
;   r0 -> input image 1bpp   (8bit)
;   r1 -> se radius, ie if 2, width = 2+1+2 = 5.
;
;FUNCTION
; 
; void erode_h_bin_in_place_a(unsigned short int *src, short int SE_width);
;
;SYNOPSIS
;  
;   
;
;******************************************************************************
; r0		Source
; r1 		Structuring element width (horizontal)

.globl erode_h_bin_in_place_a
erode_h_bin_in_place_a:

   
	mov r2, r0
	; load in 32 bytes, 256 pixels, 240 data, 12 0's
	
	vld H(0,16), r2
	add r2, 16
	vld H(0,32), r2
	add r2, 16
	
	vmov H(0,0),  0xFF
	vmov H(0,48), 0xFF

   mov r4, 1 ;Horizontal offset
   

	;Perform bit shifts of 1..7 and store in rows below
	;	H(1,0) = H(0,0) << 1
	;  ..       ..
	;  H(7,0) = H(0,0) << 7
;x=0-15
	vshl H(1,0), H(0,0), 1
	vlsr H(2,0), H(0,0)+r4, 7
	vor H(1,0), H(1,0),H(2,0)
	
	vshl H(2,0), H(0,0), 2
	vlsr H(3,0), H(0,0)+r4, 6
	vor H(2,0), H(2,0), H(3,0)

	vshl H(3,0), H(0,0), 3
	vlsr H(4,0), H(0,0)+r4, 5
	vor H(3,0), H(3,0),H(4,0)

	vshl H(4,0), H(0,0), 4
	vlsr H(5,0), H(0,0)+r4, 4
	vor H(4,0), H(4,0),H(5,0)

	vshl H(5,0), H(0,0), 5
	vlsr H(6,0), H(0,0)+r4, 3
	vor H(5,0), H(5,0),H(6,0)

	vshl H(6,0), H(0,0), 6
	vlsr H(7,0), H(0,0)+r4, 2
	vor H(6,0), H(6,0),H(7,0)

	vshl H(7,0), H(0,0), 7
	vlsr H(8,0), H(0,0)+r4, 1
	vor H(7,0), H(7,0),H(8,0)

;x=16-31
	vshl H(1,16), H(0,16), 1
	vlsr H(2,16), H(0,16)+r4, 7
	vor H(1,16), H(1,16),H(2,16)
	
	vshl H(2,16), H(0,16), 2
	vlsr H(3,16), H(0,16)+r4, 6
	vor H(2,16), H(2,16), H(3,16)

	vshl H(3,16), H(0,16), 3
	vlsr H(4,16), H(0,16)+r4, 5
	vor H(3,16), H(3,16),H(4,16)

	vshl H(4,16), H(0,16), 4
	vlsr H(5,16), H(0,16)+r4, 4
	vor H(4,16), H(4,16),H(5,16)

	vshl H(5,16), H(0,16), 5
	vlsr H(6,16), H(0,16)+r4, 3
	vor H(5,16), H(5,16),H(6,16)

	vshl H(6,16), H(0,16), 6
	vlsr H(7,16), H(0,16)+r4, 2
	vor H(6,16), H(6,16),H(7,16)

	vshl H(7,16), H(0,16), 7
	vlsr H(8,16), H(0,16)+r4, 1
	vor H(7,16), H(7,16),H(8,16)

;x=32-47
	vshl H(1,32), H(0,32), 1
	vlsr H(2,32), H(0,32)+r4, 7
	vor H(1,32), H(1,32),H(2,32)
	
	vshl H(2,32), H(0,32), 2
	vlsr H(3,32), H(0,32)+r4, 6
	vor H(2,32), H(2,32), H(3,32)

	vshl H(3,32), H(0,32), 3
	vlsr H(4,32), H(0,32)+r4, 5
	vor H(3,32), H(3,32),H(4,32)

	vshl H(4,32), H(0,32), 4
	vlsr H(5,32), H(0,32)+r4, 4
	vor H(4,32), H(4,32),H(5,32)

	vshl H(5,32), H(0,32), 5
	vlsr H(6,32), H(0,32)+r4, 3
	vor H(5,32), H(5,32),H(6,32)

	vshl H(6,32), H(0,32), 6
	vlsr H(7,32), H(0,32)+r4, 2
	vor H(6,32), H(6,32),H(7,32)

	vshl H(7,32), H(0,32), 7
	vlsr H(8,32), H(0,32)+r4, 1
	vor H(7,32), H(7,32),H(8,32)

;48-63 - ALL ZEROS. 

	vmov H(0++,48), 0 REP 8
	
;Work out erosion
	mov r2, 0
	add r2, r1, r1		;r2 = 2*radius
	;Initial values
	mov r3, 1			;bit/vertical offset
	mov r4, 0			;horizontal offset
	mov r5, 0
	
	;Copy row 0 to row 16
	vmov H(16,0),  H(0,0)
	vmov H(16,16), H(0,16)
	vmov H(16,32), H(0,32)
	vmov H(16,48), H(0,48)
	
	
	ehbip1:
	cmp r2, 0
	beq ehbip3
		;if r3 = 8 then r3 = 0, r4=r4+1
		cmp r3, 8
			beq ehbip2

		;set offset vector
		mov r5, r3			;Vertical offset (0-8)
		shl r5, 6			;Shift left by 6 bits
		or r5, r4			;or with the horizontal offset (0-16)
		vand H(16,0), H(0,0)+r5,  H(16,0)
		vand H(16,16), H(0,16)+r5, H(16,16)
		vand H(16,32), H(0,32)+r5, H(16,32)
		vand H(16,48), H(0,48)+r5, H(16,48)
		sub r2, 1
		;Increase vertical offset
		add r3, 1
	b ehbip1
	
	ehbip2:
		mov r3, 0
		add r4, 1
	b ehbip1

	ehbip3:
	;Now move row 16 w pixels to the left
	;Therefore offset is 64-w
	;complicated as horizontal bytes offset and left bit shit needed.

	;r1=w
	;r2=LEFT horizontal shift
	;r3=bit shift

	vmov H(17,0), H(16,0)
	vmov H(17,16), H(16,16)
	vmov H(17,32), H(16,32)
	vmov H(17,48), H(16,48)
	

	vmov H(18,0), H(0,0)
	vmov H(18,16), H(0,16)
	vmov H(18,32), H(0,32)
	vmov H(18,48), H(0,48)


	mov r2, 0
	mov r3, r1		;r3 = w

	ehbip4:
	 	cmp r3, 8	;if r3 < 7 then finished
			blt ehbip5
		sub r3, 8	;r3 = r4 -8
		add r2, 1	;r2 ++
	b ehbip4

ehbip5:
   cmp r3, 0
   bgt ehbip6
   
ehbip8:
	cmp r2, 0
	bgt ehbip7

ehbip9:
	;Save out
	mov r2, r0
	vst H(18,16), r2
	add r2, 16
	vst H(18,32), r2

	b lr

ehbip6:
	;Perform bit shift right on row H(16,0) and put in H(17,0)
	mov r4, 63
	mov r5, 8
	sub r5, r3
	
	vlsr H(17,0), H(16,0), r3
	vshl H(18,0), H(16,0)+r4, r5
	vor H(17,0), H(18,0), H(17,0)

	vlsr H(17,16), H(16,16), r3
	vshl H(18,16), H(16,16)+r4, r5
	vor H(17,16), H(18,16), H(17,16)

	vlsr H(17,32), H(16,32), r3
	vshl H(18,32), H(16,32)+r4, r5
	vor H(17,32), H(18,32), H(17,32)

	vlsr H(17,48), H(16,48), r3
	vshl H(18,48), H(16,48)+r4, r5
	vor H(17,48), H(18,48), H(17,48)
	
	vmov H(18,0), H(17,0)
	vmov H(18,16), H(17,16)
	vmov H(18,32), H(17,32)
	vmov H(18,48), H(17,48)
b ehbip8
	
	
ehbip7:
	;Now perform horizontal shift
	mov r4, 64
	sub r4, r2
	vmov H(18,0), 0
	vmov H(18,16), 0
	vmov H(18,32), 0
	vmov H(18,48), 0
	
	
	vadd H(18,0),   H(17,0)+r4,  0
	vadd H(18,16),  H(17,16)+r4,  0
	vadd H(18,32),  H(17,32)+r4,  0
	vadd H(18,48),  H(17,48)+r4,  0
b ehbip9


;*****************************************************************************
;
;NAME dilate_h_bin_in_place_a
;   
;
;INPUT_PARAMS
;   r0 -> input image 1bpp   (8bit)
;   r1 -> se radius, ie if 2, width = 2+1+2 = 5.
;
;FUNCTION
; 
; void dilate_h_bin_in_place_a(unsigned short int *src, short int SE_width);
;
;SYNOPSIS
;  
;   
;
;******************************************************************************
; r0		Source
; r1 		Structuring element width (horizontal)

.globl dilate_h_bin_in_place_a
dilate_h_bin_in_place_a:

   
	mov r2, r0
	; load in 32 bytes, 256 pixels, 240 data, 12 0's
	
	vld H(0,16), r2
	add r2, 16
	vld H(0,32), r2
	add r2, 16
	
	vmov H(0,0),  0
	vmov H(0,48), 0

   mov r4, 1 ;Horizontal offset
   

	;Perform bit shifts of 1..7 and store in rows below
	;	H(1,0) = H(0,0) << 1
	;  ..       ..
	;  H(7,0) = H(0,0) << 7
;x=0-15
	vshl H(1,0), H(0,0), 1
	vlsr H(2,0), H(0,0)+r4, 7
	vor H(1,0), H(1,0),H(2,0)
	
	vshl H(2,0), H(0,0), 2
	vlsr H(3,0), H(0,0)+r4, 6
	vor H(2,0), H(2,0), H(3,0)

	vshl H(3,0), H(0,0), 3
	vlsr H(4,0), H(0,0)+r4, 5
	vor H(3,0), H(3,0),H(4,0)

	vshl H(4,0), H(0,0), 4
	vlsr H(5,0), H(0,0)+r4, 4
	vor H(4,0), H(4,0),H(5,0)

	vshl H(5,0), H(0,0), 5
	vlsr H(6,0), H(0,0)+r4, 3
	vor H(5,0), H(5,0),H(6,0)

	vshl H(6,0), H(0,0), 6
	vlsr H(7,0), H(0,0)+r4, 2
	vor H(6,0), H(6,0),H(7,0)

	vshl H(7,0), H(0,0), 7
	vlsr H(8,0), H(0,0)+r4, 1
	vor H(7,0), H(7,0),H(8,0)

;x=16-31
	vshl H(1,16), H(0,16), 1
	vlsr H(2,16), H(0,16)+r4, 7
	vor H(1,16), H(1,16),H(2,16)
	
	vshl H(2,16), H(0,16), 2
	vlsr H(3,16), H(0,16)+r4, 6
	vor H(2,16), H(2,16), H(3,16)

	vshl H(3,16), H(0,16), 3
	vlsr H(4,16), H(0,16)+r4, 5
	vor H(3,16), H(3,16),H(4,16)

	vshl H(4,16), H(0,16), 4
	vlsr H(5,16), H(0,16)+r4, 4
	vor H(4,16), H(4,16),H(5,16)

	vshl H(5,16), H(0,16), 5
	vlsr H(6,16), H(0,16)+r4, 3
	vor H(5,16), H(5,16),H(6,16)

	vshl H(6,16), H(0,16), 6
	vlsr H(7,16), H(0,16)+r4, 2
	vor H(6,16), H(6,16),H(7,16)

	vshl H(7,16), H(0,16), 7
	vlsr H(8,16), H(0,16)+r4, 1
	vor H(7,16), H(7,16),H(8,16)

;x=32-47
	vshl H(1,32), H(0,32), 1
	vlsr H(2,32), H(0,32)+r4, 7
	vor H(1,32), H(1,32),H(2,32)
	
	vshl H(2,32), H(0,32), 2
	vlsr H(3,32), H(0,32)+r4, 6
	vor H(2,32), H(2,32), H(3,32)

	vshl H(3,32), H(0,32), 3
	vlsr H(4,32), H(0,32)+r4, 5
	vor H(3,32), H(3,32),H(4,32)

	vshl H(4,32), H(0,32), 4
	vlsr H(5,32), H(0,32)+r4, 4
	vor H(4,32), H(4,32),H(5,32)

	vshl H(5,32), H(0,32), 5
	vlsr H(6,32), H(0,32)+r4, 3
	vor H(5,32), H(5,32),H(6,32)

	vshl H(6,32), H(0,32), 6
	vlsr H(7,32), H(0,32)+r4, 2
	vor H(6,32), H(6,32),H(7,32)

	vshl H(7,32), H(0,32), 7
	vlsr H(8,32), H(0,32)+r4, 1
	vor H(7,32), H(7,32),H(8,32)

;48-63 - ALL ZEROS. 

	vmov H(0++,48), 0 REP 8
	
;Work out dilation
	mov r2, 0
	add r2, r1, r1		;r2 = 2*radius
	;Initial values
	mov r3, 1			;bit/vertical offset
	mov r4, 0			;horizontal offset
	mov r5, 0
	
	;Copy row 0 to row 16
	vmov H(16,0),  H(0,0)
	vmov H(16,16), H(0,16)
	vmov H(16,32), H(0,32)
	vmov H(16,48), H(0,48)
	
	
	dhbip1:
	cmp r2, 0
	beq dhbip3
		;if r3 = 8 then r3 = 0, r4=r4+1
		cmp r3, 8
			beq dhbip2

		;set offset vector
		mov r5, r3			;Vertical offset (0-8)
		shl r5, 6			;Shift left by 6 bits
		or r5, r4			;or with the horizontal offset (0-16)
		vor H(16,0), H(0,0)+r5,  H(16,0)
		vor H(16,16), H(0,16)+r5, H(16,16)
		vor H(16,32), H(0,32)+r5, H(16,32)
		vor H(16,48), H(0,48)+r5, H(16,48)
		sub r2, 1
		;Increase vertical offset
		add r3, 1
	b dhbip1
	
	dhbip2:
		mov r3, 0
		add r4, 1
	b dhbip1

	dhbip3:
	;Now move row 16 w pixels to the left
	;Therefore offset is 64-w
	;complicated as horizontal bytes offset and left bit shit needed.

	;r1=w
	;r2=LEFT horizontal shift
	;r3=bit shift

	vmov H(17,0), H(16,0)
	vmov H(17,16), H(16,16)
	vmov H(17,32), H(16,32)
	vmov H(17,48), H(16,48)
	

	vmov H(18,0), H(0,0)
	vmov H(18,16), H(0,16)
	vmov H(18,32), H(0,32)
	vmov H(18,48), H(0,48)


	mov r2, 0
	mov r3, r1		;r3 = w

	dhbip4:
	 	cmp r3, 8	;if r3 < 7 then finished
			blt dhbip5
		sub r3, 8	;r3 = r4 -8
		add r2, 1	;r2 ++
	b dhbip4

dhbip5:
   cmp r3, 0
   bgt dhbip6
   
dhbip8:
	cmp r2, 0
	bgt dhbip7

dhbip9:
	;Save out
	mov r2, r0
	vst H(18,16), r2
	add r2, 16
	vst H(18,32), r2

	b lr

dhbip6:
	;Perform bit shift right on row H(16,0) and put in H(17,0)
	mov r4, 63
	mov r5, 8
	sub r5, r3
	
	vlsr H(17,0), H(16,0), r3
	vshl H(18,0), H(16,0)+r4, r5
	vor H(17,0), H(18,0), H(17,0)

	vlsr H(17,16), H(16,16), r3
	vshl H(18,16), H(16,16)+r4, r5
	vor H(17,16), H(18,16), H(17,16)

	vlsr H(17,32), H(16,32), r3
	vshl H(18,32), H(16,32)+r4, r5
	vor H(17,32), H(18,32), H(17,32)

	vlsr H(17,48), H(16,48), r3
	vshl H(18,48), H(16,48)+r4, r5
	vor H(17,48), H(18,48), H(17,48)
	
	vmov H(18,0), H(17,0)
	vmov H(18,16), H(17,16)
	vmov H(18,32), H(17,32)
	vmov H(18,48), H(17,48)
b dhbip8
	
	
dhbip7:
	;Now perform horizontal shift
	mov r4, 64
	sub r4, r2
	vmov H(18,0), 0
	vmov H(18,16), 0
	vmov H(18,32), 0
	vmov H(18,48), 0
	
	
	vadd H(18,0),   H(17,0)+r4,  0
	vadd H(18,16),  H(17,16)+r4,  0
	vadd H(18,32),  H(17,32)+r4,  0
	vadd H(18,48),  H(17,48)+r4,  0
b dhbip9
 