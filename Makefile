export TARGET = iphone:clang:latest:7.0

INSTALL_TARGET_PROCESSES = typestatusd MobileSMS Preferences

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

ifeq ($(IMAGENT),1)
INSTALL_TARGET_PROCESSES += imagent
endif

export ADDITIONAL_CFLAGS = -Wextra -Wno-unused-parameter

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = springboard client relay prefs messages

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
ifneq ($(PACKAGE_BUILDNAME)$(IMAGENT),debug)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
	$(ECHO_NOTHING)cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
endif

	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
