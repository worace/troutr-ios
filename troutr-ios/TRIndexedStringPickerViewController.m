//
//  TRIndexedStringPickerViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 6/22/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRIndexedStringPickerViewController.h"

@interface TRIndexedStringPickerViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *filteredResults;
@property BOOL isSearching;
@end

@implementation TRIndexedStringPickerViewController

#pragma mark - search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        self.isSearching = NO;
    } else {
        NSLog(@"total items: %d", [[[self store] sortedList] count]);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
        self.filteredResults = [NSMutableArray arrayWithArray:[[[self store] sortedList] filteredArrayUsingPredicate:predicate]];
        self.isSearching = YES;
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    self.isSearching = NO;
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavBar];
    [self addGestureRecognizers];
    [self configureSearchBar];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)addGestureRecognizers {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureSearchBar {
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 70, 320, 44)];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.filteredResults = [[NSMutableArray alloc] init];
    [self.tableView setTableHeaderView:self.searchBar];
}

- (void)configureNavBar {
    self.navigationController.navigationBarHidden = YES;
}

- (TRIndexedStringStore *)store {
    return [[TRIndexedStringStore alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return 1;
    } else {
        return [[self.store indexKeys] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return [self.filteredResults count];
    } else {
        NSString *key = [[self.store indexKeys] objectAtIndex:section];
        return [[self.store itemsForKey:key] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isSearching) {
        return @"";
    } else {
        return [[self.store indexKeys] objectAtIndex:section];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return @[];
    } else {
        return [self alphabet];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [self itemForIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = [self itemForIndexPath:indexPath];
    [self.delegate pickerDidSelectItem:item fromPicker:self];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self.store indexKeys] indexOfObject:title];
}

#pragma - mark convenience

- (NSArray *)alphabet {
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

- (NSString *)itemForIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        return [self.filteredResults objectAtIndex:indexPath.row];
    } else {
        return [[self itemsForIndexPath:indexPath] objectAtIndex:indexPath.row];
    }
}

- (NSArray *)itemsForIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[self.store indexKeys] objectAtIndex:indexPath.section];
    return [self.store itemsForKey:key];
}

@end
