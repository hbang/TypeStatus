include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusClient

TypeStatusClient_FILES = $(wildcard *.x) $(wildcard *.xm) $(wildcard *.m) ../global/HBTSPreferences.m
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_EXTRA_FRAMEWORKS = Cephei
TypeStatusClient_CFLAGS = -I../global -include ../global/Global.h

include $(THEOS_MAKE_PATH)/tweak.mk
