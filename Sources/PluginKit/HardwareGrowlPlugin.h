//
//  HardwareGrowlPlugin.h
//  HardwareGrowler
//
//  Created by Daniel Siemer on 5/2/12.
//  Copyright (c) 2012 The Growl Project, LLC. All rights reserved.
//

// NSImage / NSView appear in this contract; the 2012 project pulled them in
// via a Cocoa prefix header. Import AppKit directly instead.
#import <Cocoa/Cocoa.h>

@protocol HWGrowlPluginControllerProtocol <NSObject>
@required
-(void)notifyWithName:(NSString*)name 
					 title:(NSString*)title
			 description:(NSString*)description
					  icon:(NSData*)iconData
	  identifierString:(NSString*)identifier
		  contextString:(NSString*)context
					plugin:(id)plugin;

-(BOOL)onLaunchEnabled;
-(BOOL)pluginDisabled:(id)plugin;

@end

@protocol HWGrowlPluginProtocol <NSObject>
@required
-(void)setDelegate:(id<HWGrowlPluginControllerProtocol>)aDelegate;
-(id<HWGrowlPluginControllerProtocol>)delegate;
-(NSString*)pluginDisplayName;

@optional
// Legacy AppKit-based settings UI. The modern app renders monitor settings in
// SwiftUI and never calls these, but monitors may still implement them.
-(NSImage*)preferenceIcon;
-(NSView*)preferencePane;
-(void)startObserving;
-(void)stopObserving;
-(BOOL)enabledByDefault;

@end

@protocol HWGrowlPluginNotifierProtocol <NSObject>
@required
-(NSArray*)noteNames;
-(NSDictionary*)localizedNames;
-(NSDictionary*)noteDescriptions;
-(NSArray*)defaultNotifications;

@optional
-(void)postRegistrationInit;
-(void)fireOnLaunchNotes;
-(void)noteClosed:(NSString*)contextString byClick:(BOOL)clicked;

@end

/* Used for purely stat monitoring plugins */
@protocol HWGrowlPluginMonitorProtocol <NSObject>
@optional
-(NSView*)menuBarSizedView;
-(NSView*)menuViewOfWidth:(CGFloat)width;

@end
