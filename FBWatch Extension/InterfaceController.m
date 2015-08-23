//
//  InterfaceController.m
//  FBWatch Extension
//
//  Created by Blake Tsuzaki on 8/19/15.
//  Copyright © 2015 High Caffeine Content. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
@property NSString *path;
@property NSArray *files;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    if ([WCSession isSupported]){
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message{
    self.path = [message objectForKey:@"path"];
    if ([[message objectForKey:@"requestFile"] isEqualToString:@"YES"]){
        NSLog(@"File Sent %@", self.path);
        NSData *filedata = [NSData dataWithContentsOfFile:self.path];
        [[WCSession defaultSession] sendMessageData:filedata
                                       replyHandler:^(NSData * _Nonnull replyMessageData) {
                                           
                                       }
                                       errorHandler:^(NSError * _Nonnull error) {
                                           
                                       }];
    }else{
        NSError *error = nil;
        self.files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
        NSMutableArray *dirList = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [self.files count]; i++){
            BOOL isDirectory;
            NSString *newPath = [self.path stringByAppendingPathComponent:self.files[i]];
            [[NSFileManager defaultManager] fileExistsAtPath:newPath isDirectory:&isDirectory];
            [dirList addObject:isDirectory?@"YES":@"NO"];
        }
        NSDictionary *filesDict = @{@"files":self.files?self.files:@[],@"isDirectory":dirList?dirList:@[]};
        [[WCSession defaultSession] sendMessage:filesDict
                                   replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                                       
                                   }
                                   errorHandler:^(NSError * _Nonnull error) {
                                       if (error){
                                           NSLog(@"%@", [error localizedDescription]);
                                       }
                                   }];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



