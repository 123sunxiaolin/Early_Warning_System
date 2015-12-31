//
//  Map_PersonInfo.h
//  地图模块
//
//  Created by kys-2 on 14-5-29.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAImageView.h"
@interface Map_PersonInfo : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
     NSString *touxiao;
    UITableView *InfoTable;
    PAImageView *avaterImageView;
    //request
    NSMutableDictionary * Map_Jsons;
    NSMutableArray *Map_InfoArrayNumber;
    NSMutableArray *Map_ClassInfo;
}
@property (nonatomic,strong) NSString *Map_InfoName;
@property (nonatomic,strong) NSString *Map_InfoNickName;
@property (nonatomic,strong) UIImageView *InfoBackground;
-(void)initBackGroundForInfo;
-(void)back;
-(void)EnlargeBackgroundImg;
//地图用户获得个人信息
-(void)Map_GetInfomationFromURL;
@end
