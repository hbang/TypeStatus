include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusClient

TypeStatusClient_FILES = $(wildcard *.x) $(wildcard *.xm) $(wildcard *.m)
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_EXTRA_FRAMEWORKS = Cephei
TypeStatusClient_CFLAGS = -include ../Global.h
TypeStatusClient_USE_SUBSTRATE = 0

include $(THEOS_MAKE_PATH)/tweak.mk
