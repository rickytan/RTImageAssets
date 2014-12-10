//
//  IAImageSet.m
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import "IAImageSet.h"
#import "IAGenerateOperation.h"
#import "IASettingsWindow.h"

NSString const *IAImageIdiom = @"idiom";
NSString const *IAImageScale = @"scale";
NSString const *IAImageFilename = @"filename";
NSString const *IAImageSubtype = @"subtype";

@implementation NSImage (Resizing)

- (NSImage *)resizedImageWithScale:(CGFloat)scale
{
    scale /= 2.f;
    NSSize scaledSize = NSMakeSize(self.size.width * scale, self.size.height * scale);
    NSLog(@"%@", NSStringFromSize(scaledSize));
    NSImage *newImage = [[NSImage alloc] initWithSize:scaledSize];
    [newImage lockFocus];
    [self drawInRect:NSMakeRect(0, 0, scaledSize.width, scaledSize.height)
            fromRect:NSZeroRect
           operation:NSCompositeCopy
            fraction:1.0
      respectFlipped:YES
               hints:@{NSImageHintInterpolation: @(NSImageInterpolationDefault)}];
    [newImage unlockFocus];
    return newImage;
    return [NSImage imageWithSize:scaledSize
                          flipped:NO
                   drawingHandler:^BOOL(NSRect dstRect) {
                       NSLog(@"%@", NSStringFromRect(dstRect));
                       [self drawInRect:dstRect];
                       return YES;
                   }];
}

- (BOOL)saveToFile:(NSString *)filePath withType:(NSBitmapImageFileType)type
{
    NSData *data = nil;
    if (type == NSTIFFFileType) {
        data = self.TIFFRepresentation;
    }
    else {
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:self.TIFFRepresentation];
        data = [rep representationUsingType:type
                                 properties:nil];
    }
    return [data writeToFile:filePath
                  atomically:NO];
}

@end

@interface IAImageSet ()
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSMutableDictionary *contentInfo;
@property (nonatomic, assign, getter=isChanged) BOOL changed;
- (void)generate3xIfNeeded;
- (void)generate2xIfNeeded;
- (void)generate1xIfNeeded;
- (void)generateMissing;
@end

@implementation IAImageSet

+ (instancetype)imageSetWithPath:(NSString *)path
{
    return [[self alloc] initWithPath:path];
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.bundle = [NSBundle bundleWithPath:path];
        NSString *contentFile = [self.bundle pathForResource:@"Contents"
                                                      ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:contentFile];
        if (data) {
            NSError *error = nil;
            self.contentInfo = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
    return self;
}

- (NSArray *)images
{
    return self.contentInfo[@"images"];
}

- (void)setFilename:(NSString *)filename
           forScale:(NSString *)scale
{
    for (id obj in self.images) {
        if ([obj[IAImageScale] isEqualToString:scale] &&
            ([@[@"iphone", @"universal"] containsObject:obj[IAImageIdiom]])) {
            obj[IAImageFilename] = filename;
            self.changed = YES;
        }
    }
}

- (NSString *)filenameForImageName:(NSString *)imageName ofScaleExtension:(NSString *)scaleExt
{
    NSString *filename = imageName.stringByDeletingPathExtension;
    NSRange range = [imageName rangeOfString:@"@2x"];
    if (range.location != NSNotFound) {
        filename = [imageName substringToIndex:range.location];
    }
    range = [imageName rangeOfString:@"@3x"];
    if (range.location != NSNotFound) {
        filename = [imageName substringToIndex:range.location];
    }

    NSString *final = [NSString stringWithFormat:@"%@%@.png", filename, scaleExt];
    NSInteger count = 0;
    while ([[NSFileManager defaultManager] fileExistsAtPath:[self.bundle pathForResource:final
                                                                                  ofType:nil]]) {
        final = [NSString stringWithFormat:@"%@%@~%ld.png", filename, scaleExt, ++count];
    }
    return final;
}

- (NSInteger)get3xImageIndex
{
    NSArray *images = self.images;
    for (NSUInteger i = 0; i < images.count; ++i) {
        if ([images[i][IAImageScale] isEqualToString:@"3x"] && [images[i][IAImageFilename] length])
            return i;
    }
    return NSNotFound;
}

- (NSInteger)get2xImageIndex
{
    NSArray *images = self.images;
    for (NSUInteger i = 0; i < images.count; ++i) {
        if ([images[i][IAImageScale] isEqualToString:@"2x"] && [images[i][IAImageFilename] length])
            return i;
    }
    return NSNotFound;
}

- (NSInteger)get1xImageIndex
{
    NSArray *images = self.images;
    for (NSUInteger i = 0; i < images.count; ++i) {
        if ([images[i][IAImageScale] isEqualToString:@"1x"] && [images[i][IAImageFilename] length])
            return i;
    }
    return NSNotFound;
}



- (void)generate1xIfNeeded
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IASettingsGenerateNonRetinaKey]) {
        NSInteger idx = [self get1xImageIndex];
        if (idx != NSNotFound)
            return;

        CGFloat scale = 1.f / 3;
        idx = [self get3xImageIndex];
        if (idx == NSNotFound) {
            scale = 1.f / 2;
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:IASettingsDownscaleKey] isEqualToString:@"iphone6"]) {
                scale /= 750.f / 640.f;
            }
            idx = [self get2xImageIndex];
        }
        if (idx != NSNotFound) {
            NSString *imgName = self.images[idx][IAImageFilename];
            NSImage *img = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:[self.bundle pathForResource:imgName
                                                                                                              ofType:nil]]];
            NSImage *scaledImage = [img resizedImageWithScale:scale];
            NSString *fileName = [self filenameForImageName:imgName
                                           ofScaleExtension:@""];
            if ([scaledImage saveToFile:[[self.bundle resourcePath] stringByAppendingPathComponent:fileName]
                               withType:NSPNGFileType]) {
                [self setFilename:fileName
                         forScale:@"1x"];
            }
        }
    }
}

- (void)generate2xIfNeeded
{
    NSInteger idx = [self get2xImageIndex];
    if (idx != NSNotFound)
        return;

    idx = [self get3xImageIndex];
    if (idx != NSNotFound) {
        NSString *imgName = self.images[idx][IAImageFilename];
        NSImage *img = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:[self.bundle pathForResource:imgName
                                                                                                          ofType:nil]]];
        CGFloat scale = [[[NSUserDefaults standardUserDefaults] stringForKey:IASettingsDownscaleKey] isEqualToString:@"iphone6"] ? 750.f/960 : 640.f/960;
        NSImage *scaledImage = [img resizedImageWithScale:scale];
        NSString *fileName = [self filenameForImageName:imgName
                                       ofScaleExtension:@"@2x"];
        if ([scaledImage saveToFile:[[self.bundle resourcePath] stringByAppendingPathComponent:fileName]
                           withType:NSPNGFileType]) {
            [self setFilename:fileName
                     forScale:@"2x"];
        }
    }
}

- (void)generate3xIfNeeded
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IASettingsUpscaleKey]) {
        NSInteger idx = [self get3xImageIndex];
        if (idx != NSNotFound)
            return;

        idx = [self get2xImageIndex];
        if (idx != NSNotFound) {
            NSString *imgName = self.images[idx][IAImageFilename];
            NSImage *img = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:[self.bundle pathForResource:imgName
                                                                                                              ofType:nil]]];
            CGFloat scale = [[[NSUserDefaults standardUserDefaults] stringForKey:IASettingsDownscaleKey] isEqualToString:@"iphone6"] ? 960.f/750 : 960.f/640;
            NSImage *scaledImage = [img resizedImageWithScale:scale];
            NSString *fileName = [self filenameForImageName:imgName
                                           ofScaleExtension:@"@3x"];
            if ([scaledImage saveToFile:[[self.bundle resourcePath] stringByAppendingPathComponent:fileName]
                               withType:NSPNGFileType]) {
                [self setFilename:fileName
                         forScale:@"3x"];
            }
        }
    }
}

- (void)generateMissing
{
    [self generate1xIfNeeded];
    [self generate2xIfNeeded];
    [self generate3xIfNeeded];

    if (self.isChanged) {
        [[NSJSONSerialization dataWithJSONObject:self.contentInfo
                                              options:NSJSONWritingPrettyPrinted
                                                error:NULL] writeToFile:[self.bundle pathForResource:@"Contents"
                                                                                              ofType:@"json"]
         atomically:NO];
    }
}

@end

@interface IAImageAssets ()
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSArray *imageSets;
@end

@implementation IAImageAssets

+ (instancetype)assetsWithPath:(NSString *)path
{
    return [[self alloc] initWithPath:path];
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _bundle = [NSBundle bundleWithPath:path];

        NSError *error = nil;
        NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
                                                                             error:&error];
        if (error) {
            NSLog(@"Fail to get contents in: %@", path);
        }
        else {
            NSPredicate *filter = [NSPredicate predicateWithFormat:@"pathExtension = 'imageset'"];
            items = [items filteredArrayUsingPredicate:filter];
            NSMutableArray *images = [NSMutableArray arrayWithCapacity:items.count];
            for (NSString *p in items) {
                IAImageSet *imageSet = [IAImageSet imageSetWithPath:[self.bundle pathForResource:p
                                                                                          ofType:nil]];
                [images addObject:imageSet];
            }
            self.imageSets = [NSArray arrayWithArray:images];
        }
    }

    return self;
}

- (void)addToProccesingQueue:(NSOperationQueue *)queue
{
    [queue addOperation:[IAGenerateOperation operationWithAssets:self]];
}

@end
