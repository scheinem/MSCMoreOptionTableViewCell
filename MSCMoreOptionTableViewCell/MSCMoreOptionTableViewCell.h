//
//  MSCMoreOptionTableViewCell.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCellDelegate.h"

@interface MSCMoreOptionTableViewCell : UITableViewCell

/*
 * Set the content offset of the inner scroll view to zero,
 * hide the confirmation view.
 */
- (void)revertToOriginalState;

@property (nonatomic, weak) id<MSCMoreOptionTableViewCellDelegate> delegate;

- (void)hideDeleteConfirmation;

@end
