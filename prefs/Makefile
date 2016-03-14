TARGET = :clang::5.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TypeStatus
TypeStatus_FILES = $(wildcard *.m) $(wildcard *.x) ../global/HBTSConversationPreferences.x
TypeStatus_INSTALL_PATH = /Library/PreferenceBundles
TypeStatus_FRAMEWORKS = CoreGraphics UIKit
TypeStatus_PRIVATE_FRAMEWORKS = Preferences
TypeStatus_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
TypeStatus_WEAK_FRAMEWORKS = Contacts ContactsUI
TypeStatus_CFLAGS = -I../global -include ../global/Global.h

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TypeStatus.plist$(ECHO_END)
