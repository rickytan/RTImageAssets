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

static RTImageAssets *sharedPlugin;

@interface RTImageAssets()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) IASettingsWindow *settingsWindow;
@property (nonatomic, strong) NSOperationQueue *queue;
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

        // Create menu items, initialize UI, etc.

        // Sample Menu Item:

        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *imageAssetsItem = [[menuItem submenu] addItemWithTitle:@"ImageAssets"
                                                                        action:nil
                                                                 keyEquivalent:@""];
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
        }

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
