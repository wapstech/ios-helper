#import <sys/socket.h>
#import <arpa/inet.h>
#import <CoreFoundation/CoreFoundation.h>
#import "THNetStatus.h"
#import "TutuUtils.h"


#define kCSShouldPrintReachabilityFlags 0

static void CSPrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char *comment) {
#if kCSShouldPrintReachabilityFlags
	
//    NSLog(@"CSNetReachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
//		  (flags & kSCNetworkReachabilityFlagsIsWWAN)				? 'W' : '-',
//		  (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
//		  (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
//		  (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
//		  (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
//		  (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
//		  (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
//		  (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
//		  (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
//		  comment
//		  );
#endif
}


@implementation THNetStatus


static void CSReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in THReachabilityCallback");
    NSCAssert([(NSObject *) info isKindOfClass:[THNetStatus class]], @"info was wrong class in CSReachabilityCallback");

    NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];

    THNetStatus *noteObject = (THNetStatus *) info;
    [[NSNotificationCenter defaultCenter] postNotificationName:kTHReachabilityChangedNotification object:noteObject];

    [myPool release];
}

- (BOOL)thStartNotifier {
    BOOL retVal = NO;
    SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(thReachabilityRef, CSReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(thReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            retVal = YES;
        }
    }
    return retVal;
}

- (void)thStopNotifier {
    if (thReachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(thReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)dealloc {
    [self thStopNotifier];
    if (thReachabilityRef != NULL) {
        CFRelease(thReachabilityRef);
    }
    [super dealloc];
}

+ (THNetStatus *)thReachabilityWithHostName:(NSString *)hostName; {
    THNetStatus *retVal = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL) {
        retVal = [[[self alloc] init] autorelease];
        if (retVal != NULL) {
            retVal->thReachabilityRef = reachability;
            retVal->thLocalWiFiRef = NO;
        }
    }
    return retVal;
}

+ (THNetStatus *)thReachabilityWithAddress:(const struct sockaddr_in *)hostAddress; {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *) hostAddress);
    THNetStatus *retVal = NULL;
    if (reachability != NULL) {
        retVal = [[[self alloc] init] autorelease];
        if (retVal != NULL) {
            retVal->thReachabilityRef = reachability;
            retVal->thLocalWiFiRef = NO;
        }
    }
    return retVal;
}

+ (THNetStatus *)thReachabilityForInternetConnection; {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return [self thReachabilityWithAddress:&zeroAddress];
}

+ (THNetStatus *)thReachabilityForLocalWiFi; {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    THNetStatus *retVal = [self thReachabilityWithAddress:&localWifiAddress];
    if (retVal != NULL) {
        retVal->thLocalWiFiRef = YES;
    }
    return retVal;
}

+(BOOL)networkAvailable
{
    if ([[THNetStatus thReachabilityForLocalWiFi] thCurrentReachabilityStatus] != THNotReachable) {
        return YES;
    }
    if ([[THNetStatus thReachabilityForInternetConnection] thCurrentReachabilityStatus] != THNotReachable) {
        return YES;
    }
    return NO;
}


+ (BOOL)isTHUsingWifi {
    THNetworkStatus wifiStatus = [[THNetStatus thReachabilityForLocalWiFi] thCurrentReachabilityStatus];

    if (wifiStatus == THNotReachable) {
        return FALSE;
    }

    return TRUE;
}


+ (BOOL)isTHUsingInternet {
    THNetworkStatus internetStatus = [[THNetStatus thReachabilityForInternetConnection] thCurrentReachabilityStatus];
    if (internetStatus == THNotReachable) {
        return FALSE;
    }
    return TRUE;
}


+ (NSString *)getTHReachibilityType {
    if ([THNetStatus isTHUsingWifi]) {
        return @"wifi";
    }

    if ([THNetStatus isTHUsingInternet]) {
        return @"mobile";
    }

    return @"none";
}



#pragma mark Network Flag Handling

- (THNetworkStatus)csLocalWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags {
    CSPrintReachabilityFlags(flags, "csLocalWiFiStatusForFlags");

    BOOL retVal = THNotReachable;
    if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
        retVal = THReachableViaWiFi;
    }
    return retVal;
}

- (THNetworkStatus)csNetworkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    CSPrintReachabilityFlags(flags, "csNetworkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return THNotReachable;
    }

    BOOL retVal = THNotReachable;

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        retVal = THReachableViaWiFi;
    }


    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            // ... and no [user] intervention is needed
            retVal = THReachableViaWiFi;
        }
    }

    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        retVal = THReachableViaWWAN;
    }
    return retVal;
}

- (BOOL)thConnectionRequired; {
    NSAssert(thReachabilityRef != NULL, @"thConnectionRequired called with NULL thReachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(thReachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}

- (THNetworkStatus)thCurrentReachabilityStatus {
    NSAssert(thReachabilityRef != NULL, @"currentNetworkStatus called with NULL thReachabilityRef");
    THNetworkStatus retVal = THNotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(thReachabilityRef, &flags)) {
        if (thLocalWiFiRef) {
            retVal = [self csLocalWiFiStatusForFlags:flags];
        }
        else {
            retVal = [self csNetworkStatusForFlags:flags];
        }
    }
    return retVal;
}
@end

