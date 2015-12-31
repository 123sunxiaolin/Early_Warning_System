//
//  CheckStudentsTable.m
//  Attendance
//
//  Created by kys-2 on 14-5-7.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "CheckStudentsTable.h"
#import "Check_StudentsCell.h"
#import "Defines.h"
@interface CheckStudentsTable ()

@end

@implementation CheckStudentsTable
@synthesize StudentNumber;
@synthesize StudentNameArr;
@synthesize StudentStatus;
@synthesize S_class;
@synthesize S_date;
@synthesize S_lesson;
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
    [self initToolBar];
    Table_Students=[[UITableView alloc]initWithFrame:CGRectMake(0, 70, 320,ScreenHeight-120)];
    Table_Students.delegate=self;
    Table_Students.dataSource=self;
    [self.view addSubview:Table_Students];
    [self initHeadViewFortable];
	
}
-(void)initHeadViewFortable
{
    //添加headView
    UIView *head=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    UILabel *Classname=[[UILabel alloc]init];
    Classname.frame=CGRectMake(35, 10, 70, 30);
    Classname.backgroundColor=[UIColor clearColor];
    Classname.font=[UIFont systemFontOfSize:12];
    Classname.textColor=[UIColor blackColor];
    Classname.text=@"当前课程:";
    UILabel *name=[[UILabel alloc]init];
    name.frame=CGRectMake(100, 10, 150, 30);
    name.textColor=[UIColor blueColor];
    name.backgroundColor=[UIColor clearColor];
    //[name.layer setBorderColor:[UIColor grayColor].CGColor];
    //[name.layer setBorderWidth:2.0];
   // [name.layer setCornerRadius:5.0];
    name.font=[UIFont systemFontOfSize:15];
    name.textAlignment=NSTextAlignmentCenter;
    //name.text=@"计算机组成原理与设计";
    name.text=S_lesson;
    //
    UILabel *time=[[UILabel alloc]init];
    time.frame=CGRectMake(120, 40, 100, 30);
    time.backgroundColor=[UIColor clearColor];
    time.font=[UIFont systemFontOfSize:11];
    //获得系统日期
   /* NSDate * senddate=[NSDate date];
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    
    time.text=[NSString stringWithFormat:@"%d年-%d月-%d日",year,month,day];*/
    time.text=S_date;
    //add background
    UIImageView *headBack=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    headBack.image=[UIImage imageNamed:@"back.png"];
    
    [headBack addSubview:time];
    [headBack addSubview:Classname];
    [headBack addSubview:name];
    [head addSubview:headBack];
    Table_Students.tableHeaderView=head;

}
-(void)initToolBar
{
    UIToolbar *tool=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
    tool.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"Nback.png"]];
    UILabel *Class_checked=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    Class_checked.textAlignment=NSTextAlignmentCenter;
    Class_checked.font=[UIFont fontWithName:@"Comic Sans Ms" size:15];
    Class_checked.center=tool.center;
    Class_checked.text=S_class;
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(320-50, 10, 50, 50);
    [back setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(BackToFrontView) forControlEvents:UIControlEventTouchUpInside];
    [tool addSubview:back];
    [tool addSubview:Class_checked];
    [self.view addSubview:tool];
}
-(void)BackToFrontView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [StudentNameArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Check_StudentsCell";
    Check_StudentsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[Check_StudentsCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.userInteractionEnabled=NO;
    cell.textLabel.text=[StudentNameArr objectAtIndex:indexPath.row];
     NSString *touxiang_URL=[_StudentTouxiangArr objectAtIndex:indexPath.row];
    if (![touxiang_URL isKindOfClass:[NSNull class]]) {
        /*
         [avaterImageView setImageURL:touxiang_URL];
         [StudTable addSubview:avaterImageView];*/
        [cell.paimageview setImageURL:touxiang_URL];
        cell.imageView.image=[UIImage  imageNamed:@"11.png"];
    }else{
        cell.imageView.image=[UIImage  imageNamed:@"11.png"];
    }

    cell.detailTextLabel.text=[StudentNumber objectAtIndex:indexPath.row];
    cell.StatusLable.text=[StudentStatus objectAtIndex:indexPath.row];

    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
