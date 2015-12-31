//
//  RegisterForTeachers.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-3.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETActivityIndicatorView.h"
@interface RegisterForTeachers : UIViewController<UITextFieldDelegate,NSXMLParserDelegate>
{
     NSMutableDictionary *JsonObjects;
}
//网络请求
-(void)getNetworkRequestMain;
//填写注册接口
@property (nonatomic,strong)ETActivityIndicatorView *etactivity1;
@property (nonatomic,strong) NSString *URL;
@property (nonatomic,strong) NSArray *info;
- (IBAction)BackgroundTap:(id)sender;
- (IBAction)RegisterBtn:(id)sender;
- (IBAction)CancelBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *Name;
@property (weak, nonatomic) IBOutlet UITextField *NickName;

@property (weak, nonatomic) IBOutlet UITextField *PhoneNum;
@property (weak, nonatomic) IBOutlet UITextField *IDNum;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UITextField *ConfirmPassword;
-(void)TextfieldAssume;
@end
