//
//  MusicViewController.m
//  Music Search
//
//  Created by Yike Xue on 8/31/15.
//  Copyright (c) 2015 Yike Xue. All rights reserved.
//

#import "MusicViewController.h"

@interface MusicViewController ()
@property (nonatomic) NSString *songData;
@property (nonatomic) NSURLSession *apiSession;
@end

@implementation MusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Lyrics";
    self.albumImg.image = self.albumImage;
    self.trackNameLabel.text = self.musicName;
    self.artistNameLabel.text = self.artistName;
    self.albumNameLabel.text = self.albumName;

    NSURLSessionConfiguration *apiSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [apiSessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    apiSessionConfig.timeoutIntervalForRequest = 30.0;
    apiSessionConfig.timeoutIntervalForResource = 60.0;
    self.apiSession = [NSURLSession sessionWithConfiguration:apiSessionConfig
                                                    delegate:nil
                                               delegateQueue:[NSOperationQueue mainQueue]];
    [self getSongData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getSongData {
    //The spinner indicated the process of data downloading, use the right bar button on NavigationItem
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    spinner.hidesWhenStopped = YES;
    NSLog(@"%@",self.artistName);
    NSString *url = [NSString stringWithFormat:@"http://lyrics.wikia.com/api.php?func=getSong&artist=%@&song=%@&fmt=json",@"Tom+Waits",@"new+coat+of+paint"];
    //Get the music list with url+keyword
    [[self.apiSession dataTaskWithURL:[NSURL URLWithString:url]
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (!error) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                            if (httpResponse.statusCode == 200) {
                                NSError *jsonError;
                                //Because the return json text did not start with array or object, instead, it's "song=". We should add the "{}" before json parsing
                                
                                NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
                                NSLog(@"%@",[result substringFromIndex:7]);
                                NSData *newData = [[result substringFromIndex:7] dataUsingEncoding:NSUTF8StringEncoding];
                                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:newData
                                                                                         options:NSJSONReadingAllowFragments
                                                                                           error:&jsonError];
                                if (!jsonError) {
                                    //If getting data without error:
          
                                    //Following is a printout for test, comment it after test
                                    NSLog(@"data fetched:\n%@",jsonData);
//                                    self.lyricsUrl = [jsonData objectForKey:@"url"];
                                    NSString *lyrics = [jsonData objectForKey:@"lyrics"];
                                    if(lyrics != nil &&[lyrics length] > 0){
                                        self.lyricsTextView .text = lyrics;
                                    }else{
                                        self.lyricsTextView .text = @"Found no lyrics!";
                                    }
                                }else{
                                    NSLog(@"Error:%@",jsonError);
                                }
                            }
                        }
                        [spinner stopAnimating];
                    }] resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
