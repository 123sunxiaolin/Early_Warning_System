//
//  NamesList.m
//  Attendance
//
//  Created by kys-2 on 14-4-20.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "NamesList.h"
#import "Toast+UIView.h"
#import "HasSignedStudents.h"
#import "UITextField+Shake.h"
#import "SelectionCell.h"
#import "UIViewController+KNSemiModal.h"
#import "PMCalendar.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "CheckStudentsTable.h"
#import "Defines.h"
#import "KxMenu.h"

#import "PAImageView.h"
#import "TSPopoverController.h"
#import "TSActionSheet.h"
#import "FastCheck_ViewController.h"

#import "DLAVAlertView.h"
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertViewTextFieldTheme.h"
#import "DLAVAlertViewButtonTheme.h"
#import "iToast.h"
/*存在bug：点击查看考勤返回时，tableview的frame不对*/


@interface NamesList ()
@property (nonatomic, strong) PMCalendarController *pmCC;
@end

@implementation NamesList{
    StudCell *studentcell;
    NSString *zhuangtai;
    NSMutableDictionary *allStudent ;
    NSArray *allNumb;
    NSArray *allold;
    UIView *gengxinView;
    int row;
}
@synthesize StudTable;
@synthesize tool;
@synthesize leftMarquee,rightMarquee,topMarquee,bottomMarquee;
@synthesize pmCC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma --mark RequestDelegate For CollegesAndGrades
-(void)GetRequestForCollegeAndGrades
{//获得  学院  和  年级
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetGradeAndColleges_CAO]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForCollegeAndGrade:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForCollegeAndGrade:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForCollegeAndGrade:(ASIHTTPRequest *)request
{
    [CollegeLoad stopAnimating];
    /*xueyuanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [xueyuanBtn setImage:[UIImage imageNamed:@"Fresh.png"] forState:UIControlStateNormal];
    xueyuanBtn.tag=35;
    [xueyuanBtn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView insertSubview:xueyuanBtn aboveSubview:XUeyuanText];*/
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForCollegeAndGrade:(ASIHTTPRequest *)request
{
    [CollegeLoad stopAnimating];
    //[xueyuanBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    NSData *responseData = [request responseData];
    JsonCollegeAndGrades=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders Three 解析＝%@",JsonCollegeAndGrades);
    @try {
    if ([JsonCollegeAndGrades count])
    {
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
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"学院信息==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"学院信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"学院信息");
    }
    
}
#pragma --mark RequestDelegate For professions
-(void)GetRequestForProfessions
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:XUeyuanText.text, @"collegeName",NianJiText.text,@"yearClass", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetProfessons_CAO]];
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
#pragma --mark RequestDelegate For Classes
-(void)GetRequestForClasses
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:XUeyuanText.text, @"collegeName",NianJiText.text,@"yearClass",ZhuanYeText.text,@"profession", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetClasses_CAO]];
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
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"学生信息==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"学生信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"学生信息");
    }
}
#pragma --mark RequestDelegate For Lessons
-(void)GetRequestForLessons
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:NianJiText.text,@"grade",ZhuanYeText.text,@"profession",BanJiText.text,@"classID", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetLessons_CAO]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForLessons:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForLessons:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForLessons:(ASIHTTPRequest *)request
{
    [Lessonsload stopAnimating];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForLessons:(ASIHTTPRequest *)request
{
    [Lessonsload stopAnimating];
    NSData *responseData = [request responseData];
    JsonLessons=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",JsonLessons);
    @try {
    if ([JsonLessons valueForKey:@"className"] )
    {
        kechengBtn.enabled=YES;
        LessonArr=[JsonLessons valueForKey:@"className"];
        
    }
    else
    {
        ClassInput.placeholder=@"请手动输入课程名称...";
        ClassInput.font=[UIFont systemFontOfSize:12];
        ClassInput.textColor=[UIColor darkGrayColor];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"学生信息==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"学生信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"学生信息");
    }
    
}
#pragma --mark RequestDelegate SubmitData//点名
-(void)SubmitAllDataForDianMing
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:NianJiText.text,@"grade",ZhuanYeText.text,@"profession",BanJiText.text,@"classID", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLSubmitData_CAO]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForSubmitData:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForSubmitData:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForSubmitData:(ASIHTTPRequest *)request
{
    
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForSubmitData:(ASIHTTPRequest *)request
{
    
    //[Lessonsload stopAnimating];
    CAll_StuName=[[NSMutableArray alloc]init];
    CAll_StuNumber=[[NSMutableArray alloc]init];
    CAll_headSculpture=[[NSMutableArray alloc]init];
    NSData *responseData = [request responseData];
    JsonClassmates=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students555解析＝%@",JsonClassmates);
    @try {
    if ([JsonClassmates count])
    {
        if ([[JsonClassmates objectForKey:@"Status"] isEqualToString:@"Fail"])
        {
            [self.view makeToast:@"获取数据失败"];
        }else
        {
        for (int i=0; i<[JsonClassmates count]; i++)
        {
            [CAll_StuName addObject:[[JsonClassmates objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studentName"]];
            [CAll_StuNumber addObject:[[JsonClassmates objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studentID"]];
            [CAll_headSculpture addObject:[[JsonClassmates objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"headSculpture"]];
            
        }
            
            
        name.text=ClassInput.text;
            
        [StudTable reloadData];//刷新列表
            
            
        [UIView animateWithDuration:0.5 animations:^{
            choiceView.transform = CGAffineTransformMakeScale(0.2, 0.2);
            choiceView.alpha = 0.0;
            grayView.transform=CGAffineTransformMakeScale(0.2, 0.2);
            grayView.alpha=0.0;
        } completion:^(BOOL finished) {
            //添加新的动画  实现tableview动画显示
            [UIView animateWithDuration:0.5 animations:^{
                [grayView removeFromSuperview];
                [choiceView removeFromSuperview];
                /*change*/
                [self MethodForHeadView];
                
                [self MethodForToolBar];
                
                [self MethodForNavigationBar];
                
            } completion:^(BOOL finished) {
                if (finished) {
                    return ;
                    
                }
            }];
          
            
        }];
        
        /*change*/
        tool.hidden=NO;
        }

    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"修改信息==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"修改信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"修改信息");
    }

}
#pragma --mark RequestDelegate checkout//查询
-(void)GetRequestClassmatsCheckedByLeaders
{
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:dateInput.text,@"date",ClassInput.text,@"course",SectionText.text,@"classTime",NianJiText.text,@"grade",ZhuanYeText.text,@"profession",BanJiText.text,@"classID", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLForCheck_CAO]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForCheck:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForCheck:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForCheck:(ASIHTTPRequest *)request
{
    [SubmitDataLoad stopAnimating];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForCheck:(ASIHTTPRequest *)request
{
   [SubmitDataLoad stopAnimating];
    Check_StuName=[[NSMutableArray alloc] init];
    Check_StuNumber=[[NSMutableArray alloc] init];
    Check_StuStatus=[[NSMutableArray alloc] init];
    Check_StuTouxiao=[[NSMutableArray alloc] init];
    NSData *responseData = [request responseData];
    JsonChecked=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",JsonChecked);
    @try {
    if ([JsonChecked count])
    {
        if ([[JsonChecked valueForKey:@"Status"] isEqualToString:@"CannotAnalyzeData"])
        {
            [self.view makeToast:@"解析数据失败"];
        }
        else if([[JsonChecked valueForKey:@"Status"] isEqualToString:@"Fail"])
        {
            [self.view makeToast:@"解析数据失败"];
        }
        else
        {

        for (int i=0; i<[JsonChecked count]; i++)
        {
            [Check_StuTouxiao addObject:[[JsonChecked valueForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"headSculpture"]];
            [Check_StuName addObject:[[JsonChecked valueForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studentName"]];
            [Check_StuNumber addObject:[[JsonChecked valueForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studentNumber"]];
            [Check_StuStatus addObject:[[JsonChecked valueForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studyStatus"]];

            
        }
            CheckStudentsTable *checklist=[[CheckStudentsTable alloc]init];
            checklist.title=@"查询列表";
            checklist.StudentTouxiangArr=[NSArray arrayWithArray:Check_StuTouxiao];
            checklist.StudentNameArr=[NSArray arrayWithArray:Check_StuName];
            checklist.StudentNumber=[NSArray arrayWithArray:Check_StuNumber];
            checklist.StudentStatus=[NSArray arrayWithArray:Check_StuStatus];
            checklist.S_class=[NSString stringWithFormat:@"%@%@%@",NianJiText.text,ZhuanYeText.text,BanJiText.text];
            checklist.S_lesson=[NSString stringWithFormat:@"%@",ClassInput.text];
            checklist.S_date=[NSString stringWithFormat:@"%@",dateInput.text];
            //[self.navigationController pushViewController:checklist animated:YES];
            [self presentViewController:checklist animated:YES completion:nil];
            
            [UIView animateWithDuration:0.3 animations:^{
                choiceView.transform=CGAffineTransformMakeScale(0.3, 0.3);
                choiceView.alpha=0.2;
                
                
            } completion:^(BOOL finished)
             {
                 [choiceView removeFromSuperview];
                 [self PoptheViewAllOverScreen];
             }];
            
        }
    }
    else
    {
        [self.view makeToast:@"返回数据为空!"];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"查询列表==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"查询列表==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"查询列表");
    }
}
/*-(void)loadView
{
    
}*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self PoptheViewAllOverScreen];
    [FastCheckBtn removeFromSuperview];
    [CallBtn removeFromSuperview];
    [rightMarquee removeFromSuperview];
    [leftMarquee removeFromSuperview];
    [topMarquee removeFromSuperview];
    [bottomMarquee removeFromSuperview];
    
    allStudent=[[NSMutableDictionary alloc] init];
    zhuangtai=[[NSString alloc] init];
   
    /*change*/
    //self.navigationController.navigationBarHidden=NO
    ;
    //身份
    ID_User=[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"];
    isCheck=NO;
    [self PoptheViewAllOverScreen];
     count=0;
    //[self MethodForHeadView];
    //
    //[self MethodForToolBar];
    //
   // [self MethodForNavigationBar];
    data=[[NSMutableArray alloc] init];
    for (int i=0; i<30; i++) {
        [data addObject:[NSString stringWithFormat:@"黄晓明＋%d",i]];
    }
    StudArray=[[NSMutableArray alloc]init];
    StudStatus=[[NSMutableArray alloc]init];
    
    
    
    //
    if([ID_User isEqualToString:@"领导"]||[ID_User isEqualToString:@"辅导员"])
    {
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(0, 0, 32, 32);
    [back setImage:[UIImage imageNamed:@"map_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(BackToFrontViewCaoQin) forControlEvents:UIControlEventTouchUpInside];
        
    //UIBarButtonItem *left_btn=[[UIBarButtonItem alloc]initWithCustomView:back];
    //self.navigationItem.leftBarButtonItem=left_btn;
        
     
    }

}
-(void)BackToFrontViewCaoQin
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- UI Design
-(void)MethodForHeadView
{
    StudTable=[[UITableView alloc]init];
    StudTable.frame=CGRectMake(0, 64, 320, self.view.frame.size.height-88);
    StudTable.dataSource=self;
    StudTable.delegate=self;
    [self.view addSubview:StudTable];
    
    
    //添加headView
    UIView *head=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    UILabel *Classname=[[UILabel alloc]init];
    Classname.frame=CGRectMake(30, 10, 70, 30);
    Classname.backgroundColor=[UIColor clearColor];
    Classname.font=[UIFont systemFontOfSize:12];
    Classname.textColor=[UIColor blackColor];
    Classname.text=@"当前课程:";
    name=[[UILabel alloc]init];
    name.frame=CGRectMake(100, 10, 150, 30);
    name.textColor=[UIColor blueColor];
    name.backgroundColor=[UIColor clearColor];
    [name.layer setBorderColor:[UIColor grayColor].CGColor];
    [name.layer setBorderWidth:2.0];
    [name.layer setCornerRadius:5.0];
    name.font=[UIFont systemFontOfSize:15];
    name.textAlignment=NSTextAlignmentCenter;
    name.text=ClassInput.text;
    //
    UILabel *time=[[UILabel alloc]init];
    time.frame=CGRectMake(120, 40, 100, 30);
    time.backgroundColor=[UIColor clearColor];
    time.font=[UIFont systemFontOfSize:11];
    //获得系统日期
    NSDate * senddate=[NSDate date];
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    
    time.text=[NSString stringWithFormat:@"%d年-%d月-%d日",year,month,day];
    //add background
    UIImageView *headBack=[[UIImageView alloc]initWithFrame:CGRectMake(0,0, 320, 70)];
    headBack.image=[UIImage imageNamed:@"back.png"];
    
    [headBack addSubview:time];
    [headBack addSubview:Classname];
    [headBack addSubview:name];
    [head addSubview:headBack];
    StudTable.tableHeaderView=head;
}
-(void)MethodForNavigationBar
{
    /*change*/
    /*HTPressableButton *lookBtn=[HTPressableButton buttonWithType:UIButtonTypeCustom];
    lookBtn.style=HTPressableButtonStyleRounded;
    lookBtn.frame=CGRectMake(0, 0, 50, 30);
    [lookBtn.layer setCornerRadius:5.0];
    //lookBtn.backgroundColor=[UIColor grayColor];
    lookBtn.buttonColor = [UIColor blueJeansColor];
    lookBtn.shadowColor = [UIColor blueJeansDarkColor];
   lookBtn.titleLabel.textColor=[UIColor blackColor];
    [lookBtn setTitle:@"查看" forState:UIControlStateNormal];
      lookBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    lookBtn.tag=10;
    right=[[UIBarButtonItem alloc] initWithCustomView:lookBtn];
    right.enabled=NO;//点名提交成功后才能查看
    self.navigationItem.rightBarButtonItem=right;
    [lookBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    //
    HTPressableButton *GoOnBtn=[HTPressableButton buttonWithType:UIButtonTypeCustom];
    GoOnBtn.style=HTPressableButtonStyleRounded;
    GoOnBtn.frame=CGRectMake(0, 0, 60, 30);
    GoOnBtn.buttonColor = [UIColor lemonColor];
    GoOnBtn.shadowColor = [UIColor lemonDarkColor];

    [GoOnBtn.layer setCornerRadius:5.0];
    //GoOnBtn.backgroundColor=[UIColor grayColor];
    GoOnBtn.titleLabel.textColor=[UIColor redColor];
    [GoOnBtn setTitle:@"继续点名" forState:UIControlStateNormal];
    GoOnBtn.titleLabel.font=[UIFont systemFontOfSize:13];
    GoOnBtn.tag=12;
    left=[[UIBarButtonItem alloc] initWithCustomView:GoOnBtn];
    self.navigationItem.leftBarButtonItem=left;
    [GoOnBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];*/
    self.navigationItem.leftBarButtonItem=nil;
    UIButton *MoreBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    MoreBtn.frame=CGRectMake(0, 64, 40, 25);
    MoreBtn.backgroundColor=[UIColor clearColor];
    MoreBtn.alpha=0.75;
    [MoreBtn setImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
   // MoreBtn.tag=9;
    [MoreBtn addTarget:self action:@selector(showActionSheet:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    right=[[UIBarButtonItem alloc] initWithCustomView:MoreBtn];
    self.navigationItem.rightBarButtonItem=right;

}
#pragma mark-----更多选项按钮 __考勤
-(void) showActionSheet:(id)sender forEvent:(UIEvent*)event
{
    //[self  MethodForHeadView];
    TSActionSheet *actionSheet = [[TSActionSheet alloc] initWithTitle:nil];
    actionSheet.frame=CGRectMake(0, 0, 80, 200);
    actionSheet.backgroundColor=[UIColor blackColor];
    [actionSheet addButtonWithTitle:@"查看考勤" color:[UIColor clearColor] titleColor:[UIColor whiteColor] borderWidth:1.0 borderColor:[UIColor clearColor] block:^{
        NSLog(@"123");
        StudTable.userInteractionEnabled=YES;

        [UIView animateWithDuration:0.3 animations:^{
            gengxinView.transform=CGAffineTransformMakeScale(0.3, 0.3);
            gengxinView.alpha=0.2;
            
            
        } completion:^(BOOL finished)
         {
             [gengxinView removeFromSuperview];
         }];

        HasSignedStudents *test=[[HasSignedStudents alloc]init];
        test.title=@"点名详情";
        test.studArr=StudArray;
        test.statusArray=StudStatus;
        test.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:test animated:YES];

    }];
    
    [actionSheet addButtonWithTitle:@"继续点名" color:[UIColor clearColor] titleColor:[UIColor whiteColor] borderWidth:1.0 borderColor:[UIColor clearColor] block:^{
        NSLog(@"123");
        [UIView animateWithDuration:0.3 animations:^{
            gengxinView.transform=CGAffineTransformMakeScale(0.3, 0.3);
            gengxinView.alpha=0.2;
            
            
        } completion:^(BOOL finished)
         {
             [gengxinView removeFromSuperview];
         }];
        StudTable.userInteractionEnabled=YES;

        [UIView animateWithDuration:0.3 animations:^{
            StudTable.transform = CGAffineTransformMakeScale(0.2, 0.2);
            StudTable.alpha = 0.0;
            tool.transform=CGAffineTransformMakeScale(0.2, 0.2);
            tool.alpha=0.0;
        } completion:^(BOOL finished) {
            //添加新的动画  实现tableview动画显示
            [StudTable removeFromSuperview];
            [tool removeFromSuperview];
            /*change*/
            self.navigationItem.rightBarButtonItem=nil;
            self.navigationItem.leftBarButtonItem=nil;
            [self PoptheViewAllOverScreen];
            
        }];

    }];
#pragma mark 更新点名
    [actionSheet addButtonWithTitle:@"更新点名" color:[UIColor clearColor] titleColor:[UIColor whiteColor] borderWidth:1.0 borderColor:[UIColor clearColor] block:^
    {//更新点名
        NSLog(@"123");
        gengxinView=[[UIView alloc] init];
        gengxinView.frame=CGRectMake(self.view.frame.size.width/2-110, self.view.frame.size.height/2-100, 215, 220);
        gengxinView.layer.masksToBounds=YES;
        gengxinView.layer.cornerRadius=5.0;
        gengxinView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"choiceback.png"]];
        StudTable.userInteractionEnabled=NO;
        [self.view  addSubview:gengxinView];
       
        Update_Classtime=[[JYTextField alloc]initWithFrame:CGRectMake(35,65, 145, 30)
                                               cornerRadio:5
                                               borderColor:RGB(166, 166, 166)
                                               borderWidth:2
                                                lightColor:RGB(243, 168, 51)
                                                 lightSize:8
                                          lightBorderColor:RGB(235, 235, 235)];
        Update_Classtime.font=[UIFont systemFontOfSize:15];
        Update_Classtime.clearButtonMode=UITextFieldViewModeNever;
        Update_Classtime.tag=203;
        Update_Classtime.delegate=self;
         Update_Classtime.userInteractionEnabled=NO;
        Update_Classtime.placeholder=@"上课节数";
        [gengxinView addSubview:Update_Classtime];
        jieshuBtn=[UIButton buttonWithType:UIButtonTypeContactAdd];
        jieshuBtn.frame=CGRectMake(150, 65, 30, 30);
        jieshuBtn.tag=25;
        [jieshuBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
        [gengxinView addSubview:jieshuBtn];
        [gengxinView insertSubview:jieshuBtn aboveSubview:Update_Classtime];
        Update_studyStatus=[[JYTextField alloc]initWithFrame:CGRectMake(35, 135, 145, 30)
                                                cornerRadio:5
                                                borderColor:RGB(166, 166, 166)
                                                borderWidth:2
                                                 lightColor:RGB(243, 168, 51)
                                                  lightSize:8
                                           lightBorderColor:RGB(235, 235, 235)];
        Update_studyStatus.font=[UIFont systemFontOfSize:15];
        Update_studyStatus.clearButtonMode=UITextFieldViewModeNever;
        Update_oldStudyStatus.tag=200;
        Update_studyStatus.text=@"";
        Update_studyStatus.delegate=self;
        Update_studyStatus.placeholder=@"现在的状态";
        Update_studyStatus.keyboardType = UIKeyboardTypeNumberPad;
        Update_studyStatus.userInteractionEnabled=NO;
        [gengxinView addSubview:Update_studyStatus];
        newStatusBtn=[UIButton buttonWithType:UIButtonTypeContactAdd];
        newStatusBtn.tag=37;
        newStatusBtn.frame=CGRectMake(150, 135, 30, 30);
        [newStatusBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
        [gengxinView addSubview:newStatusBtn];
        [gengxinView insertSubview:newStatusBtn aboveSubview:Update_studyStatus];
        
        
        Update_oldStudyStatus=[[JYTextField alloc]initWithFrame:CGRectMake(35,100, 145, 30)
                                                    cornerRadio:5
                                                    borderColor:RGB(166, 166, 166)
                                                    borderWidth:2
                                                     lightColor:RGB(243, 168, 51)
                                                      lightSize:8
                                               lightBorderColor:RGB(235, 235, 235)];
        Update_oldStudyStatus.font=[UIFont systemFontOfSize:15];
        Update_oldStudyStatus.clearButtonMode=UITextFieldViewModeNever;
        Update_oldStudyStatus.tag=201;
        Update_oldStudyStatus.delegate=self;
        Update_oldStudyStatus.userInteractionEnabled=NO;
        Update_oldStudyStatus.placeholder=@"以前的状态";
        [gengxinView addSubview:Update_oldStudyStatus];
        oldStatusBtn=[UIButton buttonWithType:UIButtonTypeContactAdd];
        oldStatusBtn.tag=38;
        oldStatusBtn.frame=CGRectMake(150, 100, 30, 30);
        [oldStatusBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
        [gengxinView addSubview:oldStatusBtn];
        [gengxinView insertSubview:oldStatusBtn aboveSubview:Update_oldStudyStatus];
        Update_studentNum=[[JYTextField alloc]initWithFrame:CGRectMake(35, 30, 145, 30)
                                                cornerRadio:5
                                                borderColor:RGB(166, 166, 166)
                                                borderWidth:2
                                                 lightColor:RGB(243, 168, 51)
                                                  lightSize:8
                                           lightBorderColor:RGB(235, 235, 235)];
        Update_studentNum.font=[UIFont systemFontOfSize:15];
        Update_studentNum.clearButtonMode=UITextFieldViewModeAlways;
        Update_studentNum.delegate=self;
        Update_studentNum.tag=202;
        Update_studentNum.text=@"";
        Update_studentNum.placeholder=@"请输入学号";
        Update_studentNum.keyboardType = UIKeyboardTypeNumberPad;
        [gengxinView addSubview:Update_studentNum];
        UIToolbar * topView = [[UIToolbar alloc]
                               initWithFrame:CGRectMake(0, 0, 320, 30)];
        [topView
         setBarStyle:UIBarStyleDefault];
        
        UIBarButtonItem * btnSpace =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self
         action:nil];
        UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self
                                        action:@selector(quxiaojianpan)];
        NSArray * buttonsArray = [NSArray
                                  arrayWithObjects:btnSpace, doneButton, nil];
        
        
        [topView setItems:buttonsArray];
        
        [Update_studentNum setInputAccessoryView:topView];
        UIButton *update_btn=[UIButton buttonWithType:UIButtonTypeCustom];
        update_btn.frame=CGRectMake(170, 170, 40, 40);
        [update_btn setImage:[UIImage imageNamed:@"ConfirmBtn.png"] forState:UIControlStateNormal];
        [update_btn addTarget:self action:@selector(UPdateSend) forControlEvents:UIControlEventTouchUpInside];
        [gengxinView addSubview:update_btn];
        UIButton *update_quxiao=[UIButton buttonWithType:UIButtonTypeCustom];
        update_quxiao.frame=CGRectMake(177, 0, 40, 40);
        [update_quxiao setImage:[UIImage imageNamed:@"close2@.png"] forState:UIControlStateNormal];
        [update_quxiao addTarget:self action:@selector(UPdatequxiao) forControlEvents:UIControlEventTouchUpInside];
        [gengxinView addSubview:update_quxiao];
        }];

    [Update_studentNum resignFirstResponder];
    [Update_Classtime resignFirstResponder];
    [Update_oldStudyStatus resignFirstResponder];
    [Update_studyStatus resignFirstResponder];
    actionSheet.cornerRadius = 5;
    [actionSheet showWithTouch:event];
    
}
-(void)UPdatequxiao{
    [UIView animateWithDuration:0.3 animations:^{
        gengxinView.transform=CGAffineTransformMakeScale(0.3, 0.3);
        gengxinView.alpha=0.2;
        
        
    } completion:^(BOOL finished)
     {
         [gengxinView removeFromSuperview];
     }];
    StudTable.userInteractionEnabled=YES;

}
-(void)UPdateSend{
    //需要判断一下是否为空
    if ([Update_studentNum.text isEqualToString:@""]||[Update_Classtime.text isEqualToString:@""]||[Update_oldStudyStatus.text isEqualToString:@""]||[Update_studyStatus.text isEqualToString:@""]) {
        NSMutableArray *countArr_update=[[NSMutableArray alloc]init];
        for (int i=200; i<204; i++)
        {//解决输入的信息不能为空
            JYTextField *jy=(JYTextField *)[gengxinView viewWithTag:i];
            if ([jy.text isEqualToString:@""])
            {
                [countArr_update addObject:[NSString stringWithFormat:@"%d",jy.tag]];
            }
        }
        
        for (int k=0; k<[countArr_update count]; k++) {
            JYTextField *test=(JYTextField*)[gengxinView viewWithTag:[[countArr_update objectAtIndex:k] integerValue]];
            [test shake:20 withDelta:5
               andSpeed:0.03
         shakeDirection:ShakeDirectionHorizontal];
            
        }

    }else
    {//当全部不为空的时候
        [self UpdateInformation_OnFunction_caoqin];
        
    }
}
-(void)UpdateInformation_OnFunction_caoqin
{
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:Update_Classtime.text,@"classTime",Update_studentNum.text,@"studentNumber",Update_studyStatus.text,@"studyStatus",Update_oldStudyStatus.text,@"oldStudyStatus",nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLupdateStudentOut]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailed_update:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceed_update:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
    

}
- (void)ASIHttpRequestFailed_update:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    [self.view makeToast:Request_TimeOut];
    NSLog(@"the error is %@",error);
    [self UPdatequxiao];
}
//网络请求成功
- (void)ASIHttpRequestSuceed_update:(ASIHTTPRequest *)request{
    [CollegeLoad stopAnimating];
    NSData *responseData = [request responseData];
    JsonCollegeAndGrades=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders Three 解析＝%@",JsonCollegeAndGrades);
    NSString *Alert=[JsonCollegeAndGrades valueForKey:@"Status"];
    @try {
        if ([JsonCollegeAndGrades count])
        {
            if ([Alert isEqualToString:@"Success"]) {
                
                [iToast make:@"更新成功" duration:1000];
                [self UPdatequxiao];
            }else{
                [self UPdatequxiao];
                UIAlertView *AlerVIew=[[UIAlertView alloc] initWithTitle:nil message:@"发送失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [AlerVIew show];
                
            }
        }
        else
        {
            [self UPdatequxiao];
            UIAlertView *AlerVIew=[[UIAlertView alloc] initWithTitle:nil message:@"数据返回为空\n请重新操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [AlerVIew show];
            
            
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"数据返回为空==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"数据返回为空==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"数据返回");
    }
    
}

-(void)quxiaojianpan{
    [Update_studentNum resignFirstResponder];
    [Update_Classtime resignFirstResponder];
    [Update_oldStudyStatus resignFirstResponder];
    [Update_studyStatus resignFirstResponder];

}
-(void)MethodForToolBar
{
    tool=[[UIToolbar alloc]init];
    tool.frame=CGRectMake(0,self.view.frame.size.height - tool.frame.size.height-44, 320, 44);
    tool.barTintColor=[[UIColor blueColor] colorWithAlphaComponent:.65];
    tool.barStyle=UIBarStyleDefault;
    tool.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    tool.tintColor = [[UIColor blueColor] colorWithAlphaComponent:.65];
    UILabel *tip=[[UILabel alloc]init];
    tip.frame=CGRectMake(5, 5, 50, 10);
    tip.backgroundColor=[UIColor clearColor];
    tip.font=[UIFont systemFontOfSize:10];
    tip.textColor=[UIColor whiteColor];
    tip.text=@"当前班级:";
    //
    UILabel *Class=[[UILabel alloc]init];
    Class.frame=CGRectMake(5, 15, 150, 20);
    Class.backgroundColor=[UIColor clearColor];
    Class.font=[UIFont systemFontOfSize:15];
    Class.textColor=[UIColor blackColor];
    Class.adjustsFontSizeToFitWidth=YES;
    Class.text=[NSString stringWithFormat:@"%@%@%@",NianJiText.text,ZhuanYeText.text,BanJiText.text];
    //
    UIImageView *line=[[UIImageView alloc]init];
    line.frame=CGRectMake(0, 30, 145, 15);
    line.image=[UIImage imageNamed:@"redline.png"];
    //
    UILabel *Shidao=[[UILabel alloc]init];
    Shidao.frame=CGRectMake(160, 2, 50, 20);
    Shidao.font=[UIFont systemFontOfSize:11];
    Shidao.textColor=[UIColor redColor];
    Shidao.text=@"实到人数:";
    NumShidao=[[UILabel alloc]init];
    NumShidao.frame=CGRectMake(210, 2, 40, 20);
    NumShidao.font=[UIFont systemFontOfSize:11];
    NumShidao.textColor=[UIColor redColor];
    
    NumShidao.text=[NSString stringWithFormat:@"%d",CAll_StuName.count-count];


    //
    UILabel *Yindao=[[UILabel alloc]init];
    Yindao.frame=CGRectMake(160, 22, 50, 20);
    Yindao.font=[UIFont systemFontOfSize:11];
    Yindao.textColor=[UIColor redColor];
    Yindao.text=@"应到人数:";
    //
    NumYindao=[[UILabel alloc]init];
    NumYindao.frame=CGRectMake(210, 22, 40, 20);
    NumYindao.font=[UIFont systemFontOfSize:11];
    NumYindao.textColor=[UIColor redColor];
    NumYindao.text=[NSString stringWithFormat:@"%d",[CAll_StuName count]];
    //
    HTPressableButton *ConfirmBtn2=[HTPressableButton buttonWithType:UIButtonTypeCustom];
    ConfirmBtn2.style=HTPressableButtonStyleRounded;
    ConfirmBtn2.frame=CGRectMake(240, 5, 60, 35);
    //ConfirmBtn2.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell.png"]];
    ConfirmBtn2.buttonColor=[UIColor grassColor];
    ConfirmBtn2.shadowColor=[UIColor grassDarkColor];
    [ConfirmBtn2.layer setCornerRadius:10.0];
    [ConfirmBtn2 setTitle:@"确 定" forState:UIControlStateNormal];
    ConfirmBtn2.tag=11;
    [ConfirmBtn2 addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    
    tool.hidden=NO;
    [tool addSubview:ConfirmBtn2];
    [tool addSubview:NumYindao];
    [tool addSubview:NumShidao];
    [tool addSubview:Shidao];
    [tool addSubview:Yindao];
    [tool addSubview:line];
    [tool addSubview:Class];
    [tool addSubview:tip];
    [self.view addSubview:tool];
    [StudTable bringSubviewToFront:tool];
    
}
-(void)TurnToRight{
    //添加手指向右滑动屏幕时执行的操作
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden=NO;
}

-(void)PoptheViewAllOverScreen
{
    // if ([Teacher isEqualToString:@"0"]) {
    
    grayView=[[UIView alloc]init];
    grayView.frame=CGRectMake(0, 0, ScreenWidth,ScreenHeight);
    grayView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"kaoqin_backImage.png"]];
    StudTable.hidden=YES;//设置列表视图隐藏
    /*change*/
    //self.navigationController.navigationBarHidden=YES;
    [self.view addSubview:grayView];
    //添加向右滑动返回父视图
    UISwipeGestureRecognizer *turnRight =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(TurnToRight)];
    turnRight.direction=UISwipeGestureRecognizerDirectionRight;//控制方向向右
    [grayView addGestureRecognizer:turnRight];
    
    CallBtn=[HTPressableButton buttonWithType:UIButtonTypeCustom];
    CallBtn.style=HTPressableButtonStyleRounded;
       if ([ID_User isEqualToString:@"普通教师"])
    {
        CallBtn.frame=CGRectMake(0, 0, 100, 100);
        CallBtn.center=grayView.center;
        CallBtn.alpha=0.7;
        CallBtn.buttonColor=[UIColor grassColor];
        CallBtn.shadowColor=[UIColor grassDarkColor];
        [CallBtn setTitle:@"精确点名" forState:UIControlStateNormal];
        /*change*/
        
        //[CallBtn setImage:[UIImage imageNamed:@"btnimg.png"] forState:UIControlStateNormal];//点名按钮
        CallBtn.tag=13;
        //Animate
       /* UIImage *leftImage = [UIImage imageNamed:@"triangle_right"];
        UIImage *test_left=[UIImage imageNamed:@"Caoqin_1"];
        
        leftMarquee=[[DEInfiniteTileMarqueeView alloc]initWithFrame:CGRectMake(5, ScreenHeight/2-10, 100, 20)];
        leftMarquee.tileImage = test_left;
        leftMarquee.tileDuration = 1.8;
        leftMarquee.direction = DEInfiniteTileMarqueeViewDirectionLeftToRight;
        
        UIImage *test_right=[UIImage imageNamed:@"Caoqin_2"];
        UIImage *rightImage = [UIImage imageWithCGImage: test_right.CGImage
                                                  scale: test_right.scale
                                            orientation: UIImageOrientationUp];
        rightMarquee=[[DEInfiniteTileMarqueeView alloc]initWithFrame:CGRectMake(ScreenWidth/2+55, ScreenHeight/2-10, 100, 20)];
        rightMarquee.tileImage = rightImage;
        rightMarquee.tileDuration = 1.8;
        rightMarquee.direction = DEInfiniteTileMarqueeViewDirectionRightToLeft;
        
        UIImage *topImage = [UIImage imageWithCGImage: leftImage.CGImage
                                                scale: leftImage.scale
                                          orientation: UIImageOrientationRight];
        topMarquee=[[DEInfiniteTileMarqueeView alloc]initWithFrame:CGRectMake(ScreenWidth/2-10, ScreenHeight/2-55-100, 20, 100)];
        topMarquee.tileImage = topImage;
        topMarquee.tileDuration = 0.5;
        topMarquee.direction = DEInfiniteTileMarqueeViewDirectionTopToBottom;
        
        UIImage *bottomImage = [UIImage imageWithCGImage: leftImage.CGImage
                                                   scale: leftImage.scale
                                             orientation: UIImageOrientationLeft];
        bottomMarquee=[[DEInfiniteTileMarqueeView alloc]initWithFrame:CGRectMake(ScreenWidth/2-10, ScreenHeight/2+55, 20, 100)];
        bottomMarquee.tileImage = bottomImage;
        bottomMarquee.tileDuration = 0.5;
        bottomMarquee.direction = DEInfiniteTileMarqueeViewDirectionBottomToTop;*/
       // [grayView addSubview:leftMarquee];
       // [grayView addSubview:rightMarquee];
       // [grayView addSubview:topMarquee];
       // [grayView addSubview:bottomMarquee];
        

    }
    else if([ID_User isEqualToString:@"领导"]||[ID_User isEqualToString:@"辅导员"])
    {
        CallBtn.frame=CGRectMake(162.5,grayView.center.y-110, 100, 80);
        CallBtn.alpha=0.9;
        CallBtn.buttonColor=[UIColor grassColor];
        CallBtn.shadowColor=[UIColor grassDarkColor];
        [CallBtn setTitle:@"精确点名" forState:UIControlStateNormal];
        
        //[CallBtn setImage:[UIImage imageNamed:@"btnimg.png"] forState:UIControlStateNormal];//点名按钮
        CallBtn.tag=13;
        //
        CheckBtn=[HTPressableButton buttonWithType:UIButtonTypeCustom];
        CheckBtn.frame=CGRectMake(162.5, grayView.center.y-5-20, 100, 120);
        CheckBtn.hidden=NO;
        CheckBtn.style=HTPressableButtonStyleRounded;
        CheckBtn.buttonColor=[UIColor blueJeansColor];
        CheckBtn.shadowColor=[UIColor blueJeansDarkColor];
        [CheckBtn setTitle:@"精确查询" forState:UIControlStateNormal];
        CheckBtn.alpha=0.9;
        /*change*/
       // [CheckBtn setImage:[UIImage imageNamed:@"btnimg1.png"] forState:UIControlStateNormal];//查询按钮
        CheckBtn.tag=15;
        CheckBtn.backgroundColor=[UIColor clearColor];
        [CheckBtn.layer setCornerRadius:5.0];
        CheckBtn.titleLabel.textColor=[UIColor redColor];
        CheckBtn.titleLabel.font=[UIFont systemFontOfSize:20];
        [CheckBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
        [grayView addSubview:CheckBtn];
        //快速查询
        FastCheckBtn=[HTPressableButton buttonWithType:UIButtonTypeCustom];
        FastCheckBtn.frame=CGRectMake(57.5, CallBtn.frame.origin.y, 100, 200);
        FastCheckBtn.style=HTPressableButtonStyleRounded;
        FastCheckBtn.buttonColor=[UIColor lemonColor];
        FastCheckBtn.shadowColor=[UIColor lemonDarkColor];
         FastCheckBtn.titleLabel.font=[UIFont systemFontOfSize:20];
        [FastCheckBtn setTitle:@"快速查询" forState:UIControlStateNormal];
        FastCheckBtn.alpha=0.9;
        FastCheckBtn.tag=7;
        [FastCheckBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
        [grayView addSubview:FastCheckBtn];
        
        
        NSLog(@"--callbtn,x=%f,y=%f",CheckBtn.frame.size.height,CheckBtn.frame.origin.y);
        
        //Animate
       /* UIImage *leftImage = [UIImage imageNamed:@"triangle_right"];
        leftMarquee=[[DEInfiniteTileMarqueeView alloc]initWithFrame:CGRectMake(5, ScreenHeight/2-10, 100, 20)];
        leftMarquee.tileImage = leftImage;
        leftMarquee.tileDuration = 0.5;
        leftMarquee.direction = DEInfiniteTileMarqueeViewDirectionLeftToRight;
        
        
        UIImage *rightImage = [UIImage imageWithCGImage: leftImage.CGImage
                                                  scale: leftImage.scale
                                            orientation: UIImageOrientationUpMirrored];
        rightMarquee=[[DEInfiniteTileMarqueeView alloc]initWithFrame:CGRectMake(ScreenWidth/2+55, ScreenHeight/2-10, 100, 20)];
        rightMarquee.tileImage = rightImage;
        rightMarquee.tileDuration = 0.5;
        rightMarquee.direction = DEInfiniteTileMarqueeViewDirectionRightToLeft;
        
        UIImage *topImage = [UIImage imageWithCGImage: leftImage.CGImage
                                                scale: leftImage.scale
                                          orientation: UIImageOrientationRight];
        topMarquee=[[DEInfiniteTileMarqueeView alloc]initWithFrame:CGRectMake(ScreenWidth/2-10, ScreenHeight/2-55-100-45, 20, 100)];
        topMarquee.tileImage = topImage;
        topMarquee.tileDuration = 0.5;
        topMarquee.direction = DEInfiniteTileMarqueeViewDirectionTopToBottom;
        
        UIImage *bottomImage = [UIImage imageWithCGImage: leftImage.CGImage
                                                   scale: leftImage.scale
                                             orientation: UIImageOrientationLeft];
        bottomMarquee=[[DEInfiniteTileMarqueeView alloc]initWithFrame:CGRectMake(ScreenWidth/2-10, ScreenHeight/2+55+45, 20, 100)];
        bottomMarquee.tileImage = bottomImage;
        bottomMarquee.tileDuration = 0.5;
        bottomMarquee.direction = DEInfiniteTileMarqueeViewDirectionBottomToTop;*/
        //[grayView addSubview:leftMarquee];
        //[grayView addSubview:rightMarquee];
        //[grayView addSubview:topMarquee];
        //[grayView addSubview:bottomMarquee];
        

        
    }

    CallBtn.backgroundColor=[UIColor clearColor];
    [CallBtn.layer setCornerRadius:5.0];
    CallBtn.titleLabel.textColor=[UIColor redColor];
    CallBtn.titleLabel.font=[UIFont systemFontOfSize:20];
     [CallBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    [grayView addSubview:CallBtn];
    
    //添加导航栏
   /* Tool_back=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    Tool_back.alpha=0.9;
    Tool_back.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbackground.png"]];
    UIButton *Btn_back=[UIButton buttonWithType:UIButtonTypeCustom];
    Btn_back.frame=CGRectMake(5, 17, 40, 40);
    [Btn_back setImage:[UIImage imageNamed:@"left.png"] forState:UIControlStateNormal];
    Btn_back.tag=36;
    [Btn_back addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *Tool_title=[[UILabel alloc]init];
    Tool_title.frame=CGRectMake(0, 0, 100, 50);
    Tool_title.center=Tool_back.center;
    Tool_title.textColor=[UIColor blackColor];
    Tool_title.text=@"考勤点查";
    [Tool_back addSubview:Tool_title];
    [Tool_back addSubview:Btn_back];
    [grayView addSubview:Tool_back];*/
    
}


#pragma mark-view For choice
-(void)presentChoiceViewForLeaders
{
    choiceView=[[UIView alloc]init];
    choiceView.frame=CGRectMake(0, 0, ScreenWidth, 230);
    choiceView.center=grayView.center;
    choiceView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"choiceback.png"]];
    [choiceView.layer setCornerRadius:5.0];
    choiceView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    choiceView.alpha = 0;
    //添加返回按钮
    CloseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    CloseBtn.frame=CGRectMake(ScreenWidth-40, 0, 40, 40);
    [CloseBtn setImage:[UIImage imageNamed:@"close2@.png"] forState:UIControlStateNormal];
    [choiceView addSubview:CloseBtn];
    CloseBtn.tag=34;
    [CloseBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];

    [UIView animateWithDuration:0.35 delay:0 options: UIViewAnimationOptionCurveLinear    animations:^{
        [FastCheckBtn removeFromSuperview];
        [CallBtn removeFromSuperview];
        [rightMarquee removeFromSuperview];
        [leftMarquee removeFromSuperview];
        [topMarquee removeFromSuperview];
        [bottomMarquee removeFromSuperview];
        [grayView addSubview:choiceView];
        choiceView.alpha = 1;
        choiceView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        return ;
    }];
        UILabel *DateName=[[UILabel alloc]init];
        DateName.frame=CGRectMake(10, 10, 70, 30);
        DateName.textColor=[UIColor grayColor];
        DateName.font=[UIFont systemFontOfSize:14];
        DateName.text=@"查询日期:";
        [choiceView addSubview:DateName];
        
        UIButton *AddDate=[UIButton buttonWithType:UIButtonTypeCustom];
        AddDate.frame=CGRectMake(300-40+2, 10+2, 23, 23);
        [AddDate setImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
        AddDate.tag=30;
     
       // [choiceView addSubview:AddDate];
        [AddDate addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
        dateInput=[[JYTextField alloc]initWithFrame:CGRectMake(70, 10, 220, 30)
                                         cornerRadio:5
                                         borderColor:RGB(166, 166, 166)
                                         borderWidth:2
                                          lightColor:RGB(243, 168, 51)
                                           lightSize:8
                                    lightBorderColor:RGB(235, 235, 235)];
        dateInput.borderStyle=UITextBorderStyleNone;
        dateInput.enabled=NO;
        dateInput.tag=46;
        dateInput.textColor=[UIColor blueColor];
        dateInput.font=[UIFont systemFontOfSize:15];
        dateInput.placeholder=@"请选择日期...";
        dateInput.delegate=self;
        dateInput.backgroundColor=[UIColor whiteColor];
        [choiceView addSubview:dateInput];
        [choiceView insertSubview:AddDate aboveSubview:dateInput];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleBackgroundTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [choiceView addGestureRecognizer:tapRecognizer];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];//监听弹出
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    //college
    UILabel *collegeLable=[[UILabel alloc]init];
    collegeLable.frame=CGRectMake(36, 50, 50, 30);
    collegeLable.textColor=[UIColor grayColor];
    collegeLable.font=[UIFont systemFontOfSize:14];
    collegeLable.text=@"学院:";
    [choiceView addSubview:collegeLable];
    //TextField
    XUeyuanText=[[JYTextField alloc]initWithFrame:CGRectMake(70, 50, 220, 30)
                                                 cornerRadio:5
                                                 borderColor:RGB(166, 166, 166)
                                                 borderWidth:2
                                                  lightColor:RGB(243, 168, 51)
                                                   lightSize:8
                                            lightBorderColor:RGB(235, 235, 235)];
    XUeyuanText.font=[UIFont systemFontOfSize:15];
    XUeyuanText.enabled=NO;
    xueyuanBtn.tag=40;
    XUeyuanText.borderStyle=UITextBorderStyleNone;
    XUeyuanText.placeholder=@"请选择学院";
    //
    xueyuanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
   // xueyuanBtn.frame=CGRectMake(220-30, 0, 30, 30);
    xueyuanBtn.frame=CGRectMake(300-40, 51, 30, 30);
    xueyuanBtn.backgroundColor=[UIColor clearColor];
    
    [xueyuanBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    xueyuanBtn.tag=20;
    [xueyuanBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    //[XUeyuanText addSubview:xueyuanBtn];
    [choiceView addSubview:XUeyuanText];
    [choiceView insertSubview:xueyuanBtn aboveSubview:XUeyuanText];
    //添加加载界面
    CollegeLoad=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CollegeLoad.frame=CGRectMake(0, 0, 30, 30);
    [CollegeLoad startAnimating];
    [xueyuanBtn addSubview:CollegeLoad];
    
    XueyuanTable=[[TableViewWithBlock alloc] init];
    XueyuanTable.frame=CGRectMake(70, 80, 220, 5);
    XueyuanTable.backgroundColor=[UIColor whiteColor];
    XueyuanTable.hidden=YES;
    [choiceView addSubview:XueyuanTable];
    
    //Nianji
    UILabel *NianjiLable=[[UILabel alloc]initWithFrame:CGRectMake(15, 85, 50, 30)];
    NianjiLable.textColor=[UIColor grayColor];
    NianjiLable.font=[UIFont systemFontOfSize:14];
    NianjiLable.text=@"年级:";
    [choiceView addSubview:NianjiLable];
    NianJiText=[[JYTextField alloc]initWithFrame:CGRectMake(13, 115, 70, 30)
                                cornerRadio:5
                                     borderColor:RGB(166, 166, 166)
                                     borderWidth:2
                                      lightColor:RGB(243, 168, 51)
                                       lightSize:8
                                lightBorderColor:RGB(235, 235, 235)];
    NianJiText.font=[UIFont systemFontOfSize:13];
    NianJiText.tag=41;
    //NianJiText.enabled=YES;
    NianJiText.userInteractionEnabled=NO;
    NianJiText.borderStyle=UITextBorderStyleNone;
    NianJiText.placeholder=@"年级";
    //
    nianjiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //nianjiBtn.frame=CGRectMake(70-30, 0, 30, 30);
    nianjiBtn.frame=CGRectMake(53, 116, 30, 30);
    nianjiBtn.backgroundColor=[UIColor clearColor];
    [nianjiBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    nianjiBtn.tag=21;
    [nianjiBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    //[NianJiText addSubview:nianjiBtn];
    //[NianJiText addSubview:nianjiBtn];
    //[choiceView bringSubviewToFront:nianjiBtn];
    [choiceView addSubview:NianJiText];
    [choiceView insertSubview:nianjiBtn aboveSubview:NianJiText];
    

    
    NianJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(13, 145, 70, 8)];
    //NianJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(13, 289+40, 70, 8)];

    NianJiTable.backgroundColor=[UIColor clearColor];
    NianJiTable.hidden=YES;
    [choiceView addSubview:NianJiTable];
    //[grayView insertSubview:NianJiTable aboveSubview:choiceView];
    //ZhuanYe
    zhuanyeLable=[[UILabel alloc]initWithFrame:CGRectMake(100, 85, 50, 30)];
    zhuanyeLable.textColor=[UIColor grayColor];
    zhuanyeLable.font=[UIFont systemFontOfSize:14];
    zhuanyeLable.text=@"专业:";
    [choiceView addSubview:zhuanyeLable];
    ZhuanYeText=[[JYTextField alloc]initWithFrame:CGRectMake(100, 115, 140, 30)
                                      cornerRadio:5
                                      borderColor:RGB(166, 166, 166)
                                      borderWidth:2
                                       lightColor:RGB(243, 168, 51)
                                        lightSize:8
                                 lightBorderColor:RGB(235, 235, 235)];
    ZhuanYeText.font=[UIFont systemFontOfSize:12];
    ZhuanYeText.tag=42;
    ZhuanYeText.enabled=NO;
    ZhuanYeText.borderStyle=UITextBorderStyleNone;
    ZhuanYeText.placeholder=@"请选择专业";
    zhuanyeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //zhuanyeBtn.frame=CGRectMake(130-30, 0, 30, 30);
    zhuanyeBtn.frame=CGRectMake(210, 116, 30, 30);

    zhuanyeBtn.backgroundColor=[UIColor clearColor];
    [zhuanyeBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    zhuanyeBtn.tag=22;
    [zhuanyeBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    //[ZhuanYeText addSubview:zhuanyeBtn];
    [choiceView addSubview:ZhuanYeText];
    [choiceView insertSubview:zhuanyeBtn aboveSubview:ZhuanYeText];
    ZhuanyeTable=[[TableViewWithBlock alloc] init];
    ZhuanyeTable.frame=CGRectMake(100, 145, 140, 5);
    ZhuanyeTable.backgroundColor=[UIColor whiteColor];
    ZhuanyeTable.hidden=YES;
    [choiceView addSubview:ZhuanyeTable];
    //Banji
    banjiLable=[[UILabel alloc]init];
    banjiLable.frame=CGRectMake(245, 85, 50, 30);
    banjiLable.textColor=[UIColor grayColor];
    banjiLable.font=[UIFont systemFontOfSize:14];
    banjiLable.text=@"班级:";
    [choiceView addSubview:banjiLable];
    BanJiText=[[JYTextField alloc]initWithFrame:CGRectMake(245, 115, 70, 30)
                                    cornerRadio:5
                                    borderColor:RGB(166, 166, 166)
                                    borderWidth:2
                                     lightColor:RGB(243, 168, 51)
                                      lightSize:8
                               lightBorderColor:RGB(235, 235, 235)];
    BanJiText.font=[UIFont systemFontOfSize:14];
    BanJiText.enabled=NO;
    BanJiText.tag=43;
    BanJiText.borderStyle=UITextBorderStyleNone;
    BanJiText.placeholder=@"班级";
    [choiceView addSubview:BanJiText];
    banjiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //banjiBtn.frame=CGRectMake(70-30, 0, 30, 30);
    banjiBtn.frame=CGRectMake(315-30, 116, 30, 30);
    banjiBtn.backgroundColor=[UIColor clearColor];
    [banjiBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    banjiBtn.tag=23;
    [banjiBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    //[BanJiText addSubview:banjiBtn];
    BanJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(245, 145, 70, 5)];
    BanJiTable.backgroundColor=[UIColor whiteColor];
    BanJiTable.hidden=YES;
    [choiceView addSubview:BanJiTable];
    [choiceView insertSubview:banjiBtn aboveSubview:BanJiText];
    //Classinput
    className=[[UILabel alloc]init];
    className.frame=CGRectMake(13, 150, 70, 30);
    className.textColor=[UIColor grayColor];
    className.font=[UIFont systemFontOfSize:14];
    className.text=@"课程名称:";
    [choiceView addSubview:className];
   
    //
    ClassInput=[[JYTextField alloc]initWithFrame:CGRectMake(13, 180, 150, 30)
                                     cornerRadio:5
                                     borderColor:RGB(166, 166, 166)
                                     borderWidth:2
                                      lightColor:RGB(243, 168, 51)
                                       lightSize:8
                                lightBorderColor:RGB(235, 235, 235)];
    ClassInput.borderStyle=UITextBorderStyleNone;
    ClassInput.tag=44;
    //ThemeCon.frame=CGRectMake(45, 5, 90, 20);
    ClassInput.textColor=[UIColor blueColor];
    ClassInput.font=[UIFont systemFontOfSize:15];
    ClassInput.placeholder=@"请输入/选择课程";
    ClassInput.clearButtonMode=UITextFieldViewModeNever;
    ClassInput.delegate=self;
    ClassInput.backgroundColor=[UIColor whiteColor];
    [choiceView addSubview:ClassInput];
    kechengBtn=[UIButton buttonWithType:UIButtonTypeContactAdd];
    kechengBtn.tag=24;
    kechengBtn.frame=CGRectMake(134, 180, 30, 30);
    [kechengBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:kechengBtn];
    [choiceView insertSubview:kechengBtn aboveSubview:ClassInput];
    //节数
    SectionLable=[[UILabel alloc]init];
    SectionLable.frame=CGRectMake(175, 150, 70, 30);
    SectionLable.textColor=[UIColor grayColor];
    SectionLable.font=[UIFont systemFontOfSize:14];
    SectionLable.text=@"课程节数:";
    [choiceView addSubview:SectionLable];
    SectionText=[[JYTextField alloc]initWithFrame:CGRectMake(175, 180,70, 30)
                                     cornerRadio:5
                                     borderColor:RGB(166, 166, 166)
                                     borderWidth:2
                                      lightColor:RGB(243, 168, 51)
                                       lightSize:8
                                lightBorderColor:RGB(235, 235, 235)];
    SectionText.borderStyle=UITextBorderStyleNone;
    SectionText.enabled=NO;
    SectionText.tag=45;
    SectionText.textColor=[UIColor blueColor];
    SectionText.font=[UIFont systemFontOfSize:15];
    SectionText.placeholder=@"节数";
    SectionText.backgroundColor=[UIColor whiteColor];
    [choiceView addSubview:SectionText];
    jieshuBtn=[UIButton buttonWithType:UIButtonTypeContactAdd];
    jieshuBtn.frame=CGRectMake(216, 180, 30, 30);
    jieshuBtn.tag=25;
    [jieshuBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:jieshuBtn];
    [choiceView insertSubview:jieshuBtn aboveSubview:SectionText];

    

    ConfirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    ConfirmBtn.frame=CGRectMake(choiceView.frame.size.width-55, choiceView.frame.size.height-55, 50, 50);
    ConfirmBtn.backgroundColor=[UIColor clearColor];
    //[conbtn setTitle:@"提交" forState:UIControlStateNormal];
    [ConfirmBtn setImage:[UIImage imageNamed:@"ConfirmBtn.png"] forState:UIControlStateNormal];
    [choiceView addSubview:ConfirmBtn];
    ConfirmBtn.tag=33;
    [ConfirmBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    //首先初始化按钮为不可点击
    xueyuanBtn.enabled=NO;
    nianjiBtn.enabled=NO;
    zhuanyeBtn.enabled=NO;
    banjiBtn.enabled=NO;
    kechengBtn.enabled=NO;
}
-(void)presentChoiceViewForTeachers
{
    choiceView=[[UIView alloc]init];
    choiceView.frame=CGRectMake(0, 0, ScreenWidth, 230);
    choiceView.center=grayView.center;
    choiceView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"choiceback.png"]];
    [choiceView.layer setCornerRadius:5.0];
    choiceView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    choiceView.alpha = 0;
    //添加返回按钮
    CloseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    CloseBtn.frame=CGRectMake(ScreenWidth-40, 0, 40, 40);
    [CloseBtn setImage:[UIImage imageNamed:@"close2@.png"] forState:UIControlStateNormal];
    [choiceView addSubview:CloseBtn];
    CloseBtn.tag=34;
    [CloseBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.35 delay:0 options: UIViewAnimationOptionCurveLinear    animations:^{
        [FastCheckBtn removeFromSuperview];
        [CallBtn removeFromSuperview];
        [rightMarquee removeFromSuperview];
        [leftMarquee removeFromSuperview];
        [topMarquee removeFromSuperview];
        [bottomMarquee removeFromSuperview];
        [grayView addSubview:choiceView];
        choiceView.alpha = 1;
        choiceView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        return ;
    }];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handleBackgroundTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [choiceView addGestureRecognizer:tapRecognizer];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];//监听弹出
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    //college
    UILabel *collegeLable=[[UILabel alloc]init];
    collegeLable.frame=CGRectMake(36, 30, 50, 30);
    collegeLable.textColor=[UIColor grayColor];
    collegeLable.font=[UIFont systemFontOfSize:14];
    collegeLable.text=@"学院:";
    [choiceView addSubview:collegeLable];
    //TextField
    XUeyuanText=[[JYTextField alloc]initWithFrame:CGRectMake(80, 30, 220, 30)
                                      cornerRadio:5
                                      borderColor:RGB(166, 166, 166)
                                      borderWidth:2
                                       lightColor:RGB(243, 168, 51)
                                        lightSize:8
                                 lightBorderColor:RGB(235, 235, 235)];
    XUeyuanText.font=[UIFont systemFontOfSize:15];
    XUeyuanText.tag=40;
    XUeyuanText.enabled=NO;
    XUeyuanText.borderStyle=UITextBorderStyleNone;
    XUeyuanText.placeholder=@"请选择学院";
    //
    xueyuanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    // xueyuanBtn.frame=CGRectMake(220-30, 0, 30, 30);
    xueyuanBtn.frame=CGRectMake(300-30, 31, 30, 30);
    xueyuanBtn.backgroundColor=[UIColor clearColor];
    
    [xueyuanBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    xueyuanBtn.tag=20;
    [xueyuanBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:XUeyuanText];
    
    //添加加载界面
    CollegeLoad=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CollegeLoad.frame=CGRectMake(0, 0, 30, 30);
    [CollegeLoad startAnimating];
    [xueyuanBtn addSubview:CollegeLoad];
    
    [choiceView insertSubview:xueyuanBtn aboveSubview:XUeyuanText];
    XueyuanTable=[[TableViewWithBlock alloc] init];
    XueyuanTable.frame=CGRectMake(80, 60, 220, 5);
    XueyuanTable.backgroundColor=[UIColor whiteColor];
    XueyuanTable.hidden=YES;
    [choiceView addSubview:XueyuanTable];
    
    //Nianji
    UILabel *NianjiLable=[[UILabel alloc]initWithFrame:CGRectMake(15, 75, 50, 30)];
    NianjiLable.textColor=[UIColor grayColor];
    NianjiLable.font=[UIFont systemFontOfSize:14];
    NianjiLable.text=@"年级:";
    [choiceView addSubview:NianjiLable];
    NianJiText=[[JYTextField alloc]initWithFrame:CGRectMake(13, 105, 70, 30)
                                     cornerRadio:5
                                     borderColor:RGB(166, 166, 166)
                                     borderWidth:2
                                      lightColor:RGB(243, 168, 51)
                                       lightSize:8
                                lightBorderColor:RGB(235, 235, 235)];
    NianJiText.font=[UIFont systemFontOfSize:13];
    //NianJiText.enabled=YES;
    NianJiText.tag=41;
    NianJiText.userInteractionEnabled=NO;
    NianJiText.borderStyle=UITextBorderStyleNone;
    NianJiText.placeholder=@"年级";
    //
    nianjiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //nianjiBtn.frame=CGRectMake(70-30, 0, 30, 30);
    nianjiBtn.frame=CGRectMake(53, 106, 30, 30);
    nianjiBtn.backgroundColor=[UIColor clearColor];
    [nianjiBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    nianjiBtn.tag=21;
    [nianjiBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:NianJiText];
    [choiceView insertSubview:nianjiBtn aboveSubview:NianJiText];
    
    
    
    NianJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(13, 135, 70, 8)];
    //NianJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(13, 289+40, 70, 8)];
    
    NianJiTable.backgroundColor=[UIColor clearColor];
    NianJiTable.hidden=YES;
    [choiceView addSubview:NianJiTable];
    //[grayView insertSubview:NianJiTable aboveSubview:choiceView];
    //ZhuanYe
    zhuanyeLable=[[UILabel alloc]initWithFrame:CGRectMake(100, 75, 50, 30)];
    zhuanyeLable.textColor=[UIColor grayColor];
    zhuanyeLable.font=[UIFont systemFontOfSize:14];
    zhuanyeLable.text=@"专业:";
    [choiceView addSubview:zhuanyeLable];
    ZhuanYeText=[[JYTextField alloc]initWithFrame:CGRectMake(100, 105, 140, 30)
                                      cornerRadio:5
                                      borderColor:RGB(166, 166, 166)
                                      borderWidth:2
                                       lightColor:RGB(243, 168, 51)
                                        lightSize:8
                                 lightBorderColor:RGB(235, 235, 235)];
    ZhuanYeText.font=[UIFont systemFontOfSize:12];
    ZhuanYeText.tag=42;
    ZhuanYeText.enabled=NO;
    ZhuanYeText.borderStyle=UITextBorderStyleNone;
    ZhuanYeText.placeholder=@"请选择专业";
    zhuanyeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //zhuanyeBtn.frame=CGRectMake(130-30, 0, 30, 30);
    zhuanyeBtn.frame=CGRectMake(210, 106, 30, 30);
    
    zhuanyeBtn.backgroundColor=[UIColor clearColor];
    [zhuanyeBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    zhuanyeBtn.tag=22;
    [zhuanyeBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    //[ZhuanYeText addSubview:zhuanyeBtn];
    [choiceView addSubview:ZhuanYeText];
    [choiceView insertSubview:zhuanyeBtn aboveSubview:ZhuanYeText];
    ZhuanyeTable=[[TableViewWithBlock alloc] init];
    ZhuanyeTable.frame=CGRectMake(100, 135, 140, 5);
    ZhuanyeTable.backgroundColor=[UIColor clearColor];
    ZhuanyeTable.hidden=YES;
    [choiceView addSubview:ZhuanyeTable];
    //Banji
    banjiLable=[[UILabel alloc]init];
    banjiLable.frame=CGRectMake(245, 75, 50, 30);
    banjiLable.textColor=[UIColor grayColor];
    banjiLable.font=[UIFont systemFontOfSize:14];
    banjiLable.text=@"班级:";
    [choiceView addSubview:banjiLable];
    BanJiText=[[JYTextField alloc]initWithFrame:CGRectMake(245, 105, 70, 30)
                                    cornerRadio:5
                                    borderColor:RGB(166, 166, 166)
                                    borderWidth:2
                                     lightColor:RGB(243, 168, 51)
                                      lightSize:8
                               lightBorderColor:RGB(235, 235, 235)];
    BanJiText.font=[UIFont systemFontOfSize:14];
    BanJiText.enabled=NO;
    BanJiText.tag=43;
    BanJiText.borderStyle=UITextBorderStyleNone;
    BanJiText.placeholder=@"班级";
    [choiceView addSubview:BanJiText];
    banjiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //banjiBtn.frame=CGRectMake(70-30, 0, 30, 30);
    banjiBtn.frame=CGRectMake(315-30, 106, 30, 30);
    banjiBtn.backgroundColor=[UIColor clearColor];
    [banjiBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    banjiBtn.tag=23;
    [banjiBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    //[BanJiText addSubview:banjiBtn];
    BanJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(245, 135, 70, 5)];
    BanJiTable.backgroundColor=[UIColor whiteColor];
    BanJiTable.hidden=YES;
    [choiceView addSubview:BanJiTable];
    [choiceView insertSubview:banjiBtn aboveSubview:BanJiText];
    //Classinput
    className=[[UILabel alloc]init];
    className.frame=CGRectMake(13, 140, 70, 30);
    className.textColor=[UIColor grayColor];
    className.font=[UIFont systemFontOfSize:14];
    className.text=@"课程名称:";
    [choiceView addSubview:className];
    //
    ClassInput=[[JYTextField alloc]initWithFrame:CGRectMake(13, 170, 150, 30)
                                     cornerRadio:5
                                     borderColor:RGB(166, 166, 166)
                                     borderWidth:2
                                      lightColor:RGB(243, 168, 51)
                                       lightSize:8
                                lightBorderColor:RGB(235, 235, 235)];

    ClassInput.tag=44;
    ClassInput.borderStyle=UITextBorderStyleNone;
    //ThemeCon.frame=CGRectMake(45, 5, 90, 20);
    ClassInput.textColor=[UIColor blueColor];
    ClassInput.font=[UIFont systemFontOfSize:15];
    ClassInput.placeholder=@"请输入/选择课程";
    ClassInput.clearButtonMode=UITextFieldViewModeNever;
    ClassInput.delegate=self;
    ClassInput.backgroundColor=[UIColor whiteColor];
    [choiceView addSubview:ClassInput];
    kechengBtn=[UIButton buttonWithType:UIButtonTypeContactAdd];
    kechengBtn.tag=24;
    kechengBtn.frame=CGRectMake(134, 170, 30, 30);
    [kechengBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:kechengBtn];
    [choiceView insertSubview:kechengBtn aboveSubview:ClassInput];
    //节数
    SectionLable=[[UILabel alloc]init];
    SectionLable.frame=CGRectMake(175, 140, 70, 30);
    SectionLable.textColor=[UIColor grayColor];
    SectionLable.font=[UIFont systemFontOfSize:14];
    SectionLable.text=@"课程节数:";
    [choiceView addSubview:SectionLable];
    SectionText=[[JYTextField alloc]initWithFrame:CGRectMake(175, 170,70, 30)
                                      cornerRadio:5
                                      borderColor:RGB(166, 166, 166)
                                      borderWidth:2
                                       lightColor:RGB(243, 168, 51)
                                        lightSize:8
                                 lightBorderColor:RGB(235, 235, 235)];
    SectionText.tag=45;
    SectionText.borderStyle=UITextBorderStyleNone;
    SectionText.enabled=NO;
    SectionText.textColor=[UIColor blueColor];
    SectionText.font=[UIFont systemFontOfSize:15];
    SectionText.placeholder=@"节数";
    SectionText.backgroundColor=[UIColor whiteColor];
    [choiceView addSubview:SectionText];
    jieshuBtn=[UIButton buttonWithType:UIButtonTypeContactAdd];
    jieshuBtn.frame=CGRectMake(216, 170, 30, 30);
    jieshuBtn.tag=25;
    [jieshuBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:jieshuBtn];
    [choiceView insertSubview:jieshuBtn aboveSubview:SectionText];
    
    
    
    ConfirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    ConfirmBtn.frame=CGRectMake(choiceView.frame.size.width-60, choiceView.frame.size.height-60, 55, 55);
    ConfirmBtn.backgroundColor=[UIColor clearColor];
    //[conbtn setTitle:@"提交" forState:UIControlStateNormal];
    [ConfirmBtn setImage:[UIImage imageNamed:@"ConfirmBtn.png"] forState:UIControlStateNormal];
    [choiceView addSubview:ConfirmBtn];
    ConfirmBtn.tag=14;
    [ConfirmBtn addTarget:self action:@selector(BtnClickForCaoqin:) forControlEvents:UIControlEventTouchUpInside];

    //首先初始化按钮为不可点击
    xueyuanBtn.enabled=NO;
    nianjiBtn.enabled=NO;
    zhuanyeBtn.enabled=NO;
    banjiBtn.enabled=NO;
    kechengBtn.enabled=NO;
    

}
- (void)shake
{//when themeTextfield is null,it is shaking
	[ClassInput shake:20 withDelta:5
           andSpeed:0.03
     shakeDirection:ShakeDirectionHorizontal];
}
- (void) handleBackgroundTap:(UITapGestureRecognizer*)sender
{
    [ClassInput resignFirstResponder];
}
-(void)keyboardWillShow
{
   
    if (DEVICE_IS_IPHONE5) {
        [UIView animateWithDuration:0.3 animations:^{
        choiceView.frame=CGRectMake(0,150-30, ScreenWidth, 230);
 
    } completion:^(BOOL finished) {
        return ;
    }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            choiceView.frame=CGRectMake(0,60-25, ScreenWidth, 230);
            
        } completion:^(BOOL finished) {
            return ;
        }];
    }

    
}
-(void)keyboardWillHide
{
    [UIView animateWithDuration:0.3 animations:^{
        choiceView.center=grayView.center;

    } completion:^(BOOL finished) {
        return ;
    }];

    
}
#pragma mark--KxmenuClickMethod
- (void) pushMenuItem:(KxMenuItem*)sender
{
    if ([sender.title isEqualToString:@"查看考勤"])
    {//查看考勤
        
    }else if ([sender.title isEqualToString:@"继续点名"])
    {//继续点名
        
        
    }
    else
    {
    }
}
#pragma mark--clickDelegate
-(void)BtnClickForCaoqin:(UIButton *)sender
{/*tag值:20~25分别对应用于班级选择的选项*/
    switch (sender.tag) {
            case 7:
        {
            FastCheck_ViewController *fast=[[FastCheck_ViewController alloc]init];
            fast.title=@"快速查询";
            fast.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:fast animated:YES];
        }
            break;
//     case 9:
//        {//导航栏上显示更多选项的按钮
//            
//            /*change*/
//            NSArray *menuItems=@[[KxMenuItem menuItem:@"查看考勤" image:nil
//                target:self action:@selector(pushMenuItem:)],[KxMenuItem menuItem:@"继续点名" image:nil
//                                                                           target:self action:@selector(pushMenuItem:)],[KxMenuItem menuItem:@"更新点名" image:nil
//                                                                                                                                      target:self action:@selector(pushMenuItem:)]];
//            for (int i=0; i<[menuItems count]; i++)
//            {
//                KxMenuItem *menuitem=menuItems[i];
//                menuitem.foreColor=[UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
//                menuitem.alignment=NSTextAlignmentCenter;
//
//            }
//            [KxMenu showMenuInView:self.view
//                          fromRect:sender.frame
//                         menuItems:menuItems];
//            
//            
//        }
//            break;
//        case 10:
//        {//查看点名后的到勤状态
//            /*change*/
//            HasSignedStudents *test=[[HasSignedStudents alloc]init];
//            test.title=@"点名详情";
//            test.studArr=StudArray;
//            test.statusArray=StudStatus;
//            [self.navigationController pushViewController:test animated:YES];
//            NSLog(@"进行点名查看...");
//        }
//            break;
        case 11:
        {//确定点名的情况
            /*change*/
            NSLog(@"点名确定...");
            //数据加载。。。
            NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserNickName"],@"teacherName",ClassInput.text,@"course",allStudent,@"allStudent",nil];
            NSLog(@"%@",user);
            //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
            NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
            NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLSubmitClasses_CAO]];
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

            right.enabled=YES;
        }
            break;
//        case 12:
//        {//继续点名的按钮
//            NSLog(@"继续点名....");
//            //初始化 导航栏的左右按钮为nil
//            /*change*/
//            [UIView animateWithDuration:0.3 animations:^{
//                StudTable.transform = CGAffineTransformMakeScale(0.2, 0.2);
//                StudTable.alpha = 0.0;
//                tool.transform=CGAffineTransformMakeScale(0.2, 0.2);
//                tool.alpha=0.0;
//            } completion:^(BOOL finished) {
//                //添加新的动画  实现tableview动画显示
//                [StudTable removeFromSuperview];
//                [tool removeFromSuperview];
//                /*change*/
//                self.navigationItem.rightBarButtonItem=nil;
//                self.navigationItem.leftBarButtonItem=nil;
//                [self PoptheViewAllOverScreen];
//                
//            }];
//
//        }
//            break;
        case 13:
        {//当前身份为教师
            isCheck=NO;
            CheckBtn.hidden=YES;
            [self presentChoiceViewForTeachers];
            [self GetRequestForCollegeAndGrades];
            NSLog(@"开始加载选择页面");
        }
            break;
            case 14:
        {//点名  教师身份  需要提交数据到服务器
            if ([XUeyuanText.text isEqualToString:@""]||[NianJiText.text isEqualToString:@""]||[ZhuanYeText.text isEqualToString:@""]||[BanJiText.text isEqualToString:@""]||[ClassInput.text isEqualToString:@""]||[SectionText.text isEqualToString:@""])
            {
                NSMutableArray *countArr=[[NSMutableArray alloc]init];
                for (int i=40; i<46; i++)
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
            {
                SubmitDataLoad=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                SubmitDataLoad.frame=CGRectMake(0, 0, 55, 55);
                [ConfirmBtn addSubview:SubmitDataLoad];
                [SubmitDataLoad startAnimating];
            
                //进行网络请求获得数据
                [self SubmitAllDataForDianMing];

            }

            
        }
            break;
            case 15:
        {//切换身份为  领导和辅导员
            NSLog(@"当前登录者为领导...");
            isCheck=YES;
            [StudTable removeFromSuperview];
            [tool removeFromSuperview];
            CheckBtn.hidden=YES;
            [self presentChoiceViewForLeaders];
            [self GetRequestForCollegeAndGrades];


        }
            break;
            case 20:
        {//学院的选择
            XueyuanTable.hidden=NO;
            if (isOpened)
            {//添加个动画会更好
      
                NianJiText.transform = CGAffineTransformMakeScale(0.3, 0.3);
                nianjiBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                zhuanyeBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                ZhuanYeText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                zhuanyeLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                banjiLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                banjiBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                BanJiText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                SectionLable.transform=CGAffineTransformMakeScale(0.3, 0.3);

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
                    BanJiText.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    BanJiText.alpha=1.0;
                    banjiBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    banjiBtn.alpha=1.0;
                    SectionLable.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    SectionLable.alpha=1.0;
                    
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
                    BanJiText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    BanJiText.alpha=0.0;
                    banjiBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    banjiBtn.alpha=0.0;
                    SectionLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    SectionLable.alpha=0.0;

                }];
                
                
                [UIView animateWithDuration:0.3 animations:^
                {
                    UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
                    [xueyuanBtn setImage:openImage forState:UIControlStateNormal];
                    
                    CGRect frame=XueyuanTable.frame;
                    if (isCheck)
                    {
                         frame.size.height=100;
                    }
                    else
                    {
                         frame.size.height=110;
                    }
                    [XueyuanTable setFrame:frame];
                } completion:^(BOOL finished)
                {
                    
                    isOpened=YES;
                }];
                
                
            }
            if (XUeyuanText.text.length) {
                nianjiBtn.enabled=YES;
            }
            
            /* [XUeyuanText shake:20 withDelta:5
             andSpeed:0.03
             shakeDirection:ShakeDirectionHorizontal];*/
        }
            break;
            case 21:
        {//年级的选择
            NianJiTable.hidden=NO;
            if (isOpened) {
                
                className.transform = CGAffineTransformMakeScale(0.3, 0.3);
                 ClassInput.transform = CGAffineTransformMakeScale(0.3, 0.3);
                 kechengBtn.transform = CGAffineTransformMakeScale(0.3, 0.3);
                
                [UIView animateWithDuration:0.3 animations:^{
                    className.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    className.alpha=1.0;
                    ClassInput.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    ClassInput.alpha=1.0;
                    kechengBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    kechengBtn.alpha=1.0;
                    
                }];
                
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
                    className.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    className.alpha=0.0;
                    ClassInput.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    ClassInput.alpha=0.0;
                    kechengBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    kechengBtn.alpha=0.0;
                    
                }];
                
                [UIView animateWithDuration:0.3 animations:^{
                    UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
                    [nianjiBtn setImage:openImage forState:UIControlStateNormal];
                    
                    CGRect frame=NianJiTable.frame;
                    if (isCheck)
                    {
                        frame.size.height=84;
                    }
                    else
                    {
                        frame.size.height=90;

                    }
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
            case 22:
        {//专业的选择
            ZhuanyeTable.hidden=NO;
            
            if (isOpened)
            {
                ClassInput.transform=CGAffineTransformMakeScale(0.3, 0.3);
                kechengBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                SectionLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                SectionText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                jieshuBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                
                [UIView animateWithDuration:0.3 animations:^{
                    ClassInput.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    ClassInput.alpha=1.0;
                   kechengBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    kechengBtn.alpha=1.0;
                    SectionLable.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    SectionLable.alpha=1.0;
                    SectionText.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    SectionText.alpha=1.0;
                    jieshuBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    jieshuBtn.alpha=1.0;
                    
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
                    ClassInput.transform = CGAffineTransformMakeScale(0.3, 0.3);
                    ClassInput.alpha=0.0;
                    kechengBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    kechengBtn.alpha=0.0;
                    SectionLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    SectionLable.alpha=0.0;
                    SectionText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    SectionText.alpha=0.0;
                    jieshuBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    jieshuBtn.alpha=0.0;
                    
                }];
                
                [UIView animateWithDuration:0.3 animations:^{
                    UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
                    [zhuanyeBtn setImage:openImage forState:UIControlStateNormal];
                    
                    CGRect frame=ZhuanyeTable.frame;
                    if (isCheck)
                    {
                        frame.size.height=84;

                    }
                    else
                    {
                        frame.size.height=90;

                    }
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
            case 23:
        {//班级的选择
            BanJiTable.hidden=NO;
            if (isOpened)
            {
                SectionLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                SectionText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                jieshuBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                ConfirmBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                [UIView animateWithDuration:0.3 animations:^{
                    SectionLable.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    SectionLable.alpha=1.0;
                    SectionText.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    SectionText.alpha=1.0;
                    jieshuBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    jieshuBtn.alpha=1.0;
                    ConfirmBtn.transform=CGAffineTransformMakeScale(1.0, 1.0);
                    ConfirmBtn.alpha=1.0;
                    
                }];
                
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
                    
                    ConfirmBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    ConfirmBtn.alpha=0.0;
                    SectionLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    SectionLable.alpha=0.0;
                    SectionText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    SectionText.alpha=0.0;
                    jieshuBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                    jieshuBtn.alpha=0.0;
                    
                }];

                
                [UIView animateWithDuration:0.3 animations:^{
                    UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
                    [banjiBtn setImage:openImage forState:UIControlStateNormal];
                    
                    CGRect frame=BanJiTable.frame;
                    if (isCheck)
                    {
                        frame.size.height=84;
                        
                    }
                    else
                    {
                        frame.size.height=90;
                        
                    }
                    [BanJiTable setFrame:frame];
                } completion:^(BOOL finished){
                    
                    isOpened=YES;
                }];
                
                
            }
            if (BanJiText.text.length) {
                Lessonsload=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                Lessonsload.frame=CGRectMake(0, 0, 30, 30);
                [kechengBtn addSubview:Lessonsload];
                [Lessonsload startAnimating];
                [self GetRequestForLessons];
            }

        }
            break;
            case 24:
        {//课程的选择
           // LessonArr=[[NSArray alloc] initWithObjects:@"计算机组成原理",@"高频电子线路",@"信号与线性系统",@"大学英语", nil];
            row=0;
            [Dropobj fadeOut];
            [self showPopUpWithTitle:@"选择课程:" withOption:LessonArr xy:CGPointMake(16, 150) size:CGSizeMake(287, 280) isMultiple:NO];

        }
            break;
            case 25:
        {//节数的选择
            SectionArr=[NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
            [self showPopUpWithTitle:@"选择节数:" withOption:SectionArr xy:CGPointMake(16, 150) size:CGSizeMake(287, 280) isMultiple:YES];

        }
            break;
            case 30:
        {//出现日历
            self.pmCC = [[PMCalendarController alloc] initWithThemeName:@"default"];
            pmCC.delegate = self;
            pmCC.mondayFirstDayOfWeek = NO;
            [pmCC presentCalendarFromView:sender
                 permittedArrowDirections:PMCalendarArrowDirectionAny
                                 animated:YES];
            [self calendarController:pmCC didChangePeriod:pmCC.period];
            

        }
            break;
            case 31:
        {
            
        }
            break;
            case 32:
        {
        }
            break;
            case 33:
        {
            if ([XUeyuanText.text isEqualToString:@""]||[NianJiText.text isEqualToString:@""]||[ZhuanYeText.text isEqualToString:@""]||[BanJiText.text isEqualToString:@""]||[ClassInput.text isEqualToString:@""]||[SectionText.text isEqualToString:@""]||[dateInput.text isEqualToString:@""]) {
                NSMutableArray *countArr=[[NSMutableArray alloc]init];
                for (int i=40; i<47; i++)
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
            {
                SubmitDataLoad=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                SubmitDataLoad.frame=CGRectMake(0, 0, 55, 55);
                [ConfirmBtn addSubview:SubmitDataLoad];
                [SubmitDataLoad startAnimating];
                
                //进行网络请求获得数据
                [self GetRequestClassmatsCheckedByLeaders];
                
            }
            

            NSLog(@"领导辅导员身份登录");
        }
            break;
            case 34:
        {//取消选择后的操作
            /*change*/
            //self.navigationController.navigationBar.hidden=NO;
            [UIView animateWithDuration:0.3 animations:^{
                choiceView.transform=CGAffineTransformMakeScale(0.3, 0.3);
                choiceView.alpha=0.2;
                
                
            } completion:^(BOOL finished)
            {
                [choiceView removeFromSuperview];
                [self PoptheViewAllOverScreen];
            }];

                   }
            break;
            case 35:
        {//获得学院和年级
            [self GetRequestForCollegeAndGrades];
        }
            break;
            case 36:
        {
            [self.navigationController popViewControllerAnimated:YES];
            /*change*/
           // self.navigationController.navigationBarHidden=NO;
        }
            break;
        case 37:{
            row=2;
            allNumb =[[NSArray alloc] init];
            allNumb=[NSArray arrayWithObjects:@"旷课",@"迟到",@"请假", @"正常",nil];
            [self showPopUpWithTitle:@"现在的状态:" withOption:allNumb xy:CGPointMake(16, 150) size:CGSizeMake(287, 280) isMultiple:NO];
        }
            break;
        case 38:{
            row=1;
            allold =[[NSArray alloc] init];
            allold=[NSArray arrayWithObjects:@"旷课",@"迟到",@"请假", nil];
            [self showPopUpWithTitle:@"以前的状态:" withOption:allold xy:CGPointMake(16, 150) size:CGSizeMake(287, 280) isMultiple:NO];
        }
            break;
        default:
            break;
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#pragma mark KDropListViewDelegate methods lessons
-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple{
    
    
    Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    Dropobj.delegate = self;
    [Dropobj showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [Dropobj SetBackGroundDropDwon_R:0.0 G:108.0 B:194.0 alpha:0.70];
    
}
- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex{//单选
    /*----------------Get Selected Value[Single selection]-----------------*/
    if (row==1) {
        Update_oldStudyStatus.text=[allold objectAtIndex:anIndex];

    }
    if (row==2) {
        Update_studyStatus.text=[allNumb objectAtIndex:anIndex];
    }
    
    if (row==0) {
           ClassInput.text=[LessonArr objectAtIndex:anIndex];
    }
 
   }
- (void)DropDownListView:(DropDownListView *)dropdownListView Datalist:(NSMutableArray*)ArryData{//多选
    
    /*----------------Get Selected Value[Multiple selection]-----------------*/
    NSMutableString *str=[NSMutableString stringWithFormat:@""];
    for (int i=0; i<[ArryData count]; i++) {
        [str appendFormat:@"%@",[ArryData objectAtIndex:i]];
    }
    SectionText.text=str;
    Update_Classtime.text=str;
    NSLog(@"%@",SectionText.text);
    NSLog(@"多选＝＝＝%@",ArryData);
    
}
- (void)DropDownListViewDidCancel{
    
}


#pragma mark PMCalendarControllerDelegate methods

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    dateInput.text = [NSString stringWithFormat:@"%@ "
                        , [newPeriod.startDate dateStringWithFormat:@"yyyy-MM-dd"]
                        ];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [CAll_StuName count];
}
-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StudCellIdentifier = @"StudCell";
    studentcell = [tableView dequeueReusableCellWithIdentifier:StudCellIdentifier];
    /*存在bug  需要重新设计算法*/
    if (studentcell.isSign&&studentcell.isOff&&studentcell.isAbsent){
        studentcell.isSign=NO;
        studentcell.isOff=NO;
        studentcell.isAbsent=NO;
    
    }
        //当cell复用的时候，需要重新定义，以便于后面列表重新显示

    if (studentcell == nil) {
        studentcell = [[StudCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:StudCellIdentifier];
            studentcell.delegate=self;
    }
  
    NSLog(@"%@",[CAll_headSculpture objectAtIndex:indexPath.row]);
     NSString *touxiang_URL=[CAll_headSculpture objectAtIndex:indexPath.row];
    if (![touxiang_URL isKindOfClass:[NSNull class]]) {
       /*
        [avaterImageView setImageURL:touxiang_URL];
        [StudTable addSubview:avaterImageView];*/
        [studentcell.paimageview setImageURL:touxiang_URL];
        studentcell.imageView.image=[UIImage  imageNamed:@"11.png"];
    }else{
              studentcell.imageView.image=[UIImage  imageNamed:@"11.png"];
    }
    studentcell.detailTextLabel.text=[CAll_StuNumber objectAtIndex:indexPath.row];
    studentcell.textLabel.text=[CAll_StuName objectAtIndex:indexPath.row];
    NSLog(@"isOff==%hhd,isSign==%hhd,isAbsent==%hhd",studentcell.isOff,studentcell.isSign,studentcell.isAbsent);
    @try {
    if ([StudArray containsObject:studentcell.detailTextLabel.text]) {
   // StudStatus
        
        if ([StudStatus[indexPath.row] isEqualToString:@"请假"]) {
            [studentcell.OffBtn setTitle:@"✅" forState:UIControlStateNormal];
            studentcell.isOff=YES;
        }else if([StudStatus[indexPath.row] isEqualToString:@"迟到"]){
            [studentcell.LateBtn setTitle:@"✅" forState:UIControlStateNormal];
            studentcell.isSign=YES;
        }else{
            [studentcell.AbsentBtn setTitle:@"✅" forState:UIControlStateNormal];
            studentcell.isAbsent=YES;

        }
     
    }else{
   
        if(studentcell.isOff&&studentcell.isSign==NO&&studentcell.isAbsent==NO){
        [studentcell.OffBtn setTitle:@"请假" forState:UIControlStateNormal];
            studentcell.isOff=NO;
        }
        if(studentcell.isSign&&studentcell.isOff==NO&&studentcell.isAbsent==NO){
        [studentcell.LateBtn setTitle:@"迟到" forState:UIControlStateNormal];
        studentcell.isSign=NO;
        }
        if(studentcell.isAbsent&&studentcell.isSign==NO&&studentcell.isOff==NO){
        [studentcell.AbsentBtn setTitle:@"旷课" forState:UIControlStateNormal];
             studentcell.isAbsent=NO;
        }
        
       
    }
}
    @catch (NSException *exception) {
       // UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"Leaders失败==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alert show];
        studentcell.isSign=NO;
        studentcell.isOff=NO;
        studentcell.isAbsent=NO;
        NSLog(@"Leaders失败==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"Leaders信息");
    }

        return studentcell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cliclAtRow:%d,status:",indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
}
#pragma mark-studcell For buttonClickDelegate
-(void)ClickTheStatusBtnFrom:(StudCell *)sCell withTheStus:(NSString*)Status
{
    
    if ([Status isEqualToString:@"每位同学只能一个到勤状态"]) {
        [self.view makeToast:@"每位同学只能有一个到勤状态"];
    }else{
        if ([Status isEqualToString:@"旷课"]||[Status isEqualToString:@"请假"]||[Status isEqualToString:@"迟到"]) {
            count++;
          
            /*change*/
           // NumYindao.text=@"50";
            NumShidao.text=[NSString stringWithFormat:@"%d",count];
        }else if ([Status isEqualToString:@"取消旷课"]||[Status isEqualToString:@"取消请假"]||[Status isEqualToString:@"取消迟到"]){
            count--;
            NumShidao.text=[NSString stringWithFormat:@"%d",count];
        }
        [StudArray addObject:sCell.detailTextLabel.text];
        [StudStatus addObject:Status];
           [self MethodForToolBar];
        [self.view makeToast:[NSString stringWithFormat:@"%@同学现在\n    已%@",sCell.textLabel.text,Status]];
        
        zhuangtai=Status;
    }
    if ([zhuangtai isEqualToString:@"取消旷课"]||[zhuangtai isEqualToString:@"取消请假"]||[zhuangtai isEqualToString:@"取消迟到"]){
        [allStudent removeObjectForKey:sCell.detailTextLabel.text];
    }else{
        NSDictionary *namestudent  =[[NSDictionary alloc] initWithObjectsAndKeys:sCell.detailTextLabel.text,@"studentNumber",zhuangtai,@"status",SectionText.text,@"classTime",nil];
        
        [allStudent setObject:namestudent forKey:sCell.detailTextLabel.text];
        
        
    }
        //[student setDictionary:allstudent];
    NSLog(@"%@",allStudent);
    NSLog(@"学生＝＝＝%@",StudArray);
}
#pragma mark-ScrollViewDelegate
// scrollView 开始拖动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView

{
    /*change*/
    //self.navigationController.navigationBarHidden=YES;
    //tool.hidden=YES;
    NSLog(@"scrollViewWillBeginDragging");
  
}

// scrollView 结束拖动
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate

{
    
    NSLog(@"scrollViewDidEndDragging");
    
}
// scrollview 减速停止

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{//重新显示toolbar需要添加动画
    //tool.hidden=NO;
    /*change*/
    //self.navigationController.navigationBarHidden=NO;
    NSLog(@"scrollViewDidEndDecelerating");
 
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{//隐藏键盘的方法
    [Update_studentNum resignFirstResponder];
    [Update_Classtime resignFirstResponder];
    [Update_oldStudyStatus resignFirstResponder];
    [Update_studyStatus resignFirstResponder];
	[self.view.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[UITextField class]]||[obj isKindOfClass:[UITextView class]]) {
			[obj resignFirstResponder];
		}
	}];
    UITouch *touch = [touches anyObject];
    
    if ([touch.view isKindOfClass:[UIView class]]) {
        [Dropobj fadeOut];
    }

}
//提交
-(void)RequestForCollegeAndGrades
{//获得  学院  和  年级
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetGradeAndColleges_CAO]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForCollegeAndGrade:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForCollegeAndGrade:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailed:(ASIHTTPRequest *)request{
    //[etactivity stopAAnimating];
    //if (request)
    //{}
    
    NSError *error = [request error];
    [self.view makeToast:Request_TimeOut];
    //[etactivity stopAnimating];
    NSLog(@"the error is %@",error);
    self.view.userInteractionEnabled=YES;
}
//网络请求成功
- (void)ASIHttpRequestSuceed:(ASIHTTPRequest *)request{
     [CollegeLoad stopAnimating];
    NSData *responseData = [request responseData];
    JsonCollegeAndGrades=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders Three 解析＝%@",JsonCollegeAndGrades);
    NSString *Alert=[JsonCollegeAndGrades valueForKey:@"Status"];
    @try {
        if ([JsonCollegeAndGrades count])
        {
            if ([Alert isEqualToString:@"Success"]) {
                
                UIAlertView *AlerVIew=[[UIAlertView alloc] initWithTitle:nil message:@"发送成功" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [AlerVIew show];
            }else{
                UIAlertView *AlerVIew=[[UIAlertView alloc] initWithTitle:nil message:@"发送失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [AlerVIew show];
            }
        }
        else
        {
            UIAlertView *AlerVIew=[[UIAlertView alloc] initWithTitle:nil message:@"数据返回为空\n请重新操作" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [AlerVIew show];
            
            
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"数据返回为空==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"数据返回为空==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"数据返回");
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)tabImageName
{
	return @"kaoqin_tabbar_icon.png";
}

- (NSString *)tabTitle
{
	return self.title=@"考勤中心";
    
}

@end
