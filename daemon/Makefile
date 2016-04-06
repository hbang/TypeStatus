include $(THEOS)/makefiles/common.mk

TOOL_NAME = typestatusd

typestatusd_FILES = $(wildcard *.x) $(wildcard *.m) ../global/HBTSContactHelper.x
typestatusd_INSTALL_PATH = /usr/libexec
typestatusd_WEAK_FRAMEWORKS = Contacts
typestatusd_PRIVATE_FRAMEWORKS = ChatKit
typestatusd_EXTRA_FRAMEWORKS = Cephei CydiaSubstrate
typestatusd_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk

after-typestatusd-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
	$(ECHO_NOTHING)cp ws.hbang.typestatusd.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)

	$(ECHO_NOTHING)$(PRINT_FORMAT) "Sudo access required to change ownership of daemon files."$(ECHO_END)
	$(ECHO_NOTHING)sudo chown root:wheel $(THEOS_STAGING_DIR)/Library/LaunchDaemons/ws.hbang.typestatusd.plist$(ECHO_END)
	$(ECHO_NOTHING)sudo chown root:wheel $(THEOS_STAGING_DIR)/usr/libexec/typestatusd$(ECHO_END)
