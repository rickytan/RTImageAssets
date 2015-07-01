//
//  RTImageAssets.m
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import <objc/runtime.h>
#import "RTImageAssets.h"
#import "IASettingsWindow.h"
#import "IAAppiconWindow.h"
#import "IAWorkspace.h"
#import "IAImageSet.h"
#import "XcodeIDE.h"

#include <objc/runtime.h>

@interface DTAssetiLifeDelegate (Hook)
@end

@implementation DTAssetiLifeDelegate

- (void)assetCategoryController:(id)arg1
               willDisplayAsset:(id)arg2
{

}

@end

static RTImageAssets *sharedPlugin;

@interface RTImageAssets() <IAAppiconWindowDelegate, IDEApplicationEventDelegate>
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) IASettingsWindow *settingsWindow;
@property (nonatomic, strong) IAAppiconWindow *iconWindow;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMenuItem *menuItem;
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

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onApplicationLaunch:)
                                                     name:NSApplicationDidFinishLaunchingNotification
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

#pragma mark - delegate

#pragma mark - Actions

- (NSMenuItem *)menuItem
{
    if (!_menuItem) {
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

            NSMenuItem *appiconItem = [[imageAssetsItem submenu] addItemWithTitle:[self.bundle localizedStringForKey:@"AppIcons"
                                                                                                               value:nil
                                                                                                               table:nil]
                                                                           action:@selector(_dropAppicon:)
                                                                    keyEquivalent:@"a"];
            appiconItem.target = self;
            appiconItem.keyEquivalentModifierMask = NSControlKeyMask | NSShiftKeyMask | NSAlternateKeyMask;

            [[imageAssetsItem submenu] addItemWithTitle:[self.bundle localizedStringForKey:@"Settings"
                                                                                     value:nil
                                                                                     table:nil]
                                                 action:@selector(_settings:)
                                          keyEquivalent:@""].target = self;

            self.menuItem = imageAssetsItem;
        }
    }
    return _menuItem;
}

- (void)_generateAssets:(id)sender
{
    NSString *currentWorkspace = [IAWorkspace currentWorkspacePath];
    if (currentWorkspace) {
        // issue #13 https://github.com/rickytan/RTImageAssets/issues/13
        if (self.queue.operationCount)
            return;

        NSString *currentWorkingDir = [currentWorkspace stringByDeletingPathExtension];
        NSArray *bundlesToProcess = [self assetsBundlesInPath:currentWorkingDir];

        if (bundlesToProcess.count == 0) {
            NSBeginAlertSheet(LocalizedString(@"Can't find any .xcassets bundle"), LocalizedString(@"OK"), nil, nil, [NSApp mainWindow], nil, NULL, NULL, NULL, @"%@", LocalizedString(@"use Asset Catalogs"));
        }
        else {
            for (NSString *bundlePath in bundlesToProcess) {
                IAImageAssets *assets = [IAImageAssets assetsWithPath:bundlePath];
                [assets addToProccesingQueue:self.queue];
            }
        }
    }
}

- (void)_dropAppicon:(id)sender
{
    NSString *currentWorkspace = [IAWorkspace currentWorkspacePath];
    if (currentWorkspace) {
        NSString *currentWorkingDir = [currentWorkspace stringByDeletingPathExtension];
        NSArray *bundlesToProcess = [self assetsBundlesInPath:currentWorkingDir];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:bundlesToProcess.count];
        for (NSString *bundlePath in bundlesToProcess) {
            IAImageAssets *assets = [IAImageAssets assetsWithPath:bundlePath];
            [arr addObject:assets];
        }
        self.iconWindow.imageAssets = arr;
        [self.iconWindow showWindow:sender];
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

- (void)onApplicationLaunch:(NSNotification *)notification
{
    self.menuItem.enabled = NO;
}

- (void)onProjectOpen:(NSNotification *)notification
{
    self.menuItem.enabled = YES;
}

- (void)onProjectClose:(NSNotification *)notification
{
    self.menuItem.enabled = NO;
    [self.iconWindow close];
}

- (void)onProjectChanged:(NSNotification *)notification
{
    self.menuItem.enabled = YES;
    [self.iconWindow close];
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

- (IAAppiconWindow *)iconWindow
{
    if (!_iconWindow) {
        _iconWindow = [[IAAppiconWindow alloc] initWithWindowNibName:NSStringFromClass([IAAppiconWindow class])];
        _iconWindow.delegate = self;
    }
    return _iconWindow;
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

#pragma mark - IAAppicon delegate

- (void)appIconWindow:(IAAppiconWindow *)window
generateIconsWithImage:(NSImage *)image
{
    IAIconSet *iconset = window.selectedIconSet;
    if (iconset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [iconset generateAllIcons:image];
        });
    }
}

@end
