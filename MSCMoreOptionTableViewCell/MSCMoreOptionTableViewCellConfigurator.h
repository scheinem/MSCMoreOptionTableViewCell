//
// Created by Robert Gilliam on 1/17/14.
// Copyright (c) 2014 Manfred Scheiner. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSCMoreOptionTableViewCell;


@interface MSCMoreOptionTableViewCellConfigurator : NSObject

- (instancetype)initWithCell:(MSCMoreOptionTableViewCell *)cell;


- (void)initOrTeardownActionMenuButtonsIfNeeded;


@property (nonatomic, readonly, weak) MSCMoreOptionTableViewCell *cell;

@end