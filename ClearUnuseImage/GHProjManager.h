//
//  GHClassParser.h
//  CodeShit
//
//  Created by YongCheHui on 15/12/15.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GHImageFile : NSObject
@property(nonatomic,copy) NSString* imageKey;
@property(nonatomic,copy) NSString* subPath;
@property(nonatomic,copy) NSString* fullPath;
@end

@interface GHProjManager : NSObject
+(instancetype)sharedInstance;
-(void)detectFilesBlockComplite:(void(^)())finish;
-(void)removeImages:(NSArray<GHImageFile *>*)images;
@property(nonatomic,strong) NSMutableArray<GHImageFile *>* imageFiless;
@end
