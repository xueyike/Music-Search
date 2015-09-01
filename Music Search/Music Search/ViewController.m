//
//  ViewController.m
//  Music Search
//
//  Created by Yike Xue on 8/31/15.
//  Copyright (c) 2015 Yike Xue. All rights reserved.
//

#import "ViewController.h"
#import "SearchTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapSearchBtn:(id)sender {
    //If needed, more actions could be done in this method after the prepareForSegue method
}

- (IBAction)didEndOnExit:(id)sender {
    [self resignFirstResponder];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showSearchResult"]) {
        SearchTableViewController *controller = (SearchTableViewController *)[segue destinationViewController];
        [controller setKeyword:self.keywordInput.text];
    }
}
@end
