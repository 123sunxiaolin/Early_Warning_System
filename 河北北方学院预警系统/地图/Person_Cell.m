//
//  Person_Cell.m
//  地图模块
//
//  Created by kys-2 on 14-5-20.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "Person_Cell.h"
#import "PAImageView.h"
@implementation Person_Cell
//@synthesize VoiceView;
@synthesize Headimage;
@synthesize UserName;
@synthesize timeLabel;
@synthesize LocationInfo;
@synthesize LocateBtn;
@synthesize ContentText;
@synthesize Picture;
@synthesize VoiceBtn;
@synthesize Divorceline;
@synthesize delegate;
@synthesize audioBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {     /*buton's tag from 100 to 103  */
        _paimageview = [[PAImageView alloc]initWithFrame:CGRectMake(5, 5, 44,44) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
        
        Headimage=[UIButton buttonWithType:UIButtonTypeCustom];
        //[Headimage setImage:[UIImage imageNamed:@"11.png"] forState:UIControlStateNormal];
        Headimage.alpha=0.88;
        Headimage.frame=CGRectMake(5, 5, 45, 45);
        Headimage.backgroundColor=[UIColor clearColor];
        [Headimage.layer setCornerRadius:5.0];
        Headimage.tag=100;
        [Headimage addTarget:self action:@selector(ClickWiththeStatus:) forControlEvents:UIControlEventTouchUpInside];
        
        UserName=[[UILabel alloc]initWithFrame:CGRectMake(70, 7, 100, 20)];
        UserName.backgroundColor=[UIColor clearColor];
        UserName.textColor = [UIColor orangeColor];
        UserName.font = [UIFont fontWithName:@"Helvetica" size:18];
        timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(72, 28, 120, 20)];
        timeLabel.backgroundColor=[UIColor clearColor];
        timeLabel.textColor = [UIColor darkGrayColor];
        timeLabel.numberOfLines=2;
        timeLabel.font = [UIFont fontWithName:@"Helvetica" size:9];
        
        LocateBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        LocateBtn.backgroundColor=[UIColor clearColor];
        LocateBtn.frame=CGRectMake(UserName.frame.origin.x+90, 3, 65, 30);
        //LocateBtn.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:12];
        //[LocateBtn setTitle:@"定位" forState:UIControlStateNormal];
        [LocateBtn setImage:[UIImage imageNamed:@"map_locate"] forState:UIControlStateNormal];
        //[LocateBtn.layer setCornerRadius:3.0];
        LocateBtn.tag=101;
        [LocateBtn addTarget:self action:@selector(ClickWiththeStatus:) forControlEvents:UIControlEventTouchUpInside];
        
        LocationInfo=[[UILabel alloc]initWithFrame:CGRectMake(timeLabel.frame.origin.x+90, timeLabel.frame.origin.y+6, 120, 20)];
        LocationInfo.backgroundColor=[UIColor clearColor];
        LocationInfo.textColor = [UIColor darkGrayColor];
        LocationInfo.font = [UIFont fontWithName:@"Helvetica" size:9];
        //LocationInfo.numberOfLines=0;
        //[LocationInfo sizeToFit];
        
        ContentText=[[UITextView alloc]initWithFrame:CGRectZero];
        ContentText.backgroundColor=[UIColor clearColor];
        ContentText.textColor=[UIColor blackColor];
        ContentText.textAlignment=NSTextAlignmentLeft;
        ContentText.font=[UIFont fontWithName:@"Helvetica" size:15];
        ContentText.userInteractionEnabled=NO;
        
        Picture=[[UIImageView alloc]init];
        Picture.frame=CGRectZero;
        //Picture.tag=103;
        Picture.userInteractionEnabled=YES;
        [Picture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageViewOnClick)]];
        
        VoiceBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        VoiceBtn.frame=CGRectMake(LocateBtn.frame.origin.x+35, 7, 27, 27);
        VoiceBtn.backgroundColor=[UIColor clearColor];
         VoiceBtn.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:12];
        [VoiceBtn setTitle:@"语音" forState:UIControlStateNormal];
        [VoiceBtn setImage:[UIImage imageNamed:@"map_yuyin"] forState:UIControlStateNormal];
        VoiceBtn.tag=102;
        [VoiceBtn addTarget:self action:@selector(ClickWiththeStatus:) forControlEvents:UIControlEventTouchUpInside];
//        VoiceView=[[UIView alloc]initWithFrame:CGRectMake(VoiceBtn.frame.origin.x+45, 7, 25, 25)];
//        VoiceView.backgroundColor=[UIColor clearColor];
//        
       audioBtn=[[AudioButton alloc]initWithFrame:CGRectMake(VoiceBtn.frame.origin.x+40, 7, 25, 25)];

        
        Divorceline=[[UIImageView alloc]initWithFrame:CGRectZero];
        
        Divorceline.backgroundColor=[UIColor clearColor];
        [self addSubview:_paimageview];
        [self addSubview:Headimage];
        [self addSubview:UserName];
        [self addSubview:timeLabel];
        [self addSubview:LocationInfo];
        [self addSubview:LocateBtn];
        [self addSubview:ContentText];
        [self addSubview:Picture];
        //[self addSubview:VoiceBtn];
        [self addSubview:Divorceline];
        //[self addSubview:VoiceView];
        [self addSubview:audioBtn];
        
    }
    return self;
}
-(void)ImageViewOnClick
{
    [delegate ClickTheStatusBtnFrom:self withTheStus:@"103"];

}
-(void)ClickWiththeStatus:(UIButton*)sender
{
    switch (sender.tag) {
        case 100:
        {//头像按钮
            [delegate ClickTheStatusBtnFrom:self withTheStus:@"100"];
        }
            break;
            case 101:
        {//定位按钮
            [delegate ClickTheStatusBtnFrom:self withTheStus:@"101"];
        }
            break;
            case 102:
        {//语音
            [delegate ClickTheStatusBtnFrom:self withTheStus:@"102"];
        }
            break;
//            case 103:
//        {//图片
//            [delegate ClickTheStatusBtnFrom:self withTheStus:@"103"];
//        }
//            break;
        default:
            break;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
