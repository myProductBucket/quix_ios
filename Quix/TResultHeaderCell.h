//
//  TResultHeaderCell.h
//  Quix
//
//  Created by Karl Faust on 12/25/15.
//  Copyright © 2015 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TResultHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *reportIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numvberOf;

@end
