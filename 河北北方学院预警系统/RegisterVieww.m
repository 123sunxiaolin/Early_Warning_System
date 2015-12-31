//
//  RegisterVieww.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-1.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "RegisterVieww.h"
#import <QuartzCore/QuartzCore.h>
#import "SelectionCell.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "Defines.h"
#import "SVProgressHUD.h"
#import "Toast+UIView.h"
#import "iToast.h"
@interface RegisterVieww ()
@end
@implementation RegisterVieww
@synthesize Name;
@synthesize NickName;
@synthesize StudNum;
@synthesize PhoneNumber;
@synthesize IDNumber;
@synthesize Password;
@synthesize ConFirmNum;
@synthesize BanjiTEXT;
@synthesize NianjiText;
@synthesize ZhuanYeTEXT;
@synthesize XueYuanTEXT;
@synthesize tb1,tb2,tb3,tb4;
@synthesize btn1,btn2,btn3,btn4;
@synthesize URL;
@synthesize etactivity1;
#pragma FirstRequestDelegate for  College Grade
- (void)ASIHttpRequestFailedForFirst:(ASIHTTPRequest *)request{
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    NSError *error = [request error];
    [request setNumberOfTimesToRetryOnTimeout:2];
    NSString *errorStr=[error.userInfo valueForKey:@"NSLocalizedDescription"];
    if ([errorStr isEqualToString:@"The request timed out"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"网络请求超时，请重新连接" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag=100;
        [alert show];
        alert.alpha=0.5;
        alert.backgroundColor=[UIColor cyanColor];

    }else if([errorStr isEqualToString:@"A connection failure occurred"]){
        [SVProgressHUD showErrorWithStatus:@"网络连接失败"];
 }
 NSLog(@"the error is1234 %@",errorStr);
 }
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 10:
            alertView.hidden=YES;
            [NSThread sleepForTimeInterval:0.8];
            [self dismissViewControllerAnimated:YES completion:nil];

            break;
            case 11:
            alertView.hidden=YES;
            [NSThread sleepForTimeInterval:0.8];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
         default:
            break;
    }
    //判断buttonIndex的值，buttonIndex的值从上往下由0开始。
}
 //网络请求成功
 - (void)ASIHttpRequestSuceedForFirst:(ASIHTTPRequest *)request{
    [SVProgressHUD dismiss];
     self.view.userInteractionEnabled=YES;
  NSData *responseData = [request responseData];
  JsonFirst=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
     
     @try {
     NSLog(@"json解析＝%@",JsonFirst);
     if (![JsonFirst count]) {
         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"数据未加载成功，请重新进入" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
         alert.tag=11;
         [alert show];

     }else{
         btn4.enabled=YES;//使学院选择的按钮激活
         //获取学院名称
         NSArray *Colleges=[[NSArray alloc] initWithArray:[JsonFirst valueForKey:@"college"]];
         NSArray *Grades=[[NSArray alloc]initWithArray:[JsonFirst valueForKey:@"grade"]];
         NSArray *textfields=[[NSArray alloc]initWithObjects:NianjiText,XueYuanTEXT, nil];
         NSArray *btns=[[NSArray alloc]initWithObjects:btn1,btn4,nil];
         NSArray *tbs=[[NSArray alloc]initWithObjects:tb1,tb4, nil];

         NSInteger counts=[Colleges count];
         NSInteger counts1=[Grades count];
         for (int i=0; i<2; i++) {
                [[tbs objectAtIndex:i]initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
                    if (i==0) {
                        return counts1;
                    }else{
             return counts;
                    }
         }
                        setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
                            SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
                            if (!cell) {
                                cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
                                [cell setSelectionStyle: UITableViewCellSelectionStyleGray];
                            }
                            cell.lb.font=[UIFont systemFontOfSize:13];
                            if (i==0) {
                                [cell.lb setText:[Grades objectAtIndex:indexPath.row]];
                            }else{
                            [cell.lb setText:[Colleges objectAtIndex:indexPath.row]];
                            }
                            return cell;
                        }
                            setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
                                
                                SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
                                [[textfields objectAtIndex:i]setText:cell.lb.text];
                                [[btns objectAtIndex:i] sendActionsForControlEvents:UIControlEventTouchUpInside];

                            }];
             if (i==0) {
                [tb1.layer setBorderColor:[UIColor lightGrayColor].CGColor];
                 [tb1.layer setBorderWidth:2];
             }
             else{
                 [tb4.layer setBorderColor:[UIColor lightGrayColor].CGColor];
                 [tb4.layer setBorderWidth:2];
             }

         }
          }
     }
     @catch (NSException *exception) {
         [iToast make:[NSString stringWithFormat:@"学生注册错误 %@",exception] duration:1000];
         NSLog(@"学生注册==Exception: %@", exception);
     }
     @finally {
         NSLog(@"学生注册");
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
#pragma 注册时获取学院信息
-(void)getNetworkRequestFirst
{
   
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",IP,REGISTER];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForFirst:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForFirst:)];
    [request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    //当请求超时的措施
    [SVProgressHUD showWithStatus:@"正在加载数据..."];
    self.view.userInteractionEnabled=NO;
}
#pragma SecondRequestDelegate  for  profession
-(void)getNetworkRequestSecond
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:XueYuanTEXT.text, @"collegeName",NianjiText.text,@"yearClass", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成Name.text assword.text _IdShow.text
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,REGISTER2]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForSecond:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForSecond:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求

}
- (void)ASIHttpRequestFailedForSecond:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"网络连接失败，请重新连接网络" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag=10;
        [alert show];
        alert.alpha=0.5;
        alert.backgroundColor=[UIColor cyanColor];
        
    }
    NSLog(@"the error is %@",error);
}
//网络请求成功
- (void)ASIHttpRequestSuceedForSecond:(ASIHTTPRequest *)request{
    
    NSData *responseData = [request responseData];
    JsonObjects2=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",JsonObjects2);
    @try {
    if (![JsonObjects2 count]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"数据未加载成功，请重新进入" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag=11;
        [alert show];
        
    }else{
        btn2.enabled=YES;
        NSArray *Professions=[JsonObjects2 valueForKey:@"profession"];
        NSInteger professioncount=Professions.count;
        [tb2 initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
            return professioncount;
        }
                       setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
                           SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
                           if (!cell) {
                               cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
                               [cell setSelectionStyle: UITableViewCellSelectionStyleGray];
                           }
                           cell.lb.font=[UIFont systemFontOfSize:13];
                           [cell.lb setText:[Professions objectAtIndex:indexPath.row]];

                           return cell;

                       }
                           setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
                               SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
                               [ZhuanYeTEXT setText:cell.lb.text];
                               [btn2 sendActionsForControlEvents:UIControlEventTouchUpInside];
                           }];
        [tb2.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [tb2.layer setBorderWidth:2];

    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"学生注册错误 %@",exception] duration:1000];
        NSLog(@"学生注册==Exception: %@", exception);
    }
    @finally {
        NSLog(@"学生注册二级服务器请求");
    }
}
#pragma ThirdRequestDelegateFor Class
-(void)getNetworkRequestThird
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:XueYuanTEXT.text, @"collegeName",NianjiText.text,@"yearClass",ZhuanYeTEXT.text,@"profession", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成Name.text assword.text _IdShow.text
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,REGISTER3]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForThird:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForThird:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForThird:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    if (error) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"网络连接失败，请重新连接网络" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag=10;
        [alert show];
        alert.alpha=0.5;
        alert.backgroundColor=[UIColor cyanColor];
        
    }
    NSLog(@"the error is %@",error);
}
//网络请求成功
- (void)ASIHttpRequestSuceedForThird:(ASIHTTPRequest *)request{
    
    NSData *responseData = [request responseData];
    JsonObjectDic=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",JsonObjectDic);
    @try {
    if (![JsonObjectDic count]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"数据未加载成功，请重新进入" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag=11;
        [alert show];
        
    }else{
        btn3.enabled=YES;
        NSArray *Class=[JsonObjectDic valueForKey:@"classID"];
       // NSSet *ClassSet=[NSSet setWithArray:Class];
        NSInteger ClassCount=Class.count;
        [tb3 initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
            return ClassCount;
        }
                       setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
                           SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
                           if (!cell) {
                               cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
                               [cell setSelectionStyle: UITableViewCellSelectionStyleGray];
                           }
                           cell.lb.font=[UIFont systemFontOfSize:13];
                           [cell.lb setText:[Class objectAtIndex:indexPath.row]];
                           
                           return cell;
                           
                       }
                           setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
                               SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
                               [BanjiTEXT setText:cell.lb.text];
                               [btn3 sendActionsForControlEvents:UIControlEventTouchUpInside];
                           }];
        [tb3.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [tb3.layer setBorderWidth:2];

    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"学生注册错误 %@",exception] duration:1000];
        NSLog(@"学生注册==Exception: %@", exception);

    }
    @finally {
        
        NSLog(@"学生注册三级服务器请求");
    }
}
#pragma MainRequestDelegateFor Register
-(void)getNetworkRequestMain
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:Name.text,@"studentName",NickName.text,@"nickname",StudNum.text,@"id",PhoneNumber.text,@"studentPhone",IDNumber.text,@"studentCardId",Password.text,@"password",@"Role_Student",@"role",XueYuanTEXT.text, @"college",NianjiText.text,@"grade",ZhuanYeTEXT.text,@"profession",BanjiTEXT.text,@"classId", nil];
      //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成Name.text assword.text _IdShow.text
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,STUDENTURL]];
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
    etactivity1.hidden=YES;
    self.view.userInteractionEnabled=YES;

    NSData *responseData = [request responseData];
    JsonData=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",JsonData);
    @try {
    if ([[JsonData valueForKey:@"Status"] isEqualToString:@"Success"])
    {
        //
        //保存身份
        [[NSUserDefaults standardUserDefaults]setObject:@"学生" forKey:@"UserID"];
        //保存用户名
        [[NSUserDefaults standardUserDefaults]setObject:NickName.text forKey:@"UserNickName"];
        
        etactivity1.hidden=YES;
        self.view.userInteractionEnabled=YES;
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        NSString *shenfen=[NSString stringWithFormat:@"学生"];
        [dic setValue:shenfen forKey:@"shenfen"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PostData" object:self userInfo:dic];
    }
    else if ([[JsonData objectForKey:@"Status"] isEqualToString:@"Auditing"]){
         [self.view makeToast:@"正在审核教师身份，请稍等......."];
    }
    else if ([[JsonData objectForKey:@"Status"] isEqualToString:@"Fail"])
    {
        [SVProgressHUD showErrorWithStatus:@"注册失败，请重新尝试....."];//需要将textfield置空
    }
    else if ([[JsonData objectForKey:@"Status"] isEqualToString:@"UserNicknameRepeat"])
    {
        [self.view makeToast:@"该昵称已存在\n请重新输入"];
    }
    else
    {
        [self.view makeToast:@"未知名网络错误"];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"学生注册错误 %@",exception] duration:1000];
        NSLog(@"学生注册==Exception: %@", exception);

    }
    @finally {
        
        NSLog(@"注册事件");
    }

}
-(void)UIassume
{
    Name.delegate=self;
    NickName.delegate=self;
    StudNum.delegate=self;
    PhoneNumber.delegate=self;
    IDNumber.delegate=self;
    Password.delegate=self;
    ConFirmNum.delegate=self;
    Name.clearButtonMode=UITextFieldViewModeAlways;
    NickName.clearButtonMode=UITextFieldViewModeAlways;
    StudNum.clearButtonMode=UITextFieldViewModeAlways;
    PhoneNumber.clearButtonMode=UITextFieldViewModeAlways;
    IDNumber.clearButtonMode=UITextFieldViewModeAlways;
    Password.clearButtonMode=UITextFieldViewModeAlways;
    ConFirmNum.clearButtonMode=UITextFieldViewModeAlways;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isOpened=NO;
    //[self getNetworkRequestFirst];
    btn1.enabled=NO;
    btn2.enabled=NO;
    btn3.enabled=NO;
    btn4.enabled=NO;
    NSArray *tbs=[[NSArray alloc]initWithObjects:tb1,tb2,tb3,tb4, nil];
    for (int i=0; i<4; i++) {
        [[tbs objectAtIndex:i]
         setHidden:YES];//设置隐藏
    }
    [self UIassume];
    //[self UIDataBase];
    NSLog(@"URL%@",URL);
   
 }
- (void)viewWillAppear:(BOOL)animated
{
   [self getNetworkRequestFirst];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)backGroundTap:(id)sender {
    [Name resignFirstResponder];
    [NickName resignFirstResponder];
    [StudNum resignFirstResponder];
    [PhoneNumber resignFirstResponder];
    [IDNumber resignFirstResponder];
    [Password resignFirstResponder];
    [ConFirmNum resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{//点击return键盘隐藏
    if (theTextField==Name||theTextField==NickName || theTextField==Password||theTextField==ConFirmNum||theTextField==IDNumber) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

#pragma DroplistClickDelegate
- (IBAction)NianjiBtn:(id)sender {
    tb1.hidden=NO;
    [Name resignFirstResponder];
    [Password resignFirstResponder];
    if (isOpened) {
        
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [btn1 setImage:closeImage forState:UIControlStateNormal];
            CGRect frame=tb1.frame;
            frame.size.height=1;
            [tb1 setFrame:frame];
            
        } completion:^(BOOL finished){
            
            isOpened=NO;
        }];
    }else{
        
        
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            [btn1 setImage:openImage forState:UIControlStateNormal];
            
            CGRect frame=tb1.frame;
            
            frame.size.height=120;
            [tb1 setFrame:frame];
        } completion:^(BOOL finished){
            
            isOpened=YES;
        }];
        
    }
    if (NianjiText.text.length) {
        //发送第二次请求获取专业
        [self getNetworkRequestSecond];
    }
    NSLog(@"selected:%@",NianjiText.text);
}
- (IBAction)ZhuanYeBtn:(id)sender {
    tb2.hidden=NO;
    [Name resignFirstResponder];
    [Password resignFirstResponder];
    if (isOpened) {
        btn4.hidden=NO;
        XueYuanTEXT.hidden=NO;//处理视图重叠问题
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [btn2 setImage:closeImage forState:UIControlStateNormal];
            CGRect frame=tb2.frame;
            frame.size.height=1;
            [tb2 setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
    }else{
        
        btn4.hidden=YES;
        XueYuanTEXT.hidden=YES;
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            [btn2 setImage:openImage forState:UIControlStateNormal];
            CGRect frame=tb2.frame;
            frame.size.height=120;
            [tb2 setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=YES;
        }];
    }
    if (ZhuanYeTEXT.text.length) {
        //发送第三次请求  获取对应的班级
        [self getNetworkRequestThird];
    }
    NSLog(@"selected:%@",ZhuanYeTEXT.text);

    
}
- (IBAction)BanjiBtn:(id)sender {
    tb3.hidden=NO;
    [Name resignFirstResponder];
    [Password resignFirstResponder];
    if (isOpened) {
        btn4.hidden=NO;
        tb4.hidden=NO;
        XueYuanTEXT.hidden=NO;//处理视图重叠问题
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [btn3 setImage:closeImage forState:UIControlStateNormal];
            CGRect frame=tb3.frame;
            frame.size.height=1;
            [tb3 setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
    }else{
        btn4.hidden=YES;
        tb4.hidden=YES;
        XueYuanTEXT.hidden=YES;
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            [btn3 setImage:openImage forState:UIControlStateNormal];
            CGRect frame=tb3.frame;
            frame.size.height=100;
            [tb3 setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=YES;
        }];
    }
    NSLog(@"selected:%@",BanjiTEXT.text);
}
- (IBAction)XueYuanBtn:(id)sender {
    tb4.hidden=NO;
    //btn1.enabled=YES;
    [Name resignFirstResponder];
    [Password resignFirstResponder];
    if (isOpened) {
        
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [btn4 setImage:closeImage forState:UIControlStateNormal];
            CGRect frame=tb4.frame;
            frame.size.height=1;
            [tb4 setFrame:frame];
        } completion:^(BOOL finished){
            isOpened=NO;
        }];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            [btn4 setImage:openImage forState:UIControlStateNormal];
            CGRect frame=tb4.frame;
            frame.size.height=120;
            [tb4 setFrame:frame];
        } completion:^(BOOL finished){
            
            isOpened=YES;
        }];
        
        
    }
    if (XueYuanTEXT.text.length) {
        btn1.enabled=YES;
    }
    NSLog(@"selected:%@",XueYuanTEXT.text);
}

- (IBAction)RegisterBtn:(id)sender {
    //判断是否为空
    if ([Name.text isEqualToString:@""]||[NickName.text isEqualToString:@""]||[StudNum.text isEqualToString:@""]||[PhoneNumber.text isEqualToString:@""]||[IDNumber.text isEqualToString:@""]||[Password.text isEqualToString:@""]||[ConFirmNum.text isEqualToString:@""]||[NianjiText.text isEqualToString:@""]||[ZhuanYeTEXT.text isEqualToString:@""]||[BanjiTEXT.text isEqualToString:@""]||[XueYuanTEXT.text isEqualToString:@""]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"当您的注册信息没有输入完整，是无法完成注册"
                                                    delegate:self cancelButtonTitle:@"知道咯！" otherButtonTitles:nil, nil];
        [alert show];
        
    }else if([Password.text length]<7)
    {
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入的密码不足7个字符，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else if ([Password.text length]>16)
    {
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入的密码超过16个字符，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];

        
    }else if(![Password.text isEqualToString:ConFirmNum.text])
    {//判断密码和确认密码是否一致
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您两次输入的密码不一致，请查正后重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else if([PhoneNumber.text length]!=11)
    {
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入的手机号码无效，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else if([IDNumber.text length]!=18)
    {
        NSLog(@"%d",[IDNumber.text length]);
        UIAlertView *tip=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您输入的身份证号无效，请重新输入" delegate:self cancelButtonTitle:@"我知道咯" otherButtonTitles:nil, nil];
        [tip show];
    }else
    {
        tb1.hidden=YES;
        tb2.hidden=YES;
        tb3.hidden=YES;
        tb4.hidden=YES;
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

@end
