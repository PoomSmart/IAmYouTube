ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET = iphone:clang:latest:15.0
else
TARGET = iphone:clang:latest:11.0
endif
ARCHS = arm64
PACKAGE_VERSION = 1.3.1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IAmYouTube

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
