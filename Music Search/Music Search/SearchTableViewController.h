//
//  SearchTableViewController.h
//  Music Search
//
//  Created by Yike Xue on 8/31/15.
//  Copyright (c) 2015 Yike Xue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicViewController;
@interface SearchTableViewController : UITableViewController

@property (nonatomic) NSString *keyword;
@property (strong, nonatomic) MusicViewController *musicViewController;

@end
