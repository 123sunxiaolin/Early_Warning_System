//
//  CheackWLan.m
//  MingXingYiChu
//
//  Created by 任杰 on 13-10-27.
//  Copyright (c) 2013年 任杰. All rights reserved.
//

#import "CheackWLan.h"
#import "Reachability.h"
@implementation CheackWLan
+(BOOL)cheackWlan
{
    Reachability * reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    //NSString *message = nil;
    switch (status) {
        case kNotReachable:
//            message = @"亲,当前无网络哦 😭";
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
//            [alert release];
            return NO;
            //            NSAssert(1 != 1, @"Argument must be non-nil");
            break;
        default:
            break;
    }
    
    return YES;
    
}
@end
