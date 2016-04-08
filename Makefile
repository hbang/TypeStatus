INSTALL_TARGET_PROCESSES = MobileSMS Preferences

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

ifeq ($(IMAGENT),1)
INSTALL_TARGET_PROCESSES += imagent
endif

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = springboard client relay prefs messages

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
ifneq ($(PACKAGE_BUILDNAME),debug)
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN
endif

	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
