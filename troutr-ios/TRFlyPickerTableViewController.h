//
//  TRFlyPickerTableViewController.h
//  Pods
//
//  Created by Horace Williams on 5/14/14.
//
//

#import "TRIndexedStringPickerViewController.h"
#import "TRIndexedStringPickerDelegate.h"
#import "TRFlyPickerDelegate.h"

@interface TRFlyPickerTableViewController : TRIndexedStringPickerViewController
@property (nonatomic, weak) NSObject <TRFlyPickerDelegate> *delegate;
@end
