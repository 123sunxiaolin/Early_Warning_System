//
//  messageCell.h
//  EmergencyView
//
//  Created by kys-2 on 14-4-15.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAImageView.h"
@protocol PhoneMessageDelegate;//***定制

@interface messageCell : UITableViewCell
@property (nonatomic,strong)PAImageView  *headimageview;
@property (nonatomic,strong) UIButton *IphoneBtn;
@property (nonatomic,strong) UIButton *MessageBtn;
@property (nonatomic,assign)id<PhoneMessageDelegate> delegate;//声明协议
-(void)initTheCellView;
//click
-(void)BtnClickForcell:(UIButton*)sender;

@end
@protocol PhoneMessageDelegate <NSObject>

-(void)ClickAtContactNumberFrom:(messageCell*)BtnCell WithTheFunction:(NSString *)FunTape;

@end
