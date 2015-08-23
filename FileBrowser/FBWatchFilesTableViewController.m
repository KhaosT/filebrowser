//
//  FBWatchFilesTableViewController.m
//  FileBrowser
//
//  Created by Blake Tsuzaki on 8/19/15.
//  Copyright © 2015 High Caffeine Content. All rights reserved.
//

#import "FBWatchFilesTableViewController.h"
#import "FBCustomPreviewController.h"

@interface FBWatchFilesTableViewController ()
@property NSArray *isDir;
@property NSString *filePath;
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
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(requestTableUpdate)
                      forControlEvents:UIControlEventValueChanged];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(updateTableWithArray:) name:@"shouldUpdateTable" object:nil];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self requestTableUpdate];
}

- (void)requestTableUpdate{
    [[FBConnectivity sharedInstance] requestContentsFromFolder:self.path];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateFailed) userInfo:nil repeats:NO];
}

- (void)updateFailed{
    [self.refreshControl endRefreshing];
}

- (void)respondToFileReceived:(NSNotification *) notification{
    NSString *fileURL = (NSString *)notification.object;
    if ([FBCustomPreviewController canHandleExtension:[fileURL pathExtension]]&&NO)
    {
        FBCustomPreviewController *preview = [[FBCustomPreviewController alloc] initWithFile:fileURL];
        [self.navigationController pushViewController:preview animated:YES];
    }
    else
    {
        self.filePath = fileURL;
        QLPreviewController *preview = [[QLPreviewController alloc] init];
        preview.dataSource = self;
        //[self presentViewController:preview animated:YES completion:^{}];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.navigationController pushViewController:preview animated:YES];
        }];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedFile" object:nil];
}

- (void)updateTableWithArray:(NSNotification *) notification{
    self.files = [notification.object objectForKey:@"files"];
    self.isDir = [notification.object objectForKey:@"isDirectory"];
    NSLog(@"%@", notification.object);
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
    
    BOOL isDirectory = [[self.isDir objectAtIndex:indexPath.row] isEqualToString:@"YES"];
    
    cell.textLabel.text = self.files[indexPath.row];
    
    if (isDirectory)
        cell.imageView.image = [UIImage imageNamed:@"Folder"];
    else if ([[newPath pathExtension] isEqualToString:@"png"])
        cell.imageView.image = [UIImage imageNamed:@"Picture"];
    else
        cell.imageView.image = nil;
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
    NSLog(@"Requesting %@", newPath);
    
    BOOL isDirectory = [[self.isDir objectAtIndex:indexPath.row] isEqualToString:@"YES"];
    
    if (isDirectory)
    {
        FBWatchFilesTableViewController *vc = [[FBWatchFilesTableViewController alloc] initWithPath:newPath];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(respondToFileReceived:) name:@"receivedFile" object:nil];
        [[FBConnectivity sharedInstance] requestFileAtPath:newPath];
    }
}

#pragma mark - QuickLook

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item {
    
    return YES;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index {
    return [NSURL fileURLWithPath:self.filePath];
}

@end
