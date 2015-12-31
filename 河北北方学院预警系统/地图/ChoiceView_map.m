//
//  ChoiceView_map.m
//  地图模块
//
//  Created by kys-2 on 14-5-12.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "ChoiceView_map.h"
#import "Map_Main.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "SelectionCell.h"
#import "Toast+UIView.h"
#import "UITextField+Shake.h"
#import "Defines.h"
#import "FKRSearchBarTableViewController.h"
#import "iToast.h"
//雪花产生所用到得函数----------可以变换图片
#define SNOW_IMAGENAME         @"snow"
#define IMAGE_X                arc4random()%(int)ScreenWidth
#define IMAGE_ALPHA            ((float)(arc4random()%10))/10
#define IMAGE_WIDTH            arc4random()%20 + 10
#define PLUS_HEIGHT            ScreenHeight/25
#define IMAGENAMED(NAME)        [UIImage imageNamed:NAME]

#define LEADER @"1"
#define HEADERTEACHER @"0"
@interface ChoiceView_map ()

@end

@implementation ChoiceView_map

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
    //self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"map_choicebackground"]];
    
    backImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    backImg.image=[UIImage imageNamed:@"map_choicebackground"];
    [self.view addSubview:backImg];
    [self FallSnowFromSky];//雪花
    [self LoadSlideOnView];//滑动选择
}
#pragma mark 滑动选择界面
-(void)LoadSlideOnView
{
    //滑动事件
    Slide_choice = [[MBSliderView alloc] initWithFrame:CGRectMake(20, ScreenHeight-52-48, self.view.frame.size.width-40.0, 44.0)];
       // Loaded from nib
    [Slide_choice setText:@"Choose Class"];
    [Slide_choice setThumbColor:[UIColor colorWithRed:128.0/255.0 green:190.0/255.0 blue:28.0/255.0 alpha:1.0]];
    [Slide_choice setDelegate:self];
    UIToolbar *tool=[[UIToolbar alloc]initWithFrame:CGRectMake(0, ScreenHeight-60-48, ScreenWidth, 60)];
    tool.backgroundColor=[UIColor cyanColor];
    [tool addSubview:Slide_choice];
    [backImg addSubview:tool];
    [self.view addSubview:Slide_choice];
    [self.view insertSubview:Slide_choice aboveSubview:tool];
	

}
- (void) sliderDidSlide:(MBSliderView *)slideView {
    //需要对身份进行判断
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"辅导员"])
    {//辅导员
    [self RequestGetClassInfoByHeaderTeachers];
    }
    else if([[[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"] isEqualToString:@"领导"])
    {//领导
        [self ChooseClassInLeader];
        [self GetRequestForCollegeAndGradesFromClass];
        
    }
    [slideView setThumbColor:[self randomColor]];
    [slideView setLabelColor:[self randomColor]];
}
// Random Color
- (UIColor *) randomColor {
    CGFloat r = arc4random()%255;
    CGFloat g = arc4random()%255;
    CGFloat b = arc4random()%255;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}
#pragma mark 网络请求----领导----学生学院和年级
-(void)GetRequestForCollegeAndGradesFromClass
{//获得  学院  和  年级
    [Activityview_one startAnimating];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,URLGetGradeAndColleges_CAO]];//获得学院年级的URL
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
    [Activityview_one stopAnimating];
    //[self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
- (void)ASIHttpRequestSuceedForCollegeAndGrade:(ASIHTTPRequest *)request
{
    [Activityview_one stopAnimating];
    NSData *responseData = [request responseData];
    JsonCollegeAndGrades=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Leaders Three 解析＝%@",JsonCollegeAndGrades);
    @try {
   if ([JsonCollegeAndGrades count])
   {
       //[self ChooseClassInLeader];
       xueyuanBtn.enabled=YES;
       CollegesFromClass=[JsonCollegeAndGrades valueForKey:@"college"];
       GradesFromClass=[JsonCollegeAndGrades valueForKey:@"grade"];
       //创建下拉列表
       NSArray *textfields=[[NSArray alloc]initWithObjects:XUeyuanText,NianJiText, nil];
       NSArray *btns=[[NSArray alloc]initWithObjects:xueyuanBtn,nianjiBtn,nil];
       NSArray *tbs=[[NSArray alloc]initWithObjects:XueyuanTable,NianJiTable, nil];
       
       NSInteger counts=[CollegesFromClass count];
       NSInteger counts1=[GradesFromClass count];
       for (int i=0; i<2; i++)
       {
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
        [iToast make:[NSString stringWithFormat:@"领导数据错误 %@",exception] duration:1000];
        NSLog(@"领导数据错误==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"Leaders信息");
    }

}
#pragma --mark RequestDelegate For 学生专业
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
    //获得学生专业的URL
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
    //JsonProfessions=[[NSMutableDictionary alloc] init];//重新申明一下
   //ProfessionsFromClass=[[NSArray alloc] init];
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
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);

    }
    @finally {
        
        NSLog(@"专业信息");
    }

}
#pragma --mark RequestDelegate For 学生班级
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
    //重新申明
    //JsonClasses=[[NSMutableDictionary alloc]init];
    ///ClassFromLeader=[[NSArray alloc]init];
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

#pragma mark 网络请求----辅导员
-(void)RequestGetClassInfoByHeaderTeachers
{//辅导员第一次请求
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserNickName"],@"userNickname", nil];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserNickName"]);
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,Map_URLGetClassesManagedByHeadteacher]];//辅导员获得所管辖的班级
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
    [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForHeadTeachers:(ASIHTTPRequest *)request
{
   
    NSData *responseData = [request responseData];
    JSONdataForHeadTeacher=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor HeadTeachers 解析＝%@",JSONdataForHeadTeacher);
    ZhongHeArr=[[NSMutableArray alloc]init];
    GradeIdArr=[[NSMutableArray alloc]init];
    @try {
    if ([JSONdataForHeadTeacher count])
    {
         [SVProgressHUD dismiss];
        if ([[JSONdataForHeadTeacher valueForKey:@"Status"] isEqualToString:@"getGPCFail"])
        {
            [self.view makeToast:@"返回数据失败\n请重新操作"];
        }
         else
        {
            NSLog(@"udhfash==%@",[[[JSONdataForHeadTeacher objectForKey:@"0"] valueForKey:@"grade"] valueForKey:@"profession"]);
             for (int i=0; i<[JSONdataForHeadTeacher count]; i++)
            {
          NSDictionary *info=[[NSDictionary alloc]init];
                NSString *num=[NSString stringWithFormat:@"%d",i];
                info=[[JSONdataForHeadTeacher objectForKey:num] valueForKey:@"grade"];
                NSLog(@"info==%@",[info valueForKey:@"gradeName"]);
                NSString *grade=[NSString stringWithFormat:@"%@",[info valueForKey:@"gradeName"] ];
                NSString *zhuanye=[info valueForKey:@"profession"];
                NSString *class=[info valueForKey:@"classID"];
                NSString * OneInfo=[NSString stringWithFormat:@"%@%@%@",grade,zhuanye,class];
                NSString *infoString=[[[[OneInfo stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
                [GradeIdArr addObject:[info
                                       valueForKey:@"gradeID"]];
                [ZhongHeArr addObject:infoString];
                NSLog(@"1111=%@",[info
                                  valueForKey:@"gradeID"]);
            }
          
            DataArray=[NSArray arrayWithArray:ZhongHeArr];
            [self popClickAction];

        }
    }
    else
    {
        //[self.view makeToast:@"加载数据失败😭"];
        [SVProgressHUD showWithStatus:@"获取数据失败"];
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
#pragma mark   产生动态雪花背景
-(void)FallSnowFromSky
{
    //
    _imagesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; ++ i) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:IMAGENAMED(SNOW_IMAGENAME)];
        float x = IMAGE_WIDTH;
        imageView.frame = CGRectMake(IMAGE_X, -30, x, x);
        imageView.alpha = IMAGE_ALPHA;
        [backImg addSubview:imageView];
        [_imagesArray addObject:imageView];
    }
    [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(makeSnow) userInfo:nil repeats:YES];
    //

}
static int i = 0;
- (void)makeSnow
{
    i = i + 1;
    if ([_imagesArray count] > 0) {
        UIImageView *imageView = [_imagesArray objectAtIndex:0];
        imageView.tag = i;
        [_imagesArray removeObjectAtIndex:0];
        [self snowFall:imageView];
    }
    
}

- (void)snowFall:(UIImageView *)aImageView
{
    [UIView beginAnimations:[NSString stringWithFormat:@"%i",aImageView.tag] context:nil];
    [UIView setAnimationDuration:6];
    [UIView setAnimationDelegate:self];
    aImageView.frame = CGRectMake(aImageView.frame.origin.x, ScreenHeight, aImageView.frame.size.width, aImageView.frame.size.height);
    //NSLog(@"%@",aImageView);
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:[animationID intValue]];
    float x = IMAGE_WIDTH;
    imageView.frame = CGRectMake(IMAGE_X, -30, x, x);
    [_imagesArray addObject:imageView];
}
#pragma mark  method choiceView  For leader see headerteachers
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
}


#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
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
    
    /* int row = indexPath.row;
     
     if(row == 0){
     cell.textLabel.text = @"Facebook";
     cell.imageView.image = [UIImage imageNamed:@"ic_facebook.png"];
     }else if (row == 1){
     cell.textLabel.text = @"Twitter";
     cell.imageView.image = [UIImage imageNamed:@"ic_twitter.png"];
     }else if (row == 2){
     cell.textLabel.text = @"Google Plus";
     cell.imageView.image = [UIImage imageNamed:@"ic_google_plus.png"];
     }else {
     cell.textLabel.text = @"Email";
     cell.imageView.image = [UIImage imageNamed:@"ic_share_email.png"];
     }*/
    //    UIActivityIndicatorView *test=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    test.frame=CGRectMake(0, 0, 60, 60);
    //    test.tag=indexPath.row+100;
    //    cell.accessoryView=test;
    //    cell.tag=indexPath.row;
    //    //[test startAnimating];
    
    return cell;
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
        [popoverListView dismiss];
    } completion:^(BOOL finished)
     {
         Map_Main *mapList=[[Map_Main alloc]init];
         mapList.title=[NSString stringWithFormat:@"%@",[DataArray objectAtIndex:indexPath.row]];
         mapList.GradeId=[NSString stringWithFormat:@"%@",[GradeIdArr objectAtIndex:indexPath.row]];
         mapList.hidesBottomBarWhenPushed=YES;
         [self.navigationController pushViewController:mapList animated:YES];
         
     }];
    
    /* [UIView animateWithDuration:.35 animations:^{
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
     if (![Leader isEqualToString:@"1"])
     {
     collegeName=[NSString stringWithFormat:@"%@",[DataArray objectAtIndex:indexPath.row]];
     [self GetRequestForHeadteachersFromOneCollege];//获得各个学院的辅导员
     }
     else if(![HeaderTeacher isEqualToString:@"2"])
     {
     GradeIdStr=[NSString stringWithFormat:@"%@",[GradeIdArr objectAtIndex:indexPath.row]];
     [self getTheOnlyClassByGradeid];
     NSLog(@"9999=%@",[GradeIdArr objectAtIndex:indexPath.row]);
     }
     NSLog(@"%s : %d", __func__, indexPath.row);
     // your code here*/
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
#pragma mark 构造为领导选择班级的界面
-(void)ChooseClassInLeader
{
    choiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 300)];
    /*change ios */
    choiceView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"popView_image.png"]];
    
    //College
    UILabel *collegeLable=[[UILabel alloc]init];
    collegeLable.frame=CGRectMake(20, 50-5, 50, 30);
    collegeLable.textColor=[UIColor grayColor];
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
    [xueyuanBtn addTarget:self action:@selector(BtnClickForClassChoice:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:XUeyuanText];
    [choiceView insertSubview:xueyuanBtn aboveSubview:XUeyuanText];
    //加载界面
    Activityview_one=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    Activityview_one.frame=CGRectMake(0, 0, 30, 30);
    [xueyuanBtn addSubview:Activityview_one];
    
    XueyuanTable=[[TableViewWithBlock alloc] init];
    XueyuanTable.frame=CGRectMake(55, 75, 205, 5);
    XueyuanTable.backgroundColor=[UIColor whiteColor];
    XueyuanTable.hidden=YES;
    [choiceView addSubview:XueyuanTable];
    
    //Grade
    UILabel *NianjiLable=[[UILabel alloc]initWithFrame:CGRectMake(20, 85+15, 50, 30)];
    NianjiLable.textColor=[UIColor grayColor];
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
    [nianjiBtn addTarget:self action:@selector(BtnClickForClassChoice:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:NianJiText];
    [choiceView insertSubview:nianjiBtn aboveSubview:NianJiText];
    
    NianJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(20, 160, 80, 8)];
    
    NianJiTable.backgroundColor=[UIColor whiteColor];
    NianJiTable.hidden=YES;
    [choiceView addSubview:NianJiTable];
    
    
    //Profession
    zhuanyeLable=[[UILabel alloc]initWithFrame:CGRectMake(120, 85+15, 50, 30)];
    zhuanyeLable.textColor=[UIColor grayColor];
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
    [zhuanyeBtn addTarget:self action:@selector(BtnClickForClassChoice:) forControlEvents:UIControlEventTouchUpInside];
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
    banjiLable.textColor=[UIColor grayColor];
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
    [banjiBtn addTarget:self action:@selector(BtnClickForClassChoice:) forControlEvents:UIControlEventTouchUpInside];
    
    
    BanJiTable=[[TableViewWithBlock alloc]initWithFrame:CGRectMake(105,230, 80, 5)];
    BanJiTable.backgroundColor=[UIColor whiteColor];
    BanJiTable.hidden=YES;
    [choiceView addSubview:BanJiTable];
    [choiceView insertSubview:banjiBtn aboveSubview:BanJiText];
    
    UIButton *confirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame=CGRectMake(choiceView.frame.size.width-60, choiceView.frame.size.height-40, 50, 30);
    confirmBtn.backgroundColor=[UIColor clearColor];
    confirmBtn.layer.masksToBounds=YES;
    confirmBtn.layer.cornerRadius=5.0;
    [confirmBtn setImage:[UIImage imageNamed:@"submit_btn.png"] forState:UIControlStateNormal];
    [choiceView addSubview:confirmBtn];
    confirmBtn.tag=14;
    [confirmBtn addTarget:self action:@selector(BtnClickForClassChoice:) forControlEvents:UIControlEventTouchUpInside];
    [[KGModal sharedInstance] showWithContentView:choiceView andAnimated:YES];

}
#pragma mark--clickDelegate
-(void)BtnClickForClassChoice:(UIButton *)sender
{
    switch (sender.tag) {
        case 10:
        {//学院
            XueyuanTable.hidden=NO;
            if (isOpened)
            {//添加个动画会更好
                //                nianjiBtn.hidden=NO;
                //                NianJiText.hidden=NO;
                //                zhuanyeBtn.hidden=NO;
                //                ZhuanYeText.hidden=NO;
                //                zhuanyeLable.hidden=NO;
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
                
                
                //                nianjiBtn.hidden=YES;
                //                NianJiText.hidden=YES;
                //                zhuanyeBtn.hidden=YES;
                //                ZhuanYeText.hidden=YES;
                //                zhuanyeLable.hidden=YES;
                //                NianJiText.transform = CGAffineTransformMakeScale(0.3, 0.3);
                //                nianjiBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                //                zhuanyeBtn.transform=CGAffineTransformMakeScale(0.3, 0.3);
                //                ZhuanYeText.transform=CGAffineTransformMakeScale(0.3, 0.3);
                //                zhuanyeLable.transform=CGAffineTransformMakeScale(0.3, 0.3);
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
            
            /* [XUeyuanText shake:20 withDelta:5
             andSpeed:0.03
             shakeDirection:ShakeDirectionHorizontal];*/
        }
            break;
        case 11:
        {//年级
            /*[NianJiText shake:20 withDelta:5
             andSpeed:0.03
             shakeDirection:ShakeDirectionHorizontal];*/
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
            /*[ZhuanYeText shake:20 withDelta:5
             andSpeed:0.03
             shakeDirection:ShakeDirectionHorizontal];*/
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
            /*[BanJiText shake:20 withDelta:5
             andSpeed:0.03
             shakeDirection:ShakeDirectionHorizontal];*/
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
                        [countArr addObject:[NSString stringWithFormat:@"%ld",(long)jy.tag]];
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
                //[self PopLoadViewAfterConfirmBtnClicked];
                [self SubmitDataToServer];
               /* Map_Main *mapList=[[Map_Main alloc]init];
                mapList.title=[NSString stringWithFormat:@"%@%@",ZhuanYeText.text,BanJiText.text];
                mapList.GradeId=[NSString stringWithFormat:@"%@",BanJiText.text];
                mapList.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:mapList animated:YES];*/
            }
        }
        default:
            break;
    }

}
-(void)SubmitDataToServer
{//提交所选择的班级数据
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"gradeID",NianJiText.text,@"grade",ZhuanYeText.text,@"profession",BanJiText.text,@"classID", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,Map_URLForStudentInfomations]];
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
- (void)ASIHttpRequestSuceedForClassmatesSeven:(ASIHTTPRequest *)request
{
    // [spinner ]
    //[[KGModal sharedInstance] hide];
    studItems=[[NSMutableArray alloc]init];
    studContact=[[NSMutableArray alloc]init];
    NSData *responseData = [request responseData];
    JsonClassmates=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor Students解析＝%@",JsonClassmates);
    @try {
    if ([JsonClassmates count]) {
        
        [[KGModal sharedInstance] hide];
        NSTimer *timer;
        timer=[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(changeToMapView) userInfo:nil repeats:NO];
        for (int i=0; i<[[JsonClassmates objectForKey:@"student"] count]; i++)
        {
            [studItems addObject:[[[JsonClassmates objectForKey:@"student"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"studentName"]];
            [studContact addObject:[[[JsonClassmates objectForKey:@"student"] objectForKey:[NSString stringWithFormat:@"%d",i]] valueForKey:@"phone"]];
        }
        //缓存一下学生的信息
        [[NSUserDefaults standardUserDefaults] setObject:studItems forKey:@"students"];
        [[NSUserDefaults standardUserDefaults]setObject:studContact forKey:@"studContact"];
        
        [UIView animateWithDuration:1.7 animations:^{
            FKRSearchBarTableViewController *stud=[[FKRSearchBarTableViewController alloc]init];
            stud.identifer=@"student";
            stud.title=@"同学";
            //[self.navigationController pushViewController:stud animated:YES];
            
        }];
        
    }
    else
    {
        [self.view makeToast:@"获取数据失败"];
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
-(void)changeToMapView
{
    Map_Main *mapList=[[Map_Main alloc]init];
    mapList.title=[NSString stringWithFormat:@"%@%@",ZhuanYeText.text,BanJiText.text];
    mapList.GradeId=[NSString stringWithFormat:@"%@",BanJiText.text];
    mapList.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:mapList animated:YES];

}
- (void)ASIHttpRequestFailedForClassmatesSeven:(ASIHTTPRequest *)request
{
    [[KGModal sharedInstance] hide];
    [self.view makeToast:@"由于网络原因,\n数据更新失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)tabImageName
{
	return @"mapunselect.png";
}

- (NSString *)tabTitle
{
	return self.title=@"地图";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
