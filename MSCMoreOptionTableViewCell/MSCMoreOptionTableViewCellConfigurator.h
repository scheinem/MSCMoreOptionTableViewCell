//
// Created by Robert Gilliam on 1/17/14.
// Copyright (c) 2014 Manfred Scheiner. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSCMoreOptionTableViewCell;


@interface MSCMoreOptionTableViewCellConfigurator : NSObject

- (void)configureActionMenuButtonsIfNeeded;

@property (nonatomic, weak) MSCMoreOptionTableViewCell *cell;

- (instancetype)initWithCell:(MSCMoreOptionTableViewCell *)cell;


@end