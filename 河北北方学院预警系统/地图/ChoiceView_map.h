//
//  ChoiceView_map.h
//  地图模块
//
//  Created by kys-2 on 14-5-12.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPopoverListView.h"
#import "MBSliderView.h"
#import "KGModal.h"
#import "JYTextField.h"
#import "TableViewWithBlock.h"
@class TableViewWithBlock;
@interface ChoiceView_map : UIViewController<UIPopoverListViewDelegate,UIPopoverListViewDataSource,MBSliderViewDelegate>
{
    UIPopoverListView *poplistview;//弹出列表
    MBSliderView *Slide_choice;//滑动选择
    NSArray *DataArray;//弹出列表数据
    NSMutableArray *_imagesArray;//产生雪花背景
    UIImageView *backImg;//背景图片
    
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
    UIView *choiceView ;
    //网络请求--辅导员
    NSDictionary *JSONdataForHeadTeacher;
    NSMutableArray *ZhongHeArr;//班级信息合成
    NSMutableArray *GradeIdArr;//Gradeid信息
    //网络请求--领导
    NSMutableDictionary *JsonCollegeAndGrades;
    NSMutableDictionary *JsonProfessions;
    NSMutableDictionary *JsonClasses;
    NSMutableDictionary *JsonClassmates;

    UIActivityIndicatorView *Activityview_one;//加载学院
    UIActivityIndicatorView *professionsload;//加载专业信息
    UIActivityIndicatorView *Classesload;//加载班级信息

    
    NSArray *CollegesFromClass;//获得学院的数据
    NSArray *GradesFromClass;//获得年级的数据
    NSArray *ProfessionsFromClass;//获得专业的数据
    NSArray *ClassFromLeader;//获得班级的数据
    BOOL isOpened;//控制下拉列表的收放
    
    NSMutableArray *studItems;
    NSMutableArray *studContact;
    NSMutableArray *leaderItems;
    NSMutableArray *leaderContact;
    NSMutableArray *headersItems;
    NSMutableArray *headerContact;

}
-(void)FallSnowFromSky;//雪花
-(void)LoadSlideOnView;//滑动选择
-(void)ChooseClassInLeader;//为领导构造选择班级界面
-(void)BtnClickForClassChoice:(UIButton *)sender;//点击方法
//网络请求的方法--辅导员
-(void)RequestGetClassInfoByHeaderTeachers;//登陆者为辅导员的时候发送请求获取班级信息

//网络请求----领导
-(void)GetRequestForCollegeAndGradesFromClass;//学院和年级
-(void)GetRequestForProfessions;//专业
-(void)GetRequestForClasses;//班级
-(void)SubmitDataToServer;//提交班级信息
@end
