//
//  TRAppDelegate.m
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRAppDelegate.h"
#import "TRHomeViewController.h"
#import "TRAuthenticationViewController.h"
#import "TRCatchLog.h"
#import <Parse/Parse.h>
#import "Masonry.h"


@implementation TRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self configureParse];
    
    TRHomeViewController *homeVC = [[TRHomeViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    if (![PFUser currentUser]) {
        [navVC pushViewController:[[TRAuthenticationViewController alloc] init] animated:NO];
    }
    self.window.rootViewController = navVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)configureParse {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"configuration" ofType:@"plist"];
    NSDictionary *configuration = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSString *parseClientID = configuration[@"ParseCredentials"][@"ClientID"];
    NSString *parseClientSecret = configuration[@"ParseCredentials"][@"ClientSecret"];
    [Parse setApplicationId:parseClientID clientKey:parseClientSecret];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[TRCatchLog sharedStore] saveChanges];
}

@end
