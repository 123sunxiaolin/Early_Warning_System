//
//  S_InfoCell.m
//  地图模块
//
//  Created by kys-2 on 14-5-29.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "S_InfoCell.h"

@implementation S_InfoCell
@synthesize InfoLael;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        InfoLael=[[UILabel alloc]initWithFrame:CGRectMake(100, 5, 200, 30)];
        InfoLael.backgroundColor=[UIColor clearColor];
        InfoLael.textColor=[UIColor blackColor];
        InfoLael.font=[UIFont fontWithName:@"Helvetica" size:15];
        [self addSubview:InfoLael];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
