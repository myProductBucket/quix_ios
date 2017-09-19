//
//  SDashboardViewController.m
//  Quix
//
//  Created by Karl Faust on 12/18/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "SDashboardViewController.h"
#import "MFSideMenu.h"
#import "DisplayingImageViewController.h"
#import "SUpgradeViewController.h"


@interface SDashboardViewController ()<JDDroppableViewDelegate>{
    
    BOOL isEven;//ordering of the Quiz
    UIView *firstView;
    UIView *secondView;
    UIView *currentView;
    NSArray *alphaArray;//A, B, C, D
    
    NSMutableDictionary *examDic;//the whole data for exam question and quiz
    NSMutableDictionary *resultDic;//the whole data for the result of question and quiz
    
    NSMutableDictionary *quizDic;//indicating Quiz
    NSMutableDictionary *resultQuizDic;//indicating Result Quiz
    
    NSMutableArray *questionsArray;//only for question
    NSMutableArray *endQuestionResultArray;//Indicating the array of the result of the specific question
    
    NSMutableDictionary *curQuestion;//current Question
    NSMutableDictionary *curResultQuestion;//current Result Question
    NSMutableArray *answers;//current Answers
    
    NSInteger questionIndex;//indicating current question index
    
    NSInteger currentQuizType;//indicating Quiz Type(0: multiple choice, 1: multple select, 2: matching, ...)
    
    NSInteger selectedNumber;//indicating selected answers number
    
    NSInteger correctCount;//indicating the count of the correct Questions
    
    NSTimer *timer;//counting exam time
    NSInteger currentTime;//indicating current time(S)
    NSInteger examTime;//indicating exam time(S)
    
    BOOL isCorrect;
    
    //----the property For Multiple Choice
    BOOL isChecked;//if you have alrady checked the question, you have only one opinion(you can have 2 opinion)
    
    //----the property For Order
    NSMutableArray *displayedAnswers;//answers being deployed by random
    
    //startView Center Y constraint
    __weak IBOutlet NSLayoutConstraint *startViewCenterY;

}
@property (weak, nonatomic) IBOutlet UIView *startView;
@property (weak, nonatomic) IBOutlet UITextField *quizIDTextField;

@end

@implementation SDashboardViewController

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
    
    self.title = NSLocalizedString(@"Dashboard", nil);
    //setup menu
    [self setupMenuBarButtonItems];
    
    //initialize
    alphaArray = @[@"A", @"B", @"C", @"D"];
    
    //detecting the keyboard showing and hiding event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.startView setHidden:false];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    firstView = [self createView];
//    secondView = [self createView];
    NSLog(@"%f", firstView.frame.size.width);
//    [self.view addSubview:firstView];
//    [self.view addSubview:secondView];
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

//starting quiz with quiz ID
- (IBAction)startTouchUp:(id)sender {
    //checking upgrade
    NSUserDefaults *me = [NSUserDefaults standardUserDefaults];
    NSInteger num = [(NSString *)[me objectForKey:QUIZ_SOLVED] intValue];
    NSNumber *isUpgrade;
    if (![me objectForKey:ISUPGRADE]) {
        isUpgrade = [NSNumber numberWithBool:NO];
    }else{
        isUpgrade = (NSNumber *)[me objectForKey:ISUPGRADE];
    }

    if (num > LIMITEDQUIZNUM && isUpgrade == [NSNumber numberWithBool:NO]) {
        SUpgradeViewController *sUpgradeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"naviUpgrade"];
        [self.menuContainerViewController setCenterViewController:sUpgradeVC];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        return;
    }
    //---------------------------------------------------------------------------
    [self initialExamData];
    
    [self.view endEditing:true];
    //Saving Student User Name
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([userdefault objectForKey:STUDENTNAME]) {//if your name has already been saved
        questionIndex = 0;
        
        [self.startView setHidden:true];
        
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:self.quizIDTextField.text forKey:@"quiz_id"];
        [self httpGetExamQuestion:param];
    }else{
        [self saveStudentName];
    }
    ///...............
}

- (void)saveStudentName {
    UIAlertController * alert = [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Name", nil)
                                  message:NSLocalizedString(@"For once, please write your full name.", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:NSLocalizedString(@"Your full name here", nil)];
    }];
    UIAlertAction* save = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Save", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             UITextField *nameText = alert.textFields[0];
                             if ([nameText checkText:nameText]) {
                                 [[NSUserDefaults standardUserDefaults] setObject:nameText.text forKey:STUDENTNAME];
                             }else{
                                 [self showWarningAlert:NSLocalizedString(@"Enter a valid Full Name", nil)];
                             }
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                           actionWithTitle:NSLocalizedString(@"Cancel", nil)
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               [alert dismissViewControllerAnimated:YES completion:nil];
                               
                           }];
    
    [alert addAction:save];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Tap Gesture in MainView
- (IBAction)dismissKeyBoard:(id)sender {
    [self.view endEditing:true];
}

#pragma mark - DropableView Delegate
- (void)droppableViewBeganDragging:(JDDroppableView*)view;
{
    NSLog(@"%ld", (long)view.tag);
    [UIView animateWithDuration:0.33 animations:^{
        view.backgroundColor = [UIColor orangeColor];
        view.alpha = 0.8;
    }];
}

- (void)droppableViewDidMove:(JDDroppableView*)view;
{
    //
}

- (void)droppableViewEndedDragging:(JDDroppableView*)view onTarget:(UIView *)target
{
    NSLog(@"%ld", (long)view.tag);
    [UIView animateWithDuration:0.33 animations:^{
        view.backgroundColor = [UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1];

        view.alpha = 1.0;
    }];
}

- (void)droppableView:(JDDroppableView*)view enteredTarget:(UIView*)target
{
    [UIView animateWithDuration:0.1 animations:^{
//        target.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [target setBackgroundColor:[UIColor darkGrayColor]];
    }];
}

- (void)droppableView:(JDDroppableView*)view leftTarget:(UIView*)target
{
    [UIView animateWithDuration:0.1 animations:^{
//        target.transform = CGAffineTransformMakeScale(1.0, 1.0);
        target.backgroundColor = [UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1];
    }];
}

- (BOOL)shouldAnimateDroppableViewBack:(JDDroppableView*)view wasDroppedOnTarget:(UIView*)target
{
    [self droppableView:view leftTarget:target];
    NSLog(@"%ld", (long)view.tag);
    NSLog(@"%ld", (long)target.tag);
    if (target.hidden == false) {
        if (currentQuizType == 3) {//For Order Quiz
            [self changeOrderAnswer:view other:(JDDroppableView *)target];
        }else if (currentQuizType == 4) {//For Match Quiz
            [self checkMatchAnswer:view wasDroppedOnTarget:target];
        }
        return YES;
    }
    
//    // animate out and remove view
//    [UIView animateWithDuration:0.33 animations:^{
//        view.transform = CGAffineTransformMakeScale(0.2, 0.2);
//        view.alpha = 0.2;
//        view.center = target.center;
//    } completion:^(BOOL finished) {
//        [view removeFromSuperview];
//    }];
    return YES;
}


#pragma mark - Custom Method

- (BOOL)isFillForMatch {
    for (UIView *subV in currentView.subviews) {
        if ([subV isKindOfClass:[UILabel class]] && subV.tag < 8 && subV.tag % 2 == 1 && subV.hidden == NO) {
            UILabel *label = (UILabel *)subV;
            if (![self checkText:label.text]) {
                return false;
            }
        }
    }
    return true;
}

//checking match answer, you have only 2 opinions
- (void)checkMatchAnswer: (JDDroppableView *)origin wasDroppedOnTarget: (UIView *)target {
    if ([target isKindOfClass:[UILabel class]]) {
        NSLog(@"%ld", (long)target.tag);
        UILabel *result = (UILabel *)target;
        NSInteger ind = result.tag / 2;
        NSMutableDictionary *answer = answers[ind];
        NSMutableDictionary *curAns = displayedAnswers[origin.tag];

        if (isChecked == true && [[answer objectForKey:ANSWERID] intValue] != [[curAns objectForKey:ANSWERID] intValue]) {//you had already 2 opinions
            
            //ending current match question
            NSString *feedback = [curQuestion objectForKey:FEEDBACK];
            if ([self checkText:FEEDBACK]) {
                [self showFeedbackAlert:feedback title:NSLocalizedString(@"Wrong", nil)];
            }else{
                [self showAlert:NSLocalizedString(@"Wrong answer", nil) isCorrect:NO];
            }
            
        }else if ([[answer objectForKey:ANSWERID] intValue] != [[curAns objectForKey:ANSWERID] intValue]) {//Now you have 1 opinion
            [self showAlert:NSLocalizedString(@"Wrong answer, please try again!", nil) isCorrect:NO];
            return;
        }else{
            isChecked = false;
            [result setText:[curAns objectForKey:@"match_"]];

            for (UIView *subV in origin.subviews) {
                [subV removeFromSuperview];
            }
            // animate out and remove view
            [UIView animateWithDuration:0.33 animations:^{
                origin.transform = CGAffineTransformMakeScale(0.2, 0.2);
                origin.alpha = 0.2;
                origin.center = target.center;
            } completion:^(BOOL finished) {
                [origin setHidden:true];
            }];
            if ([self isFillForMatch]) {
                
                //ending current match question
//                correctCount++;
                NSString *feedback = [curQuestion objectForKey:FEEDBACK];
                if ([self checkText:FEEDBACK]) {
                    [self showFeedbackAlert:feedback title:NSLocalizedString(@"Correct", nil)];
                }else{
                    [self showAlert:NSLocalizedString(@"Correct answer!", nil) isCorrect:YES];
                }
                
            }else{
//                [displayedAnswers exchangeObjectAtIndex:origin.tag withObjectAtIndex:ind];
//                [self showAlert:@"You are right!" isCorrect:YES];
                // animate out and remove view
               
            }
        }
    }
}

- (void)endCurrentMatchQuestion {
    //ending current question or If you are limit, ending current quiz
    [curResultQuestion setObject:@"First Answer" forKey:RESULT_USERSFIRSTANSWER];
    [curResultQuestion setObject:@"Correct Answer" forKey:RESULT_CORRECTANSWER];
    if ([self isFillForMatch]) {
        
        correctCount++;//increasing correctCount
        
        [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
        [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_FIRSTCORRECT];
    }else{
        [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_ISCORRECT];
        [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
    }
    [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
    [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_THIRDCORRECT];
    
    [self endCurrentQuestion];
}

//In order Quiz, change the seat of answer
- (void)changeOrderAnswer:(JDDroppableView *)origin other: (JDDroppableView *)other {
    [displayedAnswers exchangeObjectAtIndex:origin.tag withObjectAtIndex:other.tag];
    [self setTextForDropable:origin];
    [self setTextForDropable:other];
}

- (void)showKeyboard:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGFloat key_Hei = keyboardFrameBeginRect.size.height;
    CGFloat hei = self.view.frame.size.height;
    CGFloat startV_Hei = self.startView.frame.size.height;
    CGFloat startV_CY = (key_Hei - startV_Hei / 2) - hei / 2;
    if (startV_CY < 0) {
        startViewCenterY.constant = startV_CY;
    }

    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    CGFloat curViewY = currentView.frame.size.height * 1 / 3 - key_Hei + naviHei;
    [currentView setFrame:CGRectMake(currentView.frame.origin.x, curViewY, currentView.frame.size.width, currentView.frame.size.height)];
}

- (void)hideKeyboard:(NSNotification *)notification {
    if (startViewCenterY.constant != 0) {
        startViewCenterY.constant = 0;
    }
    
    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    [currentView setFrame:CGRectMake(currentView.frame.origin.x, naviHei, currentView.frame.size.width, currentView.frame.size.height)];
    NSLog(@"%f", currentView.frame.origin.y);
}



- (void)initialExamData {
    examDic = [[NSMutableDictionary alloc] init];
    resultDic = [[NSMutableDictionary alloc] init];
    quizDic = [[NSMutableDictionary alloc] init];
    resultQuizDic = [[NSMutableDictionary alloc] init];
    questionsArray = [[NSMutableArray alloc] init];
    endQuestionResultArray = [[NSMutableArray alloc] init];
    selectedNumber = 0;
    correctCount = 0;
    
    isChecked = false;
    
    isEven = true;
}

- (void)displayNewQuestion {
    if (isEven) {//showing the first view
        //        [self setView:self.firstView];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [firstView setFrame:CGRectMake(0, firstView.frame.origin.y, firstView.frame.size.width, firstView.frame.size.height)];
            [secondView setFrame:CGRectMake(secondView.frame.size.width, secondView.frame.origin.y, secondView.frame.size.width, secondView.frame.size.height)];
            
        } completion:^(BOOL finished) {
            
            isEven = false;
        }];
    }else{
        //        [self setView:self.secondView];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [secondView setFrame:CGRectMake(0, secondView.frame.origin.y, secondView.frame.size.width, secondView.frame.size.height)];
            [firstView setFrame:CGRectMake(firstView.frame.size.width, firstView.frame.origin.y, firstView.frame.size.width, firstView.frame.size.height)];
        } completion:^(BOOL finished) {
            
            isEven = true;
        }];
    }
}

- (void)hideQuestion {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [firstView setFrame:CGRectMake(firstView.frame.size.width, firstView.frame.origin.y, firstView.frame.size.width, firstView.frame.size.height)];
        [secondView setFrame:CGRectMake(secondView.frame.size.width, secondView.frame.origin.y, secondView.frame.size.width, secondView.frame.size.height)];
        
    } completion:^(BOOL finished) {
    }];
}

- (UIView *)createView{
    UIView *customV;
    switch (currentQuizType) {
        case 0://Multiple Choice
            customV = [self createChoiceView];
            break;
        case 1://Multiple Select
            customV = [self createSelectView];
            break;
        case 2://Fill in the Blank
            customV = [self createBlankView];
            break;
        case 3://Order
            customV = [self createOrderView];
            break;
        case 4://Match
            customV = [self createMatchView];
            break;
        case 5://Short Answer
            customV = [self createShortAnswerView];
            break;
        default:
            break;
    }
    return customV;
}
//////////////////////////////////////////////--------Short Answer
- (UIView *)createShortAnswerView {

    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    
    CGFloat wid = self.view.frame.size.width; //NSLog(@"%f", self.view.frame.size.width);
    CGFloat hei = self.view.frame.size.height - naviHei;  //NSLog(@"%f", self.view.frame.size.height);
    UIView *customV = [self setHeaderView:wid height:hei];
    
    [customV addSubview:[self addTextForShortAnswer:wid parentHei:hei]];
    
    UIButton *nextBt = [[UIButton alloc] initWithFrame:CGRectMake(wid - hei * 2 / 5 - 5, hei * 7 / 8 - 5, hei * 2 / 5, hei / 8)];
    [nextBt setBackgroundColor:[UIColor colorWithRed:(137/255.f) green:(202/255.f) blue:(44/255.f) alpha:1]];
    [nextBt setTintColor:[UIColor whiteColor]];
    [nextBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBt setTitle:NSLocalizedString(@"Check", nil) forState:UIControlStateNormal];
    [nextBt setReversesTitleShadowWhenHighlighted:true];
    [nextBt setShowsTouchWhenHighlighted:true];
    [nextBt addTarget:self action:@selector(nextShortAnswerPressed:) forControlEvents:UIControlEventTouchUpInside];
    [nextBt.titleLabel setFont:[UIFont systemFontOfSize:(hei / 16)]];
    [nextBt setTag:111];//-----------Set the tag of the Next Button - tag - 111
    [customV addSubview:nextBt];
    
    return customV;
}

- (void)nextShortAnswerPressed: (UIButton *)sender {
//    questionIndex++;
    //getting answers from textview
    NSString *myAnswer;
    for (UIView *subV in currentView.subviews) {
        if ([subV isKindOfClass:[UITextView class]]) {
            UITextView *textV = (UITextView *)subV;
            myAnswer = textV.text;
            break;
        }
    }
    
    [curResultQuestion setObject:myAnswer forKey:RESULT_USERSFIRSTANSWER];
    [curResultQuestion setObject:myAnswer forKey:RESULT_CORRECTANSWER];
    [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
    [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_FIRSTCORRECT];
    [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
    [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_THIRDCORRECT];
    
    [endQuestionResultArray addObject:curResultQuestion];
    
    correctCount++;
    if ([curQuestion objectForKey:FEEDBACK]) {
        [self showFeedbackAlert:[curQuestion objectForKey:FEEDBACK] title:NSLocalizedString(@"Feedback", nil)];
    }else{
        
        questionIndex++;
        if (questionIndex >= questionsArray.count) {//completing Short Answer Quiz
            [self showAlert:NSLocalizedString(@"Your results saved and quiz owner can see it now", nil) isCorrect:YES];
        }else{
            [self showQuestion];
        }
    }
}

//////////////////////////////////////////////--------Multiple Choice
- (UIView *)createChoiceView {

    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    
    CGFloat wid = self.view.frame.size.width; //NSLog(@"%f", self.view.frame.size.width);
    CGFloat hei = self.view.frame.size.height - naviHei;  //NSLog(@"%f", self.view.frame.size.height);
    UIView *customV = [self setHeaderView:wid height:hei];
    
    for (int i = 0; i < 4; i++) {
        //getting numerical Label // A, B, C, D
        [customV addSubview:[self getNumberLabel:i parentHei:hei parentWid:wid]];
        [customV addSubview:[self getAnswerButton:i parentHei:hei parentWid:wid]];
    }
    
    return customV;
}
//////////////////////////////////////////////--------Multiple Select
- (UIView *)createSelectView {
    
    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    
    CGFloat wid = self.view.frame.size.width; //NSLog(@"%f", self.view.frame.size.width);
    CGFloat hei = self.view.frame.size.height - naviHei;  //NSLog(@"%f", self.view.frame.size.height);
    UIView *customV = [self setHeaderView:wid height:hei];
    
    for (int i = 0; i < 4; i++) {
        //getting numerical Label // A, B, C, D
        [customV addSubview:[self getCheckImageView:i parentHei:hei parentWid:wid]];
        [customV addSubview:[self getAnswerButton:i parentHei:hei parentWid:wid]];
    }
    
    UIButton *nextBt = [[UIButton alloc] initWithFrame:CGRectMake(wid - hei * 2 / 5 - 5, hei * 7 / 8 - 5, hei * 2 / 5, hei / 8)];
    [nextBt setBackgroundColor:[UIColor colorWithRed:(137/255.f) green:(202/255.f) blue:(44/255.f) alpha:1]];
    [nextBt setTintColor:[UIColor whiteColor]];
    [nextBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBt setTitle:NSLocalizedString(@"Check", nil) forState:UIControlStateNormal];
    [nextBt setReversesTitleShadowWhenHighlighted:true];
    [nextBt setShowsTouchWhenHighlighted:true];
    [nextBt addTarget:self action:@selector(checkQuestionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [nextBt.titleLabel setFont:[UIFont systemFontOfSize:(hei / 16)]];
    [nextBt setTag:111];//-----------Set the tag of the Next Button - tag - 111
    [customV addSubview:nextBt];
    
    return customV;
    //body View
}
//////////////////////////////////////////////--------Order
- (UIView *)createOrderView {
    
    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    
    CGFloat wid = self.view.frame.size.width; //NSLog(@"%f", self.view.frame.size.width);
    CGFloat hei = self.view.frame.size.height - naviHei;  //NSLog(@"%f", self.view.frame.size.height);
    UIView *customV = [self setHeaderView:wid height:hei];
    
    for (int i = 0; i < 4; i++) {
        //getting numerical Label // A, B, C, D
        [customV addSubview:[self getNumberLabel:i parentHei:hei parentWid:wid]];

//        //getting anwer view
        [customV addSubview:[self getAnswerViewForOrder:i parentHei:hei parentWid:wid]];
    }
    //setting droptarget View for Answer
    for (UIView *subV1 in customV.subviews) {
        if ([subV1 isKindOfClass:[JDDroppableView class]]) {
            JDDroppableView *curJD = (JDDroppableView *)subV1;
            for (UIView *subV2 in customV.subviews) {
                if ([subV2 isKindOfClass:[JDDroppableView class]]) {
                    JDDroppableView *otherJD = (JDDroppableView *)subV2;
                    if (curJD.tag != otherJD.tag) {
                        [curJD addDropTarget:otherJD];
                    }
                }
                
            }
        }
    }
    
    UIButton *nextBt = [[UIButton alloc] initWithFrame:CGRectMake(wid - hei * 2 / 5 - 5, hei * 7 / 8 - 5, hei * 2 / 5, hei / 8)];
    [nextBt setBackgroundColor:[UIColor colorWithRed:(137/255.f) green:(202/255.f) blue:(44/255.f) alpha:1]];
    [nextBt setTintColor:[UIColor whiteColor]];
    [nextBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBt setTitle:NSLocalizedString(@"Check", nil) forState:UIControlStateNormal];
    [nextBt setReversesTitleShadowWhenHighlighted:true];
    [nextBt setShowsTouchWhenHighlighted:true];
    [nextBt addTarget:self action:@selector(checkOrderQuestionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [nextBt.titleLabel setFont:[UIFont systemFontOfSize:(hei / 16)]];
    [nextBt setTag:111];//-----------Set the tag of the Next Button - tag - 111
    [customV addSubview:nextBt];
    
    return customV;
}

- (void)checkOrderQuestionPressed: (UIButton *)sender {
//    NSString *feedback = [curQuestion objectForKey:FEEDBACK];
//    if ([self checkText:feedback]) {
//        [self showFeedbackAlert:[curQuestion objectForKey:FEEDBACK] title:@"Feedback"];
//    }else{
        [self orderQuizResultProcess];
//    }
}

- (void) orderQuizResultProcess {
    if (isChecked == true || [self checkCorrectForOrder]) {
        
        NSString *content = @"";
        NSString *ansCon = @"";
        for (NSInteger i = 0; i < answers.count; i++) {
            NSMutableDictionary *origin = answers[i];
            NSMutableDictionary *change = displayedAnswers[i];
            
            if ([self checkText:ansCon]) {
                ansCon = [NSString stringWithFormat:@"%@,%@", ansCon, [origin objectForKey:@"text"]];
            }else{
                ansCon = [origin objectForKey:@"text"];
            }

            if ([self checkText:content]) {
                content = [NSString stringWithFormat:@"%@,%@", content, [change objectForKey:@"text"]];
            }else{
                content = [change objectForKey:@"text"];
            }

        }
        
        [curResultQuestion setObject:content forKey:RESULT_USERSFIRSTANSWER];
        [curResultQuestion setObject:ansCon forKey:RESULT_CORRECTANSWER];
        
        if ([self checkCorrectForOrder] && isChecked == false) {
            
            correctCount++;//increasing correctCount
            
            [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_FIRSTCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
        }else if ([self checkCorrectForOrder] && isChecked == true) {
            [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_SECONDCORRECT];
        }else{
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_ISCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
        }
        
        [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_THIRDCORRECT];
        
        if ([self checkCorrectForOrder]) {
            [self showAlert:NSLocalizedString(@"Correct answer!", nil) isCorrect:YES];
        }else{
            NSString *feedback = [curQuestion objectForKey:FEEDBACK];
            if ([self checkText:feedback]) {
                [self showFeedbackAlert:[curQuestion objectForKey:FEEDBACK] title:NSLocalizedString(@"Feedback", nil)];
            }else{
                [self showAlert:NSLocalizedString(@"Wrong answer", nil) isCorrect:NO];
            }
        }
    }else{
        [self showAlert:NSLocalizedString(@"Wrong answer, please try again!", nil) isCorrect:NO];
//        isChecked = true;
    }
}

- (void)endCurrentQuestion {
    [endQuestionResultArray addObject:curResultQuestion];
    questionIndex++;
    if (questionIndex >= questionsArray.count) {
        [self completeQuestionAlert];
        
        [timer invalidate];
        timer = nil;
    }else{
        [self showQuestion];
    }
}

- (BOOL) checkCorrectForOrder {
    for (NSInteger i = 0; i < answers.count; i++) {
        NSMutableDictionary *origin = answers[i];
        NSMutableDictionary *change = displayedAnswers[i];
        if ([[origin objectForKey:@"id"] intValue] != [[change objectForKey:@"id"] intValue]) {
            return false;
        }
    }
    return true;
}
//////////////////////////////////////////////--------Match
- (UIView *)createMatchView {

    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    
    CGFloat wid = self.view.frame.size.width; //NSLog(@"%f", self.view.frame.size.width);
    CGFloat hei = self.view.frame.size.height - naviHei;  //NSLog(@"%f", self.view.frame.size.height);
    UIView *customV = [self setHeaderView:wid height:hei];
    
    for (int i = 0; i < 4; i++) {
        //getting numerical Label // A, B, C, D
        [customV addSubview:[self getNumberLabel:i parentHei:hei parentWid:wid]];
        //getting anwer button
        [self getAnswerViewsForMatch:customV index:i parentHei:hei parentWid:wid];
    }
    
    //setting droptarget for dropable views
    for (UIView *subV in customV.subviews) {
        if ([subV isKindOfClass:[JDDroppableView class]]) {
            JDDroppableView *dropV = (JDDroppableView *)subV;
            for (UIView *subV1 in customV.subviews) {
                if ([subV1 isKindOfClass:[UILabel class]] && subV1.tag < 8 && subV1.tag % 2 == 1) {
                    dropV.delegate = self;
                    [dropV addDropTarget:subV1];
                }
            }
        }
    }
    
//    UIButton *nextBt = [[UIButton alloc] initWithFrame:CGRectMake(wid - hei * 2 / 5 - 5, hei * 7 / 8 - 5, hei * 2 / 5, hei / 8)];
//    [nextBt setBackgroundColor:[UIColor colorWithRed:(137/255.f) green:(202/255.f) blue:(44/255.f) alpha:1]];
//    [nextBt setTintColor:[UIColor whiteColor]];
//    [nextBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [nextBt setTitle:@"Next" forState:UIControlStateNormal];
//    [nextBt setReversesTitleShadowWhenHighlighted:true];
//    [nextBt setShowsTouchWhenHighlighted:true];
//    [nextBt addTarget:self action:@selector(nextQuestionPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [nextBt setTag:111];//-----------Set the tag of the Next Button - tag - 111
//    [customV addSubview:nextBt];
    
    return customV;
}
//////////////////////////////////////////////--------Fill in the Blank
- (UIView *)createBlankView {

    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    
    CGFloat wid = self.view.frame.size.width; //NSLog(@"%f", self.view.frame.size.width);
    CGFloat hei = self.view.frame.size.height - naviHei;  //NSLog(@"%f", self.view.frame.size.height);
    UIView *customV = [self setHeaderView:wid height:hei];
    
    [customV addSubview:[self addTextForShortAnswer:wid parentHei:hei]];
    
    UIButton *nextBt = [[UIButton alloc] initWithFrame:CGRectMake(wid - hei * 2 / 5 - 5, hei * 7 / 8 - 5, hei * 2 / 5, hei / 8)];
    [nextBt setBackgroundColor:[UIColor colorWithRed:(137/255.f) green:(202/255.f) blue:(44/255.f) alpha:1]];
    [nextBt setTintColor:[UIColor whiteColor]];
    [nextBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBt setTitle:NSLocalizedString(@"Check", nil) forState:UIControlStateNormal];
    [nextBt setReversesTitleShadowWhenHighlighted:true];
    [nextBt setShowsTouchWhenHighlighted:true];
    [nextBt addTarget:self action:@selector(nextBlankQuestionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [nextBt.titleLabel setFont:[UIFont systemFontOfSize:(hei / 16)]];
    [nextBt setTag:111];//-----------Set the tag of the Next Button - tag - 111
    [customV addSubview:nextBt];
    
    return customV;
}

- (void)nextBlankQuestionPressed: (UIButton *)sender {
    
    BOOL isCor = false;
    //getting answers from textview
    NSArray *myAnswers = [[NSArray alloc] init];
    for (UIView *subV in currentView.subviews) {
        if ([subV isKindOfClass:[UITextView class]]) {
            UITextView *textV = (UITextView *)subV;
            NSString *str = textV.text;
            myAnswers = [str componentsSeparatedByString:@"\n"];
            
            break;
        }
    }
    //comparing answers
    NSString *rep;
    NSString *ans;
    for (NSInteger i = 0; i < myAnswers.count; i++) {
        rep = myAnswers[i];
        if ([self checkText:rep] == NO) {//check whether text is empty or none.
            continue;
        }
        rep = [rep lowercaseString];
        isCor = NO;
        for (NSMutableDictionary *answer in answers) {
            ans = [answer objectForKey:ANSWERTEXT];
            if ([self checkText:ans] == NO) {////check whether text is empty or none.
                continue;
            }
            ans = [ans lowercaseString];
            if ([rep isEqualToString:ans]) {
                isCor = YES;
                break;
            }
        }
        if (isCor == NO) {
            break;
        }
    }
    
    if (isChecked == true || isCor) {//ending this question and next or complete this quiz
        
        NSString *content = @"";
        NSString *ansCon = @"";
        for (NSInteger i = 0; i < answers.count; i++) {
            NSMutableDictionary *origin = answers[i];
            if ([self checkText:ansCon]) {
                ansCon = [NSString stringWithFormat:@"%@,%@", ansCon, [origin objectForKey:@"text"]];
            }else{
                ansCon = [origin objectForKey:@"text"];
            }

        }
        for (NSInteger i = 0; i < myAnswers.count; i++) {
            NSString *change = myAnswers[i];
            if ([self checkText:content]) {
                content = [NSString stringWithFormat:@"%@,%@", content, change];
            }else{
                content = change;
            }

        }
        
        [curResultQuestion setObject:content forKey:RESULT_USERSFIRSTANSWER];
        [curResultQuestion setObject:ansCon forKey:RESULT_CORRECTANSWER];
        
        NSString *title;
        NSString *msg;
        
        if (isCor) {
            title = NSLocalizedString(@"Correct", nil);
            msg = NSLocalizedString(@"Correct answer!", nil);
            correctCount++;//increasing correctCount
            
            if (isChecked == false) {
                [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
                [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_FIRSTCORRECT];
                [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
            }else{
                [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
                [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
                [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_SECONDCORRECT];
            }

            
        }else{
            title = NSLocalizedString(@"Wrong", nil);
            msg = NSLocalizedString(@"Wrong answer", nil);
            
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_ISCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
        }

        [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_THIRDCORRECT];
        
        //
        NSString *feedback = [curQuestion objectForKey:FEEDBACK];
        if (isCor) {
            [self showAlert:NSLocalizedString(@"Correct answer!", nil) isCorrect:YES];
        }else{
            if ([self checkText:feedback]) {
                [self showFeedbackAlert:feedback title:NSLocalizedString(@"Feedback", nil)];
            }else{
                [self showAlert:NSLocalizedString(@"Wrong answer", nil) isCorrect:NO];
            }
        }
    }else{
        [self showAlert:NSLocalizedString(@"Wrong answer, please try again!", nil) isCorrect:NO];
        for (UIView *subV in currentView.subviews) {
            if ([subV isKindOfClass:[CustomTextView class]]) {
                CustomTextView *textV = (CustomTextView *)subV;
                [textV setText:@""];
                break;
            }
        }
    }
}


- (UIView *)setHeaderView:(CGFloat)wid height:(CGFloat)hei {
    
    CGFloat naviHei = self.navigationController.navigationBar.frame.size.height;
    
    
    UIView *customV = [[UIView alloc] initWithFrame:CGRectMake(wid, naviHei, wid, hei)];
    [customV setBackgroundColor:[UIColor whiteColor]];
    
    //header view
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid, hei / 6)];
    [headerV setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:(236/255.f)]];
    [headerV setTag:11111];
    [customV addSubview:headerV];
    
    UILabel *quizName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, wid / 2, hei / 15)];
    [quizName setFont:[UIFont fontWithName:@"Helvetica-Bold" size: (hei / 15)]];
    quizName.tag = 11;//------------------- quizName - tag - 11
    quizName.text = @"Math Test";/////for testing
    //    [quizName setBackgroundColor:[UIColor grayColor]];
    [customV addSubview:quizName];
    
    UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, hei / 15, (hei / 6 - hei / 12), (hei / 6 - hei / 12))];
    iconImg.image = [UIImage imageNamed:@"Clock"];
    [iconImg setTag:555];
    [customV addSubview:iconImg];
    
    UILabel *quizTime = [[UILabel alloc] initWithFrame:CGRectMake(10 + hei / 12, hei / 15, wid / 2 - hei / 18, hei / 12)];
    [quizTime setTextColor:[UIColor colorWithRed:(222/255.f) green:(52/255.f) blue:(43/255.f) alpha:1]];
    quizTime.tag = 12;//------------------- quizTime - tag - 12
    quizTime.text = @"12:00 min";/////for testing
    [quizTime setFont:[UIFont systemFontOfSize:hei / 16]];
    [customV addSubview:quizTime];
    
    UILabel *numberOfQ = [[UILabel alloc] initWithFrame:CGRectMake(wid - hei / 3 - 10, 5, hei / 3 - 10, hei / 6 - 10)];
    [numberOfQ setFont:[UIFont fontWithName:@"Helvetica-Bold" size: (hei / 6 - 15)]];
    [numberOfQ setTag:13];//------------------- questionNumber - tag - 13
    [customV addSubview:numberOfQ];
    
    //body View
    UILabel *questionL = [[UILabel alloc] initWithFrame:CGRectMake(hei / 6, hei / 6, wid - hei / 3, hei / 6)];
    questionL.textAlignment = NSTextAlignmentCenter;
    [questionL setFont:[UIFont fontWithName:@"Helvetica" size: (hei / 24)]];
    questionL.numberOfLines = 0;
    questionL.text = @"Lorem ipsum dolor sit amet, consectetu daipiscing slit. alliquam facilitisis libero telkd a efficitu elit maximus ut?";
    [questionL setTextColor:[UIColor blackColor]];
    [questionL setTag:14];//----------------- question Text - tag - 14
    [customV addSubview:questionL];
    
    //---attach button
    UIButton *attachButton = [[UIButton alloc] initWithFrame:CGRectMake(wid - hei / 6 + 5, hei / 6 + 5, hei / 6 - 10, hei / 6 - 10)];
    [attachButton setBackgroundImage:[UIImage imageNamed:@"ic_attachedImage.png"] forState:UIControlStateNormal];
    [attachButton addTarget:self action:@selector(attachButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [attachButton setReversesTitleShadowWhenHighlighted:true];
    [attachButton setShowsTouchWhenHighlighted:true];
    [attachButton setTitle:@"" forState:UIControlStateNormal];
    [attachButton setTag:1111];
    [customV addSubview:attachButton];
    return customV;
}

- (void)attachButtonPressed: (UIButton *)sender {
    [ProgressHUD show:NSLocalizedString(@"Loading", nil) Interaction:NO];
    NSString *str = [curQuestion objectForKey:ATTACHMENT];
    
    if ([self checkText:str]) {//checking the image data
        
        NSURL *url = [[NSURL alloc] initWithString:str];
        NSData *data = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];

        DisplayingImageViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DisplayingImageViewController"];
        imageVC.image = image;
        
        [ProgressHUD dismiss];
        
        [self.navigationController pushViewController:imageVC animated:true];
        
    }else{
        [ProgressHUD dismiss];
        [self showWarningAlert:NSLocalizedString(@"There is no image for this question!", nil)];
    }

}

- (void)checkAttachImage {
    BOOL isAttached = false;
    NSString *str = [curQuestion objectForKey:ATTACHMENT];
    if ([self checkText:str]) {
        isAttached = true;
    }
    
    for (UIView *subV in currentView.subviews) {
        if ([subV isKindOfClass:[UIButton class]] && subV.tag == 1111) {//if the button is attaching button
            UIButton *button = (UIButton *)subV;
            if (isAttached) {
                [button setEnabled:true];
            }else{
                [button setEnabled:false];
            }
        }
    }
}

- (CustomTextView *)addTextForShortAnswer: (CGFloat)wid parentHei: (CGFloat)hei {
    CustomTextView *answerTV = [[CustomTextView alloc] init];
    [answerTV setFrame:CGRectMake(wid / 6, hei / 3, wid * 2 / 3, hei / 3)];
    [answerTV.layer setBorderWidth:1];
    [answerTV.layer setBorderColor:[UIColor grayColor].CGColor];
    [answerTV setFont:[UIFont fontWithName:answerTV.font.fontName size:17]];
    answerTV.placeholder = NSLocalizedString(@"Write your answer", nil);
    
    return answerTV;
}

- (BOOL)isCorrectChecked {// checking whether the answer is correct or not for Multiple Select
    BOOL f = true;
    for (NSMutableDictionary *answer in answers) {
        if (([[answer objectForKey:CORRECT] intValue] == 1 && [[answer objectForKey:FEEDBACK] intValue] == 0) || ([[answer objectForKey:FEEDBACK] intValue] == 1 && [[answer objectForKey:CORRECT] intValue] == 0)) {
            return false;
        }
    }
    return f;
}

- (void)checkQuestionPressed: (UIButton *)sender {//checking for Multiple Select
    
    if (![curResultQuestion objectForKey:RESULT_USERSFIRSTANSWER]) {
        NSString *ansCon = @"";
        for (NSMutableDictionary *answer in answers) {
            if ([[answer objectForKey:FEEDBACK] intValue] == 1) {
                if ([self checkText:ansCon]) {
                    ansCon = [NSString stringWithFormat:@"%@, %@", ansCon, [answer objectForKey:@"text"]];
                }else{
                    ansCon = [answer objectForKey:@"text"];
                }
            }
        }
        [curResultQuestion setObject:ansCon forKey:RESULT_USERSFIRSTANSWER];
    }
    
    if (isChecked || [self isCorrectChecked]) {//If you have already 2 opinions < Or > you are correct.
        NSString *content = @"";
        for (NSMutableDictionary *answer in answers) {
            if ([[answer objectForKey:CORRECT] intValue] == 1) {
                if ([self checkText:content]) {
                    content = [NSString stringWithFormat:@"%@, %@", content, [answer objectForKey:@"text"]];
                }else{
                    content = [answer objectForKey:@"text"];
                }
            }
        }

        [curResultQuestion setObject:content forKey:RESULT_CORRECTANSWER];
        if ([self isCorrectChecked]) {
            if (isChecked == false) {
                [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
                [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_FIRSTCORRECT];
                [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
            }else{
                [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
                [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
                [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_SECONDCORRECT];
            }
        }else{
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_ISCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
        }
        [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_THIRDCORRECT];
        
        if ([self isCorrectChecked]) {
            correctCount++;
            [self showAlert:NSLocalizedString(@"Correct answer!", nil) isCorrect:YES];
        }else{
            if ([self checkText:[curQuestion objectForKey:FEEDBACK]]) {
                [self showFeedbackAlert:[curQuestion objectForKey:FEEDBACK] title:NSLocalizedString(@"Feedback", nil)];
            }else{
                [self showAlert:NSLocalizedString(@"Wrong answer", nil) isCorrect:NO];
            }
        }
    }else{//If now you had 1 opinion < And > you are incorrect

        [self showAlert:NSLocalizedString(@"Wrong answer, please try again!", nil) isCorrect:NO];
        for (UIView *subV in currentView.subviews) {
            if ([subV isKindOfClass:[UIImageView class]] && subV.tag < 500) {
                UIImageView *imageV = (UIImageView *)subV;
                [imageV setImage:[UIImage imageNamed:@"ic_unchecked.png"]];
                if (imageV.tag % 2 == 1) {
                    imageV.tag -= 1;
                }
                
                NSInteger ind = (imageV.tag - 100) / 2;
                if (ind < answers.count) {
                    NSMutableDictionary *answer = answers[(imageV.tag - 100) / 2];
                    [answer setObject:@"" forKey:FEEDBACK];
                }
            }
        }
        return;
    }
}

//saving result and displaying next questions
- (void)saveQuestionResult {
    if (currentQuizType == 5) {
        NSString *feedback = [curQuestion objectForKey:FEEDBACK];
        [self showFeedbackAlert:feedback title:NSLocalizedString(@"Feedback", nil)];
        [timer invalidate];
        timer = nil;
        return;
    }else{
    //Calculating mark for specific question
    //-current question result
        if (![curResultQuestion objectForKey:RESULT_CORRECTANSWER]) {
            [curResultQuestion setObject:@"" forKey:RESULT_CORRECTANSWER];
        }
        if (![curResultQuestion objectForKey:RESULT_USERSFIRSTANSWER]) {
            [curResultQuestion setObject:@"" forKey:RESULT_USERSFIRSTANSWER];
        }
        if (![curResultQuestion objectForKey:RESULT_ISCORRECT]) {
            
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_ISCORRECT];
        }
        if (![curResultQuestion objectForKey:RESULT_FIRSTCORRECT]) {
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
        }
        if (![curResultQuestion objectForKey:RESULT_SECONDCORRECT]) {
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
        }
        if (![curResultQuestion objectForKey:RESULT_THIRDCORRECT]) {
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_THIRDCORRECT];
        }
        [endQuestionResultArray addObject:curResultQuestion];
        NSLog(@"%@", endQuestionResultArray);
        ///////////////////////////////////////////

        selectedNumber = 0;
    }
    if ([[curResultQuestion objectForKey:RESULT_ISCORRECT] intValue] == 1) {
        correctCount++;
    }
    
    
    [endQuestionResultArray addObject:curResultQuestion];

    [self completeQuestionAlert];
    
    [timer invalidate];
    timer = nil;
}

- (void)completeQuestionAlert {
    //results---------
    [resultQuizDic setObject:[NSString stringWithFormat:@"%u", (uint)(100 * correctCount / questionsArray.count)] forKey:RESULT_QUIZ_SCORE];
    [resultQuizDic setObject:[NSString stringWithFormat:@"%lu", (unsigned long)correctCount] forKey:RESULT_QUIZ_CORRECTCOUNT];
    
//    UIViewController *controller = [[UIViewController alloc]init];
//    UITextView *textView;
    NSString *content = @"";
    content = [NSString stringWithFormat:NSLocalizedString(@"%@\nScore: %d", nil), content, [(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_SCORE] intValue]];
    content = [NSString stringWithFormat:NSLocalizedString(@"%@\nCorrect Count: %d", nil), content, [(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_CORRECTCOUNT] intValue]];
    content = [NSString stringWithFormat:NSLocalizedString(@"%@\nTotal Question: %d", nil), content, [(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_TOTALQUESTION] intValue]];
    
    NSInteger myFontSize;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        myFontSize = 24;
    }else{
        myFontSize = 16;
    }
    
    NSDictionary *attriDic = @{
                               NSFontAttributeName : [UIFont systemFontOfSize:(myFontSize - 2) weight:UIFontWeightMedium],
                               NSForegroundColorAttributeName : [UIColor darkGrayColor]
                               };
    
    NSAttributedString *attriContent = [[NSAttributedString alloc] initWithString:content attributes:attriDic];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Here is your quiz report", nil)
                                  message:content
                                  preferredStyle:UIAlertControllerStyleAlert];
    
//    [alert setValue:controller forKey:@"contentViewController"];
    [alert setValue:attriContent forKey:@"attributedMessage"];
    
    UIAlertAction* yes = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self saveExamResult];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
//    [controller setPreferredContentSize:alert.view.bounds.size];
    
//    textView  = [[UITextView alloc]initWithFrame:alert.view.frame];
    //adding question status in textview
    
//    [textView setEditable:false];
//    [textView setText:content];
//    [textView setFont:[UIFont systemFontOfSize:20]];
//    
//    [controller.view addSubview:textView];
//    [controller.view bringSubviewToFront:textView];
//    [controller.view setUserInteractionEnabled:YES];
//    [textView setUserInteractionEnabled:YES];

    
    [alert addAction:yes];
//    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAttachImageAlert: (UIImage *)image {
    UIViewController *controller = [[UIViewController alloc]init];
    UIImageView *imageV;
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert setValue:controller forKey:@"contentViewController"];
    
    UIAlertAction* ok = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"OK", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                            
                          }];
    
    [controller setPreferredContentSize:alert.view.bounds.size];
    
    imageV  = [[UIImageView alloc]initWithFrame:alert.view.frame];
    imageV.image = image;
    //adding question status in textview
    
    [controller.view addSubview:imageV];
    [controller.view bringSubviewToFront:imageV];
    [controller.view setUserInteractionEnabled:YES];
    [imageV setUserInteractionEnabled:YES];
    
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveExamResult {
    //updating exam result for user
    if (currentQuizType != 5) {
        [self updateExamResult];
    }
    
    //transforing the exam result to server
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjects:@[resultQuizDic, endQuestionResultArray] forKeys:@[@"results", @"questions"]];
    [self httpSaveExamResult:param];
}

- (void)updateExamResult {//NSUserDefault------SandBox
    NSUserDefaults *me = [NSUserDefaults standardUserDefaults];
    //quiz_solved count
    if ([me objectForKey:QUIZ_SOLVED]) {
        NSInteger num = [(NSString *)[me objectForKey:QUIZ_SOLVED] intValue];
        num++;
        [me setObject:[NSString stringWithFormat:@"%ld", (long)num] forKey:QUIZ_SOLVED];
    }else{
        [me setObject:@"1" forKey:QUIZ_SOLVED];
    }
    //questions_solved count
    if ([me objectForKey:QUESTIONS_SOLVED]) {
        NSInteger num = [(NSString *)[me objectForKey:QUESTIONS_SOLVED] intValue];
        num += questionsArray.count;
        [me setObject:[NSString stringWithFormat:@"%ld", (long)num] forKey:QUESTIONS_SOLVED];
    }else{
        [me setObject:[NSString stringWithFormat:@"%ld", (long)(questionsArray.count)] forKey:QUESTIONS_SOLVED];
    }
    //questions_solved count
    if ([me objectForKey:AVERAGE_SCORE]) {
        NSInteger ascore = [(NSString *)[me objectForKey:AVERAGE_SCORE] intValue];
        NSInteger solved_num = [(NSString *)[me objectForKey:QUIZ_SOLVED] intValue];
        NSInteger cscore = [(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_SCORE] intValue];
        NSInteger score = (ascore * (solved_num - 1) + cscore) / solved_num;

        [me setObject:[NSString stringWithFormat:@"%ld", (long)score] forKey:AVERAGE_SCORE];
    }else{
        [me setObject:[NSString stringWithFormat:@"%@", [resultQuizDic objectForKey:RESULT_QUIZ_SCORE]] forKey:AVERAGE_SCORE];
    }
    //correct percentage
    if ([me objectForKey:CORRECT]) {
        NSInteger num = [(NSString *)[me objectForKey:CORRECT] intValue];
        num += [(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_SCORE] intValue];
        [me setObject:[NSString stringWithFormat:@"%ld", (long)(num / 2)] forKey:CORRECT];
    }else{
        [me setObject:[NSString stringWithFormat:@"%ld", (long)[(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_SCORE] intValue]] forKey:CORRECT];
    }
    //average quiz time
    if ([me objectForKey:AVERAGE_QUIZTIME]) {
        NSInteger oldTime = [(NSString *)[me objectForKey:AVERAGE_QUIZTIME] intValue];
        NSInteger newTime = examTime - currentTime;
        NSInteger solved_num = [(NSString *)[me objectForKey:QUIZ_SOLVED] intValue];
        newTime = (oldTime * (solved_num - 1) + newTime) / solved_num;
        [me setObject:[NSString stringWithFormat:@"%ld", (long)newTime] forKey:AVERAGE_QUIZTIME];
    }else{
        [me setObject:[NSString stringWithFormat:@"%ld", (long)[(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_SCORE] intValue]] forKey:AVERAGE_QUIZTIME];
    }
    //highest score
    if ([me objectForKey:HIGHEST_SCORE]) {
        NSInteger oldScore = [(NSString *)[me objectForKey:HIGHEST_SCORE] intValue];
        NSInteger newScore = [(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_SCORE] intValue];
        if (oldScore > newScore) {
            newScore = oldScore;
        }
        [me setObject:[NSString stringWithFormat:@"%ld", (long)newScore] forKey:HIGHEST_SCORE];
    }else{
        [me setObject:[NSString stringWithFormat:@"%ld", (long)[(NSString *)[resultQuizDic objectForKey:RESULT_QUIZ_SCORE] intValue]] forKey:HIGHEST_SCORE];
    }
}
//---------------getting number label for Multiple Choice
- (UILabel *)getNumberLabel: (NSInteger)num parentHei: (CGFloat)pHei parentWid: (CGFloat)pWid {
    CGFloat hei = pHei / 8; //the height of the label
//    CGFloat wid = pWid - 30; //the width of the label
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, pHei / 3 + (hei + 1) * num, hei, hei)];//numerical(A, B, C, D)
    [numLabel setBackgroundColor: [UIColor colorWithRed:(222/255.f) green:(52/255.f) blue:(43/255.f) alpha:1]];
    [numLabel setTextColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1]];
    [numLabel setFont:[UIFont systemFontOfSize:(hei * 2 / 3)]];
    [numLabel setText:alphaArray[num]];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [numLabel setTag:(100 + num)];
    [numLabel setHidden:false];
    
    return numLabel;
}

//---------------getting number label for Multiple Choice
- (UIImageView *)getCheckImageView: (NSInteger)num parentHei: (CGFloat)pHei parentWid: (CGFloat)pWid {
    CGFloat hei = pHei / 8; //the height of the label
    //    CGFloat wid = pWid - 30; //the width of the label
    UIImageView *checkImageV = [[UIImageView alloc] initWithFrame:CGRectMake(15, pHei / 3 + (hei + 1) * num, hei, hei)];//numerical(A, B, C, D)

    [checkImageV setImage:[UIImage imageNamed:@"ic_unchecked.png"]];

    [checkImageV setTag:(100 + num * 2)];
    [checkImageV setHidden:false];
    
    return checkImageV;
}
//--------------getting anwer label
- (UILabel *)getAnswerLabel: (NSInteger)num parentHei: (CGFloat)pHei parentWid: (CGFloat)pWid {
    CGFloat hei = pHei / 8; //the height of the label
    CGFloat wid = pWid - 30; //the width of the label
    UILabel *ansLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + hei, pHei / 3 + (hei + 1) * num, wid - hei, hei)];//numerical(A, B, C, D)
    [ansLabel setBackgroundColor: [UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    [ansLabel setTextColor:[UIColor colorWithRed:(150/255.f) green:(150/255.f) blue:(150/255.f) alpha:1]];
    [ansLabel setText:alphaArray[num]];
    ansLabel.textAlignment = NSTextAlignmentCenter;
    [ansLabel setTag:(num + 1)];
    [ansLabel setHidden:false];
    
    return ansLabel;
}

//getting answer button For < Multiple Choice and Select >
- (UIButton *)getAnswerButton: (NSInteger)num parentHei: (CGFloat)pHei parentWid: (CGFloat)pWid {
    CGFloat hei = pHei / 8; //the height of the button
    CGFloat wid = pWid - 30; //the width of the button
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15 + hei, pHei / 3 + (hei + 1) * num, wid - hei, hei)];//numerical(A, B, C, D)
    [button setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    [button setTitleColor:[UIColor colorWithRed:(150/255.f) green:(150/255.f) blue:(150/255.f) alpha:1] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:(hei * 2 / 3)]];
    
    button.tag = num;
//    [button addTarget:self action:@selector(textModeButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
//    [button addTarget:self action:@selector(textModeButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(selectAnswerDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(selectAnswerUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(selectAnswerUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [button setReversesTitleShadowWhenHighlighted:true];
    [button setShowsTouchWhenHighlighted:true];
    [button setHidden:false];
    
    return button;
}

//getting answer view For < Order >
- (JDDroppableView *)getAnswerViewForOrder: (NSInteger)num parentHei: (CGFloat)pHei parentWid: (CGFloat)pWid {
    CGFloat hei = pHei / 8; //the height of the button
    CGFloat wid = pWid - 30; //the width of the button
    JDDroppableView *dropV = [[JDDroppableView alloc] initWithFrame:CGRectMake(15 + hei, pHei / 3 + (hei + 1) * num, wid - hei, hei)];//numerical(A, B, C, D)
    [dropV setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    [dropV setHidden:false];

    dropV.delegate = self;
//    [button setTitleColor:[UIColor colorWithRed:(150/255.f) green:(150/255.f) blue:(150/255.f) alpha:1] forState:UIControlStateNormal];
    
    dropV.tag = num;
    
    return dropV;
}

- (UILabel *)getAnswerLabelForMatch: (NSInteger)num parentHei: (CGFloat)pHei parentWid: (CGFloat)pWid {
    CGFloat hei = pHei / 8; // the height of the button
    CGFloat wid = pWid - 30; // the width of the button
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15 + hei, pHei / 3 + (hei + 1) * num, (wid - hei) / 4, hei)];
    [label setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    [label setTag:num];
    
    return label;
}

- (void)getAnswerViewsForMatch: (UIView *)curV index: (NSInteger)num parentHei: (CGFloat)pHei parentWid: (CGFloat)pWid {
    
    CGFloat hei = pHei / 8; // the height of the button
    CGFloat wid = pWid - 30; // the width of the button
    
    // first label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15 + hei, pHei / 3 + (hei + 1) * num, (wid - hei) / 4, hei)];
    [label setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    [label setTag:num * 2];//-----setting  tag  2 * num
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:(hei / 2)]];
    [curV addSubview:label];//
    
    //second label
    UILabel *blankLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + hei + (wid - hei) / 4 + (wid - hei) / 8, pHei / 3 + (hei + 1) * num, (wid - hei) / 4, hei)];
    [blankLabel setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    [blankLabel setTag:num * 2 + 1];//setting tag ()  2 * num + 1
    [blankLabel setTextAlignment:NSTextAlignmentCenter];
    [blankLabel setFont:[UIFont systemFontOfSize:(hei / 2)]];
    [curV addSubview:blankLabel];
    
    //conjunctional view
    UIView *conV = [[UIView alloc] initWithFrame:CGRectMake(15 + hei + (wid - hei) / 4, pHei / 3 + hei / 2 + (hei + 1) * num, (wid - hei) / 8, 2)];
    [conV setBackgroundColor:[UIColor blackColor]];
    [conV setTag:(100 + num)];///       100 + num
    [curV addSubview:conV];
    
    //third view
    JDDroppableView *matchingV = [[JDDroppableView alloc] initWithFrame:CGRectMake(15 + hei + (wid - hei) / 2 + (wid - hei) / 4, pHei / 3 + (hei + 1) * num, (wid - hei) / 4, hei)];
    [matchingV setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    [matchingV setTag:num];
    [curV addSubview:matchingV];
}

- (void) selectAnswerDown: (UIButton *)sender {
    [sender setBackgroundColor:[UIColor lightGrayColor]];
}

- (void) selectAnswerUpOutside: (UIButton *)sender {
    [sender setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
}

- (void) selectAnswerUpInside: (UIButton *)sender {
    
    [sender setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    
    NSLog(@"choose the answer");
    selectedNumber++;
    
    if (currentQuizType == 0) {//Multiple Choice
        [self choiceForMultipleChoice:sender.tag];
    }else{//Multiple Select
        [self selectForMultipleSelect:sender.tag];
    }
    
}

- (void)selectForMultipleSelect: (NSInteger)tag {
    UIView *curV = currentView;
    for (UIView *subV in curV.subviews) {
        if ([subV isKindOfClass:[UIImageView class]]) {
            UIImageView *imageV = (UIImageView *)subV;
            NSInteger ind = imageV.tag - 100;
            NSInteger che = ind % 2;
            ind = ind / 2;
            if (ind == tag) {
                if (ind >= answers.count) {//array limit
                    return;
                }
                if (che == 0) {
                    imageV.tag += 1;
                    [imageV setImage:[UIImage imageNamed:@"ic_checked.png"]];
                    NSMutableDictionary *answer = answers[ind];
                    [answer setObject:[NSNumber numberWithBool:YES] forKey:FEEDBACK];
                }else{
                    imageV.tag -= 1;
                    [imageV setImage:[UIImage imageNamed:@"ic_unchecked.png"]];
                    NSMutableDictionary *answer = answers[ind];
                    [answer setObject:[NSNumber numberWithBool:NO] forKey:FEEDBACK];
                }
            }
        }
    }
}

- (void) choiceForMultipleChoice: (NSInteger)tag {
    NSMutableDictionary *curAnswer;
    NSString *numStr;
    NSInteger num;//if num == 0, incorrect.  Or num == 1, correct
    
    if (tag < answers.count) {
        curAnswer = answers[tag];
        numStr = [curAnswer objectForKey:@"correct"];//If it is correct, num = 1
        num = [numStr intValue];
        NSLog(@"%@", [curAnswer objectForKey:@"correct"]);

    }else{
        return;
    }
    
    if (num == 1) {//if you are correct

        [curResultQuestion setObject:[curAnswer objectForKey:@"text"] forKey:RESULT_CORRECTANSWER];
        
        if (selectedNumber == 1) {
            correctCount++;
            [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_ISCORRECT];
            [curResultQuestion setObject:[curAnswer objectForKey:@"text"] forKey:RESULT_USERSFIRSTANSWER];
            [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_FIRSTCORRECT];
        }else if (selectedNumber == 2) {
            [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_SECONDCORRECT];
        }else if (selectedNumber == 3) {
            [curResultQuestion setObject:[NSNumber numberWithBool:YES] forKey:RESULT_THIRDCORRECT];
        }
    }else{
        if (selectedNumber == 1) {
            [curResultQuestion setObject:[curAnswer objectForKey:@"text"] forKey:RESULT_USERSFIRSTANSWER];
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_FIRSTCORRECT];
        }else if (selectedNumber == 2) {
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_SECONDCORRECT];
        }else if (selectedNumber == 3) {
            [curResultQuestion setObject:[NSNumber numberWithBool:NO] forKey:RESULT_THIRDCORRECT];
        }
    }
    
    //---show answer feedback
    NSString *feedback = [curAnswer objectForKey:@"feedback"];
    NSString *feedbackQ;
    feedbackQ = [curQuestion objectForKey:@"feedback"];
    
    if (num == 1) {
//        if ([self checkText:feedback]) {
//            [self showFeedbackAlert:feedback title:@"Correct"];
//        }else{
//            if ([self checkText:feedbackQ]) {
//                [self showFeedbackAlert:feedbackQ title:@"Feedback"];
//            }else{
//                [self endCurrentQuestion];
//            }
//        }
        [self showAlert:NSLocalizedString(@"Correct answer!", nil) isCorrect:YES];
    }else{
        if ([self checkText:feedback]) {
            [self showFeedbackAlert:feedback title:NSLocalizedString(@"Wrong", nil)];
        }else{
            NSString *feedbackQ = [curQuestion objectForKey:FEEDBACK];
            if ([self checkText:feedbackQ]) {
                [self showFeedbackAlert:feedbackQ title:NSLocalizedString(@"Wrong", nil)];
            }else{
                [self showAlert:NSLocalizedString(@"Wrong answer", nil) isCorrect:NO];
            }
        }
    }
}


- (BOOL)checkText: (NSString *)text {//check the Quiz Name and Time in ModalEffectView
    NSString *rawString = text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        // Text was empty or only whitespace.
        
        return NO;
    }
    return YES;
}

- (void) showFeedbackAlert: (NSString *)msg title: (NSString *)title{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableAttributedString *titleTxt = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", msg]];
    if ([title isEqualToString:NSLocalizedString(@"Wrong", nil)]) {//--------------failure
        // Sets the font color of last four characters to red.
        [titleTxt addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(200/255.f) green:(0/255.f) blue:(0/255.f) alpha:1] range: NSMakeRange(0, titleTxt.length)];
        [alert setValue:titleTxt forKey:@"attributedTitle"];
        
        // Sets the font color of last four characters to blue.
        [message addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(200/255.f) green:(0/255.f) blue:(0/255.f) alpha:1] range: NSMakeRange(0, message.length)];
        [alert setValue:message forKey:@"attributedMessage"];
        
    }else if ([title isEqualToString:NSLocalizedString(@"Correct", nil)]) {//--------------Correc-t
        // Sets the font color of last four characters to green.
        [titleTxt addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(0/255.f) green:(200/255.f) blue:(0/255.f) alpha:1] range: NSMakeRange(0, titleTxt.length)];
        [alert setValue:titleTxt forKey:@"attributedTitle"];
        
        // Sets the font color of last four characters to green.
        [message addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(0/255.f) green:(200/255.f) blue:(0/255.f) alpha:1] range: NSMakeRange(0, message.length)];
        [alert setValue:message forKey:@"attributedMessage"];
        
    }else{//only for feedback (you checked the correct answer)
        // Sets the font color of last four characters to green.
//        [titleTxt addAttribute: NSForegroundColorAttributeName value: [UIColor blackColor] range: NSMakeRange(0, titleTxt.length)];
//        [alert setValue:titleTxt forKey:@"attributedTitle"];
        
        // Sets the font color of last four characters to green.
        [message addAttribute: NSForegroundColorAttributeName value: [UIColor blackColor] range: NSMakeRange(0, message.length)];
        [alert setValue:message forKey:@"attributedMessage"];
    }

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if (currentQuizType == 5) {//short answer
                                 questionIndex++;
                                 if (questionIndex >= questionsArray.count || currentTime <= 0) {
                                    [self showAlert:NSLocalizedString(@"Your results saved and quiz owner can see it now", nil) isCorrect:YES];
                                 }else{
                                     [self showQuestion];
                                 }
                             }else if (currentQuizType == 1) {//multiple select
                                 if ([title isEqualToString:NSLocalizedString(@"Correct", nil)]) {
                                     NSString *feedbackQ;
                                     feedbackQ = [curQuestion objectForKey:@"feedback"];
                                     if ([self checkText:feedbackQ]) {
                                         [self showFeedbackAlert:feedbackQ title:NSLocalizedString(@"Feedback", nil)];//
                                     }else{
                                         [self endCurrentQuestion];
                                     }
                                 }else if ([title isEqualToString:NSLocalizedString(@"Feedback", nil)]) {
                                     [self endCurrentQuestion];
                                 }
                             }else if (currentQuizType == 3) {//Order
                                 [self endCurrentQuestion];
                             }else if (currentQuizType == 4) {//Match Quiz
                                 [self endCurrentMatchQuestion];
                             }else if (currentQuizType == 2) {//Fill in the Blank
                                 [self endCurrentQuestion];
                             }

                         }];
    
    [alert addAction:ok];
    

    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){    //if device is an iPad
//        [alert setModalPresentationStyle:UIModalPresentationPopover];
        [alert.popoverPresentationController setPermittedArrowDirections:0];
        [alert.popoverPresentationController setSourceView:self.view];
        CGRect rect = self.view.frame;
        rect.origin.x = self.view.frame.size.width / 15;
        rect.origin.y = self.view.frame.size.height / 15;
        [alert.popoverPresentationController setSourceRect:rect];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
    if ([title isEqualToString:NSLocalizedString(@"Correct", nil)]) {
        [alert.view setTintColor:[UIColor colorWithRed:(0/255.f) green:(200/255.f) blue:(0/255.f) alpha:1]];
    }else if ([title isEqualToString:NSLocalizedString(@"Wrong", nil)]) {
        [alert.view setTintColor:[UIColor colorWithRed:(200/255.f) green:(0/255.f) blue:(0/255.f) alpha:1]];
    }else{
        [alert.view setTintColor:[UIColor blackColor]];
    }
}

- (void)settingViews: (UIView *)customV {
    
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

- (void)showAlert: (NSString *)msg isCorrect:(BOOL)isCor{// showing correct or wrong
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
//    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"title"];
//    
//    // Sets the font color of last four characters to green.
//    [title addAttribute: NSForegroundColorAttributeName value: [UIColor greenColor] range: NSMakeRange(0, title.length)];
//    [alert setValue:title forKey:@"attributedTitle"];
    if (isCor) {
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:msg];
        
        // Sets the font color of last four characters to green.
        [message addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(0/255.f) green:(200/255.f) blue:(0/255.f) alpha:1] range: NSMakeRange(0, message.length)];
        [alert setValue:message forKey:@"attributedMessage"];
    }else{
        NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:msg];
        
        // Sets the font color of last four characters to green.
        [message addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(200/255.f) green:(0/255.f) blue:(0/255.f) alpha:1] range: NSMakeRange(0, message.length)];
        [alert setValue:message forKey:@"attributedMessage"];
    }

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             if (currentQuizType == 3 || currentQuizType == 1 || currentQuizType == 2) {//< Order Quiz > or < Multiple Select > or < Fill in the blank >
                                 if (isCor == YES || (isCor == NO && isChecked == YES)) {
                                     [self endCurrentQuestion];
                                 }else{
                                     isChecked = YES;
                                 }
                             }else if (currentQuizType == 5) {//short Answer Quiz
                                 [resultQuizDic setObject:[NSString stringWithFormat:@"%u", (uint)(100 * correctCount / questionsArray.count)] forKey:RESULT_QUIZ_SCORE];
                                 [resultQuizDic setObject:[NSString stringWithFormat:@"%lu", (unsigned long)correctCount] forKey:RESULT_QUIZ_CORRECTCOUNT];
                                 
                                 [self saveExamResult];
                                 [timer invalidate];
                                 timer = nil;
//                                 [self showStartView];
                             }else if (currentQuizType == 0) {//Multiple Choice
                                 if (isCor) {
                                     [self endCurrentQuestion];
                                 }else{
                                     //???
                                 }
                             }else if (currentQuizType == 4) {//Match Quiz
                                 if (isCor) {
                                     [self endCurrentMatchQuestion];
                                 }else{
                                     if (isChecked == false) {
                                         isChecked = true;
                                     }else{
                                         [self endCurrentMatchQuestion];
                                     }
                                 }

                             }
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    if (isCor) {
        [alert.view setTintColor:[UIColor colorWithRed:(0/255.f) green:(200/255.f) blue:(0/255.f) alpha:1]];
    }else{
        [alert.view setTintColor:[UIColor colorWithRed:(200/255.f) green:(0/255.f) blue:(0/255.f) alpha:1]];
    }
}

- (void)showQuestion {
    selectedNumber = 0;
    
    if (isEven) {
        currentView = firstView;
    }else{
        currentView = secondView;
    }
    
//    if (currentQuizType == 0 || currentQuizType == 1) {//Multiple Choice or Select
        [self setQuestionInfo:currentView];
//    }
    
    [self displayNewQuestion];
}

- (void)countingTime: (NSTimer *)sender {
    currentTime--;
    for (UIView *subV in firstView.subviews) {
        if ([subV isKindOfClass:[UILabel class]]) {
            if (subV.tag == 12) {
                UILabel *label = (UILabel *)subV;
                if ((currentTime % 60) < 10) {
                    [label setText:[NSString stringWithFormat:@"%d:0%d", (uint)(currentTime / 60), (uint)(currentTime % 60)]];
                }else{
                    [label setText:[NSString stringWithFormat:@"%d:%d", (uint)(currentTime / 60), (uint)(currentTime % 60)]];
                }
            }
        }
    }
    for (UIView *subV in secondView.subviews) {
        if ([subV isKindOfClass:[UILabel class]]) {
            if (subV.tag == 12) {
                UILabel *label = (UILabel *)subV;
                if ((currentTime % 60) < 10) {
                    [label setText:[NSString stringWithFormat:@"%d:0%d", (uint)(currentTime / 60), (uint)(currentTime % 60)]];
                }else{
                    [label setText:[NSString stringWithFormat:@"%d:%d", (uint)(currentTime / 60), (uint)(currentTime % 60)]];
                }
            }
        }
    }
    if (currentTime <= 0) {
        [sender invalidate];
        sender = nil;
        [self saveQuestionResult];
    }
}

//setQuestionInfo for several Type of the Quiz

- (void)setQuestionInfo: (UIView *)curView {
    curQuestion = [[NSMutableDictionary alloc] init];
    curResultQuestion = [[NSMutableDictionary alloc] init];
    answers = [[NSMutableArray alloc] init];
    curQuestion = questionsArray[questionIndex];
    answers = [curQuestion objectForKey:@"answers"];

    for (UIView *subV in curView.subviews) {
        
        [subV setHidden:false];
        
        if ([subV isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subV;
            if (label.tag == 11) {//Quiz Name
                [label setText:[quizDic objectForKey:@"subject"]];
            }
            else if (label.tag == 12 && questionIndex == 0) {//Quiz Time
                [label setText:[NSString stringWithFormat:@"%@:00", [quizDic objectForKey:@"time"]]];
            }
            else if (label.tag == 13) {//Question Number
                [label setText:[NSString stringWithFormat:@"%ld/%lu", (long)(questionIndex + 1), (unsigned long)questionsArray.count]];
            }
            else if (label.tag == 14) {//Question Label
                [label setText:[NSString stringWithFormat:@"%@", [curQuestion objectForKey:@"text"]]];
                //------
                [curResultQuestion setObject:[curQuestion objectForKey:@"text"] forKey:RESULT_QUESTIONTEXT];//saving current question text
                [curResultQuestion setObject:[curQuestion objectForKey:@"id"] forKey:RESULT_QUESTIONID];
            }
        }
    }
    //if there is attached image, attaching button is enabled, or diabled.
    [self checkAttachImage];
    
    if (currentQuizType == 0 || currentQuizType == 1) {//Multiple Choice & Select
        [self setInfoForChoiceSelect:curView];
    }else if (currentQuizType == 5) {//ShortAnswer
        [self setInfoForShortAnswer:curView];
    }else if (currentQuizType == 2) {//Fill in the Blank
        [self setInfoForBlank:curView];
    }else if (currentQuizType == 3) {//Order
        [self setInfoForOrder:curView];
    }else if (currentQuizType == 4) {//Match
        [self setInfoForMatch:curView];
    }
    
    //
}

- (void)setInfoForBlank: (UIView *)curV {
    isChecked = false;
    for (UIView *subV in curV.subviews) {
        if ([subV isKindOfClass:[CustomTextView class]]) {
            CustomTextView *textV = (CustomTextView *)subV;
            [textV setText:@""];
        }else if ([subV isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subV;
            if (button.tag == 111) {
                if ((questionIndex + 1) == questionsArray.count) {
                    [button setTitle:NSLocalizedString(@"Complete", nil) forState:UIControlStateNormal];
                }else{
                    [button setTitle:NSLocalizedString(@"Check", nil) forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)setInfoForOrder: (UIView *)curV {
    isChecked = false;
    
    displayedAnswers = [[NSMutableArray alloc] init];
    //deploy answers by random
    displayedAnswers = [answers mutableCopy];
    
    NSInteger count = displayedAnswers.count;
    
    for (NSInteger i = 0; i < count; i++) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [displayedAnswers exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
//    NSLog(@"%@", displayedAnswers);
//    NSLog(@"%@", answers);
    //---display the answer text corresponding displayedAnswers
    for (UIView *subV in curV.subviews) {
        if ([subV isKindOfClass:[JDDroppableView class]]) {
            JDDroppableView *dropV = (JDDroppableView *)subV;
            [dropV setHidden:false];
            [self setTextForDropable: dropV];
        }else if ([subV isKindOfClass:[UILabel class]]) {//alpha label set the hidden
            UILabel *label = (UILabel *)subV;
            NSLog(@"%ld", (long)(label.tag - 100));
            if ((label.tag - 100) >= answers.count && label.tag >= 100) {
                [label setHidden:true];
            }
        }else if ([subV isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subV;
            if (button.tag == 111) {
                if ((questionIndex + 1) == questionsArray.count) {
                    [button setTitle:NSLocalizedString(@"Complete", nil) forState:UIControlStateNormal];
                }else{
                    [button setTitle:NSLocalizedString(@"Check", nil) forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void) setTextForDropable: (JDDroppableView *)dropV {
    for (UIView *subV in dropV.subviews) {
        [subV removeFromSuperview];
    }
    NSString *content;
    if (currentQuizType == 3) {//Order
        content = ANSWERTEXT;
    }else if (currentQuizType == 4) {//Match
        content = @"match_";//meaning matching answer
    }
    if (displayedAnswers.count > dropV.tag) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dropV.frame.size.width, dropV.frame.size.height)];
        NSMutableDictionary *dic = displayedAnswers[dropV.tag];
        [label setText:[dic objectForKey:content]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:(dropV.frame.size.height / 2)]];
        [dropV addSubview:label];
    }else{
        [dropV setHidden:true];
    }

}

- (void)setInfoForMatch: (UIView *)curV {
    isChecked = false;
    
    displayedAnswers = [[NSMutableArray alloc] init];
    //deploy answers by random
    displayedAnswers = [answers mutableCopy];
    
    NSInteger count = displayedAnswers.count;
    
    for (NSInteger i = 0; i < count; i++) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [displayedAnswers exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    //    NSLog(@"%@", displayedAnswers);
    //    NSLog(@"%@", answers);
    //---display the answer text corresponding displayedAnswers
    for (UIView *subV in curV.subviews) {
        if ([subV isKindOfClass:[UILabel class]] && subV.tag < 8 && subV.tag % 2 == 0) {
            NSInteger ind = subV.tag / 2;
            UILabel *label = (UILabel *)subV;
            if (ind < answers.count) {
                NSMutableDictionary *answer = answers[ind];
                [label setText:[answer objectForKey:ANSWERTEXT]];
                [label setHidden:false];
            }else{
                [label setHidden:true];
            }

        }else if ([subV isKindOfClass:[UILabel class]] && subV.tag < 8 && subV.tag % 2 == 1) {
            NSInteger ind = subV.tag / 2;
            if (ind >= answers.count) {
                [subV setHidden:true];
            }else{
                [subV setHidden:false];
            }
            UILabel *label = (UILabel *)subV;
            [label setText:@""];
        }else if ([subV isKindOfClass:[UILabel class]] && subV.tag > 100 && (subV.tag - 100) >= answers.count) {
            NSInteger ind = subV.tag - 100;
            if (ind >= answers.count) {
                [subV setHidden:true];
            }else{
                [subV setHidden:false];
            }
        }else if ([subV isKindOfClass:[JDDroppableView class]]) {
            JDDroppableView *dropV = (JDDroppableView *)subV;

            if (dropV.tag >= answers.count) {
                [dropV setHidden:true];
            }else{
                if (dropV.alpha < 1) {
                    [dropV setAlpha:1];
                    dropV.transform = CGAffineTransformMakeScale(1, 1);
                }
                [dropV setHidden:false];
            }
            [self setTextForDropable:dropV];
            
        }else if ([subV isKindOfClass:[UIView class]] && subV.tag > 99 && subV.tag < 105) {
            NSInteger ind = subV.tag - 100;
            if (ind >= answers.count) {
                [subV setHidden:true];
            }else{
                [subV setHidden:false];
            }
        }
    }
}

- (void)setInfoForChoiceSelect: (UIView *)curV {
    isChecked = false;
    for (UIView *subV in curV.subviews) {
        if ([subV isKindOfClass:[UIButton class]]){//subview is UIbutton class
            UIButton *button = (UIButton *)subV;
            NSMutableDictionary *ansDic;
            if (button.tag == 111) {//if the subV is the Next Button(111)
                if ((questionIndex + 1) == questionsArray.count) {
                    [button setTitle:NSLocalizedString(@"Complete", nil) forState:UIControlStateNormal];
                }else{
                    [button setTitle:NSLocalizedString(@"Check", nil) forState:UIControlStateNormal];
                }
            }
            else if (button.tag == 0) {//Answer A
                
                if (answers.count > 0) {
                    ansDic = answers[0];
                    if ([self checkText:[ansDic objectForKey:@"text"]]) {
                        [button setTitle:[ansDic objectForKey:@"text"] forState:UIControlStateNormal];
                    }else{
                        [self setHideItemForSelectWithButton:button currentView:curV];
                    }
                }else{
                    [self setHideItemForSelectWithButton:button currentView:curV];
                }
            }
            else if (button.tag == 1) {//Answer B
                
                if (answers.count > 1) {
                    ansDic = answers[1];
                    if ([self checkText:[ansDic objectForKey:@"text"]]) {
                        [button setTitle:[ansDic objectForKey:@"text"] forState:UIControlStateNormal];
                    }else{
                        [self setHideItemForSelectWithButton:button currentView:curV];
                    }
                }else{
                    [self setHideItemForSelectWithButton:button currentView:curV];
                }
            }
            else if (button.tag == 2) {//Answer C
                
                if (answers.count > 2) {
                    ansDic = answers[2];
                    if ([self checkText:[ansDic objectForKey:@"text"]]) {
                        [button setTitle:[ansDic objectForKey:@"text"] forState:UIControlStateNormal];
                    }else{
                        [self setHideItemForSelectWithButton:button currentView:curV];
                    }
                }else{
                    [self setHideItemForSelectWithButton:button currentView:curV];
                }
            }
            else if (button.tag == 3) {//Answer D
                
                if (answers.count > 3) {
                    ansDic = answers[3];
                    if ([self checkText:[ansDic objectForKey:@"text"]]) {
                        [button setTitle:[ansDic objectForKey:@"text"] forState:UIControlStateNormal];
                    }else{
                        [self setHideItemForSelectWithButton:button currentView:curV];
                    }

                }else{
                    [self setHideItemForSelectWithButton:button currentView:curV];
                }
            }
            
            if (button.tag != 1111) {
                [button setEnabled:true];
            }
        }
    }
}

- (void)setHideItemForSelectWithButton: (UIButton *)button currentView: (UIView *)curV {
    [self hideIndexLabel:(100 + button.tag) currentView:curV];
    [self hideCheckImage:(100 + button.tag * 2) currentView:curV];
    [button setTitle:@"" forState:UIControlStateNormal];
    [button setHidden:true];
}

//- (void)setShowItemForSelectWithButton: (UIButton *)button currentView: (UIView *)curV {
//    [self hideIndexLabel:(100 + button.tag) currentView:curV];
//    [self hideCheckImage:(100 + button.tag * 2) currentView:curV];
//    [button setTitle:@"" forState:UIControlStateNormal];
//    [button setHidden:true];
//}

- (void)showSubViewsOf {
    
}

- (void)setInfoForShortAnswer: (UIView *)curV {
    for (UIView *subV in curV.subviews) {
        if ([subV isKindOfClass:[CustomTextView class]]) {
            CustomTextView *textV = (CustomTextView *)subV;
            [textV setText:@""];
        }else if ([subV isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subV;
            if (button.tag == 111) {
                if ((questionIndex + 1) == questionsArray.count) {
                    [button setTitle:NSLocalizedString(@"Complete", nil) forState:UIControlStateNormal];
                }else{
                    [button setTitle:NSLocalizedString(@"Check", nil) forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)hideIndexLabel: (NSInteger)num currentView: (UIView *)curV {
    for (UIView *subV in curV.subviews) {
        if ([subV isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subV;
            if (label.tag == num) {
                [label setHidden:true];
            }
        }
    }
}

- (void)hideCheckImage: (NSInteger)num currentView: (UIView *)curV {
    for (UIView *subV in curV.subviews) {
        if ([subV isKindOfClass:[UIImageView class]]) {
            UIImageView *imageV = (UIImageView *)subV;
            if (imageV.tag == num) {
                [imageV setHidden:true];
            }
        }
    }
}

- (void)setQuizInfo {
    [resultQuizDic setObject:[quizDic objectForKey:@"quiz_id"] forKey:RESULT_QUIZ_QUIZID];
    [resultQuizDic setObject:[quizDic objectForKey:@"time"] forKey:RESULT_QUIZ_TIME];
    [resultQuizDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:STUDENTNAME] forKey:RESULT_QUIZ_STUDENTNAME];
    [resultQuizDic setObject:[NSString stringWithFormat:@"%lu", (unsigned long)questionsArray.count] forKey:RESULT_QUIZ_TOTALQUESTION];
}

- (void)showStartView {
    [self initialExamData];
    [self.quizIDTextField setText:@""];
    [self.startView setHidden:false];
    [self hideQuestion];
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

#pragma mark - http AFNetworking Custom Method

- (void)httpGetExamQuestion: (NSMutableDictionary *)param {
    [ProgressHUD show:NSLocalizedString(@"Loading", nil) Interaction:NO];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, EXAMQUESTIONS];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager GET:url parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        NSMutableDictionary *dic = [responseObject mutableCopy];
        quizDic = [[dic objectForKey:@"quiz_informations"] mutableCopy];
        currentQuizType = [[quizDic objectForKey:@"quiz_type"] intValue];
        NSMutableArray *questArray = [[dic objectForKey:@"questions"] mutableCopy];
        for (NSMutableDictionary *questDic in questArray) {
            NSMutableDictionary *newDic = [questDic mutableCopy];
            NSMutableArray *ansArray = [newDic objectForKey:@"answers"];
            NSMutableArray *newArray = [[NSMutableArray alloc] init];
            for (NSMutableDictionary *ansDic in ansArray) {
                [newArray addObject:[ansDic mutableCopy]];
            }
//            newDic = [NSMutableDictionary dictionaryWithObject:@[newArray] forKey:@[@"answers"]];
            [newDic setObject:newArray forKey:@"answers"];
            [questionsArray addObject:newDic];
        }
        examDic = [NSMutableDictionary dictionaryWithObjects:@[quizDic, questionsArray] forKeys:@[@"quiz_informations", @"questions"]];
        examTime = [(NSString *)[quizDic objectForKey:@"time"] intValue] * 60;//seconds
        currentTime = examTime;
        
        [self setQuizInfo];
        
        firstView = [self createView];
        secondView = [self createView];
        [self.view addSubview:firstView];
        [self.view addSubview:secondView];
        
        if (questionsArray.count > 0) {
            //counting time for Quiz
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countingTime:) userInfo:nil repeats:YES];
            
            [self.startView setHidden:true];
            [self showQuestion];
        }else{
            [self showWarningAlert:NSLocalizedString(@"There is no data for this Quiz", nil)];
        }

        [ProgressHUD dismiss];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSString *errorStr = [NSString stringWithFormat:@"%@", error];
        if ([errorStr rangeOfString:@"array or object"].location == NSNotFound) {
            [self showWarningAlert:NSLocalizedString(@"Netwok problems\nPlease try again!", nil)];
        }else{
            [self showMessage:@"There is no Quiz that matches with given ID"];
        }

//        [self showWarningAlert:[NSString stringWithFormat:@"The network status has some problems.\n Please try again!"]];
        [self showStartView];//go to the start up for Exam for testing
        [ProgressHUD dismiss];
    }];
}

- (void)httpSaveExamResult: (NSMutableDictionary *)dic {
    [ProgressHUD show:NSLocalizedString(@"Saving", nil) Interaction:NO];
    
    NSString *registerData = [dic rj_jsonStringWithPrettyPrint:YES];
    NSLog(@"JSON: %@", registerData);
    
    NSData *nsData = [registerData dataUsingEncoding: NSUTF8StringEncoding];
    NSString *based64Encode = [nsData base64EncodedStringWithOptions:0];
    NSLog(@"64Encoded: %@", based64Encode);
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:based64Encode forKey:@"json"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, SAVERESULTS];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        
        [self showStartView];//go to the start up for Exam
        [ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSString *errorStr = [NSString stringWithFormat:@"%@", error];
        if ([errorStr rangeOfString:@"array or object"].location == NSNotFound) {
            [self showWarningAlert:NSLocalizedString(@"Netwok problems\nPlease try again!", nil)];
        }else{
            [self showMessage:NSLocalizedString(@"Your results saved and quiz owner can see it now", nil)];
        }
        
//        [self showWarningAlert:[NSString stringWithFormat:@"The network status has some problems. Please try again!"]];
        [self showStartView];//go to the start up for Exam for testing
        [ProgressHUD dismiss];
        
    }];

}

- (void)showMessage: (NSString *)msg {
    //    NSString *msg = @"Quiz ID copied, now share it with your students";
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){    //if device is an iPad
        //        [alert setModalPresentationStyle:UIModalPresentationPopover];
        [alert.popoverPresentationController setPermittedArrowDirections:0];
        [alert.popoverPresentationController setSourceView:self.view];
        CGRect rect = self.view.frame;
        rect.origin.x = self.view.frame.size.width / 20;
        rect.origin.y = self.view.frame.size.height / 20;
        [alert.popoverPresentationController setSourceRect:rect];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
    
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alert dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"Do some work");
    });
    
    //copy Quiz ID.
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
