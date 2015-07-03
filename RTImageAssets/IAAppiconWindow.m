//
//  IAAppiconWindow.m
//  RTImageAssets
//
//  Created by ricky on 14-12-18.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import "RTImageAssets.h"
#import "IAAppiconWindow.h"
#import "IAImageSet.h"
#import <CoreGraphics/CoreGraphics.h>

@interface IAImageViewInternal : NSImageView
@end

@implementation IAImageViewInternal

- (void)awakeFromNib
{
    self.layer.cornerRadius = 120.f;
    self.layer.masksToBounds = YES;
    self.wantsLayer = YES;

    [self registerForDraggedTypes:[NSImage imagePasteboardTypes]];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *board = [sender draggingPasteboard];
    NSURL *fileURL = [NSURL URLFromPasteboard:board];
    if (fileURL) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:fileURL];
        NSImageRep *rep = [[image representations] firstObject];
        if (rep.pixelsHigh == 1024 && rep.pixelsWide == 1024) {
            return YES;
        }
    }

    NSBeginAlertSheet(LocalizedString(@"Not Supported!"), LocalizedString(@"OK"), nil, nil, self.window, nil, NULL, NULL, NULL, @"%@", LocalizedString(@"Please provide a 1024x1024 resolution image!"));

    return NO;
}

@end

@interface IAAppiconWindow () <NSWindowDelegate>
@property (weak) IBOutlet NSPopUpButton *imageAssetButton;
@property (weak) IBOutlet NSPopUpButton *iconSetButton;
@property (weak) IBOutlet NSImageView *appIconImageView;
@property (weak) IBOutlet NSButton *generateButton;

@end

@implementation IAAppiconWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    self.generateButton.enabled = NO;

    [self reloadMenu];
}

- (BOOL)windowShouldClose:(id)sender
{
    self.appIconImageView.image = [[RTImageAssets sharedPlugin].bundle imageForResource:@"Appicon"];
    self.generateButton.enabled = NO;
    return YES;
}

- (void)reloadSecondMenu
{
    [self.iconSetButton.menu removeAllItems];
    if (self.imageAssetButton.selectedItem) {
        IAImageAssets *asset = self.imageAssetButton.selectedItem.representedObject;

        for (IAIconSet *icon in asset.iconSets) {
            NSMenuItem *subitem = [self.iconSetButton.menu addItemWithTitle:icon.name
                                                                     action:@selector(onSelect:)
                                                              keyEquivalent:@""];
            subitem.representedObject = icon;
        }
    }
}

- (IAIconSet *)selectedIconSet
{
    return self.iconSetButton.selectedItem.representedObject;
}

- (void)reloadMenu
{
    [self.imageAssetButton.menu removeAllItems];
    for (IAImageAssets *asset in self.imageAssets) {
        NSMenuItem *item = [self.imageAssetButton.menu addItemWithTitle:asset.name
                                                                 action:@selector(onSelectAsset:)
                                                          keyEquivalent:@""];
        item.representedObject = asset;
        if (!asset.iconSets.count) {
            item.enabled = NO;
        }
    }
    [self reloadSecondMenu];
}

- (void)setImageAssets:(NSArray *)imageAssets
{
    _imageAssets = imageAssets;
    if (self.isWindowLoaded) {
        [self reloadMenu];
    }
}

#pragma mark - Actions

- (void)onSelectAsset:(NSMenuItem *)item {
    [self reloadSecondMenu];
}

- (void)onSelect:(NSMenuItem *)item {

}

- (IBAction)onDropImage:(id)sender {
    self.generateButton.enabled = self.appIconImageView.image != nil;
    if (!self.appIconImageView.image) {
        self.appIconImageView.image = [[RTImageAssets sharedPlugin].bundle imageForResource:@"Appicon"];
    }
}

- (IBAction)onGenerate:(id)sender {
    if ([self.delegate respondsToSelector:@selector(appIconWindow:generateIconsWithImage:)]) {
        [self.delegate appIconWindow:self
              generateIconsWithImage:self.appIconImageView.image];
    }
}


@end
