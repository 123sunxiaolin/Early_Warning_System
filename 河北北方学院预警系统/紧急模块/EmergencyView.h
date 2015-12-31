//
//  EmergencyView.h
//  EmergencyView
//
//  Created by kys-2 on 14-4-25.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGModal.h"
#import "UIPopoverListView.h"
#import "MDFlickrActivityIndicatorView.h"
#import "JYTextField.h"
#import "TableViewWithBlock.h"
@class TableViewWithBlock;
@interface EmergencyView : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate,UIPopoverListViewDelegate,UIPopoverListViewDataSource>
{
    // Json Leaders
    NSMutableDictionary *jsonLeaderObjects;//one
    NSMutableDictionary *JsonCollegeObjects;//two
    NSMutableDictionary *JsonHeadTeachersObjects;//Three
    NSString *collegeName;//Three
    NSMutableDictionary *JsonCollegeAndGrades;//four
    NSMutableDictionary *JsonProfessions;//five
    NSMutableDictionary *JsonClasses;//Six
    NSMutableDictionary *JsonClassmates;//Seven
    
    NSMutableDictionary *JsonHeadTeacherFirst;//headTeachers
    NSMutableDictionary *JsonHeadTeacherTwo;//headTeachers
    NSMutableDictionary *JsonHeadTeacherThree;//headTeachers

    
    NSMutableArray *ZhongHeArr;//班级信息合成
    NSMutableArray *GradeIdArr;//Gradeid信息
    NSString *GradeIdStr;//用于GradeId的值
    
    NSArray *CollegesFromClass;//获得学院的数据
    NSArray *GradesFromClass;//获得年级的数据
    NSArray *ProfessionsFromClass;//获得专业的数据
    NSArray *ClassFromLeader;//获得班级的数据
    BOOL isOpened;//控制下拉列表的收放
    
    UIActivityIndicatorView *ActivityView;//加载
    UIActivityIndicatorView *professionsload;//加载专业信息
    UIActivityIndicatorView *Classesload;//加载班级信息
    
    NSArray *collegeArr;
    //Json  students
    NSMutableDictionary *jsonObjects;
    NSMutableArray *studItems;
    NSMutableArray *studContact;
    NSMutableArray *studImages;
    NSMutableArray *leaderItems;
    NSMutableArray *leaderContact;
    NSMutableArray *headersItems;
    NSMutableArray *headerContact;

    
    //popView For Leader Or HeaderTeachers
    UIPopoverListView *poplistview;
    MDFlickrActivityIndicatorView *spinner;
    UIView *choiceView ;
    NSArray *DataArray;
    
    //Drop list
    JYTextField *XUeyuanText;
    JYTextField *NianJiText;
    JYTextField *ZhuanYeText;
    JYTextField *BanJiText;
    UIButton *xueyuanBtn;
    UIButton *nianjiBtn;
    UIButton *zhuanyeBtn;
    UIButton *banjiBtn;
    TableViewWithBlock *XueyuanTable;
    TableViewWithBlock *NianJiTable;
    TableViewWithBlock *ZhuanyeTable;
    TableViewWithBlock *BanJiTable;
    UILabel *zhuanyeLable;
    UILabel *banjiLable;
    //
    NSString *user_ID;
}
@property (nonatomic,strong)UITableView *IDTable;
-(void)GetRequestForLeaderOne;//Leader one
-(void)GetRequestForCollegeByLeader;//leaders two
-(void)GetRequestForHeadteachersFromOneCollege;//leaders three
-(void)GetRequestForCollegeAndGradesFromClass;//leaders Four
-(void)GetRequestForProfessions;//five
-(void)GetRequestForClasses;//six
-(void)SubmitDataToServer;//seven
-(void)GetContactsForLeadersAndHeaderTeachers;//Headerteachers First
-(void)GetClassesManagedByHeaderteacher;//Headerteachers two
-(void)getTheOnlyClassByGradeid;//Headerteachers three  根据Gradeid获得相应的班级
-(void)getContactsFromNetwork;//Students
//choose   Class
-(void)ChooseClass;
-(void)PopLoadViewAfterConfirmBtnClicked;
@end
