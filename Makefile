TARGET := iphone:clang:latest:11.0
ARCHS = arm64
PACKAGE_VERSION = 1.0.1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IAmYouTube

IAmYouTube_FILES = Tweak.x
IAmYouTube_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
