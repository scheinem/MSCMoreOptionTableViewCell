//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIButton *moreOptionButton;
@property (nonatomic, strong) UIScrollView *cellScrollView;

@end

@implementation MSCMoreOptionTableViewCell {
    UIView *_deleteConfirmationView;
    UITableView *_tableView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _moreOptionButton = nil;
    _cellScrollView = nil;

    [self setupMoreOption];
}

- (void)dealloc {
    [self.cellScrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject(NSKeyValueObserving)
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sublayers"]) {
        [self cellScrollViewLayerSublayersDidChange];
    }
}

- (void)cellScrollViewLayerSublayersDidChange
{
    CALayer *cellScrollViewLayer = _cellScrollView.layer;   // implies: UITableViewCell -> UIScrollView -> .layer

    BOOL moreOptionDeleteButtonVisiblePrior = (self.moreOptionButton != nil); // more option has been shown before? when is this button set?
    BOOL swipeToDeleteControlVisible = NO;

    CALayer *swipeToDeleteLayer = [self findSwipeToDeleteLayerInScrollViewLayer:cellScrollViewLayer];
    if (swipeToDeleteLayer) {   // what the hell is happening here?!?!
        if (self.moreOptionButton) {
            swipeToDeleteControlVisible = YES;
        }
        else {
            [self configureActionMenuButtonsInLayer:swipeToDeleteLayer];
        }
    }

    // what does this do?                                    // visiblePrior == self.moreOptionButton
    if (moreOptionDeleteButtonVisiblePrior && !swipeToDeleteControlVisible) { // !swipeToDeleteVisible == !self.moreOptionButton || !self.swipeToDeleteLayer
        self.moreOptionButton = nil;
    }
}

- (void)configureActionMenuButtonsInLayer:(CALayer *)layer
{
    // a layer containing a delete confirmation view
    UIView *deleteConfirmationView = layer.delegate;
    _deleteConfirmationView = deleteConfirmationView;

    UITableView *tableView = [self tableView];
    _tableView = tableView;

    [self configureDeleteButton];

    if ([self shouldDisplayMoreButton]) {
        [self configureMoreButton];
    }
}

- (void)configureMoreButton
{
    self.moreOptionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.moreOptionButton addTarget:self action:@selector(moreOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.moreOptionButton.titleLabel.numberOfLines = 0;
    self.moreOptionButton.titleLabel.textAlignment =  NSTextAlignmentCenter;

    [self.moreOptionButton setTitle:[self moreOptionButtonTitleFromDelegate] forState:UIControlStateNormal];
    [self setMoreButtonTitleColorFromDelegate];
    [self setMoreButtonBackgroundColorFromDelegate];

    [self sizeThingsToFit];

    [_deleteConfirmationView addSubview:self.moreOptionButton];
}

- (void)sizeThingsToFit
{
    CGFloat priorMoreOptionButtonFrameWidth = self.moreOptionButton.frame.size.width;
    CGFloat originalDeleteConfirmationViewWidth = _deleteConfirmationView.frame.size.width - priorMoreOptionButtonFrameWidth;
    
    [self sizeMoreOptionButtonToFitText];
    [self sizeDeleteConfirmationViewToFitMoreButton:originalDeleteConfirmationViewWidth];
}

- (void)sizeDeleteConfirmationViewToFitMoreButton:(CGFloat)originalDeleteConfirmationViewWidth
{
    CGRect rect = _deleteConfirmationView.frame;

    rect.size.width = CGRectGetMaxX(self.moreOptionButton.frame) + originalDeleteConfirmationViewWidth;
    rect.origin.x = _deleteConfirmationView.superview.bounds.size.width - rect.size.width; // right align

    _deleteConfirmationView.frame = rect;
}

- (void)sizeMoreOptionButtonToFitText
{
    CGRect moreOptionButtonFrame = CGRectZero;

    moreOptionButtonFrame.size.width = [self moreOptionButtonWidth];
    
    moreOptionButtonFrame.size.height = [self moreOptionButtonHeight];
    
    self.moreOptionButton.frame = moreOptionButtonFrame;
}

- (CGFloat)moreOptionButtonWidth
{
    if ([[self delegate] respondsToSelector:@selector(tableView:widthForMoreOptionButtonForRowAtIndexPath:)]) {
        return [[self delegate] tableView:[self tableView] widthForMoreOptionButtonForRowAtIndexPath:[self indexPath]];
    }else{
        CGSize sizeThatFits = [self.moreOptionButton sizeThatFits:self.moreOptionButton.bounds.size];
        return sizeThatFits.width + 30.f;
    }
}

- (CALayer *)findSwipeToDeleteLayerInScrollViewLayer:(CALayer *)scrollViewLayer
{
    for (CALayer *layer in [scrollViewLayer sublayers]) {
        NSString *className = NSStringFromClass([layer.delegate class]);
        if ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]) {
            return layer;
        }
    }

    return nil;
}

- (NSIndexPath *)indexPath
{
    return [_tableView indexPathForCell:self];
}

- (void)setMoreButtonBackgroundColorFromDelegate
{
    UIColor *backgroundColor = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:backgroundColorForMoreOptionButtonForRowAtIndexPath:)]) {
        backgroundColor = [self.delegate tableView:_tableView backgroundColorForMoreOptionButtonForRowAtIndexPath:[_tableView indexPathForCell:self]];
    }
    if (backgroundColor == nil) {
        backgroundColor = [UIColor lightGrayColor];
    }
    [self.moreOptionButton setBackgroundColor:backgroundColor];
}

- (void)setMoreButtonTitleColorFromDelegate
{
    UIColor *titleColor = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:titleColorForMoreOptionButtonForRowAtIndexPath:)]) {
        titleColor = [self.delegate tableView:_tableView titleColorForMoreOptionButtonForRowAtIndexPath:[_tableView indexPathForCell:self]];
    }
    if (titleColor == nil) {
        titleColor = [UIColor whiteColor];
    }
    [self.moreOptionButton setTitleColor:titleColor forState:UIControlStateNormal];
}

- (BOOL)shouldDisplayMoreButton
{
    return [self moreOptionButtonTitleFromDelegate] != nil;
}

- (void)configureDeleteButton
{
    [self configureDeleteButtonBackgroundColorFromDelegate];
    [self configureDeleteButtonTitleColorFromDelegate];
}

- (void)configureDeleteButtonBackgroundColorFromDelegate
{
    if ([self.delegate respondsToSelector:@selector(tableView:backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        UIButton *deleteConfirmationButton = [self deleteButtonFromDeleteConfirmationView:_deleteConfirmationView];
        if (deleteConfirmationButton) {
            UIColor *deleteButtonColor = [self.delegate tableView:_tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:[_tableView indexPathForCell:self]];
            if (deleteButtonColor) {
                deleteConfirmationButton.backgroundColor = deleteButtonColor;
            }
        }
    }
}

- (void)configureDeleteButtonTitleColorFromDelegate
{
    if ([self.delegate respondsToSelector:@selector(tableView:titleColorForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        UIButton *deleteConfirmationButton = [self deleteButtonFromDeleteConfirmationView:_deleteConfirmationView];
        if (deleteConfirmationButton) {
            UIColor *deleteButtonTitleColor = [self.delegate tableView:_tableView titleColorForDeleteConfirmationButtonForRowAtIndexPath:[_tableView indexPathForCell:self]];
            if (deleteButtonTitleColor) {
                for (UIView *label in deleteConfirmationButton.subviews) {
                    if ([label isKindOfClass:[UILabel class]]) {
                        [(UILabel*)label setTextColor:deleteButtonTitleColor];
                        break;
                    }
                }
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - private methods
////////////////////////////////////////////////////////////////////////

/*
 * Looks for a UIDeleteConfirmationButton in a given UIDeleteConfirmationView.
 * Returns nil if the button could not be found.
 */
- (UIButton *)deleteButtonFromDeleteConfirmationView:(UIView *)deleteConfirmationView {
    for (UIButton *deleteConfirmationButton in deleteConfirmationView.subviews) {
        NSString *name = NSStringFromClass([deleteConfirmationButton class]);
        if ([name hasPrefix:@"UI"] && [name rangeOfString:@"Delete"].length > 0 && [name hasSuffix:@"Button"]) {
            return deleteConfirmationButton;
        }
    }
    return nil;
}

- (void)moreOptionButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tableView:moreOptionButtonPressedInRowAtIndexPath:)]) {
        [self.delegate tableView:[self tableView] moreOptionButtonPressedInRowAtIndexPath:[[self tableView] indexPathForCell:self]];
    }
}

- (UITableView *)tableView {
    UIView *superview = self.superview;
    while(superview) {
        if([superview isKindOfClass:[UITableView class]]) {
           return (UITableView *)superview;
        }else{
            superview = superview.superview;
        }
    }

    return nil;
}

- (UIButton *)deleteConfirmationButton
{
    return [self deleteButtonFromDeleteConfirmationView:_deleteConfirmationView]; // or cache?
}

- (CGFloat)moreOptionButtonHeight
{
    UIButton *deleteConfirmationButton = [self deleteConfirmationButton];

    return deleteConfirmationButton.frame.size.height ? deleteConfirmationButton.frame.size.height : _deleteConfirmationView.frame.size.height;
}

- (void)setupMoreOption {
    _cellScrollView = [self findScrollView];
    [_cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
}

- (UIScrollView *)findScrollView
{
    /*
     * Look for UITableViewCell's scrollView.
     * Any CALayer found here can only be generated by UITableViewCell's
     * 'initWithStyle:reuseIdentifier:', so there is no way adding custom
     * sublayers before. This means custom sublayers are no problem and
     * don't break MSCMoreOptionTableViewCell's functionality.
    */

    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
           return (UIScrollView *)layer.delegate;
        }
    }

    return nil;
}

- (NSString *)moreOptionButtonTitleFromDelegate
{
    UITableView *tableView = [self tableView];

    NSString *moreTitle = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:titleForMoreOptionButtonForRowAtIndexPath:)]) {
        moreTitle = [self.delegate tableView:tableView titleForMoreOptionButtonForRowAtIndexPath:[tableView indexPathForCell:self]];
    }
    
    return moreTitle;
}

@end