//
//  MusicViewController.h
//  Music Search
//
//  Created by Yike Xue on 8/31/15.
//  Copyright (c) 2015 Yike Xue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicViewController : UIViewController

@property (strong, nonatomic) NSString *musicName;
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSString *albumName;
@property (strong, nonatomic) UIImage *albumImage;
@property (weak, nonatomic) IBOutlet UIImageView *albumImg;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *lyricsTextView;

@end
