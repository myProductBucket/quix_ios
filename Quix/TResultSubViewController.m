//
//  TResultSubViewController.m
//  Quix
//
//  Created by Xiao Ming Liu on 15/1/2016.
//  Copyright © 2016 self. All rights reserved.
//

#import "TResultSubViewController.h"
#import "TResultSubCell.h"
#import "TResultQuestionViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TResultSubViewController()<UITableViewDataSource, UITableViewDelegate> {
    NSString *selectedQuizID;
    NSString *selectedQuizName;
    NSMutableArray *resultsArray;
    NSString *MY_USERID;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation TResultSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = selectedQuizName;
    
//    [self showAlertWithTitle:@"" message:@"Perfect"];
    if (selectedQuizID == nil) {
        [self showAlertWithTitle:@"Alert" message:NSLocalizedString(@"There is no data for this Quiz", nil)];
        return;
    }
    [self httpGetResult:selectedQuizID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.myTableView reloadData];
    
    [self.myTableView layoutIfNeeded];
}

- (void)setCurrentQuizID: (NSString *)quizID quizName: (NSString *)quizName{
    selectedQuizID = quizID;
    selectedQuizName = quizName;
}

#pragma mark - UITableViewDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultsArray.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    TResultHeaderCell *headerCell = (TResultHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"TResultHeaderCell"];
//    //    NSUserDefaults *curUser = [NSUserDefaults standardUserDefaults];
//    
//    headerCell.nameLabel.text = @"My Exams";//the name of the Teacher
//    headerCell.reportIcon.image = [UIImage imageNamed:@"ic_question.png"];
//    headerCell.numvberOf.text = [NSString stringWithFormat:@"%lu Quizes", (unsigned long)quizArray.count];
//    return headerCell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= resultsArray.count) {
        return nil;
    }
    NSMutableDictionary *studentInfo = [resultsArray[indexPath.row] objectForKey:@"results"];
    
    TResultSubCell *resultCell = (TResultSubCell *)[self.myTableView dequeueReusableCellWithIdentifier:@"TResultSubCell"];
    
//        Adds a shadow to sampleView
    [resultCell.contentV setFrame:CGRectMake(8, 8, self.myTableView.frame.size.width - 16, 114)];
    NSLog(@"%f", self.myTableView.frame.size.width);
    NSLog(@"%f", resultCell.contentV.frame.size.width);
    CALayer *layer = resultCell.contentV.layer;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 4.0f;
    layer.shadowOpacity = 0.80f;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
    [layer setCornerRadius:4.0f];
    
    //set the student name
    [resultCell.nameLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Name : %@", nil), [studentInfo objectForKey:@"student_name"]]];
    //set the time
    [resultCell.timeLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Time : %d (s)", nil), [[studentInfo objectForKey:@"time"] intValue]]];
    //set the correct Count
    [resultCell.correctCountLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Correct/Total : %d / %d", nil), [[studentInfo objectForKey:@"correct_count"] intValue], [[studentInfo objectForKey:@"total_question"] intValue]]];
    //set the score
    [resultCell.scoreLabel setText:[NSString stringWithFormat:@"%d", [[studentInfo objectForKey:@"score"] intValue]]];
    [resultCell.resultButton setTag:indexPath.row];
    
    return resultCell;
}

- (IBAction)resultsTouchUp:(id)sender {
    NSInteger index = ((UIButton *)sender).tag;
    NSMutableArray *questionResults = [resultsArray[index] objectForKey:@"questions"];
    NSMutableDictionary *studentInfo = [resultsArray[index] objectForKey:@"results"];
    
    TResultQuestionViewController *questVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TResultQuestionViewController"];
    [questVC setQuestionResultWithName:[studentInfo objectForKey:@"student_name"] questionResults:questionResults];
    [self.navigationController pushViewController:questVC animated:YES];
}


#pragma mark - Custom Method

- (void)showAlertWithTitle: (NSString *)title message: (NSString *)msg{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
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

#pragma mark - http AfNetworking -- getting Resutls corresponding QuizID
- (void)httpGetResult: (NSString *)quizID {
    [ProgressHUD show:@"Loading..." Interaction:NO];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:quizID forKey:@"quiz_id"];
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, GETRESULTS];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        resultsArray = [[NSMutableArray alloc] init];
        
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        NSMutableArray *array = [responseObject mutableCopy];
        for (int i = 0; i < array.count; i++) {
            NSMutableDictionary *dic = [array[i] mutableCopy];
            NSMutableDictionary *newDic;
            NSMutableDictionary *results = [[dic objectForKey:@"results"] mutableCopy];
            NSMutableDictionary *questions = [[dic objectForKey:@"questions"] mutableCopy];
            newDic = [NSMutableDictionary dictionaryWithObjects:@[results, questions] forKeys:@[@"results", @"questions"]];
            [resultsArray addObject:newDic];
        }
        NSLog(@"%@", resultsArray);
        
        [self.myTableView reloadData];

        [ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self showAlertWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"There is no data for this Quiz", nil)]];
        [ProgressHUD dismiss];
    }];
}

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



@end
