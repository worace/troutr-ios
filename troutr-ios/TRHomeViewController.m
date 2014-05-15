//
//  TRHomeViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRHomeViewController.h"
#import "TRCatchImagePickerViewController.h"
#import "TRCatch.h"

@interface TRHomeViewController ()

@end

@implementation TRHomeViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (IBAction)logCatch:(id)sender {
    TRCatchImagePickerViewController *imageStep = [[TRCatchImagePickerViewController alloc] init];
    imageStep.catchInProgress = [[TRCatch alloc] init];
    [self.navigationController pushViewController:imageStep animated:YES];
}


@end
