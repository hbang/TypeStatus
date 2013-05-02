TARGET = :clang

include theos/makefiles/common.mk

THEOS_BUILD_DIR = debs

TWEAK_NAME = TypeStatus
TypeStatus_FILES = Tweak.xm $(wildcard *.m)
TypeStatus_FRAMEWORKS = UIKit CoreGraphics

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework

ifneq ($(DEBUG),1)
	find $(THEOS_STAGING_DIR) -iname \*.plist -exec plutil -convert xml1 {} \;
endif

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences; sbopenurl prefs:root=TypeStatus"
endif
