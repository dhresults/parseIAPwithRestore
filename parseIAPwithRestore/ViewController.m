//
//  ViewController.m
//  parseIAPwithRestore
//
//  Created by Difint on 9/30/12.
//  Copyright (c) 2012 Difint. All rights reserved.
//

#import "ViewController.h"

#import <Parse/Parse.h>
#import "ParseID.h"

@interface ViewController ()

@end

@implementation ViewController

- (NSString *)pathForContent:(int)productNumber
{
  NSString *iapID, *downloadName;
  NSArray *products = [[NSArray alloc] initWithObjects:Purchase1,Purchase2,Purchase3,nil];
  NSArray *downloads = [[NSArray alloc] initWithObjects:Download1,Download2,Download3,nil];
  iapID = [products objectAtIndex:productNumber];
  downloadName = [downloads objectAtIndex:productNumber];
  
  NSString *dataDir = [NSSearchPathForDirectoriesInDomains(
                                                           NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *privateString = [dataDir stringByAppendingPathComponent:@"Private Documents"];
  NSString *parseString = [privateString stringByAppendingPathComponent:@"Parse"];
  NSString *packString = [parseString stringByAppendingPathComponent:iapID];
  NSString *path = [packString stringByAppendingPathComponent:downloadName];
  return path;
}

- (NSString *)lockStringForProduct:(int)productNumber
{
  NSString *lockString;
  NSArray *lockIcons = [[NSArray alloc] initWithObjects:@"🔒",@"🔓",nil];

  NSFileManager *filemgr = [NSFileManager defaultManager];
  NSString *path = [self pathForContent:productNumber-1];

  NSString *lock = [lockIcons objectAtIndex:0];
  if ([filemgr fileExistsAtPath:path] == YES) {
    lock = [lockIcons objectAtIndex:1];
  }
  lockString = [NSString stringWithFormat:@"%@ Purchase %d  ",lock,productNumber];

  return lockString;
}

// Get the string value of the downloaded file
- (NSString *)stringForProduct:(int)productNumber
{
  NSString *purchaseString = @"❌";
  if(productNumber == 2)
    purchaseString = @"🍴";
  NSString *path = [self pathForContent:productNumber];
  NSFileManager *filemgr = [NSFileManager defaultManager];
  if ([filemgr fileExistsAtPath:path] == YES)
    purchaseString = [NSString stringWithContentsOfFile:path
                                               encoding:NSUTF8StringEncoding error:nil];

  return purchaseString;
}

- (void)buyProduct:(int)productNumber
{
  NSArray *products = [[NSArray alloc] initWithObjects:Purchase1,Purchase2,Purchase3,nil];

  [PFPurchase buyProduct:[products objectAtIndex:productNumber] block:^(NSError *error) {
    if (!error) {
      HUD.labelText = @"Downloading";
    } else { // hide HUD on error
      [HUD hide:YES];
    }
  }];
}

- (IBAction)buttonPressed:(UIButton *)sender
{
  HUD = [[MBProgressHUD alloc] initWithView:self.view];
  [self.view addSubview:HUD];
  [HUD removeFromSuperViewOnHide];
  [HUD show:YES];

  // duff device? fall through and buy product or else restore
  switch([sender tag]) {
    case kPurchaseButton1:
    case kPurchaseButton2:
    case kPurchaseButton3:
      HUD.labelText = [NSString stringWithFormat:@"Purchasing %d",[sender tag]];
      NSLog(@"hudtext = %@",HUD.labelText);
      [self buyProduct:[sender tag]-1];
      break;
    default: // Restore
      HUD.labelText = @"Checking Purchases";
      [PFPurchase restore];
      break;
  }
}

// required by protocol
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
}

// this is to get the total number of products to restore
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
  purchaseCount = queue.transactions.count;
  if(queue.transactions.count > 0)
    HUD.labelText = @"Restoring Purchases";
}

- (void)drawUnlock
{
  
}

- (void)drawLabelFromPurchase:(int)number
{
  NSString *labelName = [NSString stringWithFormat:@"purchaseLabel%d",number];
  if(number < 3) {  // show lock state for non-consumables
    NSString *buttonName = [NSString stringWithFormat:@"purchaseButton%d",number];
    UIButton *button = [self valueForKey:buttonName];
    [button setTitle:[self lockStringForProduct:number] forState:UIControlStateNormal];
  }
  UILabel *label = [self valueForKey:labelName];
  [label setText:[self stringForProduct:number-1]];
}

- (void)downloadFinished:(id)sender
{
  NSNumber *number = [sender object];
  [self drawLabelFromPurchase:[number intValue]];
  purchaseCount--;
  if(purchaseCount <= 0) {
  	[HUD hide:YES];
    purchaseCount = 0;
  }
  
}

- (void)unlockAlreadyPurchasedContent
{
  [self drawLabelFromPurchase:1];
  [self drawLabelFromPurchase:2];
  [self drawLabelFromPurchase:3];
}

- (void)viewWillAppear:(BOOL)animated
{
  [self unlockAlreadyPurchasedContent];
  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(downloadFinished:)
                                               name:@"downloadFinished"
                                             object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
