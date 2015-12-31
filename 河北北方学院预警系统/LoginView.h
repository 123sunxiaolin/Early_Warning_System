//
//  LoginView.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-2-27.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+DataSourceBlocks.h"
#import "ETActivityIndicatorView.h"
@class TableViewWithBlock;
@interface LoginView : UIViewController<UITextFieldDelegate,NSXMLParserDelegate>
{
    BOOL isOpened;
    //json解析相关
    NSMutableDictionary *JsonObjects;
}
@property (nonatomic,strong)ETActivityIndicatorView *etactivity;
@property (nonatomic,strong) NSString *ID;
@property (weak, nonatomic) IBOutlet UITextField *Name;
@property (weak, nonatomic) IBOutlet UITextField *Password;
- (IBAction)BackgroundTap:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField;
- (IBAction)CancelButton:(id)sender;
//下拉列表
@property (retain, nonatomic) IBOutlet UIButton *OpenButton;
- (IBAction)changeOpenStatus:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *IdShow;
@property (retain, nonatomic) IBOutlet TableViewWithBlock *tb;
//登录按钮
- (IBAction)LoginBtn:(id)sender;
- (IBAction)ForgetNum:(id)sender;
@end
