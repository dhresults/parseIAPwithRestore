//
//  ViewController.h
//  parseIAPwithRestore
//
//  Created by Difint on 9/30/12.
//  Copyright (c) 2012 Difint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreKit/SKPaymentQueue.h"
#import "MBProgressHUD.h"

@interface ViewController : UIViewController <SKPaymentTransactionObserver> {
  IBOutlet UIButton *purchaseButton1, *purchaseButton2, *purchaseButton3;
  IBOutlet UILabel *purchaseLabel1, *purchaseLabel2, *purchaseLabel3;
  IBOutlet UIButton *restoreButton;
  int purchaseCount; // number of transactions in queue
  
  MBProgressHUD *HUD;
}

#define kPurchaseButton1  1
#define kPurchaseButton2  2
#define kPurchaseButton3  3
#define   kRestoreButton  4

- (IBAction)buttonPressed:(UIButton *)sender;


@end
