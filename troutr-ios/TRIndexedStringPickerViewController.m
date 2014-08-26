//
//  TRIndexedStringPickerViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 6/22/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRIndexedStringPickerViewController.h"

@implementation TRIndexedStringPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (TRIndexedStringStore *)store {
    return [[TRIndexedStringStore alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.store indexKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [[self.store indexKeys] objectAtIndex:section];
    return [[self.store itemsForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.store indexKeys] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self alphabet];
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
    return [[self itemsForIndexPath:indexPath] objectAtIndex:indexPath.row];
}

- (NSArray *)itemsForIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[self.store indexKeys] objectAtIndex:indexPath.section];
    return [self.store itemsForKey:key];
}

@end
