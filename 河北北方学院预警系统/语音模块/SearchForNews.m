//
//  SearchForNews.m
//  YuYinDemo
//
//  Created by kys-2 on 14-4-15.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "SearchForNews.h"
#import "detailWebView.h"
#import "Toast+UIView.h"
#import "iToast.h"
@interface SearchForNews ()

@end

@implementation SearchForNews
@synthesize NewsData;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)adjustJSONdataForShow
{
    @try {
        TitleArr=[[NSMutableArray alloc]init];
        addressUrlArr=[[NSMutableArray alloc]init];
        if (![[NewsData valueForKey:@"Status"] length])
        {
            for (int i=0; i<NewsData.count; i++)
            {
                NSString *num=[NSString stringWithFormat:@"%d",i];
                [TitleArr addObject:[[NewsData objectForKey:num] objectForKey:@"newsTitle"]];//获取新闻列表标题
                [addressUrlArr addObject:[[NewsData objectForKey:num] valueForKey:@"url"]];
            }
            
        }
        else
        {
            ToastView = [[PopupView alloc] initWithFrame:CGRectMake(100, 300, 0, 0)];
            ToastView.ParentView = self.view;
            
            [ToastView setText:@"新闻搜索为空"];
            
        }

    }
    @catch (NSException *exception) {
        NSLog(@"error:%@",exception);
    }
    @finally {
        
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
     NSLog(@"121212%@",NewsData);
    [self adjustJSONdataForShow];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TitleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.backgroundColor=[UIColor clearColor];
        }
        cell.textLabel.text=[TitleArr objectAtIndex:indexPath.row];
        return cell;

    }
    @catch (NSException *exception) {
        NSLog(@"error:%@",exception);
    }
    @finally {
    }
   
}
#pragma UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        URL=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[addressUrlArr objectAtIndex:indexPath.row]]];
        detailWebView *webView=[[detailWebView alloc]init];
        webView.title=@"详情";
        webView.URlAddress=URL;
        webView.hight=@"64";
        webView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:webView animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];//取消选中状态

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"数据错误:%@",exception] duration:800];
    }
    @finally {
        NSLog(@"新闻链接");
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


@end
