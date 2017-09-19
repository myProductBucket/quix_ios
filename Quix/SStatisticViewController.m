//
//  SStatisticViewController.m
//  Quix
//
//  Created by Karl Faust on 12/18/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "SStatisticViewController.h"
#import "MFSideMenu.h"

@interface SStatisticViewController (){
    
}
@property (weak, nonatomic) IBOutlet UILabel *quizSolvedLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *highestScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionSolvedLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageTimeLabel;

@end

@implementation SStatisticViewController

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
    
    self.title = NSLocalizedString(@"Statistic", nil);
    //setup menu
    [self setupMenuBarButtonItems];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //show statistic
    [self showExamStatistic];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSInteger myFont = self.quizSolvedLabel.frame.size.width * 50 / 211;
    [self.questionSolvedLabel setFont:[UIFont systemFontOfSize:myFont]];
    [self.quizSolvedLabel setFont:[UIFont systemFontOfSize:myFont]];
    [self.highestScoreLabel setFont:[UIFont systemFontOfSize:myFont]];
    [self.correctLabel setFont:[UIFont systemFontOfSize:myFont]];
    [self.averageScoreLabel setFont:[UIFont systemFontOfSize:myFont]];
    [self.averageTimeLabel setFont:[UIFont systemFontOfSize:myFont]];
    
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

#pragma mark - Custom Method

- (void)showExamStatistic {
    //Quiz_Solved
    if ([[NSUserDefaults standardUserDefaults] objectForKey:QUIZ_SOLVED]) {
        [self.quizSolvedLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:QUIZ_SOLVED]];
    }else{
        [self.quizSolvedLabel setText:@"0"];
    }

    //Average_Score
    if ([[NSUserDefaults standardUserDefaults] objectForKey:AVERAGE_SCORE]) {
        [self.averageScoreLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:AVERAGE_SCORE]];
    }else{
        [self.averageScoreLabel setText:@"0"];
    }
    
    //Highest_Score
    if ([[NSUserDefaults standardUserDefaults] objectForKey:HIGHEST_SCORE]) {
        [self.highestScoreLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:HIGHEST_SCORE]];
    }else{
        [self.highestScoreLabel setText:@"0"];
    }

    //Correct
    if ([[NSUserDefaults standardUserDefaults] objectForKey:CORRECT]) {
        [self.correctLabel setText:[NSString stringWithFormat:@"%%%@", [[NSUserDefaults standardUserDefaults] objectForKey:CORRECT]]];
    }else{
        [self.correctLabel setText:@"%0"];
    }

    //Questions_Solved
    if ([[NSUserDefaults standardUserDefaults] objectForKey:QUESTIONS_SOLVED]) {
        [self.questionSolvedLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:QUESTIONS_SOLVED]];
    }else{
        [self.questionSolvedLabel setText:@"0"];
    }

    //Average QuizTime
    NSInteger averageTime = [[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:AVERAGE_QUIZTIME]] intValue];
    NSString *averageStr = @"";
    if ((averageTime % 60) < 10) {
        averageStr = [NSString stringWithFormat:@"%d:0%d", (uint)(averageTime / 60), (uint)(averageTime % 60)];
    }else{
        averageStr = [NSString stringWithFormat:@"%d:%d", (uint)(averageTime / 60), (uint)(averageTime % 60)];
    }
    [self.averageTimeLabel setText:averageStr];
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
