//
//  TDashboardHeaderCell.h
//  Quix
//
//  Created by Karl Faust on 12/18/15.
//  Copyright © 2015 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDashboardHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *reportIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//Teacher name or Quiz name
@property (weak, nonatomic) IBOutlet UILabel *numberOf;//number of Quiz or the time of Quiz
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *addLabel;

@end
