//
//  Map_Main.m
//  地图模块
//
//  Created by kys-2 on 14-5-11.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "Map_Main.h"
#import "Map_detail.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "AudioPlayer.h"
#import "Map_PersonInfo.h"
#import "Defines.h"
#import "iToast.h"

@interface Map_Main ()
{
    NSMutableArray *nameItem;
    NSMutableArray *NicknameItem;
    NSMutableArray *wordItem;
    NSMutableArray *geographyItem;
    NSMutableArray *pictureItem;
    NSMutableArray *touxiangItem;
    NSMutableArray *thumbnailPictureItem;
    NSMutableArray *luyinItem;
    NSMutableArray *latitudeItem;
    NSMutableArray *longitudeItem;
    NSMutableArray *NumberItem;
    NSMutableArray *timeItem;
    
}
@end

@implementation Map_Main
@synthesize GradeId;
@synthesize contentString;
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
    //请求
    [SVProgressHUD showWithStatus:@"正在加载数据..."];
    [self RequestForClassmatesInfoByGrade];
    
    NSLog(@"gradeid==%@",GradeId);
    PersonTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    PersonTable.delegate=self;
    PersonTable.dataSource=self;
    PersonTable.backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"map_background.png"]];
    [self.view addSubview:PersonTable];
    //
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(0, 0, 32, 32);
    [back setImage:[UIImage imageNamed:@"map_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(BackToFrontView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left_btn=[[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem=left_btn;
    
}
-(void)BackToFrontView
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark--网络请求
-(void)RequestForClassmatesInfoByGrade
{
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:GradeId,@"gradeID",@"",@"grade",@"",@"profession",@"",@"classID", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,Map_URLForStudentInfomations]];
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
    [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}

- (void)ASIHttpRequestSuceedForHeadTeachersThree:(ASIHTTPRequest *)request
{
    //[SVProgressHUD dismiss];
    pictureItem=[[NSMutableArray alloc] init];
    thumbnailPictureItem=[[NSMutableArray alloc] init];
    touxiangItem=[[NSMutableArray alloc] init];
    luyinItem=[[NSMutableArray alloc] init];
    nameItem=[[NSMutableArray alloc] init];
    NicknameItem=[[NSMutableArray alloc]init];
    NumberItem=[[NSMutableArray alloc] init];
    
    latitudeItem=[[NSMutableArray alloc] init];
    longitudeItem=[[NSMutableArray alloc] init];
    wordItem=[[NSMutableArray alloc] init];
    geographyItem=[[NSMutableArray alloc] init];
    timeItem=[[NSMutableArray alloc] init];
    
    NSData *responseData = [request responseData];
    JsonClassmates=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];
    //得到解析的数据
    NSLog(@"jsonFor HeadTeachers 解析＝%@",JsonClassmates);
        NSLog(@"%d",JsonClassmates.count);
    @try {
    if (JsonClassmates.count) {
        [SVProgressHUD showSuccessWithStatus:@"成功"];
    for (int i=0; i<[[JsonClassmates valueForKey:@"longLat"] count]; i++)
    {
        [timeItem addObject:[[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"longLatDate"] stringByReplacingOccurrencesOfString:@"-" withString:@" "]];
        
        [nameItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"studentName"]];
         [touxiangItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"headSculpture"]];
         [NicknameItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"nickname"]];
        
        
       
        [NumberItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"studentNumber"]];
               [thumbnailPictureItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"thumbnailPictureURL"]];

        [pictureItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"pictureURL"]];
        
        
        

        
        [luyinItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"speechURL"]];
      
              [geographyItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"geography"]];
        
        
        [latitudeItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"latitude"]];
       
        [longitudeItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"longitude"]];
   
        [wordItem addObject:[[[JsonClassmates valueForKey:@"longLat"] objectForKey:[NSString stringWithFormat:@"longLat%d",i]] valueForKey:@"word"]];
        

    }
    
    _urls=[[NSArray alloc] init];
    _urls=thumbnailPictureItem;
    
    NSMutableArray *D=[[NSMutableArray alloc] init];
    for (int i=0; i<luyinItem.count; i++) {
        
        NSDictionary *nsd=[NSDictionary dictionaryWithObjectsAndKeys: luyinItem[i], @"url", nil];
        [D addObject:nsd];
       NSLog(@"%@",D);
   }
    
   itemArray=D;
    NSLog(@"%@",itemArray);
    [PersonTable reloadData];
   // NSTimer *timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reload) userInfo:nil repeats:NO];
    //timer=nil;
    }else
    {
        [SVProgressHUD showErrorWithStatus:@"暂无数据"];
        //[iToast make:@"暂无数据" duration:900];
    }
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"地图信息==%@",exception] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"地图信息==Exception: %@", exception);
    }
    @finally {
        
        NSLog(@"地图信息");
    }

}
/*-(void)reload
{
    [PersonTable reloadData];
}*/
-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    
    float rowheight;
    if ([contentString length]<90) {
        rowheight=60+[self GetSizeFromString:[wordItem objectAtIndex:indexPath.row]].height*1.5;
    }else
    {
        rowheight=60+[self GetSizeFromString:[wordItem objectAtIndex:indexPath.row]].height*1.2;
    }
   // NSLog(@"stringlength==%d",contentString.length);
    float PictureHeight=150.0;
    float distanceHeight=10.0;
    //需要判断接受的信息是否含有图片和语音
    
    return rowheight+PictureHeight+distanceHeight;
}
-(CGSize)GetSizeFromString:(NSString *)string
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:15]};
    // 计算文本的大小
    CGSize textSize = [string boundingRectWithSize:CGSizeMake(320, MAXFLOAT) // 用于计算文本绘制时占据的矩形块
        options: NSStringDrawingUsesLineFragmentOrigin // 文本绘制时的附加选项
       attributes:attributes        // 文字的属性
       context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
    return textSize;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *StudCellIdentifier = @"Cell";
        Person_Cell *cell = [tableView dequeueReusableCellWithIdentifier:StudCellIdentifier];
        if (cell == nil)
        {
            cell = [[Person_Cell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:StudCellIdentifier];
            cell.backgroundColor=[UIColor colorWithRed:250 green:255 blue:240 alpha:0.7];
            //cell.alpha=0.4;
            cell.delegate=self;
            
        }
        //添加语音按钮
        cell.audioBtn.tag = indexPath.row;
        [cell.audioBtn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        NSEnumerator *enumer=[JsonClassmates keyEnumerator];
        NSString *key=[enumer nextObject];
        if (key!=nil) {
            NSLog(@"%@",nameItem);
            cell.UserName.text=[nameItem objectAtIndex:indexPath.row];
        }else{
            cell.UserName.text=@"没有信息";
        }
        //计算时间
        NSMutableDictionary *CreateTime=[[NSMutableDictionary alloc]init];
        
        [CreateTime setValue:[timeItem objectAtIndex:indexPath.row] forKey:@"created_at"];
        cell.timeLabel.text=[self returnUploadTime:CreateTime];
        if (key!=nil) {
            cell.LocationInfo.text=[geographyItem objectAtIndex:indexPath.row];
            
        }else {
            cell.LocationInfo.text=nil;
        }
        NSString *touxiang_URL=[touxiangItem objectAtIndex:indexPath.row];
        if (![touxiang_URL isKindOfClass:[NSNull class]]) {
            /*
             [avaterImageView setImageURL:touxiang_URL];
             [StudTable addSubview:avaterImageView];*/
            [cell.paimageview setImageURL:touxiang_URL];
            
        }else{
            [cell.Headimage setImage:[UIImage imageNamed:@"11.png"] forState:UIControlStateNormal];
        }
        //地理信息
        cell.LocationInfo.numberOfLines=0;
        cell.LocationInfo.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.LocationInfo sizeToFit];
        
        CGSize stringSize=[self GetSizeFromString:[wordItem objectAtIndex:indexPath.row]];
        NSLog(@"size===%f",stringSize.height);
        cell.ContentText.frame=CGRectMake(5, cell.Headimage.frame.size.height+10, 320, stringSize.height);
        if (key!=nil) {
            contentString=[wordItem objectAtIndex:indexPath.row];
            cell.ContentText.text=[wordItem objectAtIndex:indexPath.row];
        }
        [cell.ContentText sizeToFit];
        cell.Picture.frame=CGRectMake(5, cell.ContentText.frame.origin.y+stringSize.height+14, 120, 150);
        UIImage *placeholder = [UIImage imageNamed:@"timeline_image_loading.png"];
        [cell.Picture setImageURL:_urls[indexPath.row] placeholder:placeholder];
        
        cell.Divorceline.frame=CGRectMake(0, cell.Picture.frame.origin.y+240, 320, 8);
        cell.Divorceline.image=[UIImage imageNamed:@"red_line"];
        return cell;

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误:%@",exception] duration:900];
        NSLog(@"error==%@",exception);
    }
    @finally {
    }
   }
#pragma mark---语音播放 
- (void)playAudio:(AudioButton *)button
{
    @try {
        NSInteger index = button.tag;
        NSDictionary *item = [itemArray objectAtIndex:index];
        
        if (Map_audioPlayer == nil)
        {
            Map_audioPlayer = [[AudioPlayer alloc] init];
        }
        
        if ([Map_audioPlayer.button isEqual:button])
        {
            [Map_audioPlayer play];
        }
        else
        {
            [Map_audioPlayer stop];
            
            Map_audioPlayer.button = button;
            Map_audioPlayer.url = [NSURL URLWithString:[item objectForKey:@"url"]];
            
            [Map_audioPlayer play];
        }

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"暂无录音"] duration:800];
    }
    @finally {
    }
  }
#pragma  mark  --获得系统时间
-(NSString *)returnUploadTime:(NSDictionary *)dic
{
    //Tue May 21 10:56:45 +0800 2013
    NSString *timeStr = [dic objectForKey:@"created_at"];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy MM dd HH:mm:SS"];
    NSDate *d=[date dateFromString:timeStr];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1)
    {
        //*大于一小时小于一天*/
        
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
       /* NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"HH:mm"];
        timeString = [NSString stringWithFormat:@"今天 %@",[dateformatter stringFromDate:d]];*/
    }
    if (cha/86400>1&&cha/86400<=2)
    {
        //        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        //        timeString = [timeString substringToIndex:timeString.length-7];
        //        timeString=[NSString stringWithFormat:@"%@天前", timeString];
        /*NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YY-MM-dd HH:mm"];
        timeString = [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:d]];*/
        timeString = [NSString stringWithFormat:@"昨天"];
        
    }
    if (cha/86400>2&&cha/86400<=3)
    {
         timeString = [NSString stringWithFormat:@"前天"];
    }
    if(cha/86400>3)
    {
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YY-MM-dd HH:mm"];
        timeString = [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:d]];
    }
   
    return timeString;

}
#pragma mark ---MapPersoncellDelegate
-(void)ClickTheStatusBtnFrom:(Person_Cell *)MapCell withTheStus:(NSString *)Status
{
    @try {
        NSIndexPath *indexPath = [PersonTable indexPathForCell:MapCell];//获取cell的索引
        // NSLog(@"index=%d",indexPath.row);
        if ([Status isEqualToString:@"100"])
        {
#pragma mark---------跳转到个人中心
            NSLog(@"跳转到个人中心");
            Map_PersonInfo *personInfo=[[Map_PersonInfo alloc]init];
            personInfo.title=@"个人信息";
            personInfo.Map_InfoName=[nameItem objectAtIndex:indexPath.row];
            personInfo.Map_InfoNickName=[NicknameItem objectAtIndex:indexPath.row];
            personInfo.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:personInfo animated:YES];
            
        }
        else if([Status isEqualToString:@"101"])
        {//定位
            Map_detail *map=[[Map_detail alloc]init];
            map.title=@"位置查看";
            map.map_latitude=[latitudeItem objectAtIndex:indexPath.row];
            map.map_longitude=[longitudeItem objectAtIndex:indexPath.row];
            map.S_UserName=[nameItem objectAtIndex:indexPath.row];
            map.S_Number=[NumberItem objectAtIndex:indexPath.row];
            map.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:map animated:YES];
        }
        else if ([Status isEqualToString:@"102"])
        {//语音
            NSLog(@"语音");
        }
        else
        {
            NSLog(@"图片");
            NSInteger count = pictureItem.count;
            // 1.封装图片数据
            NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
            
            // 替换为中等尺寸图片
            NSString *url = [pictureItem[indexPath.row] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:url]; // 图片路径
            photo.srcImageView = MapCell.Picture; // 来源于哪个UIImageView
            [photos addObject:photo];
            
            
            // 2.显示相册
            MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
            browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
            browser.photos = photos; // 设置所有的图片
            [browser show];
            
        }

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);

    }
    @finally {
    }
    

}
#pragma mark ---tableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        Map_detail *map=[[Map_detail alloc]init];
        map.title=@"位置查看";
        map.map_latitude=[latitudeItem objectAtIndex:indexPath.row];
        map.map_longitude=[longitudeItem objectAtIndex:indexPath.row];
        map.S_UserName=[nameItem objectAtIndex:indexPath.row];
        map.S_Number=[NumberItem objectAtIndex:indexPath.row];
        map.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:map animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误 %@",exception] duration:1000];
        NSLog(@"数据错误==Exception: %@", exception);

    }
    @finally {
    }
   }
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
