//
//  ViewController.m
//  Quix
//
//  Created by Karl Faust on 12/17/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "ViewController.h"
#import "TeacherLoginViewController.h"
#import "AppDelegate.h"
//#import <GoogleSignIn/GoogleSignIn.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageV;
@property (weak, nonatomic) IBOutlet UILabel *studentLabel;
@property (weak, nonatomic) IBOutlet UILabel *stuDescription;
@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *teaDescription;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.backGroundImageV setHidden:false];
    // Do any additional setup after loading the view, typically from a nib.
//    NSLog(@"%@", NSLocalizedString(@"To take quizzes\nlogin here", nil));
    [self.stuDescription setText:NSLocalizedString(@"To take quizzes\nlogin here", nil)];
    [self.teaDescription setText:NSLocalizedString(@"To create quizzes\nlogin here", nil)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (BOOL)shouldAutorotate {
//    return NO;
//}

- (IBAction)studentLoginTouchUp:(id)sender {
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del setRootMenu:false isGuest:false];//if false , user is student
}

- (IBAction)teacherLoginTouchUp:(id)sender {
    TeacherLoginViewController *teacherLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"teacherLoginView"];
    
    [self presentViewController:teacherLoginVC animated:true completion:nil];
}

@end
