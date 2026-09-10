//
//  GrowlNetworkUtilities.m
//  HardwareGrowler
//
//  Trimmed from Growl's Common/Source/GrowlNetworkUtilities. The original
//  -isLocalHost NSString category is inlined here.
//

#import "GrowlNetworkUtilities.h"

#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>

@implementation GrowlNetworkUtilities

+ (NSString *)localHostName {
	NSString *hostname = @"localhost";

	CFStringRef cfHostName = SCDynamicStoreCopyLocalHostName(NULL);
	if (cfHostName != NULL) {
		hostname = [[(NSString *)cfHostName copy] autorelease];
		CFRelease(cfHostName);
		if ([hostname hasSuffix:@".local"]) {
			hostname = [hostname substringToIndex:([hostname length] - [@".local" length])];
		}
	}
	return hostname;
}

+ (BOOL)stringIsLocalHost:(NSString *)string {
	NSString *hostName = [self localHostName];
	return ([string isEqualToString:@"127.0.0.1"] ||
			[string isEqualToString:@"::1"] ||
			[string isEqualToString:@"0:0:0:0:0:0:0:1"] ||
			[string caseInsensitiveCompare:@"localhost"] == NSOrderedSame ||
			[string caseInsensitiveCompare:hostName] == NSOrderedSame);
}

+ (NSArray *)routableIPAddresses {
	NSMutableArray *addresses = nil;
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *current = NULL;

	if (getifaddrs(&interfaces) == 0) {
		current = interfaces;
		while (current != NULL) {
			NSString *currentString = nil;
			NSString *interface = [NSString stringWithUTF8String:current->ifa_name];

			if (![interface isEqualToString:@"lo0"] && ![interface isEqualToString:@"utun0"] &&
				current->ifa_addr != NULL) {
				if (current->ifa_addr->sa_family == AF_INET) {
					char stringBuffer[INET_ADDRSTRLEN];
					struct sockaddr_in *ipv4 = (struct sockaddr_in *)current->ifa_addr;
					if (inet_ntop(AF_INET, &(ipv4->sin_addr), stringBuffer, INET_ADDRSTRLEN))
						currentString = [NSString stringWithFormat:@"%s", stringBuffer];
				} else if (current->ifa_addr->sa_family == AF_INET6) {
					char stringBuffer[INET6_ADDRSTRLEN];
					struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)current->ifa_addr;
					if (inet_ntop(AF_INET6, &(ipv6->sin6_addr), stringBuffer, INET6_ADDRSTRLEN))
						currentString = [NSString stringWithFormat:@"%s", stringBuffer];
				}

				if (currentString && ![self stringIsLocalHost:currentString]) {
					if (!addresses)
						addresses = [NSMutableArray array];
					[addresses addObject:currentString];
				}
			}

			current = current->ifa_next;
		}
	}
	freeifaddrs(interfaces);
	return [[addresses copy] autorelease];
}

+ (NSString *)getPrimaryIPOfType:(NSString *)type fromStore:(SCDynamicStoreRef)dynStore {
	NSString *returnIP = nil;
	NSString *primaryKey = [NSString stringWithFormat:@"State:/Network/Global/%@", type];
	CFDictionaryRef newValue = SCDynamicStoreCopyValue(dynStore, (CFStringRef)primaryKey);
	if (newValue) {
		NSString *ipKey = [NSString stringWithFormat:@"State:/Network/Interface/%@/%@",
						   [(NSDictionary *)newValue objectForKey:@"PrimaryInterface"], type];
		CFDictionaryRef ipInfo = SCDynamicStoreCopyValue(dynStore, (CFStringRef)ipKey);
		if (ipInfo) {
			CFArrayRef addrs = CFDictionaryGetValue(ipInfo, CFSTR("Addresses"));
			if (addrs && CFArrayGetCount(addrs)) {
				CFStringRef ip = CFArrayGetValueAtIndex(addrs, 0);
				returnIP = [NSString stringWithString:(NSString *)ip];
			}
			CFRelease(ipInfo);
		}
		CFRelease(newValue);
	}
	return returnIP;
}

@end
