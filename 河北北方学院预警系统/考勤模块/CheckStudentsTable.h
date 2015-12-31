//
//  CheckStudentsTable.h
//  Attendance
//
//  Created by kys-2 on 14-5-7.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckStudentsTable : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *Table_Students;
}
@property (nonatomic,strong)NSArray *StudentTouxiangArr;
@property (nonatomic,strong)NSArray *StudentNameArr;
@property (nonatomic,strong)NSArray *StudentNumber;
@property (nonatomic,strong)NSArray *StudentStatus;
@property (nonatomic,strong)NSString *S_class;
@property (nonatomic,strong)NSString *S_lesson;
@property (nonatomic,strong)NSString *S_date;
-(void)initToolBar;
-(void)BackToFrontView;
-(void)initHeadViewFortable;
@end
