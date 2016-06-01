//
//  GHImageWindowController.m
//  ClearUnuseImage
//
//  Created by YongCheHui on 16/5/31.
//  Copyright © 2016年 ApesStudio. All rights reserved.
//

#import "GHImageWindowController.h"
#import "GHProjManager.h"

@interface GHImageWindowController ()

@end

@implementation GHImageWindowController
{
    BOOL _loading;
}
- (id)init
{
    if (![super initWithWindowNibName:@"ImageWindow"]) {
        return nil;
    }
    return self; 
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.tableView.dataSource = self;
    self.indicator.hidden = NO;
    [self.indicator startAnimation:nil];
    [[GHProjManager sharedInstance] detectFilesBlockComplite:^{
        _loading = YES;
        [self.tableView reloadData];
        self.indicator.hidden = YES;
        [self.indicator stopAnimation:nil];
    }];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return !_loading?0:[GHProjManager sharedInstance].imageFiless.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = [tableColumn identifier];
    GHImageFile *data = [GHProjManager sharedInstance].imageFiless[row];
    if ([identifier isEqualToString:@"path"]) {
        tableColumn.title = [data subPath];
        return [data subPath];
    }
    else if ([identifier isEqualToString:@"image"])
    {
        tableColumn.title = [data imageKey];
        return [data imageKey];
    }
    return nil;
}

-(IBAction)deleteRows:(id)sender {
    NSIndexSet * indexSet = [self.tableView selectedRowIndexes];
    NSArray*images = [[GHProjManager sharedInstance].imageFiless objectsAtIndexes:indexSet];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    for (GHImageFile* imgFile in images) {
        NSString* filePath = imgFile.fullPath;
        [fileManager removeItemAtPath:filePath error:nil];
    }
    [[GHProjManager sharedInstance] removeImages:images];
    [self.tableView reloadData];
}

-(IBAction)deleteAll:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    [alert setMessageText:@"您确定删除全部吗？"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSArray*images = [GHProjManager sharedInstance].imageFiless;
            NSFileManager* fileManager = [NSFileManager defaultManager];
            for (GHImageFile* imgFile in images) {
                NSString* filePath = imgFile.fullPath;
                [fileManager removeItemAtPath:filePath error:nil];
            }
            [[GHProjManager sharedInstance] removeImages:images];
            [self.tableView reloadData];
        }
    }];
}



@end
