//
//  UIImagePickerController+UIImagePickerController_OrientationFix.m
//  Quix
//
//  Created by Xiao Ming Liu on 5/1/2016.
//  Copyright © 2016 self. All rights reserved.
//

#import "UIImagePickerController+UIImagePickerController_OrientationFix.h"

@implementation UIImagePickerController (UIImagePickerController_OrientationFix)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end
