//
//  NamesList.h
//  Attendance
//
//  Created by kys-2 on 14-4-20.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudCell.h"
#import "JYTextField.h"
#import "DEInfiniteTileMarqueeView.h"
#import "TableViewWithBlock.h"
#import "PMCalendar.h"
#import "DropDownListView.h"

#import "HTPressableButton.h"
#import "UIColor+HTColor.h"
#import "KxMenu.h"

//
@class TableViewWithBlock;
@interface NamesList : UIViewController<UITableViewDataSource,UITableViewDelegate,StudentCellDelegate,UITextFieldDelegate,PMCalendarControllerDelegate,kDropDownListViewDelegate>
{
    NSMutableArray *data;
    UIView *background;
    //到勤计数
    int count;
    UILabel *NumShidao;
    UILabel *NumYindao;
    UIBarButtonItem *right;
    UIBarButtonItem *left;
    //将点名的人员放到数组中
    NSMutableArray *StudArray;
    NSMutableArray *StudStatus;
    //choiceView
    UIView *grayView;
    HTPressableButton *CallBtn;
    HTPressableButton *CheckBtn;
    HTPressableButton *FastCheckBtn;
    UIView *choiceView;
    //textfirld
    JYTextField *ClassInput;
    JYTextField *XUeyuanText;
    JYTextField *NianJiText;
    JYTextField *ZhuanYeText;
    JYTextField *BanJiText;
    JYTextField *dateInput;
    JYTextField *SectionText;
    JYTextField *Update_studentNum;//更新时需要输入学号
    JYTextField *Update_Classtime;//更新时需要输入节数
    JYTextField *Update_oldStudyStatus;//更新以前的状态
    JYTextField *Update_studyStatus;//更新后的状态
    
    // button for listview tag:from 20 to 25
    UIButton *xueyuanBtn;
    UIButton *nianjiBtn;
    UIButton *zhuanyeBtn;
    UIButton *banjiBtn;
    UIButton *kechengBtn;
    UIButton *newStatusBtn;
    UIButton *jieshuBtn;
    UIButton *ConfirmBtn;
    UIButton *oldStatusBtn;
    //popTable
    TableViewWithBlock *XueyuanTable;
    TableViewWithBlock *NianJiTable;
    TableViewWithBlock *ZhuanyeTable;
    TableViewWithBlock *BanJiTable;
    //
    UILabel *zhuanyeLable;
    UILabel *banjiLable;
    UILabel *className;
    UILabel *SectionLable;
  
    //View for leader
    UILabel *Datelable;
    //DropListView for lesson and sectionNumber
    DropDownListView * Dropobj;
    NSArray *LessonArr;
    NSArray *SectionArr;
    //JSONRequest
    NSMutableDictionary *JsonCollegeAndGrades;//学院和年级
    NSMutableDictionary *JsonProfessions;//专业
    NSMutableDictionary *JsonClasses;//班级
    NSMutableDictionary *JsonLessons;//课程
    NSMutableDictionary *JsonClassmates;//人名单
    //加载界面
    NSMutableDictionary *JsonChecked;//查询
    UIActivityIndicatorView *CollegeLoad;//加载专业
    UIActivityIndicatorView *professionsload;//加载专业信息
    UIActivityIndicatorView *Classesload;//加载班级信息
    UIActivityIndicatorView *Lessonsload;//加载课程信息
    UIActivityIndicatorView *SubmitDataLoad;//加载提交信息

    NSArray *CollegesFromClass;//获得学院的数据
    NSArray *GradesFromClass;//获得年级的数据
    NSArray *ProfessionsFromClass;//获得专业的数据
    NSArray *ClassFromLeader;//获得班级的数据
    BOOL isOpened;
    BOOL isCheck;//判断是否点击查询
    //用于传递给查询的学生列表视图
    NSMutableArray *Check_StuName;
    NSMutableArray *Check_StuNumber;
    NSMutableArray *Check_StuStatus;
    NSMutableArray *Check_StuTouxiao;
    //用于点名的学生列表
    NSMutableArray *CAll_StuName;
    NSMutableArray *CAll_StuNumber;
    NSMutableArray *CAll_headSculpture;

    //返回按钮
    UIButton *CloseBtn;
    //身份验证
    NSString *ID_User;
    //添加导航栏
    UIToolbar *Tool_back;
    //选择后的课程名称
    UILabel *name;
}
@property (nonatomic,strong)UITableView *StudTable;
@property (nonatomic,strong)UIToolbar *tool;
//Animation Line
@property (nonatomic,strong) DEInfiniteTileMarqueeView *leftMarquee;
@property (nonatomic,strong) DEInfiniteTileMarqueeView *rightMarquee;
@property (nonatomic,strong) DEInfiniteTileMarqueeView *topMarquee;
@property (nonatomic,strong) DEInfiniteTileMarqueeView *bottomMarquee;
//Methods
-(void)MethodForToolBar;
-(void)MethodForHeadView;
-(void)MethodForNavigationBar;
-(void)PoptheViewAllOverScreen;
-(void)presentChoiceViewForLeaders;//领导辅导员
-(void)presentChoiceViewForTeachers;//教师
-(void)GetRequestForCollegeAndGrades;//获得学院和年级
-(void)GetRequestForProfessions;//获得专业
-(void)GetRequestForClasses;//获得班级
-(void)GetRequestForLessons;//获得相应班级下的课程名称
-(void)SubmitAllDataForDianMing;//提交信息获得班级名单
-(void)GetRequestClassmatsCheckedByLeaders;//查看考勤
//click
-(void)BtnClickForCaoqin:(UIButton*)sender;
- (void) pushMenuItem:(KxMenuItem *)sender;//menuClickMethod

@end
