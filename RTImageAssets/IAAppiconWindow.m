//
//  IAAppiconWindow.m
//  RTImageAssets
//
//  Created by ricky on 14-12-18.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import "RTImageAssets.h"
#import "IAAppiconWindow.h"
#import <CoreGraphics/CoreGraphics.h>

@interface IAImageViewInternal : NSImageView
@end

@implementation IAImageViewInternal

- (void)awakeFromNib
{
    self.layer.cornerRadius = 120.f;
    self.layer.masksToBounds = YES;
    self.layer.backgroundColor = [NSColor redColor].CGColor;
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

    NSBeginAlertSheet(LocalizedString(@"Not Supported!"), LocalizedString(@"OK"), nil, nil, self.window, nil, NULL, NULL, NULL, @"%@", LocalizedString(@"Please provide a 1024X1024 resolution image!"));

    return NO;
}

@end

@interface IAAppiconWindow () <NSWindowDelegate>
@property (weak) IBOutlet NSPopUpButton *osTypeButton;
@property (weak) IBOutlet NSPopUpButton *deviceTypeButton;
@property (weak) IBOutlet NSImageView *appIconImageView;

@end

@implementation IAAppiconWindow

- (void)windowDidLoad {
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSLog(@"%@", self.appIconImageView.registeredDraggedTypes);
}



- (IAIconGenerationDeviceType)deviceType
{
    return [self.deviceTypeButton.menu indexOfItem:self.deviceTypeButton.selectedItem];
}

- (IAIconGenerationOSType)OSType
{
    return [self.osTypeButton.menu indexOfItem:self.osTypeButton.selectedItem];
}

- (BOOL)windowShouldClose:(id)sender
{
    self.appIconImageView.image = [[RTImageAssets sharedPlugin].bundle imageForResource:@"Appicon"];
    return YES;
}

#pragma mark - Actions

- (IBAction)onGenerate:(id)sender {
    if ([self.delegate respondsToSelector:@selector(appIconWindow:generateIconsWithImage:)])
        [self.delegate appIconWindow:self
              generateIconsWithImage:self.appIconImageView.image];

}


@end
