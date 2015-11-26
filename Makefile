include $(THEOS)/makefiles/common.mk

SUBPROJECTS = springboard client relay prefs messages

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN/postrm

	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences MobileSMS" || true
else
	install.exec spring
endif
