#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "THHardwareUtils.h"


@implementation THHardwareUtils

#pragma mark sysctlbyname utils
+ (NSString *)getSysInfoByName:(char *)typeSpecifier {
    size_t size;
    
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char answer[size];
    
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    
    return results;
}


+ (NSString *)getSysInfo
{
    return [self getSysInfoByName:"hw.machine"];
}


+ (NSString *) hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}


#pragma mark sysctl utils
+ (NSUInteger)getSysInfo:(uint)typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}


+ (NSUInteger)cpuFrequency {
    return [self getSysInfo:HW_CPU_FREQ];
}


+ (NSUInteger)busFrequency {
    return [self getSysInfo:HW_BUS_FREQ];
}

+ (NSUInteger)totalMemory {
    return [self getSysInfo:HW_PHYSMEM];
}


+ (NSUInteger)userMemory {
    return [self getSysInfo:HW_USERMEM];
}


+ (NSUInteger)maxSocketBufferSize {
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}



#pragma mark file system
+ (NSNumber *)totalDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}


+ (NSNumber *)freeDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}


static const char *device_string_names[CSUIDeviceMAX] =
{
    "Unknown iOS device",
    
    "iPhone Simulator",
    "iPhone Simulator",
    "iPad Simulator",
    
    "iPhone 1G",
    "iPhone 3G",
    "iPhone 3GS",
    "iPhone 4",
    "iPhone 4s",
    "iPhone 5",
    "iPhone 5s",
    "iPhone 6",
    "iPhone 6p",
    
    "iPod touch 1G",
    "iPod touch 2G",
    "iPod touch 3G",
    "iPod touch 4G",
    
    "iPad 1G",
    "iPad 2G",
    
    "Unknown iPhone",
    "Unknown iPod",
    "Unknown iPad",
    "iFPGA",
};


#pragma mark getSysInfo type and name utils
+ (NSUInteger)platformType {
    NSString *platform = [self getSysInfo];
    
    // if ([getSysInfo isEqualToString:@"XX"])
    //	return CSUIDeviceUnknown;
    
    if ([platform isEqualToString:@"iFPGA"])
        return CSUIDeviceIFPGA;
    
    if ([platform isEqualToString:@"iPhone1,1"])
        return CSUIDevice1GiPhone;
    
    if ([platform isEqualToString:@"iPhone1,2"])
        return CSUIDevice3GiPhone;
    
    if ([platform hasPrefix:@"iPhone2"])
        return CSUIDevice3GSiPhone;
    
    if ([platform hasPrefix:@"iPhone3"])
        return CSUIDevice4iPhone;
    
    if ([platform hasPrefix:@"iPhone4"])
        return CSUIDevice5iPhone;
    
    if ([platform isEqualToString:@"iPod1,1"])
        return CSUIDevice1GiPod;
    
    if ([platform isEqualToString:@"iPod2,1"])
        return CSUIDevice2GiPod;
    
    if ([platform isEqualToString:@"iPod3,1"])
        return CSUIDevice3GiPod;
    
    if ([platform isEqualToString:@"iPod4,1"])
        return CSUIDevice4GiPod;
    
    if ([platform isEqualToString:@"iPad1,1"])
        return CSUIDevice1GiPad;
    
    if ([platform isEqualToString:@"iPad2,1"])
        return CSUIDevice2GiPad;
    
    // MISSING A SOLUTION HERE Tutu DATE Tutu DIFFERENTIATE iPAD and iPAD 3G.
    
    if ([platform hasPrefix:@"iPhone"])
        return CSUIDeviceUnknowniPhone;
    
    if ([platform hasPrefix:@"iPod"])
        return CSUIDeviceUnknowniPod;
    
    if ([platform hasPrefix:@"iPad"])
        return CSUIDeviceUnknowniPad;
    
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"]) {
        if ([[UIScreen mainScreen] bounds].size.width < 768)
            return CSUIDeviceiPhoneSimulatoriPhone;
        else
            return CSUIDeviceiPhoneSimulatoriPad;
        
        return CSUIDeviceiPhoneSimulator;
    }
    return CSUIDeviceUnknown;
}


+ (NSString *)platformString {
    NSUInteger type = [self platformType];
    return [NSString stringWithUTF8String:device_string_names[type]];
}


+ (NSString *)platformCode {
    switch ([self platformType]) {
        case CSUIDevice1GiPhone:
            return @"M68";
        case CSUIDevice3GiPhone:
            return @"N82";
        case CSUIDevice3GSiPhone:
            return @"N88";
        case CSUIDevice4iPhone:
            return @"N89";
        case CSUIDevice5iPhone:
            return @"Unknown iPhone";
        case CSUIDeviceUnknowniPhone:
            return @"Unknown iPhone";
        case CSUIDevice1GiPod:
            return @"N45";
        case CSUIDevice2GiPod:
            return @"N72";
        case CSUIDevice3GiPod:
            return @"N18";
        case CSUIDevice4GiPod:
            return @"N80";
        case CSUIDeviceUnknowniPod:
            return @"Unknown iPod";
        case CSUIDevice1GiPad:
            return @"K48";
        case CSUIDevice2GiPad:
            return @"Unknown iPad";
        case CSUIDeviceUnknowniPad:
            return @"Unknown iPad";
        case CSUIDeviceiPhoneSimulator:
            return @"iPhone Simulator";
        default:
            return @"Unknown iOS device";
    }
}


@end
