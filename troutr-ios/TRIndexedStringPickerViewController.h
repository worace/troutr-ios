//
//  TRIndexedStringPickerViewController.h
//  troutr-ios
//
//  Created by Horace Williams on 6/22/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRIndexedStringStore.h"
#import "TRIndexedStringPickerDelegate.h"

@interface TRIndexedStringPickerViewController : UITableViewController
@property (nonatomic, weak) NSObject <TRIndexedStringPickerDelegate> *delegate;
- (NSString *)itemForIndexPath:(NSIndexPath *)indexPath;
@end
