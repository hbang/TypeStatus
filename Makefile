TARGET = :clang

include theos/makefiles/common.mk

THEOS_BUILD_DIR = debs

TWEAK_NAME = TypeStatus
TypeStatus_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
