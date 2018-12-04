#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

extern NSString *const kTHReachabilityChangedNotification;
typedef enum {
    THNotReachable = 0,
    THReachableViaWiFi,
    THReachableViaWWAN,
} THNetworkStatus;


@interface THNetStatus : NSObject {
    BOOL thLocalWiFiRef;
    SCNetworkReachabilityRef thReachabilityRef;
}

+(BOOL)networkAvailable;

+ (THNetStatus *)thReachabilityWithHostName:(NSString *)hostName;

+ (THNetStatus *)thReachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

+ (THNetStatus *)thReachabilityForInternetConnection;

+ (THNetStatus *)thReachabilityForLocalWiFi;

+ (NSString *)getTHReachibilityType;

+ (BOOL)isTHUsingWifi;

+ (BOOL)isTHUsingInternet;


- (BOOL)thStartNotifier;

- (void)thStopNotifier;

- (THNetworkStatus)thCurrentReachabilityStatus;

- (BOOL)thConnectionRequired;

@end
