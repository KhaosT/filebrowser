//
//  FBConnectivity.m
//  FileBrowser
//
//  Created by Blake Tsuzaki on 8/19/15.
//  Copyright © 2015 High Caffeine Content. All rights reserved.
//

#import "FBConnectivity.h"
@interface FBConnectivity()

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
    NSDictionary *pathDict = @{@"path":path};
    [[WCSession defaultSession] sendMessage:pathDict
                               replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
                                   NSLog(@"%@", replyMessage);
                               }
                               errorHandler:^(NSError * _Nonnull error) {
                               }];
    NSLog(@"Sent Request");
}
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateTable" object:[message objectForKey:@"files"]];
}
@end
