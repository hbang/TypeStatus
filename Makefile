ifeq ($(SIMULATOR),1)
	export TARGET = simulator:latest:7.0
else
	export TARGET = iphone:latest:7.0
endif

INSTALL_TARGET_PROCESSES = MobileSMS Preferences

ifneq ($(RESPRING),0)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

ifeq ($(IMAGENT),1)
	INSTALL_TARGET_PROCESSES += imagent
endif

export ADDITIONAL_CFLAGS = -Wextra -Wno-unused-parameter

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = api springboard client prefs messages

ifneq ($(SIMULATOR),1)
	SUBPROJECTS += relay
endif

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/DEBIAN \
		$(THEOS_STAGING_DIR)/Library/Frameworks \
		$(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp preinst $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
ifneq ($(PACKAGE_BUILDNAME)$(IMAGENT),debug)
	$(ECHO_NOTHING)cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
endif

	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)ln -s /usr/lib/TypeStatus/TypeStatusProvider.framework $(THEOS_STAGING_DIR)/Library/Frameworks/TypeStatusProvider.framework$(ECHO_END)
