include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusRelay

TypeStatusRelay_FILES = $(wildcard *.x) $(wildcard *.m)
TypeStatusRelay_PRIVATE_FRAMEWORKS = IMCore
TypeStatusRelay_EXTRA_FRAMEWORKS = Cephei
TypeStatusRelay_LIBRARIES = rocketbootstrap
TypeStatusRelay_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
