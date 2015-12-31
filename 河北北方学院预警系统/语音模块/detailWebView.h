//
//  detailWebView.h
//  NEwsDEmo
//
//  Created by kys-2 on 14-3-31.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface detailWebView : UIViewController<UIWebViewDelegate>
{
    //第二次请求
    NSMutableDictionary *SecondContent;
    UIActivityIndicatorView *activity;

}
@property (nonatomic,weak) NSURL *URlAddress;
@property (nonatomic,weak) NSString*  hight;
@end
