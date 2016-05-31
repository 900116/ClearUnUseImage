//
//  ClearUnuseImage.m
//  ClearUnuseImage
//
//  Created by YongCheHui on 16/5/31.
//  Copyright © 2016年 ApesStudio. All rights reserved.
//

#import "ClearUnuseImage.h"
#import "GHProjManager.h"
#import "GHImageWindowController.h"

@interface ClearUnuseImage()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation ClearUnuseImage
{
    GHProjManager *_manager;
    GHImageWindowController* _preferenceController;
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
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(projectDidClose:)
                                           name:@"PBXProjectDidCloseNotification"
                                         object:nil];
    }
    return self;
}

-(void)projectDidClose:(NSNotification*)noti
{
    [_preferenceController dismissController:nil];
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"ClearUnUseImage" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
    [self go];
}

-(void)go
{
    _manager = [GHProjManager sharedInstance];
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    _preferenceController = [[GHImageWindowController alloc] init];
    [_preferenceController showWindow:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
