//
//  LoginView.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-2-27.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "LoginView.h"
#import <QuartzCore/QuartzCore.h>
#import "SelectionCell.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "ASIFormDataRequest.h"
#import "Defines.h"
#import "SVProgressHUD.h"
@interface LoginView ()

@end
@implementation LoginView
@synthesize Name;
@synthesize Password;
@synthesize ID;
@synthesize IdShow;
//@synthesize URL;
@synthesize etactivity;
/*使用昵称进行登录*/
//网络请求失败
- (void)ASIHttpRequestFailed_login:(ASIHTTPRequest *)request{
    [SVProgressHUD dismiss];
    NSError *error = [request error];
    [self.view makeToast:Request_TimeOut];
    NSLog(@"the error is %@",error);
    //etactivity.hidden=YES;
    self.view.userInteractionEnabled=YES;
}
//网络请求成功
- (void)ASIHttpRequestSuceed_login:(ASIHTTPRequest *)request{
    NSData *responseData = [request responseData];
    JsonObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",JsonObjects);
    //etactivity.hidden=YES;
    self.view.userInteractionEnabled=YES;
    @try {
    if ([[JsonObjects objectForKey:@"Status"] isEqualToString:@"Success"])
    {
        [SVProgressHUD showSuccessWithStatus:@"成功"];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setValue:IdShow.text forKey:@"shenfen"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PostData" object:self userInfo:dic];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //获取完整路径
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"user.plist"];
        //在这里的数据是通过解析获得的
        NSMutableDictionary *dictplist = [[NSMutableDictionary alloc ] init];
        [dictplist setObject:Name.text forKey:@"userName"];
        [dictplist writeToFile:plistPath atomically:YES];

    }
    else if ([[JsonObjects objectForKey:@"Status"] isEqualToString:@"NotHaveUser"]){
        [SVProgressHUD dismiss];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"该用户名不存在，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [alert show];
        _tb.hidden=YES;
    }
    else if([[JsonObjects objectForKey:@"Status"] isEqualToString:@"PasswordError"]){
        [SVProgressHUD dismiss];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"密码错误,请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [alert show];
       _tb.hidden=YES;
    }
    else
    {
        [SVProgressHUD dismiss];
        [self.view makeToast:@"未知名网络错误"];
        _tb.hidden=YES;
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"该用户名不存在==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"该用户名不存在==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"该用户名");
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //输入登录接口
    Name.clearButtonMode=UITextFieldViewModeAlways;//用于一次性删除输入框中的内容
    Name.delegate=self;
    Password.clearButtonMode=UITextFieldViewModeAlways;
    Password.delegate=self;
    //设置默认用户登录
    Name.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"];
    Password.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"UserPassword"];
    IdShow.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];

    //下拉列表
    _tb.hidden=YES;
    NSArray *IdArr=[[NSArray alloc]initWithObjects:@"学生",@"辅导员",@"普通教师",@"领导", nil];
    NSInteger rowNumber=[IdArr count];
    isOpened=NO;
    [_tb initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        return rowNumber;
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
            [cell setSelectionStyle: UITableViewCellSelectionStyleGray];
        }
        [cell.lb setText:[IdArr objectAtIndex:indexPath.row]];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        IdShow.text=cell.lb.text;
        [_OpenButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
    
    [_tb.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_tb.layer setBorderWidth:2];

   
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)BackgroundTap:(id)sender {
    [Name resignFirstResponder];
    [Password resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{//点击return键盘隐藏
    if (theTextField==Name || theTextField==Password) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)CancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)changeOpenStatus:(id)sender {
    _tb.hidden=NO;
    [Name resignFirstResponder];
    [Password resignFirstResponder];
    if (isOpened) {
        
         [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [_OpenButton setImage:closeImage forState:UIControlStateNormal];
            
            CGRect frame=_tb.frame;
            
            frame.size.height=1;
            [_tb setFrame:frame];
            
        } completion:^(BOOL finished){
            
            isOpened=NO;
        }];
    }else{
        
        
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            [_OpenButton setImage:openImage forState:UIControlStateNormal];
            
            CGRect frame=_tb.frame;
            
            frame.size.height=120;
            [_tb setFrame:frame];
        } completion:^(BOOL finished){
            
            isOpened=YES;
        }];
        
        
    }
    NSLog(@"selected:%@",IdShow.text);

}
- (IBAction)LoginBtn:(id)sender {
    /*需要根据登录者的身份进行选择*/
    if ([Name.text isEqualToString:@""]||[Password.text isEqualToString:@""]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示！" message:@"请您输入姓名和密码" delegate:self cancelButtonTitle:@"我知道咯！" otherButtonTitles:nil, nil];
        [alertView show];

    }else if ([IdShow.text isEqualToString:@""]) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示！" message:@"请您选择登录身份" delegate:self cancelButtonTitle:@"我知道咯！" otherButtonTitles:nil, nil];
        [alertView show];
    }else
    {
        //数据加载界面
       /* etactivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(120, 250, 60, 60)];
        //you can set your custom color for ETActivityIndicatorView
        etactivity.color = [UIColor cyanColor];
        [etactivity startAAnimating];*/
        [SVProgressHUD showWithStatus:@"正在登录..."];
        [self.view addSubview:etactivity];
        _tb.hidden=YES;
        self.view.userInteractionEnabled=NO;//取消与用户交互
        NSString *m_ID=[[NSString alloc]init];
        if ([IdShow.text isEqualToString:@"学生"])
        {
            m_ID=@"Role_Student";
        }
        else if([IdShow.text isEqualToString:@"普通教师"])
        {
            m_ID=@"Role_Teacher";
        }
        else if ([IdShow.text isEqualToString:@"辅导员"])
        {
            m_ID=@"Role_HeadTeacher";
        }
        else
        {
            m_ID=@"Role_Leader";
        }
        //保存身份
        [[NSUserDefaults standardUserDefaults]setObject:IdShow.text forKey:@"UserID"];
        //保存用户名
        [[NSUserDefaults standardUserDefaults]setObject:Name.text forKey:@"UserNickName"];
        //保存用户密码
        [[NSUserDefaults standardUserDefaults]setObject:Password.text forKey:@"UserPassword"];
        //数据加载。。。
        NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:Name.text, @"userName",Password.text,@"password",m_ID,@"role", nil];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URL_Login]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setValidatesSecureCertificate:NO];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(ASIHttpRequestFailed_login:)];
        [request setDidFinishSelector:@selector(ASIHttpRequestSuceed_login:)];
        //[request startAsynchronous];
        [request setDefaultResponseEncoding:NSUTF8StringEncoding];
        [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempJsonData];
        [request startAsynchronous];//开启同步请求
    }
    
}

- (IBAction)ForgetNum:(id)sender {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请到河北北方学院预警系统管理处修改密码" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
    [alert show];
}
@end
