#import <UIKit/UIKit.h>


// Platforms
// iFPGA	 ->	??
// iPhone1,1 ->	iPhone 1G
// iPhone1,2 ->	iPhone 3G
// iPhone2,1 ->	iPhone 3GS
// iPhone3,1 ->	iPhone 4/AT&T
// iPhone3,2 ->	iPhone 4/Other Carrier?
// iPhone3,3 ->	iPhone 4/Other Carrier?
// iPhone4,1 ->	??iPhone 5
// iPod1,1   -> iPod touch 1G
// iPod2,1   -> iPod touch 2G
// iPod2,2   -> ??iPod touch 2.5G
// iPod3,1   -> iPod touch 3G
// iPod4,1   -> iPod touch 4G
// iPod5,1   -> ??iPod touch 5G
// iPad1,1   -> iPad 1G, WiFi
// iPad1,?   -> iPad 1G, 3G <- needs 3G owner to test
// iPad2,1   -> iPad 2G (iProd 2,1)

// i386, x86_64 -> iPhone Simulator
typedef enum JOYUIDevicePlatform {
    CSUIDeviceUnknown,
    CSUIDeviceiPhoneSimulator,
    CSUIDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    CSUIDeviceiPhoneSimulatoriPad,
    CSUIDevice1GiPhone,
    CSUIDevice3GiPhone,
    CSUIDevice3GSiPhone,
    CSUIDevice4iPhone,
    CSUIDevice5iPhone,
    CSUIDevice1GiPod,
    CSUIDevice2GiPod,
    CSUIDevice3GiPod,
    CSUIDevice4GiPod,
    CSUIDevice1GiPad, // both regular and 3G
    CSUIDevice2GiPad,
    CSUIDeviceUnknowniPhone,
    CSUIDeviceUnknowniPod,
    CSUIDeviceUnknowniPad,
    CSUIDeviceIFPGA,
    CSUIDeviceMAX,
} JOYUIDevicePlatform;

@interface THHardwareUtils : NSObject

+ (NSString *)getSysInfo;

+ (NSString *)hwmodel;

+ (NSUInteger)platformType;

+ (NSString *)platformString;

+ (NSString *)platformCode;

+ (NSUInteger)cpuFrequency;

+ (NSUInteger)busFrequency;

+ (NSUInteger)totalMemory;

+ (NSUInteger)userMemory;

+ (NSNumber *)totalDiskSpace;

+ (NSNumber *)freeDiskSpace;

@end
