TARGET := iphone:clang:latest:11.0
ARCHS = arm64
PACKAGE_VERSION = 1.1.1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IAmYouTube

$(TWEAK_NAME)_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk
