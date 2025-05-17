NAME     := cv_libaray

COMPILER ?= mw
PLATFORM ?= vc02db
RTOS     ?= none
GAME     ?= TRUE
DEBUG    ?= TRUE

SOURCE   := cv_library.c cv_library.s
VPATH    :=
IPATH    :=

LIBS     := vc_image/vc_image \
            vclib/vclib       \
            vmcs/camplus/camplus

VLLS     :=

SRC_ROOT ?= ../..

DEFINES  := 
DEFINES_GLOBAL := USE_RGB565

CFLAGS   :=

#------------------------------------------------------------------------------
# Common stuff below
#------------------------------------------------------------------------------
include $(SRC_ROOT)/makefiles/common.mk 

# The End
