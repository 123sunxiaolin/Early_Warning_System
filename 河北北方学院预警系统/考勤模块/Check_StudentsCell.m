//
//  Check_StudentsCell.m
//  Attendance
//
//  Created by kys-2 on 14-5-6.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "Check_StudentsCell.h"

@implementation Check_StudentsCell
@synthesize StatusLable;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
     _paimageview = [[PAImageView alloc]initWithFrame:CGRectMake(15, 7, 50,50) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
        
        StatusLable=[[UILabel alloc]initWithFrame:CGRectMake(320-70, 10, 70, 40)];
        StatusLable.font=[UIFont systemFontOfSize:15];
        [self addSubview:_paimageview];
        [self addSubview:StatusLable];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
