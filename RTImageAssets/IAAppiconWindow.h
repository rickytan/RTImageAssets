//
//  IAAppiconWindow.h
//  RTImageAssets
//
//  Created by ricky on 14-12-18.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IAAppiconWindow;

@protocol IAAppiconWindowDelegate <NSObject>
@optional
- (void)appIconWindow:(IAAppiconWindow *)window
generateIconsWithImage:(NSImage *)image;

@end

typedef NS_ENUM(NSInteger, IAIconGenerationOSType) {
    IAIconGenerationOSTypeAll   = 0,
    IAIconGenerationOSTypeiOS7
};

typedef NS_ENUM(NSInteger, IAIconGenerationDeviceType) {
    IAIconGenerationDeviceTypeUniversal     = 0,
    IAIconGenerationDeviceTypeiPhone,
    IAIconGenerationDeviceTypeiPad
};

@interface IAAppiconWindow : NSWindowController
@property (nonatomic, assign) IBOutlet id<IAAppiconWindowDelegate> delegate;
@property (nonatomic, readonly) IAIconGenerationOSType OSType;
@property (nonatomic, readonly) IAIconGenerationDeviceType deviceType;
@end
