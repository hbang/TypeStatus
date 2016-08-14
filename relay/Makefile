include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusRelay

TypeStatusRelay_FILES = IMAgentRelay.x Conversation.x ../global/HBTSPreferences.m ../global/HBTSConversationPreferences.x
TypeStatusRelay_PRIVATE_FRAMEWORKS = IMCore
TypeStatusRelay_EXTRA_FRAMEWORKS = Cephei
TypeStatusRelay_LIBRARIES = rocketbootstrap
TypeStatusRelay_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
