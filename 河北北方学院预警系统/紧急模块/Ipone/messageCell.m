//
//  messageCell.m
//  EmergencyView
//
//  Created by kys-2 on 14-4-15.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "messageCell.h"

@implementation messageCell

@synthesize IphoneBtn,MessageBtn,headimageview;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initTheCellView];
    }
    return self;
}
-(void)initTheCellView
{
    //headimageview = [[PAImageView alloc]initWithFrame:CGRectMake(15, 7, 50,50) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
    IphoneBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    IphoneBtn.titleLabel.font=[UIFont systemFontOfSize:10];
    IphoneBtn.frame=CGRectMake(210, 5, 40, 30);
    [IphoneBtn setBackgroundColor:[UIColor clearColor]];
    IphoneBtn.tag=1000;
    [IphoneBtn addTarget:self action:@selector(BtnClickForcell:) forControlEvents:UIControlEventTouchUpInside];
    
    MessageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    MessageBtn.titleLabel.font=[UIFont systemFontOfSize:10];
    MessageBtn.frame=CGRectMake(250, 5, 40, 30);
    [MessageBtn setBackgroundColor:[UIColor clearColor]];
    MessageBtn.tag=1001;
    [MessageBtn addTarget:self action:@selector(BtnClickForcell:) forControlEvents:UIControlEventTouchUpInside];
   // [self addSubview:headimageview];
    [self addSubview:IphoneBtn];
    [self addSubview:MessageBtn];
    
    
}
-(void)BtnClickForcell:(UIButton *)sender
{
    switch (sender.tag) {
        case 1000:
        {
            [self.delegate ClickAtContactNumberFrom:self WithTheFunction:@"Iphone"];
            
        }
         break;
        case 1001:
        {
            [self.delegate ClickAtContactNumberFrom:self WithTheFunction:@"Message"];
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
