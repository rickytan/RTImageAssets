//
//  RTImageAssets.m
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import "RTImageAssets.h"
#import "IASettingsWindow.h"
#import "IAWorkspace.h"
#import "IAImageSet.h"
#import "XcodeIDE.h"

#include <objc/runtime.h>

static RTImageAssets *sharedPlugin;

@interface NSView (RTImageAssets)
@property (nonatomic, assign, getter=isFileDragging) BOOL fileDragging;
- (void)myDraggingEnded:(id<NSDraggingInfo>)sender;
- (NSDragOperation)myDraggingEntered:(id<NSDraggingInfo>)sender;
- (void)myDraggingExited:(id<NSDraggingInfo>)sender;

- (BOOL)myPerformDragOperation:(id<NSDraggingInfo>)sender;
- (NSDraggingSession *)myBeginDraggingSessionWithItems:(NSArray *)items event:(NSEvent *)event source:(id<NSDraggingSource>)source;


- (void)myDrawRect:(NSRect)rect;
- (id)myInitWithFrame:(NSRect)frameRect;
@end

@implementation NSView (RTImageAssets)

+ (void)load
{
    return;
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(draggingEnded:)),
                                   class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(myDraggingEnded:)));
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(draggingEntered:)),
                                   class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(myDraggingEntered:)));
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(draggingExited:)),
                                   class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(myDraggingExited:)));
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(drawRect:)),
                                   class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(myDrawRect:)));
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(initWithFrame:)),
                                   class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(myInitWithFrame:)));
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(performDragOperation:)),
                                   class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(myPerformDragOperation:)));
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(beginDraggingSessionWithItems:event:source:)),
                                   class_getInstanceMethod(NSClassFromString(@"IBICMultipartImageView"), @selector(myBeginDraggingSessionWithItems:event:source:)));
}

- (void)setFileDragging:(BOOL)fileDragging
{
    objc_setAssociatedObject(self, "RTImageAssets.fileDragging", @(fileDragging), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isFileDragging
{
    id v = objc_getAssociatedObject(self, "RTImageAssets.fileDragging");
    return [v boolValue];
}

- (NSDraggingSession *)myBeginDraggingSessionWithItems:(NSArray *)items event:(NSEvent *)event source:(id<NSDraggingSource>)source
{
    NSDraggingSession *session = [self myBeginDraggingSessionWithItems:items event:event source:source];

    return session;
}

- (id)myInitWithFrame:(NSRect)frame
{
    id obj = [self myInitWithFrame:frame];
    [self registerForDraggedTypes:@[NSPasteboardTypePNG, NSFilenamesPboardType]];

    return obj;
}

- (BOOL)myPerformDragOperation:(id<NSDraggingInfo>)sender
{
    BOOL v = [self myPerformDragOperation:sender];

    return v;
}

- (NSDragOperation)myDraggingEntered:(id<NSDraggingInfo>)sender
{
    self.fileDragging = YES;
    [self setNeedsDisplay:YES];
    return [self myDraggingEntered:sender];
}

- (void)myDraggingEnded:(id<NSDraggingInfo>)sender
{
    NSPoint point = [sender draggingLocation];
    NSDragOperation op = [sender draggingSourceOperationMask];

    point = [self convertPoint:point fromView:nil];
    NSView *view = [self hitTest:point];
    if (view != self) {
        NSString *imageFile = [[sender draggingPasteboard] stringForType:@"public.file-url"];
        NSLog(@"%@", imageFile);
    }

    self.fileDragging = NO;
    [self setNeedsDisplay:YES];
    [self myDraggingEnded:sender];
}

- (void)myDraggingExited:(id<NSDraggingInfo>)sender
{
    self.fileDragging = NO;
    [self setNeedsDisplay:YES];
    [self myDraggingExited:sender];
}

- (void)myDrawRect:(NSRect)dirtyRect
{
    [self myDrawRect:dirtyRect];

    if (self.isFileDragging) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 2.f, 2.f)
                                                             xRadius:2.f
                                                             yRadius:2.f];
        path.lineWidth = 4.f;
        path.lineCapStyle = NSRoundLineCapStyle;
        path.lineJoinStyle = NSRoundLineJoinStyle;

        [[NSColor redColor] setStroke];
        [path stroke];
    }
}

@end

@interface RTImageAssets()
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) IASettingsWindow *settingsWindow;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMenuItem *menuItem;
@property (nonatomic, strong) NSMutableDictionary *notiCache;
@end

@implementation RTImageAssets

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        self.notiCache = [NSMutableDictionary dictionary];

        // Create menu items, initialize UI, etc.

        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];

            NSMenuItem *imageAssetsItem = [[menuItem submenu] addItemWithTitle:@"ImageAssets"
                                                                        action:nil
                                                                 keyEquivalent:@""];
            imageAssetsItem.enabled = NO;
            imageAssetsItem.submenu = [[NSMenu alloc] init];
            NSMenuItem *generateItem = [[imageAssetsItem submenu] addItemWithTitle:[self.bundle localizedStringForKey:@"Generate"
                                                                                                                value:nil
                                                                                                                table:nil]
                                                                            action:@selector(_generateAssets:)
                                                                     keyEquivalent:@"a"];
            generateItem.keyEquivalentModifierMask = NSControlKeyMask | NSShiftKeyMask;
            generateItem.target = self;
            [[imageAssetsItem submenu] addItemWithTitle:[self.bundle localizedStringForKey:@"Settings"
                                                                                     value:nil
                                                                                     table:nil]
                                                 action:@selector(_settings:)
                                          keyEquivalent:@""].target = self;

            self.menuItem = imageAssetsItem;
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onProjectChanged:)
                                                     name:@"PBXProjectDidChangeNotification"
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNotif:)
                                                     name:nil
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onProjectChanged:)
                                                     name:@"PBXProjectDidChangeNotification"
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onProjectOpen:)
                                                     name:@"PBXProjectDidOpenNotification"
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onProjectClose:)
                                                     name:@"PBXProjectWillCloseNotification"
                                                   object:nil];

        [[NSUserDefaults standardUserDefaults] registerDefaults:@{IASettingsDownscaleKey: @"iphone5",
                                                                  IASettingsUpscaleKey: @NO,
                                                                  IASettingsGenerateNonRetinaKey: @NO,
                                                                  IASettingsRename: @YES}];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_queue waitUntilAllOperationsAreFinished];
    _queue = nil;
    _settingsWindow = nil;
}

#pragma mark - Actions

- (void)_generateAssets:(id)sender
{
    NSString *currentWorkspace = [IAWorkspace currentWorkspacePath];
    if (currentWorkspace) {
        NSString *currentWorkingDir = [currentWorkspace stringByDeletingPathExtension];
        NSArray *bundlesToProcess = [self assetsBundlesInPath:currentWorkingDir];

        for (NSString *bundlePath in bundlesToProcess) {
            IAImageAssets *assets = [IAImageAssets assetsWithPath:bundlePath];
            [assets addToProccesingQueue:self.queue];
        }
    }
    else {

    }
}

- (void)_settings:(id)sender
{
    if (_queue.operationCount) {
        NSAlert *alert = [NSAlert alertWithMessageText:LocalizedString(@"Processing")
                                         defaultButton:LocalizedString(@"OK")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"%@", LocalizedString(@"Please Wait")];
        [alert runModal];
    }
    else {
        [self.settingsWindow showWindow:sender];
    }
}

#pragma mark - Methods

- (void)onNotif:(NSNotification *)notification
{

}

- (void)onProjectOpen:(NSNotification *)notification
{
    self.menuItem.enabled = YES;
}

- (void)onProjectClose:(NSNotification *)notification
{
    self.menuItem.enabled = NO;
}

- (void)onProjectChanged:(NSNotification *)notification
{
    self.menuItem.enabled = YES;
}

- (NSArray *)assetsBundlesInPath:(NSString *)path
{
    NSMutableArray *bundles = [NSMutableArray array];

    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *filePath = nil;
    while (filePath = [enumerator nextObject]) {
        if ([@"xcassets" isEqualToString:filePath.pathExtension]) {
            NSString *fullPath = [path stringByAppendingPathComponent:filePath];
            NSError *error = nil;
            NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath
                                                                                  error:&error];
            if ([attr[NSFileType] isEqualTo:NSFileTypeDirectory]) {
                [bundles addObject:fullPath];
            }
        }
    }

    return [NSArray arrayWithArray:bundles];
}

- (IASettingsWindow *)settingsWindow
{
    if (!_settingsWindow) {
        _settingsWindow = [[IASettingsWindow alloc] initWithWindowNibName:NSStringFromClass([IASettingsWindow class])];
    }
    return _settingsWindow;
}

- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.name = @"RTImageAssets Generation Queue";
        _queue.maxConcurrentOperationCount = 5;
    }
    return _queue;
}

@end
