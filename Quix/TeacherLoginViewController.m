//
//  TeacherLoginViewController.m
//  Quix
//
//  Created by Karl Faust on 12/17/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "TeacherLoginViewController.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface TeacherLoginViewController (){
    BOOL isGuest;
}
@property (weak, nonatomic) IBOutlet UILabel *googleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fbLabel;
@property (weak, nonatomic) IBOutlet UIButton *guestButton;

@end

@implementation TeacherLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [GIDSignIn sharedInstance].uiDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSInteger myFont = self.googleLabel.frame.size.width * 13 / 158;
    [self.googleLabel setFont:[UIFont systemFontOfSize:myFont]];
    [self.fbLabel setFont:[UIFont systemFontOfSize:myFont]];
    [self.guestButton.titleLabel setFont:[UIFont systemFontOfSize:myFont]];
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


- (IBAction)googleLoginTouchUp:(id)sender {
    [ProgressHUD show:@"" Interaction:NO];
    [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)facebookLoginTouchUp:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [login logInWithReadPermissions: @[@"public_profile"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"%@", error);
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             isGuest =false;
             
             NSLog(@"%@", result);
             NSLog(@"Logged in");
             //Todo
             [[[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"id, name, picture.type(large),email, birthday, bio"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 NSDictionary *userData = (NSDictionary*)result;
                 NSLog(@"userData = %@", userData);
                 NSUserDefaults *me = [NSUserDefaults standardUserDefaults];
                 [me setObject:userData[@"email"] forKey:USEREMAIL];
                 [me setObject:userData[@"id"] forKey:USERID];
                 [me setObject:userData[@"name"] forKey:USERNAME];
                 [me setObject:userData[@"picture"][@"data"][@"url"] forKey:USERPHOTOURL];
                 
//                 NSData *data = [NSData dataWithContentsOfURL:pictureURL];
//                 PFFile *file = [PFFile fileWithData:data];
//                 user[@"avatar"] = file;
//                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                     [ProgressHUD dismiss];
//                     if((succeeded == TRUE) && (error == nil)){
//                         [self goToLocationVC];
//                     }else{
//                         [self createAlert:@"Error" withMessage:@"An error occurred in facebook login.\nPlease try again later!"];
//                     }
//                 }];
                 [self teacherLogin];
             }];
             
         }
     }];
}

- (IBAction)guestLoginTouchUp:(id)sender {
    isGuest = true;
//    NSUserDefaults *myInfo = [NSUserDefaults standardUserDefaults];
//    NSInteger guestID = random() * 10000000000 + 9999999999;
//    [myInfo setObject:[NSString stringWithFormat:@"%ld", (long)guestID] forKey:USERID];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:NSLocalizedString(@"You can use the app through Guest User, but you need to login via Google or Facebook accounts to be able to save your quizzes", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self teacherLogin];
                             [alert dismissViewControllerAnimated:YES completion:nil];

                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Cancel", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)teacherLogin {
    
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del setRootMenu:true isGuest:isGuest];//if true , user is teacher
}

- (void)registerUser {
    NSURL *URL = [NSURL URLWithString:ROOTURL];
    NSDictionary *parameters = @{@"json": @"json"};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
//    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"format": @"json"};
//    
//    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
//    jsonReponseSerializer.acceptableContentTypes = nil;
//    manager.responseSerializer = jsonReponseSerializer;
//    
//    NSString *url = [NSString stringWithFormat:@"%@/register.php", ROOTURL];
//    
//    [ProgressHUD show:@"" Interaction:YES];
//    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        [ProgressHUD dismiss];
//        NSLog(@"%@", responseObject);
//        if ([responseObject[@"status"] isEqualToString:@"success"]) {
//            
//            id dataAry = responseObject[@"data"];
//            if (dataAry == [NSNull null]) {
//                [ProgressHUD show:@"No games!" Interaction:NO];
//
//            }else{
//
//
//            }
//            
//        }else{
//            [ProgressHUD showError:@"Get data Failed!" Interaction:NO];
//
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [ProgressHUD dismiss];
//
//    }];

}

#pragma mark - Google Sign In
// Stop the UIActivityIndicatorView animation that was started when the user
// pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
//    [myActivityIndicator stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
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
