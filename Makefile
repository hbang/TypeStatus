ifeq ($(SIMULATOR),1)
	export TARGET = simulator:latest:7.0
else
	export TARGET = iphone:latest:7.0
endif

INSTALL_TARGET_PROCESSES = MobileSMS Preferences

ifneq ($(RESPRING),0)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

ifeq ($(IMAGENT),1)
	INSTALL_TARGET_PROCESSES += imagent
endif

export ADDITIONAL_CFLAGS = -Wextra -Wno-unused-parameter -I$(THEOS_PROJECT_DIR)/global -include $(THEOS_PROJECT_DIR)/global/Global.h -fobjc-arc
export ADDITIONAL_LDFLAGS = -F$(THEOS_OBJ_DIR)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatus TypeStatusClient TypeStatusRelay TypeStatusMessages

TypeStatus_FILES = $(wildcard springboard/*.[xm])
TypeStatus_FRAMEWORKS = UIKit
TypeStatus_EXTRA_FRAMEWORKS = Cephei
TypeStatus_LIBRARIES = rocketbootstrap
TypeStatus_LDFLAGS = -framework TypeStatusProvider

TypeStatusClient_FILES = $(wildcard client/*.[xm])
TypeStatusClient_FRAMEWORKS = UIKit CoreGraphics
TypeStatusClient_EXTRA_FRAMEWORKS = Cephei
TypeStatusClient_LIBRARIES = rocketbootstrap MobileGestalt
TypeStatusClient_LDFLAGS = -framework TypeStatusProvider

client/HBTSStatusBarForegroundView.x_CFLAGS = -fno-objc-arc

TypeStatusRelay_FILES = $(wildcard relay/*.[xm])
TypeStatusRelay_PRIVATE_FRAMEWORKS = IMCore
TypeStatusRelay_EXTRA_FRAMEWORKS = Cephei
TypeStatusRelay_LIBRARIES = rocketbootstrap

TypeStatusMessages_FILES = $(wildcard messages/*.[xm])
TypeStatusMessages_FRAMEWORKS = UIKit
TypeStatusMessages_PRIVATE_FRAMEWORKS = ChatKit
TypeStatusMessages_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS = api prefs

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/DEBIAN \
		$(THEOS_STAGING_DIR)/Library/Frameworks \
		$(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp preinst $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
ifneq ($(PACKAGE_BUILDNAME)$(IMAGENT),debug)
	$(ECHO_NOTHING)cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
endif

	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)ln -s /usr/lib/TypeStatus/TypeStatusProvider.framework $(THEOS_STAGING_DIR)/Library/Frameworks/TypeStatusProvider.framework$(ECHO_END)

docs: stage
	$(ECHO_BEGIN)$(PRINT_FORMAT_MAKING) "Generating docs"; jazzy --module-version $(THEOS_PACKAGE_BASE_VERSION)$(ECHO_END)
	$(ECHO_BEGIN)rm -rf docs/undocumented.json build/$(ECHO_END)

ifeq ($(FINALPACKAGE),1)
before-package:: docs
endif

.PHONY: docs
