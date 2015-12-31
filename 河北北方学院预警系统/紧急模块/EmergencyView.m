//
//  EmergencyView.m
//  EmergencyView
//
//  Created by kys-2 on 14-4-25.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "EmergencyView.h"
#import "FKRSearchBarTableViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "Toast+UIView.h"
#import "UITextField+Shake.h"
#import "SelectionCell.h"
#import "Defines.h"
#import "iToast.h"

//后续处理
#define Leader @"1"
#define HeaderTeacher @"2"
#define STUDENTS @"3"


@interface EmergencyView ()

@end

@implementation EmergencyView
@synthesize IDTable;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma --mark RequestDelegate For Leaders one
-(void)GetRequestForLeaderOne
{
    [SVProgressHUD showWithStatus:@"正在更新数据"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLLeader]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForLeaderOne:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForLeaderOne:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startAsynchronous];//开启同步请求
    self.view.userInteractionEnabled=NO;
}
- (void)ASIHttpRequestFailedForLeaderOne:(ASIHTTPRequest *)request
{
    self.view.userInteractionEnabled=YES;
    //[self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    [SVProgressHUD showErrorWithStatus:@"更新数据失败"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);

}
- (void)ASIHttpRequestSuceedForLeaderOne:(ASIHTTPRequest *)request
{
    self.view.userInteractionEnabled=YES;
    [SVProgressHUD showSuccessWithStatus:@"更新数据成功!"];
    leaderItems=[[NSMutableArray alloc]init];
    leaderContact=[[NSMutableArray alloc]init];
    
    NSData *responseData = [request responseData];
    jsonLeaderObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders 解析＝%@",jsonLeaderObjects);
    @try {
    if ([jsonLeaderObjects count])
    {
        [self.view makeToast:@"获取数据成功"];
    }
    for (int i=0; i<[jsonLeaderObjects count]; i++)
    {
        [leaderItems addObject:[[jsonLeaderObjects objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"leaderName"]];
        [leaderContact addObject:[[jsonLeaderObjects objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"phone"]];
    }
    //缓存一下领导的信息
    [[NSUserDefaults standardUserDefaults] setObject:leaderItems forKey:@"leaders"];
    [[NSUserDefaults standardUserDefaults]setObject:leaderContact forKey:@"leaderContact"];
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"领导信息");
    }
    
}
#pragma --mark RequestDelegate For Leaders two
-(void)GetRequestForCollegeByLeader
{
    [ActivityView startAnimating];//开始加载画面
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetCollegeByLeaders]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForLeaderTwo:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForLeaderTwo:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startAsynchronous];//开启同步请求

}
- (void)ASIHttpRequestFailedForLeaderTwo:(ASIHTTPRequest *)request
{
    [ActivityView stopAnimating];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForLeaderTwo:(ASIHTTPRequest *)request
{
    [ActivityView stopAnimating];
    NSData *responseData = [request responseData];
    JsonCollegeObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders Two 解析＝%@",JsonCollegeObjects);
    DataArray=[JsonCollegeObjects valueForKey:@"college"];
    [self popClickAction];

}
#pragma --mark RequestDelegate For Leaders three
-(void)GetRequestForHeadteachersFromOneCollege
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:collegeName, @"collegeName", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetHeaderTeachersBycollege]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForLeaderThree:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForLeaderThree:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求

}
- (void)ASIHttpRequestFailedForLeaderThree:(ASIHTTPRequest *)request
{
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);

}
- (void)ASIHttpRequestSuceedForLeaderThree:(ASIHTTPRequest *)request
{
    headersItems=[[NSMutableArray alloc]init];
    headerContact=[[NSMutableArray alloc]init];
    NSData *responseData = [request responseData];
    JsonHeadTeachersObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders Three 解析＝%@",JsonHeadTeachersObjects);
    @try {
    if (JsonHeadTeachersObjects.count) {
        [poplistview dismiss];//加载页面隐藏
        for (int i=0; i<[[JsonHeadTeachersObjects objectForKey:@"headTeacher"] count]; i++) {
            [headersItems addObject:[[[JsonHeadTeachersObjects objectForKey:@"headTeacher"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"headTeacherName"]];
            [headerContact addObject:[[[JsonHeadTeachersObjects objectForKey:@"headTeacher"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"phone"]];
        }
        //缓存一下辅导员的信息
        [[NSUserDefaults standardUserDefaults]setObject:headersItems forKey:@"headers"];
        [[NSUserDefaults standardUserDefaults]setObject:headerContact forKey:@"headerContact"];

        FKRSearchBarTableViewController *stud=[[FKRSearchBarTableViewController alloc]init];
        stud.identifer=@"header";
        stud.title=@"辅导员";
        stud.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:stud animated:YES];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"辅导员信息");
    }
    
}
#pragma --mark RequestDelegate For Leaders four
-(void)GetRequestForCollegeAndGradesFromClass
{//获得  学院  和  年级
    [ActivityView startAnimating];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetGradeOrCollegeInLeaders]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForCollegeAndGradeFour:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForCollegeAndGradeFour:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForCollegeAndGradeFour:(ASIHTTPRequest *)request
{
    [ActivityView stopAnimating];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForCollegeAndGradeFour:(ASIHTTPRequest *)request
{
    [ActivityView stopAnimating];
    NSData *responseData = [request responseData];
    JsonCollegeAndGrades=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders Three 解析＝%@",JsonCollegeAndGrades);
    @try {
    if ([JsonCollegeAndGrades count])
    {
    [self ChooseClass];//弹出选择班级的界面
     xueyuanBtn.enabled=YES;
     CollegesFromClass=[JsonCollegeAndGrades valueForKey:@"college"];
     GradesFromClass=[JsonCollegeAndGrades valueForKey:@"grade"];
    //创建下拉列表
    NSArray *textfields=[[NSArray alloc]initWithObjects:XUeyuanText,NianJiText, nil];
    NSArray *btns=[[NSArray alloc]initWithObjects:xueyuanBtn,nianjiBtn,nil];
    NSArray *tbs=[[NSArray alloc]initWithObjects:XueyuanTable,NianJiTable, nil];
    
    NSInteger counts=[CollegesFromClass count];
    NSInteger counts1=[GradesFromClass count];
    for (int i=0; i<2; i++) {
        [[tbs objectAtIndex:i]initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section)
        {
            if (i==0)
            {
                return counts;
            }else
            {
                return counts1;
            }
        }
         setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath)
        {
             
    SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
    if (!cell)
    {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
    [cell setSelectionStyle: UITableViewCellSelectionStyleGray];
        
    }
    cell.lb.font=[UIFont systemFontOfSize:16];
    if (i==0)
    {
    [cell.lb setText:[CollegesFromClass objectAtIndex:indexPath.row]];
        
    }
    else
    {
    [cell.lb setText:[GradesFromClass objectAtIndex:indexPath.row]];
        
    }
     return cell;
            
    }
    setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath)
        {
                                                
    SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
    [[textfields objectAtIndex:i]setText:cell.lb.text];
            
    [[btns objectAtIndex:i] sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
        
        if (i==0)
        {
            [XueyuanTable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [XueyuanTable.layer setBorderWidth:2];
        }
        else
        {
            [NianJiTable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [NianJiTable.layer setBorderWidth:2];
        }
        
    }

    }
    else
    {
        [self.view makeToast:@"获取数据为空"];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        
    }
    

}
#pragma --mark RequestDelegate For Leaders five
-(void)GetRequestForProfessions
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:XUeyuanText.text, @"collegeName",NianJiText.text,@"yearClass", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetProfessons]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForProfessionsFive:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForProfessionsFive:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForProfessionsFive:(ASIHTTPRequest *)request
{
    [professionsload stopAnimating];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForProfessionsFive:(ASIHTTPRequest *)request
{
    [professionsload stopAnimating];
    NSData *responseData = [request responseData];
    JsonProfessions=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",JsonProfessions);
    @try {
    if ([JsonProfessions count])
    {//得到专业信息的下拉列表
        zhuanyeBtn.enabled=YES;
        ProfessionsFromClass=[JsonProfessions objectForKey:@"profession"];
        NSInteger professioncount=ProfessionsFromClass.count;
        [ZhuanyeTable initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section)
        {
            return professioncount;
        }
         
        setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath)
        {
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell)
        {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
        [cell setSelectionStyle: UITableViewCellSelectionStyleGray];
            
        }
        cell.lb.font=[UIFont systemFontOfSize:16];
        [cell.lb setText:[ProfessionsFromClass objectAtIndex:indexPath.row]];
                           
        return cell;
            
        }
        setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath)
        {
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        [ZhuanYeText setText:cell.lb.text];
            
        [zhuanyeBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
            
        }];
        [ZhuanyeTable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [ZhuanyeTable.layer setBorderWidth:2];
        
    }
    else
    {
        [self.view makeToast:@"获取数据失败"];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"专业信息==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"专业信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"专业信息");
    }
}
#pragma --mark RequestDelegate For Leaders six
-(void)GetRequestForClasses
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:XUeyuanText.text, @"collegeName",NianJiText.text,@"yearClass",ZhuanYeText.text,@"profession", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetClasses]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForClassesSix:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForClassesSix:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForClassesSix:(ASIHTTPRequest *)request
{
    [Classesload stopAnimating];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
   }
- (void)ASIHttpRequestSuceedForClassesSix:(ASIHTTPRequest *)request
{
    [Classesload stopAnimating];
    NSData *responseData = [request responseData];
    JsonClasses=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",JsonClasses);
    @try {
    if ([JsonClasses count])
    {
        ClassFromLeader=[JsonClasses valueForKey:@"classID"];
        banjiBtn.enabled=YES;
        NSInteger ClassCount=ClassFromLeader.count;
        [BanJiTable initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section)
        {
            return ClassCount;
        }
         setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath)
        {
        SelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell)
        {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"SelectionCell" owner:self options:nil]objectAtIndex:0];
        [cell setSelectionStyle: UITableViewCellSelectionStyleGray];
            
        }
        cell.lb.font=[UIFont systemFontOfSize:16];
        [cell.lb setText:[ClassFromLeader objectAtIndex:indexPath.row]];
                           
        return cell;
        }
        setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath)
        {
        SelectionCell *cell=(SelectionCell*)[tableView cellForRowAtIndexPath:indexPath];
        [BanJiText setText:cell.lb.text];
        [banjiBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
            
        }];
        [BanJiTable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [BanJiTable.layer setBorderWidth:2];
        
    }
    else
    {
        [self.view makeToast:@"数据加载失败"];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"班级信息");
    }
}
#pragma --mark RequestDelegate For Leaders Seven
-(void)SubmitDataToServer
{//提交所选择的班级数据
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"gradeID",NianJiText.text,@"grade",ZhuanYeText.text,@"profession",BanJiText.text,@"classID", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetClassemates]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForClassmatesSeven:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForClassmatesSeven:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForClassmatesSeven:(ASIHTTPRequest *)request
{
    [[KGModal sharedInstance] hide];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForClassmatesSeven:(ASIHTTPRequest *)request
{
  // [spinner ]
    //[[KGModal sharedInstance] hide];
    studItems=[[NSMutableArray alloc]init];
    studContact=[[NSMutableArray alloc]init];
    studImages=[[NSMutableArray alloc]init];
    NSData *responseData = [request responseData];
    JsonClassmates=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",JsonClassmates);
    @try {
    if ([JsonClassmates count]) {
        [[KGModal sharedInstance] hide];
        
        for (int i=0; i<[[JsonClassmates objectForKey:@"student"] count]; i++)
        {/*change ios */ //需要添加头像
            [studItems addObject:[[[JsonClassmates objectForKey:@"student"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studentName"]];
            [studContact addObject:[[[JsonClassmates objectForKey:@"student"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"phone"]];
            //[studImages addObject:[[[JsonClassmates objectForKey:@"student"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"headSculpture"]];
        }
        //缓存一下学生的信息
        [[NSUserDefaults standardUserDefaults] setObject:studItems forKey:@"students"];
        [[NSUserDefaults standardUserDefaults]setObject:studContact forKey:@"studContact"];
        //[[NSUserDefaults standardUserDefaults]setObject:studImages forKey:@"studImages"];
        
        
        [UIView animateWithDuration:1.7 animations:^{
            FKRSearchBarTableViewController *stud=[[FKRSearchBarTableViewController alloc]init];
            stud.identifer=@"student";
            stud.title=@"同学";
            stud.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:stud animated:YES];

        }];
       
    }
    else
    {
        [self.view makeToast:@"获取数据失败"];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"学生信息");
    }
}
#pragma --mark RequestDelegate For HeaderTeacher
-(void)GetContactsForLeadersAndHeaderTeachers
{//辅导员身份登录
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserNickName"],@"headTeacherNickname", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetLeadersAndHeaders]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForHeadTeachers:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForHeadTeachers:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForHeadTeachers:(ASIHTTPRequest *)request
{
   
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForHeadTeachers:(ASIHTTPRequest *)request
{
    headersItems=[[NSMutableArray alloc]init];
    headerContact=[[NSMutableArray alloc]init];
    leaderItems=[[NSMutableArray alloc]init];
    leaderContact=[[NSMutableArray alloc]init];
    NSData *responseData = [request responseData];
    JsonHeadTeacherFirst=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor HeadTeachers 解析＝%@",JsonHeadTeacherFirst);
    @try {
    if ([JsonHeadTeacherFirst count]) {
        [self.view makeToast:@"更新数据成功!"];
        for (int i=0; i<[[JsonHeadTeacherFirst valueForKey:@"headTeacher"] count]; i++)
        {
            [headersItems addObject:[[[JsonHeadTeacherFirst valueForKey:@"headTeacher"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"headTeacherName"]];
            [headerContact addObject:[[[JsonHeadTeacherFirst valueForKey:@"headTeacher"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"phone"]];
        }
        for (int j=0; j<[[JsonHeadTeacherFirst valueForKey:@"leader"] count]; j++)
        {
            [leaderItems addObject:[[[JsonHeadTeacherFirst valueForKey:@"leader"] objectForKey:[NSString stringWithFormat:@"%d",j]] valueForKey:@"leaderName"]];
            [leaderContact addObject:[[[JsonHeadTeacherFirst valueForKey:@"leader"] objectForKey:[NSString stringWithFormat:@"%d",j]] valueForKey:@"phone"]];
        }
        //缓存一下领导的信息
        [[NSUserDefaults standardUserDefaults] setObject:leaderItems forKey:@"leaders"];
        [[NSUserDefaults standardUserDefaults]setObject:leaderContact forKey:@"leaderContact"];
        //缓存一下辅导员的信息
        [[NSUserDefaults standardUserDefaults]setObject:headersItems forKey:@"headers"];
        [[NSUserDefaults standardUserDefaults]setObject:headerContact forKey:@"headerContact"];

    }
    else
    {
        [self.view makeToast:@"更新数据失败😭!"];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"领导和辅导员数据错误 %@",exception] duration:1000];
        NSLog(@"领导和辅导员数据错误==Exception: %@", exception);

    }
    @finally {
        
        NSLog(@"领导和辅导员通讯录");
    }
}
#pragma --mark RequestDelegate For HeaderTeacher two
-(void)GetClassesManagedByHeaderteacher
{//获得辅导员管理的班级  年级 专业
    [ActivityView startAnimating];
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserNickName"],@"headTeacherNickname", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetClassesManagedByHeadteacher]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForHeadTeachersTwo:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForHeadTeachersTwo:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForHeadTeachersTwo:(ASIHTTPRequest *)request
{
    [ActivityView stopAnimating];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForHeadTeachersTwo:(ASIHTTPRequest *)request
{
   [ActivityView stopAnimating];
    NSData *responseData = [request responseData];
    JsonHeadTeacherTwo=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor HeadTeachers 解析＝%@",JsonHeadTeacherTwo);
    ZhongHeArr=[[NSMutableArray alloc]init];
    GradeIdArr=[[NSMutableArray alloc]init];
    @try {
    if ([JsonHeadTeacherTwo count]) {
        for (int i=0; i<[[JsonHeadTeacherTwo valueForKey:@"grade"] count]; i++) {
            NSDictionary *info=[[NSDictionary alloc]init];
            info=[[JsonHeadTeacherTwo valueForKey:@"grade"] objectForKey:[NSString stringWithFormat:@"%d",i]];
            NSString *grade=[info valueForKey:@"grade"];
            NSString *zhuanye=[info valueForKey:@"profession"];
            NSString *class=[info valueForKey:@"classID"];
            NSString * OneInfo=[NSString stringWithFormat:@"%@%@%@",grade,zhuanye,class];
            [GradeIdArr addObject:[info
                        valueForKey:@"gradeID"]];
            [ZhongHeArr addObject:OneInfo];
        }
        NSLog(@"1111=%@",ZhongHeArr);
        DataArray=[NSArray arrayWithArray:ZhongHeArr];
        [self popClickAction];
    }
    else
    {
        [self.view makeToast:@"加载数据失败😭"];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"学生通讯录");
    }
}
#pragma --mark RequestDelegate For HeaderTeacher three  //获得相应的班级
-(void)getTheOnlyClassByGradeid
{
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:GradeIdStr,@"gradeID", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetClassByGradeId]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForHeadTeachersThree:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForHeadTeachersThree:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForHeadTeachersThree:(ASIHTTPRequest *)request
{
    [poplistview dismiss];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForHeadTeachersThree:(ASIHTTPRequest *)request
{
    studItems=[[NSMutableArray alloc]init];
    studContact=[[NSMutableArray alloc]init];
    studImages=[[NSMutableArray alloc]init];
    NSData *responseData = [request responseData];
    JsonHeadTeacherThree=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor HeadTeachers 解析＝%@",JsonHeadTeacherThree);
    @try {
    if ([JsonHeadTeacherThree count]) {
        [poplistview dismiss];
        for (int i=0; i<[[JsonHeadTeacherThree valueForKey:@"student"] count]; i++) {
        /*change  ios */
            [studItems addObject:[[[JsonHeadTeacherThree valueForKey:@"student"]objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studentName"]];
            [studContact addObject:[[[JsonHeadTeacherThree valueForKey:@"student"]objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"phone"]];
            //[studImages addObject:[[[JsonClassmates objectForKey:@"student"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"headSculpture"]];
        }
        //缓存一下学生的信息
        [[NSUserDefaults standardUserDefaults] setObject:studItems forKey:@"students"];
        [[NSUserDefaults standardUserDefaults]setObject:studContact forKey:@"studContact"];
        //[[NSUserDefaults standardUserDefaults]setObject:studImages forKey:@"studImages"];
        [UIView animateWithDuration:1.7 animations:^{
            FKRSearchBarTableViewController *stud=[[FKRSearchBarTableViewController alloc]init];
            stud.identifer=@"student";
            stud.title=@"同学";
            stud.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:stud animated:YES];
            
        }];

    }
    else
    {
        [self.view makeToast:@"更新数据失败😭"];
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"学生信息");
    }

}
#pragma --mark RequestDelegate For Students
-(void)getContactsFromNetwork
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserNickName"], @"userNickname", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URL_Student]];
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
}
- (void)ASIHttpRequestFailed:(ASIHTTPRequest *)request{
    
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
//网络请求成功
- (void)ASIHttpRequestSuceed:(ASIHTTPRequest *)request{
    studItems=[[NSMutableArray alloc]init];
    studContact=[[NSMutableArray alloc]init];
    headersItems=[[NSMutableArray alloc]init];
    headerContact=[[NSMutableArray alloc]init];
    leaderItems=[[NSMutableArray alloc]init];
    leaderContact=[[NSMutableArray alloc]init];
    
    NSData *responseData = [request responseData];
    jsonObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",jsonObjects);
    
    //获取学生列表
    @try {
    for (int i=0; i<[[jsonObjects valueForKey:@"classmates"] count]; i++) {
        
        /*change ios */
        [studItems addObject:[[[jsonObjects valueForKey:@"classmates"]objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studentName"]];
        [studContact addObject:[[[jsonObjects valueForKey:@"classmates"]objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"phone"]];
    }
    //获取辅导员列表  需要判断  当前为学生
    for (int j=0; j<[[jsonObjects valueForKey:@"headTeacher"] count]; j++) {
        [headersItems addObject:[[jsonObjects valueForKey:@"headTeacher"] valueForKey:@"headTeacherName"]];
        [headerContact addObject:[[jsonObjects valueForKey:@"headTeacher"] valueForKey:@"phone"]];
    }
    //获取领导列表
    for (int k=0; k<[[jsonObjects valueForKey:@"leader"]count]; k++) {
        [leaderItems addObject:[[[jsonObjects valueForKey:@"leader"] objectForKey:[NSString stringWithFormat:@"%d",k]] valueForKey:@"leaderName"]];
        [leaderContact addObject:[[[jsonObjects valueForKey:@"leader"] objectForKey:[NSString stringWithFormat:@"%d",k]] valueForKey:@"phone"]];
    }
    
     //缓存一下学生的信息
    [[NSUserDefaults standardUserDefaults] setObject:studItems forKey:@"students"];
    [[NSUserDefaults standardUserDefaults]setObject:studContact forKey:@"studContact"];
    //缓存一下领导的信息
    [[NSUserDefaults standardUserDefaults] setObject:leaderItems forKey:@"leaders"];
    [[NSUserDefaults standardUserDefaults]setObject:leaderContact forKey:@"leaderContact"];
    //缓存一下辅导员的信息
    [[NSUserDefaults standardUserDefaults]setObject:headersItems forKey:@"headers"];
    [[NSUserDefaults standardUserDefaults]setObject:headerContact forKey:@"headerContact"];
    [self.view makeToast:@"数据更新成功!"];
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"学生信息");
    }

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IDTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    IDTable.backgroundColor=[UIColor clearColor];
    IDTable.backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"sos_backImage.png"]];
    IDTable.delegate=self;
    IDTable.dataSource=self;
    [self.view addSubview:IDTable];
    
    //根据登录者的身份进行不同的第一次请求
    user_ID=[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
    if ([user_ID isEqualToString:@"领导"]||[user_ID isEqualToString:@"普通教师"])
    {//领导身份登录
        NSLog(@"领导身份登录");
        [self GetRequestForLeaderOne];
        
    }
    else if ([user_ID isEqualToString:@"辅导员"])
    {//辅导员身份登录
        NSLog(@"辅导员身份登录");
    [self GetContactsForLeadersAndHeaderTeachers];
        
    }
    else if([user_ID isEqualToString:@"学生"])
    {//学生身份登录
        [self getContactsFromNetwork];
    }
    
   }
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (DEVICE_IS_IPHONE5) {
        return 100.0;
    }else
    {
        return 80.0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head;
    if (section==0) {
        head=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        for (int i=0; i<5; i++) {
            UIImageView *star=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_jinji.png"]];
            star.frame=CGRectMake(1+22*i, 5, 20, 20);
            [head addSubview:star];
        }

    }else  if(section==1)
    {
        head=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        for (int i=0; i<3; i++) {
            UIImageView *star=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_jinji.png"]];
            star.frame=CGRectMake(1+22*i, 5, 20, 20);
            [head addSubview:star];
        }

    }
    else
    {
        head=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        for (int i=0; i<1; i++) {
            UIImageView *star=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"star_jinji.png"]];
            star.frame=CGRectMake(1+22*i, 5, 20, 20);
            [head addSubview:star];
        }

    }
    return head;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    //cell.imageView.image=[UIImage imageNamed:@"contacts.png"];
    
    cell.textLabel.textColor=[UIColor colorWithRed:255 green:255 blue:00 alpha:1.0];
    cell.textLabel.font=[UIFont systemFontOfSize:20];
    cell.backgroundColor=[UIColor clearColor];
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    if (indexPath.section==0)
    {
        cell.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"enemy_leaderBtn.png"]];
        cell.tag=10+indexPath.row;
    }
    else if (indexPath.section==1)
    {
        ActivityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        ActivityView.frame=CGRectMake(0, 0, 50, 50);
        if ([user_ID isEqualToString:@"领导"]||[user_ID isEqualToString:@"普通教师"])
        {
        cell.accessoryView=ActivityView;
        }
          cell.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"enemy_teacherBtn.png"]];
    //cell.textLabel.text=@"辅导员通讯录";
    }
    else
    {
        if ([user_ID isEqualToString:@"领导"]||[user_ID isEqualToString:@"普通教师"])
        {
            cell.accessoryView=ActivityView;
        }
        else if ([user_ID isEqualToString:@"辅导员"])
        {
            cell.accessoryView=ActivityView;
        }
     cell.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"enemy_studentBtn.png"]];
        //cell.textLabel.text=@"学生通讯录";
    }
    
    return cell;
}
#pragma mark-TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        FKRSearchBarTableViewController *stud=[[FKRSearchBarTableViewController alloc]init];
        stud.identifer=@"leader";
        stud.title=@"领导";
        stud.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:stud animated:YES];
        
    }else if (indexPath.section==1)
    {
       if ([user_ID isEqualToString:@"领导"]||[user_ID isEqualToString:@"普通教师"])
       {//登录者为领导 请求学院 根据学院获得辅导员
        [self GetRequestForCollegeByLeader];
           //获取学院
           //[self popClickAction];
        }
        else
        {
        FKRSearchBarTableViewController *stud=[[FKRSearchBarTableViewController alloc]init];
        stud.identifer=@"header";
        stud.title=@"辅导员";
            stud.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:stud animated:YES];
        }
        
    }
    if (indexPath.section==2)
    {
        if ([user_ID isEqualToString:@"领导"]||[user_ID isEqualToString:@"普通教师"])
        {//  领导进入按层次选择班级
            isOpened=NO;
            [self GetRequestForCollegeAndGradesFromClass];
           // [self ChooseClass];
        }
        else if([user_ID isEqualToString:@"辅导员"])
        {//  辅导员选择自己管辖的班级
        [self GetClassesManagedByHeaderteacher];
        }
        else
        {
        FKRSearchBarTableViewController *stud=[[FKRSearchBarTableViewController alloc]init];
        stud.identifer=@"student";
        stud.title=@"同学";
            stud.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:stud animated:YES];
       }
    }
    NSLog(@"%d",indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)ChooseClass
{/*change ios */
    choiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 300)];
   choiceView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"popView_image.png"]];
    choiceView.layer.masksToBounds=YES;
    choiceView.layer.cornerRadius=5.0;
    
    //College
    UILabel *collegeLable=[[UILabel alloc]init];
    collegeLable.frame=CGRectMake(20, 50-5, 50, 30);
    collegeLable.textColor=[UIColor blackColor];
    collegeLable.font=[UIFont systemFontOfSize:14];
    collegeLable.text=@"学院:";
    [choiceView addSubview:collegeLable];
    
    XUeyuanText=[[JYTextField alloc]initWithFrame:CGRectMake(50+5, 50-5, 205, 30)
                                      cornerRadio:5
                                      borderColor:RGB(166, 166, 166)
                                      borderWidth:2
                                       lightColor:RGB(243, 168, 51)
                                        lightSize:8
                                 lightBorderColor:RGB(235, 235, 235)];
    XUeyuanText.font=[UIFont systemFontOfSize:15];
    XUeyuanText.tag=30;
    XUeyuanText.enabled=NO;
    XUeyuanText.borderStyle=UITextBorderStyleNone;
    XUeyuanText.placeholder=@"请选择学院";

    xueyuanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    // xueyuanBtn.frame=CGRectMake(220-30, 0, 30, 30);
    xueyuanBtn.frame=CGRectMake(250-30+10, 51-5, 30, 30);
    xueyuanBtn.backgroundColor=[UIColor clearColor];
    [xueyuanBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    xueyuanBtn.tag=10;
    xueyuanBtn.enabled=NO;
    [xueyuanBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:XUeyuanText];
    [choiceView insertSubview:xueyuanBtn aboveSubview:XUeyuanText];
    
    XueyuanTable=[[TableViewWithBlock alloc] init];
    XueyuanTable.frame=CGRectMake(55, 75, 205, 5);
    XueyuanTable.backgroundColor=[UIColor whiteColor];
    XueyuanTable.hidden=YES;
    [choiceView addSubview:XueyuanTable];
    
    //Grade
    UILabel *NianjiLable=[[UILabel alloc]initWithFrame:CGRectMake(20, 85+15, 50, 30)];
    NianjiLable.textColor=[UIColor blackColor];
    NianjiLable.font=[UIFont systemFontOfSize:14];
    NianjiLable.text=@"年级:";
    [choiceView addSubview:NianjiLable];
    
    NianJiText=[[JYTextField alloc]initWithFrame:CGRectMake(20, 115+15, 80, 30)
                                     cornerRadio:5
                                     borderColor:RGB(166, 166, 166)
                                     borderWidth:2
                                      lightColor:RGB(243, 168, 51)
                                       lightSize:8
                                lightBorderColor:RGB(235, 235, 235)];
    NianJiText.font=[UIFont systemFontOfSize:14];
    //NianJiText.enabled=YES;
    NianJiText.userInteractionEnabled=NO;
    NianJiText.tag=31;
    NianJiText.borderStyle=UITextBorderStyleNone;
    NianJiText.placeholder=@"年级";
    //
    nianjiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //nianjiBtn.frame=CGRectMake(70-30, 0, 30, 30);
    nianjiBtn.frame=CGRectMake(53+18, 116+15, 30, 30);
    nianjiBtn.backgroundColor=[UIColor clearColor];
    [nianjiBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    nianjiBtn.tag=11;
    nianjiBtn.enabled=NO;
    [nianjiBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:NianJiText];
    [choiceView insertSubview:nianjiBtn aboveSubview:NianJiText];
    
    NianJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(20, 160, 80, 8)];
    
    NianJiTable.backgroundColor=[UIColor whiteColor];
    NianJiTable.hidden=YES;
    [choiceView addSubview:NianJiTable];
    
    
    //Profession
    zhuanyeLable=[[UILabel alloc]initWithFrame:CGRectMake(120, 85+15, 50, 30)];
    zhuanyeLable.textColor=[UIColor blackColor];
    zhuanyeLable.font=[UIFont systemFontOfSize:14];
    zhuanyeLable.text=@"专业:";
    [choiceView addSubview:zhuanyeLable];
    
    ZhuanYeText=[[JYTextField alloc]initWithFrame:CGRectMake(120, 130, 150, 30)
                                      cornerRadio:5
                                      borderColor:RGB(166, 166, 166)
                                      borderWidth:2
                                       lightColor:RGB(243, 168, 51)
                                        lightSize:8
                                 lightBorderColor:RGB(235, 235, 235)];
    ZhuanYeText.font=[UIFont systemFontOfSize:14];
    ZhuanYeText.enabled=NO;
    ZhuanYeText.tag=32;
    ZhuanYeText.borderStyle=UITextBorderStyleNone;
    ZhuanYeText.placeholder=@"请选择专业";
    
    zhuanyeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    zhuanyeBtn.frame=CGRectMake(240, 131, 30, 30);
    zhuanyeBtn.backgroundColor=[UIColor clearColor];
    [zhuanyeBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    zhuanyeBtn.tag=12;
    zhuanyeBtn.enabled=NO;
    [zhuanyeBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:ZhuanYeText];
    [choiceView insertSubview:zhuanyeBtn aboveSubview:ZhuanYeText];
    ZhuanyeTable=[[TableViewWithBlock alloc]init];
    ZhuanyeTable.frame=CGRectMake(120,160, 150, 8);
    ZhuanyeTable.backgroundColor=[UIColor whiteColor];
    ZhuanyeTable.hidden=YES;
    [choiceView addSubview:ZhuanyeTable];
    
    //Class
    banjiLable=[[UILabel alloc]init];
    banjiLable.frame=CGRectMake(105, 200-30, 50, 30);
    banjiLable.textColor=[UIColor blackColor];
    banjiLable.font=[UIFont systemFontOfSize:14];
    banjiLable.text=@"班级:";
    [choiceView addSubview:banjiLable];
    
    BanJiText=[[JYTextField alloc]initWithFrame:CGRectMake(105, 200, 80, 30)
                                    cornerRadio:5
                                    borderColor:RGB(166, 166, 166)
                                    borderWidth:2
                                     lightColor:RGB(243, 168, 51)
                                      lightSize:8
                               lightBorderColor:RGB(235, 235, 235)];
    BanJiText.font=[UIFont systemFontOfSize:14];
    BanJiText.enabled=NO;
    BanJiText.tag=33;
    BanJiText.borderStyle=UITextBorderStyleNone;
    BanJiText.placeholder=@"班级";
    [choiceView addSubview:BanJiText];
    
    banjiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    banjiBtn.frame=CGRectMake(155, 200, 30, 30);
    banjiBtn.backgroundColor=[UIColor clearColor];
    [banjiBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    banjiBtn.tag=13;
    banjiBtn.enabled=NO;
    [banjiBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];

    
    BanJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(105,230, 80, 5)];
    BanJiTable.backgroundColor=[UIColor whiteColor];
    BanJiTable.hidden=YES;
    [choiceView addSubview:BanJiTable];
    [choiceView insertSubview:banjiBtn aboveSubview:BanJiText];
    
    UIButton *confirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame=CGRectMake(choiceView.frame.size.width-60, choiceView.frame.size.height-40, 50, 30);
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = 5.0;
    confirmBtn.backgroundColor=[UIColor clearColor];
    [confirmBtn setImage:[UIImage imageNamed:@"submit_btn.png"] forState:UIControlStateNormal];
    [choiceView addSubview:confirmBtn];
    confirmBtn.tag=14;
    [confirmBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[KGModal sharedInstance] showWithContentView:choiceView andAnimated:YES];

}

#pragma mark--clickDelegate
-(void)BtnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 10:
        {//学院
            XueyuanTable.hidden=NO;
            if (isOpened)
            {//添加个动画会更好
                NianJiText.transform = CGAffineTransformMakeScale(0.3, 0.3);
                nianjiBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                zhuanyeBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                ZhuanYeText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                zhuanyeLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                banjiLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                
                [UIView animateWithDuration:0.3 animations:^{
                    NianJiText.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    NianJiText.alpha=1.0;
                    nianjiBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    nianjiBtn.alpha=1.0;
                    zhuanyeBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    zhuanyeBtn.alpha=1.0;
                    ZhuanYeText.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    ZhuanYeText.alpha=1.0;
                    zhuanyeLable.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    zhuanyeLable.alpha=1.0;
                    banjiLable.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    banjiLable.alpha=1.0;

                }];
                
               
                [UIView animateWithDuration:0.3 animations:^{
                    UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
                    [xueyuanBtn setImage:closeImage forState:UIControlStateNormal];
                    
                    CGRect frame=XueyuanTable.frame;
                    
                    frame.size.height=0.01;
                    [XueyuanTable setFrame:frame];
                    
                } completion:^(BOOL finished){
                    
                    isOpened=NO;
                }];
            }else{
                
                [UIView animateWithDuration:0.3 animations:^{
                    NianJiText.transform = CGAffineTransformMakeScale(0.3, 0.3);
                    NianJiText.alpha=0.0;
                    nianjiBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    nianjiBtn.alpha=0.0;
                    zhuanyeBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    zhuanyeBtn.alpha=0.0;
                    ZhuanYeText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    ZhuanYeText.alpha=0.0;
                    zhuanyeLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    zhuanyeLable.alpha=0.0;
                    banjiLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    banjiLable.alpha=0.0;
                }];
                

                [UIView animateWithDuration:0.3 animations:^{
                    UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
                    [xueyuanBtn setImage:openImage forState:UIControlStateNormal];
                    
                    CGRect frame=XueyuanTable.frame;
                    
                    frame.size.height=120;
                    [XueyuanTable setFrame:frame];
                } completion:^(BOOL finished){
                    
                    isOpened=YES;
                }];
                
                
            }
            if (XUeyuanText.text.length) {
                nianjiBtn.enabled=YES;
            }

        }
            break;
        case 11:
        {//年级
            NianJiTable.hidden=NO;
             if (isOpened) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
                    [nianjiBtn setImage:closeImage forState:UIControlStateNormal];
                    
                    CGRect frame=NianJiTable.frame;
                    
                    frame.size.height=0.01;
                    [NianJiTable setFrame:frame];
                    
                } completion:^(BOOL finished){
                    
                    isOpened=NO;
                }];
            }else{
                
                [UIView animateWithDuration:0.3 animations:^{
                    UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
                    [nianjiBtn setImage:openImage forState:UIControlStateNormal];
                    
                    CGRect frame=NianJiTable.frame;
                    
                    frame.size.height=100;
                    [NianJiTable setFrame:frame];
                } completion:^(BOOL finished){
                    
                    isOpened=YES;
                }];
                
            }
            if (NianJiText.text.length)
            {//进行获取专业的请求
            professionsload=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                professionsload.frame=CGRectMake(0, 0, 30, 30);
                [zhuanyeBtn addSubview:professionsload];
                [professionsload startAnimating];
                [self GetRequestForProfessions];
            }

            
        }
            break;
        case 12:
        {//专业
            ZhuanyeTable.hidden=NO;
            
              if (isOpened)
              {
                  banjiLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                  BanJiText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                  banjiBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                  
                  [UIView animateWithDuration:0.3 animations:^{
                      banjiLable.transform = CGAffineTransformMakeScale(1.0, 1.0);
                      banjiLable.alpha=1.0;
                      BanJiText.transform=CGAffineTransformMakeScale(1.0, 1.0);
                      BanJiText.alpha=1.0;
                      banjiBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                      banjiBtn.alpha=1.0;
                      
                  }];

                 [UIView animateWithDuration:0.3 animations:^{
                    UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
                    [zhuanyeBtn setImage:closeImage forState:UIControlStateNormal];
                    
                    CGRect frame=ZhuanyeTable.frame;
                    
                    frame.size.height=0.01;
                    [ZhuanyeTable setFrame:frame];
                    
                } completion:^(BOOL finished){
                    
                    isOpened=NO;
                }];
            }
              else
              {
                  [UIView animateWithDuration:0.3 animations:^{
                      banjiLable.transform = CGAffineTransformMakeScale(0.3, 0.3);
                      banjiLable.alpha=0.0;
                      BanJiText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                      BanJiText.alpha=0.0;
                      banjiBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                      banjiBtn.alpha=0.0;
                    
                  }];

                 [UIView animateWithDuration:0.3 animations:^{
                    UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
                    [zhuanyeBtn setImage:openImage forState:UIControlStateNormal];
                    
                    CGRect frame=ZhuanyeTable.frame;
                    
                    frame.size.height=95;
                    [ZhuanyeTable setFrame:frame];
                } completion:^(BOOL finished){
                    
                    isOpened=YES;
                }];
                
            }
            if (ZhuanYeText.text.length)
            {//发送第三次请求  获取对应的班级
                Classesload=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                Classesload.frame=CGRectMake(0, 0, 30, 30);
                [banjiBtn addSubview:Classesload];
                [Classesload startAnimating];
                [self GetRequestForClasses];

            }
        }
            break;
        case 13:
        {//班级
            BanJiTable.hidden=NO;
             if (isOpened)
             {
                 
                  [UIView animateWithDuration:0.3 animations:^{
                    UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
                    [banjiBtn setImage:closeImage forState:UIControlStateNormal];
                    
                    CGRect frame=BanJiTable.frame;
                    
                    frame.size.height=0.01;
                    [BanJiTable setFrame:frame];
                    
                } completion:^(BOOL finished){
                    
                    isOpened=NO;
                }];
            }else{
                
                [UIView animateWithDuration:0.3 animations:^{
                    UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
                    [banjiBtn setImage:openImage forState:UIControlStateNormal];
                    
                    CGRect frame=BanJiTable.frame;
                    
                    frame.size.height=65;
                    [BanJiTable setFrame:frame];
                } completion:^(BOOL finished){
                    
                    isOpened=YES;
                }];
                
                
            }

            
        }
            break;
        case 14:
        {//确认
            //判断的输入是否都不为空
            if ([XUeyuanText.text isEqualToString:@""]||[NianJiText.text isEqualToString:@""]||[ZhuanYeText.text isEqualToString:@""]||[BanJiText.text isEqualToString:@""]) {
                NSMutableArray *countArr=[[NSMutableArray alloc]init];
                for (int i=30; i<34; i++)
                {//解决输入的信息不能为空
                    JYTextField *jy=(JYTextField *)[choiceView viewWithTag:i];
                    if ([jy.text isEqualToString:@""])
                    {
                        [countArr addObject:[NSString stringWithFormat:@"%d",jy.tag]];
                    }
                }
                
                for (int k=0; k<[countArr count]; k++) {
                    JYTextField *test=(JYTextField*)[choiceView viewWithTag:[[countArr objectAtIndex:k] integerValue]];
                    [test shake:20 withDelta:5
                       andSpeed:0.03
                 shakeDirection:ShakeDirectionHorizontal];

                }
                
            }
            else
            {//开始进行请求
            [self PopLoadViewAfterConfirmBtnClicked];
            [self SubmitDataToServer];

            }
        }
        default:
            break;
    }
}
#pragma mark PopLoadViewAfterConfirmBtnClicked
-(void)PopLoadViewAfterConfirmBtnClicked
{
    for(UIView *view in [choiceView subviews])
    {
        
        [UIView animateWithDuration:.35 animations:^{
            view.transform = CGAffineTransformMakeScale(1.5, 1.5);
            view.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [view removeFromSuperview];
            }
        }];
        
    };
    spinner=[[MDFlickrActivityIndicatorView alloc]initWithFrame:CGRectMake(50, 76, 200, 120)];
    spinner.alpha=0.0;
    spinner.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [choiceView addSubview:spinner];
    
    UILabel *load=[[UILabel alloc]initWithFrame:CGRectMake(75+20, 200-10, 100, 40)];
    load.alpha=0.0;
    load.transform = CGAffineTransformMakeScale(0.3, 0.3);
    
    load.backgroundColor=[UIColor clearColor];
    load.font=[UIFont systemFontOfSize:20];
    load.textColor=[UIColor blackColor];
    load.text=@"正在加载...";
    [choiceView addSubview:load];
    
    [UIView animateWithDuration:.35 animations:^{
        spinner.transform = CGAffineTransformMakeScale(1, 1);
        spinner.alpha = 1.0;
        load.transform = CGAffineTransformMakeScale(1, 1);
        load.alpha=1.0;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [spinner startAnimating];
            
        }
    }];
    
}
#pragma mark  method choiceView  For leader see headerteachers
- (void)popClickAction
{//弹出的列表  用于领导进入根据学院查询辅导员／用于辅导员进入选择管辖的班级
    
    CGFloat xWidth = self.view.bounds.size.width - 20.0f;
    CGFloat yHeight = 272.0f;
    CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
    NSLog(@"ddddd=%f",yOffset);
    poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = YES;
    if ([user_ID isEqualToString:@"领导"]||[user_ID isEqualToString:@"普通教师"])
    {
    [poplistview setTitle:@"选择学院"];
    }
    else
    {
        [poplistview setTitle:@"选择管辖班级"];
    }
    [poplistview show];
   // DataArray=[[NSArray alloc]initWithObjects:@"基础医学院",@"法政学院",@"医学检验学院",@"药学院",@"文学院",@"中医学院",@"理学院",@"信息科学与工程学院",@"艺术学院",@"外国语学院",@"农林科技学院",@"动物科技学院",@"经济管理学院", nil];

}


#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:identifier] ;
        cell.textLabel.text=[DataArray objectAtIndex:indexPath.row];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row%2)
        {
            cell.imageView.image = [UIImage imageNamed:@"ic_facebook.png"];
        }else
        {
            cell.imageView.image = [UIImage imageNamed:@"ic_twitter.png"];
        }
        
        
        return cell;

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);
    }
    @finally {
    }
    
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return [DataArray count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
        [UIView animateWithDuration:.35 animations:^{
            popoverListView.listView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            popoverListView.listView.alpha = 0.0;
            popoverListView.backgroundColor=[UIColor whiteColor];
            popoverListView.alpha=0.86;
            spinner=[[MDFlickrActivityIndicatorView alloc]initWithFrame:CGRectMake(50, 76, 200, 120)];
            //spinner.center=popoverListView.center;
            [spinner startAnimating];
            UILabel *load=[[UILabel alloc]initWithFrame:CGRectMake(75+20, 200-10, 100, 40)];
            load.backgroundColor=[UIColor clearColor];
            load.font=[UIFont systemFontOfSize:20];
            load.textColor=[UIColor cyanColor];
            load.text=@"正在加载...";
            [popoverListView addSubview:load];
            [popoverListView addSubview:spinner];

        } completion:^(BOOL finished)
         {
            if (finished)
            {
                [popoverListView.listView setHidden:YES ];
            }
        }];
        
        //popoverListView.listView.hidden=YES;
    NSString *collegeStr=[NSString stringWithFormat:@"   您选择了\n%@",[DataArray objectAtIndex:indexPath.row]];
    [self.view makeToast:collegeStr];
    //根据登录者身份进行判断
    if ([user_ID isEqualToString:@"领导"]||[user_ID isEqualToString:@"普通教师"])
    {
    collegeName=[NSString stringWithFormat:@"%@",[DataArray objectAtIndex:indexPath.row]];
    [self GetRequestForHeadteachersFromOneCollege];//获得各个学院的辅导员
    }
    else if([user_ID isEqualToString:@"辅导员"])
    {
        GradeIdStr=[NSString stringWithFormat:@"%@",[GradeIdArr objectAtIndex:indexPath.row]];
        [self getTheOnlyClassByGradeid];
        NSLog(@"9999=%@",[GradeIdArr objectAtIndex:indexPath.row]);
    }
    NSLog(@"%s : %d", __func__, indexPath.row);
    // your code here
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)tabImageName
{
	return @"1.png";
}

- (NSString *)tabTitle
{
	return self.title=@"SOS";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
