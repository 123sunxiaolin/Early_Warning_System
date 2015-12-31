//
//  FastCheck_Detail.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-6-8.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "FastCheck_Detail.h"
#import "Defines.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "Toast+UIView.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "FastCheck_DetailCell.h"

#import "SJAvatarBrowser.h"
#import "AFNetworking.h"
#import "PAImageView.h"


@interface FastCheck_Detail ()

@end

@implementation FastCheck_Detail
@synthesize S_Num,CenterBackground,S_Name;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark---------请求获得学生的缺课详情
-(void)RequestForDetailInfo
{
    [SVProgressHUD showWithStatus:@"正在更新数据"];
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:S_Num,@"studentNumber", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,CaoQin_DetailURl]];
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
    [SVProgressHUD showErrorWithStatus:@"更新数据失败"];
    // [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForDetail:(ASIHTTPRequest *)request
{
    [SVProgressHUD showSuccessWithStatus:@"更新数据成功!"];
    NSData *responseData = [request responseData];
    JsonDeatail=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    ClassNameArray=[[NSMutableArray alloc]init];
    CalendarArray=[[NSMutableArray alloc]init];
    TeacherNameArray=[[NSMutableArray alloc]init];
    YearArray=[[NSMutableArray alloc] init];
    MonthArray=[[NSMutableArray alloc] init];
    DayArray=[[NSMutableArray alloc]init];
        //得到解析的数据
    NSLog(@"jsonFor DetailInfo 解析＝%@",JsonDeatail);
    @try {
    if ([JsonDeatail count])
    {
        if ([[JsonDeatail valueForKey:@"Status"] isEqualToString:@"cannotAnalyzeData"])
        {
            [self.view makeToast:@"解析数据错误\n请重试"];
        }
        else if([[JsonDeatail valueForKey:@"Status"] isEqualToString:@"Fail"])
        {
            [self.view makeToast:@"获得数据失败"];
        }
        else
        {//进行数据解析  组合
            for (int i=[[JsonDeatail valueForKey:@"callOver"] count]-1; i>=0; i--)
            {
                [ClassNameArray addObject:[[[JsonDeatail valueForKey:@"callOver"]objectAtIndex:i] valueForKey:@"className"]];
                NSString *info=[NSString stringWithFormat:@"%@",[[[JsonDeatail valueForKey:@"callOver"]objectAtIndex:i] valueForKey:@"date"]];
                NSString *year=[[NSString alloc] init];
                year=[info substringWithRange:NSMakeRange(0, 4)];
                NSString *month=[[NSString alloc]init];
                month=[info substringWithRange:NSMakeRange(5, 2)];
                NSString *day=[[NSString alloc]init];
                day=[info substringWithRange:NSMakeRange(8, 2)];
                [YearArray addObject:year];
                [MonthArray addObject:month];
                [DayArray addObject:day];
                [TeacherNameArray addObject:[[[JsonDeatail valueForKey:@"callOver"]objectAtIndex:i] valueForKey:@"teacherName"]];
                
            
            }
            dataArray=[NSMutableArray arrayWithArray:ClassNameArray];
            NSLog(@"ooooo==%@",DayArray);
            [infoTableview reloadData];
            
            //获得同学的班级
             S_ClassStr=[NSString stringWithFormat:@"%@%@%@班",[[JsonDeatail valueForKey:@"grade"] valueForKey:@"yearClass"],[[JsonDeatail valueForKey:@"grade"] valueForKey:@"profession"],[[JsonDeatail valueForKey:@"grade"] valueForKey:@"classId"]];
            NSLog(@"%@",S_ClassStr);
            [self FastCheck_CreateViewForBackground];
        }

    }
    else
    {
        [self.view makeToast:@"无返回数据"];
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
#pragma mark--------加载缺课详情背景界面
-(void)FastCheck_CreateViewForBackground
{
    //加载背景
    CenterBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, 180)];
    CenterBackground.backgroundColor=[UIColor clearColor];
    CenterBackground.image=[UIImage imageNamed:@"InfoCenter_background"];
    UITapGestureRecognizer *infocenter_tap=[[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(FastCheck_ShowInfocenterBackground)];
    CenterBackground.userInteractionEnabled=YES;
    [CenterBackground addGestureRecognizer:infocenter_tap];
    [self.view addSubview:CenterBackground];
    
    CGFloat imageSize=75.f;
    PAImageView *avaterImageView = [[PAImageView alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (CenterBackground.frame.size.height-imageSize)/2+48, imageSize, imageSize) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
    [avaterImageView setImageURL:_URL_picture];
    [self.view insertSubview:avaterImageView aboveSubview:CenterBackground];
    NSLog(@"%f--%f",avaterImageView.frame.origin.x,avaterImageView.frame.origin.y);
    //学生姓名
    UILabel *Sname=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-imageSize)/2, (CenterBackground.frame.size.height-imageSize)/2+imageSize-4, imageSize, 25)];
    Sname.backgroundColor=[UIColor clearColor];
    Sname.textColor=[UIColor colorWithWhite:255 alpha:1.0];//设置姓名的颜色为铬黄
    Sname.font=[UIFont fontWithName:@"Helvetica" size:15];
    Sname.text=S_Name;
    Sname.textAlignment=NSTextAlignmentCenter;
    [CenterBackground addSubview:Sname];
    //学生班级
    UILabel *ClassLabel=[[UILabel alloc]initWithFrame:CGRectMake(Sname.frame.origin.x, Sname.frame.origin.y+Sname.frame.size.height, imageSize, Sname.frame.size.height)];
    ClassLabel.backgroundColor=[UIColor clearColor];
    ClassLabel.font=[UIFont fontWithName:@"Helvetica" size:10];
    ClassLabel.textColor=[UIColor colorWithRed:255 green:128 blue:0 alpha:1.0];
    ClassLabel.text=S_ClassStr;
    ClassLabel.textAlignment=NSTextAlignmentCenter;
    //[Snickname sizeToFit];
    [CenterBackground addSubview:ClassLabel];


}
-(void)FastCheck_ShowInfocenterBackground
{
    [SJAvatarBrowser showImage:CenterBackground];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    //请求
    [self RequestForDetailInfo];
    
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(0, 0, 32, 32);
    [back setImage:[UIImage imageNamed:@"map_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(BringBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left_btn=[[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem=left_btn;
    //tableview
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    mySearchBar.delegate = self;
    [mySearchBar setPlaceholder:@"搜索"];
    
    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:mySearchBar contentsController:self];    searchDisplayController.active = NO;
    searchDisplayController.delegate=self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    //[self CreateViewForBackground];
    infoTableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 180, ScreenWidth, ScreenHeight-180+50)];
    NSLog(@"$$$%f",CenterBackground.frame.size.height);
    infoTableview.backgroundColor=[UIColor whiteColor];
    infoTableview.dataSource=self;
    infoTableview.delegate=self;
    infoTableview.tableHeaderView=mySearchBar;
    [self.view addSubview:infoTableview];
}
-(void)BringBack
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tabBarController.tabBar setHidden:NO];
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
-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    FastCheck_DetailCell *cell = (FastCheck_DetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FastCheck_DetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.userInteractionEnabled=NO;
    if (indexPath.row==0) {
        [cell.TopSegment setHidden:YES];
    }
    else
    {
        [cell.TopSegment setHidden:NO];
    }
    cell.selectionStyle=UITableViewCellSeparatorStyleNone;
    cell.DateImage.text=[NSString stringWithFormat:@"%@",[DayArray objectAtIndex:indexPath.row]];
    NSString *monthStr=[[NSString alloc]init];
    monthStr=[MonthArray objectAtIndex:indexPath.row];
    NSString *yearStr=[NSString stringWithFormat:@"%@",[YearArray objectAtIndex:indexPath.row]];
    cell.YDatelabel.text=[NSString stringWithFormat:@"  %@月\n%@年",monthStr,yearStr];
    cell.TeacherNameLabel.text=[NSString stringWithFormat:@"授课教师:%@",[TeacherNameArray objectAtIndex:indexPath.row] ];
       if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.ClassNameLabel.text = searchResults[indexPath.row];
}
    else {
        cell.ClassNameLabel.text = dataArray[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
