//
//  GHSettingWindow.h
//  ClearUnuseImage
//
//  Created by YongCheHui on 16/6/6.
//  Copyright © 2016年 ApesStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GHSettingWindow : NSWindowController
@property(nonatomic,weak) IBOutlet NSButton* checkBox;
-(IBAction)Rec_Navite_changeState:(NSButton*)sender;
@end
