//
//  FBConnectivity.m
//  FileBrowser
//
//  Created by Blake Tsuzaki on 8/19/15.
//  Copyright © 2015 High Caffeine Content. All rights reserved.
//

#import "FBConnectivity.h"
@interface FBConnectivity()
@property (strong, nonatomic) NSString *requestedFileName;
@end

@implementation FBConnectivity

+ (FBConnectivity *)sharedInstance{
    static dispatch_once_t p = 0;
    
    __strong static FBConnectivity *_sharedInstance = nil;
    
    dispatch_once(&p, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if ([WCSession isSupported]){
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    return self;
}
- (void)requestContentsFromFolder:(NSString *)path{
    self.requestedFileName = path;
    NSDictionary *pathDict = @{@"path":path,@"requestFile":@"NO"};
    [[WCSession defaultSession] sendMessage:pathDict
                               replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                               }
                               errorHandler:^(NSError * _Nonnull error) {
                               }];
}
- (void)requestFileAtPath:(NSString *)path{
    self.requestedFileName = [path lastPathComponent];
    NSDictionary *pathDict = @{@"path":path,@"requestFile":@"YES"};
    [[WCSession defaultSession] sendMessage:pathDict
                               replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                                } errorHandler:^(NSError * _Nonnull error) {
                                }];
}
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message{
    NSMutableDictionary *listdict = [[NSMutableDictionary alloc] initWithDictionary:message copyItems:YES];
    if ([[listdict objectForKey:@"files"] count] == 0)
    {
        if ([self.requestedFileName isEqualToString:@"/System"]){
            [listdict setObject:@[@"Library"] forKey:@"files"];
            [listdict setObject:@[@"YES"] forKey:@"isDirectory"];
        }
        
        if ([self.requestedFileName isEqualToString:@"/Library"]){
            [listdict setObject:@[@"Preferences"] forKey:@"files"];
            [listdict setObject:@[@"YES"] forKey:@"isDirectory"];
        }
        
        if ([self.requestedFileName isEqualToString:@"/var"]){
            [listdict setObject:@[@"mobile"] forKey:@"files"];
            [listdict setObject:@[@"YES"] forKey:@"isDirectory"];
        }
        
        if ([self.requestedFileName isEqualToString:@"/usr"]){
            [listdict setObject:@[@"lib"] forKey:@"files"];
            [listdict setObject:@[@"YES"] forKey:@"isDirectory"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateTable" object:listdict];
}

- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData{
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", docsdir, self.requestedFileName];
    NSLog(@"Received %@", filepath);
    [messageData writeToFile:filepath atomically:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedFile" object:filepath];
}
@end
