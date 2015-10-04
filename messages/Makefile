include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusMessages
TypeStatusMessages_FILES = $(wildcard *.xm) $(wildcard *.m) ../HBTSConversationPreferences.m
TypeStatusMessages_FRAMEWORKS = UIKit
TypeStatusMessages_PRIVATE_FRAMEWORKS = ChatKit
TypeStatusMessages_LIBRARIES = cephei
TypeStatusMessages_USE_SUBSTRATE = 0

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall MobileSMS; sleep 0.2; sblaunch com.apple.MobileSMS"
