//
//  AppDelegate.m
//  Quix
//
//  Created by Karl Faust on 12/17/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "AppDelegate.h"
#import "SideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "TDashboardViewController.h"
#import "SDashboardViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate (){
    BOOL isTeacher;
    BOOL isGoogleSignIn;
    BOOL isGuest;
}

@end

@implementation AppDelegate

@synthesize isGuest = _isGuest;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //google sign in
    [GIDSignIn sharedInstance].clientID = @"995712266351-a887b1aj31fn8lmcungap1kolkcag3ss.apps.googleusercontent.com";
    
    [GIDSignIn sharedInstance].delegate = self;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([url.scheme isEqualToString:@"fb1674756029408454"]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }else{
        return [[GIDSignIn sharedInstance] handleURL:url
                                       sourceApplication:sourceApplication
                                              annotation:annotation];

    }
}
//----------------------------------------

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}
#pragma mark - GIDSignInDelegate Method

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    [ProgressHUD show:@"" Interaction:true];
    if (error == nil) {
        NSLog(@"%@", user);
        
        NSString *userId = user.userID;                  // For client-side use only!
        NSString *idToken = user.authentication.idToken; // Safe to send to the server
        NSString *name = user.profile.name;
        NSString *email = user.profile.email;
        NSURL *imageURL = [user.profile imageURLWithDimension:5];
        
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithObjects:@[userId, name, email, imageURL.absoluteString] forKeys:@[USERID, USERNAME, USEREMAIL, USERPHOTOURL]];//@{USERID: userId, USERNAME: name, USEREMAIL: email, USERPHOTOURL: imageURL.absoluteString};
        NSLog(@"NSDictionary --- %@", infoDic);
        
        NSUserDefaults *myInfo = [NSUserDefaults standardUserDefaults];
        
        if ([myInfo objectForKey:USERID] == nil) {
            [myInfo setObject:userId forKey:USERID];
            [myInfo setObject:idToken forKey:USERTOKEN];
            [myInfo setObject:name forKey:USERNAME];
            [myInfo setObject:email forKey:USEREMAIL];
            [myInfo setObject:imageURL.absoluteString forKey:USERPHOTOURL];
        }else{
            [myInfo setObject:userId forKey:USERID];
            [myInfo setObject:idToken forKey:USERTOKEN];
            [myInfo setObject:name forKey:USERNAME];
            [myInfo setObject:email forKey:USEREMAIL];
            [myInfo setObject:imageURL.absoluteString forKey:USERPHOTOURL];
        }
        //-----Register user(teacher) info to server
        NSLog(@"Dictionary: %@", infoDic);
        
        NSString *registerData = [infoDic rj_jsonStringWithPrettyPrint:YES];
        NSLog(@"JSON: %@", registerData);

        NSData *nsData = [registerData dataUsingEncoding: NSUTF8StringEncoding];
        NSString *based64Encode = [nsData base64EncodedStringWithOptions:0];
        NSLog(@"64Encoded: %@", based64Encode);
        
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:based64Encode forKey:@"json"];
        
        NSString *url = [NSString stringWithFormat:@"%@/register.php", ROOTURL];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
        [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@---getting Quizes Success----%@", responseObject, task);
            
            [ProgressHUD dismiss];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [ProgressHUD dismiss];
        }];

        ///////////////////////----------------------//////////////
        isGoogleSignIn = true;
        AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [del setRootMenu:true isGuest:false];
    }else{
        [ProgressHUD dismiss];
        NSLog(@"------found some errors-------");
    }
    // Perform any operations on signed in user here.

    // ...
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
    NSLog(@"%@", error);
    isGoogleSignIn = false;
}

#pragma mark - setRootView

- (void) setRootMenu: (BOOL)is_Teacher isGuest:(BOOL)isGuestForTeacher {
    isTeacher = is_Teacher;
    _isGuest = isGuestForTeacher;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SideMenuViewController *leftMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"sideMenuViewController"];
    
    [leftMenuViewController setUserPriority:isTeacher];//meaning of Teacher or Student
    
    UIViewController *centerVC;
    if (isTeacher) {
        centerVC = (TDashboardViewController *)[storyboard instantiateViewControllerWithIdentifier:@"naviDashboard"];
//        [(TDashboardViewController *)centerVC setPriority:isGuest];
    }else{
        centerVC = (SDashboardViewController *)[storyboard instantiateViewControllerWithIdentifier:@"naviSDashboard"];
    }

    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:centerVC
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ufuk-matti.Quix" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Quix" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Quix.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
