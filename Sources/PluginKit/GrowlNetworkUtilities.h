//
//  GrowlNetworkUtilities.h
//  HardwareGrowler
//
//  Trimmed from Growl's Common/Source/GrowlNetworkUtilities. Only the pieces
//  HWGrowlNetworkMonitor needs are kept.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface GrowlNetworkUtilities : NSObject

/// Non-loopback, non-link-local IPv4/IPv6 addresses currently assigned to any
/// interface.
+ (NSArray *)routableIPAddresses;

/// Primary IP for a global key type (e.g. "IPv4") from an SCDynamicStore.
+ (NSString *)getPrimaryIPOfType:(NSString *)type fromStore:(SCDynamicStoreRef)dynStore;

/// The machine's local host name with any trailing ".local" removed.
+ (NSString *)localHostName;

@end
