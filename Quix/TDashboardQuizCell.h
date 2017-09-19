//
//  TDashboardQuizCell.h
//  Quix
//
//  Created by Karl Faust on 12/18/15.
//  Copyright © 2015 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDashboardQuizCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *numofQuestionsLbl;
@property (weak, nonatomic) IBOutlet UILabel *quizTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *quizNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
