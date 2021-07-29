#import <CoreFoundation/CoreFoundation.h>

static const CFStringRef YT_BUNDLE_ID = CFSTR("com.google.ios.youtube");
static const CFStringRef YT_NAME = CFSTR("YouTube");

%hookf(CFMutableDictionaryRef, _CFBundleCopyInfoDictionaryInDirectoryWithVersion, CFAllocatorRef alloc, CFURLRef url, CFURLRef *infoPlistUrl, uint8_t version) {
    CFMutableDictionaryRef dict = %orig(alloc, url, infoPlistUrl, version);
    if (dict != NULL) {
        CFStringRef packageType = (CFStringRef)CFDictionaryGetValue(dict, CFSTR("CFBundlePackageType"));
        if (packageType != NULL && CFStringCompare(packageType, CFSTR("APPL"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            CFStringRef currentBundleIdentifier = (CFStringRef)CFDictionaryGetValue(dict, kCFBundleIdentifierKey);
            if (currentBundleIdentifier != NULL && CFStringHasPrefix(currentBundleIdentifier, YT_BUNDLE_ID)) {
                CFDictionarySetValue(dict, kCFBundleIdentifierKey, YT_BUNDLE_ID);
                CFDictionarySetValue(dict, kCFBundleNameKey, YT_NAME);
                CFDictionarySetValue(dict, CFSTR("CFBundleDisplayName"), YT_NAME);
            }
        }
    }
    return dict;
}

%ctor {
    MSImageRef cf = MSGetImageByName("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation");
    %init(_CFBundleCopyInfoDictionaryInDirectoryWithVersion = (void *)MSFindSymbol(cf, "__CFBundleCopyInfoDictionaryInDirectoryWithVersion"));
}