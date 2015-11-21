include $(THEOS)/makefiles/common.mk

SUBPROJECTS = daemon client relay prefs

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst prerm postrm $(THEOS_STAGING_DIR)/DEBIAN

	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences MobileSMS" || true
else
	install.exec spring
endif
