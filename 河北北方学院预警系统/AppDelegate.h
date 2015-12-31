//
//  AppDelegate.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-2-27.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginView.h"
@class AKTabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSArray *views;
}
@property (nonatomic,strong) NSString *IDString;
@property (nonatomic,strong) LoginView *loginID;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AKTabBarController *tabBarController;

@end
