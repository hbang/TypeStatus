include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatus TypeStatusRelay TypeStatusClient

TypeStatus_FILES = SpringBoard.xm
TypeStatus_FRAMEWORKS = UIKit

TypeStatusRelay_FILES = IMAgentRelay.x HBTSConversationPreferences.m
TypeStatusRelay_LIBRARIES = cephei

TypeStatusClient_FILES = Client.xm HBTSPreferences.m HBTSStatusBarForegroundView.xm $(wildcard HBTSStatusBar*ItemView.x)
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_LIBRARIES = cephei

SUBPROJECTS = prefs messages

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN/postrm

	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences MobileSMS"
else
	install.exec spring
endif
