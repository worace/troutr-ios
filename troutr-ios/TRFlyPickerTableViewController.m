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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[TRFlyStore sharedStore] flyIndexKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [[[TRFlyStore sharedStore] flyIndexKeys] objectAtIndex:section];
    return [[[TRFlyStore sharedStore] fliesForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[TRFlyStore sharedStore] flyIndexKeys] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self alphabet];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [self flyForIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fly = [self flyForIndexPath:indexPath];
    [self.delegate flyPickerDidSelectFly:fly fromPicker:self];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[[TRFlyStore sharedStore] flyIndexKeys] indexOfObject:title];
}

#pragma - mark convenience

- (NSArray *)alphabet {
    return @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

- (NSString *)flyForIndexPath:(NSIndexPath *)indexPath {
    return [[self fliesForIndexPath:indexPath] objectAtIndex:indexPath.row];
}

- (NSArray *)fliesForIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[[TRFlyStore sharedStore] flyIndexKeys] objectAtIndex:indexPath.section];
    return [[TRFlyStore sharedStore] fliesForKey:key];
}

@end
