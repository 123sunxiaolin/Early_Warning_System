//
//  FastCheck_DetailCell.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-6-8.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FastCheck_DetailCell : UITableViewCell
@property (nonatomic,strong) UILabel *TopSegment;
@property (nonatomic,strong) UILabel *BottomSegment;
@property (nonatomic,strong) UILabel *DateImage;
@property (nonatomic,strong) UILabel *YDatelabel;//日期Label
@property (nonatomic,strong) UILabel *ClassNameLabel;//显示课程名称
@property (nonatomic,strong) UILabel *TeacherNameLabel;//授课老师姓名
@end
