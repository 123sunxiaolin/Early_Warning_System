//
//  FastCheck_ViewController.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-6-5.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "FastCheck_ViewController.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "Defines.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "Toast+UIView.h"
#import "FastCheckCell.h"
#import "FastCheck_Detail.h"

@interface FastCheck_ViewController ()

@end

@implementation FastCheck_ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark----领导请求
-(void)getRequsetForCollegesByLeaders
{
    [SVProgressHUD showWithStatus:@"正在更新数据"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,ASSISTANTfirst]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForLeader:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForLeader:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startAsynchronous];//开启同步请求
    self.view.userInteractionEnabled=NO;
}
- (void)ASIHttpRequestFailedForLeader:(ASIHTTPRequest *)request
{
    self.view.userInteractionEnabled=YES;
    //[self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    [SVProgressHUD showErrorWithStatus:@"更新数据失败"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
    
}
- (void)ASIHttpRequestSuceedForLeader:(ASIHTTPRequest *)request
{
    self.view.userInteractionEnabled=YES;
    [SVProgressHUD showSuccessWithStatus:@"更新数据成功!"];
    NSData *responseData = [request responseData];
    JsonNameList=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders 解析＝%@",JsonNameList);
    @try {
    if ([[JsonNameList valueForKey:@"college"] count])
    {
        popArray=[JsonNameList valueForKey:@"college"];
        [self popClickAction];
    }else
    {
        [self.view makeToast:@"加载数据失败"];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"加载数据失败==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"加载数据失败==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"加载数据");
    }

}
#pragma mark---领导第二次请求
-(void)GetRequestTwiceByLeaders
{
    [SVProgressHUD showWithStatus:@"正在更新数据"];
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:collegenStr,@"collegeName",@"20",@"pageSize",@"1",@"currentPage", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,CaoQinUrlLeader]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForLeaderTwice:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForLeaderTwice:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求


}
- (void)ASIHttpRequestFailedForLeaderTwice:(ASIHTTPRequest *)request
{
    self.view.userInteractionEnabled=YES;
    //[self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    [SVProgressHUD showErrorWithStatus:@"更新数据失败"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
    
}
- (void)ASIHttpRequestSuceedForLeaderTwice:(ASIHTTPRequest *)request
{
    self.view.userInteractionEnabled=YES;
    [SVProgressHUD showSuccessWithStatus:@"更新数据成功!"];
    NSData *responseData = [request responseData];
    JsonTwiceleader=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders11 解析＝%@",JsonTwiceleader);
    Status_picture=[[NSMutableArray alloc] init];
    dataArray=[[NSMutableArray alloc]init];
    StudentNum=[[NSMutableArray alloc]init];
    StatusNum=[[NSMutableArray alloc]init];
    @try {
    if ([[JsonTwiceleader valueForKey:@"callOverCountUtilList"] count])
    {
        for (int i=0; i<[[JsonTwiceleader valueForKey:@"callOverCountUtilList"] count]; i++)
        {
            //学生头像
            [Status_picture addObject:[[[JsonTwiceleader valueForKey:@"callOverCountUtilList"] objectAtIndex:i] valueForKey:@"studentImageUrl"]];
            //学生姓名
            [dataArray addObject:[[[JsonTwiceleader valueForKey:@"callOverCountUtilList"] objectAtIndex:i] valueForKey:@"studentName"]];
            //学生学号
            [StudentNum addObject:[[[JsonTwiceleader valueForKey:@"callOverCountUtilList"] objectAtIndex:i] valueForKey:@"studentNumber"]];
            //学生缺课次数
            [StatusNum addObject:[[[JsonTwiceleader valueForKey:@"callOverCountUtilList"] objectAtIndex:i] valueForKey:@"statusNum"]];
            
        }
        //[self initTheTableView];//加载tableView
        tableview.hidden=NO;
        [tableview reloadData];
    }
    else
    {
        [self.view makeToast:@"加载数据失败！"];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"考勤==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"考勤==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"考勤");
    }

}

#pragma mark----辅导员请求----获得辅导员管辖的班级
-(void)RequestForClassesByHeadTeachers
{
    [SVProgressHUD showWithStatus:@"正在更新数据"];
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults]objectForKey:@"UserNickName"],@"headTeacherNickname", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetClassesManagedByHeadteacher]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailedForHeadTeachersOne:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceedForHeadTeachersOne:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
}
- (void)ASIHttpRequestFailedForHeadTeachersOne:(ASIHTTPRequest *)request
{
    [SVProgressHUD showErrorWithStatus:@"更新数据失败"];
   // [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForHeadTeachersOne:(ASIHTTPRequest *)request
{
    [SVProgressHUD showSuccessWithStatus:@"更新数据成功!"];
     NSData *responseData = [request responseData];
    jsonOnceHeadTeacher=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    ClassManaged=[[NSMutableArray alloc]init];
    gradeIDArr=[[NSMutableArray alloc]init];
    //得到解析的数据
    NSLog(@"jsonFor HeadTeachers 解析＝%@",jsonOnceHeadTeacher);
    @try {
    if ([jsonOnceHeadTeacher count])
    {
        if ([[jsonOnceHeadTeacher valueForKey:@"Status"] isEqualToString:@"cannotAnalyzeData"])
        {
            [self.view makeToast:@"解析数据错误\n请重试"];
        }
        else if([[jsonOnceHeadTeacher valueForKey:@"Status"] isEqualToString:@"Fail"])
        {
            [self.view makeToast:@"获得数据失败"];
        }
        else
        {//进行数据解析  组合
            for (int i=0; i<[[jsonOnceHeadTeacher valueForKey:@"grade"] count]; i++) {
                NSDictionary *info=[[NSDictionary alloc]init];
                info=[[jsonOnceHeadTeacher valueForKey:@"grade"] objectForKey:[NSString stringWithFormat:@"%d",i]];
                NSString *grade=[info valueForKey:@"grade"];
                NSString *zhuanye=[info valueForKey:@"profession"];
                NSString *class=[info valueForKey:@"classID"];
                NSString * OneInfo=[NSString stringWithFormat:@"%@%@%@",grade,zhuanye,class];
                [gradeIDArr addObject:[info
                                       valueForKey:@"gradeID"]];
                [ClassManaged addObject:OneInfo];
            }
            popArray=[NSArray arrayWithArray:ClassManaged];
            [self popClickAction];
 
        }
    }else
    {
        [self.view makeToast:@"无数据返回"];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"辅导员==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"辅导员==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"辅导员");
    }
}
#pragma mark------------辅导员第二次请求
-(void)RequestTwiceByHeadTeacher
{
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:Selected_Class,@"gradeID", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,CaoQin_HeadTeacher]];
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
    [poplistview dismiss];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForHeadTeachersTwo:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    JsonTwiceHeadTeacher=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor HeadTeachers 解析＝%@",JsonTwiceHeadTeacher);
    Status_picture=[[NSMutableArray alloc] init];
    dataArray=[[NSMutableArray alloc]init];
    StudentNum=[[NSMutableArray alloc]init];
    StatusNum=[[NSMutableArray alloc]init];
    @try {
    if ([[JsonTwiceHeadTeacher valueForKey:@"callOverCountUtilList"] count])
    {
        for (int i=0; i<[[JsonTwiceHeadTeacher valueForKey:@"callOverCountUtilList"] count]; i++)
        {
            //学生的头像
            [Status_picture addObject:[[[JsonTwiceHeadTeacher valueForKey:@"callOverCountUtilList"] objectAtIndex:i] valueForKey:@"studentImageUrl"]];
            //学生姓名
            [dataArray addObject:[[[JsonTwiceHeadTeacher valueForKey:@"callOverCountUtilList"] objectAtIndex:i] valueForKey:@"studentName"]];
            //学生学号
            [StudentNum addObject:[[[JsonTwiceHeadTeacher valueForKey:@"callOverCountUtilList"] objectAtIndex:i] valueForKey:@"studentNumber"]];
            //学生缺课次数
            [StatusNum addObject:[[[JsonTwiceHeadTeacher valueForKey:@"callOverCountUtilList"] objectAtIndex:i] valueForKey:@"statusNum"]];
            
        }
        //[self initTheTableView];//加载tableView
        tableview.hidden=NO;
        [tableview reloadData];
    }
    else
    {
        [self.view makeToast:@"加载数据失败！"];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"考勤==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"考勤==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"考勤");
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //验证身份
    [self ChooseID];
    [self initTheTableView];
    self.view.backgroundColor=[UIColor whiteColor];
    UIBarButtonItem *right=[[UIBarButtonItem alloc]initWithTitle:@"查询" style:UIBarButtonItemStyleBordered target:self action:@selector(ForButtonPressed)];
    self.navigationItem.rightBarButtonItem=right;
    
}
-(void)ForButtonPressed
{
    NSLog(@"123");
    [self ChooseID];
}
#pragma mark----登录身份判断
-(void)ChooseID
{
    //网络请求
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"辅导员"])
    {//辅导员登录
        [self RequestForClassesByHeadTeachers];
    }else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"领导"])
    {//领导登录
        [self getRequsetForCollegesByLeaders];
    }
    

}
#pragma mark--------加载显示tableView
-(void)initTheTableView
{
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder:@"搜索学生"];
    
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];
    searchDisplayController.active = NO;
    searchDisplayController.delegate=self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    tableview=[[UITableView alloc]initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeight)];
    tableview.backgroundColor=[UIColor whiteColor];
    tableview.dataSource = self;
    tableview.delegate = self;
    tableview.tableHeaderView = mySearchBar;
    [self.view addSubview:tableview];
    
   //dataArray = [@[@"百度",@"六六",@"谷歌",@"苹果",@"and",@"table",@"view",@"and",@"and",@"苹果IOS",@"谷歌android",@"微软",@"微软WP",@"table",@"table",@"table",@"六六",@"六六",@"六六",@"table",@"table",@"table"]mutableCopy];
    
    tableview.hidden=YES;
}
- (void)popClickAction
{//弹出的列表  用于领导进入根据学院查询辅导员／用于辅导员进入选择管辖的班级
    
    CGFloat xWidth = self.view.bounds.size.width - 20.0f;
    CGFloat yHeight = 272.0f;
    CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
    NSLog(@"ddddd=%f",yOffset);
    poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate =self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = YES;
    [poplistview setTitle:@"请选择班级"];
    [poplistview show];
    //DataArray=[[NSArray alloc]initWithObjects:@"基础医学院",@"法政学院",@"医学检验学院",@"药学院",@"文学院",@"中医学院",@"理学院",@"信息科学与工程学院",@"艺术学院",@"外国语学院",@"农林科技学院",@"动物科技学院",@"经济管理学院", nil];
    //DataArray=[[NSArray alloc]initWithObjects:@"电子信息工程1班",@"电子信息工程2班",@"电子信息工程3班",@"信息工程1班",@"信息工程2班", nil];
    
}


#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier] ;
    cell.textLabel.text=[popArray objectAtIndex:indexPath.row];
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

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    return [popArray count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%@",[popArray objectAtIndex:indexPath.row]);
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"辅导员"])
    {//辅导员登录
        Selected_Class=[NSString stringWithFormat:@"%@",[gradeIDArr objectAtIndex:indexPath.row]];
        [popoverListView dismiss];
        [self RequestTwiceByHeadTeacher];
    }
    else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"领导"])
    {//领导登录
        collegenStr=[NSString stringWithFormat:@"%@",[popArray objectAtIndex:indexPath.row]];
        [popoverListView dismiss];
        [self GetRequestTwiceByLeaders];

    }

   }

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#pragma mark----UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    }
    else {
        return dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    FastCheckCell *cell = (FastCheckCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
        cell = [[FastCheckCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    NSString *touxiang_URL=[Status_picture objectAtIndex:indexPath.row];
    if (![touxiang_URL isKindOfClass:[NSNull class]]) {
        /*
         [avaterImageView setImageURL:touxiang_URL];
         [StudTable addSubview:avaterImageView];*/
        [cell.paimageview setImageURL:touxiang_URL];
        cell.imageView.image=[UIImage  imageNamed:@"11.png"];
    }else{
        cell.imageView.image=[UIImage  imageNamed:@"11.png"];
    }

            
    cell.imageView.image=[UIImage imageNamed:@"11"];
    cell.detailTextLabel.text=[StudentNum objectAtIndex:indexPath.row];
    NSString *countNum=[NSString stringWithFormat:@"%@",[StatusNum objectAtIndex:indexPath.row]];
    cell.AbsentCount.text=[NSString stringWithFormat:@"🔔旷课:%@次",countNum];

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = searchResults[indexPath.row];
    }
    else {
        cell.textLabel.text = dataArray[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FastCheck_Detail *detail=[[FastCheck_Detail alloc]init];
    NSString *name=[dataArray objectAtIndex:indexPath.row];
    detail.URL_picture=[Status_picture objectAtIndex:indexPath.row];
    detail.S_Name=name;
    detail.title=@"缺勤详情";
    detail.S_Num=[NSString stringWithFormat:@"%@",[StudentNum objectAtIndex:indexPath.row]];
    [self.tabBarController.tabBar setHidden:YES];
    detail.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:detail animated:YES];
   
}

#pragma mark-----UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchResults = [[NSMutableArray alloc]init];
    if (mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
        for (int i=0; i<dataArray.count; i++) {
            if ([ChineseInclude isIncludeChineseInString:dataArray[i]]) {
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:dataArray[i]];
                NSRange titleResult=[tempPinYinStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:dataArray[i]];
                }
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:dataArray[i]];
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0) {
                    [searchResults addObject:dataArray[i]];
                }
            }
            else {
                NSRange titleResult=[dataArray[i] rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:dataArray[i]];
                }
            }
        }
    } else if (mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:mySearchBar.text]) {
        for (NSString *tempStr in dataArray) {
            NSRange titleResult=[tempStr rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [searchResults addObject:tempStr];
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.frame = CGRectMake(-320, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
