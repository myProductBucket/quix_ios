//
//  ShareViewController.m
//  Quix
//
//  Created by Xiao Ming Liu on 28/12/2015.
//  Copyright © 2015 self. All rights reserved.
//

#import "ShareViewController.h"
#import "CHTumblrMenuView.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface ShareViewController ()<MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, FBSDKSharingDelegate>{
    UIDocumentInteractionController *documentController; // used in sharing
}

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showShareView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (BOOL)shouldAutorotate {
//    return NO;
//}

////////--------------------------------
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
//        photo.image = viewImage;
//        photo.userGenerated = YES;
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
//        content.
//        [FBSDKShareDialog showFromViewController:self
//                                     withContent:content
//                                        delegate:nil];
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.fromViewController = self;
        dialog.shareContent = content;
        dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
        if (![dialog canShow]) {
            // fallback presentation when there is no FB app
            dialog.mode = FBSDKShareDialogModeFeedBrowser;
        }
        [dialog show];
        
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
        [mySLComposerSheet2 setInitialText:[NSString stringWithFormat:@"Sent from Quix. Download this app from here %@", APP_LINK]];
        [mySLComposerSheet2 addImage:viewImage];
        [mySLComposerSheet2 addURL:[NSURL URLWithString:APP_LINK]];
        
        [self presentViewController:mySLComposerSheet2 animated:YES completion:^{
            //TODO
        }];
        
    }];
    
    //save to Camera roll
    [menuShare addMenuItemWithTitle:@"Save" andIcon:[UIImage imageNamed:@"share_phone.png"] andSelectedBlock:^{
        UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    }];
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
