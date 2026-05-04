#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <Foundation/Foundation.h>

#define YT_BUNDLE_ID @"com.google.ios.youtube"
#define YT_NAME @"YouTube"

@interface SSOConfiguration : NSObject
@end

static NSString *accessGroupID() {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: @"bundleSeedID",
        (__bridge id)kSecAttrService: @"",
        (__bridge id)kSecReturnAttributes: @YES
    };

    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query,
                                          (CFTypeRef *)&result);

    if (status == errSecItemNotFound) {
        status = SecItemAdd((__bridge CFDictionaryRef)query,
                            (CFTypeRef *)&result);
    }

    if (status != errSecSuccess) {
        return nil;
    }

    NSString *accessGroup =
        [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];

    return accessGroup;
}

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

%hook SSOClientLogin

+ (NSString *)defaultSourceString {
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

%hook YTHotConfig

- (BOOL)clientInfraClientConfigIosEnableFillingEncodedHacksInnertubeContext { return NO; }

%end

%hook NSBundle

+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:YT_BUNDLE_ID])
        return NSBundle.mainBundle;
    return %orig(identifier);
}

- (NSString *)bundleIdentifier {
    return [self isEqual:NSBundle.mainBundle] ? YT_BUNDLE_ID : %orig;
}

- (NSDictionary *)infoDictionary {
    NSDictionary *dict = %orig;
    if (![self isEqual:NSBundle.mainBundle])
        return %orig;
    NSMutableDictionary *info = [dict mutableCopy];
    if (info[@"CFBundleIdentifier"]) info[@"CFBundleIdentifier"] = YT_BUNDLE_ID;
    if (info[@"CFBundleDisplayName"]) info[@"CFBundleDisplayName"] = YT_NAME;
    if (info[@"CFBundleName"]) info[@"CFBundleName"] = YT_NAME;
    return info;
}

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if (![self isEqual:NSBundle.mainBundle])
        return %orig;
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return YT_NAME;
    return %orig;
}

%end

%hook SSOKeychainHelper
+ (NSString *)accessGroup {
    return accessGroupID();
}
+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}
%end

%hook SSOKeychainCore
+ (NSString *)accessGroup {
    return accessGroupID();
}

+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}
%end

%hook NSFileManager

- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier) {
        NSArray *paths = [[NSFileManager defaultManager]
                          URLsForDirectory:NSDocumentDirectory
                          inDomains:NSUserDomainMask];

        NSURL *documentsURL = paths.lastObject;
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }

    return %orig(groupIdentifier);
}
%end
