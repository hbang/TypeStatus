include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusMessages
TypeStatusMessages_FILES = $(wildcard *.xm) $(wildcard *.m) ../global/HBTSConversationPreferences.x
TypeStatusMessages_FRAMEWORKS = UIKit
TypeStatusMessages_PRIVATE_FRAMEWORKS = ChatKit
TypeStatusMessages_EXTRA_FRAMEWORKS = Cephei
TypeStatusMessages_CFLAGS = -I../global -include ../global/Global.h

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall MobileSMS; sleep 0.2; sblaunch com.apple.MobileSMS"
