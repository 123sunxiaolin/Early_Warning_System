//
//  StudCell.m
//  Attendance
//
//  Created by kys-2 on 14-4-16.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "StudCell.h"
#import "Toast+UIView.h"
@implementation StudCell
@synthesize LateBtn,OffBtn,AbsentBtn;
@synthesize isSign,isOff,isAbsent;
@synthesize paimageview;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initViewForAttendance];
    }
    return self;
}
-(void)initViewForAttendance
{
    //显示头像
     paimageview = [[PAImageView alloc]initWithFrame:CGRectMake(17, 3, 44,44) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
    //旷课
    AbsentBtn=[HTPressableButton buttonWithType:UIButtonTypeCustom];
    AbsentBtn.frame=CGRectMake(180, 5, 40, 40);
    AbsentBtn.style=HTPressableButtonStyleCircular;
    AbsentBtn.buttonColor=[UIColor grapeFruitColor];
    AbsentBtn.shadowColor=[UIColor grapeFruitDarkColor];
    [AbsentBtn setTitle:@"旷课" forState:UIControlStateNormal];
    AbsentBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    AbsentBtn.tag=2;
    [AbsentBtn addTarget:self action:@selector(ClickWiththeStatus:) forControlEvents:UIControlEventTouchUpInside];
    //请假
    OffBtn=[HTPressableButton buttonWithType:UIButtonTypeCustom];
    OffBtn.frame=CGRectMake(225, 5, 40, 40);
    OffBtn.style=HTPressableButtonStyleCircular;
    OffBtn.buttonColor=[UIColor lemonColor];
    OffBtn.shadowColor=[UIColor lemonDarkColor];
    [OffBtn setTitle:@"请假" forState:UIControlStateNormal];
    OffBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    OffBtn.tag=1;
    [OffBtn addTarget:self action:@selector(ClickWiththeStatus:) forControlEvents:UIControlEventTouchUpInside];

    //迟到
    LateBtn=[HTPressableButton buttonWithType:UIButtonTypeCustom];
    LateBtn.frame=CGRectMake(270, 5, 40, 40);
     LateBtn.style=HTPressableButtonStyleCircular;
    LateBtn.buttonColor=[UIColor mintColor];
    LateBtn.shadowColor=[UIColor mintDarkColor];
    [LateBtn setTitle:@"迟到" forState:UIControlStateNormal];
    LateBtn.titleLabel.font=[UIFont systemFontOfSize:15];


   // LateBtn.backgroundColor=[UIColor clearColor];
    LateBtn.tag=0;
    [LateBtn addTarget:self action:@selector(ClickWiththeStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    /* //迟到按钮
     [LateBtn setImage:[UIImage imageNamed:@"sign.png"] forState:UIControlStateNormal];
   // OffBtn.backgroundColor=[UIColor grayColor];
    [OffBtn setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
    //AbsentBtn.backgroundColor=[UIColor grayColor];
    [AbsentBtn setImage:[UIImage imageNamed:@"absent.png"] forState:UIControlStateNormal];*/
    [self addSubview:paimageview];
    [self addSubview:LateBtn];
    [self addSubview:OffBtn];
    [self addSubview:AbsentBtn];
    //[self HandSlideEvent];将按钮设置为非隐藏
    
}
//#pragma mark - Gesture recognizer delegate
//-(void)HandSlideEvent
//{
//    UISwipeGestureRecognizer *left=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [left setDirection:UISwipeGestureRecognizerDirectionLeft];
//    UISwipeGestureRecognizer *right=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [right setDirection:UISwipeGestureRecognizerDirectionRight];
////    self.animationType = RMSwipeTableViewCellAnimationTypeEaseInOut;
////    self.animationDuration = 1.2f;
//
//    [self addGestureRecognizer:left];
//    [self addGestureRecognizer:right];
//}
//-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
//    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
//        
//               NSLog(@"swipe left");
//        LateBtn.hidden=NO;
//        OffBtn.hidden=NO;
//        AbsentBtn.hidden=NO;
//        //执行程序
//    }
//    
//    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
//        
//        NSLog(@"swipe right");
//        SignBtn.hidden=YES;
//        OffBtn.hidden=YES;
//        AbsentBtn.hidden=YES;
//        //执行程序
//    }
//}
#pragma ClickDelegate
-(void)ClickWiththeStatus:(UIButton *)sender
{
    switch (sender.tag) {
        case 0:
        {
            if (isSign==NO&&isOff==NO&&isAbsent==NO) {
           /* LateBtn.layer.borderColor=[UIColor clearColor].CGColor;
            LateBtn.layer.borderWidth=0.0;
            LateBtn.layer.cornerRadius=0.0;
            LateBtn.backgroundColor=[UIColor clearColor];*/
            //[LateBtn setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
            [LateBtn setTitle:@"👌" forState:UIControlStateNormal];
            isSign=YES;
            [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"迟到"];
                
            }else if(isSign&&isOff==NO&&isAbsent==NO){
//                LateBtn.layer.borderColor=[UIColor clearColor].CGColor;
//                SignBtn.layer.borderWidth=0.0;
//                SignBtn.layer.cornerRadius=0.0;
//                SignBtn.backgroundColor=[UIColor clearColor];
//                [SignBtn setImage:[UIImage imageNamed:@"sign.png"] forState:UIControlStateNormal];
                [LateBtn setTitle:@"迟到" forState:UIControlStateNormal];
                isSign=NO;
                [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"取消迟到"];
            }else
            {
                [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"每位同学只能一个到勤状态"];
            }
            
        }
            break;
        case 1:{
            if (isOff==NO&&isSign==NO&&isAbsent==NO) {
                /*OffBtn.layer.borderColor=[UIColor clearColor].CGColor;
                OffBtn.layer.borderWidth=0.0;
                OffBtn.layer.cornerRadius=0.0;
                OffBtn.backgroundColor=[UIColor clearColor];
                [OffBtn setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];*/
                [OffBtn setTitle:@"👌" forState:UIControlStateNormal];
                isOff=YES;
                [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"请假"];
                
            }else if(isOff&&isSign==NO&&isAbsent==NO){
               /* OffBtn.layer.borderColor=[UIColor clearColor].CGColor;
                OffBtn.layer.borderWidth=0.0;
                OffBtn.layer.cornerRadius=0.0;
                OffBtn.backgroundColor=[UIColor clearColor];
                [OffBtn setImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];*/
                [OffBtn setTitle:@"请假" forState:UIControlStateNormal];
                isOff=NO;
                [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"取消请假"];
                
            }else{
                [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"每位同学只能一个到勤状态"];

            }

            
        }
            break;
        case 2:{
            if (isAbsent==NO&&isSign==NO&&isOff==NO) {
               /* AbsentBtn.layer.borderColor=[UIColor clearColor].CGColor;
                AbsentBtn.layer.borderWidth=0.0;
                AbsentBtn.layer.cornerRadius=0.0;
                AbsentBtn.backgroundColor=[UIColor clearColor];
                [AbsentBtn setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];*/
                [AbsentBtn setTitle:@"👌" forState:UIControlStateNormal];
                isAbsent=YES;
                [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"旷课"];
               
            }else if(isAbsent&&isSign==NO&&isOff==NO){
                /*AbsentBtn.layer.borderColor=[UIColor clearColor].CGColor;
                AbsentBtn.layer.borderWidth=0.0;
                AbsentBtn.layer.cornerRadius=0.0;
                AbsentBtn.backgroundColor=[UIColor clearColor];
                [AbsentBtn setImage:[UIImage imageNamed:@"absent.png"] forState:UIControlStateNormal];*/
                [AbsentBtn setTitle:@"旷课" forState:UIControlStateNormal];
                isAbsent=NO;
                [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"取消旷课"];
                
            }else{
                [self.delegate ClickTheStatusBtnFrom:self withTheStus:@"每位同学只能一个到勤状态"];

            }

           
        }
            break;
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
