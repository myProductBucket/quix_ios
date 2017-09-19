//
//  TDashboardQuestionCell.h
//  Quix
//
//  Created by Karl Faust on 12/18/15.
//  Copyright © 2015 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDashboardQuestionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@end
