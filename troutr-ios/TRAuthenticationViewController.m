//
//  TRAuthenticationViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 9/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRAuthenticationViewController.h"
#import "TRAuthenticationView.h"

@interface TRAuthenticationViewController ()

@end

@implementation TRAuthenticationViewController

- (id)init {
    self = [super init];
    if (!self) return nil;
    self.title = @"Log In";
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    label.text = @"hi welcome to auth";
    [self.view addSubview:label];
    
    // Do any additional setup after loading the view.
}

- (void)loadView {
    NSLog(@"authentication loadview");
    self.view = [[TRAuthenticationView alloc] init];
}

@end
