//
//  AssistantView.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-3.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "AssistantView.h"
#import "MLTableAlert.h"
#import "Toast+UIView.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "Defines.h"
#import "SVProgressHUD.h"
#import "iToast.h"
@interface AssistantView ()

@end

@implementation AssistantView
@synthesize Name;
@synthesize NickName;
@synthesize PhoneNum;
@synthesize IDNum;
@synthesize XueyuanTEXT;
@synthesize Password;
@synthesize ConfirmPassword;
@synthesize ChooseAlert;
@synthesize ZhuanYeScroll;
@synthesize addbtn;
@synthesize URL;
@synthesize activity;
@synthesize etactivity1;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            }
    return self;
}
-(void)UIAssume
{
    Name.delegate=self;
    NickName.delegate=self;
    PhoneNum.delegate=self;
    IDNum.delegate=self;
    Password.delegate=self;
    ConfirmPassword.delegate=self;
    Name.clearButtonMode=UITextFieldViewModeAlways;
    NickName.clearButtonMode=UITextFieldViewModeAlways;
    PhoneNum.clearButtonMode=UITextFieldViewModeAlways;
    IDNum.clearButtonMode=UITextFieldViewModeAlways;
    Password.clearButtonMode=UITextFieldViewModeAlways;
    ConfirmPassword.clearButtonMode=UITextFieldViewModeAlways;
}
#pragma FirstRequestDelegate for  College
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
}
#pragma 解析获得的学院信息
- (void)ASIHttpRequestSuceedForFirst:(ASIHTTPRequest *)request{
        [SVProgressHUD dismiss];
        self.view.userInteractionEnabled=YES;
        NSData *responseData = [request responseData];
        JSONobjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
        NSLog(@"json解析＝%@",JSONobjects);
    @try{
        if (![JSONobjects count]) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"数据未加载成功，请重新进入" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alert.tag=11;
            [alert show];
            
        }else{
            addbtn.enabled=YES;
            colleges=[[NSMutableArray alloc]init];
            colleges=[JSONobjects valueForKey:@"college" ];
        }
    }
    @catch (NSException *exception) {
        
        [iToast make:[NSString stringWithFormat:@"辅导员注册错误 %@",exception] duration:1000];
        NSLog(@"辅导员注册==Exception: %@", exception);    }
    @finally {
        
        NSLog(@"辅导员注册信息 ");
    }
    

}
-(void)getNetworkRequestFirst
{//第一次请求获取学院信息
    
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",IP,ASSISTANTfirst];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForFirst:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForFirst:)];
    [request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    //当请求超时的措施
    //[request setNumberOfTimesToRetryOnTimeout:2];
    [SVProgressHUD showWithStatus:@"正在加载数据..."];
    self.view.userInteractionEnabled=NO;
}
#pragma SecondRequestDelegate  for  profession
-(void)getNetworkRequestSecond
{//第二次请求  获得相应学院下的班级
    
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:XueyuanTEXT.text, @"collegeName", nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *urlstr = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,ASSISTANTsecond]];//出现问题
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlstr];
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
    
    //添加加载数据界面
    activity=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.center=ZhuanYeScroll.center;
    activity.color=[UIColor grayColor];
    [self.view addSubview:activity];
    [activity startAnimating];
    activity.hidesWhenStopped=YES;
}
- (void)ASIHttpRequestFailedForSecond:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    
    [activity stopAnimating];
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
    objectArr =[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    //[activity stopAnimating];
    //ZhuanYeScroll.backgroundColor=[UIColor clearColor];
    NSLog(@"json解析＝%@",objectArr);
    @try {
        
    if (![objectArr count]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"数据未加载成功，请重新进入" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.tag=11;
        [alert show];
        
    }else{
        //用于清除之前的缓存数据
        //[ZhuanYeArr removeAllObjects];
        
        zonghe=[[NSMutableArray alloc] init];
        for (int i=0; i<[[objectArr valueForKey:@"grade"] count]; i++) {
            NSDictionary *info=[[NSDictionary alloc]init];
            info=[[objectArr valueForKey:@"grade"] objectAtIndex:i];
            NSString *year=[info valueForKey:@"yearClass"];
            NSString *zhuanye=[info valueForKey:@"profession"];
            NSString *class=[info valueForKey:@"classId"];
            NSString * OneInfo=[NSString stringWithFormat:@"%@%@%@",year,zhuanye,class];
            [zonghe addObject:OneInfo];
        }
        
        [activity stopAnimating];
        ZhuanYeArr=[NSMutableArray arrayWithArray:zonghe];
        [self AddZhuanyeQcheck];
        NSLog(@"99999999----%@",zonghe);
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"学生注册第一次数据错误 %@",exception] duration:1000];
        NSLog(@"学生注册第一次数据错误： %@", exception);    }
    @finally {
        
        NSLog(@"学生注册第一次数据错误");
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 10:
            alertView.hidden=YES;
            break;
        case 11:
            [activity stopAnimating];
            break;
        default:
            break;
    }
    //判断buttonIndex的值，buttonIndex的值从上往下由0开始。
}
#pragma MainRequestDelegateFor Register
-(void)getNetworkRequestMain
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:Name.text,@"headTeacherName",NickName.text,@"nickname",PhoneNum.text,@"teacherPhone",IDNum.text,@"teacherCardId",Password.text,@"password",@"Role_HeadTeacher",@"role",XueyuanTEXT.text, @"collegeName",QcheckArr,@"grade", nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,ASSISTANTMain]];
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
    jsonForMain=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    NSLog(@"json解析＝%@",jsonForMain);
    @try {
    if ([[jsonForMain objectForKey:@"Status"] isEqualToString:@"Success"]) {
        //保存身份
        [[NSUserDefaults standardUserDefaults]setObject:@"辅导员" forKey:@"UserID"];
        //保存用户名
        [[NSUserDefaults standardUserDefaults]setObject:NickName.text forKey:@"UserNickName"];
        
        
        etactivity1.hidden=YES;
        self.view.userInteractionEnabled=YES;
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        NSString *shenfen=[NSString stringWithFormat:@"辅导员"];
        [dic setValue:shenfen forKey:@"shenfen"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PostData" object:self userInfo:dic];
       
        
    }else if ([[jsonForMain objectForKey:@"Status"] isEqualToString:@"Auditing"]){
        [self.view makeToast:@"正在审核教师身份，请稍等......."];
    }else if ([[jsonForMain objectForKey:@"Status"] isEqualToString:@"Fail"]){
        [SVProgressHUD showErrorWithStatus:@"注册失败，请重新尝试....."];//需要将textfield置空
    }else
    {
        [self.view makeToast:@"未知名网络错误"];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"注册失败 %@",exception] duration:1000];
        NSLog(@"学生注册失败==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"注册");
    }

}

-(void)AddZhuanyeQcheck
{
    @try {
        for (int i=0; i<[ZhuanYeArr count]; i++) {
            QCheckBox *check = [[QCheckBox alloc] initWithDelegate:self];
            check.frame = CGRectMake(25, 20*i, 100, 20);
            check.tag=[[[[objectArr valueForKey:@"grade"] objectAtIndex:i] valueForKey:@"gradeId"] integerValue];
            [check setTitle:[ZhuanYeArr objectAtIndex:i] forState:UIControlStateNormal];
            [check setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [check setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
            [check setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
            [check.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
            [ZhuanYeScroll addSubview:check];
            [check setChecked:NO];
        }
        CGSize newSize = CGSizeMake(50, 20*[[objectArr valueForKey:@"grade"] count]);
        [ZhuanYeScroll setContentSize:newSize];
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        NSLog(@"添加数据");
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    QcheckArr=[[NSMutableArray alloc]init];
    [self UIAssume];
    addbtn.enabled=NO;
    ZhuanYeScroll.backgroundColor=[UIColor clearColor];
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
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{//点击return键盘隐藏
    if (theTextField==Name||theTextField==NickName || theTextField==Password||theTextField==ConfirmPassword||theTextField==IDNum) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)CancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backgrounTap:(id)sender {
    [Name resignFirstResponder];
    [NickName resignFirstResponder];
    [PhoneNum resignFirstResponder];
    [IDNum resignFirstResponder];
    [Password resignFirstResponder];
    [ConfirmPassword resignFirstResponder];

}

- (IBAction)RegisterBtn:(id)sender {
    //进行输入处理
    //[self getNetworkRequestMain];
    if ([Name.text isEqualToString:@""]||[NickName.text isEqualToString:@""]||[PhoneNum.text isEqualToString:@""]||[IDNum.text isEqualToString:@""]||[XueyuanTEXT.text isEqualToString:@""]||[Password.text isEqualToString:@""]||[ConfirmPassword.text isEqualToString:@""]) {
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
    }else if(![Password.text isEqualToString:ConfirmPassword.text])
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

        //发起网络请求
        [self getNetworkRequestMain];
    }
}

- (IBAction)AddBtn:(id)sender {
    @try {
        /**********************/
        //处理多次选择学院出现的视图重叠现象
        [ZhuanYeArr removeAllObjects];
        for (QCheckBox *sons in[ZhuanYeScroll subviews]) {
            [sons removeFromSuperview];
        }
        /***********************/
        NSArray *XUEYuanArr=[NSArray arrayWithArray:colleges];
        ChooseAlert=[[MLTableAlert alloc] initWithTitle:@"请您选择学院" cancelButtonTitle:@"取消" numberOfRows:^NSInteger (NSInteger section){
            return [XUEYuanArr count];
        }
                                               andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath){
                                                   static NSString *CellIdentifier = @"CellIdentifier";
                                                   UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
                                                   if (cell == nil)
                                                       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                                                   
                                                   cell.textLabel.text = [XUEYuanArr objectAtIndex:indexPath.row];
                                                   
                                                   
                                                   return cell;
                                               }];
        ChooseAlert.height=300.0;
        //点击事件
        [ChooseAlert configureSelectionBlock:^(NSIndexPath *selectedIndex){
            XueyuanTEXT.text=[XUEYuanArr objectAtIndex:selectedIndex.row];
            [self AddZhuanyeQcheck];
            if (XueyuanTEXT.text.length) {
                //进行第二次请求
                
                [self getNetworkRequestSecond];
            }
            NSLog(@"99999999%@",XueyuanTEXT.text);
            
        } andCompletionBlock:^{
            return;
        }];
        // show the alert
        [ChooseAlert show];

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
         NSLog(@"数据错误");
    }
    

}

#pragma mark - QCheckBoxDelegate

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {
    NSNumber *tag=[NSNumber numberWithInt:checkbox.tag];
    [QcheckArr addObject:tag];
    NSLog(@"selected====%@",tag);
   
}
@end
