//
//  TRFlyPickerTableViewController.m
//  Pods
//
//  Created by Horace Williams on 5/14/14.
//
//

#import "TRFlyPickerTableViewController.h"
#import "TRFlyStore.h"

@interface TRFlyPickerTableViewController ()
@end

@implementation TRFlyPickerTableViewController
- (TRFlyStore *)store {
    return [TRFlyStore sharedStore];
}
@end
