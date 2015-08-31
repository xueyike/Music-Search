//
//  ViewController.h
//  Music Search
//
//  Created by Yike Xue on 8/31/15.
//  Copyright (c) 2015 Yike Xue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *keywordInput;

- (IBAction)tapSearchBtn:(id)sender;
- (IBAction)didEndOnExit:(id)sender;
@end

