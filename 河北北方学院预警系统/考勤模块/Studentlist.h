//
//  Studentlist.h
//  Attendance
//
//  Created by kys-2 on 14-4-16.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudCell.h"
#import "TTUITableViewZoomController.h"
@interface Studentlist : TTUITableViewZoomController<StudentCellDelegate>{
    NSMutableArray *data;
    UIView *background;
}
//methods
-(void)PoptheViewAllOverScreen;
@end
