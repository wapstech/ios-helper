

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

/**
 * Does ARC support GCD objects?
 * It does if the minimum deployment target is iOS 6+ or Mac OS X 8+
 *
 * @see http://opensource.apple.com/source/libdispatch/libdispatch-228.18/os/object.h
 **/
#if OS_OBJECT_USE_OBJC
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

/**
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif


extern NSString *const kWPReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, NetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    TDNotReachable = 0,
    TDReachableViaWiFi = 2,
    TDReachableViaWWAN = 1
};

@class THReachability;

typedef void (^NetworkReachable)(THReachability * reachability);
typedef void (^NetworkUnreachable)(THReachability * reachability);

@interface THReachability : NSObject

@property (nonatomic, copy) NetworkReachable    reachableBlock;
@property (nonatomic, copy) NetworkUnreachable  unreachableBlock;


@property (nonatomic, assign) BOOL reachableOnWWAN;

+(THReachability *)reachabilityWithHostname:(NSString*)hostname;
// This is identical to the function above, but is here to maintain
//compatibility with Apples original code. (see .m)
+(THReachability *)reachabilityWithHostName:(NSString*)hostname;
+(THReachability *)reachabilityForInternetConnection;
+(THReachability *)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
+(THReachability *)reachabilityForLocalWiFi;
+(BOOL)networkAvailable;
-(THReachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

-(BOOL)startNotifier;
-(void)stopNotifier;

-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
// Is user intervention required?
-(BOOL)isInterventionRequired;

-(NetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;

+ (NSString *)getTHReachibilityType;
+ (BOOL)isUsingWifi;
+ (BOOL)isUsingInternet;
@end
