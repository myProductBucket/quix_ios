//
//  TResultQuestionViewController.m
//  Quix
//
//  Created by Xiao Ming Liu on 15/1/2016.
//  Copyright © 2016 self. All rights reserved.
//

#import "TResultQuestionViewController.h"
#import "TResultQuestionCell.h"

@interface TResultQuestionViewController()<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *questResults;
    NSString *name;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation TResultQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:name];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UITableView Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return questResults.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 184;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    TResultHeaderCell *headerCell = (TResultHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"TResultHeaderCell"];
//    //    NSUserDefaults *curUser = [NSUserDefaults standardUserDefaults];
//
//    headerCell.nameLabel.text = @"My Exams";//the name of the Teacher
//    headerCell.reportIcon.image = [UIImage imageNamed:@"ic_question.png"];
//    headerCell.numvberOf.text = [NSString stringWithFormat:@"%lu Quizzes", (unsigned long)quizArray.count];
//    return headerCell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= questResults.count) {
        return nil;
    }
    NSMutableDictionary *questionInfo = questResults[indexPath.row];
    
    TResultQuestionCell *resultCell = (TResultQuestionCell *)[self.myTableView dequeueReusableCellWithIdentifier:@"TResultQuestionCell"];
    
    //        Adds a shadow to sampleView
    [resultCell.contentV setFrame:CGRectMake(8, 8, self.myTableView.frame.size.width - 16, 168)];
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
    [resultCell.questionLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Question : %@", nil), [questionInfo objectForKey:@"question"]]];
    //set the time
    [resultCell.correctAnswerLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Correct Answer : %@", nil), [questionInfo objectForKey:@"correct_answer"]]];
    //set the correct Count
    [resultCell.firstAnswerLabel setText:[NSString stringWithFormat:NSLocalizedString(@"First Answer : %@", nil), [questionInfo objectForKey:@"users_first_answer"]]];
    
    //set the score
    NSInteger attemptNum = 0;
    if ([[questionInfo objectForKey:@"first_try_correct"] intValue] == 1) {
        attemptNum = 1;
    }else if ([[questionInfo objectForKey:@"second_try_correct"] intValue] == 1) {
        attemptNum = 2;
    }else if ([[questionInfo objectForKey:@"third_try_correct"] intValue] == 1) {
        attemptNum = 3;
    }else{
        attemptNum = 2;
    }
    [resultCell.numberOfLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Number of attempt that user found correct answer : %ld", nil), (long)attemptNum]];
    
    //set correct or uncorrect
    if ([[questionInfo objectForKey:@"isCorrect"] intValue] == 1) {
        [resultCell.statusImageV setImage:[UIImage imageNamed:@"correct_status.png"]];
    }else{
        [resultCell.statusImageV setImage:[UIImage imageNamed:@"wrong_status.png"]];
    }
    
    return resultCell;
}


#pragma mark - Custom Method

- (void)setQuestionResultWithName: (NSString *)stuName questionResults: (NSMutableArray *)array {
    questResults = array;
    name = stuName;
}

@end
