//
//  RTImageAssets.h
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import <AppKit/AppKit.h>

#define LocalizedString(key)    [[RTImageAssets sharedPlugin].bundle localizedStringForKey:(key) value:(key) table:nil]

@interface RTImageAssets : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end