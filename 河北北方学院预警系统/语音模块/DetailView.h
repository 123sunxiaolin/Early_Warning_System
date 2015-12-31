//
//  DetailView.h
//  YuYinDemo
//
//  Created by kys-2 on 14-3-23.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupView.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
//气泡视图
#import "UIBubbleTableViewDataSource.h"
#import "SearchForNews.h"
#import "PulsingHaloLayer.h"
@class UIBubbleTableView;

@interface DetailView : UIViewController<IFlyRecognizerViewDelegate,UIBubbleTableViewDataSource>
{
    UITextView              *_textView;
    //UIScrollView *upView;
    UIView *choiceView;
    UILabel *content;
    //
    IFlyRecognizerView      *_iflyRecognizerView;
    PopupView *_popview;
    BOOL isFirst;
    int count;
    //气泡视图显示
    UIBubbleTableView *bubbleTable;
    NSMutableArray *bubbleData;
    //news'search
    NSMutableDictionary *jsonObjects;//存放每一个
}
@property (nonatomic, strong) PulsingHaloLayer *halo;

-(void)CreateUIView;
-(void)StartYuYin:(id)sender;
-(void)showChoicebtn:(id)sender;
//////
-(void)InitListenling;
//数据更新
-(void)refreshData;
//获取网络状态
-(void)getNetworkStatus;
//新闻搜索
-(void)SetRequestForNews;
@end
