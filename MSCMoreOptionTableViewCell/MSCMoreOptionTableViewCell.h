//
//  MSCMoreOptionTableViewCell.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCellDelegate.h"

extern const CGFloat MSCMoreOptionTableViewCellButtonWidthSizeToFit;

/*
 * deleteConfirmationButton       - Button created by UIKit, already customized using
 *                                  using the 'MSCMoreOptionTableViewCellDelegate'
 *
 * moreOptionButton               - Button created by MSCMoreOptionTableViewCell, already
 *                                  customized using the 'MSCMoreOptionTableViewCellDelegate'
 *
 * *deleteConfirmationButtonWidth - Pointer to the width that 'deleteConfirmationButton' should
 *                                  get when beeing displayed. 
 *                                  Overrides an eventually set frame.size.width during the 
 *                                  'configurationBlock' execution. 
 *                                  When set to 'MSCMoreOptionTableViewCellButtonWidthSizeToFit'
 *                                  the width will be calculated: 'contentSize + edgeInsets'
 *
 * *moreOptionButtonWidth         - Pointer to the width that 'moreOptionButton' should
 *                                  get when beeing displayed.
 *                                  Overrides an eventually set frame.size.width during the
 *                                  'configurationBlock' execution.
 *                                  When set to 'MSCMoreOptionTableViewCellButtonWidthSizeToFit'
 *                                  the width will be calculated: 'contentSize + edgeInsets'
 *
 */
typedef void (^MSCMoreOptionTableViewCellConfigurationBlock)(UIButton *deleteConfirmationButton,
                                                             UIButton *moreOptionButton,
                                                             CGFloat *deleteConfirmationButtonWidth,
                                                             CGFloat *moreOptionButtonWidth);

@interface MSCMoreOptionTableViewCell : UITableViewCell 

@property (nonatomic, weak) id<MSCMoreOptionTableViewCellDelegate> delegate;
@property (nonatomic, copy) MSCMoreOptionTableViewCellConfigurationBlock configurationBlock;

- (void)hideDeleteConfirmation;

@end
