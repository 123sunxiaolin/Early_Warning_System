//
//  AssistantView.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-3.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCheckBox.h"
#import "ETActivityIndicatorView.h"
@class MLTableAlert;
@interface AssistantView : UIViewController<UITextFieldDelegate,QCheckBoxDelegate>
{
    NSMutableArray *QcheckArr;//用于存储checkbox的元素
    NSDictionary *objectArr;//第二次请求返回值
    NSMutableArray *zonghe;
    NSMutableDictionary *JSONobjects;//第一次请求返回
    NSMutableArray *JsonObjects;
    
    NSMutableArray *colleges;//用于存储学院信息
    
    NSMutableDictionary *jsonForMain;//第三次请求返回
    NSMutableArray*ZhuanYeArr;
}

//填写注册接口
@property (nonatomic,strong)ETActivityIndicatorView *etactivity1;
@property (nonatomic,strong) NSString *URL;

- (IBAction)CancelBtn:(id)sender;
- (IBAction)backgrounTap:(id)sender;

- (IBAction)RegisterBtn:(id)sender;
- (IBAction)AddBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addbtn;

//网络请求
-(void)getNetworkRequestFirst;
-(void)getNetworkRequestSecond;
-(void)getNetworkRequestMain;
////////
@property (nonatomic,strong) UIActivityIndicatorView *activity;//加载画面
@property (nonatomic,strong) MLTableAlert *ChooseAlert;

@property (weak, nonatomic) IBOutlet UITextField *Name;
@property (weak, nonatomic) IBOutlet UITextField *NickName;
@property (weak, nonatomic) IBOutlet UITextField *PhoneNum;
@property (weak, nonatomic) IBOutlet UITextField *IDNum;
@property (weak, nonatomic) IBOutlet UITextField *XueyuanTEXT;

@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UITextField *ConfirmPassword;
-(void)UIAssume;
@property (weak, nonatomic) IBOutlet UIScrollView *ZhuanYeScroll;

@end
