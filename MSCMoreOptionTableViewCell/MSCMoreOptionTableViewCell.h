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

// should be framework private
@property (nonatomic, strong) UIButton *moreOptionButton;

- (NSIndexPath *)indexPath;
@end
