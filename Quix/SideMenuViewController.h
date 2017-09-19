//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Gao on 11/12/15.

#import <UIKit/UIKit.h>

@interface SideMenuViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (void)setUserPriority: (BOOL)userStyle;

@end