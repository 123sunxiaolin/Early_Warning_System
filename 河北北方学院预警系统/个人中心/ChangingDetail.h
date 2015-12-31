//
//  ChangingDetail.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-10.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangingDetail : UIViewController<UITextFieldDelegate>
{
    NSMutableDictionary *JsonStatus;
}
//用于传送不同身份的URL和身份标志字
@property (nonatomic,strong)NSString *IDIdentifer;
@property (nonatomic,strong)NSString *InfoChangeURL;

@property (nonatomic,strong)NSString *XiugaiChoice;
@property (nonatomic,strong)NSString *nickName;
/*该ID用于验证进入此界面的身份，以便于区分数据的存储       */
- (IBAction)backgrondTap:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *numberText;
@property (weak, nonatomic) IBOutlet UILabel *phoneLable;
//修改密码时的操作
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UITextField *presentPassword;
@property (weak, nonatomic) IBOutlet UITextField *passwordNew;
//设置按钮状态
@property (nonatomic,strong) IBOutlet UIButton *bt;
-(void)ComeBackData:(id)sender;
-(void)back;
//密码、手机号码修改的请求
-(void)SubmitRequestForChanging;
@end
