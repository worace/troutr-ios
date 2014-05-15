//
//  TRCatchDetailViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRCatchDetailViewController.h"
#import "TRCatchLog.h"
#import "TRCatch.h"

@interface TRCatchDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *flyLabel;
@property (weak, nonatomic) IBOutlet UILabel *catchCountLabel
;
@end

@implementation TRCatchDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displaySpeciesInfo];
    [self displayFlyInfo];
    [self displayCatchCount];
}

- (void)displaySpeciesInfo {
    NSLog(@"catch is %@", self.catch);
    self.speciesLabel.text = [@"Species: " stringByAppendingString:self.catch.species];
}
- (void)displayFlyInfo {
    self.flyLabel.text = [@"Caught on: " stringByAppendingString:self.catch.fly];
}

- (void)displayCatchCount {
    NSInteger count = [[[TRCatchLog sharedStore] allCatches] count];
    self.catchCountLabel.text = [NSString stringWithFormat:@"you've logged %d catches", count];
}

@end
