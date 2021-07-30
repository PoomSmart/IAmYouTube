#import <CoreFoundation/CoreFoundation.h>

static const CFStringRef YT_BUNDLE_ID = CFSTR("com.google.ios.youtube");
static const CFStringRef YT_NAME = CFSTR("YouTube");

%hookf(CFMutableDictionaryRef, CFBundleGetInfoDictionary, CFBundleRef bundle) {
    CFMutableDictionaryRef dict = %orig(bundle);
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
