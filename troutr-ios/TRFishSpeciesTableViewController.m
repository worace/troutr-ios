//
//  TRFishSpeciesTableViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 8/26/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//


#import "TRFishSpeciesTableViewController.h"
#import "TRFishSpeciesStore.h"

@interface TRFishSpeciesTableViewController ()

@end

@implementation TRFishSpeciesTableViewController
- (TRFishSpeciesStore *)store {
    return [TRFishSpeciesStore sharedStore];
}
@end