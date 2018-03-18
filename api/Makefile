include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = TypeStatusProvider
TypeStatusProvider_FILES = $(wildcard *.m) $(wildcard *.x) $(wildcard *.xm)
TypeStatusProvider_PUBLIC_HEADERS = TypeStatusProvider.h HBTSNotification.h HBTSProvider.h HBTSProviderController.h
TypeStatusProvider_FRAMEWORKS = MobileCoreServices
TypeStatusProvider_PRIVATE_FRAMEWORKS = AppSupport
TypeStatusProvider_EXTRA_FRAMEWORKS = Cephei CydiaSubstrate
TypeStatusProvider_LIBRARIES = rocketbootstrap
TypeStatusProvider_INSTALL_PATH = /usr/lib

include $(THEOS)/makefiles/framework.mk

after-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/Frameworks$(ECHO_END)
