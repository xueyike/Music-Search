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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;

@end

static NSString *apiUrlString = @"https://itunes.apple.com/search?term=%@";

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.keyword;
    //Create an api session to download to music list from itunes api according to the keyword
    NSURLSessionConfiguration *apiSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [apiSessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    apiSessionConfig.timeoutIntervalForRequest = 30.0;
    apiSessionConfig.timeoutIntervalForResource = 60.0;
    self.apiSession = [NSURLSession sessionWithConfiguration:apiSessionConfig
                                                    delegate:nil
                                               delegateQueue:[NSOperationQueue mainQueue]];
    [self getSearchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getSearchData {
    //The spinner indicated the process of data downloading, use the right bar button on NavigationItem
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    spinner.hidesWhenStopped = YES;
    
    //Get the music list with url+keyword
    [[self.apiSession dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:apiUrlString,self.keyword]]
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
                                    NSLog(@"%@ data fetched:\n%@", self.musicCount,jsonData);
                                    self.musicData = jsonData[@"results"];
                                    [self.tableView reloadData];
                                }
                            }
                        }
                        self.navigationItem.rightBarButtonItem = self.reloadButton;
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
        cell.textLabel.text = @"No result found!";
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 if ([[segue identifier] isEqualToString:@"showMusic"]) {
     NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
     NSDictionary *specificMusic = self.musicData[indexPath.section];

     MusicViewController *controller = (MusicViewController *)[segue destinationViewController];

     [controller setMusicName:[specificMusic objectForKey:@"trackName"]];
     [controller setArtistName:[specificMusic objectForKey:@"artistName"]];
     [controller setAlbumName:[specificMusic objectForKey:@"collectionName"]];
     //To avoid redownloading the image, send the UIImage data to next page
     UIImageView *imageView = (UIImageView *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:1];
     UIImage *albumImage = imageView.image;
     [controller setAlbumImage:albumImage];
 }
 }

@end
