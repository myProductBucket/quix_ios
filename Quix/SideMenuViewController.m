//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Gao on 11/12/15.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import "SideMenuHeaderCell.h"
#import "SideMenuMidCell.h"
#import "TDashboardViewController.h"
#import "TResultViewController.h"
#import "SDashboardViewController.h"
#import "SStatisticViewController.h"
#import "SUpgradeViewController.h"
//#import "ShareViewController.h"

#import "CHTumblrMenuView.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>



@interface SideMenuViewController()<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, FBSDKSharingDelegate>{
    
    UIDocumentInteractionController *documentController; // used in sharing
    
    NSArray *iconNames;
    NSArray *itemNames;
    BOOL isTeacher;
}
@end

@implementation SideMenuViewController

- (void) viewWillAppear:(BOOL)animated {
    if (isTeacher) {
        iconNames = @[@"ic_dashboard.png", @"ic_statistic.png", @"ic_share.png", @"ic_exit.png"];
        itemNames = @[NSLocalizedString(@"Dashboard", nil), NSLocalizedString(@"Results", nil), NSLocalizedString(@"Share", nil), NSLocalizedString(@"Exit", nil)];
    }
    else {
        iconNames = @[@"ic_dashboard.png", @"ic_statistic.png", @"ic_upgrade.png", @"ic_share.png", @"ic_exit.png"];
        itemNames = @[NSLocalizedString(@"Dashboard", nil), NSLocalizedString(@"Statistic", nil), NSLocalizedString(@"Upgrade", nil), NSLocalizedString(@"Share", nil), NSLocalizedString(@"Exit", nil)];
    }
}


- (void)setUserPriority: (BOOL)userStyle {// If userStyle is true, Teacher
    isTeacher = userStyle;
}


#pragma mark -
#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@""];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isTeacher) {
        return 4;
    }else{
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SideMenuHeaderCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuHeaderCell"];
    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SideMenuMidCell *midCell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuMidCell"];
    if (midCell == nil) {
        midCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    midCell.iconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", iconNames[indexPath.row]]];
    midCell.iconName.text = [NSString stringWithFormat:@"%@", itemNames[indexPath.row]];
    
    return midCell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isTeacher) {
        if (indexPath.row == 0) {//Dashboard
            TDashboardViewController *tDashboardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"naviDashboard"];
            [self.menuContainerViewController setCenterViewController:tDashboardVC];
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        }
        else if (indexPath.row == 1) {//Results
            TResultViewController *tResultVC = [self.storyboard instantiateViewControllerWithIdentifier:@"naviResult"];
            [self.menuContainerViewController setCenterViewController:tResultVC];
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        }
        else if (indexPath.row == 2) {//Share
            [self showShareView];
        }
        else if (indexPath.row == 3) {//Exit
            [self exitMyApp];
        }
    }else{//Student
        if (indexPath.row == 0) {//Dashboard
            SDashboardViewController *sDashboardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"naviSDashboard"];
            [self.menuContainerViewController setCenterViewController:sDashboardVC];
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        }
        else if (indexPath.row == 1) {//Statistic
            SStatisticViewController *sStatisticVC = [self.storyboard instantiateViewControllerWithIdentifier:@"naviStatistic"];
            [self.menuContainerViewController setCenterViewController:sStatisticVC];
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        }
        else if (indexPath.row == 2) {//Upgrade
//            [self.menuContainerViewController addUpgradeView: [self upgradeView]];
            SUpgradeViewController *sUpgradeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"naviUpgrade"];
            [self.menuContainerViewController setCenterViewController:sUpgradeVC];
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        }
        else if (indexPath.row == 3) {//Share
            [self showShareView];
        }
        else if (indexPath.row == 4) {//Exit
            
            [self exitMyApp];
            
        }
        
    }
    
}


- (void)exitMyApp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Exit App", nil)
                                                                   message:NSLocalizedString(@"Are you sure you want to exit?", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert]; // 1
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              NSLog(@"You pressed button Yes");
                                                              exit(0);
                                                          }]; // 2
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed button No");
                                                           }]; // 3
    
    [alert addAction:firstAction]; // 4
    [alert addAction:secondAction]; // 5
    
    [self presentViewController:alert animated:YES completion:nil]; // 6
//    exit(0);
}

//in current this method isnot used.
- (UIView *)upgradeView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat wid = screenWidth / 2;
    CGFloat hei = screenHeight * 3 / 5;
    UIView *upgradeV = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - wid) / 2, (screenHeight - hei) / 2, wid, hei)];
    //adding header Label
    UILabel *headerL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wid, hei / 6)];
    headerL.text = NSLocalizedString(@"Free Usage Limit Reached", nil);
    [headerL setTextColor:[UIColor colorWithRed:(255/255.f) green:255/255.f blue:255/255.f alpha:1]];
    [headerL setBackgroundColor:[UIColor colorWithRed:(54/255.f) green:173/255.f blue:2/255.f alpha:1]];
    headerL.textAlignment = NSTextAlignmentCenter;
    [headerL setFont:[UIFont fontWithName:@"Helvetica" size:hei / 12]];
    [upgradeV addSubview:headerL];
    
    //adding the body view
    UIView *bodyV = [[UIView alloc] initWithFrame:CGRectMake(0, hei / 6, wid, hei * 5 / 6)];
    [bodyV setBackgroundColor:[UIColor colorWithRed:75 green:235 blue:5 alpha:1]];
    [upgradeV addSubview:bodyV];
    
    return upgradeV;
}


////////////--------------
- (void)showShareView{
    //get edited image
    
    //    waterMarkLbl.hidden = NO; // show water mark label
    
    //    UIGraphicsBeginImageContextWithOptions(self.shareView.frame.size, YES, [UIScreen mainScreen].scale);
    //    [self.shareView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    waterMarkLbl.hidden = YES; // hidden water mark label
    
    ////////////////////////////
    // open share option
    CHTumblrMenuView *menuShare = [[CHTumblrMenuView alloc] init];
    
    ///FB SHARING
    [menuShare addMenuItemWithTitle:@"Facebook" andIcon:[UIImage imageNamed:@"share_fb.png"] andSelectedBlock:^{
        
        //new FB share
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = viewImage;
        photo.userGenerated = YES;
//        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//        content.photos = @[photo];
        content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];

        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:nil];
//        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
//        dialog.fromViewController = self;
//        dialog.content = content;
//        dialog.mode = FBSDKShareDialogModeShareSheet;
//        [dialog show];
        
        ///////////////////////////////
    }];
    
    ///WhatsApp SHARING
    [menuShare addMenuItemWithTitle:@"WhatsApp" andIcon:[UIImage imageNamed:@"share_what.png"] andSelectedBlock:^{
        [self shareimageOnWhatsapp:viewImage];
    }];
    
    // mail send
    [menuShare addMenuItemWithTitle:@"Mail" andIcon:[UIImage imageNamed:@"share_mail.png"] andSelectedBlock:^{
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        if ([MFMailComposeViewController canSendMail]) {
            //Setting up the Subject, recipients, and message body.
            [mail setToRecipients:[NSArray arrayWithObjects:@"email@email.com",nil]];
            [mail setSubject:@"Sent from Meme Shot"];
            [mail setMessageBody:[NSString stringWithFormat:@"Download this app from here %@",APP_LINK] isHTML:NO];
            //Present the mail view controller
            
            NSData *dataImage = [NSData dataWithData:UIImagePNGRepresentation(viewImage)];
            
            [mail addAttachmentData:dataImage
                           mimeType:@"image/png"
                           fileName:@"Photica.png"];
            
            [self presentViewController:mail animated:YES completion:nil];
        }
    }];
    
    ///FB messenger SHARING
    [menuShare addMenuItemWithTitle:@"Messenger" andIcon:[UIImage imageNamed:@"share_messenger.png"] andSelectedBlock:^{
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]) {
            [FBSDKMessengerSharer shareImage:viewImage withOptions:nil];
        } else {
            NSString *appStoreLink = @"https://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
        }
        
    }];
    
    ///Instagram sharing
    [menuShare addMenuItemWithTitle:@"Instagram" andIcon:[UIImage imageNamed:@"share_instagram.png"] andSelectedBlock:^{
        [self shareImageOnInstagram:viewImage];
    }];
    
    ///twitter share
    [menuShare addMenuItemWithTitle:@"Twitter" andIcon:[UIImage imageNamed:@"share_twitter.png"] andSelectedBlock:^{
        SLComposeViewController *mySLComposerSheet2 = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet2 setInitialText:[NSString stringWithFormat:@"Sent from Meme Shot. Download this app from here %@", APP_LINK]];
        [mySLComposerSheet2 addImage:viewImage];
        [mySLComposerSheet2 addURL:[NSURL URLWithString:APP_LINK]];
        
        [self presentViewController:mySLComposerSheet2 animated:YES completion:^{
            //TODO
        }];
        
    }];
    
//    //save to Camera roll
//    [menuShare addMenuItemWithTitle:@"Save" andIcon:[UIImage imageNamed:@"share_phone.png"] andSelectedBlock:^{
//        UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
//    }];
    
    [menuShare show];
}

-(void)shareimageOnWhatsapp: (UIImage*)shareImage{
    
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]]){
        
        NSString    * savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
        
        [UIImageJPEGRepresentation(shareImage, 1.0) writeToFile:savePath atomically:YES];
        
        documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
        documentController.UTI = @"net.whatsapp.image";
        documentController.delegate = self;
        NSString *captinText = [NSString stringWithFormat:APP_LINK];
        documentController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:captinText,@"Caption", nil];
        
        [documentController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated: YES];
        
    }
    
}

-(void)shareImageOnInstagram:(UIImage*)shareImage
{
    NSString* imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    [UIImagePNGRepresentation(shareImage) writeToFile:imagePath atomically:YES];
    documentController = [[UIDocumentInteractionController alloc]init];
    documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
    documentController.delegate=self;
    NSString *captinText = [NSString stringWithFormat:APP_LINK];
    documentController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:captinText,@"InstagramCaption", nil];
    documentController.UTI = @"com.instagram.exclusivegram";
    [documentController presentOpenInMenuFromRect:CGRectZero
                                           inView:self.view
                                         animated:YES];
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"completed share:%@", results);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"sharing error:%@", error);
    NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
    @"There was a problem sharing, please try again later.";
    NSString *title = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops!";
    
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"share cancelled");
}

#pragma mark -MFMailComposeViewControllerDelegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
