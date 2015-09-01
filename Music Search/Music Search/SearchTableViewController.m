//
//  SearchTableViewController.m
//  Music Search
//
//  Created by Yike Xue on 8/31/15.
//  Copyright (c) 2015 Yike Xue. All rights reserved.
//

#import "SearchTableViewController.h"
#import "MusicViewController.h"
#import "SearchTableViewCell.h"

@interface SearchTableViewController ()

@property (nonatomic) NSArray *musicData;
@property (nonatomic) NSNumber *musicCount;
@property (nonatomic) NSURLSession *apiSession;
@property (nonatomic) NSString *message;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;

@end

static NSString *apiUrlString = @"https://itunes.apple.com/search?term=%@";

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.keyword;
    self.message = @"Loading...";
    //Create an api session to download to music list from itunes api according to the keyword
    //Use NSURLSession and set its delegateQueue as mainQueue, then the downloading process could be done in the background, when download finished, update the UI
    NSURLSessionConfiguration *apiSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [apiSessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    apiSessionConfig.timeoutIntervalForRequest = 20.0;
    apiSessionConfig.timeoutIntervalForResource = 40.0;
    self.apiSession = [NSURLSession sessionWithConfiguration:apiSessionConfig
                                                    delegate:nil
                                               delegateQueue:[NSOperationQueue mainQueue]];
    [self getSearchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)paramProcess:(NSString *)originParam{
    //When we using the keyword as a param in the url, pay attention to change all spaces to "+".
    //There are many special symbols need to be changed in url address. Given more time, I could improve all of them but here I just change some common symbols like " + ", " \" ", " \' ", " / "
    NSString *newParam = [[[[[originParam stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"] stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"] stringByReplacingOccurrencesOfString:@"\'" withString:@"%27"] stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    return newParam;
}

- (void)getSearchData {
    //The spinner indicated the process of data downloading, use the right bar button on NavigationItem
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    spinner.hidesWhenStopped = YES;
    
    //Get the music list with url+keyword
    //Take care of the error(exeption) cases with self.message
    [[self.apiSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:apiUrlString,[self paramProcess:self.keyword]]]
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (!error) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                            if (httpResponse.statusCode == 200) {
                                NSError *jsonError;
                                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                         options:NSJSONReadingAllowFragments
                                                                                           error:&jsonError];
                                if (!jsonError) {
                                    //If getting data without error:
                                    
                                    self.musicCount = jsonData[@"resultCount"];
                                    //Following is a printout for test, comment it after test
//                                    NSLog(@"%@ data fetched:\n%@", self.musicCount,jsonData);
                                    self.musicData = jsonData[@"results"];
                                    if([self.musicData count] < 1){
                                        self.message = @"Found no result!";
                                    }
                                }else{
                                    self.message = @"Json Error!";
                                    NSLog(@"JsonError%@",jsonError);
                                }
                            }else{
                                self.message = @"Respond Error!";
                            }
                        }else{
                            self.message = @"Network Error!";
                            NSLog(@"Error:%@",error);
                        }
                        self.navigationItem.rightBarButtonItem = self.reloadButton;
                        [self.tableView reloadData];
                    }] resume];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //If no result found or not found yet, return 1
    if(self.musicCount.intValue < 1){
        return 1;
    }else{
        return self.musicCount.intValue;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if(self.musicCount.intValue < 1){
        //For the case no result found
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.textLabel.text = self.message;
        return cell;
    }else{
        //Given more time I would prefer to do the lazy loading(show a few results first and when you drag down to view more, then load more), which could save the memory and cpu very much
        SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell" forIndexPath:indexPath];
        NSDictionary *music = self.musicData[indexPath.row];
        cell.trackName.text = [music objectForKey:@"trackName"];
        cell.artistName.text = [music objectForKey:@"artistName"];
        cell.albumName.text = [music objectForKey:@"collectionName"];
        //I use the artworkUrl60(between the 30 and 100) as the album image --taking consideration of providing good quality image with appropriate speed
        NSString *imageUrlFormatString = [music objectForKey:@"artworkUrl60"];

        [[self.apiSession dataTaskWithURL:[NSURL URLWithString:imageUrlFormatString]
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                            if (!error) {
                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                                if (httpResponse.statusCode == 200) {
                                    UIImage *image = [UIImage imageWithData:data];
                                    cell.albumImg.image = image;
                                }
                            }
                        }] resume];
        return cell;
    }
}



#pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 if ([[segue identifier] isEqualToString:@"showMusic"]) {
     NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

     MusicViewController *controller = (MusicViewController *)[segue destinationViewController];

     //To avoid redownloading the image and other data, send the data to next page
     UIImageView *imageView = (UIImageView *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:1];
     UIImage *albumImage = imageView.image;
     UILabel *label1 = (UILabel *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:2];
     UILabel *label2 = (UILabel *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:3];
     UILabel *label3 = (UILabel *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:4];
     [controller setMusicName:label1.text];
     [controller setArtistName:label2.text];
     [controller setAlbumName:label3.text];
     [controller setAlbumImage:albumImage];
 }
 }

@end
