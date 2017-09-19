//
//  TResultViewController.m
//  Quix
//
//  Created by Karl Faust on 12/18/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "TResultViewController.h"
#import "MFSideMenu.h"

#import "TResultCell.h"
#import "TResultHeaderCell.h"

#import "TResultSubViewController.h"

#import "AppDelegate.h"

@interface TResultViewController ()<UITableViewDelegate, UITableViewDataSource>{
    BOOL isGuest;
    
    NSMutableArray *quizArray;//the set of the Quiz
    NSMutableArray *resultsArray;
    NSString *MY_USERID;
}


@property (weak, nonatomic) IBOutlet UITableView *myTable;


@end

@implementation TResultViewController

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
    
    self.title = NSLocalizedString(@"Results", nil);
    //setup menu
    [self setupMenuBarButtonItems];
    
    //----getting quiz result(array)
    AppDelegate *myDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (myDel.isGuest == NO) {//If you are Admin
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:USERID]) {
            MY_USERID = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
        }else{
            MY_USERID = TESTUSERID;
        }
        
        [self httpGetQuiz];
    }else{//If you are Guest
        //        MY_ID = TESTUSERID;
        //        [self httpGetQuiz];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return NO;
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

#pragma mark - Tableview Delegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return quizArray.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 74;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TResultHeaderCell *headerCell = (TResultHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"TResultHeaderCell"];
//    NSUserDefaults *curUser = [NSUserDefaults standardUserDefaults];
   
    headerCell.nameLabel.text = NSLocalizedString(@"My Exams", nil);//the name of the Teacher
    headerCell.reportIcon.image = [UIImage imageNamed:@"ic_question.png"];
    headerCell.numvberOf.text = [NSString stringWithFormat:NSLocalizedString(@"%lu Quizzes", nil), (unsigned long)quizArray.count];
    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TResultCell *quizCell = (TResultCell *)[self.myTable dequeueReusableCellWithIdentifier:@"TResultCell"];
    quizCell.numLabel.text = [NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)];
    NSMutableDictionary *currentQuiz = quizArray[indexPath.row];
    quizCell.quizLabel.text = [currentQuiz objectForKey:QUIZNAME];
    quizCell.shareButton.tag = indexPath.row;
    quizCell.resultButton.tag = indexPath.row;
    
    if (indexPath.row == (quizArray.count - 1)) {
        [ProgressHUD dismiss];
    }
    
    return quizCell;
}

#pragma mark - Custom Event Method

- (IBAction)shareTouchUp:(UIButton *)sender {
    NSMutableDictionary *selectedQuiz = quizArray[sender.tag];
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Share this ID(%@) with your students", nil), [selectedQuiz objectForKey:QUIZID]];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Share ID", nil)
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* copy = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Copy to Clipboard", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
//                             [[NSUserDefaults standardUserDefaults] setObject:[selectedQuiz objectForKey:QUIZID] forKey:COPYEDQUIZID];
                             UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                             [pasteBoard setString:[selectedQuiz objectForKey:QUIZID]];
                             [self showMessage];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Cancel", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:copy];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)resultTouchUp:(UIButton *)sender {
    NSMutableDictionary *selectedQuiz = quizArray[sender.tag];
    NSString *quizID = [selectedQuiz objectForKey:QUIZID];
//    [self httpGetResult:quizID];
    
    if (quizID == nil || [quizID checkText] == NO) {
        [self showWarningAlert:NSLocalizedString(@"There is no data for this Quiz", nil)];
        return;
    }
    
    //display the TResultSubViewController
    TResultSubViewController *tResultSubVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TResultSubViewController"];
    [tResultSubVC setCurrentQuizID:quizID quizName:[selectedQuiz objectForKey:QUIZNAME]];
    [self.navigationController pushViewController:tResultSubVC animated:true];
    
}


#pragma mark - http AF Networking Custom Method

- (void) httpGetQuiz {
    //    if ([curUser objectForKey:USERID] == nil) {
    //        return;
    //    }
    [ProgressHUD show:NSLocalizedString(@"Loading", nil) Interaction:NO];
    quizArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:MY_USERID forKey:@"account_id"];//forKey:[curUser objectForKey:USERID]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, GETQUIZES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        NSMutableArray *resArray = [responseObject mutableCopy];
        for (int i = 0; i < resArray.count; i++) {
            NSMutableDictionary *dic = [resArray[i] mutableCopy];
            [quizArray addObject:dic];
        }
        
        [self.myTable reloadData];
        [ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"The network has some problems. Please try again!"]];
        [ProgressHUD dismiss];
    }];
}


#pragma mark - Custome Methods

- (void)showWarningAlert: (NSString *)msg{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
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

- (void)showMessage {
    NSString *msg = NSLocalizedString(@"Quiz ID copied, now share it with your students", nil);
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alert dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"Do some work");
    });
    
    //copy Quiz ID.
}


- (void)showResults {
    NSString *resultStr = @"";
    for (NSMutableDictionary *dic in resultsArray) {
        NSMutableDictionary *resultsDic = [dic objectForKey:@"results"];
        if ([resultsDic objectForKey:@"student_name"]) {
            resultStr = [NSString stringWithFormat:NSLocalizedString(@"%@\nStudent Name: %@", nil), resultStr, [resultsDic objectForKey:@"student_name"]];
        }
        if ([resultsDic objectForKey:@"score"]) {
            resultStr = [NSString stringWithFormat:NSLocalizedString(@"%@\nScore: %@", nil), resultStr, [resultsDic objectForKey:@"score"]];
        }
        if ([resultsDic objectForKey:@"correct_count"]) {
            resultStr = [NSString stringWithFormat:NSLocalizedString(@"%@\nCorrect Count: %@", nil), resultStr, [resultsDic objectForKey:@"correct_count"]];
        }
        if ([resultsDic objectForKey:@"total_question"]) {
            resultStr = [NSString stringWithFormat:NSLocalizedString(@"%@\nTotal Question: %@", nil), resultStr, [resultsDic objectForKey:@"total_question"]];
        }
        resultStr = [NSString stringWithFormat:@"%@\n", resultStr];
    }
    
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
