include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatus

TypeStatus_FILES = $(wildcard *.x) $(wildcard *.m)
TypeStatus_FRAMEWORKS = UIKit
TypeStatus_WEAK_FRAMEWORKS = Contacts
TypeStatus_EXTRA_FRAMEWORKS = Cephei
TypeStatus_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
