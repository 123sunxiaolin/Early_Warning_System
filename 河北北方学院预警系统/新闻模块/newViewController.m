//
//  newViewController.m
//  NEwsDEmo
//
//  Created by kys-2 on 14-3-30.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "newViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "ASIFormDataRequest.h"
#import "SVProgressHUD.h"
#import "detailWebView.h"
#import "Defines.h"
#import "Toast+UIView.h"
#import "iToast.h"
@interface newViewController ()
{
      int index;
}
@end

@implementation newViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.view.backgroundColor=CommonColor;
    }
    return self;
}
#pragma first  for  title/date/secondURL
-(void)getNewsResource
{
    [SVProgressHUD showWithStatus:@"正在加载数据...."];
    
    NSString *checkboxStr=[NSString stringWithFormat:@"%d",index];
    //数据加载。。。
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:checkboxStr, @"index",@"学校风采",@"sectionName", nil];
    index++;
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,NEWS]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailed_newsList:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceed_newsList:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求

}
//网络请求失败
- (void)ASIHttpRequestFailed_newsList:(ASIHTTPRequest *)request{
    [SVProgressHUD showErrorWithStatus:@"数据加载失败!"];
    NSError *error = [request error];
	NSLog(@"the error is %@",error);
}
//网络请求成功
- (void)ASIHttpRequestSuceed_newsList:(ASIHTTPRequest *)request{
    [SVProgressHUD dismiss];
        NSData *responseData = [request responseData];
    jsonObjects=[responseData objectFromJSONDataWithParseOptions:JKParseOptionLooseUnicode];//得到解析的数据
    
    NSLog(@"json解析＝%@",jsonObjects );
    @try {
    if ([jsonObjects count])
    {
        if ([[jsonObjects valueForKey:@"Status"] isEqualToString:@"LoadingNewsError"]) {
            [self.view makeToast:@"加载新闻失败"];
        }
        else if ([[jsonObjects valueForKey:@"Status"] isEqualToString:@"cannotAnalyzeData"])
        {
            [self.view makeToast:@"新闻数据解析出错"];
        }
        else
        {
            NSLog(@"count-====%d",jsonObjects.count);
            for (int i=0; i<jsonObjects.count; i++) {
                NSString *num=[NSString stringWithFormat:@"%d",i];
                [TitleArr addObject:[[jsonObjects objectForKey:num] objectForKey:@"Theme"]];//获取新闻列表标题
  
                [DateArr addObject:[[jsonObjects objectForKey:num] objectForKey:@"ReDate"]];//获取日期
                [addressUrlArr addObject:[[jsonObjects objectForKey:num] valueForKey:@"URL"]];
                [Authors addObject:[[jsonObjects objectForKey:num] valueForKey:@"Author"]];
                NSLog(@"dbfvsifhif=%@",[[jsonObjects objectForKey:num] valueForKey:@"Author"]);
            }
            NewsTitles=[NSArray arrayWithArray:TitleArr];
            dates=[NSArray arrayWithArray:DateArr];
            DetailURL=[NSArray arrayWithArray:addressUrlArr];
            [self.tableView reloadData];//刷新数据
            [self.tableView reloadData];
            [self stopLoading];


        }
    }
    else
    {
        [self.view makeToast:@"获取新闻数据为空"];
        self.hasMore = NO;
       
    }
    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"新闻数据错误 %@",exception] duration:1000];
        NSLog(@"新闻数据错误==Exception: %@", exception);    }
    @finally {
        
        NSLog(@"新闻列表");
    }
        }
#pragma UI --Create

-(void)LoadDataForNews
{
    headArr1=[NSArray arrayWithArray:TitleArr];
   // dates1
    headArr2=[NSArray arrayWithObjects:@"title4",@"title5",@"title6", nil];
    NewsTitles=headArr1;
}
//添加刷新界面

-(void)LoadRefreshView
{

    
    //添加 下拉列表更新视图
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
		view.delegate = self;
		[self.view addSubview:view];
		_refreshHeaderView = view;
    }
    //  日期更新
	[_refreshHeaderView refreshLastUpdatedDate];
   
}
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    //根据分段控件的值tag  进行不同的request请求
    [self getNewsResource];
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    //[self.view reloadInputViews];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (void)viewDidLoad
{
    index=1;
    [super viewDidLoad];
    SegmentNum=1;
    TitleArr=[[NSMutableArray alloc] init];
    DateArr=[[NSMutableArray alloc] init];
    addressUrlArr=[[NSMutableArray alloc] init];
    Authors=[[NSMutableArray alloc]init];


    //[self LoadDataForNews];//修改
    [self getNewsResource];
    [self LoadRefreshView];

}
- (void)viewWillAppear:(BOOL)animated
{//当页面准备加载时 进行URL请求
    
}
-(void)selected:(id)sender
{
    
    UISegmentedControl *control=(UISegmentedControl *)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
            NSLog(@"正在转摘头条新闻...");
            [self getNewsResource];
            //NewsTitles=headArr1;
           // [self.tableView reloadData];
            SegmentNum=1;
            break;
        case 1:
            NSLog(@"正在转载热点新闻");
            headArr2=[NSArray arrayWithObjects:@"title4",@"title5",@"title6", nil];
            NewsTitles=headArr2;
            SegmentNum=2;
            [self.tableView reloadData];
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NewsTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
        return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.backgroundColor=[UIColor whiteColor];
        }
        
        // Configure the cell...
        if (SegmentNum==1)
        {
            cell.imageView.image=[UIImage imageNamed:@"news.png"];
            cell.textLabel.text=[NewsTitles objectAtIndex:indexPath.section];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font=[UIFont boldSystemFontOfSize:16];
            cell.textLabel.textColor=[UIColor blackColor];
            cell.detailTextLabel.textColor=[UIColor orangeColor];
            cell.detailTextLabel.font=[UIFont systemFontOfSize:13];
            
            
            
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@       %@",[dates objectAtIndex:indexPath.section],[Authors objectAtIndex:indexPath.section]];
            
        }
        else if(SegmentNum==2)
        {
            cell.textLabel.text=[NewsTitles objectAtIndex:indexPath.row];
            
        }
        
        return cell;

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"新闻数据错误 %@",exception] duration:1000];
        NSLog(@"新闻数据错误==Exception: %@", exception);
    }
    @finally {
       // NSLog(@"新闻数据");
    }
    }
#pragma UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        URL=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[DetailURL objectAtIndex:indexPath.row]]];
        detailWebView *webView=[[detailWebView alloc]init];
        webView.title=@"新闻详情";
        webView.URlAddress=URL;
        webView.hight=@"0";
        webView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:webView animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];//取消选中状态
    }
    @catch (NSException *exception) {
        NSLog(@"数据错误:%@",exception);
    }
    @finally {
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

//上拉更新
- (void)refresh {
    
    [self performSelector:@selector(addItem) withObject:nil afterDelay:0.5];
}
-(void)addItem
{
    [SVProgressHUD showWithStatus:@"正在加载数据...."];
    //数据加载。。。
  
    index++;
      NSString *checkboxStr=[NSString stringWithFormat:@"%d",index];
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:checkboxStr, @"index",@"学校风采",@"sectionName", nil];
    //构造了一个最简单的字典类型的数据，因为自iOS 5后提供把NSDictionary转换成
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &error];//转换成json格式
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IP,NEWS]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(ASIHttpRequestFailed_newsList:)];
    [request setDidFinishSelector:@selector(ASIHttpRequestSuceed_newsList:)];
    //[request startAsynchronous];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempJsonData];
    [request startAsynchronous];//开启同步请求
   
    [self.tableView reloadData];
    [self stopLoading];

}
- (NSString *)tabImageName
{
	return @"newsunselect.png";
}

- (NSString *)tabTitle
{
	return self.title=@"校园新闻";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



@end
