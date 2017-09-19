//
//  TResultQuestionCell.h
//  Quix
//
//  Created by Xiao Ming Liu on 15/1/2016.
//  Copyright © 2016 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TResultQuestionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctAnswerLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstAnswerLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageV;
@property (weak, nonatomic) IBOutlet UIView *contentV;

@end
