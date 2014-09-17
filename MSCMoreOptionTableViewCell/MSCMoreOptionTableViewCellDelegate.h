//
//  MSCMoreOptionTableViewCellDelegate.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

@protocol MSCMoreOptionTableViewCellDelegate<NSObject>

@optional

// 'more' button

/*
 * Tells the delegate that the 'more' button for specified row was pressed.
 */
- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * When property 'configurationBlock' is nil:
 * ==========================================
 * If not implemented or returning nil the 'More' button will neither be created
 * nor displayed, the cell will act like a common UITableViewCell and the only 
 * two delegate methods which will have an impact will be:
 * 
 * - tableView:backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:
 * - tableView:titleColorForDeleteConfirmationButtonForRowAtIndexPath:
 *
 * This behaviour is needed to ensure compatiblity of code from developers
 * that was written for usage of MSCMoreOptionTableViewCell 1.x
 *
 * When property 'configurationBlock' is set (NOT nil):
 * ====================================================
 * The 'more' button will be created then customized using the delegate methods,
 * passed to the configuration block and added to the view hierarchy afterwards.
 *
 * NOTE:
 * =====
 * The 'more' button also supports multiline titles.
 *
 */
- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the 'more' button will have [UIColor whiteColor]
 * as titleColor.
 *
 */
- (UIColor *)tableView:(UITableView *)tableView titleColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the 'more' button will have [UIColor lightGrayColor]
 * as backgroundColor.
 *
 */
- (UIColor *)tableView:(UITableView *)tableView backgroundColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning a lower value than the 'more' button's 'fitting' value,
 * the 'More' button width will not be changed.
 *
 */
- (CGFloat)tableView:(UITableView *)tableView minimumWidthForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented the 'more' button will have (0, 15, 0, 15) as 'edgeInsets'.
 *
 */
- (UIEdgeInsets)tableView:(UITableView *)tableView edgeInsetsForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

// 'delete' button

/*
 * If not implemented or returning nil the 'delete' button will have it's default backgroundColor.
 *
 */
- (UIColor *)tableView:(UITableView *)tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented or returning nil the 'delete' button will have it's default titleColor.
 *
 */
- (UIColor *)tableView:(UITableView *)tableView titleColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

/*
 * If not implemented the 'delete' button will have (0, 15, 0, 15) as 'edgeInsets'.
 *
 */
- (UIEdgeInsets)tableView:(UITableView *)tableView edgeInsetsForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
