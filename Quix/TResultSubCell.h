//
//  TResultSubCell.h
//  Quix
//
//  Created by Xiao Ming Liu on 15/1/2016.
//  Copyright © 2016 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TResultSubCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *contentV;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *resultButton;

@end
