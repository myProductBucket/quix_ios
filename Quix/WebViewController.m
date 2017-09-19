//
//  WebViewController.m
//  Quix
//
//  Created by Xiao Ming Liu on 14/1/2016.
//  Copyright © 2016 self. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController() {
    
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlString = @"https://www.washington.edu/oea/services/scanning_scoring/index.html";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end
