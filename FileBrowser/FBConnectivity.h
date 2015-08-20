//
//  FBConnectivity.h
//  FileBrowser
//
//  Created by Blake Tsuzaki on 8/19/15.
//  Copyright © 2015 High Caffeine Content. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface FBConnectivity : NSObject <WCSessionDelegate>
+ (FBConnectivity *)sharedInstance;
- (void)requestContentsFromFolder:(NSString *)path;
@end
