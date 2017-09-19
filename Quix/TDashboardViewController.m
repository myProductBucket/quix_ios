//
//  TDashboardViewController.m
//  Quix
//
//  Created by Karl Faust on 12/18/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "TDashboardViewController.h"
#import "MFSideMenu.h"
#import "TDashboardHeaderCell.h"
#import "TDashboardQuizCell.h"
#import "TDashboardQuestionCell.h"
#import "AppDelegate.h"
#import "WebViewController.h"

@interface TDashboardViewController ()<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    BOOL isGuest;
    BOOL isQuiz;
    BOOL isUpdate;//for Question including answers
    CGFloat MODALTIMEINTERNAL;
    
    NSInteger rowCount;//current rows
    NSInteger selectedIndex;//indicating selected Row Index(Quiz) of the tableview
    NSInteger selectedQuizID;//indicating selected Quiz ID through tablevioew(quizArray)
    NSInteger selectedQuestionIndex;//indicating selected Row Index(Question) of the tableview
    NSArray *quizIcons;//matching, ordering, ....
    NSArray *quizModes;//.........
    NSArray *quizDescription;//description for quiz
    
    NSArray *alphaArray;//A, B, C, D
    
    NSMutableArray *quizArray;//the set of the Quiz
    NSMutableArray *questionArray;//the set of the whole Questions
    NSMutableArray *subQuestionArray;//the sub array of the QuestionArray (corresponding the individual Quiz)
    
    NSMutableDictionary *questionStats;//indicating the selected Question Stats
//    BOOL isYes;//for Question Alert
    
    /*Current Teacher ID (Your ID)*/
    NSString *MY_USERID;
    
    NSString *attachedImage;
}
#pragma mark - Modal Effect View Property
@property (weak, nonatomic) IBOutlet UIVisualEffectView *modalEffectView;
@property (weak, nonatomic) IBOutlet UILabel *modalTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *modalScrollV;
//Quiz
@property (weak, nonatomic) IBOutlet UITextField *quizNameText;//If it is Question, QuestionText
@property (weak, nonatomic) IBOutlet UITextField *quizTimeText;//If it is Question, Feedback corresponding the Qestion
@property (weak, nonatomic) IBOutlet UIButton *attachButton;

//Question
//@property (weak, nonatomic) IBOutlet UITextView *questionTextV;

#pragma mark - TableView Property
@property (weak, nonatomic) IBOutlet UITableView *myTable;//displaying Quiz and Questions
//--headerCell

//attaching image for question
//@property (nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTableViewConstraint;
@end

@implementation TDashboardViewController

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
    
    //setting hidden of modalEffectView
    [self.modalEffectView setHidden:true];
    [self.modalEffectView setAlpha:0];
    
    isQuiz = YES;
    isUpdate = NO;
    MODALTIMEINTERNAL = 0.5;
    quizIcons = @[@"ic_drag_order.png", @"ic_fill_blank.png", @"ic_match.png", @"ic_multiple_choice.png", @"ic_multiple_correct.png", @"ic_multiple_correct.png"];
    quizModes = @[NSLocalizedString(@"Order", nil), NSLocalizedString(@"Fill in the Blank", nil), NSLocalizedString(@"Match", nil), NSLocalizedString(@"Multiple Choice", nil), NSLocalizedString(@"Multiple Select", nil), NSLocalizedString(@"Short Answer/Essay", nil)];
    quizDescription = @[@"", NSLocalizedString(@"Single word/phrase answer", nil), @"", NSLocalizedString(@"2~4 choices, 1 correct answer", nil), NSLocalizedString(@"2~4 choices, more than 1 correct answer", nil), NSLocalizedString(@"Free-form answer", nil)];
    
    //Multiple Choice, Multiple Select, Fill in the Blank, Ordering, Matching, and Short Answer/Essay type questions
    if (quizArray == nil) {
        quizArray = [[NSMutableArray alloc] init];
    }
    if (questionArray == nil) {
        questionArray = [[NSMutableArray alloc] init];
    }
    if (subQuestionArray == nil) {
        subQuestionArray = [[NSMutableArray alloc] init];
    }

    alphaArray = @[@"A", @"B", @"C", @"D"];
//    [self setBorderLine];
    [self.shareButton setHidden:true];
    self.bottomTableViewConstraint.constant = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self setModalScrollV];
    
    //
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.shareButton setHidden:true];
    self.bottomTableViewConstraint.constant = 0;
    
    AppDelegate *myDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    isGuest = myDel.isGuest;
    if (isGuest == NO) {//If you are Admin
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:USERID]) {
            MY_USERID = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
        }else{
            MY_USERID = TESTUSERID;
        }
        
        [self httpGetQuiz];
    }else{//If you are Guest
        MY_USERID = TESTUSERID;
//        [self httpGetQuiz];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///////////////////
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (BOOL)shouldAutorotate {
//    return NO;
//}

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

#pragma mark - custom event

- (IBAction)shareButtonTouchUp:(UIButton *)sender {
    
    NSMutableDictionary *selectedQuiz = quizArray[selectedIndex];
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
                               [self showMessage: NSLocalizedString(@"Quiz ID copied, now share it with your students", nil)];
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

- (IBAction)addTouchUp:(id)sender {
    isUpdate = NO;
    [self setModalScrollV];
    
    [self showModalEffectView];
}
//Touch Up the <X> button
- (IBAction)closeModalTouchUp:(id)sender {
    [self.view endEditing:YES];
    
    [self hideModalEffectView];
}
//attaching the image
- (IBAction)attachTouchUp:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attaching Image", nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* gallery = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Gallery", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* camera = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Camera", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                             {
                                [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
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
    [alert addAction:gallery];
    [alert addAction:camera];
    [alert addAction:cancel];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){    //if device is an iPad
        //        [alert setModalPresentationStyle:UIModalPresentationPopover];
        [alert.popoverPresentationController setPermittedArrowDirections:0];
        [alert.popoverPresentationController setSourceView:self.view];
        CGRect rect = self.view.frame;
        rect.origin.x = self.view.frame.size.width / 20;
        rect.origin.y = self.view.frame.size.height / 20;
        [alert.popoverPresentationController setSourceRect:rect];
    }
    
    [self presentViewController:alert animated:true completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  
    NSData *dataImage = [[NSData alloc] init];
//    dataImage = UIImagePNGRepresentation(image);
    dataImage = UIImageJPEGRepresentation(image, 0.1 /*compressionQuality*/);
    attachedImage = [dataImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITableView Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isQuiz) {
        rowCount = quizArray.count;
    }else{
        rowCount = subQuestionArray.count;
    }
    return rowCount;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 74;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TDashboardHeaderCell *headerCell = (TDashboardHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"TDashboardHeaderCell"];
    NSUserDefaults *curUser = [NSUserDefaults standardUserDefaults];
    if (isQuiz) {
        headerCell.nameLabel.text = [curUser objectForKey:USERNAME];//the name of the Teacher
        headerCell.reportIcon.image = [UIImage imageNamed:@"ic_question.png"];
        headerCell.numberOf.text = [NSString stringWithFormat:NSLocalizedString(@"%lu Quizzes", nil), (unsigned long)quizArray.count];
        headerCell.addLabel.text = NSLocalizedString(@"Add Quiz", nil);
    }else{
        headerCell.nameLabel.text = [(NSMutableDictionary *)(quizArray[selectedIndex]) objectForKey:QUIZNAME];//Quiz Name
        headerCell.reportIcon.image = [UIImage imageNamed:@"ic_quiz_time.png"];
        headerCell.numberOf.text = [NSString stringWithFormat:@"%@:00 min", [(NSMutableDictionary *)(quizArray[selectedIndex]) objectForKey:QUIZTIME]];
        headerCell.addLabel.text = NSLocalizedString(@"Add Question", nil);
    }
    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *myCell;
    if (isQuiz) {
        if (quizArray.count == 0) {
            return nil;
        }
        TDashboardQuizCell *quizCell = (TDashboardQuizCell *)[self.myTable dequeueReusableCellWithIdentifier:@"TDashboardQuizCell"];
        quizCell.numLabel.text = [NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)];
        NSMutableDictionary *currentQuiz = quizArray[indexPath.row];
        quizCell.quizNameLabel.text = [currentQuiz objectForKey:QUIZNAME];
        quizCell.quizTimeLabel.text = [NSString stringWithFormat: @"%@:00 min", [currentQuiz objectForKey:QUIZTIME]];
        quizCell.deleteButton.tag = indexPath.row;
        quizCell.editButton.tag = indexPath.row;

        quizCell.numofQuestionsLbl.text = [NSString stringWithFormat:NSLocalizedString(@"%@ questions", nil), [currentQuiz objectForKey:NUMOFQUESTIONS]];
        
        myCell = quizCell;
    }else{
        if (subQuestionArray.count == 0) {
            return nil;
        }
        TDashboardQuestionCell *questionCell = (TDashboardQuestionCell *)[self.myTable dequeueReusableCellWithIdentifier:@"TDashboardQuestionCell"];
        NSMutableDictionary *selectedQuestion = subQuestionArray[indexPath.row];
        [questionCell.numLabel setText:[NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)]];
        [questionCell.questionLabel setText:[selectedQuestion objectForKey:QUESTIONNAME]];
        [questionCell.deleteButton setTag:indexPath.row];
        [questionCell.editButton setTag:indexPath.row];
        [questionCell.statusButton setTag:indexPath.row];
        myCell = questionCell;
    }
    
    if (indexPath.row == (rowCount - 1)) {
        [ProgressHUD dismiss];
    }
    
    return myCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isQuiz) {//If you are Admin or Guest, you have to analyze .....
        
        selectedIndex = indexPath.row;
        
        if (isGuest == NO) {//if you are admin, getting questions corresponding specific Quiz

            [ProgressHUD show:NSLocalizedString(@"Loading", nil) Interaction:NO];
            subQuestionArray = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *selectedQuiz = quizArray[indexPath.row];
            NSInteger questionCount = [(NSString *)[selectedQuiz objectForKey:@"question_count"] intValue];
            
            selectedQuizID = [[selectedQuiz objectForKey:QUIZTYPE] intValue];
            
            if (questionCount <= 0) {
                isQuiz = NO;
                [self.myTable reloadData];
                [ProgressHUD dismiss];
            }else{
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

                [parameters setObject:[selectedQuiz objectForKey:QUIZID] forKey:@"quiz_id"];
            
                [self httpGetQuestions:parameters];
            }
        }else{//if you are guest
            isQuiz = NO;
            
            NSMutableDictionary *selectedQuiz = quizArray[indexPath.row];
            selectedQuizID = [[selectedQuiz objectForKey:QUIZTYPE] intValue];
            
            subQuestionArray = questionArray[selectedIndex];
            [self.myTable reloadData];
        }
    }else{//if it is Question
        selectedQuestionIndex = indexPath.row;
        
        if (isGuest == NO) {
//            NSMutableDictionary *curQuestion = subQuestionArray[indexPath.row];
//            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[curQuestion objectForKey:QUESTIONID] forKey:@"question_id"];
//            [self httpGetAnswers:param];
        }
        
        isUpdate = YES;
        [self setModalScrollV];
        [self showModalEffectView];
    }
}

#pragma mark - Manage Quiz and Questions
-(void)getQuiz {
    
}

- (void)httpCustomManager: (NSString *)postContext parameter: (NSMutableDictionary *)param {
    NSString *url = [NSString stringWithFormat:@"%@/%@", ROOTURL, postContext];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:url parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        
        [ProgressHUD dismiss];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [ProgressHUD dismiss];
    }];
}

#pragma mark - Custom Method
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
    
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alert dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"Do some work");
    });
    
    //copy Quiz ID.
}

- (void)showAlert: (NSString *)msg {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
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
}

- (void)showModalEffectView {
    if (isQuiz) {
        [self.modalTitle setText:NSLocalizedString(@"New Quiz", nil)];
        [self.quizNameText setPlaceholder:NSLocalizedString(@"Write your quiz name here", nil)];
        [self.quizTimeText setPlaceholder:NSLocalizedString(@"Time Allocated (optional)", nil)];
        [self.quizNameText setText:@""];
        self.quizTimeText.text = @"";
        [self.quizTimeText setKeyboardType:UIKeyboardTypeNumberPad];
        [self.attachButton setHidden:true];
    }else{//Question
        [self.quizNameText setPlaceholder:NSLocalizedString(@"Write question here", nil)];
        [self.quizTimeText setPlaceholder:NSLocalizedString(@"Write feedback (Optional)", nil)];
        [self.quizTimeText setKeyboardType:UIKeyboardTypeDefault];
        if (isUpdate) {
            [self.modalTitle setText:NSLocalizedString(@"Update Question", nil)];
            NSMutableDictionary *questionDic = subQuestionArray[selectedQuestionIndex];
            [self.quizNameText setText:[questionDic objectForKey:QUESTIONNAME]];
            self.quizTimeText.text = [questionDic objectForKey:FEEDBACK];
            [self.quizNameText setEnabled:false];
            [self.quizTimeText setEnabled:false];
        }else{
            
            attachedImage = [[NSString alloc] init];
            
            [self.modalTitle setText:NSLocalizedString(@"New Question", nil)];
            [self.quizNameText setText:@""];
            self.quizTimeText.text = @"";
            [self.quizNameText setEnabled:true];
            [self.quizTimeText setEnabled:true];
        }
        [self.attachButton setHidden:false];
    }
    
    [UIView animateWithDuration:MODALTIMEINTERNAL delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.modalEffectView setHidden:false];
        [self.modalEffectView setAlpha:1];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideModalEffectView {
    [UIView animateWithDuration:MODALTIMEINTERNAL delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.modalEffectView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.modalEffectView setHidden:true];
    }];
}

- (void)setModalScrollV {//initialize the modal View(scrollview)
    //remove original subviews in ModalScrollView
    for(UIView *subview in [self.modalScrollV subviews]) {
        [subview removeFromSuperview];
    }
    
    CGFloat scrollHeight;
    CGFloat scrolWidth;
    
//    isQuiz = false;
    
    if (isQuiz) {//If adding Quiz
        scrollHeight = self.modalScrollV.frame.size.height;
        scrolWidth = (scrollHeight * 3 / 2) * 6 + 40;
        
        [self.modalScrollV setContentSize:CGSizeMake(scrolWidth, scrollHeight)];
        
        for (NSInteger i = 0; i < 6; i++) {
            [self addSubViewForQuiz:i];
        }
    }else{//If adding Question
        if (selectedQuizID == 0) {//mutiple choice (only this, you can choose the feedback)
            scrollHeight = 620;//10 + (30 + 10 + 30 + 20) * 4 + 50
        }else if (selectedQuizID == 5) {//short answer
            scrollHeight = self.modalScrollV.frame.size.height;
        }else{
            scrollHeight = 420;
        }

        scrolWidth = self.modalScrollV.frame.size.width;
        
        [self.modalScrollV setContentSize:CGSizeMake(scrolWidth, scrollHeight)];
        
//        if (selectedQuizID != 5) {//if it is not short answer()
            for (NSInteger i = 0; i < 4; i++) {
                [self addSubViewForQuestion: i];
            }
//        }
        
        [self addSaveButtonForQuestion];
    }
}
//--------------------------------------------adding subviews for Quiz
- (void)addSubViewForQuiz: (NSInteger)num {
    CGFloat hei = self.modalScrollV.frame.size.height;
    CGFloat wid = hei * 3 / 2;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake((wid + 8) * num, 0, wid, hei)];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((wid - hei / 2) / 2, 0, hei / 2, hei / 2)];
    imageV.image = [UIImage imageNamed:quizIcons[num]];
    [view addSubview:imageV];
    
    UILabel *modeLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, hei / 2, wid, hei / 4)];
    [modeLabel setText:quizModes[num]];
    [modeLabel setTextColor:[UIColor colorWithRed:(222/255.f) green:(52/255.f) blue:(43/255.f) alpha:1]];
    [modeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size: (hei / 7)]];
    modeLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:modeLabel];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, hei * 3 / 4, wid, hei / 4)];

    detailLabel.numberOfLines = 0;
    detailLabel.text = quizDescription[num];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    [detailLabel setFont:[UIFont fontWithName: modeLabel.font.fontName size: (hei / 12)]];
    [view addSubview:detailLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, wid, hei)];
    button.tag = num;
    [button setHighlighted:true];
    [button addTarget:self action:@selector(textModeButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(textModeButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [button addTarget:self action:@selector(textModeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    [self.modalScrollV addSubview:view];
}

- (void)textModeButtonTouchUpOutside: (UIButton *)button {
//    [button setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    [button.superview setBackgroundColor:[UIColor whiteColor]];
    NSLog(@"---------------------%ld, <Outside>", (long)button.tag);
}

- (void)textModeButtonTouchDown: (UIButton *)button {
    for (UIView *view in self.modalScrollV.subviews) {
        [view setBackgroundColor:[UIColor whiteColor]];
    }
    [button.superview setBackgroundColor:[UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1]];
    NSLog(@"---------------------%ld, <Down>", (long)button.tag);
}

- (void)textModeButtonPressed: (UIButton *)button {//adding the Quiz in tableview
    [ProgressHUD show:@"Adding Quiz..." Interaction:NO];
    NSLog(@"---------------------%ld", (long)button.tag);
    
    if ([self.quizNameText checkText: self.quizNameText] == NO) {
        [self showWarningAlert:NSLocalizedString(@"You can not leave quiz name empty", nil)];
        [ProgressHUD dismiss];
    }else{//------------ Adding the Quiz in tableview
        NSString *quizID;
        switch (button.tag) {//@"Order", @"Fill in the Blank", @"Match", @"Multiple Choice", @"Multiple Select", @"Short Answer/Essay"
            case 0://Order: 3
                quizID = @"3";
                break;
            case 1://Fill in the Blank: 2
                quizID = @"2";
                break;
            case 2://Match: 4
                quizID = @"4";
                break;
            case 3://Multiple Choice: 0
                quizID = @"0";
                break;
            case 4://Multiple Select: 1
                quizID = @"1";
                break;
            case 5://Short Answer/Essay: 5
                quizID = @"5";
                break;
                
            default:
                break;
        }
        
        if ([self.quizTimeText checkText:self.quizTimeText] == NO) {
            [self.quizTimeText setText:@"20"];//setting default time(20 min)
        }
        
        NSMutableDictionary *quizDic = [NSMutableDictionary dictionaryWithObjects:@[self.quizNameText.text, quizID, self.quizTimeText.text, [NSNumber numberWithInt:0]] forKeys:@[QUIZNAME, QUIZTYPE, QUIZTIME, NUMOFQUESTIONS]];//@{QUIZNAME: self.quizNameText.text, QUIZID: quizID, QUIZTIME: self.quizTimeText.text, NUMOFQUESTIONS: [NSNumber numberWithInt:0]};
        
        if (isGuest == NO) {
            NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithObjects:@[self.quizNameText.text, quizID, self.quizTimeText.text, MY_USERID] forKeys:@[QUIZNAME, QUIZTYPE, QUIZTIME, TEACHERID]];
            
            [self httpAddQuiz:newDic];//trasforing the new quiz to Server
        }
        else{
            [quizArray addObject:quizDic];
        
            NSMutableArray *subArray = [[NSMutableArray alloc] init];
            [questionArray addObject:subArray];
        
            [self.myTable reloadData];
        
            [ProgressHUD dismiss];
        }
        [self hideModalEffectView];
    }
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

- (void)showQuestionAlert: (NSString *)msg{
//    BOOL isYes = YES;
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Question", nil)
                                  message:msg
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yes = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Yes", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                            
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"No", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                            
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}


//- (BOOL)checkText: (UITextField *)text {//check the Quiz Name and Time in ModalEffectView
//    NSString *rawString = [text text];
//    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
//    if ([trimmed length] == 0) {
//        // Text was empty or only whitespace.
//        
//        return NO;
//    }
//    return YES;
//}

- (void)initTextField {
    self.quizNameText.text = @"";
    self.quizTimeText.text = @"";
}
//----------------------------------------------   Adding subviews for Questions
- (void)addSubViewForQuestion: (NSInteger)num {
    CGFloat hei = 140;
    CGFloat cHei = 90;
    if (selectedQuizID != 0) {//if multiple choice(need feedback section in only this quiz)
        hei = 90;
    }
    CGFloat wid = self.modalScrollV.frame.size.width;
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10 + hei * num, 30, 30)];
    [numLabel setBackgroundColor: [UIColor colorWithRed:(222/255.f) green:(52/255.f) blue:(43/255.f) alpha:1]];
    [numLabel setTextColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1]];
    [numLabel setText:alphaArray[num]];
    numLabel.textAlignment = NSTextAlignmentCenter;
    [numLabel setTag:num];
    
    //write the answer
    UITextField *ansTxt = [[UITextField alloc] initWithFrame:CGRectMake(45, 10 + hei * num, wid - 50, 30)];
    ansTxt.tag = num * 2;//----------------tag for answer
    ansTxt.layer.borderColor = [UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1].CGColor;
    ansTxt.layer.borderWidth = 1.0;
    if (selectedQuizID != 2) {
        [ansTxt setPlaceholder:NSLocalizedString(@" Write choice here", nil)];
    }else{
        if (num == 0) {
            [ansTxt setPlaceholder:NSLocalizedString(@" Write correct answer here", nil)];
        }else{
            [ansTxt setPlaceholder:NSLocalizedString(@" Write alternative correct answer (Optional)", nil)];
        }
    }


    //write the feedback
    UITextField *feedTxt = [[UITextField alloc] initWithFrame:CGRectMake(45, 50 + hei * num, wid - 50, 30)];
    feedTxt.tag = num * 2 + 1;//-------------------tag for feedback
    feedTxt.layer.borderColor = [UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1].CGColor;
    feedTxt.layer.borderWidth = 1.0;
    
    [feedTxt setPlaceholder:NSLocalizedString(@" Write feedback about this choice (Optional)", nil)];
    
    if (selectedQuizID != 0) {//if multiple choice(need feedback section in only this quiz)
        [feedTxt setHidden:true];
        cHei = 50;
    }
    if (selectedQuizID == 4) {//match questions
        [feedTxt setPlaceholder:NSLocalizedString(@" Write correct match for this choice here (Required)", nil)];
        [feedTxt setHidden:false];
    }
    
    //check button(true or false)
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(wid - 160, cHei + hei * num, 150, 30)];
    button.tag = num * 2;
    [button setBackgroundImage:[UIImage imageNamed:@"ic_correct_unchecked.png"] forState:UIControlStateNormal];
//    [button setTitle:@"Is this choice correct?" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:true];
    [button setReversesTitleShadowWhenHighlighted:true];
    [button addTarget:self action:@selector(checkButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
    if (selectedQuizID != 0 && selectedQuizID != 1) {//if it is not Multiple choice and Mutiple select, correctAnswer Button is invisible.
        [button setHidden:true];
    }
    
    if (isUpdate) {
        NSMutableDictionary *selectedQuestion = subQuestionArray[selectedQuestionIndex];
        NSMutableArray *selectedAnswers = [selectedQuestion objectForKey:ANSWERS];
        if (num >= selectedAnswers.count) {
            [ansTxt setText:@""];
            [feedTxt setText:@""];
        }else{
            NSMutableDictionary *currentAnswer = selectedAnswers[num];
            [ansTxt setText:[currentAnswer objectForKey:ANSWERTEXT]];
            if (selectedQuizID == 4) {//Match Quiz
                [feedTxt setText:[currentAnswer objectForKey:@"match_"]];
                NSLog(@"%@", feedTxt.text);
            }else{
                [feedTxt setText:[currentAnswer objectForKey:FEEDBACK]];
            }

            NSString *checkStats = [NSString stringWithFormat:@"%@", [currentAnswer objectForKey:CORRECT]];
            if ([checkStats isEqualToString:@"1"]) {
                [button setBackgroundImage:[UIImage imageNamed: @"ic_correct_checked.png"] forState:UIControlStateNormal];
            }else{
                [button setBackgroundImage:[UIImage imageNamed: @"ic_correct_unchecked.png"] forState:UIControlStateNormal];
            }
        }
//        [button setEnabled:NO];
    }
    
    if (selectedQuizID == 5) {
        [numLabel setHidden:true];
        [ansTxt setHidden:true];
        [feedTxt setHidden:true];
        [button setHidden:true];
    }

    [self.modalScrollV addSubview:numLabel];
    [self.modalScrollV addSubview:ansTxt];
    [self.modalScrollV addSubview:feedTxt];
    [self.modalScrollV addSubview:button];
}

- (void)checkButtonTouchUp: (UIButton *)sender {
    if (sender.tag % 2 == 0) {
        sender.tag += 1;
        [sender setBackgroundImage:[UIImage imageNamed:@"ic_correct_checked.png"] forState:UIControlStateNormal];
        
        if (selectedQuizID == 0) {//multiple choice
            for (UIView *subV in self.modalScrollV.subviews) {
                if ([subV isKindOfClass:[UIButton class]] && subV.tag < 8) {
                    UIButton *button = (UIButton *)subV;
                    if (button.tag % 2 == 1 && button.tag != sender.tag) {
                        button.tag -= 1;
                        [button setBackgroundImage:[UIImage imageNamed:@"ic_correct_unchecked.png"] forState:UIControlStateNormal];
                    }
                }
            }
        }
    }else{
        sender.tag -= 1;
        [sender setBackgroundImage:[UIImage imageNamed:@"ic_correct_unchecked.png"] forState:UIControlStateNormal];
    }
}

- (void)uncheckOthers {
    for (UIView *subV in self.modalScrollV.subviews) {
        if ([subV isKindOfClass:[UIButton class]] && subV.tag < 8) {
            UIButton *button = (UIButton *)subV;
            if (button.tag % 2 == 1) {
                button.tag -= 1;
                [button setBackgroundImage:[UIImage imageNamed:@"ic_correct_unchecked.png"] forState:UIControlStateNormal];
            }
        }
    }
}

//setting boarderline in modalView for Question
- (void)setBorderLineForModalScrollView {
    
//    self.modalScrollV set
//    self.questionTextV.layer.borderColor = [UIColor colorWithRed:(236/255.f) green:(236/255.f) blue:(236/255.f) alpha:1].CGColor;
//    self.questionTextV.layer.borderWidth = 1.0;
//    self.questionTextV.layer.cornerRadius = 5.0;
}

//------------------------------------------------adding SaveButton for Question
- (void)addSaveButtonForQuestion {
    CGFloat hei = 140;
    
    if (selectedQuizID == 0) {//multiple choice
        hei = 140;
    }else if (selectedQuizID == 5) {//short answer
        hei = 0;
    }else{
        hei = 90;
    }
    
    CGFloat wid = self.modalScrollV.frame.size.width;
    
    UIButton *saveBt = [[UIButton alloc] initWithFrame:CGRectMake(wid - 175, 10 + hei * 4, 170, 30)];
    [saveBt setBackgroundColor:[UIColor colorWithRed:(137/255.f) green:(202/255.f) blue:(44/255.f) alpha:1]];
    [saveBt setTintColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1]];
    if (isUpdate) {
        [saveBt setTitle:NSLocalizedString(@"Update Question", nil) forState:UIControlStateNormal];
    }else{
        [saveBt setTitle:NSLocalizedString(@"Save Question", nil) forState:UIControlStateNormal];
    }
    [saveBt addTarget:self action:@selector(saveQuestionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [saveBt setReversesTitleShadowWhenHighlighted:true];
    [saveBt setShowsTouchWhenHighlighted:true];
    [saveBt setTag:100];
    
    [self.modalScrollV addSubview:saveBt];
}

- (void)saveQuestionPressed: (UIButton *)sender {
    
    [ProgressHUD show:NSLocalizedString(@"Proccessing", nil) Interaction:NO];
    
//    BOOL isFill = NO;
    NSMutableArray *answerArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *selectedQuestion;
    if (isUpdate) {
        selectedQuestion = subQuestionArray[selectedQuestionIndex];
        answerArray = [selectedQuestion objectForKey:ANSWERS];
    }
    
    NSString *text = @"";
    
    //answers check
    
    BOOL isCorrectAnswer = FALSE;//indicating whether there is correct answer or none.(The teacher have to selecte at least one correct answer.)
    
    for (UIView *subV in self.modalScrollV.subviews) {
        if ([subV isKindOfClass:[UITextField class]]) {
            UITextField *textF = (UITextField *)subV;
            NSLog(@"%ld", (long)textF.tag);
            if (textF.tag < 4 && textF.tag % 2 == 0 && (selectedQuizID != 5 && selectedQuizID != 2)) {//if the current quiz is not short answer and fill in the blank
                if ([textF checkText:textF] == NO) {
                    [self showWarningAlert:NSLocalizedString(@"Fill at least 2 choices for this question type", nil)];
                    [ProgressHUD dismiss];
                    return;
                }
            }
            
            if (textF.tag < 2 && textF.tag % 2 == 0 && (selectedQuizID == 2)) {//if the current quiz is fill in the blank
                if ([textF checkText:textF] == NO) {
                    [self showWarningAlert:NSLocalizedString(@"Fill at least 1 answer for this Question", nil)];
                    [ProgressHUD dismiss];
                    return;
                }
            }
            
            if (textF.tag % 2 == 0) {//answer
                text = textF.text;
            }else{//feedback or matching text
                
                if ([self checkText:text] == NO) {
                    continue;
                }else if ([self checkText:text] && [self checkText:textF.text] == NO && selectedQuizID == 4) {//Match Quiz
                    [self showWarningAlert:NSLocalizedString(@"Enter a match for each pair", nil)];
                    return;
                }
                
                BOOL isCorrect = NO;
                NSString *str = (isCorrect)? @"true" : @"false";
                NSMutableDictionary * answerDic;
                
                if (isUpdate) {
                    NSInteger index = textF.tag / 2;
                    if (index < answerArray.count) {
                        NSMutableDictionary *nswerDic = answerArray[index];
                        NSMutableDictionary *curQuiz = quizArray[selectedIndex];
                        [nswerDic setObject:text forKey:ANSWERTEXT];
                        if ([[curQuiz objectForKey:QUIZTYPE] intValue] == 4) {//this is Match Quiz
                            [nswerDic setObject:textF.text forKey:MATCH];
                        }else {
                            [nswerDic setObject:textF.text forKey:FEEDBACK];
                        }
                    }
                }else{
                    
                    if (selectedQuizID == 4) {//Match Question
                        answerDic = [NSMutableDictionary dictionaryWithObjects:@[text, str, @"", textF.text] forKeys:@[ANSWERTEXT, CORRECT, FEEDBACK, MATCH]];//@{ANSWERTEXT: text, CORRECT: str, FEEDBACK: textF.text, MATCH: @""};
                    }else{
                        answerDic = [NSMutableDictionary dictionaryWithObjects:@[text, str,textF.text, @""] forKeys:@[ANSWERTEXT, CORRECT, FEEDBACK, MATCH]];//@{ANSWERTEXT: text, CORRECT: str, FEEDBACK: textF.text, MATCH: @""};
                    }
                    [answerArray addObject:answerDic];
                }
            }
        }
        //check button (it is true or false)
        if ([subV isKindOfClass:[UIButton class]] && subV.tag < 8) {
            NSInteger ind = subV.tag / 2;//indicating answer index (0 ~ 3)
            NSInteger lef = subV.tag % 2;//indicating checked or unchecked
            if (ind >= answerArray.count) {
                continue;
            }
            NSMutableDictionary *answerDic = answerArray[ind];
            
            BOOL checkStats;
            if (lef == 0) {
                checkStats = FALSE;
            }else{
                checkStats = TRUE;
                isCorrectAnswer = TRUE;
            }
            
            [answerDic setObject:[NSNumber numberWithBool:checkStats] forKey:CORRECT];
        }
    }
    
    if (isCorrectAnswer == FALSE && (selectedQuizID == 0 || selectedQuizID == 1)) {//If there is nothing for correct answer//Multiple Choice or Multiple Select
        [self showWarningAlert:NSLocalizedString(@"Set at least one choice as correct answer", nil)];
        [ProgressHUD dismiss];
        return;
    }
    
    
    if (isUpdate == NO) {
        NSMutableDictionary *questionDic = [NSMutableDictionary dictionaryWithObjects:@[self.quizNameText.text, self.quizTimeText.text, @"", MY_USERID, answerArray] forKeys:@[QUESTIONNAME, FEEDBACK, ATTACHMENT, TEACHERID, ANSWERS]];//@{QUESTIONNAME: self.quizNameText.text, FEEDBACK: self.quizTimeText.text, ATTACHMENT: @"", TEACHERID: @"106576594855868836584", ANSWERS: answerArray};
        
        if (isGuest == NO) {//-------adding the questions data to server
            
            NSMutableDictionary *curQuiz = quizArray[selectedIndex];
            NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjects:@[self.quizNameText.text, self.quizTimeText.text, @"", answerArray, [curQuiz objectForKey:QUIZID]] forKeys:@[QUESTIONNAME, FEEDBACK, ATTACHMENT, ANSWERS, QUIZID]];
            
            [self httpAddQuestion:param];
            
            if ([[curQuiz objectForKey:QUIZTYPE] intValue] == 3 && subQuestionArray.count == 0) {//Order
                [self showAlert:NSLocalizedString(@"Make sure you entered choices in correct order, that is how app knows the correct answer. Do not worry; the app will shuffle choices on student side", nil)];
            }
        }else{
            
            NSMutableDictionary *curQuiz = quizArray[selectedIndex];
            if ([[curQuiz objectForKey:QUIZTYPE] intValue] == 3 && subQuestionArray.count == 0) {//Order
                [self showAlert:NSLocalizedString(@"Make sure you entered choices in correct order, that is how app knows the correct answer. Do not worry; the app will shuffle choices on student side", nil)];
            }
        }
        [subQuestionArray addObject:questionDic];

    }else{
        [selectedQuestion setObject:self.quizNameText.text forKey:QUESTIONNAME];
        [selectedQuestion setObject:self.quizTimeText.text forKey:FEEDBACK];
        
        if (isGuest == NO) {//-------updating the answers data to server
            for (NSMutableDictionary *ansDic in answerArray) {
                NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjects:@[[ansDic objectForKey:ANSWERTEXT], [ansDic objectForKey:ANSWERID], [ansDic objectForKey:@"match_"], [ansDic objectForKey:FEEDBACK]] forKeys:@[ANSWERTEXT, @"answer_id", MATCH, FEEDBACK]];
                [self httpUpdateAnswer:param];
            }
        }
    }
    
    NSLog(@"saveQuestion---");
    if (isGuest == YES) {
        [self.myTable reloadData];
        
        [ProgressHUD dismiss];
    }
    [self hideModalEffectView];
}

//---------------- Tap Gesture
- (IBAction)dismissKeyboard:(id)sender {
    NSLog(@"dismiss KeyBoard....");
    [self.view endEditing:YES];
}

- (void)setPriority: (BOOL)guest {
    isGuest = guest;
}

- (void)showQuestonStats {

    NSMutableArray *questArray = [questionStats objectForKey:@"question"];
    NSMutableDictionary *quizDic = [questionStats objectForKey:@"quiz"];
    NSMutableAttributedString *content;
    NSString *midStr;
    NSInteger correctPer;
    NSInteger myFontSize;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        myFontSize = 24;
    }else{
        myFontSize = 16;
    }
    
    NSDictionary *conAttrDict = @{
                               NSFontAttributeName : [UIFont systemFontOfSize:myFontSize weight:UIFontWeightLight],
                               NSForegroundColorAttributeName : [UIColor blackColor]
                               };
    NSDictionary *titleAttrDict = @{
                                  NSFontAttributeName : [UIFont systemFontOfSize:myFontSize weight:UIFontWeightBold],
                                  NSForegroundColorAttributeName : [UIColor blackColor]
                                  };
    
    content = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"\nQuiz State", nil) attributes:titleAttrDict];
    midStr = [NSString stringWithFormat:NSLocalizedString(@"\nAverage Score: %@", nil), [quizDic objectForKey:@"avg_score"]];
    [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
    
    midStr = [NSString stringWithFormat:NSLocalizedString(@"\nAverage Time: %@(s)", nil), [quizDic objectForKey:@"avg_time"]];
    [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
    
    midStr = [NSString stringWithFormat:NSLocalizedString(@"\nStudent Count: %@\n", nil), [quizDic objectForKey:@"student_count"]];
    [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
    
    [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"\nQuestion State", nil) attributes:titleAttrDict]];
    
    if (selectedQuestionIndex < questArray.count) {
        NSMutableDictionary *questInfo = questArray[selectedQuestionIndex];
        correctPer = [[questInfo objectForKey:@"first_try"] intValue];//the percentage of the correct answers
        
        midStr = [NSString stringWithFormat:NSLocalizedString(@"\nFirst Try Correct:  %%%d", nil), [[questInfo objectForKey:@"first_try"] intValue]];
        [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
        
        midStr = [NSString stringWithFormat:NSLocalizedString(@"\nSecond Try Correct:  %%%d", nil), [[questInfo objectForKey:@"second_try"] intValue]];
        [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
        
        midStr = [NSString stringWithFormat:NSLocalizedString(@"\nThird Try Correct:  %%%d", nil), [[questInfo objectForKey:@"third_try"] intValue]];
        [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
    }else{
        correctPer = 0;
        midStr = [NSString stringWithFormat:@"\nFirst Try Correct:  %%%d", 0];
        [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
        
        midStr = [NSString stringWithFormat:@"\nSecond Try Correct:  %%%d", 0];
        [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
        
        midStr = [NSString stringWithFormat:@"\nThird Try Correct:  %%%d\n\n", 0];
        [content appendAttributedString:[[NSMutableAttributedString alloc] initWithString:midStr attributes:conAttrDict]];
    }
    
    if (selectedQuizID == 0) {//Multiple Choice
        NSMutableAttributedString *feedback;
        NSDictionary *feedAttrDict;
        UIColor *feedColor;
        NSString *feedStr;
        if (correctPer >= 80) {
            feedStr = NSLocalizedString(@"\n\nThis question needs revisions. A question correctly answered by more than 80% of students, it means the question is too easy.", nil);
            feedColor = [UIColor redColor];
        }else if (correctPer <= 30) {
            feedStr = NSLocalizedString(@"\n\nThis question needs revisions. A question correctly answered by less than 30% of students, it means the question is too difficult.", nil);
            feedColor = [UIColor redColor];
        }else{
            feedStr = NSLocalizedString(@"\n\nThis is a very good question. An average question should be correctly answered by 30~80% of students.", nil);
            feedColor = [UIColor colorWithRed:0 green:200/255.0f blue:0 alpha:1];
        }
        feedAttrDict = @{
                         NSFontAttributeName : [UIFont systemFontOfSize:(myFontSize - 2) weight:UIFontWeightMedium],
                         NSForegroundColorAttributeName : feedColor
                         };
        feedback = [[NSMutableAttributedString alloc] initWithString:feedStr attributes:feedAttrDict];
        
        [content appendAttributedString:feedback];
    }

    NSLog(@"%ld", (long)selectedQuestionIndex);

  
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController setValue:content forKey:@"attributedMessage"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    
    UIAlertAction *furtherReadingAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Further Reading", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        WebViewController *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        [self.navigationController pushViewController:webVC animated:true];
        
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];

    [alertController addAction:furtherReadingAction];
    [alertController addAction:cancelAction];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){    //if device is an iPad
        //        [alert setModalPresentationStyle:UIModalPresentationPopover];
        [alertController.popoverPresentationController setPermittedArrowDirections:0];
        [alertController.popoverPresentationController setSourceView:self.view];
        CGRect rect = self.view.frame;
        rect.origin.x = self.view.frame.size.width / 15;
        rect.origin.y = self.view.frame.size.height / 15;
        [alertController.popoverPresentationController setSourceRect:rect];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [imagePickerController setSourceType:sourceType];
    imagePickerController.allowsEditing = NO;
    imagePickerController.delegate = self;
    
//    if (sourceType == UIImagePickerControllerSourceTypeCamera)
//    {
//        /*
//         The user wants to use the camera interface. Set up our custom overlay view for the camera.
//         */
//        imagePickerController.showsCameraControls = YES;
//        
//        /*
//         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
//         */
////        self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
////        imagePickerController.cameraOverlayView = self.overlayView;
////        self.overlayView = nil;
//        UIView *pickerView = [[UIView alloc] initWithFrame:imagePickerController.cameraOverlayView.frame];
//        imagePickerController.cameraOverlayView = pickerView;
//    }
    
//    [UIViewController attemptRotationToDeviceOrientation];//----------
    
//    self.imagePickerController = imagePickerController;
    [self presentViewController:imagePickerController animated:YES completion:nil];
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

#pragma mark - Quiz Edit & Delete method

- (IBAction)quizEditTouchUp:(UIButton *)sender {
    selectedIndex = sender.tag;
    
    NSLog(@"--- Quiz Edit %ld---", (long)sender.tag);
    
    UIAlertController *editAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Quiz", nil) message: @"" preferredStyle:UIAlertControllerStyleAlert];
    [editAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        NSMutableDictionary *selectedQuiz = quizArray[selectedIndex];
        textField.placeholder = NSLocalizedString(@"Write your quiz name here", nil);
        textField.text = [selectedQuiz objectForKey:QUIZNAME];
    }];
    [editAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        NSMutableDictionary *selectedQuiz = quizArray[selectedIndex];
        textField.placeholder = NSLocalizedString(@"Time Allocated (optional)", nil);
        textField.text = [selectedQuiz objectForKey:QUIZTIME];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"Yes", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              UITextField *quizName = editAlert.textFields[0];
                              UITextField *quizTime = editAlert.textFields[1];
                              if ([quizName checkText:quizName] == NO) {
                                  [self showWarningAlert:NSLocalizedString(@"You can not leave quiz name empty", nil)];
                                  return;
                              }else{
                                  NSMutableDictionary *selectedQuiz = quizArray[selectedIndex];
//                                  NSMutableDictionary *newDic = [selectedQuiz mutableCopy];
//                                  [selectedQuiz removeObjectForKey:QUIZNAME];
//                                  [selectedQuiz removeObjectForKey:QUIZTIME];
                                  [selectedQuiz setValue:quizName.text forKey:QUIZNAME];
                                  if ([quizTime checkText:quizTime] == NO) {
                                      [selectedQuiz setValue:@"20" forKey:QUIZTIME];
                                  }else{
                                      [selectedQuiz setValue:quizTime.text forKey:QUIZTIME];
                                  }

                                  if (isGuest == NO) {//if you are admin
                                      [ProgressHUD show:NSLocalizedString(@"Updating", nil) Interaction:NO];
                                      [self httpUpdateQuiz];
                                  }
                              }
                              [editAlert dismissViewControllerAnimated:YES completion:nil];
                              [self.myTable reloadData];
                          }];
    [editAlert addAction:yes];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"No", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [editAlert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [editAlert addAction:no];
    [self presentViewController:editAlert animated:YES completion:nil];
}

- (IBAction)quizDeleteTouchUp:(UIButton *)sender {
    
    selectedIndex = sender.tag;
    NSLog(@"--- Quiz Delete %ld---", (long)sender.tag);
//    [self showQuestionAlert:@"Would you really delete this quiz?"];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Question", nil)
                                  message:NSLocalizedString(@"Are you sure you want to delete this ?", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"Yes", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [ProgressHUD show:NSLocalizedString(@"Deleting", nil) Interaction:NO];
                              if (isGuest == NO) {
                                  NSMutableDictionary *dic = quizArray[selectedIndex];
                                  NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[dic objectForKey:QUIZID] forKey:QUIZID];
                                  param = [param mutableCopy];
                                  [self httpDeleteQuiz:param];//-deleting data from server
                              }else{//if you are guest
                                  [questionArray removeObjectAtIndex:selectedIndex];
                              }
                              [quizArray removeObjectAtIndex:selectedIndex];
                              
                              [self.myTable reloadData];
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              if (quizArray.count == 0) {
                                  [ProgressHUD dismiss];
                              }
                          }];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"No", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Question Edit & Delete method

- (IBAction)deleteQuestionTouchUp:(UIButton *)sender {
     NSLog(@"--- Question Delete %ld---", (long)sender.tag);
    selectedQuestionIndex = sender.tag;
    
    //    [self showQuestionAlert:@"Would you really delete this quiz?"];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Delete", nil)
                                  message:NSLocalizedString(@"Are you sure you want to delete this ?", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"Yes", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [ProgressHUD show:NSLocalizedString(@"Delete", nil) Interaction:NO];
                              
                              if (isGuest == NO) {//if you are admin
                                  NSMutableDictionary *curQuestion = subQuestionArray[selectedQuestionIndex];
                                  NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[curQuestion objectForKey:QUESTIONID] forKey:@"question_id"];
                                  [self httpDeleteQuestion:param];
                              }
                              
                              [subQuestionArray removeObjectAtIndex:selectedQuestionIndex];
                              
                              [self.myTable reloadData];
                              [alert dismissViewControllerAnimated:YES completion:nil];
                              if (subQuestionArray.count == 0) {
                                  [ProgressHUD dismiss];
                              }
                          }];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"No", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)editQuestionTouchup:(UIButton *)sender {//-----Status
     NSLog(@"--- Question Edit %ld---", (long)sender.tag);
    selectedQuestionIndex = sender.tag;
    
    NSLog(@"--- Quiz Edit %ld---", (long)sender.tag);
    
    UIAlertController *editAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Edit", nil) message: @"" preferredStyle:UIAlertControllerStyleAlert];
    [editAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        NSMutableDictionary *selectedQuiz = subQuestionArray[selectedQuestionIndex];
        textField.placeholder = NSLocalizedString(@"Write question here", nil);
        textField.text = [selectedQuiz objectForKey:QUESTIONNAME];
    }];
    [editAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        NSMutableDictionary *selectedQuiz = subQuestionArray[selectedQuestionIndex];
        textField.placeholder = NSLocalizedString(@"Write feedback (Optional)", nil);
        textField.text = [selectedQuiz objectForKey:FEEDBACK];
    }];
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:NSLocalizedString(@"Yes", nil)
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              UITextField *questionName = editAlert.textFields[0];
                              UITextField *feedback = editAlert.textFields[1];
                              NSMutableDictionary *selectedQuestion = subQuestionArray[selectedQuestionIndex];
                              if ([questionName checkText:questionName] == NO) {
                                  [self showWarningAlert:NSLocalizedString(@"You can not leave question name empty", nil)];
                                  return ;
                              }else{
                                  [selectedQuestion setValue:questionName.text forKey:QUESTIONNAME];
                                  [selectedQuestion setValue:feedback.text forKey:FEEDBACK];
                              }
                              
                              if (isGuest == NO) {
                                  NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjects:@[[selectedQuestion objectForKey:QUESTIONNAME], [selectedQuestion objectForKey:QUESTIONID], [selectedQuestion objectForKey:FEEDBACK]] forKeys:@[QUESTIONNAME, @"question_id", FEEDBACK]];
                                  
                                  [self httpUpdateQuestion:param];
                              }
                              
                              [editAlert dismissViewControllerAnimated:YES completion:nil];
                              [self.myTable reloadData];
                          }];
    [editAlert addAction:yes];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"No", nil)
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [editAlert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [editAlert addAction:no];
    [self presentViewController:editAlert animated:YES completion:nil];
}

- (IBAction)statusQuestionTouchUp:(id)sender {//---------status
    UIButton *button = (UIButton *)sender;
    selectedQuestionIndex = button.tag;
    NSMutableDictionary *selectedQuestion = subQuestionArray[button.tag];
    if (![selectedQuestion objectForKey:QUESTIONID]) {
        [self showWarningAlert:NSLocalizedString(@"Netwok problems\nPlease try again!", nil)];
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[selectedQuestion objectForKey:QUESTIONID] forKey:@"question_id"];
    [self httpGetQuestionStatus:param];
}


#pragma mark - HttpNetworking

- (void)httpUpdateQuiz {
    NSMutableDictionary *selectedQuiz = quizArray[selectedIndex];
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    
    [requestDic setValue:[selectedQuiz objectForKey:QUIZID] forKey:QUIZID];
    [requestDic setValue:[selectedQuiz objectForKey:QUIZTIME] forKey:QUIZTIME];
    [requestDic setValue:[selectedQuiz objectForKey:QUIZNAME] forKey:QUIZNAME];
    NSString *str = [requestDic rj_jsonStringWithPrettyPrint:YES];
    NSData *nsData = [str dataUsingEncoding: NSUTF8StringEncoding];
    NSString *based64Encode = [nsData base64EncodedStringWithOptions:0];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:based64Encode forKey:@"json"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, UPDATEQUIZ];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
//        subQuestionArray = responseObject;
        
        [ProgressHUD dismiss];
        
        [self httpGetQuiz];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"Error: %@", error]];
        [ProgressHUD dismiss];
        
        [self httpGetQuiz];//in current for testing.............
    }];

}


- (void)httpAddQuiz: (NSMutableDictionary *)dic {
    [ProgressHUD show:@"Processing..." Interaction:NO];
    
    NSString *registerData = [dic rj_jsonStringWithPrettyPrint:YES];
    NSLog(@"JSON: %@", registerData);
    
    NSData *nsData = [registerData dataUsingEncoding: NSUTF8StringEncoding];
    NSString *based64Encode = [nsData base64EncodedStringWithOptions:0];
    NSLog(@"64Encoded: %@", based64Encode);
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:based64Encode forKey:@"json"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, ADDQUIZ];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        
        [ProgressHUD dismiss];
        
        [self httpGetQuiz];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"The network status has some problems. Please try again!"]];
        [ProgressHUD dismiss];
        
        [self httpGetQuiz];
    }];
    
}

- (void)httpGetQuestions: (NSMutableDictionary *)parameters{
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, GETQUESTIONS];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        subQuestionArray = [[NSMutableArray alloc] init];
        
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        NSMutableArray *resArray = responseObject;
        for (int i = 0; i < resArray.count; i++) {
            NSMutableDictionary *dic = [resArray[i] mutableCopy];
            NSMutableArray *ansArray = [dic objectForKey:ANSWERS];
            NSMutableArray *newArray = [[NSMutableArray alloc] init];
            for (int j = 0; j < ansArray.count; j++) {
                NSMutableDictionary *subDic = [ansArray[j] mutableCopy];
                [newArray addObject:subDic];
            }
            [dic setObject:newArray forKey:ANSWERS];
            [subQuestionArray addObject:dic];
        }
        isQuiz = NO;
        [self.myTable reloadData];
        [ProgressHUD dismiss];
        
        [self.shareButton setHidden:false];//showing share button(sharing specific Quiz ID)
        self.bottomTableViewConstraint.constant = 60;
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        isQuiz = YES;
        [self showWarningAlert:[NSString stringWithFormat:NSLocalizedString(@"Netwok problems\nPlease try again!", nil)]];
        [ProgressHUD dismiss];
    }];
}

- (void) httpGetQuiz {
    [ProgressHUD show:NSLocalizedString(@"Loading", nil) Interaction:NO];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:MY_USERID forKey:@"account_id"];//forKey:[curUser objectForKey:USERID]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, GETQUIZES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        NSMutableArray *resArray = [responseObject mutableCopy];
        quizArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < resArray.count; i++) {
            NSMutableDictionary *dic = [resArray[i] mutableCopy];
            [quizArray addObject:dic];
        }
        
        [self.myTable reloadData];
        [ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"The network status has some problems. Please try again!"]];
        [ProgressHUD dismiss];
    }];
}

- (void)httpDeleteQuiz: (NSMutableDictionary *)parameters {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, DELETEQUIZ];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        [ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"Error: %@", error]];
        [ProgressHUD dismiss];
    }];
}

- (void)httpDeleteQuestion: (NSMutableDictionary *)parameters {
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, DELETEQUESTION];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        [ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"The network status has some problems. Please try again!"]];
        [ProgressHUD dismiss];
    }];
}

- (void)httpAddQuestion: (NSMutableDictionary *)dic {
//    [ProgressHUD show:@"Processing..."];
    
    NSString *registerData = [dic rj_jsonStringWithPrettyPrint:YES];
    NSLog(@"JSON: %@", registerData);
    
    NSData *nsData = [registerData dataUsingEncoding: NSUTF8StringEncoding];
    NSString *based64Encode = [nsData base64EncodedStringWithOptions:0];
    NSLog(@"64Encoded: %@", based64Encode);
    
    
    NSMutableDictionary *parameters;
    if (attachedImage != nil && ![attachedImage isEqualToString:@""]) {
        parameters = [NSMutableDictionary dictionaryWithObjects:@[based64Encode, attachedImage] forKeys:@[@"json", @"photo"]];
    }else{
        parameters = [NSMutableDictionary dictionaryWithObject:based64Encode forKey:@"json"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, ADDQUESTION];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        
        [ProgressHUD dismiss];
        
        //getting questions again from server
        NSMutableDictionary *selectedQuiz = quizArray[selectedIndex];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:[selectedQuiz objectForKey:QUIZID] forKey:@"quiz_id"];
        [self httpGetQuestions:parameters];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"The network status has some problems. Please try again!"]];
        [ProgressHUD dismiss];
        
        //getting questions again from server
        NSMutableDictionary *selectedQuiz = quizArray[selectedIndex];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:[selectedQuiz objectForKey:QUIZID] forKey:@"quiz_id"];
        [self httpGetQuestions:parameters];
    }];
}

- (void)httpGetAnswers: (NSMutableDictionary *)parameters {
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, GETANSWERS];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        NSMutableArray *resArray = [responseObject mutableCopy];
//        NSMutableDictionary *curQuestion = subQuestionArray[selectedQuestionIndex];
//        NSMutableArray *curAnswers = [curQuestion objectForKey:ANSWERS];
        for (int i = 0; i < resArray.count; i++) {
            NSMutableDictionary *dic = [resArray[i] mutableCopy];
            [quizArray addObject:dic];
        }
        
        [self.myTable reloadData];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self showWarningAlert:NSLocalizedString(@"Netwok problems\nPlease try again!", nil)];
        [ProgressHUD dismiss];
    }];
}

- (void)httpUpdateAnswer: (NSMutableDictionary *)requestDic{
//    [ProgressHUD show:@"Updating..."];
    
    NSString *str = [requestDic rj_jsonStringWithPrettyPrint:YES];
    NSData *nsData = [str dataUsingEncoding: NSUTF8StringEncoding];
    NSString *based64Encode = [nsData base64EncodedStringWithOptions:0];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:based64Encode forKey:@"json"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, UPDATEANSWER];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
//    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        //        subQuestionArray = responseObject;
        
        [ProgressHUD dismiss];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"The network status has some problems. Please try again!"]];
        [ProgressHUD dismiss];
    }];
}

- (void)httpUpdateQuestion: (NSMutableDictionary *)dic {
    [ProgressHUD show:NSLocalizedString(@"Updating", nil) Interaction:NO];
    
    NSString *str = [dic rj_jsonStringWithPrettyPrint:YES];
    NSData *nsData = [str dataUsingEncoding: NSUTF8StringEncoding];
    NSString *based64Encode = [nsData base64EncodedStringWithOptions:0];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:based64Encode forKey:@"json"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, UPDATEQUESTION];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
//    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        //        subQuestionArray = responseObject;
        
        [ProgressHUD dismiss];
        
//        [self httpGetQuiz];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
//        [self showWarningAlert:[NSString stringWithFormat:@"The network status has some problems. Please try again!"]];
        [ProgressHUD dismiss];
        
//        [self httpGetQuiz];//in current for testing.............
    }];
}

- (void)httpGetQuestionStatus: (NSMutableDictionary *)param {
    [ProgressHUD show:NSLocalizedString(@"Loading", nil) Interaction:NO];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", ROOTURL, QUESTIONSTATS];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    //
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager POST:url parameters:param progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
        NSMutableDictionary *dic = [responseObject mutableCopy];
        NSMutableArray *array = [dic objectForKey:@"question"];
        NSMutableArray *newArray = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *ques in array) {
            NSMutableDictionary *newQ = [ques mutableCopy];
            [newArray addObject:newQ];
        }
        questionStats = [NSMutableDictionary dictionaryWithObjects:@[newArray, [dic objectForKey:@"quiz"]] forKeys:@[@"question", @"quiz"]];
        
        NSLog(@"Question Status: %@", questionStats);
        
        [self showQuestonStats];
        [ProgressHUD dismiss];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self showWarningAlert:NSLocalizedString(@"Netwok problems\nPlease try again!", nil)];
        [ProgressHUD dismiss];
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
