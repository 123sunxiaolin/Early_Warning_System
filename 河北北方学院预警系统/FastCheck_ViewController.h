//
//  FastCheck_ViewController.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-6-5.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPopoverListView.h"
@interface FastCheck_ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIPopoverListViewDataSource,UIPopoverListViewDelegate>
{
    //request
    NSMutableDictionary  *JsonNameList;
    NSMutableDictionary  *JsonTwiceleader;
    //Headteacher
    /*once*/
    NSMutableDictionary  *jsonOnceHeadTeacher;
    NSMutableArray *ClassManaged;
    NSMutableArray   *gradeIDArr;
    NSString *Selected_Class;
    /*twice*/
    NSMutableDictionary *JsonTwiceHeadTeacher;
    //leader
    NSString *collegenStr;
    //UITableview
    NSMutableArray *StudentNum;
    NSMutableArray *StatusNum;
    NSMutableArray *Status_picture;
    
    NSMutableArray *dataArray;
    NSMutableArray *searchResults;
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
    UITableView *tableview;
    //poplist
    UIPopoverListView *poplistview;//弹出列表
    NSArray *popArray;
}
//领导登录
-(void)getRequsetForCollegesByLeaders;//领导登录查询学院
-(void)GetRequestTwiceByLeaders;//领导的第二次请求

//辅导员登录
-(void)RequestForClassesByHeadTeachers;//辅导员登录查询管辖班级
-(void)RequestTwiceByHeadTeacher;//辅导员第二次请求获得缺课同学的名单
//UI
-(void)initTheTableView;
-(void)ChooseID;
-(void)ForButtonPressed;
@end
