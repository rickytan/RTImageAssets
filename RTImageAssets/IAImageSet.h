//
//  IAImageSet.h
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

extern NSString const *IAImageIdiom;
extern NSString const *IAImageScale;
extern NSString const *IAImageFilename;
extern NSString const *IAImageSubtype;


@interface IAImageSet : NSObject
@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) NSBundle *bundle;

+ (instancetype)imageSetWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;

@end

@interface IAImageAssets : NSObject
@property (nonatomic, readonly) NSBundle *bundle;
@property (nonatomic, readonly) NSArray *imageSets;
+ (instancetype)assetsWithPath:(NSString *)path;
- (id)initWithPath:(NSString *)path;
- (void)addToProccesingQueue:(NSOperationQueue *)queue;
@end

@interface NSImage (Resizing)
- (NSImage *)resizedImageWithScale:(CGFloat)scale;
- (BOOL)saveToFile:(NSString *)filePath withType:(NSBitmapImageFileType)type;
@end