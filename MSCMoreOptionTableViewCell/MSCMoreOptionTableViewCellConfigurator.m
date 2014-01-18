//
// Created by Robert Gilliam on 1/17/14.
// Copyright (c) 2014 Manfred Scheiner. All rights reserved.
//

#import "MSCMoreOptionTableViewCellConfigurator.h"
#import "MSCMoreOptionTableViewCell.h"
#import "MSCMoreOptionTableViewCellViewLocator.h"

@interface MSCMoreOptionTableViewCellConfigurator()

@property (nonatomic, readonly) MSCMoreOptionTableViewCellViewLocator *viewLocator;

@end

@implementation MSCMoreOptionTableViewCellConfigurator {

}
- (instancetype)initWithCell:(MSCMoreOptionTableViewCell *)cell
{
    self = [super init];
    if (self) {
        _cell = cell;
        _viewLocator = [[MSCMoreOptionTableViewCellViewLocator alloc] initWithCell:cell];
    }

    return self;
}

- (void)initOrTeardownActionMenuButtonsIfNeeded
{
    if (!_cell.moreOptionButton) {
        [self initActionMenuButtonsIfAble];
    }

    if (![[self viewLocator] deleteConfirmationView]) {
        _cell.moreOptionButton = nil;
    }
}

- (void)initActionMenuButtonsIfAble
{
    if ([self canConfigureActionMenuButtons]) {
        [self configureActionMenuButtons];
    }
}

- (BOOL)canConfigureActionMenuButtons
{
    return [[self viewLocator] deleteConfirmationView] != nil;
}

- (void)configureActionMenuButtons
{
    [self configureDeleteButton];

    if ([self shouldDisplayMoreButton]) {
        [self initMoreButton];
    }
}

- (void)configureDeleteButton
{
    [self configureDeleteButtonBackgroundColorFromDelegate];
    [self configureDeleteButtonTitleColorFromDelegate];
}

- (void)configureDeleteButtonBackgroundColorFromDelegate
{
    UITableView *tableView = [[self viewLocator] tableView];

    if ([self.cell.delegate respondsToSelector:@selector(tableView:backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        UIColor *deleteButtonColor = [self.cell.delegate tableView:tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:[tableView indexPathForCell:self.cell]];
        if (deleteButtonColor) {
            [[self viewLocator] deleteConfirmationButton].backgroundColor = deleteButtonColor;
        }
    }
}

- (void)configureDeleteButtonTitleColorFromDelegate
{
    UITableView *tableView = [[self viewLocator] tableView];

    if ([self.cell.delegate respondsToSelector:@selector(tableView:titleColorForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        UIColor *deleteButtonTitleColor = [self.cell.delegate tableView:tableView titleColorForDeleteConfirmationButtonForRowAtIndexPath:[tableView indexPathForCell:self.cell]];
        if (deleteButtonTitleColor) {
            [[[self viewLocator] deleteButtonLabel] setTextColor:deleteButtonTitleColor];
        }
    }
}

- (BOOL)shouldDisplayMoreButton
{
    return [self moreOptionButtonTitleFromDelegate] != nil;
}

- (void)initMoreButton
{
    self.cell.moreOptionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.cell.moreOptionButton addTarget:self action:@selector(moreOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cell.moreOptionButton.titleLabel.numberOfLines = 0;
    self.cell.moreOptionButton.titleLabel.textAlignment =  NSTextAlignmentCenter;

    [self setMoreButtonTitleFromDelegate];
    [self setMoreButtonTitleColorFromDelegate];
    [self setMoreButtonBackgroundColorFromDelegate];

    [self sizeThingsToFit];

    [[[self viewLocator] deleteConfirmationView] addSubview:self.cell.moreOptionButton];
}

- (void)setMoreButtonTitleFromDelegate
{
    [self.cell.moreOptionButton setTitle:[self moreOptionButtonTitleFromDelegate] forState:UIControlStateNormal];
}

- (NSString *)moreOptionButtonTitleFromDelegate
{
    if ([self.cell.delegate respondsToSelector:@selector(tableView:titleForMoreOptionButtonForRowAtIndexPath:)]) {
        UITableView *tableView = [[self viewLocator] tableView];
        return [self.cell.delegate tableView:tableView titleForMoreOptionButtonForRowAtIndexPath:[tableView indexPathForCell:self.cell]];
    }

    return nil;
}

- (void)setMoreButtonTitleColorFromDelegate
{
    [self.cell.moreOptionButton setTitleColor:[self moreButtonTitleColor] forState:UIControlStateNormal];
}

- (UIColor *)moreButtonTitleColor
{
    UIColor *titleColor = [self moreButtonTitleColorFromDelegate];
    if (titleColor) {
        return titleColor;
    }

    return [UIColor whiteColor];
}

- (UIColor *)moreButtonTitleColorFromDelegate
{
    UITableView *tableView = [[self viewLocator] tableView];

    if ([self.cell.delegate respondsToSelector:@selector(tableView:titleColorForMoreOptionButtonForRowAtIndexPath:)]) {
        return [self.cell.delegate tableView:tableView titleColorForMoreOptionButtonForRowAtIndexPath:[tableView indexPathForCell:self.cell]];
    }

    return nil;
}
- (void)setMoreButtonBackgroundColorFromDelegate
{
    [self.cell.moreOptionButton setBackgroundColor:[self moreButtonBackgroundColor]];
}

- (UIColor *)moreButtonBackgroundColor
{
    UIColor *backgroundColor = [self moreButtonBackgroundColorFromDelegate];
    if (backgroundColor) {
        return backgroundColor;
    }

    return [UIColor lightGrayColor];
}

- (UIColor *)moreButtonBackgroundColorFromDelegate
{
    UITableView *tableView = [[self viewLocator] tableView];

    if ([self.cell.delegate respondsToSelector:@selector(tableView:backgroundColorForMoreOptionButtonForRowAtIndexPath:)]) {
        return [self.cell.delegate tableView:tableView backgroundColorForMoreOptionButtonForRowAtIndexPath:[tableView indexPathForCell:self.cell]];
    }

    return nil;
}

- (void)sizeThingsToFit
{
    CGFloat priorMoreOptionButtonFrameWidth = self.cell.moreOptionButton.frame.size.width;
    CGFloat originalDeleteConfirmationViewWidth = [[self viewLocator] deleteConfirmationView].frame.size.width - priorMoreOptionButtonFrameWidth;

    [self sizeMoreOptionButtonToFitText];
    [self sizeDeleteConfirmationViewToFitMoreButton:originalDeleteConfirmationViewWidth];
}

- (void)sizeMoreOptionButtonToFitText
{
    CGRect moreOptionButtonFrame = CGRectZero;

    moreOptionButtonFrame.size.width = [self moreOptionButtonWidth];
    moreOptionButtonFrame.size.height = [self moreOptionButtonHeight];

    self.cell.moreOptionButton.frame = moreOptionButtonFrame;
}

- (CGFloat)moreOptionButtonWidth
{
    if ([[[self cell] delegate] respondsToSelector:@selector(tableView:widthForMoreOptionButtonForRowAtIndexPath:)]) {
        return [[[self cell] delegate] tableView:[[self viewLocator] tableView] widthForMoreOptionButtonForRowAtIndexPath:[[self viewLocator] indexPathInTableView]];
    }else{
        CGSize sizeThatFits = [self.cell.moreOptionButton sizeThatFits:self.cell.moreOptionButton.bounds.size];
        return sizeThatFits.width + 30.f;
    }
}

- (CGFloat)moreOptionButtonHeight
{
    UIButton *deleteConfirmationButton = [[self viewLocator] deleteConfirmationButton];

    return deleteConfirmationButton.frame.size.height ? deleteConfirmationButton.frame.size.height : [[self viewLocator] deleteConfirmationView].frame.size.height;
}

- (void)sizeDeleteConfirmationViewToFitMoreButton:(CGFloat)originalDeleteConfirmationViewWidth
{
    UIView *deleteConfirmationView = [[self viewLocator] deleteConfirmationView];

    CGRect rect = deleteConfirmationView.frame;

    rect.size.width = CGRectGetMaxX(self.cell.moreOptionButton.frame) + originalDeleteConfirmationViewWidth;
    rect.origin.x = deleteConfirmationView.superview.bounds.size.width - rect.size.width; // right align

    deleteConfirmationView.frame = rect;
}

- (void)moreOptionButtonPressed:(id)sender {
    UITableView *tableView = [[self viewLocator] tableView];

    if ([self.cell.delegate respondsToSelector:@selector(tableView:moreOptionButtonPressedInRowAtIndexPath:)]) {
        [self.cell.delegate tableView:tableView moreOptionButtonPressedInRowAtIndexPath:[[self viewLocator] indexPathInTableView]];
    }
}

@end