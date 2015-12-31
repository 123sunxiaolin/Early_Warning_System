//
//  SearchForNews.h
//  YuYinDemo
//
//  Created by kys-2 on 14-4-15.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupView.h"
@interface SearchForNews : UITableViewController
{
    NSMutableArray *addressUrlArr;//获得详细页面的URL
    NSMutableArray *TitleArr;//获得新闻标题
    NSMutableArray *DateArr;//获得新闻时间
    //DetailURL
    NSURL *URL;
    PopupView *ToastView;

}
@property (nonatomic,strong) NSMutableDictionary *NewsData;
-(void)adjustJSONdataForShow;
@end
