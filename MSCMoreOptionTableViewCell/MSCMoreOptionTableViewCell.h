//
//  MSCMoreOptionTableViewCell.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCellDelegate.h"

@interface MSCMoreOptionTableViewCell : UITableViewCell

@property (nonatomic, strong) id<MSCMoreOptionTableViewCellDelegate> delegate;

/* Defaults to @"More" */
@property (nonatomic, strong) NSString *moreOptionButtonTitle;
/* Defaults to [UIColor lightGrayColor] */
@property (nonatomic, strong) UIColor *moreOptionButtonBackgroundColor;
/* Defaults to [UIColor whiteColor] */
@property (nonatomic, strong) UIColor *moreOptionButtonTitleColor;

@end
