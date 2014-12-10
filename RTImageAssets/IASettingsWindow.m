//
//  IASettingsWindow.m
//  RTImageAssets
//
//  Created by ricky on 14-12-10.
//  Copyright (c) 2014年 rickytan. All rights reserved.
//

#import "IASettingsWindow.h"

NSString *IASettingsGenerateNonRetinaKey = @"IASettingsGenerateNonRetinaKey";
NSString *IASettingsUpscaleKey = @"IASettingsUpscaleKey";
NSString *IASettingsDownscaleKey = @"IASettingsDownscaleKey";

@interface IASettingsWindow ()
@property (weak) IBOutlet NSButton *nonretinaButton;
@property (weak) IBOutlet NSButton *upscaleButton;
@property (weak) IBOutlet NSMatrix *downscaleRadio;

@end

@implementation IASettingsWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.nonretinaButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:IASettingsGenerateNonRetinaKey] ? NSOnState : NSOffState;
    self.upscaleButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:IASettingsUpscaleKey] ? NSOnState : NSOffState;
    [self.downscaleRadio selectCellAtRow:0
                                  column:[[[NSUserDefaults standardUserDefaults] stringForKey:IASettingsDownscaleKey] isEqualToString:@"iphone6"] ? 1 : 0];
}

- (IBAction)onHelp:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/rickytan/"]];
}

- (IBAction)onRadio:(id)sender {
    if (self.downscaleRadio.selectedColumn == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"iphone5"
                                                  forKey:IASettingsDownscaleKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"iphone6"
                                                  forKey:IASettingsDownscaleKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onNonretina:(id)sender {
    if (self.nonretinaButton.state == NSOnState)
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:IASettingsGenerateNonRetinaKey];
    else
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:IASettingsGenerateNonRetinaKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onUpscale:(id)sender {
    if (self.upscaleButton.state == NSOnState)
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:IASettingsUpscaleKey];
    else
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:IASettingsUpscaleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
