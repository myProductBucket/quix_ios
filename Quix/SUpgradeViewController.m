//
//  SUpgradeViewController.m
//  Quix
//
//  Created by Karl Faust on 12/20/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "SUpgradeViewController.h"
#import "MFSideMenu.h"
#import <StoreKit/StoreKit.h>
#import "IMOBIAPHelper.h"

@interface SUpgradeViewController (){
    SKProduct *myProduct1;
}

@end

@implementation SUpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //trasparent the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    //set title "MY PLAYZAM"
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.title = NSLocalizedString(@"Upgrade", nil);
    //setup menu
    [self setupMenuBarButtonItems];
    
    [[IMOBIAPHelper sharedInstance]requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if(products && products.count>0){
            myProduct1 = products[0];
//            myProduct2 = products[1];
//            myProduct3 = products[2];

        }
        NSLog(@"id_count = %lu", (unsigned long)products.count);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)productPurchased:(NSNotification *)notification{
    NSLog(@"success");
    int swipeCount = 1;//[[[PFUser currentUser]objectForKey:@"swipes"]intValue];
    NSLog(@"origin_swipes = %d", swipeCount);
    NSString *productIdentifier = notification.object;
    if ([productIdentifier isEqual:@"com.quix.ufuk.new"]) {
        NSUserDefaults *me = [NSUserDefaults standardUserDefaults];
        [me setObject:[NSNumber numberWithBool:YES] forKey:ISUPGRADE];
        
        [self showAlertWithTitle:NSLocalizedString(@"Congratulations!", nil) message:NSLocalizedString(@"You unlocked unlimited version of the app, now you can take unlimited quizzes", nil)];
    }else{
        
    }
    
    NSLog(@"next_swipes = %d", swipeCount);
//    PFUser *user = [PFUser currentUser];
//    user[@"swipes"] = [NSNumber numberWithInteger:swipeCount];
//    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSLog(@"success save");
//    }];
}

- (void)showAlertWithTitle: (NSString *)title message: (NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

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

- (IBAction)noThanksTouchUp:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (IBAction)upgradeTouchUp:(id)sender {
//    if (sender.tag == 100) {
//        NSLog(@"0.99");
        [[IMOBIAPHelper sharedInstance]buyProduct:myProduct1];
//    } else if (sender.tag == 101){
//        NSLog(@"3.99");
//        [[IMOBIAPHelper sharedInstance]buyProduct:myProduct2];
//    } else if (sender.tag == 102){
//        NSLog(@"6.99");
//        [[IMOBIAPHelper sharedInstance]buyProduct:myProduct3];
//    }
}

#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        //        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"Menu"] style:UIBarButtonItemStyleDone
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
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
