//
//  AppDelegate.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-2-27.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "AppDelegate.h"
#import "OriginalView.h"
#import "PersonView.h"
#import "iflyMSC/iflySetting.h"
#import "DetailView.h"//语音
#import "newViewController.h"//新闻
#import "EmergencyView.h"//紧急
#import "NamesList.h"//考勤
#import "ChoiceView_map.h"//地图
#import "myViewController.h"//学生地图
#import "Person_INFO_Center.h"
#import "AKTabBarController.h"
#import "GuideView.h"

@implementation AppDelegate
@synthesize loginID;
@synthesize IDString;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //设置状态栏隐藏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [NSThread sleepForTimeInterval:2.0]; //延时2秒，以便用户看清楚启动页

    //语音添加
    [IFlySetting setLogFile:LVL_ALL];
    [IFlySetting showLogcat:YES];
    
    //增加表识，用于判断是否是第一次启动应用...
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(callbackFunction:)
        name:@"PostData"
        object:nil];//用于监听 切换用户
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(ReturnToUseMainView:)
        name:@"welcomeview"
        object:nil];//监听  第一次启动程序，开启欢迎界面
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        
        GuideView *guide=[[GuideView alloc]init];
        self.window.rootViewController=guide;
        [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    }else
    {
        OriginalView *original=[[OriginalView alloc]init];
        self.window.rootViewController=original;
    }
    [self.window makeKeyAndVisible];
    return YES;
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
-(void)ReturnToUseMainView:(NSNotification *)information
{//用于监听第一次启动
    [[UIApplication sharedApplication] setStatusBarHidden:false];
    
    NSDictionary *dic;
    dic=[information userInfo];
    NSString *info=[dic objectForKey:@"loadtag"];
    if ([info isEqualToString:@"firstload"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        OriginalView *original=[[OriginalView alloc]init];
        self.window.rootViewController=original;
        [self.window makeKeyAndVisible];
    }

}
-(void)callbackFunction:(NSNotification*)notification
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   
    _tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 70 : 50];
   
    [_tabBarController setMinimumHeightToDisplayTitle:40.0];
    //语音模块
    DetailView *yuyin=[[DetailView alloc] init];
     UINavigationController *nav1=[[UINavigationController alloc] initWithRootViewController:yuyin];
    nav1.navigationBar.tintColor = [UIColor darkGrayColor];
    
    [nav1.navigationBar setBackgroundImage:[UIImage imageNamed:@"yuyin_ navigation_backImage.png"] forBarMetrics:UIBarMetricsDefault];
    //新闻模块
    newViewController *news=[[newViewController alloc]init];
    UINavigationController *nav2=[[UINavigationController alloc]initWithRootViewController:news];
    [nav2.navigationBar setBackgroundImage:[UIImage imageNamed:@"topView.png"] forBarMetrics:UIBarMetricsDefault];//给导航栏添加背景图片
    
    //紧急模块
     EmergencyView*danger=[[EmergencyView alloc]init];
    UINavigationController *nav3=[[UINavigationController alloc]initWithRootViewController:danger];
    
    ChoiceView_map *map=[[ChoiceView_map alloc]init];
    UINavigationController *nav4=[[UINavigationController alloc]initWithRootViewController:map];
    
    //学生地图
    myViewController *map_Student=[[myViewController alloc]init];
    UINavigationController *nav_student=[[UINavigationController alloc]initWithRootViewController:map_Student];
    
     NamesList *caoqin=[[NamesList alloc]init];
     UINavigationController *nav5=[[UINavigationController alloc]initWithRootViewController:caoqin];
    
     Person_INFO_Center *person=[[Person_INFO_Center alloc]init];
     person.title=@"我的中心";
     UINavigationController *nav6=[[UINavigationController alloc]initWithRootViewController:person];
    
    NSDictionary *dic;
    dic=[notification userInfo];
    NSString *shenfen=[dic objectForKey:@"shenfen"];

    if ([shenfen isEqualToString:@"学生"]) {
        [_tabBarController setViewControllers:[NSMutableArray arrayWithObjects:nav1,nav2,nav3,nav_student,nav6,nil]];
        self.window.rootViewController=_tabBarController;
        
    }else if ([shenfen isEqualToString:@"普通教师"])
    {
        [_tabBarController setViewControllers:[NSMutableArray arrayWithObjects:nav1,nav2,nav3,nav5,nav6,nil]];
        self.window.rootViewController=_tabBarController;
    }else
    {
 
        [_tabBarController setViewControllers:[NSMutableArray arrayWithObjects:nav1,nav2,nav3,nav4,nav5,nav6,nil]];
        self.window.rootViewController=_tabBarController;
    }
    
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
