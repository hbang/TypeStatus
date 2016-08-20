include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusClient

TypeStatusClient_FILES = $(wildcard *.x) $(wildcard *.m) ../global/HBTSPreferences.m
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_EXTRA_FRAMEWORKS = Cephei
TypeStatusClient_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc

HBTSStatusBarForegroundView.x_CFLAGS = -fno-objc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
