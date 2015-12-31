//
//  newViewController.h
//  NEwsDEmo
//
//  Created by kys-2 on 14-3-30.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "PullRefreshTableViewController.h"
@interface newViewController : PullRefreshTableViewController<EGORefreshTableHeaderDelegate>
{
    //第一次请求
    NSMutableDictionary *jsonObjects;//获得解析的数据
    NSMutableArray *addressUrlArr;//获得详细页面的URL
    NSMutableArray *TitleArr;//获得新闻标题
    NSMutableArray *DateArr;//获得新闻时间
    
    NSArray *NewsTitles;
    //临时静态数据借用
    NSArray *headArr1;
    NSArray *dates;
    NSArray *DetailURL;
    NSMutableArray *Authors;//获取新闻的作者
    
    //修改
    NSArray *headArr2;
    NSArray *dates2;
    //DetailURL
    NSURL *URL;
    //下拉更新的变量
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    //第二次请求
    NSMutableDictionary *SecondContent;
    //对分段控件的标识
    int SegmentNum;
    
   
}
-(void)getNewsResource; //第一次请求
//-(void)getSecondNewsContent;//第二次请求
-(void)LoadDataForNews;
//-(void)createSegment;
-(void)selected:(id)sender;
//下拉更新的方法
-(void)LoadRefreshView;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end
