include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusClient

TypeStatusClient_FILES = Client.xm HBTSPreferences.m HBTSStatusBarForegroundView.xm $(wildcard HBTSStatusBar*ItemView.x)
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_LIBRARIES = cephei
TypeStatusClient_CFLAGS = -include ../Global.h

include $(THEOS_MAKE_PATH)/tweak.mk
