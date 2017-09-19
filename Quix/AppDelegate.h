//
//  AppDelegate.h
//  Quix
//
//  Created by Karl Faust on 12/17/15.
//  Copyright © 2015 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property BOOL isGuest;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) setRootMenu: (BOOL)isTeacher isGuest: (BOOL)isGuest;

@end

