//
//  Map_PersonInfo.m
//  地图模块
//
//  Created by kys-2 on 14-5-29.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "Map_PersonInfo.h"
#import "SJAvatarBrowser.h"
#import "AFNetworking.h"
#import "PAImageView.h"
#import "S_InfoCell.h"

#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"

#import "Defines.h"
#import "Toast+UIView.h"
@interface Map_PersonInfo ()

@end

@implementation Map_PersonInfo
@synthesize InfoBackground;
@synthesize Map_InfoNickName,Map_InfoName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma  mark------请求获取个人信息位于地图模块
-(void)Map_GetInfomationFromURL
{
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:Map_InfoNickName, @"userNickname",@"Role_Student",@"role", nil];
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
    Map_Jsons=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    
    Map_ClassInfo=[[NSMutableArray alloc]init];
    Map_InfoArrayNumber=[[NSMutableArray alloc]init];
    
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",Map_Jsons);
    @try {
    if ([Map_Jsons count])
    {
        touxiao=[Map_Jsons valueForKey:@"studentImageURL"];        [Map_InfoArrayNumber addObject:[Map_Jsons valueForKey:@"studentNumber"]];
        [Map_InfoArrayNumber addObject:[Map_Jsons valueForKey:@"phone"]];
        [Map_InfoArrayNumber addObject:[Map_Jsons valueForKey:@"cardId"]];

        ////
        [Map_ClassInfo addObject:[Map_Jsons valueForKey:@"grade"]];
        [Map_ClassInfo addObject:[Map_Jsons valueForKey:@"profession"]];
        [Map_ClassInfo addObject:[NSString stringWithFormat:@"%@班",[Map_Jsons valueForKey:@"class"]]];
        [avaterImageView setImageURL:touxiao];
        [InfoTable reloadData];//重新刷新数据
    }
    else
    {
        [self.view makeToast:@"获取数据失败"];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"班级信息==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"班级信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"班级信息");
    }
}
-(void)initBackGroundForInfo
{
    //进行请求
    [self Map_GetInfomationFromURL];
    //头像后面的背景
    InfoBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 64,ScreenWidth , 180)];
    InfoBackground.backgroundColor=[UIColor clearColor];
    InfoBackground.image=[UIImage imageNamed:@"Map_backimg.jpeg"];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(EnlargeBackgroundImg)];
    InfoBackground.userInteractionEnabled=YES;
        //[InfoBackground addSubview:avaterImageView];
    
    [InfoBackground addGestureRecognizer:tap];
    [self.view addSubview:InfoBackground];
    //添加头像
    CGFloat imageSize=75.f;
    avaterImageView = [[PAImageView alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (InfoBackground.frame.size.height-imageSize)/2+48, imageSize, imageSize) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
    [avaterImageView setImageURL:touxiao];
    [self.view insertSubview:avaterImageView aboveSubview:InfoBackground];
    NSLog(@"%f--%f",avaterImageView.frame.origin.x,avaterImageView.frame.origin.y);
    //学生姓名
    UILabel *Sname=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (InfoBackground.frame.size.height-imageSize)/2+imageSize-4, imageSize, 25)];
    Sname.backgroundColor=[UIColor clearColor];
    Sname.textColor=[UIColor colorWithWhite:255 alpha:1.0];//设置姓名的颜色为铬黄
    Sname.font=[UIFont fontWithName:@"Helvetica" size:15];
    Sname.text=Map_InfoName;
    Sname.textAlignment=NSTextAlignmentCenter;
    [InfoBackground addSubview:Sname];
    //学生昵称
    UILabel *Snickname=[[UILabel alloc]initWithFrame:CGRectMake(Sname.frame.origin.x, Sname.frame.origin.y+Sname.frame.size.height, imageSize, Sname.frame.size.height)];
    Snickname.backgroundColor=[UIColor clearColor];
    Snickname.font=[UIFont fontWithName:@"Helvetica" size:10];
    Snickname.textColor=[UIColor colorWithRed:255 green:128 blue:0 alpha:1.0];
    Snickname.text=Map_InfoNickName;
    Snickname.textAlignment=NSTextAlignmentCenter;
    //[Snickname sizeToFit];
    [InfoBackground addSubview:Snickname];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:YES ];
    self.view.backgroundColor=[UIColor lightGrayColor];
    [self initBackGroundForInfo];//加载头像和背景图片
  
    //返回按钮
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(0, 0, 32, 32);
    [back setImage:[UIImage imageNamed:@"map_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left_btn=[[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem=left_btn;
    //创建详细信息的列表
    InfoTable=[[UITableView alloc]initWithFrame:CGRectMake(0, InfoBackground.frame.size.height+64, ScreenWidth, ScreenHeight-InfoBackground.frame.size.height-64) style:UITableViewStyleGrouped];
    InfoTable.backgroundColor=[UIColor clearColor];
    InfoTable.dataSource=self;
    InfoTable.delegate=self;
    [self.view addSubview:InfoTable];
    
}
-(void)back
{
     [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)EnlargeBackgroundImg
{
    [SJAvatarBrowser showImage:InfoBackground];

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
        return 3;
    }
    else
    {
        return 3;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    S_InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[S_InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle=UITableViewCellSeparatorStyleSingleLine;
        [cell.layer setCornerRadius:8.0];
        cell.userInteractionEnabled=NO;
        cell.alpha=0.8;
    }
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica" size:15];
    cell.textLabel.textColor=[UIColor lightGrayColor];
    if (indexPath.section==0)
    {
        cell.InfoLael.textAlignment=NSTextAlignmentLeft;
        cell.InfoLael.font=[UIFont fontWithName:@"Helvetica" size:18];
        cell.InfoLael.text=@"     基本信息";
    }else if (indexPath.section==1)
    {
        NSArray *arr1=[NSArray arrayWithObjects:@"学号",@"手机号",@"身份证号", nil];
        //NSArray *arr2=[NSArray arrayWithObjects:@"201742247",@"15369302556",@"130986199603421562", nil];
        cell.textLabel.text=[arr1 objectAtIndex:indexPath.row];
        cell.InfoLael.text=[Map_InfoArrayNumber objectAtIndex:indexPath.row];
    }else
    {
        NSArray *arr3=[NSArray arrayWithObjects:@"年级",@"专业",@"班级", nil];
         //NSArray *arr4=[NSArray arrayWithObjects:@"2012",@"电子信息工程",@"三班", nil];
        cell.textLabel.text=[arr3 objectAtIndex:indexPath.row];
        cell.InfoLael.text=[Map_ClassInfo objectAtIndex:indexPath.row];
    }
    return cell;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
