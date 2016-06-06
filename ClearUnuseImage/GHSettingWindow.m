//
//  GHSettingWindow.m
//  ClearUnuseImage
//
//  Created by YongCheHui on 16/6/6.
//  Copyright © 2016年 ApesStudio. All rights reserved.
//

#import "GHSettingWindow.h"
#import "GHProjManager.h"

@interface GHSettingWindow ()

@end

@implementation GHSettingWindow

- (id)init
{
    if (![super initWithWindowNibName:@"GHSettingWindow"]) {
        return nil;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.checkBox.state = [GHProjManager sharedInstance].isReactiveNative;
}

-(IBAction)Rec_Navite_changeState:(NSButton*)sender {
    [GHProjManager sharedInstance].isReactiveNative = self.checkBox.state;
}

@end
