//
//  ClassesListByHeadTeacher.h
//  HeadTeacher   Info Demo
//
//  Created by kys-2 on 14-5-31.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassesListByHeadTeacher : UITableViewController
{
    NSMutableArray *Classes;
}
@property (nonatomic,strong)NSMutableArray *Classlists;
-(void)InfoCenter_Back;
@end
