TARGET = :clang::5.0
ARCHS = armv7

include theos/makefiles/common.mk

BUNDLE_NAME = TypeStatus
TypeStatus_FILES = $(wildcard *.xi) $(wildcard *.m)
TypeStatus_INSTALL_PATH = /Library/PreferenceBundles
TypeStatus_FRAMEWORKS = CoreGraphics MessageUI Twitter UIKit
TypeStatus_PRIVATE_FRAMEWORKS = Preferences
TypeStatus_LIBRARIES = hbangprefs
TypeStatus_CFLAGS = -Qunused-arguments

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TypeStatus.plist$(ECHO_END)
