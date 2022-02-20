TARGET := iphone:clang:latest:11.0
ARCHS = arm64
PACKAGE_VERSION = 1.2.0
DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IAmYouTube

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
