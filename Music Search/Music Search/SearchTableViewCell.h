//
//  SearchTableViewCell.h
//  Music Search
//
//  Created by Yike Xue on 8/31/15.
//  Copyright (c) 2015 Yike Xue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *albumImg;
@property (weak, nonatomic) IBOutlet UILabel *trackName;
@property (weak, nonatomic) IBOutlet UILabel *artistName;
@property (weak, nonatomic) IBOutlet UILabel *albumName;

@end
