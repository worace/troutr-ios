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
#import "TRCatchTableViewCell.h"
#import "TRCatchDataEntryViewController.h"
#import "TRCamViewController.h"

@implementation UINavigationController (StatusBarStyle)
- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}
@end

@interface TRHomeViewController ()

@end

@implementation TRHomeViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerCatchCell];
    [self configureNavigationBar];
}

- (void)configureNavigationBar {
    UIBarButtonItem *addCatchButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(logCatch:)];
    addCatchButton.image = [UIImage imageNamed:@"troutIcon"];
    self.navigationItem.rightBarButtonItem = addCatchButton;
}

- (void)registerCatchCell {
    [self.tableView registerClass:[TRCatchTableViewCell class] forCellReuseIdentifier:@"TRCatchTableViewCell"];
    UINib *nib = [UINib nibWithNibName:@"TRCatchTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TRCatchTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)logCatch:(id)sender {
    TRCamViewController *cameraSession = [[TRCamViewController alloc] init];
    [self.navigationController pushViewController:cameraSession animated:YES];
}

# pragma - mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[TRCatchLog sharedStore] allCatches] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRCatchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TRCatchTableViewCell"];
    [cell.contentView.superview setClipsToBounds:NO];
    TRCatch *catch = [[[TRCatchLog sharedStore] allCatches] objectAtIndex:indexPath.row];
    cell.speciesLabel.text = catch.species;
    cell.flyLabel.text = catch.fly;
    cell.tumbnailView.image = catch.image;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TRCatch *catch = [[[TRCatchLog sharedStore] allCatches] objectAtIndex:indexPath.row];
    TRCatchDetailViewController *detailVC = [[TRCatchDetailViewController alloc] init];
    detailVC.catch = catch;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
