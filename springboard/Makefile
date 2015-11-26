include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatus

TypeStatus_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m)
TypeStatus_FRAMEWORKS = UIKit
TypeStatus_EXTRA_FRAMEWORKS = Cephei
TypeStatus_CFLAGS = -include ../global/Global.h -include ../global/HBTSStatusBarAlertProtocol.h

include $(THEOS_MAKE_PATH)/tweak.mk
