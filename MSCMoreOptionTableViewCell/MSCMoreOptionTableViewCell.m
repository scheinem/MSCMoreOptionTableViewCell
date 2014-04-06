//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"
#import <objc/message.h>

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIButton *moreOptionButton;
@property (nonatomic, strong) UIScrollView *cellScrollView;

@end

@implementation MSCMoreOptionTableViewCell

////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods
////////////////////////////////////////////////////////////////////////

- (void)revertToOriginalState {
    [self.cellScrollView setContentOffset:CGPointZero animated:YES];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;

        [self setupMoreOption];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;

        [self setupMoreOption];
    }
    return self;
}

- (void)dealloc {
    [self.cellScrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject(NSKeyValueObserving)
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sublayers"]) {
        /*
         * Using '==' instead of 'isEqual:' to compare the layer's delegate and the cell's contentScrollView
         * because it must be the same instance and not an equal one.
         */
        if ([object isKindOfClass:[CALayer class]] && ((CALayer *)object).delegate == self.cellScrollView) {
            BOOL moreOptionDelteButtonVisiblePrior = (self.moreOptionButton != nil);
            BOOL swipeToDeleteControlVisible = NO;
            for (CALayer *layer in [(CALayer *)object sublayers]) {
                /*
                 * Check if the view is the "swipe to delete" container view.
                 */
                NSString *name = NSStringFromClass([layer.delegate class]);
                if ([name hasPrefix:@"UI"] && [name hasSuffix:@"ConfirmationView"]) {
                    if (self.moreOptionButton) {
                        swipeToDeleteControlVisible = YES;
                    }
                    else {
                        UIView *deleteConfirmationView = layer.delegate;
                        UITableView *tableView = [self tableView];

                        // Try to get "Delete" backgroundColor from delegate
                        if ([self.delegate respondsToSelector:@selector(tableView:backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:)]) {
                            UIButton *deleteConfirmationButton = [self deleteButtonFromDeleteConfirmationView:deleteConfirmationView];
                            if (deleteConfirmationButton) {
                                UIColor *deleteButtonColor = [self.delegate tableView:tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:[tableView indexPathForCell:self]];
                                if (deleteButtonColor) {
                                    deleteConfirmationButton.backgroundColor = deleteButtonColor;
                                }
                            }
                        }

                        // Try to get "Delete" titleColor from Delegate
                        if ([self.delegate respondsToSelector:@selector(tableView:titleColorForDeleteConfirmationButtonForRowAtIndexPath:)]) {
                            UIButton *deleteConfirmationButton = [self deleteButtonFromDeleteConfirmationView:deleteConfirmationView];
                            if (deleteConfirmationButton) {
                                UIColor *deleteButtonTitleColor = [self.delegate tableView:tableView titleColorForDeleteConfirmationButtonForRowAtIndexPath:[tableView indexPathForCell:self]];
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

                        if ([self moreOptionButtonTitle]) {
                            self.moreOptionButton = [[UIButton alloc] initWithFrame:CGRectZero];
                            [self.moreOptionButton addTarget:self action:@selector(moreOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

                            // Set "More" button's numberOfLines to 0 to enable support for multiline titles.
                            self.moreOptionButton.titleLabel.numberOfLines = 0;

                            /*
                             * Get "More" title from delegate. Doesn't have to check if delegate responds
                             * because this must be otherwise the "if"-clause wouldn't have been entered.
                             */
                            [self setMoreOptionButtonTitle:[self.delegate tableView:tableView titleForMoreOptionButtonForRowAtIndexPath:[tableView indexPathForCell:self]] inDeleteConfirmationView:deleteConfirmationView];

                            // Try to get "More" titleColor from delegate
                            UIColor *titleColor = nil;
                            if ([self.delegate respondsToSelector:@selector(tableView:titleColorForMoreOptionButtonForRowAtIndexPath:)]) {
                                titleColor = [self.delegate tableView:tableView titleColorForMoreOptionButtonForRowAtIndexPath:[tableView indexPathForCell:self]];
                            }
                            if (titleColor == nil) {
                                titleColor = [UIColor whiteColor];
                            }
                            [self.moreOptionButton setTitleColor:titleColor forState:UIControlStateNormal];

                            // Try to get "More" backgroundColor from delegate
                            UIColor *backgroundColor = nil;
                            if ([self.delegate respondsToSelector:@selector(tableView:backgroundColorForMoreOptionButtonForRowAtIndexPath:)]) {
                                backgroundColor = [self.delegate tableView:tableView backgroundColorForMoreOptionButtonForRowAtIndexPath:[tableView indexPathForCell:self]];
                            }
                            if (backgroundColor == nil) {
                                backgroundColor = [UIColor lightGrayColor];
                            }
                            [self.moreOptionButton setBackgroundColor:backgroundColor];

                            // Add the "More" button to the cell's view hierarchy
                            [deleteConfirmationView addSubview:self.moreOptionButton];
                        }

                        break;
                    }
                }
            }
            if (moreOptionDelteButtonVisiblePrior && !swipeToDeleteControlVisible) {
                self.moreOptionButton = nil;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MSCMoreOptionTableViewCell
////////////////////////////////////////////////////////////////////////

- (void)hideDeleteConfirmation {
    UITableView *tableView = [self tableView];
    
    SEL hideConfirmationViewSelector = NSSelectorFromString([NSString stringWithFormat:@"_endSwi%@teRowDi%@:", @"peToDele", @"dDelete"]);
    SEL getCellSelector = NSSelectorFromString([NSString stringWithFormat:@"_sw%@oDele%@ll", @"ipeT", @"teCe"]);
    
    if ([tableView respondsToSelector:hideConfirmationViewSelector] && [tableView respondsToSelector:getCellSelector]) {
        id cellShowingDeleteConfirmationView = objc_msgSend(tableView, getCellSelector);
        if ([self isEqual:cellShowingDeleteConfirmationView]) {
            objc_msgSend(tableView, hideConfirmationViewSelector, NO);
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
    UIView *tableView = self.superview;
    while(tableView) {
        if(![tableView isKindOfClass:[UITableView class]]) {
            tableView = tableView.superview;
        }
        else {
            return (UITableView *)tableView;
        }
    }
    return nil;
}

- (void)setMoreOptionButtonTitle:(NSString *)title inDeleteConfirmationView:(UIView *)deleteConfirmationView {
    [self.moreOptionButton setTitle:title forState:UIControlStateNormal];
    [self.moreOptionButton sizeToFit];

    CGRect moreOptionButtonFrame = CGRectZero;
    moreOptionButtonFrame.size.width = self.moreOptionButton.frame.size.width + 30.f;
    /*
     * Look for the "Delete" button to apply it's height also to the "More" button.
     * If it can't be found there is a fallback to the deleteConfirmationView's height.
     */
    UIButton *deleteConfirmationButton = [self deleteButtonFromDeleteConfirmationView:deleteConfirmationView];
    if (deleteConfirmationButton) {
        moreOptionButtonFrame.size.height = deleteConfirmationButton.frame.size.height;
    }

    if (moreOptionButtonFrame.size.height == 0.f) {
        moreOptionButtonFrame.size.height = deleteConfirmationView.frame.size.height;
    }
    self.moreOptionButton.frame = moreOptionButtonFrame;

    CGRect rect = deleteConfirmationView.frame;
    rect.origin.x -= self.moreOptionButton.frame.size.width;
    rect.size.width += self.moreOptionButton.frame.size.width;

    deleteConfirmationView.frame = rect;
}

- (void)setupMoreOption {
    /*
     * Look for UITableViewCell's scrollView.
     * Any CALayer found here can only be generated by UITableViewCell's
     * 'initWithStyle:reuseIdentifier:', so there is no way adding custom
     * sublayers before. This means custom sublayers are no problem and
     * don't break MSCMoreOptionTableViewCell's functionality.
     */
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            _cellScrollView = (UIScrollView *)layer.delegate;
            [_cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
            break;
        }
    }
}

- (NSString *)moreOptionButtonTitle {
    UITableView *tableView = [self tableView];

    NSString *moreTitle = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:titleForMoreOptionButtonForRowAtIndexPath:)]) {
        moreTitle = [self.delegate tableView:tableView titleForMoreOptionButtonForRowAtIndexPath:[tableView indexPathForCell:self]];
    }
    
    return moreTitle;
}

@end
