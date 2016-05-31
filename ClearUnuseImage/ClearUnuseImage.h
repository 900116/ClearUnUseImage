//
//  ClearUnuseImage.h
//  ClearUnuseImage
//
//  Created by YongCheHui on 16/5/31.
//  Copyright © 2016年 ApesStudio. All rights reserved.
//

#import <AppKit/AppKit.h>

@class ClearUnuseImage;

static ClearUnuseImage *sharedPlugin;

@interface ClearUnuseImage : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end