#import <dlfcn.h>
#import <Foundation/Foundation.h>

#define YT_BUNDLE_ID @"com.google.ios.youtube"
#define YT_NAME @"YouTube"

@interface SSOConfiguration : NSObject
@end

%hook YTVersionUtils

+ (NSString *)appName {
    return YT_NAME;
}

+ (NSString *)appID {
    return YT_BUNDLE_ID;
}

%end

%hook GCKBUtils

+ (NSString *)appIdentifier {
    return YT_BUNDLE_ID;
}

%end

%hook GPCDeviceInfo

+ (NSString *)bundleId {
    return YT_BUNDLE_ID;
}

%end

%hook OGLBundle

+ (NSString *)shortAppName {
    return YT_NAME;
}

%end

%hook GVROverlayView

+ (NSString *)appName {
    return YT_NAME;
}

%end

%hook OGLPhenotypeFlagServiceImpl

- (NSString *)bundleId {
    return YT_BUNDLE_ID;
}

%end

%hook APMAEU

+ (BOOL)isFAS {
    return YES;
}

%end

%hook GULAppEnvironmentUtil

+ (BOOL)isFromAppStore {
    return YES;
}

%end

%hook SSOConfiguration

- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    [self setValue:YT_NAME forKey:@"_shortAppName"];
    [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    return self;
}

%end

%hook NSBundle

- (NSString *)bundleIdentifier {
    NSArray *address = [NSThread callStackReturnAddresses];
    Dl_info info = {0};
    if (dladdr((void *)[address[2] longLongValue], &info) == 0)
        return %orig;
    NSString *path = [NSString stringWithUTF8String:info.dli_fname];
    if ([path hasPrefix:NSBundle.mainBundle.bundlePath])
        return YT_BUNDLE_ID;
    return %orig;
}

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return YT_NAME;
    return %orig;
}

%end

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
