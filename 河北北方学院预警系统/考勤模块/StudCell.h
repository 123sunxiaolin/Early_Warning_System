//
//  StudCell.h
//  Attendance
//
//  Created by kys-2 on 14-4-16.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTPressableButton.h"
#import "UIColor+HTColor.h"//立体按钮
#import "PAImageView.h"
@protocol StudentCellDelegate;//***定制

@interface StudCell : UITableViewCell<UIGestureRecognizerDelegate>
{
    //BOOL isSign;
    //BOOL isOff;
    //BOOL isAbsent;
  }
//
@property (nonatomic )BOOL isSign;
@property (nonatomic )BOOL isOff;
@property (nonatomic )BOOL isAbsent;
@property (nonatomic,strong) PAImageView *paimageview;
@property (nonatomic,strong)HTPressableButton *LateBtn;//签到按钮
@property (nonatomic,strong)HTPressableButton *OffBtn;//请假按钮
@property (nonatomic,strong)HTPressableButton *AbsentBtn;//旷课按钮
@property (nonatomic,assign)id<StudentCellDelegate> delegate;//声明协议
-(void)initViewForAttendance;
//-(void)HandSlideEvent; change
-(void)ClickWiththeStatus:(UIButton*)sender;
@end

@protocol StudentCellDelegate <NSObject>//***定制
@optional
-(void)ClickTheStatusBtnFrom:(StudCell *)sCell withTheStus:(NSString*)Status;

@end
