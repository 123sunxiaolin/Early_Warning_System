//
//  FKRSearchBarTableViewController.m
//  TableViewSearchBar
//
//  Created by Fabian Kreiser on 10.02.13.
//  Copyright (c) 2013 Fabian Kreiser. All rights reserved.
//

#import "FKRSearchBarTableViewController.h"
#import "iToast.h"
static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";

@interface FKRSearchBarTableViewController () {
    
}

@property(nonatomic, copy) NSArray *famousPersons;


@property(nonatomic, copy) NSArray *filteredPersons;
@property(nonatomic, copy) NSArray *sections;

@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;

@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController; // UIViewController doesn't retain the search display controller if it's created programmatically: http://openradar.appspot.com/10254897

@end

@implementation FKRSearchBarTableViewController
@synthesize NeedData,contacts,identifer,headimages;
#pragma mark - Initializer


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([identifer isEqualToString:@"leader"]) {
        NeedData=[[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"leaders"]];
        contacts=[[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderContact"]];
    }
    else if ([identifer isEqualToString:@"header"])
    {
        NeedData=[[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"headers"]];
        contacts=[[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"headerContact"]];
    }
    else
    {
        NeedData=[[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"students"]];
        contacts=[[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"studContact"]];
        //headimages=[[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"studImages"]];
        
    }
    
     _famousPersons=[NSArray arrayWithArray:NeedData];
     _showSectionIndexes=YES;
        UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
        
        NSMutableArray *unsortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
        for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++) {
            [unsortedSections addObject:[NSMutableArray array]];
        }
        
        for (NSString *personName in self.famousPersons) {
            NSInteger index = [collation sectionForObject:personName collationStringSelector:@selector(description)];
            [[unsortedSections objectAtIndex:index] addObject:personName];
        }
        
        NSMutableArray *sortedSections = [[NSMutableArray alloc] initWithCapacity:unsortedSections.count];
        for (NSMutableArray *section in unsortedSections) {
            [sortedSections addObject:[collation sortedArrayFromArray:section collationStringSelector:@selector(description)]];
        }
        
    self.sections = sortedSections;
    

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = @"搜索联系人";
    self.searchBar.delegate = self;
    
    [self.searchBar sizeToFit];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated) {
        [self.tableView flashScrollIndicators];
    }
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
    NSAssert(YES, @"This method should be handled by a subclass!");
}

#pragma mark - TableView Delegate and DataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView && self.showSectionIndexes) {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView && self.showSectionIndexes) {
        if ([[self.sections objectAtIndex:section] count] > 0) {
            return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch]) {
        [self scrollTableViewToSearchBarAnimated:NO];
        return NSNotFound;
    } else {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] - 1; // -1 because we add the search symbol
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"11111111111==%@",_famousPersons);
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            return self.sections.count;
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            return [[self.sections objectAtIndex:section] count];
        } else {
            return self.famousPersons.count;
        }
    } else {
        return self.filteredPersons.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    messageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[messageCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                reuseIdentifier:CellIdentifier];
       cell.imageView.image=[UIImage imageNamed:@"11.png"];

        [cell.IphoneBtn setImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
        [cell.MessageBtn setImage:[UIImage imageNamed:@"message.png"] forState:UIControlStateNormal];
        cell.delegate=self;
    }
    //cell.detailTextLabel.text=[contacts objectAtIndex:indexPath.row];
    if (tableView == self.tableView) {
        if (self.showSectionIndexes) {
            cell.textLabel.text = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        } else {
            cell.textLabel.text = [self.famousPersons objectAtIndex:indexPath.row];
        }
    } else {
        cell.textLabel.text = [self.filteredPersons objectAtIndex:indexPath.row];
    }
    //解决联系人与头像不对应的问题
    /*NSMutableDictionary *imageDic=[[NSMutableDictionary alloc]initWithObjects:headimages forKeys:_famousPersons];
    if (![[imageDic valueForKey:cell.textLabel.text] isKindOfClass:[NSNull class]]) {
        [cell.headimageview setImageURL:[imageDic valueForKey:cell.textLabel.text]];
        cell.imageView.image=[UIImage  imageNamed:@"11.png"];
    }else{
        cell.imageView.image=[UIImage  imageNamed:@"11.png"];
    }*/

    //解决联系人与电话不对应的问题
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithObjects:contacts forKeys:_famousPersons];

    cell.detailTextLabel.text=[dic objectForKey:cell.textLabel.text];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark--cellClickDelegate
-(void)ClickAtContactNumberFrom:(messageCell *)BtnCell WithTheFunction:(NSString *)FunTape
{
   
    if ([FunTape isEqualToString:@"Iphone"]) {
        @try {
            NSString *phone=[NSString stringWithFormat:@"%@",BtnCell.detailTextLabel.text];
            if (phone != nil) {
                NSString *telUrl = [NSString stringWithFormat:@"telprompt:%@",phone];
                NSURL *url = [[NSURL alloc] initWithString:telUrl];
                [[UIApplication sharedApplication] openURL:url];
            }
            [self alertWithTitle:@"提示信息" msg:@"设备没有电话功能"];
        }
        @catch (NSException *exception) {
            [iToast make:[NSString stringWithFormat:@"拨打电话错误 %@",exception] duration:1000];
            NSLog(@"拨打电话错误==Exception: %@", exception);
        }
        @finally {
        }
       
    }else
    {//调用系统发短信的方法
        numberForMessage=[NSString stringWithFormat:@"%@",BtnCell.detailTextLabel.text];
        NameForMessage=[NSString stringWithFormat:@"%@",BtnCell.textLabel.text];
        [self showMessageView];
        
    }
    
    NSLog(@"%@－－%@--%@",BtnCell.textLabel.text,BtnCell.detailTextLabel.text,FunTape);
}
#pragma mark--MessageDelegate
- (void)showMessageView
{
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:numberForMessage];
        controller.body = @"欢迎使用河北北方学院预警系统";
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:NameForMessage];//修改短信界面标题
    }else{
        
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}


//MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:nil];//关键的一句   不能为YES
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            
            [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            break;
        case MessageComposeResultSent:
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        default:
            break;
    }
}


- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    
    [alert show];  
    
}
#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = self.famousPersons;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredPersons = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.filteredPersons = [self.filteredPersons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
    
    return YES;
}

@end