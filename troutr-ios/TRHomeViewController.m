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
#import "TRCatchLog.h"
#import "TRCatchDetailViewController.h"

@interface TRHomeViewController ()

@end

@implementation TRHomeViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    UIBarButtonItem *addCatchButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(logCatch:)];
    addCatchButton.image = [UIImage imageNamed:@"troutIcon"];
    self.navigationItem.rightBarButtonItem = addCatchButton;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)logCatch:(id)sender {
    TRCatchImagePickerViewController *imageStep = [[TRCatchImagePickerViewController alloc] init];
    imageStep.catchInProgress = [[TRCatch alloc] init];
    [self.navigationController pushViewController:imageStep animated:YES];
}

# pragma - mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[TRCatchLog sharedStore] allCatches] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    TRCatch *catch = [[[TRCatchLog sharedStore] allCatches] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ caught on %@", catch.species, catch.fly];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TRCatch *catch = [[[TRCatchLog sharedStore] allCatches] objectAtIndex:indexPath.row];
    TRCatchDetailViewController *detailVC = [[TRCatchDetailViewController alloc] init];
    detailVC.catch = catch;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
