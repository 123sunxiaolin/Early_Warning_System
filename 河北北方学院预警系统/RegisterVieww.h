//
//  RegisterVieww.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-1.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETActivityIndicatorView.h"
@class TableViewWithBlock;
@interface RegisterVieww : UIViewController<UITextFieldDelegate>
{
    BOOL isOpened;
    NSMutableDictionary *JsonFirst;
    NSMutableDictionary *JsonData;
    NSMutableDictionary *JsonObjects2;
    NSMutableDictionary *JsonObjects4;
    NSMutableDictionary *JsonObjectDic;
}
//网络请求
-(void)getNetworkRequestFirst;
-(void)getNetworkRequestSecond;
-(void)getNetworkRequestThird;
-(void)getNetworkRequestMain;
//填写注册接口
@property (nonatomic,strong)ETActivityIndicatorView *etactivity1;
@property (nonatomic,strong) NSString *URL;

- (IBAction)CancelBtn:(id)sender;//退出界面
- (IBAction)backGroundTap:(id)sender;//背景按钮
- (IBAction)RegisterBtn:(id)sender;//注册按钮
/*##################*/
@property (weak, nonatomic) IBOutlet UITextField *Name;//姓名
@property (weak, nonatomic) IBOutlet UITextField *NickName;
@property (weak, nonatomic) IBOutlet UITextField *StudNum;//学号
@property (weak, nonatomic) IBOutlet UITextField *PhoneNumber;//手机号码
@property (weak, nonatomic) IBOutlet UITextField *IDNumber;//身份证号
@property (weak, nonatomic) IBOutlet UITextField *Password;//密码
@property (weak, nonatomic) IBOutlet UITextField *ConFirmNum;//确认密码

@property (weak, nonatomic) IBOutlet UITextField *NianjiText;//年级显示框
- (IBAction)NianjiBtn:(id)sender;//年级按钮
//班级下拉列表
@property (weak, nonatomic) IBOutlet UITextField *BanjiTEXT;
- (IBAction)BanjiBtn:(id)sender;
//专业
@property (weak, nonatomic) IBOutlet UITextField *ZhuanYeTEXT;
- (IBAction)ZhuanYeBtn:(id)sender;
//学院
@property (weak, nonatomic) IBOutlet UITextField *XueYuanTEXT;
- (IBAction)XueYuanBtn:(id)sender;

//列表
@property (retain, nonatomic) IBOutlet TableViewWithBlock *tb1;
@property (retain, nonatomic) IBOutlet TableViewWithBlock *tb2;
@property (retain, nonatomic) IBOutlet TableViewWithBlock *tb3;
@property (weak, nonatomic) IBOutlet TableViewWithBlock *tb4;

//butons
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;

-(void)UIassume;
//-(void)UIDataBase;

@end
