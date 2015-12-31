//
//  Studentlist.m
//  Attendance
//
//  Created by kys-2 on 14-4-16.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "Studentlist.h"
#import "Toast+UIView.h"

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
/*需要身份进行界面的判断*/
#define Teacher @"0"
#define Leader  @"1"
@interface Studentlist ()

@end

@implementation Studentlist

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //self.title=@"123";
        //self.navigationController.navigationBarHidden=YES;
       // self.navigationController.navigationBar.hidden=YES;
       
    }
    return self;
}
-(void)PoptheViewAllOverScreen
{
    if ([Teacher isEqualToString:@"0"]) {
        
    background=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    background.backgroundColor=[UIColor whiteColor];
    background.alpha=1.0;
    //[self.view addSubview:background];
 
    //[self.tableView bringSubviewToFront:background];
    }
    else{
        
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //添加headView
    UIView *head=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    UILabel *Classname=[[UILabel alloc]init];
    Classname.frame=CGRectMake(30, 10, 70, 30);
    Classname.backgroundColor=[UIColor clearColor];
    Classname.font=[UIFont systemFontOfSize:12];
    Classname.textColor=[UIColor blackColor];
    Classname.text=@"当前课程:";
//    [Classname.layer setBorderColor:[UIColor grayColor].CGColor];
//    [Classname.layer setBorderWidth:2.0];
//    [Classname];
    UILabel *name=[[UILabel alloc]init];
    name.frame=CGRectMake(100, 10, 150, 30);
    name.textColor=[UIColor blueColor];
    name.backgroundColor=[UIColor clearColor];
    [name.layer setBorderColor:[UIColor grayColor].CGColor];
    [name.layer setBorderWidth:2.0];
    [name.layer setCornerRadius:5.0];
    name.font=[UIFont systemFontOfSize:15];
    name.text=@"计算机组成原理与设计";
    //
    UILabel *time=[[UILabel alloc]init];
    time.frame=CGRectMake(120, 40, 100, 30);
    time.backgroundColor=[UIColor clearColor];
    time.font=[UIFont systemFontOfSize:11];
    //获得系统日期
    NSDate * senddate=[NSDate date];
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];

    time.text=[NSString stringWithFormat:@"%d年-%d月-%d日",year,month,day];
    //add background
    UIImageView *headBack=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    headBack.image=[UIImage imageNamed:@"back.png"];
    
    [headBack addSubview:time];
    [headBack addSubview:Classname];
    [headBack addSubview:name];
    [head addSubview:headBack];
    self.tableView.tableHeaderView=head;


    //
//    UIButton *one=[UIButton buttonWithType:UIButtonTypeCustom];
//    one.backgroundColor=[UIColor blackColor];
//    one.frame=CGRectMake(0, 0, 44, 44);
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:nil action:nil];
    UIToolbar *tool=[[UIToolbar alloc]init];
    tool.frame=CGRectMake(0,self.view.frame.size.height - tool.frame.size.height - 44-60.0, 320, 44);
    tool.barStyle=UIBarStyleDefault;
    tool.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [tool setItems:[NSArray arrayWithObject:addButton]];
    //[self.tableView addSubview:tool];
    [self.view insertSubview:tool aboveSubview:self.tableView];
    //[self.tableView bringSubviewToFront:tool];
   
    //[self.view.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    //self.tableView.hidden=YES;
     [self PoptheViewAllOverScreen];
    data=[[NSMutableArray alloc] init];
    for (int i=0; i<30; i++) {
        [data addObject:[NSString stringWithFormat:@"黄晓明＋%d",i]];
    }

   }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *StudCellIdentifier = @"StudCell";
    StudCell *cell = [tableView dequeueReusableCellWithIdentifier:StudCellIdentifier];
    if (cell == nil) {
        cell = [[StudCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StudCellIdentifier];
        cell.delegate=self;
    }
//    [self.tableView registerClass:[StudCell class] forCellReuseIdentifier:@"StudCell"];
//    static NSString *Identifier = @"StudCell";
//    StudCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier forIndexPath:indexPath];
    cell.imageView.image=[UIImage imageNamed:@"11.png"];
    cell.textLabel.text=[data objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cliclAtRow:%d,status:",indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma buttonClickDelegate
-(void)ClickTheStatusBtnFrom:(StudCell *)sCell withTheStus:(NSString*)Status
{
  
    if ([Status isEqualToString:@"每位同学只能一个到勤状态"]) {
        [self.view makeToast:@"每位同学只能有一个到勤状态"];
    }else{
    [self.view makeToast:[NSString stringWithFormat:@"%@同学现在\n    已%@",sCell.textLabel.text,Status]];
    }
}

@end
