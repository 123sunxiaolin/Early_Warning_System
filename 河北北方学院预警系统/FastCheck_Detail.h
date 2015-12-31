//
//  FastCheck_Detail.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-6-8.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FastCheck_Detail : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    //request
    NSMutableDictionary *JsonDeatail;
    NSMutableArray *ClassNameArray;
    NSMutableArray *CalendarArray;
    //日期
    NSMutableArray *YearArray;//年
    NSMutableArray *MonthArray;//月
    NSMutableArray *DayArray;//日
    
    NSMutableArray *TeacherNameArray;//授课老师
    NSString *S_ClassStr;
    //table
    UITableView *infoTableview;
    NSMutableArray *dataArray;
    NSMutableArray *searchResults;
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
}
/*加载背景墙*/
@property (nonatomic,strong) UIImageView *CenterBackground;
-(void)FastCheck_CreateViewForBackground;//加载背景墙视图
-(void)FastCheck_ShowInfocenterBackground;//放大显示背景墙图片

@property (nonatomic,strong) NSString *S_Num;//学号
@property (nonatomic,strong) NSString *S_Name;//姓名
@property (nonatomic,strong) NSString *URL_picture;//头像
-(void)BringBack;
//request
-(void)RequestForDetailInfo;
@end
