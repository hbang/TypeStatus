ARCHS = armv7
TARGET = :clang::5.0

include theos/makefiles/common.mk

THEOS_BUILD_DIR = debs

TWEAK_NAME = TypeStatus TypeStatusRelay TypeStatusClient

TypeStatus_FILES = SpringBoard.xmi
TypeStatus_FRAMEWORKS = UIKit
TypeStatus_CFLAGS = -Qunused-arguments
TypeStatus_LDFLAGS = -fobjc-arc

TypeStatusRelay_FILES = IMAgentRelay.x
TypeStatusRelay_LDFLAGS = -fobjc-arc

TypeStatusClient_FILES = Client.xmi
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_CFLAGS = -Qunused-arguments
TypeStatusClient_LDFLAGS = -fobjc-arc

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

Client.xmi: Global.xm HBTSStatusBarView.mm
	touch $@

SpringBoard.xmi: Global.xm
	touch $@

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN

	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework

ifeq ($(SHIPIT),1)
	find $(THEOS_STAGING_DIR) -iname \*.plist -exec plutil -convert binary1 {} \;
endif

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences; sleep 0.2; sbopenurl 'prefs:root=Cydia&path=TypeStatus'"
else
	install.exec spring
endif
