//
//  RegisterForTeachers.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-3.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "RegisterForTeachers.h"
#import "Defines.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "Toast+UIView.h"
#import "SVProgressHUD.h"
#import "iToast.h"
@interface RegisterForTeachers ()

@end

@implementation RegisterForTeachers
@synthesize Name;
@synthesize NickName;
@synthesize PhoneNum;
@synthesize IDNum;
@synthesize passWord;
@synthesize ConfirmPassword;
@synthesize URL;
@synthesize info;
@synthesize etactivity1
;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)TextfieldAssume
{
    Name.delegate=self;
    NickName.delegate=self;
    PhoneNum.delegate=self;
    IDNum.delegate=self;
    passWord.delegate=self;
    ConfirmPassword.delegate=self;
    Name.clearButtonMode=UITextFieldViewModeAlways;
    NickName.clearButtonMode=UITextFieldViewModeAlways;
    PhoneNum.clearButtonMode=UITextFieldViewModeAlways;
    IDNum.clearButtonMode=UITextFieldViewModeAlways;
    passWord.clearButtonMode=UITextFieldViewModeAlways;
    ConfirmPassword.clearButtonMode=UITextFieldViewModeAlways;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self TextfieldAssume];
     NSLog(@"URL%@",URL);
    NSLog(@"arr==%@",info);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{//点击return键盘隐藏
    if (theTextField==Name||theTextField==NickName || theTextField==passWord||theTextField==ConfirmPassword||theTextField==IDNum) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)BackgroundTap:(id)sender {
    [Name resignFirstResponder];
    [NickName resignFirstResponder];
    [PhoneNum resignFirstResponder];
    [IDNum resignFirstResponder];
    [passWord resignFirstResponder];
    [ConfirmPassword resignFirstResponder];
    
}


- (IBAction)CancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)RegisterBtn:(id)sender {
    //进行输入处理
    if ([Name.text isEqualToString:@""]||[NickName.text isEqualToString:@""]||[PhoneNum.text isEqualToString:@""]||[IDNum.text isEqualToString:@""]||[passWord.text isEqualToString:@""]||[ConfirmPassword.text isEqualToString:@""]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"当您的注册信息没有输入完整，是无法完成注册"
            delegate:self cancelButtonTitle:@"知道咯！" otherButtonTitles:nil, nil];
        [alert show];

    }else if([passWord.text length]<7)
    {
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入的密码不足7个字符，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else if ([passWord.text length]>16)
    {
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入的密码超过16个字符，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else if(![passWord.text isEqualToString:ConfirmPassword.text])
    {//判断密码和确认密码是否一致
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您两次输入的密码不一致，请查正后重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else if([PhoneNum.text length]<11)
    {
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入的手机号码无效，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else if([IDNum.text length]!=18)
    {
        NSLog(@"%d",[IDNum.text length]);
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入的身份证号无效，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else
    {
       etactivity1 = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(120, 250, 60, 60)];
        //you can set your custom color for ETActivityIndicatorView
        etactivity1.color = [UIColor grayColor];
        [etactivity1 startAAnimating];
        [etactivity1 setHidden:NO];
        [self.view addSubview:etactivity1];
        self.view.userInteractionEnabled=NO;
        [self getNetworkRequestMain];

    }
    

}
-(void)getNetworkRequestMain
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:Name.text,@"teacherName",NickName.text,@"nickname",PhoneNum.text,@"teacherPhone",IDNum.text,@"teacherCardId",passWord.text,@"password",@"Role_Teacher",@"role", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成Name.text assword.text _IdShow.text
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,TEACHER]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForMain:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForMain:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForMain:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    etactivity1.hidden=YES;
    self.view.userInteractionEnabled=YES;
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"网络连接错误，请重新连接网络" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        //alert.tag=10;
        [alert show];
        alert.alpha=0.5;
        alert.backgroundColor=[UIColor cyanColor];
        
    }
    NSLog(@"the error is %@",error);
}
//网络请求成功
- (void)ASIHttpRequestSuceedForMain:(ASIHTTPRequest *)request{
    
    NSData *responseData = [request responseData];
    JsonObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
   etactivity1.hidden=YES;
    self.view.userInteractionEnabled=YES;
    NSLog(@"json解析＝%@",JsonObjects);
    @try {
    if ([[JsonObjects objectForKey:@"Status"] isEqualToString:@"Success"]) {
        //保存身份
        [[NSUserDefaults standardUserDefaults]setObject:@"普通教师" forKey:@"UserID"];
        //保存用户名
        [[NSUserDefaults standardUserDefaults]setObject:NickName.text forKey:@"UserNickName"];
        
        etactivity1.hidden=YES;
        self.view.userInteractionEnabled=YES;
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        NSString *shenfen=[NSString stringWithFormat:@"普通教师"];
        [dic setValue:shenfen forKey:@"shenfen"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PostData" object:self userInfo:dic];
        
    }else if ([[JsonObjects objectForKey:@"Status"] isEqualToString:@"Auditing"]){
        [self.view makeToast:@"正在审核教师身份，请稍等......."];
    }else if ([[JsonObjects objectForKey:@"Status"] isEqualToString:@"Fail"]){
        [SVProgressHUD showErrorWithStatus:@"注册失败，请重新尝试....."];//需要将textfield置空
    }else if ([[JsonObjects objectForKey:@"Status"] isEqualToString:@"UserNicknameRepeat"])
    {
        [self.view makeToast:@"该昵称已存在\n 请重新输入"];
    }
    else
    {
        [self.view makeToast:@"未知名网络错误"];
    }

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"任课教师注册错误 %@",exception] duration:1000];
        NSLog(@"任课教师注册==Exception: %@", exception);

    }
    @finally {
        
        NSLog(@"任课教师注册");
    }
}


@end
