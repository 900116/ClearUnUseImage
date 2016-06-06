//
//  GHClassParser.m
//  CodeShit
//
//  Created by YongCheHui on 15/12/15.
//  Copyright © 2015年 ApesStudio. All rights reserved.
//

#import "GHProjManager.h"
#import "XCProject.h"
#import "XCSourceFile+Path.h"
#import "RegexKitLite.h"
#import "XCTarget.h"

@implementation GHImageFile
@end

@interface GHProjManager()
@property(nonatomic,strong) NSMutableArray* allImages;
@property(nonatomic,strong) NSMutableArray* ocFiles;
@end
@implementation GHProjManager
{
    NSString*_rootPath;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (NSString *)filePathForProjectFromNotification:(NSNotification *)notification {
    if ([notification.object respondsToSelector:@selector(projectFilePath)]) {
        NSString *pbxProjPath = [notification.object performSelector:@selector(projectFilePath)];
        return [pbxProjPath stringByDeletingLastPathComponent];
    }
    return nil;
}

-(void)detectFilesBlockComplite:(void (^)())finish
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (self.allImages.count == 0 || self.ocFiles.count == 0) {
            [self getAllFile];
        }
        for (NSString* file in self.ocFiles) {
            NSString* contentStr = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
            NSMutableArray* mutableArray = [NSMutableArray new];
            for (GHImageFile* imgFile in self.allImages) {
                if ([imgFile.fullPath rangeOfString:@"Pods"].location !=NSNotFound) {
                    [mutableArray addObject:imgFile];
                    continue;
                }
                NSString* imageKey = [imgFile.imageKey stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
                NSString* regx = [NSString stringWithFormat:@"\"%@(.png|.jpg)?\"",imageKey];
                NSArray* result = [contentStr componentsMatchedByRegex:regx];
                if (result.count > 0) {
                    [mutableArray addObject:imgFile];
                }
            }
            [self.allImages removeObjectsInArray:mutableArray];
        }
        self.imageFiless = self.allImages;
        dispatch_async(dispatch_get_main_queue(), ^{
            finish();
        });
    });
}
-(BOOL)isIgnores:(NSString *)imgkey
{
    NSString* path = [NSString stringWithFormat:@"%@/ignoreImg.data",_rootPath];
    NSMutableArray* array = [[NSArray arrayWithContentsOfFile:path] mutableCopy];
    if (array.count == 0) {
        return NO;
    }
    return [array containsObject:imgkey];
}

-(void)getAllFile
{
    NSMutableArray<GHImageFile*>* images = [NSMutableArray array];
    NSMutableArray* sourceFiles = [NSMutableArray array];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* subPath = [fm subpathsAtPath:_rootPath];
    for (NSString*str in subPath) {
        if ([str hasSuffix:@".png"] || [str hasSuffix:@".jpg"]) {
            if ([str rangeOfString:@".appiconset/"].location == NSNotFound) {
                if ([str rangeOfString:@".launchimage/"].location == NSNotFound) {
                    NSString* imageKey = [[[[[str lastPathComponent] stringByReplacingOccurrencesOfString:@"@2x" withString:@""] stringByReplacingOccurrencesOfString:@"@3x" withString:@""] stringByReplacingOccurrencesOfString:@".png" withString:@""]stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
                    if ([self isIgnores:imageKey]) {
                        continue;
                    }
                    GHImageFile* imageFile = [[GHImageFile alloc]init];
                    imageFile.imageKey = imageKey;
                    imageFile.subPath = str;
                    imageFile.fullPath = [NSString stringWithFormat:@"%@/%@",_rootPath,str];
                    [images addObject:imageFile];
                }
            }
        }
        else if([str hasSuffix:@".h"] || [str hasSuffix:@".m"] || [str hasSuffix:@".mm"] || [str hasSuffix:@".xib"]){
            if ([str rangeOfString:@"Pods"].location == NSNotFound) {
                [sourceFiles addObject:[NSString stringWithFormat:@"%@/%@",_rootPath,str]];
            }
        }
        else if(self.isReactiveNative && ([str hasSuffix:@".html"] || [str hasSuffix:@".css"] || [str hasSuffix:@".htm"])){
            if ([str rangeOfString:@"Pods"].location == NSNotFound) {
                [sourceFiles addObject:[NSString stringWithFormat:@"%@/%@",_rootPath,str]];
            }
        }
    }
    self.ocFiles = sourceFiles;
    self.allImages = images;
}

#pragma clang diagnostic pop
- (void)projectDidChange:(NSNotification *)notification {
    NSString *filePath = [self filePathForProjectFromNotification:notification];
    NSString *rootPaths = [filePath stringByDeletingLastPathComponent];

    if ([rootPaths rangeOfString:@"Pods"].location == NSNotFound) {
        _rootPath = rootPaths;
        //XCTarget* target =  [project targets][1];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self getAllFile];
        });
    }
    
    NSDictionary*dict = [NSDictionary dictionaryWithContentsOfFile:[self settingPath]];
    if (dict) {
        [GHProjManager sharedInstance].isReactiveNative = [dict[@"isRect"] boolValue];
    }
}


-(NSString *)settingPath
{
    NSString* path = [NSString stringWithFormat:@"%@/clearimageSetting.data",_rootPath];
    return path;
}

-(void)setIsReactiveNative:(BOOL)isReactiveNative
{
    _isReactiveNative = isReactiveNative;
    NSDictionary* dict = @{@"isRect":@(isReactiveNative)};
    [dict writeToFile:[self settingPath] atomically:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getAllFile];
    });
}


-(instancetype)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
       
        [notificationCenter addObserver:self
                               selector:@selector(projectDidChange:)
                                   name:@"PBXProjectDidOpenNotification"
                                 object:nil];
        
        [notificationCenter addObserver:self
                               selector:@selector(projectDidChange:)
                                   name:@"PBXProjectDidChangeNotification"
                                 object:nil];
//
//        [notificationCenter addObserver:self
//                               selector:@selector(projectDidClose:)
//                                   name:@"PBXProjectDidCloseNotification"
//                                 object:nil];
//        
//        [notificationCenter addObserver:self
//                               selector:@selector(fileDidSave:)
//                                   name:@"IDEEditorDocumentDidSaveNotification"
//                                 object:nil];
    }
    return self;
}

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GHProjManager* _manager;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc]init];
    });
    return _manager;
}

-(void)removeImages:(NSArray<GHImageFile *>*)images {
    [self.allImages removeObjectsInArray:images];
    [self.imageFiless removeObjectsInArray:images];
}

-(void)saveIgnoreImgs:(NSArray<GHImageFile *>*)images {
    NSString* path = [NSString stringWithFormat:@"%@/ignoreImg.data",_rootPath];
    NSMutableArray* array = [[NSArray arrayWithContentsOfFile:path] mutableCopy];
    if (!array) {
        array = [NSMutableArray new];
    }
    for (GHImageFile* imgFile in images) {
        [array addObject:imgFile.imageKey];
    }
    [array writeToFile:path atomically:YES];
    [self.allImages removeObjectsInArray:images];
    [self.imageFiless removeObjectsInArray:images];
}
@end
