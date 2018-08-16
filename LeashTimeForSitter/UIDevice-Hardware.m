//
//  UIDevice-Hardware.m
//  NCLEX-Pharma-Final
//
//  Created by Ted Hooban on 10/10/16.
//  Copyright © 2016 Ted Hooban. All rights reserved.
//

#include <sys/sysctl.h>
#import "UIDevice-Hardware.h"

@interface UIDevice (Hardward)

- (NSString *)modelNameForModelIdentifier:(NSString *)modelIdentifier;

@end

@implementation UIDevice (Hardware)

- (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *)modelIdentifier
{
    return [self getSysInfoByName:"hw.machine"];
}

- (NSString *)modelName
{
    return [self modelNameForModelIdentifier:[self modelIdentifier]];
}

- (NSString *)modelNameForModelIdentifier:(NSString *)modelIdentifier
{
    // iPhone http://theiphonewiki.com/wiki/IPhone
	
	//NSLog(@"model identifier %@",modelIdentifier);
    
    if ([modelIdentifier isEqualToString:@"iPhone1,1"])    return @"iPhone 4S";
    if ([modelIdentifier isEqualToString:@"iPhone1,2"])    return @"iPhone 4S";
    if ([modelIdentifier isEqualToString:@"iPhone2,1"])    return @"iPhone 4S";
    if ([modelIdentifier isEqualToString:@"iPhone3,1"])    return @"iPhone 4S";
    if ([modelIdentifier isEqualToString:@"iPhone3,2"])    return @"iPhone 4S";
    if ([modelIdentifier isEqualToString:@"iPhone3,3"])    return @"iPhone 4S)";
    if ([modelIdentifier isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([modelIdentifier isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([modelIdentifier isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([modelIdentifier isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([modelIdentifier isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([modelIdentifier isEqualToString:@"iPhone6,1"])    return @"iPhone 6";
    if ([modelIdentifier isEqualToString:@"iPhone6,2"])    return @"iPhone 6";
    if ([modelIdentifier isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([modelIdentifier isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([modelIdentifier isEqualToString:@"iPhone8,1"])    return @"iPhone 6";
    if ([modelIdentifier isEqualToString:@"iPhone8,2"])    return @"iPhone 6 Plus";
    if ([modelIdentifier isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([modelIdentifier isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([modelIdentifier isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    
    // iPad http://theiphonewiki.com/wiki/IPad
    
    //if ([modelIdentifier isEqualToString:@"iPad1,1"])      return @"iPad 1G";
    //if ([modelIdentifier isEqualToString:@"iPad2,1"])      return @"iPad 2";
    //if ([modelIdentifier isEqualToString:@"iPad2,2"])      return @"iPad 2";
    //if ([modelIdentifier isEqualToString:@"iPad2,3"])      return @"iPad 2";
    //if ([modelIdentifier isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([modelIdentifier isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([modelIdentifier isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([modelIdentifier isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([modelIdentifier isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([modelIdentifier isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([modelIdentifier isEqualToString:@"iPad3,6"])      return @"iPad 4";
    
    if ([modelIdentifier isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([modelIdentifier isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([modelIdentifier isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([modelIdentifier isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    // iPad Mini http://theiphonewiki.com/wiki/IPad_mini
    
    if ([modelIdentifier isEqualToString:@"iPad2,5"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad2,6"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad2,7"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad4,4"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad4,5"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad4,6"])      return @"iPad mini"; // TD-LTE model see https://support.apple.com/en-us/HT201471#iPad-mini2
    if ([modelIdentifier isEqualToString:@"iPad4,7"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad4,8"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad4,9"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad5,1"])      return @"iPad mini";
    if ([modelIdentifier isEqualToString:@"iPad5,2"])      return @"iPad mini";
    
    // iPad Pro https://www.theiphonewiki.com/wiki/IPad_Pro
    
    if ([modelIdentifier isEqualToString:@"iPad6,3"])      return @"iPad Pro (9.7 inch)"; // http://pdadb.net/index.php?m=specs&id=9938&c=apple_ipad_pro_9.7-inch_a1673_wifi_32gb_apple_ipad_6,3
    if ([modelIdentifier isEqualToString:@"iPad6,4"])      return @"iPad Pro (9.7 inch)"; // http://pdadb.net/index.php?m=specs&id=9981&c=apple_ipad_pro_9.7-inch_a1675_td-lte_32gb_apple_ipad_6,4
    if ([modelIdentifier isEqualToString:@"iPad6,7"])      return @"iPad Pro (12.9 inch)"; // http://pdadb.net/index.php?m=specs&id=8960&c=apple_ipad_pro_wifi_a1584_128gb
    if ([modelIdentifier isEqualToString:@"iPad6,8"])      return @"iPad Pro (12.9 inch)"; // http://pdadb.net/index.php?m=specs&id=8965&c=apple_ipad_pro_td-lte_a1652_32gb_apple_ipad_6,8
    
    // iPod http://theiphonewiki.com/wiki/IPod
    
    if ([modelIdentifier isEqualToString:@"iPod1,1"])      return @"iPod touch 1G";
    if ([modelIdentifier isEqualToString:@"iPod2,1"])      return @"iPod touch 2G";
    if ([modelIdentifier isEqualToString:@"iPod3,1"])      return @"iPod touch 3G";
    if ([modelIdentifier isEqualToString:@"iPod4,1"])      return @"iPod touch 4G";
    if ([modelIdentifier isEqualToString:@"iPod5,1"])      return @"iPod touch 5G";
    if ([modelIdentifier isEqualToString:@"iPod7,1"])      return @"iPod touch 6G"; // as 6,1 was never released 7,1 is actually 6th generation
    
    // Apple TV https://www.theiphonewiki.com/wiki/Apple_TV
    
    if ([modelIdentifier isEqualToString:@"AppleTV1,1"])      return @"Apple TV 1G";
    if ([modelIdentifier isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2G";
    if ([modelIdentifier isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3G";
    if ([modelIdentifier isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3G"; // small, incremental update over 3,1
    if ([modelIdentifier isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4G"; // as 4,1 was never released, 5,1 is actually 4th generation

	
    // Simulator
    if ([modelIdentifier hasSuffix:@"86"] || [modelIdentifier isEqual:@"x86_64"])
    {
        float width = [[UIScreen mainScreen]bounds].size.width;
        float height = [[UIScreen mainScreen]bounds].size.height;
        
        if (width == 375 && height == 667) {
            return @"iPhone 6";
        } else if (width == 414 && height == 736) {
            return @"iPhone 6 Plus";
        } else if (width == 320 && height == 568) {
            return @"iPhone 5";
		} else if (height == 812) {
			return @"iPhone X";
		}
    }
    
    return modelIdentifier;
}

- (UIDeviceFamily) deviceFamily
{
    NSString *modelIdentifier = [self modelIdentifier];
    if ([modelIdentifier hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([modelIdentifier hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([modelIdentifier hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([modelIdentifier hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    return UIDeviceFamilyUnknown;
}

@end
