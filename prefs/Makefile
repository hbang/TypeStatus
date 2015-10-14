TARGET = :clang::5.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TypeStatus
TypeStatus_FILES = $(wildcard *.m) $(wildcard *.x)
TypeStatus_INSTALL_PATH = /Library/PreferenceBundles
TypeStatus_FRAMEWORKS = UIKit CoreGraphics
TypeStatus_PRIVATE_FRAMEWORKS = Preferences
# TypeStatus_EXTRA_FRAMEWORKS = CepheiPrefs
TypeStatus_LIBRARIES = cepheiprefs
TypeStatus_CFLAGS = -include ../Global.h

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TypeStatus.plist$(ECHO_END)
