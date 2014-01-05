ARCHS = armv7
TARGET = :clang::5.0

include theos/makefiles/common.mk

THEOS_BUILD_DIR = debs

TWEAK_NAME = TypeStatus TypeStatusClient

TypeStatus_FILES = Server.xmi
TypeStatus_FRAMEWORKS = Security
TypeStatus_PRIVATE_FRAMEWORKS = BulletinBoard ChatKit IMCore IMDaemonCore UIKit
TypeStatus_CFLAGS = -Qunused-arguments

TypeStatusClient_FILES = Client.xmi
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_CFLAGS = -Qunused-arguments

SUBPROJECTS = prefs
RESPRING = 0

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

Client.xmi: Global.xm HBTSStatusBarView.mm
	touch $@

Server.xmi: Global.xm HBTSBulletinProvider.m
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
	@# install.exec "killall Preferences; sbopenurl 'prefs:root=Cydia&path=TypeStatus'"
	install.exec "killall MobileSMS; sblaunch com.apple.MobileSMS"
