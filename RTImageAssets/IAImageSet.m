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
NSString const *IAImageSize = @"size";
NSString const *IAImageFilename = @"filename";
NSString const *IAImageSubtype = @"subtype";

@implementation NSImage (Resizing)

- (NSImage *)resizedImageWithScale:(CGFloat)scale
{
    NSBitmapImageRep *rep = (NSBitmapImageRep *)self.representations.firstObject;
    // issue #56: https://github.com/rickytan/RTImageAssets/issues/56
    if (![rep isKindOfClass:[NSBitmapImageRep class]]) {
        return nil;
    }

    NSSize pixelSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);

    // issue #8: https://github.com/rickytan/RTImageAssets/issues/8
    if (pixelSize.width == 0.f || pixelSize.height == 0.f) {
        pixelSize = rep.size;
    }
    NSSize scaledSize = NSMakeSize(floorf(pixelSize.width * scale), floorf(pixelSize.height * scale));

    return [self resizedImageWithSize:scaledSize];
}

- (NSImage *)resizedImageWithSize:(NSSize)newSize
{
    NSBitmapImageRep *rep = (NSBitmapImageRep *)self.representations.firstObject;


    // issue #21: https://github.com/rickytan/RTImageAssets/issues/21
    rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                  pixelsWide:newSize.width
                                                  pixelsHigh:newSize.height
                                               bitsPerSample:rep.bitsPerSample
                                             samplesPerPixel:rep.samplesPerPixel
                                                    hasAlpha:rep.hasAlpha
                                                    isPlanar:rep.isPlanar
                                              colorSpaceName:rep.colorSpaceName
                                                 bytesPerRow:0
                                                bitsPerPixel:0];

    rep.size = newSize;

    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];

    if (!context) {
        // issue #24: https://github.com/rickytan/RTImageAssets/issues/24
        rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                      pixelsWide:newSize.width
                                                      pixelsHigh:newSize.height
                                                   bitsPerSample:8
                                                 samplesPerPixel:4
                                                        hasAlpha:YES
                                                        isPlanar:NO
                                                  colorSpaceName:NSCalibratedRGBColorSpace
                                                     bytesPerRow:0
                                                    bitsPerPixel:0];
        rep.size = newSize;
        context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    }

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    [self drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)];
    [NSGraphicsContext restoreGraphicsState];

    return [[NSImage alloc] initWithData:[rep representationUsingType:NSPNGFileType
                                                           properties:nil]];
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
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) NSString *path;
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
        self.path = path;
        self.name = path.stringByDeletingPathExtension.pathComponents.lastObject;

        NSString *contentFile = [self.path stringByAppendingPathComponent:@"Contents.json"];
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
    while ([[NSFileManager defaultManager] fileExistsAtPath:[self.path stringByAppendingPathComponent:final]]) {
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
        if ([images[i][IAImageScale] isEqualToString:@"2x"] &&
            [images[i][IAImageFilename] length] &&
            [@[@"iphone", @"universal"] containsObject:images[i][IAImageIdiom]])
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
            /*
             if ([[[NSUserDefaults standardUserDefaults] stringForKey:IASettingsDownscaleKey] isEqualToString:@"iphone6"]) {
             scale /= 750.f / 640.f;
             }
             */
            idx = [self get2xImageIndex];
        }
        if (idx != NSNotFound) {
            NSString *imgName = self.images[idx][IAImageFilename];
            NSImage *img = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:[self.path stringByAppendingPathComponent:imgName]]];
            NSImage *scaledImage = [img resizedImageWithScale:scale];
            NSString *fileName = [self filenameForImageName:imgName
                                           ofScaleExtension:@""];
            if ([scaledImage saveToFile:[self.path stringByAppendingPathComponent:fileName]
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
        NSImage *img = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:[self.path stringByAppendingPathComponent:imgName]]];
        CGFloat scale = 640.f/960;// [[[NSUserDefaults standardUserDefaults] stringForKey:IASettingsDownscaleKey] isEqualToString:@"iphone6"] ? 750.f/960 : 640.f/960;
        NSImage *scaledImage = [img resizedImageWithScale:scale];
        NSString *fileName = [self filenameForImageName:imgName
                                       ofScaleExtension:@"@2x"];
        if ([scaledImage saveToFile:[self.path stringByAppendingPathComponent:fileName]
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
            NSImage *img = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:[self.path stringByAppendingPathComponent:imgName]]];
            CGFloat scale = 960.f/640;// [[[NSUserDefaults standardUserDefaults] stringForKey:IASettingsDownscaleKey] isEqualToString:@"iphone6"] ? 960.f/750 : 960.f/640;
            NSImage *scaledImage = [img resizedImageWithScale:scale];
            NSString *fileName = [self filenameForImageName:imgName
                                           ofScaleExtension:@"@3x"];
            if ([scaledImage saveToFile:[self.path stringByAppendingPathComponent:fileName]
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

    [self postProcess];
}

- (void)postProcess
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IASettingsRename]) {
        [self rename];
    }

    if (self.isChanged) {
        self.changed = NO;
        [[NSJSONSerialization dataWithJSONObject:self.contentInfo
                                         options:NSJSONWritingPrettyPrinted
                                           error:NULL]
         writeToFile:[self.path stringByAppendingPathComponent:@"Contents.json"]
         atomically:NO];
    }
}

- (void)rename
{
    for (NSMutableDictionary *dic in self.images) {
        NSString *filename = dic[IAImageFilename];
        if (filename.length) {
            NSString *filepath = [self.path stringByAppendingPathComponent:filename];
            NSString *backfile = [[[self.path stringByAppendingPathComponent:filename.stringByDeletingPathExtension]
                                   stringByAppendingString:@"__backup~"]
                                  stringByAppendingPathExtension:filename.pathExtension];
            if ([[NSFileManager defaultManager] moveItemAtPath:filepath
                                                        toPath:backfile
                                                         error:NULL]) {
                dic[IAImageFilename] = backfile.lastPathComponent;
                self.changed = YES;
            }
        }
    }

    NSString *renameFilename = self.path.lastPathComponent.stringByDeletingPathExtension;
    for (NSMutableDictionary *dic in self.images) {
        NSString *filename = dic[IAImageFilename];
        NSString *ext = filename.pathExtension;
        if (!ext.length) {
            ext = @"png";
        }
        if (filename.length) {
            NSString *filepath = [self.path stringByAppendingPathComponent:filename];
            filename = renameFilename;
            if ([dic[IAImageIdiom] isEqualToString:@"ipad"]) {
                filename = [renameFilename stringByAppendingString:@"~ipad"];
            }

            if ([dic[IAImageSubtype] isEqualToString:@"retina4"]) {
                filename = [renameFilename stringByAppendingString:@"-568h"];
            }

            if (dic[IAImageScale] && ![dic[IAImageScale] isEqualToString:@"1x"]) {
                filename = [NSString stringWithFormat:@"%@@%@", filename, dic[IAImageScale]];
            }
            filename = [filename stringByAppendingPathExtension:ext];
            NSString *newPath = [self.path stringByAppendingPathComponent:filename];
            if ([[NSFileManager defaultManager] moveItemAtPath:filepath
                                                        toPath:newPath
                                                         error:NULL]) {
                dic[IAImageFilename] = filename;
                self.changed = YES;
            }
        }
    }
}

@end

@implementation IAIconSet

- (NSString *)imageNameForSize:(NSString *)sizeStr
{
    NSDictionary *sizeName = @{@"29x29": @"Icon-Small",
                               @"40x40": @"Icon-Spotlight-40",
                               @"50x50": @"Icon-Small-50",
                               @"57x57": @"Icon",
                               @"60x60": @"Icon-60",
                               @"72x72": @"Icon-72",
                               @"76x76": @"Icon-76"};
    return sizeName[sizeStr] ?: [@"Icon-" stringByAppendingString:[sizeStr componentsSeparatedByString:@"x"].firstObject];
}

- (void)generateAllIcons:(NSImage *)image
{
    @synchronized(self) {
        NSString *contentFile = [self.path stringByAppendingPathComponent:@"Contents.json"];
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

        for (NSMutableDictionary *img in self.images) {
            if (![img[IAImageFilename] length] || !
                [[NSFileManager defaultManager] fileExistsAtPath:[self.path stringByAppendingPathComponent:img[IAImageFilename]]]) {
                NSString *filename = [self imageNameForSize:img[IAImageSize]];
                NSInteger scale = [img[IAImageScale] integerValue];
                CGFloat size = [img[IAImageSize] floatValue];
                if (scale > 1) {
                    filename = [NSString stringWithFormat:@"%@@%@", filename, img[IAImageScale]];
                }
                filename = [filename stringByAppendingPathExtension:@"png"];
                NSImage *iconImage = [image resizedImageWithSize:NSMakeSize(size * scale, size * scale)];
                if ([iconImage saveToFile:[self.path stringByAppendingPathComponent:filename]
                                 withType:NSPNGFileType]) {
                    img[IAImageFilename] = filename;
                }
            }
        }

        [[NSJSONSerialization dataWithJSONObject:self.contentInfo
                                         options:NSJSONWritingPrettyPrinted
                                           error:NULL]
         writeToFile:[self.path stringByAppendingPathComponent:@"Contents.json"]
         atomically:NO];
    }
}

@end

@interface IAImageAssets ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSArray *imageSets;
@property (nonatomic, strong) NSArray *iconSets;
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
        self.path = path;
        self.name = path.stringByDeletingPathExtension.pathComponents.lastObject;

        NSArray *items = [self allFilesInDirectoryAtPath:path];

        NSPredicate *filter = [NSPredicate predicateWithFormat:@"pathExtension = 'imageset'"];
        NSArray *arr = [items filteredArrayUsingPredicate:filter];
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:items.count];
        for (NSURL *p in arr) {
            IAImageSet *imageSet = [IAImageSet imageSetWithPath:p.path];
            [images addObject:imageSet];
        }
        self.imageSets = [NSArray arrayWithArray:images];

        arr = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension = 'appiconset'"]];
        [images removeAllObjects];
        for (NSURL *p in arr) {
            IAIconSet *icon = [IAIconSet imageSetWithPath:p.path];
            [images addObject:icon];
        }
        self.iconSets = [NSArray arrayWithArray:images];
    }

    return self;
}

- (NSArray *)allFilesInDirectoryAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL = [NSURL fileURLWithPath:path];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:bundleURL includingPropertiesForKeys:@[NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
        return YES;
    }];

    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];

        if ([isDirectory boolValue]) {
            [mutableFileURLs addObject:fileURL];
        }
    }
    return [mutableFileURLs copy];
}

- (void)addToProccesingQueue:(NSOperationQueue *)queue
{
    [queue addOperation:[IAGenerateOperation operationWithAssets:self]];
}

@end
