//
//  MSCMoreOptionTableViewCell.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCellDelegate.h"

@interface MSCMoreOptionTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MSCMoreOptionTableViewCellDelegate> delegate;
/*
 * moreOptionButtonMinimumWidth represents the width the moreOptionButtonMinimumWidth
 * at least will be set to if it gets created. Independet of the value of
 * 'moreOptionButtonMinimumWidth' the "More" button will only be created if
 * 'tableView:titleForMoreOptionButtonForRowAtIndexPath:' is implemented and 
 * returns != nil.
 *
 * Defaults to 0.
 */
@property (nonatomic, assign) CGFloat moreOptionButtonMinimumWidth;
/*
 * moreOptionButtonHorizontalPadding represents the space between the left and/or 
 * the right border and the containing text (= "More" title).
 *
 * Defaults to 15.
 */
@property (nonatomic, assign) CGFloat moreOptionButtonHorizontalPadding;

- (void)hideDeleteConfirmation;

@end
