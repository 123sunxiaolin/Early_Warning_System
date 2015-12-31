//
//  PersonView.m
//  河北北方学院预警系统
//
//  Created by kys-2 on 14-3-7.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "PersonView.h"
#import "LoginView.h"
#import "RegisterVieww.h"
#import "RegisterForTeachers.h"
#import "AssistantView.h"
#import "ChngeINfoView.h"
#import "OriginalView.h"
#define ID1 @"学生"
#define ID2 @"普通教师"
#define ID3 @"辅导员"
@interface PersonView ()

@end

@implementation PersonView
@synthesize idcard;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.navigationController.navigationBarHidden=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;
    Choices=[[NSArray alloc] initWithObjects:@"个人信息",@"帮助",@"关于我们",@"退出登录", nil];
    //添加headImage
    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bar.png"]];
    imgView.frame=CGRectMake(0, 0, 320, 60);
    imgView.alpha=0.7;
    self.tableView.tableHeaderView=imgView;
    NSLog(@"4444444444%@",idcard);
    
    /*change*/
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(0, 0, 32, 32);
    [back setImage:[UIImage imageNamed:@"map_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(BackToFrontView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left_btn=[[UIBarButtonItem alloc]initWithCustomView:back];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"] isEqualToString:@"学生"])
    {
        self.navigationItem.leftBarButtonItem=nil;

    }else
    {
    self.navigationItem.leftBarButtonItem=left_btn;
    }

	
}
-(void)BackToFrontView
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }else if (section==1){
        return 2;
    }else{
        return 1;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat high;
    if (section==0) {
        high=0.0;
    }else if(section==1){
        high=3.0;
    }else{
        high=25.0;
    }
    return high;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    UILabel *xinxi=[[UILabel alloc]initWithFrame:CGRectMake(5, 0, 100, 20)];
    if (section==2) {
        xinxi.font=[UIFont systemFontOfSize:14];
        xinxi.textColor=[UIColor grayColor];
        xinxi.text=@"退出登录";
        [head addSubview:xinxi];
    }
    return head;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image=[UIImage imageNamed:@"heart.png"];
    if (indexPath.section==0) {
        cell.textLabel.text=[Choices objectAtIndex:0];
    }else if (indexPath.section==1){
        cell.textLabel.text=[Choices objectAtIndex:indexPath.row+1];
    }else{
        cell.textLabel.text=[Choices objectAtIndex:[Choices count]-1];
    }
    
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        //根据身份的不同进入不同的界面
        ChngeINfoView *change=[[ChngeINfoView alloc]init];
        change.title=@"个人信息";
        change.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:change animated:YES];

    }else if (indexPath.section==1){
        if (indexPath.row==0) {
            NSLog(@"您点击啦帮助界面");
        }else{
            NSLog(@"您点击啦 关于我们界面");
        }
            
    }else{
        OriginalView *original=[[OriginalView alloc]init];
        [self presentViewController:original animated:YES completion:nil];
        /*这里需要添加清除缓存信息和ASi的cookie*/
    }
    /*if (indexPath.row==0) {
        LoginView *login=[[LoginView alloc]init];
        login.title=[Choices objectAtIndex:indexPath.row];
        login.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:login animated:YES];
    }else if (indexPath.row==1){
        if ([ID1 isEqualToString:@"学生"]) {
            RegisterVieww *student=[[RegisterVieww alloc]init];
            student.title=@"学生注册界面";
            [self.navigationController pushViewController:student animated:YES];
        }else if ([ID2 isEqualToString:@"普通教师"]){
            RegisterForTeachers *teacher=[[RegisterForTeachers alloc]init];
            teacher.title=@"教师注册界面";
            [self.navigationController pushViewController:teacher animated:YES];
            
        }else if([ID3 isEqualToString:@"辅导员"]){
            AssistantView *assistant=[[AssistantView alloc]init];
            assistant.title=@"辅导员注册界面";
            assistant.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:assistant animated:YES];
         }
        
    }else if (indexPath.row==2){
        ChangeInfo *change=[[ChangeInfo alloc]init];
        change.title=@"个人信息";
        [self.navigationController pushViewController:change animated:YES];
        ChngeINfoView *change=[[ChngeINfoView alloc]init];
        change.title=@"个人信息";
        change.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:change animated:YES];
    }
        
    NSLog(@"个人中心选中%@",[Choices objectAtIndex:indexPath.row]);*/
}
 
 

@end
