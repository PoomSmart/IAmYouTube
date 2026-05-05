#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <Foundation/Foundation.h>

#define YT_BUNDLE_ID @"com.google.ios.youtube"
#define YT_NAME      @"YouTube"

#pragma mark - KeyChain Patching

@interface SSOConfiguration : NSObject
@end

static NSString *accessGroupID(void) {
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: @"bundleSeedID",
        (__bridge id)kSecAttrService: @"",
        (__bridge id)kSecReturnAttributes: @YES
    };

    CFDictionaryRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);

    if (status == errSecItemNotFound) {
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    }

    if (status != errSecSuccess) {
        return nil;
    }

    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    if (result) CFRelease(result);

    return accessGroup;
}

#pragma mark - Hooks

%hook YTVersionUtils
+ (NSString *)appName { return YT_NAME; }
+ (NSString *)appID { return YT_BUNDLE_ID; }
%end

%hook GCKBUtils
+ (NSString *)appIdentifier { return YT_BUNDLE_ID; }
%end

%hook GPCDeviceInfo
+ (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook OGLBundle
+ (NSString *)shortAppName { return YT_NAME; }
%end

%hook GVROverlayView
+ (NSString *)appName { return YT_NAME; }
%end

%hook OGLPhenotypeFlagServiceImpl
- (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook APMAEU
+ (BOOL)isFAS { return YES; }
%end

%hook GULAppEnvironmentUtil
+ (BOOL)isFromAppStore { return YES; }
%end

%hook SSOClientLogin
+ (NSString *)defaultSourceString { return YT_BUNDLE_ID; }
%end

%hook SSOConfiguration
- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    if (self) {
        [self setValue:YT_NAME      forKey:@"_shortAppName"];
        [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    }
    return self;
}
%end

%hook YTHotConfig
- (BOOL)clientInfraClientConfigIosEnableFillingEncodedHacksInnertubeContext {
    return NO;
}
%end

#pragma mark - NSBundle Spoofing

%hook NSBundle

+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:YT_BUNDLE_ID]) {
        return NSBundle.mainBundle;
    }
    return %orig(identifier);
}

- (NSString *)bundleIdentifier {
    return [self isEqual:NSBundle.mainBundle] ? YT_BUNDLE_ID : %orig;
}

- (NSDictionary *)infoDictionary {
    if (![self isEqual:NSBundle.mainBundle]) {
        return %orig;
    }

    NSMutableDictionary *info = [%orig mutableCopy];
    if (info[@"CFBundleIdentifier"]) info[@"CFBundleIdentifier"] = YT_BUNDLE_ID;
    if (info[@"CFBundleDisplayName"]) info[@"CFBundleDisplayName"] = YT_NAME;
    if (info[@"CFBundleName"]) info[@"CFBundleName"] = YT_NAME;

    return info;
}

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if (![self isEqual:NSBundle.mainBundle]) {
        return %orig;
    }

    if ([key isEqualToString:@"CFBundleIdentifier"]) {
        return YT_BUNDLE_ID;
    }
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"]) {
        return YT_NAME;
    }

    return %orig;
}

%end

#pragma mark - KeyChain Access Group Fixes

%hook SSOKeychainHelper
+ (NSString *)accessGroup       { return accessGroupID(); }
+ (NSString *)sharedAccessGroup { return accessGroupID(); }
%end

%hook SSOKeychainCore
+ (NSString *)accessGroup       { return accessGroupID(); }
+ (NSString *)sharedAccessGroup { return accessGroupID(); }
%end

#pragma mark - App Group Container Redirect

%hook NSFileManager
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier) {
        NSURL *documentsURL = [[[NSFileManager defaultManager]
            URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }
    return %orig(groupIdentifier);
}
%end