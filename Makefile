TARGET = :clang::5.0

include theos/makefiles/common.mk

TWEAK_NAME = TypeStatus TypeStatusRelay TypeStatusClient

TypeStatus_FILES = SpringBoard.xm
TypeStatus_FRAMEWORKS = UIKit
TypeStatus_LIBRARIES = cephei
TypeStatus_LDFLAGS = -fobjc-arc

TypeStatusRelay_FILES = IMAgentRelay.x
TypeStatusRelay_LDFLAGS = -fobjc-arc

TypeStatusClient_FILES = Client.xm HBTSStatusBarView.mm
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_LDFLAGS = -fobjc-arc

SUBPROJECTS = prefs

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
	install.exec "killall Preferences; sleep 0.2; sbopenurl 'prefs:root=Cydia&path=TypeStatus'"
else
	install.exec spring
endif
