//
//  HasSignedStudents.m
//  Attendance
//
//  Created by kys-2 on 14-4-22.
//  Copyright (c) 2014年 kys-2. All rights reserved.
//

#import "HasSignedStudents.h"

@interface HasSignedStudents ()

@end

@implementation HasSignedStudents
@synthesize studArr,statusArray;
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
    //studArr=[[NSArray alloc]init];
    //statusArray=[[NSArray alloc]init];
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

    return studArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
    }
    cell.imageView.image=[UIImage imageNamed:@"11.png"];
    cell.textLabel.text=[studArr objectAtIndex:indexPath.row];
    cell.detailTextLabel.text=[statusArray objectAtIndex:indexPath.row];
    
    return cell;
}


@end
