//
//  FKRSearchBarTableViewController.h
//  TableViewSearchBar
//
//  Created by Fabian Kreiser on 10.02.13.
//  Copyright (c) 2013 Fabian Kreiser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messageCell.h"
#import <MessageUI/MessageUI.h>
@interface FKRSearchBarTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate,PhoneMessageDelegate,MFMessageComposeViewControllerDelegate> {
    //发送短信
    NSString *numberForMessage;
    NSString *NameForMessage;
    
}

//- (id)initWithSectionIndexes:(BOOL)showSectionIndexes;

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated; // Implemented by the subclasses

@property(nonatomic, assign, readonly) BOOL showSectionIndexes;

@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic, strong, readonly) UISearchBar *searchBar;
@property(nonatomic, copy) NSArray *NeedData;
@property(nonatomic,strong)NSArray *contacts;
@property(nonatomic,strong)NSArray *headimages;
@property(nonatomic,strong)NSString *identifer;//判断身份

@end