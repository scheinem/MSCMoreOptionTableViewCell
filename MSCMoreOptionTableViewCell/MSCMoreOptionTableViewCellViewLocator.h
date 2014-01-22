//
// Created by Robert Gilliam on 1/17/14.
// Copyright (c) 2014 Manfred Scheiner. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSCMoreOptionTableViewCell;


@interface MSCMoreOptionTableViewCellViewLocator : NSObject

- (instancetype)initWithCell:(MSCMoreOptionTableViewCell *)cell;

- (UIView *)deleteConfirmationView;
- (UIButton *)deleteConfirmationButton;
- (UILabel *)deleteButtonLabel;

- (UITableView *)tableView;
- (NSIndexPath *)indexPathInTableView;

@property (nonatomic, weak) MSCMoreOptionTableViewCell *cell;
@property (nonatomic, readonly) UIScrollView *scrollView;

@end