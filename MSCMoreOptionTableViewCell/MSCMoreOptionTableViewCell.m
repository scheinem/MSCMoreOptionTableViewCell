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

/**
* Collaborates with a MSCMoreOptionTableViewCellConfigurator, which configures a cell to display the More option button.
*
* Notifies that cell configurator whenever the sublayers of our scroll view change, as that may indicate a need to configure
* or teardown the More option button.
*/

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MSCMoreOptionTableViewCellConfigurator *configurator;
@property (nonatomic, strong) MSCMoreOptionTableViewCellViewLocator *viewLocator;

@end

@implementation MSCMoreOptionTableViewCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _configurator = [[MSCMoreOptionTableViewCellConfigurator alloc] initWithCell:self];
    _viewLocator = [[MSCMoreOptionTableViewCellViewLocator alloc] initWithCell:self];

    [self setupMoreOption];
}

- (void)setupMoreOption {
    self.scrollView = [[self viewLocator] scrollView];

    [self observeScrollViewSublayers];
}

- (void)observeScrollViewSublayers
{
    [self.scrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self cleanupObservingScrollViewSublayers];
}

- (void)cleanupObservingScrollViewSublayers
{
    [self.scrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sublayers"]) {
        [self scrollViewLayerSublayersDidChange];
    }
}

- (void)scrollViewLayerSublayersDidChange
{
    [[self configurator] initOrTeardownActionMenuButtonsIfNeeded];
}

@end