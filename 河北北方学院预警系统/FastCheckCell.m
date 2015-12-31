//
//  FastCheckCell.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-6-6.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "FastCheckCell.h"

@implementation FastCheckCell
@synthesize AbsentCount;
@synthesize paimageview;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
          paimageview = [[PAImageView alloc]initWithFrame:CGRectMake(17, 3, 44,44) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
        
        AbsentCount=[[UILabel alloc]initWithFrame:CGRectMake(200, 10, 100, 30)];
        AbsentCount.backgroundColor=[UIColor clearColor];
        AbsentCount.font=[UIFont systemFontOfSize:15];
        AbsentCount.textColor=[UIColor redColor];
        [self addSubview:AbsentCount];
        [self addSubview:paimageview];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
