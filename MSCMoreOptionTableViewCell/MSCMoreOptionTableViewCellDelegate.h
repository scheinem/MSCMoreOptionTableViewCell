//
//  MSCMoreOptionTableViewCellDelegate.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

@protocol MSCMoreOptionTableViewCellDelegate<NSObject>

@required
- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

// "More button"

/*
 * If not implemented, returning nil or an empty string the "More" button will have
 * no title and it's width will be 60 points.
 */
- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the "More" button will have [UIColor whiteColor]
 * as titleColor;
 */
- (UIColor *)tableView:(UITableView *)tableView titleColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the "More" button will have [UIColor lightGrayColor]
 * as backgroundColor;
 */
- (UIColor *)tableView:(UITableView *)tableView backgroundColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

// "Delete button"

/*
 * If not implemented or returning nil the "Delete" button will have the default backgroundColor;
 */
- (UIColor *)tableView:(UITableView *)tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the "Delete" button will have the default titleColor;
 */
- (UIColor *)tableView:(UITableView *)tableView titleColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
