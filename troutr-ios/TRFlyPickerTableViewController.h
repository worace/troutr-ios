//
//  TRFlyPickerTableViewController.h
//  Pods
//
//  Created by Horace Williams on 5/14/14.
//
//

#import <UIKit/UIKit.h>
#import "TRFlyPickerDelegate.h"

@interface TRFlyPickerTableViewController : UITableViewController
@property (nonatomic, strong) NSObject <TRFlyPickerDelegate> *delegate;
@end
