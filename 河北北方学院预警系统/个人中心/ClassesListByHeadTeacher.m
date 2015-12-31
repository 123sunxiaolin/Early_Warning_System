//
//  ClassesListByHeadTeacher.m
//  HeadTeacher   Info Demo
//
//  Created by kys-2 on 14-5-31.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "ClassesListByHeadTeacher.h"
#import "iToast.h"
@interface ClassesListByHeadTeacher ()

@end

@implementation ClassesListByHeadTeacher
@synthesize Classlists;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //返回按钮
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(0, 0, 32, 32);
    [back setImage:[UIImage imageNamed:@"InfoCenter_back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(InfoCenter_Back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left_btn=[[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem=left_btn;
}
-(void)InfoCenter_Back
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

    return [Classlists count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        cell.userInteractionEnabled=NO;
        cell.textLabel.textColor=[UIColor blackColor];
        cell.textLabel.font=[UIFont boldSystemFontOfSize:17];
        cell.textLabel.text=[Classlists objectAtIndex:indexPath.row];
        return cell;

    }
    @catch (NSException *exception) {
        [iToast make:[NSString stringWithFormat:@"班级列表错误:%@",exception] duration:800];
        NSLog(@"查看班级列表错误");
    }
    @finally {
        NSLog(@"查看班级列表");
    
    }
    
}

@end
