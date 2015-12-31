//
//  Person_INFO_Center.m
//  HeadTeacher   Info Demo
//
//  Created by kys-2 on 14-5-31.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "Person_INFO_Center.h"
#import "SJAvatarBrowser.h"
#import "AFNetworking.h"
#import "PAImageView.h"
#import "S_InfoCell.h"

#import "DLAVAlertView.h"
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertViewTextFieldTheme.h"
#import "DLAVAlertViewButtonTheme.h"

#import "ClassesListByHeadTeacher.h"
#import "Toast+UIView.h"
#import "ChangingDetail.h"
#import "Defines.h"

#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "OriginalView.h"
#import "AKTabBarController.h"
#import "iToast.h"
#import "AppDelegate.h"

@interface Person_INFO_Center (){
    PAImageView *avaterImageView;
     BOOL isFullScreen;
      NSMutableDictionary *jsonObjects;
    NSString *touxiao;
    UIButton *imageBtn;
}
@property (nonatomic,strong) LXActionSheet *actionSheet;
@end

@implementation Person_INFO_Center
@synthesize InfoCenterBackground;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark---------------登陆者为辅导员-------查看个人信息
-(void)InfoCenter_Request_HeadTeacherToCheck
{
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"], @"userNickname",@"Role_HeadTeacher",@"role", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,infoCenterCheck_headTeacher_Url]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForInfoCenterHeadTeacher:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForInfoCenterHeadTeacher:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForInfoCenterHeadTeacher:(ASIHTTPRequest *)request
{
    [SVProgressHUD showErrorWithStatus:@"获取个人信息失败"];
   // [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForInfoCenterHeadTeacher:(ASIHTTPRequest *)request
{
    [SVProgressHUD showSuccessWithStatus:@"加载成功"];
    NSData *responseData = [request responseData];
    InfoCenterJsons=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",InfoCenterJsons);
    @try {
        if ([[InfoCenterJsons objectForKey:@"Status"] isEqualToString:@"NotHaveUser"])
        {
            [self.view makeToast:@"没有该用户。。。"];
        }else
        {
            H_name.text=[InfoCenterJsons valueForKey:@"name"];
            phone=[InfoCenterJsons valueForKey:@"phone"];
            [[NSUserDefaults standardUserDefaults]setObject:phone forKey:@"NewPhone"];
            HeadTeacherCardNum=[InfoCenterJsons valueForKey:@"cardId"];
            [InfoCenterTable reloadData];
            ClassesmanagedByHead=[[NSMutableArray alloc]init];
            for (int i=0; i<[[InfoCenterJsons valueForKey:@"gradeList"] count]; i++)
            {
                NSDictionary *into=[[InfoCenterJsons valueForKey:@"gradeList"] objectAtIndex:i];
                NSString *className=[NSString stringWithFormat:@"%@%@%@",[into valueForKey:@"yearClass"],[into valueForKey:@"profession"],[into valueForKey:@"classId"]];
                [ClassesmanagedByHead addObject:className];
            }
            NSLog(@"classmanaged===%@",ClassesmanagedByHead);
        }

    }
    @catch (NSException *exception) {
         NSLog(@"辅导员个人中心错误: %@", exception);
    }
    @finally {
        NSLog(@"辅导员个人中心 --出现错误啦");
    }
    
}
#pragma mark---------------登陆者为学生-------查看个人信息
-(void)InfoCenter_Request_StudentsToCheck
{
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"], @"userNickname",@"Role_Student",@"role", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,infoCenterCheck_Student_Url]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForInfoCenterStudent:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForInfoCenterStudent:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForInfoCenterStudent:(ASIHTTPRequest *)request
{
    [SVProgressHUD showErrorWithStatus:@"获取个人信息失败"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForInfoCenterStudent:(ASIHTTPRequest *)request
{
    [SVProgressHUD showSuccessWithStatus:@"加载成功"];
    NSData *responseData = [request responseData];
    InfoCenterJsons=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    Person_Student=[[NSMutableArray alloc] init];
    
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",InfoCenterJsons);
    @try {
    if ([[InfoCenterJsons valueForKey:@"Status"] isEqualToString:@"Fail"])
    {
        [self.view makeToast:@"返回数据为空"];
    }
    else
    {
        Sname.text=[NSString stringWithFormat:@"%@",[InfoCenterJsons objectForKey:@"name"]];
        ;
        touxiao=[InfoCenterJsons valueForKey:@"studentImageURL"];
        NSLog(@"%@",touxiao);
        [Person_Student addObject:[InfoCenterJsons valueForKey:@"studentNumber"]];
        
        
        [Person_Student addObject:[InfoCenterJsons valueForKey:@"cardId"]];
        [Person_Student addObject:[InfoCenterJsons valueForKey:@"grade"]];
        [Person_Student addObject:[InfoCenterJsons valueForKey:@"profession"]];
        [Person_Student addObject:[NSString stringWithFormat:@"%@班",[InfoCenterJsons valueForKey:@"class"]]];
        phone=[InfoCenterJsons valueForKey:@"phone"];
        [[NSUserDefaults standardUserDefaults]setObject:phone forKey:@"NewPhone"];
        [InfoCenterTable reloadData];
        if (![touxiao isKindOfClass:[NSNull class]]){
        [avaterImageView setImageURL:touxiao];
        }
        else{
            [avaterImageView setImageURL:nil];
        }
    }
    
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"学生个人信息错误 %@",exception] duration:1000];
        NSLog(@"学生个人信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"个人信息");
    }

 
}
#pragma mark---------------登陆者为普通教师-------查看个人信息
-(void)InfoCenter_Request_TeachersToCheck
{
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    //数据加载。。。
   
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"], @"userNickname",@"Role_Teacher",@"role", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,infoCenterCheck_Teacher_Url]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForInfoTeacher:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForInfoTeacher:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForInfoTeacher:(ASIHTTPRequest *)request
{
    [SVProgressHUD showErrorWithStatus:@"获取个人信息失败"];
    // [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForInfoTeacher:(ASIHTTPRequest *)request
{
    [SVProgressHUD showSuccessWithStatus:@"加载成功"];
    NSData *responseData = [request responseData];
    InfoCenterJsons=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",InfoCenterJsons);
    @try {
    if ([InfoCenterJsons count])
    {
        T_name.text=[NSString stringWithFormat:@"%@",[InfoCenterJsons valueForKey:@"name"]];
        TeacherCardNum=[InfoCenterJsons valueForKey:@"cardId"];
        phone=[InfoCenterJsons valueForKey:@"phone"];
        [[NSUserDefaults standardUserDefaults]setObject:phone forKey:@"NewPhone"];
        [InfoCenterTable reloadData];
        NSLog(@"%@",T_name.text);
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"老师个人信息错误 %@",exception] duration:1000];
        NSLog(@"老师个人信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"个人信息");
    }

}

-(void)CreateViewForBackground
{
    //加载背景
    InfoCenterBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 60, ScreenWidth, 180)];
    InfoCenterBackground.backgroundColor=[UIColor clearColor];
    InfoCenterBackground.image=[UIImage imageNamed:@"InfoCenter_background"];
    UITapGestureRecognizer *infocenter_tap=[[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(ShowInfocenterBackground)];
    InfoCenterBackground.userInteractionEnabled=YES;
    [InfoCenterBackground addGestureRecognizer:infocenter_tap];
    [self.view addSubview:InfoCenterBackground];
    //进行身份判断  以确定显示的内容
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"学生"])
    {//登陆者为学生
        //学生个人中心查看
        
        [self InfoCenter_Request_StudentsToCheck];

        CGFloat imageSize=75.f;
        avaterImageView = [[PAImageView alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (InfoCenterBackground.frame.size.height-imageSize)/2+48, imageSize, imageSize) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
        //点击添加和更换头像
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseImage:)];
        [avaterImageView addGestureRecognizer:tap];
        imageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn.frame=CGRectMake((ScreenWidth-imageSize)/2+100, (InfoCenterBackground.frame.size.height-imageSize)/2+80, imageSize, imageSize);
        [imageBtn setTitle:@"添加头像" forState:UIControlStateNormal];
        imageBtn.hidden=YES;//暂设隐藏
        [imageBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
        
        [avaterImageView addSubview:self.picture];
        [avaterImageView setImageURL:touxiao];
        //@"http://e.hiphotos.baidu.com/image/w%3D2048/sign=5454ab5e0bf79052ef1f40"
        [self.view insertSubview:avaterImageView aboveSubview:InfoCenterBackground];
        [InfoCenterBackground addSubview:imageBtn];
        NSLog(@"%f--%f",avaterImageView.frame.origin.x,avaterImageView.frame.origin.y);
        //学生姓名
        Sname=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (InfoCenterBackground.frame.size.height-imageSize)/2+imageSize-4, imageSize, 25)];
        Sname.backgroundColor=[UIColor clearColor];
        Sname.textColor=[UIColor colorWithWhite:255 alpha:1.0];//设置姓名的颜色为铬黄
        Sname.font=[UIFont fontWithName:@"Helvetica" size:15];
        Sname.text=@"";
        Sname.textAlignment=NSTextAlignmentCenter;
        [InfoCenterBackground addSubview:Sname];
        //学生昵称
        UILabel *Snickname=[[UILabel alloc]initWithFrame:CGRectMake(Sname.frame.origin.x, Sname.frame.origin.y+Sname.frame.size.height, imageSize, Sname.frame.size.height)];
        Snickname.backgroundColor=[UIColor clearColor];
        Snickname.font=[UIFont fontWithName:@"Helvetica" size:10];
        Snickname.textColor=[UIColor colorWithRed:255 green:128 blue:0 alpha:1.0];
        Snickname.text=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"]];
        Snickname.textAlignment=NSTextAlignmentCenter;
        //[Snickname sizeToFit];
        [InfoCenterBackground addSubview:Snickname];
    }
    else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"辅导员"])
    {//登陆者为辅导员
        
        [self InfoCenter_Request_HeadTeacherToCheck];//开始进行请求
         UILabel *IdLogo=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-130)/2, (InfoCenterBackground.frame.size.height-30)/2, 130, 30)];
        IdLogo.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ID_Logo"]];
        IdLogo.alpha=0.8;
        IdLogo.font=[UIFont fontWithName:@"Helvetica" size:17];
        IdLogo.textColor=[UIColor colorWithRed:255 green:97 blue:0 alpha:1.0];
        IdLogo.text=@"辅导员";
        IdLogo.textAlignment=NSTextAlignmentCenter;
        [InfoCenterBackground addSubview:IdLogo];
        
        //辅导员姓名
        CGFloat imageSize=75.f;
        H_name=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (InfoCenterBackground.frame.size.height-imageSize)/2+imageSize-15, imageSize, 25)];
        H_name.backgroundColor=[UIColor clearColor];
        H_name.textColor=[UIColor colorWithWhite:255 alpha:1.0];//设置姓名的颜色为铬黄
        H_name.font=[UIFont fontWithName:@"Helvetica" size:15];
        H_name.text=@"";
        H_name.textAlignment=NSTextAlignmentCenter;
        [InfoCenterBackground addSubview:H_name];
        //辅导员昵称
        UILabel *H_nickname=[[UILabel alloc]initWithFrame:CGRectMake(H_name.frame.origin.x, H_name.frame.origin.y+H_name.frame.size.height, imageSize, H_name.frame.size.height)];
        H_nickname.backgroundColor=[UIColor clearColor];
        H_nickname.font=[UIFont fontWithName:@"Helvetica" size:10];
        H_nickname.textColor=[UIColor colorWithRed:255 green:128 blue:0 alpha:1.0];
        H_nickname.text=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"]];
        H_nickname.textAlignment=NSTextAlignmentCenter;
        //[Snickname sizeToFit];
        [InfoCenterBackground addSubview:H_nickname];

    }
    else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"普通教师"])
    {//登陆者为普通教师
        
        [self InfoCenter_Request_TeachersToCheck];//请求
        
        //身份标签
        UILabel *IdLogo=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-130)/2, (InfoCenterBackground.frame.size.height-30)/2, 130, 30)];
        IdLogo.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ID_Logo"]];
        IdLogo.alpha=0.8;
        IdLogo.font=[UIFont fontWithName:@"Helvetica" size:16];
        IdLogo.textColor=[UIColor colorWithRed:255 green:97 blue:0 alpha:1.0];
        IdLogo.text=@"普通教师";
        IdLogo.textAlignment=NSTextAlignmentCenter;
        [InfoCenterBackground addSubview:IdLogo];
        
        //教师姓名
        CGFloat imageSize=75.f;
        T_name=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (InfoCenterBackground.frame.size.height-imageSize)/2+imageSize-15, imageSize, 25)];
        T_name.backgroundColor=[UIColor clearColor];
        T_name.textColor=[UIColor colorWithWhite:255 alpha:1.0];//设置姓名的颜色为铬黄
        T_name.font=[UIFont fontWithName:@"Helvetica" size:15];
        T_name.text=@"";
        T_name.textAlignment=NSTextAlignmentCenter;
        [InfoCenterBackground addSubview:T_name];
        //教师昵称
        UILabel *T_nickname=[[UILabel alloc]initWithFrame:CGRectMake(T_name.frame.origin.x, T_name.frame.origin.y+T_name.frame.size.height, imageSize, T_name.frame.size.height)];
        T_nickname.backgroundColor=[UIColor clearColor];
        T_nickname.font=[UIFont fontWithName:@"Helvetica" size:10];
        T_nickname.textColor=[UIColor colorWithRed:255 green:128 blue:0 alpha:1.0];
        T_nickname.text=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"]];
        T_nickname.textAlignment=NSTextAlignmentCenter;
        //[Snickname sizeToFit];
        [InfoCenterBackground addSubview:T_nickname];

        
    }
    else {
        //领导登录
        [self InfoCenter_Request_leaderToCheck];
        //身份标签
        UILabel *IdLogo=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-130)/2, (InfoCenterBackground.frame.size.height-30)/2, 130, 30)];
        IdLogo.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"ID_Logo"]];
        IdLogo.alpha=0.8;
        IdLogo.font=[UIFont fontWithName:@"Helvetica" size:16];
        IdLogo.textColor=[UIColor colorWithRed:255 green:97 blue:0 alpha:1.0];
        IdLogo.text=@"领导";
        IdLogo.textAlignment=NSTextAlignmentCenter;
        [InfoCenterBackground addSubview:IdLogo];
        
        //领导姓名
        CGFloat imageSize=75.f;
        T_name=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (InfoCenterBackground.frame.size.height-imageSize)/2+imageSize-15, imageSize, 25)];
        T_name.backgroundColor=[UIColor clearColor];
        T_name.textColor=[UIColor colorWithWhite:255 alpha:1.0];//设置姓名的颜色为铬黄
        T_name.font=[UIFont fontWithName:@"Helvetica" size:15];
        T_name.text=@"";
        T_name.textAlignment=NSTextAlignmentCenter;
        [InfoCenterBackground addSubview:T_name];
        //领导昵称
        UILabel *T_nickname=[[UILabel alloc]initWithFrame:CGRectMake(T_name.frame.origin.x, T_name.frame.origin.y+T_name.frame.size.height, imageSize, T_name.frame.size.height)];
        T_nickname.backgroundColor=[UIColor clearColor];
        T_nickname.font=[UIFont fontWithName:@"Helvetica" size:10];
        T_nickname.textColor=[UIColor colorWithRed:255 green:128 blue:0 alpha:1.0];
        T_nickname.text=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"]];
        T_nickname.textAlignment=NSTextAlignmentCenter;
        //[Snickname sizeToFit];
        [InfoCenterBackground addSubview:T_nickname];
        
    }
}
#pragma 领导请求
-(void)InfoCenter_Request_leaderToCheck{
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"], @"userNickname",@"Role_Leader",@"role", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,infoCenterCheck_Leader_Url]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForInfoCenterHeadTeacher:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForInfoCenterLeader:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求

}
#pragma mark---------------登陆者为领导-------查看个人信息
- (void)ASIHttpRequestSuceedForInfoCenterLeader:(ASIHTTPRequest *)request{
    [SVProgressHUD showSuccessWithStatus:@"加载成功"];
    NSData *responseData = [request responseData];
    InfoCenterJsons=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",InfoCenterJsons);
  
    @try {
        if ([[InfoCenterJsons objectForKey:@"Status"] isEqualToString:@"NotHaveUser"])
        {
            [self.view makeToast:@"没有该用户。。。"];
        }else
        {
            T_name.text=[NSString stringWithFormat:@"%@",[InfoCenterJsons valueForKey:@"name"]];
    
            phone=[InfoCenterJsons valueForKey:@"phone"];
            [[NSUserDefaults standardUserDefaults]setObject:phone forKey:@"NewPhone"];
            [InfoCenterTable reloadData];
        }
        
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"领导数据错误 %@",exception] duration:1000];
        NSLog(@"领导数据错误 ==Exception: %@", exception);

    }
    @finally {

            NSLog(@"领导个人中心");
    }
    

}
- (void)viewWillAppear:(BOOL)animated
{
    [InfoCenterTable reloadData];
 }
- (void)viewDidLoad
{
    [super viewDidLoad];
    isImageSheet=NO;
    UIButton *rightbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightbtn.frame=CGRectMake(0, 0, 80, 30);
    rightbtn.backgroundColor=[UIColor clearColor];
    [rightbtn setTitle:@"退出账号" forState:UIControlStateNormal];
    
    //[rightbtn setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
      UIBarButtonItem *right=[[UIBarButtonItem alloc]initWithCustomView:rightbtn];
    self.navigationItem.rightBarButtonItem=right;
    [rightbtn addTarget:self action:@selector(zhuxiao) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"infoBackground"]];
    //加载背景
    [self CreateViewForBackground];
    //添加详细信息列表
    InfoCenterTable=[[UITableView alloc]initWithFrame:CGRectMake(0, InfoCenterBackground.frame.size.height+64, ScreenWidth, ScreenHeight-InfoCenterBackground.frame.size.height-64-48) style:UITableViewStyleGrouped];
    InfoCenterTable.backgroundColor=[UIColor clearColor];
    InfoCenterTable.dataSource=self;
    InfoCenterTable.delegate=self;
    [self.view addSubview:InfoCenterTable];
    
   }
- (void)didClickOnDestructiveButton
{
    OriginalView *zhuxiao=[[OriginalView alloc] init];
    zhuxiao.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:zhuxiao animated:NO];
    self.navigationController.navigationBarHidden=YES;

}
- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex
{//注销方法  直接改变window的rootViewcontroller
    if (isImageSheet) {
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch ((int)buttonIndex) {
                case 0:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                    
                    
            }
        }
        else {
            if ((int)buttonIndex == 1) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = NO;
        
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }

}
-(void)zhuxiao{
    isImageSheet=NO;
    self.actionSheet = [[LXActionSheet alloc]initWithTitle:@"退出后不会删除任何历史数据,下次登录依然可以使用本账号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil];

    [self.actionSheet showInView:self.view];
}
-(void)ShowInfocenterBackground
{
    [SJAvatarBrowser showImage:InfoCenterBackground];
}
#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0)
    {
        return 0.1;
    }else
    {
        return 1;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
          if (section==0)
        {
            return 1;
        }
        else if (section==1)
        {
            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"学生"])
            {
                return 5;
            }
            else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"辅导员"])
            {
                return 2;
            }
            else
            {
                return 1;
            }
        }
        else
        {
            return 2;
        }

  
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *CellIdentifier = @"Cell";
        S_InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[S_InfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle=UITableViewCellSeparatorStyleSingleLine;
            [cell.layer setCornerRadius:8.0];
            cell.userInteractionEnabled=NO;
        }
        cell.alpha=0.5;
        cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:15];
        cell.textLabel.textColor=[UIColor lightGrayColor];
        if (indexPath.section==0)
        {
            cell.InfoLael.textAlignment=NSTextAlignmentLeft;
            cell.InfoLael.font=[UIFont fontWithName:@"Helvetica" size:18];
            cell.InfoLael.text=@"     基本信息";
            cell.userInteractionEnabled=NO;
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.textLabel.text=nil;
            cell.detailTextLabel.text=nil;
        }else if (indexPath.section==1)
        {//第二部分 学生
            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"学生"])
            {
                NSArray *arr1=[NSArray arrayWithObjects:@"学号",@"身份证号",@"年级",@"专业",@"班级", nil];
                cell.textLabel.text=[arr1 objectAtIndex:indexPath.row];
                cell.InfoLael.text=[Person_Student objectAtIndex:indexPath.row];
                
            }
            else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"辅导员"])
            {//辅导员
                if (indexPath.row==0)
                {
                    cell.textLabel.text=@"身份证号";
                    cell.InfoLael.text=HeadTeacherCardNum;
                    
                }
                else
                {
                    cell.textLabel.text=@"管辖班级";
                    cell.InfoLael.textAlignment=NSTextAlignmentCenter;
                    cell.InfoLael.text=@"          点击查看";
                    cell.detailTextLabel.textColor=[UIColor blackColor];
                    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                    cell.userInteractionEnabled=YES;
                }
            }
            else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"普通教师"])
                
            {//普通教师
                cell.textLabel.text=@"身份证号";
                cell.InfoLael.text=TeacherCardNum;
                
            }
            else{
                //领导
                cell.textLabel.text=@"身份证号";
                if (TeacherCardNum.length) {
                    cell.InfoLael.text=TeacherCardNum;
                }else
                {
                    cell.InfoLael.text=@"130983195602141652";
                }
            }
        }
        else
        {
            
            NSArray *arr3=[NSArray arrayWithObjects:@"手机号码",@"密码", nil];
            NSArray *arr4=[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults]objectForKey:@"NewPhone"],@"", nil];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled=YES;
            cell.detailTextLabel.font=[UIFont fontWithName:@"Helvetica" size:12];
            cell.detailTextLabel.text=@"可修改";
            cell.textLabel.text=[arr3 objectAtIndex:indexPath.row];
            cell.InfoLael.text=[arr4 objectAtIndex:indexPath.row];
        }
        return cell;

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"加载个人信息错误 %@",exception] duration:1000];
        NSLog(@"加载个人信息==Exception: %@", exception);
    }
    @finally {
        NSLog(@"加载个人信息");
    }
}
#pragma mark-----TableViewDele+gate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"---%ld,--%ld",(long)indexPath.section,(long)indexPath.row);
    if (indexPath.section==1)
    {
        ClassesListByHeadTeacher *classlist=[[ClassesListByHeadTeacher alloc]init];
        classlist.title=@"管辖班级列表";
        classlist.Classlists=ClassesmanagedByHead;
        classlist.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:classlist animated:YES];
    }else if (indexPath.section==2)
     {
         if (indexPath.row==1)
         {
             DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"请输入原密码:" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
             UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
             contentView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.3 brightness:1.0 alpha:0.8];
             alertView.alertViewStyle = DLAVAlertViewStyleSecureTextInput;
             [alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
                 NSLog(@"Tapped button '%p' at index: %ld (with input: '%@')", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex, [alertView textFieldTextAtIndex:0]);
            if (buttonIndex==1)
                 {
        if ([[alertView textFieldTextAtIndex:0] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]])
        {//进行密码验证
            NSLog(@"密码正确%d",buttonIndex);
            
            ChangingDetail *change=[[ChangingDetail alloc]init];
            //不同身份传送不同的修改URL
            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"学生"])
            {
                change.IDIdentifer=@"Role_Student";
                change.InfoChangeURL=infoCenterChange_Student_Url;
            }
            else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"辅导员"])
            {
                change.IDIdentifer=@"Role_HeadTeacher";
                change.InfoChangeURL=infoCenterChange_headTeacher_Url;
            }
            else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"领导"])
            {//普通教师
                change.IDIdentifer=@"Role_Teacher";
                change.InfoChangeURL=infoCenterChange_Teacher_Url;
                
            }
            else{
                //领导
                change.IDIdentifer=@"Role_Leader";
                change.InfoChangeURL=infoCenterChange_Leader_Url;
            }
            change.title=@"密码修改";
            change.XiugaiChoice=@"密码";
            change.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:change animated:YES];
            
        }
            
        else
     {
        [self.view makeToast:@"密码错误"];
         
     }
                 
    }
    }];
             NSLog(@"修改密码");

         }
         else
         {
             ChangingDetail *change1=[[ChangingDetail alloc]init];
             //不同身份传送不同的修改URL
             if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"学生"])
             {
                 change1.IDIdentifer=@"Role_Student";
                 change1.InfoChangeURL=infoCenterChange_Student_Url;
             }
             else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"辅导员"])
             {
                 change1.IDIdentifer=@"Role_HeadTeacher";
                 change1.InfoChangeURL=infoCenterChange_headTeacher_Url;
             }
             else
             {//普通教师
                 change1.IDIdentifer=@"Role_Teacher";
                 change1.InfoChangeURL=infoCenterChange_Teacher_Url;
             }

             change1.title=@"手机号码修改";
             change1.XiugaiChoice=@"手机号码";
             change1.hidesBottomBarWhenPushed=YES;
             [self.navigationController pushViewController:change1 animated:YES];

             NSLog(@"修改手机号");
         }
     }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)tabImageName
{
	return @"personunselect.png";
}

- (NSString *)tabTitle
{
	return self.title=@"个人中心";
}
#pragma mark - actionsheet delegate 判断是否支持相机与相册功能
#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
	[picker dismissViewControllerAnimated:YES completion:^{}];
    //得到图片
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self saveImage:image withName:@"currentImage.png"];
    //图片文件的URL
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    NSLog(@"相片====%@",fullPath);
    
    isFullScreen = NO;
    [self.picture setImage:savedImage];
    NSArray *imagePathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *imagePath=[[imagePathArray objectAtIndex:0] stringByAppendingPathComponent:@"currentImage.png"];
    
    NSData *imageData=[NSData dataWithContentsOfFile:imagePath];
    NSString* pictureDataString = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//图片转码成为base64Encoding
    
       NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserNickName"],@"nickname",pictureDataString,@"headSculpture",@"png",@"fileExtension",nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,infoCenterheadSculpture_Student_Url]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailed:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceed:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
    

    self.picture.tag = 100;
    
    //图片存入相册
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                    
            }
        }
        else {
            if (buttonIndex == 1) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
       
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = NO;
        
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
       
        
    }
}

- (void)chooseImage:(id)sender {
    isImageSheet=YES;
    [self.tabBarController.tabBar setHidden:YES];
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imageSheet=[[LXActionSheet alloc]initWithTitle:@"添加/更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"拍照",@"从相册选择"]];
    }
    else {
        imageSheet=[[LXActionSheet alloc]initWithTitle:@"添加/更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"从相册选择"]];
    }
    
    sheet.tag = 255;
    NSLog(@"图片");
    
    [imageSheet showInView:self.view];
    
}
-(void)openPicLibrary
{
    //相册是可以用模拟器打开的
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;//是否可以编辑
        
        //打开相册选择照片
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
             }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"你没有摄像头" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}
//选中图片进入的代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
//网络请求失败
- (void)ASIHttpRequestFailed:(ASIHTTPRequest *)request{
    
    //if (request)
    //{}
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceed:(ASIHTTPRequest *)request{
    
    NSData *responseData = [request responseData];
    jsonObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",jsonObjects);
    touxiao=[jsonObjects valueForKey:@"URL"];
    NSLog(@"%@",touxiao);
    if (touxiao!=nil) {
        [imageBtn removeFromSuperview];
        [self CreateViewForBackground];
    }
}


@end
