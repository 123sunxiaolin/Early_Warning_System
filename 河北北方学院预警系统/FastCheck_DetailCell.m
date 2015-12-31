//
//  FastCheck_DetailCell.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-6-8.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "FastCheck_DetailCell.h"

/*cellHeight=50.0*/
@implementation FastCheck_DetailCell
@synthesize TopSegment,BottomSegment,DateImage,YDatelabel,ClassNameLabel,TeacherNameLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        YDatelabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        YDatelabel.backgroundColor=[UIColor clearColor];
        YDatelabel.numberOfLines=0;
        YDatelabel.textColor=[UIColor grayColor];
        YDatelabel.font=[UIFont systemFontOfSize:12];
        CGFloat dateImageWidth=30.0;
        CGFloat lineWidth=5.0;
        TopSegment=[[UILabel alloc]initWithFrame:CGRectMake(50+(dateImageWidth-lineWidth)/2, 0, 3, 15)];
        TopSegment.backgroundColor=[UIColor grayColor];
        DateImage=[[UILabel alloc]initWithFrame:CGRectMake(50, 10, 30, 30)];
        DateImage.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"Circle"]];
        DateImage.textAlignment=NSTextAlignmentCenter;
        DateImage.textColor=[UIColor blackColor];
        DateImage.font=[UIFont systemFontOfSize:15];
        BottomSegment=[[UILabel alloc]initWithFrame:CGRectMake(TopSegment.frame.origin.x, 40, 3, 15+30)];
        BottomSegment.backgroundColor=[UIColor grayColor];
        ClassNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 6, 200, 40)];
        ClassNameLabel.backgroundColor=[UIColor clearColor];
        ClassNameLabel.textColor=[UIColor blackColor];
        ClassNameLabel.font=[UIFont systemFontOfSize:18];
        TeacherNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 40, 200, 30)];
        TeacherNameLabel.backgroundColor=[UIColor clearColor];
        TeacherNameLabel.font=[UIFont systemFontOfSize:15];
        TeacherNameLabel.textColor=[UIColor grayColor];
        [self addSubview:TopSegment];
        [self addSubview:DateImage];
        [self addSubview:BottomSegment];
        [self addSubview:YDatelabel];
        [self addSubview:ClassNameLabel];
        [self addSubview:TeacherNameLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
