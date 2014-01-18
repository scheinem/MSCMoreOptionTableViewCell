//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"
#import "MSCMoreOptionTableViewCellConfigurator.h"
#import "MSCMoreOptionTableViewCellViewLocator.h"

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIScrollView *cellScrollView;
@property (nonatomic, strong) MSCMoreOptionTableViewCellConfigurator *configurator;
@property (nonatomic, strong) MSCMoreOptionTableViewCellViewLocator *viewLocator;

@end

@implementation MSCMoreOptionTableViewCell {

}

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initFromCoderOrWithStyle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initFromCoderOrWithStyle];
    }
    return self;
}

- (void)initFromCoderOrWithStyle
{
    _configurator = [[MSCMoreOptionTableViewCellConfigurator alloc] initWithCell:self];
    _viewLocator = [[MSCMoreOptionTableViewCellViewLocator alloc] initWithCell:self];

    [self setupMoreOption];
}

- (void)setupMoreOption {
    self.cellScrollView = [[self viewLocator] findScrollView];

    [self observeCellScrollViewSublayers];
}

- (void)observeCellScrollViewSublayers
{
    [self.cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self cleanupObservingCellScrollViewSublayers];
}

- (void)cleanupObservingCellScrollViewSublayers
{
    [self.cellScrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sublayers"]) {
        [self cellScrollViewLayerSublayersDidChange];
    }
}

- (void)cellScrollViewLayerSublayersDidChange
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [[self configurator] configureActionMenuButtonsIfNeeded];
}

- (NSIndexPath *)indexPath
{
    return [[[self viewLocator] tableView] indexPathForCell:self];
}

@end