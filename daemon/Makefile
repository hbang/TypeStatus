include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ws.hbang.typestatusd
ws.hbang.typestatusd_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m) ../global/HBTSPreferences.m
ws.hbang.typestatusd_DYNAMIC_LIBRARY = 0
ws.hbang.typestatusd_PRIVATE_FRAMEWORKS = ChatKit
ws.hbang.typestatusd_EXTRA_FRAMEWORKS = Cephei
ws.hbang.typestatusd_CFLAGS = -include ../global/Global.h -I../global
ws.hbang.typestatusd_INSTALL_PATH = /Library/Application Support/TypeStatus.bundle/XPCServices
ws.hbang.typestatusd_BUNDLE_EXTENSION = xpc

include $(THEOS_MAKE_PATH)/bundle.mk

after-ws.hbang.typestatusd-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
	$(ECHO_NOTHING)cp ws.hbang.typestatusd.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
	$(ECHO_NOTHING)sudo chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/ws.hbang.typestatusd.plist$(ECHO_END)

	$(ECHO_NOTHING)sudo chown root:wheel "$(THEOS_STAGING_DIR)$(ws.hbang.typestatusd_INSTALL_PATH)/ws.hbang.typestatusd.xpc/ws.hbang.typestatusd"$(ECHO_END)
	$(ECHO_NOTHING)sudo chmod +x "$(THEOS_STAGING_DIR)$(ws.hbang.typestatusd_INSTALL_PATH)/ws.hbang.typestatusd.xpc/ws.hbang.typestatusd"$(ECHO_END)
