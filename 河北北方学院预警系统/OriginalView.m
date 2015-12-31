//
//  OriginalView.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-2-27.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "OriginalView.h"
#import "LoginView.h"
#import "RegisterVieww.h"
#import "MLTableAlert.h"
#import "DXAlertView.h"
#import "RegisterForTeachers.h"
#import "AssistantView.h"
#import "Defines.h"

@interface OriginalView ()

@end

@implementation OriginalView
@synthesize ChooseAlert;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Login:(id)sender {
    LoginView *login=[[LoginView alloc]init];
    [self  presentViewController:login animated:YES completion:nil ];
}

- (IBAction)Register:(id)sender {
    
    //当点击注册按钮需要进行身份验证
    NSArray *IdArr=[[NSArray alloc]initWithObjects:@"学生",@"辅导员",@"普通教师",@"领导", nil];
    
    ChooseAlert=[[MLTableAlert alloc] initWithTitle:@"请您选择身份" cancelButtonTitle:@"取消" numberOfRows:^NSInteger (NSInteger section)
    {
            return [IdArr count];
    }
 andCells:^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
    {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     
     cell.textLabel.font=[UIFont systemFontOfSize:20];
     cell.textLabel.textColor=[UIColor cyanColor];
     cell.textLabel.text = [IdArr objectAtIndex:indexPath.row];
     cell.backgroundColor=[UIColor clearColor];
     cell.imageView.image=[UIImage imageNamed:@"star"];
     cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;

    }];
    ChooseAlert.height=300.0;
    //点击事件
    [ChooseAlert configureSelectionBlock:^(NSIndexPath *selectedIndex)
    {
        user=[[NSString alloc] init];
        user=[IdArr objectAtIndex:selectedIndex.row];
        if ([user isEqualToString:@"领导"])
        {
            DXAlertView *alert=[[DXAlertView alloc]initWithTitle:@"温馨提示" contentText:@"领导人员无需进行用户注册" leftButtonTitle:nil rightButtonTitle:@"知道了"];
            [alert show];
            //alert.rightBlock=^(){};右按钮功能
            //alert.dismissBlock取消时调用的方法
                   }
        else if([user isEqualToString:@"学生"])
        {
            RegisterVieww *registerview=[[RegisterVieww alloc]init];
            registerview.URL=[NSString stringWithFormat:STUDENTURL];
            [self presentViewController:registerview animated:YES completion:nil];
        }
        else if([user isEqualToString:@"辅导员"])
        {
            
            AssistantView *assistant=[[AssistantView alloc]init];
            [self presentViewController:assistant animated:YES completion:nil];
        }
        else
        {
            RegisterForTeachers *teacher=[[RegisterForTeachers alloc]init];
            teacher.URL=[NSString stringWithFormat:TEACHER];
            [self presentViewController:teacher animated:YES completion:nil];
        }
        NSLog(@"进入%@界面",user);
        
	} andCompletionBlock:^{
		return ;
    }];
	// show the alert
	[ChooseAlert show];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
