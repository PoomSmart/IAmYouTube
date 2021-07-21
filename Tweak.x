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
    return YT_BUNDLE_ID;
}

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return YT_NAME;
    return %orig;
}

%end