//
//  DisplayingImageViewController.m
//  Quix
//
//  Created by Xiao Ming Liu on 5/1/2016.
//  Copyright © 2016 self. All rights reserved.
//

#import "DisplayingImageViewController.h"

@interface DisplayingImageViewController(){
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imageV;

@end

@implementation DisplayingImageViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.image != nil) {
        [self.imageV setImage:self.image];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}



@end
