//
//  Person_INFO_Center.h
//  HeadTeacher   Info Demo
//
//  Created by kys-2 on 14-5-31.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXActionSheet.h"
@interface Person_INFO_Center : UIViewController<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationBarDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,LXActionSheetDelegate>
{
    UITableView *InfoCenterTable;
    NSMutableDictionary *InfoCenterJsons;
    UILabel *Sname;
    UILabel *H_name;
    UILabel *T_name;
    NSMutableArray *Person_Student;//存放学生有关的信息
    NSString *phone;
    NSString *HeadTeacherCardNum;
    NSString *TeacherCardNum;
    NSMutableArray *ClassesmanagedByHead;//存放辅导员所管辖的班级
    UIImage * image;
    LXActionSheet *imageSheet;//用于选择相册
    BOOL isImageSheet;//判断是哪一个sheet
    
}
@property(nonatomic,retain) UIImageView *picture;

@property (nonatomic,strong) UIImageView *InfoCenterBackground;
-(void)CreateViewForBackground;//加载背景墙视图
-(void)ShowInfocenterBackground;//放大显示背景墙图片
//辅导员
-(void)InfoCenter_Request_HeadTeacherToCheck;//获得个人中心的信息
//学生
-(void)InfoCenter_Request_StudentsToCheck;
//普通教师
-(void)InfoCenter_Request_TeachersToCheck;
//领导
-(void)InfoCenter_Request_leaderToCheck;
@end
