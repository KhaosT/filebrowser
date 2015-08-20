//
//  FBWatchFilesTableViewController.m
//  FileBrowser
//
//  Created by Blake Tsuzaki on 8/19/15.
//  Copyright © 2015 High Caffeine Content. All rights reserved.
//

#import "FBWatchFilesTableViewController.h"

@interface FBWatchFilesTableViewController ()

@end

@implementation FBWatchFilesTableViewController

- (id)initWithPath:(NSString *)path
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.path = path;
        self.title = [path lastPathComponent];
        self.tabBarItem.image = [UIImage imageNamed:@"watch"];
        self.tabBarItem.title = @"Watch";
        
        NSError *error = nil;
        NSArray *tempFiles = nil;
        
        if (error)
        {
            NSLog(@"ERROR: %@", error);
            
            if ([path isEqualToString:@"/System"])
                tempFiles = @[@"Library"];
            
            if ([path isEqualToString:@"/Library"])
                tempFiles = @[@"Preferences"];
            
            if ([path isEqualToString:@"/var"])
                tempFiles = @[@"mobile"];
            
            if ([path isEqualToString:@"/usr"])
                tempFiles = @[@"lib"];
        }
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(requestTableUpdate)
                      forControlEvents:UIControlEventValueChanged];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(updateTableWithArray:) name:@"shouldUpdateTable" object:nil];
        [self requestTableUpdate];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
}

- (void)requestTableUpdate{
    [[FBConnectivity sharedInstance] requestContentsFromFolder:self.path];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateFailed) userInfo:nil repeats:NO];
}

- (void)updateFailed{
    [self.refreshControl endRefreshing];
}

- (void)updateTableWithArray:(NSNotification *) notification{
    NSArray *array = notification.object;
    NSLog(@"Received %@", array);
    self.files = [array sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(NSString* file1, NSString* file2) {
        NSString *newPath1 = [self.path stringByAppendingPathComponent:file1];
        NSString *newPath2 = [self.path stringByAppendingPathComponent:file2];
        
        BOOL isDirectory1, isDirectory2;
        [[NSFileManager defaultManager ] fileExistsAtPath:newPath1 isDirectory:&isDirectory1];
        [[NSFileManager defaultManager ] fileExistsAtPath:newPath2 isDirectory:&isDirectory2];
        
        if (isDirectory1 && !isDirectory2)
            return NSOrderedDescending;
        
        return  NSOrderedAscending;
    }];;
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
    
    
    BOOL isDirectory;
    BOOL fileExists = [[NSFileManager defaultManager ] fileExistsAtPath:newPath isDirectory:&isDirectory];
    
    
    if (fileExists)
    {
        if (isDirectory)
        {
            FBWatchFilesTableViewController *vc = [[FBWatchFilesTableViewController alloc] initWithPath:newPath];
            [self.navigationController pushViewController:vc animated:YES];
        }
        /*
        else if ([FBCustomPreviewController canHandleExtension:[newPath pathExtension]])
        {
            FBCustomPreviewController *preview = [[FBCustomPreviewController alloc] initWithFile:newPath];
            [self.navigationController pushViewController:preview animated:YES];
        }
        else
        {
            QLPreviewController *preview = [[QLPreviewController alloc] init];
            preview.dataSource = self;
            
            [self.navigationController pushViewController:preview animated:YES];
        }
         */
    }
}

@end
