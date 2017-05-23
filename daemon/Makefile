include $(THEOS)/makefiles/common.mk

TOOL_NAME = typestatusd

typestatusd_FILES = $(wildcard *.x) $(wildcard *.m) ../global/HBTSContactHelper.x ../global/HBTSPreferences.m ../global/HBTSStatusBarAlertServer.m
typestatusd_INSTALL_PATH = /Library/Application Support/TypeStatus/typestatusd.app
typestatusd_WEAK_FRAMEWORKS = Contacts
typestatusd_PRIVATE_FRAMEWORKS = ChatKit SpringBoardServices
typestatusd_EXTRA_FRAMEWORKS = Cephei CydiaSubstrate
typestatusd_LIBRARIES = rocketbootstrap
typestatusd_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc
typestatusd_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/tool.mk

after-typestatusd-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
	$(ECHO_NOTHING)cp ws.hbang.typestatusd.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
	$(ECHO_NOTHING)chmod 644 $(THEOS_STAGING_DIR)/Library/LaunchDaemons/ws.hbang.typestatusd.plist$(ECHO_END)

	$(ECHO_NOTHING)mkdir -p "$(THEOS_STAGING_DIR)$(typestatusd_INSTALL_PATH)"$(ECHO_END)
	$(ECHO_NOTHING)cp -r Resources/* "$(THEOS_STAGING_DIR)$(typestatusd_INSTALL_PATH)"$(ECHO_END)
