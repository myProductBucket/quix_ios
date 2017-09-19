//
//  IAPHelper.h
//  IMOB
//
//  Created by Jeff Janes on 5/21/13.
//  Copyright (c) 2013 I-mobilize.com. All rights reserved.
//

#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
- (NSMutableSet *)getPurchasedProductIdentifiers;
//- (NSMutableSet *)getDownloadingProductIdentifiers;
@end