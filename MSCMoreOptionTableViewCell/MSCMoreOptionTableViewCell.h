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
@property (nonatomic) BOOL isMoreOptionHidden;

@end
