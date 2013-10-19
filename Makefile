ARCHS = armv7
TARGET = :clang

include theos/makefiles/common.mk

THEOS_BUILD_DIR = debs

TWEAK_NAME = TypeStatus TypeStatusClient
TypeStatus_FILES = Server.xmi
TypeStatus_PRIVATE_FRAMEWORKS = ChatKit BulletinBoard
TypeStatus_CFLAGS = -Qunused-arguments

TypeStatusClient_FILES = Client.xmi
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_CFLAGS = -Qunused-arguments

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

Client.xmi: HBTSStatusBarView.xm
	touch $@

after-stage::
	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework

ifeq ($(SHIPIT),1)
	find $(THEOS_STAGING_DIR) -iname \*.plist -exec plutil -convert binary1 {} \;
endif

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences; sbopenurl 'prefs:root=Cydia&path=TypeStatus'"
endif
