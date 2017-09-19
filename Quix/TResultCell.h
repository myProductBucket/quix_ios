//
//  TResultCell.h
//  Quix
//
//  Created by Karl Faust on 12/25/15.
//  Copyright © 2015 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *quizLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *resultButton;

@end
