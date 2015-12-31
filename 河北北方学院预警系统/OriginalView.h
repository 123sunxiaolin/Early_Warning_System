//
//  OriginalView.h
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-2-27.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MLTableAlert;
@interface OriginalView : UIViewController<UIScrollViewDelegate>
{
    //json解析相关
    NSMutableArray *JsonObjects;
    NSString *user;
 
}
@property (nonatomic,strong) MLTableAlert *ChooseAlert;
- (IBAction)Login:(id)sender;
- (IBAction)Register:(id)sender;
@end
