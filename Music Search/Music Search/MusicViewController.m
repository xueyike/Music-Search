//
//  MusicViewController.m
//  Music Search
//
//  Created by Yike Xue on 8/31/15.
//  Copyright (c) 2015 Yike Xue. All rights reserved.
//

#import "MusicViewController.h"

@interface MusicViewController ()
@property (nonatomic) NSArray *songData;
@property (nonatomic) NSURLSession *apiSession;
@property (nonatomic) NSURL *lyricsUrl;
@end

@implementation MusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Music Detail";
    self.albumImg.image = self.albumImage;
    self.trackNameLabel.text = self.musicName;
    self.artistNameLabel.text = self.artistName;
    self.albumNameLabel.text = self.albumName;

    //Use NSURLSession and set its delegateQueue as mainQueue, then the downloading process could be done in the background, when download finished, update the UI
    NSURLSessionConfiguration *apiSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [apiSessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    apiSessionConfig.timeoutIntervalForRequest = 20.0;
    apiSessionConfig.timeoutIntervalForResource = 40.0;
    self.apiSession = [NSURLSession sessionWithConfiguration:apiSessionConfig
                                                    delegate:nil
                                               delegateQueue:[NSOperationQueue mainQueue]];
    [self getSongData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    self.lyricsUrl = nil;
}

- (NSString *)paramProcess:(NSString *)originParam{
    NSString *newParam = [originParam stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return newParam;
}

- (void)getSongData {
    //The spinner indicated the process of data downloading, use the right bar button on NavigationItem
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    spinner.hidesWhenStopped = YES;
    
    NSString *url = [NSString stringWithFormat:@"http://lyrics.wikia.com/api.php?func=getSong&artist=%@&song=%@&fmt=json",[self paramProcess:self.artistName],[self paramProcess:self.musicName]];
    //Get the music list with url+keyword
    [[self.apiSession dataTaskWithURL:[NSURL URLWithString:url]
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (!error) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
                            if (httpResponse.statusCode == 200) {
                                NSError *jsonError;
                                //Because the return json data did not satisfy our NSJSONSerialization format, we need to reconstruct it. We should add the "{"song":[...]}" and replace all ' with " before json parsing
                                //If directly parse json, there is error:Error Domain=NSCocoaErrorDomain Code=3840 "The operation couldn’t be completed. (Cocoa error 3840.)"
                                
                                NSString *result = [[[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding] substringFromIndex:7] stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
                                NSString *newJson = [NSString stringWithFormat:@"{\"song\":[%@]}", result];
                                NSData *newData = [newJson dataUsingEncoding:NSUTF8StringEncoding];
                                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:newData
                                                                                         options:NSJSONReadingAllowFragments
                                                                                           error:&jsonError];
                                if (!jsonError) {
                                    //If getting data without error:
          
                                    //Following is a printout for test, comment it after test
//                                    NSLog(@"data fetched:\n%@",jsonData);
                                    
                                    self.songData = jsonData[@"song"];
                                    NSDictionary *music = self.songData[0];
                                    NSString *lyrics = [music objectForKey:@"lyrics"];
                                    if(lyrics != nil &&[lyrics length] > 9){
                                        //If lyrics not found, return "not found"--length == 8
                                        self.lyricsTextView.text = lyrics;
                                        NSString *url = [music objectForKey:@"url"];
                                        self.lyricsUrl = [NSURL URLWithString:url];
                                        self.viewMoreBtn.hidden = false;
                                    }else{
                                        self.lyricsTextView.text = @"Lyrics not found!";
                                        self.viewMoreBtn.hidden = true;
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

- (IBAction)tapViewMore:(id)sender {
    if(self.lyricsUrl != nil){
        NSURLRequest *request = [NSURLRequest requestWithURL:self.lyricsUrl];
        [self.webview loadRequest:request];
        self.webview.hidden = false;
        self.viewMoreBtn.hidden = true;
    }else{
        self.viewMoreBtn.hidden = true;
        self.webview.hidden = true;
    }
}
@end
