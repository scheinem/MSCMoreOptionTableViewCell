//
//  MSCMoreOptionTableViewCellDelegate.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

@protocol MSCMoreOptionTableViewCellDelegate<NSObject>

@optional

// "More button"

/*
 * Tells the delegate that the "More" button for specified row was pressed.
 */
- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the "More" button will not be created and the
 * cell will act like a common UITableViewCell.
 *
 * The "More" button also supports multiline titles.
 */
- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the "More" button will have [UIColor whiteColor]
 * as titleColor.
 */
- (UIColor *)tableView:(UITableView *)tableView titleColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the "More" button will have [UIColor lightGrayColor]
 * as backgroundColor.
 */
- (UIColor *)tableView:(UITableView *)tableView backgroundColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

// "Delete button"

/*
 * If not implemented or returning nil the "Delete" button will have the default backgroundColor.
 */
- (UIColor *)tableView:(UITableView *)tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the "Delete" button will have the default titleColor.
 */
- (UIColor *)tableView:(UITableView *)tableView titleColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView widthForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
