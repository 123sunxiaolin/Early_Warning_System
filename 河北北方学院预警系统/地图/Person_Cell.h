//
//  Person_Cell.h
//  地图模块
//
//  Created by kys-2 on 14-5-20.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioButton.h"
#import "PAImageView.h"
@protocol MapPersonCellDelegate;//***定制
@interface Person_Cell : UITableViewCell


@property (nonatomic,strong) AudioButton *audioBtn;
//@property(nonatomic,strong) UIView *VoiceView;//音乐播放进度控制
@property (nonatomic,strong) UIButton *Headimage;//头像
@property (nonatomic,strong)PAImageView  *paimageview;
@property (nonatomic,strong) UILabel *UserName;
@property (nonatomic,strong) UILabel *timeLabel;//显示发布的时间
//@property (nonatomic,strong) UILabel *StudentID;
@property (nonatomic,strong) UILabel *LocationInfo;//地理信息
@property (nonatomic,strong) UIButton *LocateBtn;
@property (nonatomic,strong) UITextView *ContentText;
@property (nonatomic,strong) UIImageView *Picture;
@property (nonatomic,strong) UIButton *VoiceBtn;
@property (nonatomic,strong) UIImageView *Divorceline;
@property (nonatomic,assign)id<MapPersonCellDelegate> delegate;//声明协议

-(void)ClickWiththeStatus:(UIButton*)sender;
-(void)ImageViewOnClick;
@end


@protocol MapPersonCellDelegate <NSObject>

@optional
-(void)ClickTheStatusBtnFrom:(Person_Cell *)MapCell withTheStus:(NSString*)Status;

@end