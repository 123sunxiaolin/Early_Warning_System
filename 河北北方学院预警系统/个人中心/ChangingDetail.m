//
//  ChangingDetail.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-10.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "ChangingDetail.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "Defines.h"
#import "Toast+UIView.h"


#define HeadTeacherChange @"/school5/headTeacherChange.html"
#define StudentUrl @"/school5/studentChange.html"
@interface ChangingDetail ()
@end
@implementation ChangingDetail
@synthesize XiugaiChoice,nickName;
@synthesize numberText;
@synthesize phoneLable;
@synthesize image1;
@synthesize image2;
@synthesize presentPassword;
@synthesize passwordNew;
@synthesize bt;
@synthesize IDIdentifer,InfoChangeURL;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark----------------请求修改----电话号码
-(void)SubmitRequestForChanging
{
    [SVProgressHUD showWithStatus:@"正在修改数据"];
    NSDictionary *user;
    //数据加载。。。
    if ([XiugaiChoice isEqualToString:@"手机号码"])
    {//手机号码修改
         user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"], @"userNickname",IDIdentifer,@"role",@"",@"oldPassword",@"",@"newPassword",numberText.text,@"phone", nil];
    }
    else
    {//密码修改
        user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"], @"userNickname",IDIdentifer,@"role",[[NSUserDefaults standardUserDefaults]objectForKey:@"UserPassword"],@"oldPassword",passwordNew.text,@"newPassword",@"",@"phone", nil];

    }
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,InfoChangeURL]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForDetail:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForDetail:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForDetail:(ASIHTTPRequest *)request
{
    [SVProgressHUD showErrorWithStatus:@"获取个人信息失败"];
   // [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForDetail:(ASIHTTPRequest *)request
{
    [SVProgressHUD showSuccessWithStatus:@"修改成功"];

    NSData *responseData = [request responseData];
    JsonStatus=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",JsonStatus);
    @try {
    if ([[JsonStatus valueForKey:@"Status"] isEqualToString:@"NotHaveUser"])
    {
        [self.view makeToast:@"没有该用户"];
    }else if ([[JsonStatus valueForKey:@"Status"] isEqualToString:@"CannotAnalyzeData"])
    {
        [self.view makeToast:@"不能解析数据"];
    }
    else if ([[JsonStatus valueForKey:@"Status"] isEqualToString:@"Success"])
    {//返回成功
        if ([XiugaiChoice isEqualToString:@"手机号码"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:numberText.text forKey:@"NewPhone"];
            [numberText resignFirstResponder];
        }
        else
        {
            [presentPassword resignFirstResponder];
            [passwordNew resignFirstResponder];
        }
        [self.view makeToast:@"修改成功!"];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(back) userInfo:nil repeats:NO];
   
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"修改失败==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"修改失败==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"修改信息");
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([XiugaiChoice isEqualToString:@"手机号码"]) {
        phoneLable.hidden=NO;
        numberText.hidden=NO;
        image2.hidden=YES;
        image1.hidden=YES;
        presentPassword.hidden=YES;
        passwordNew.hidden=YES;
        numberText.delegate=self;
        numberText.keyboardType=UIKeyboardTypePhonePad;
        numberText.clearButtonMode=UITextFieldViewModeAlways;
    }else if ([XiugaiChoice isEqualToString:@"密码"]){
        phoneLable.hidden=YES;
        numberText.hidden=YES;
        presentPassword.delegate=self;
        passwordNew.delegate=self;
        presentPassword.keyboardType=UIKeyboardTypeDefault;
        passwordNew.keyboardType=UIKeyboardTypeDefault;
        presentPassword.clearButtonMode=UITextFieldViewModeAlways;
        passwordNew.clearButtonMode=UITextFieldViewModeAlways;
        
    }
    bt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt.backgroundColor=[UIColor clearColor];
    [bt.layer setCornerRadius:3.0];
    bt.frame=CGRectMake(5, 5, 40, 30);
    [bt setTitle:@"确认" forState:UIControlStateNormal];
    bt.titleLabel.font=[UIFont systemFontOfSize:17];
    [bt setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [bt setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    //bt.userInteractionEnabled=NO;
    [bt addTarget:self action:@selector(ComeBackData:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right=[[UIBarButtonItem alloc]initWithCustomView:bt];
    self.navigationItem.rightBarButtonItem=right;
    
    //返回按钮
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(0, 0, 32, 32);
    [back setImage:[UIImage imageNamed:@"InfoCenter_back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left_btn=[[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem=left_btn;

    
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{//点击return键盘隐藏
    if (theTextField==numberText||theTextField==presentPassword||theTextField==passwordNew) {
        [theTextField resignFirstResponder];
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ComeBackData:(id)sender
{
    //ChngeINfoView *info=[[ChngeINfoView alloc]init];
    if ([XiugaiChoice isEqualToString:@"手机号码"]) {
        if ([numberText.text length]!=11) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入手机号码无效，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
            [alert show];
        }else
        {
            
            
            [self SubmitRequestForChanging];
             //在这里需要注意只有上传服务器成功后才能存储到plist
            bt.hidden=NO;
            /*NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"data.plist"];
            NSMutableDictionary *datadic=[[[NSMutableDictionary alloc]initWithContentsOfFile:path] mutableCopy];
            [datadic setObject:numberText.text forKey:@"phonenumber"];
            [datadic writeToFile:path atomically:YES];
            //这里需要向服务器发送数据，根据返回值提示信息
            [self.navigationController popViewControllerAnimated:YES];*/
        }
    }else if ([XiugaiChoice isEqualToString:@"密码"]){
        if ([presentPassword.text length]<7||[presentPassword.text length]>16) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请输入7～16位密码" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
            [alert show];

        }else if ([passwordNew.text length]<7||[passwordNew.text length]>16){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请输入7～16位密码" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
            [alert show];

        }else if (![presentPassword.text isEqualToString:passwordNew.text]){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入密码不一致，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
            [alert show];
            presentPassword.text=@"";
            passwordNew.text=@"";
        }else{
            bt.hidden=NO;
            [self SubmitRequestForChanging];
        }
    }

}
- (IBAction)backgrondTap:(id)sender {
    [numberText resignFirstResponder];
    [presentPassword resignFirstResponder];
    [passwordNew resignFirstResponder];
}
@end
