//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"
#import <objc/message.h>

const CGFloat MSCMoreOptionTableViewCellButtonWidthSizeToFit = CGFLOAT_MIN;

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIButton *moreOptionButton;
@property (nonatomic, strong) UIScrollView *cellScrollView;

@end

@implementation MSCMoreOptionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;
        
        [self setupObserving];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;
        
        [self setupObserving];
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
         * Using '==' instead of 'isEqual:' to compare the observed object and the cell's contentScrollView's layer
         * (for iOS 7) OR the cell's layer (for iOS 8) because it must be the same instance and not an equal one.
         */
        if (object == self.cellScrollView.layer || object == self.layer) {
            BOOL swipeToDeleteControlVisible = NO;
            for (CALayer *layer in [(CALayer *)object sublayers]) {
                /*
                 * Check if the view is the 'swipe to delete' container view.
                 */
                NSString *name = NSStringFromClass([layer.delegate class]);
                if ([name hasPrefix:@"UI"] && [name hasSuffix:@"ConfirmationView"]) {
                    
                    swipeToDeleteControlVisible = YES;
                    
                    if (!self.moreOptionButton) {
                        
                        UIView *deleteConfirmationView = layer.delegate;
                        UIButton *deleteConfirmationButton = [self deleteButtonFromDeleteConfirmationView:deleteConfirmationView];
                        UITableView *tableView = [self tableView];
                        NSIndexPath *indexPath = [tableView indexPathForCell:self];
                        
                        /*
                         * 'Normalize' 'UITableViewCellDeleteConfirmationView's' title text implementation, because
                         * UIKit itself doesn't show the text using it's 'UIButtonLabel's' setTitle: but using an
                         * seperate 'UILabel'
                         *
                         * WHY Apple, WHY?
                         *
                         */
                        __block NSString *deleteConfirmationButtonTitle = nil;
                        [deleteConfirmationButton.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
                            if ([view class] == [UILabel class]) {
                                UILabel *titleLabel = (UILabel *)view;
                                deleteConfirmationButtonTitle = titleLabel.text;
                                [titleLabel removeFromSuperview];
                                titleLabel = nil;
                                *stop = YES;
                            }
                        }];
                        [deleteConfirmationButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 15.f, 0.f, 15.f)];
                        [deleteConfirmationButton setTitle:deleteConfirmationButtonTitle forState:UIControlStateNormal];
                        
                        // Need to get the delegate as strong variable because it's a weak property
                        id<MSCMoreOptionTableViewCellDelegate> strongDelegate = self.delegate;
                        if (strongDelegate) {
                            // Customize 'Delete' button using the delegate
                            
                            // Try to get 'Delete' backgroundColor from delegate
                            if ([strongDelegate respondsToSelector:@selector(tableView:backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:)]) {
                                UIColor *deleteButtonColor = [strongDelegate tableView:tableView
                           backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
                                if (deleteButtonColor) {
                                    deleteConfirmationButton.backgroundColor = deleteButtonColor;
                                }
                            }
                            
                            // Try to get 'Delete' titleColor from delegate
                            if ([strongDelegate respondsToSelector:@selector(tableView:titleColorForDeleteConfirmationButtonForRowAtIndexPath:)]) {
                                UIColor *deleteButtonTitleColor = [strongDelegate tableView:tableView
                                     titleColorForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
                                if (deleteButtonTitleColor) {
                                    for (UIView *label in deleteConfirmationButton.subviews) {
                                        if ([label isKindOfClass:[UILabel class]]) {
                                            [(UILabel*)label setTextColor:deleteButtonTitleColor];
                                            break;
                                        }
                                    }
                                }
                            }
                            
                            // Try to get 'Delete' edgeInsets from delegate
                            if ([strongDelegate respondsToSelector:@selector(tableView:edgeInsetsForDeleteConfirmationButtonForRowAtIndexPath:)]) {
                                UIEdgeInsets edgeInsets = [strongDelegate tableView:tableView
                             edgeInsetsForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
                                [deleteConfirmationButton setTitleEdgeInsets:edgeInsets];
                            }
                            
                            // Try to get 'More' title from delegate
                            NSString *moreTitle = nil;
                            if ([strongDelegate respondsToSelector:@selector(tableView:titleForMoreOptionButtonForRowAtIndexPath:)]) {
                                moreTitle = [strongDelegate tableView:tableView
                            titleForMoreOptionButtonForRowAtIndexPath:indexPath];
                                [self.moreOptionButton setTitle:moreTitle forState:UIControlStateNormal];
                            }
                            
                            // If there is a 'More' title OR the property 'configurationBlock' is set,
                            // initialize and configure the 'More' button.
                            if (moreTitle || self.configurationBlock) {
                                // Initialized 'More' button
                                self.moreOptionButton = [self freshMoreOptionButton];
                                [self.moreOptionButton setTitle:moreTitle forState:UIControlStateNormal];
                                
                                // Try to get 'More' titleColor from delegate (default: [UIColor whiteColor])
                                UIColor *titleColor = nil;
                                if ([strongDelegate respondsToSelector:@selector(tableView:titleColorForMoreOptionButtonForRowAtIndexPath:)]) {
                                    
                                    titleColor = [strongDelegate tableView:tableView
                            titleColorForMoreOptionButtonForRowAtIndexPath:indexPath];
                                }
                                if (!titleColor) {
                                    titleColor = [UIColor whiteColor];
                                }
                                [self.moreOptionButton setTitleColor:titleColor forState:UIControlStateNormal];
                                
                                // Try to get 'More' backgroundColor from delegate (default: [UIColor lightGrayColor])
                                UIColor *backgroundColor = nil;
                                if ([strongDelegate respondsToSelector:@selector(tableView:backgroundColorForMoreOptionButtonForRowAtIndexPath:)]) {
                                    
                                    backgroundColor = [strongDelegate tableView:tableView
                            backgroundColorForMoreOptionButtonForRowAtIndexPath:indexPath];
                                }
                                if (!backgroundColor) {
                                    backgroundColor = [UIColor lightGrayColor];
                                }
                                [self.moreOptionButton setBackgroundColor:backgroundColor];
                                
                                // Try to get 'More' edgeInsets from delegate (default: (0, 15, 0, 15))
                                if ([strongDelegate respondsToSelector:@selector(tableView:edgeInsetsForMoreOptionButtonForRowAtIndexPath:)]) {
                            
                                    UIEdgeInsets edgeInsets = [strongDelegate tableView:tableView
                            edgeInsetsForMoreOptionButtonForRowAtIndexPath:indexPath];
                                    [self.moreOptionButton setTitleEdgeInsets:edgeInsets];
                                } else {
                                    [self.moreOptionButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 15.f, 0.f, 15.f)];
                                }
                                
                                // Size buttons as they would be displayed.
                                [self sizeMoreOptionButtonAndDeleteConfirmationButton:deleteConfirmationButton
                                                        deleteConfirmationButtonWidth:MSCMoreOptionTableViewCellButtonWidthSizeToFit
                                                                moreOptionButtonWidth:MSCMoreOptionTableViewCellButtonWidthSizeToFit];
                                
                                /* Try to get the 'More' minimum width and set the 'More' button's width to the
                                 * maximum value of 'fitting size' and the minimum width returned by the delegate.
                                 */
                                if ([strongDelegate respondsToSelector:@selector(tableView:minimumWidthForMoreOptionButtonForRowAtIndexPath:)]) {
                                    
                                    CGFloat minimumWidth = [strongDelegate tableView:tableView
                                    minimumWidthForMoreOptionButtonForRowAtIndexPath:indexPath];
                                    
                                    CGRect moreOptionButtonFrame = self.moreOptionButton.frame;
                                    moreOptionButtonFrame.size.width = MAX(moreOptionButtonFrame.size.width, minimumWidth);
                                    self.moreOptionButton.frame = moreOptionButtonFrame;
                                }
                            }
                        }
                        
                        if (self.configurationBlock) {
                            if (!self.moreOptionButton) {
                                self.moreOptionButton = [self freshMoreOptionButton];
                            }
                            
                            CGFloat deleteConfirmationButtonWidth = MSCMoreOptionTableViewCellButtonWidthSizeToFit;
                            CGFloat moreOptionButtonWidth = MSCMoreOptionTableViewCellButtonWidthSizeToFit;
                            
                            self.configurationBlock(deleteConfirmationButton, self.moreOptionButton, &deleteConfirmationButtonWidth, &moreOptionButtonWidth);
                            
                            [self sizeMoreOptionButtonAndDeleteConfirmationButton:deleteConfirmationButton
                                                    deleteConfirmationButtonWidth:deleteConfirmationButtonWidth
                                                            moreOptionButtonWidth:moreOptionButtonWidth];
                        }
                        
                        
                        // If created add the 'More' button to the cell's view hierarchy
                        if (self.moreOptionButton) {
                            [deleteConfirmationView addSubview:self.moreOptionButton];
                        }
                    }
                }
            }
            // Set the 'More' button to nil if the 'swipe to delete' container view isn't visible anymore.
            if (self.moreOptionButton && !swipeToDeleteControlVisible) {
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
        id cellShowingDeleteConfirmationView = ((id(*)(id, SEL))objc_msgSend)(tableView, getCellSelector);
        if ([self isEqual:cellShowingDeleteConfirmationView]) {
            ((void(*)(id, SEL, BOOL))objc_msgSend)(tableView, hideConfirmationViewSelector, NO);
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - private methods
////////////////////////////////////////////////////////////////////////

/*
 * Looks for a 'UIDeleteConfirmationButton' in a given 'UIDeleteConfirmationView'.
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
    id<MSCMoreOptionTableViewCellDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(tableView:moreOptionButtonPressedInRowAtIndexPath:)]) {
        [strongDelegate tableView:[self tableView] moreOptionButtonPressedInRowAtIndexPath:[[self tableView] indexPathForCell:self]];
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

- (UIButton *)freshMoreOptionButton {
    // Initialize the 'More' button.
    UIButton *freshMoreOptionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [freshMoreOptionButton addTarget:self action:@selector(moreOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set 'More' button's numberOfLines to 0 to enable support for multiline titles.
    freshMoreOptionButton.titleLabel.numberOfLines = 0;
    
    return freshMoreOptionButton;
}

- (void)setupObserving {
    /*
     * For iOS 7:
     * ==========
     *
     * Look for UITableViewCell's scrollView.
     * Any CALayer found here can only be generated by UITableViewCell's
     * 'initWithStyle:reuseIdentifier:', so there is no way adding custom
     * sublayers before. This means custom sublayers are no problem and
     * don't break MSCMoreOptionTableViewCell's functionality.
     *
     * For iOS 8:
     * ==========
     *
     * UIDeleteConfirmationView will get added to the cell's layer directly.
     * There is no UIScrollView in the hierarchy anymore. So we need to observe
     * the cell's sublayers.
     */
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            _cellScrollView = (UIScrollView *)layer.delegate;
            break;
        }
    }
    
    CALayer *layerToObserver = _cellScrollView.layer ?: self.layer;
    [layerToObserver addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)sizeMoreOptionButtonAndDeleteConfirmationButton:(UIButton *)deleteConfirmationButton
                          deleteConfirmationButtonWidth:(CGFloat)deleteConfirmationButtonWidth
                                  moreOptionButtonWidth:(CGFloat)moreOptionButtonWidth {
    
    // Get 'Delete' button height calculated by UIKit.
    CGFloat deleteConfirmationButtonHeight = deleteConfirmationButton.frame.size.height;
    
    // Size 'More' button
    CGRect moreButtonFrame = CGRectZero;
    moreButtonFrame.size = [self.moreOptionButton intrinsicContentSize];
    
    if (moreOptionButtonWidth != MSCMoreOptionTableViewCellButtonWidthSizeToFit) {
        moreButtonFrame.size.width = moreOptionButtonWidth;
    } else if ([self.moreOptionButton imageForState:UIControlStateNormal]){
        moreButtonFrame.size.width += self.moreOptionButton.imageEdgeInsets.left + self.moreOptionButton.imageEdgeInsets.right;
    } else {
        moreButtonFrame.size.width += self.moreOptionButton.titleEdgeInsets.left + self.moreOptionButton.titleEdgeInsets.right;
    }
    moreButtonFrame.size.height = deleteConfirmationButtonHeight;
    self.moreOptionButton.frame = moreButtonFrame;
    
    // Size 'Delete' button
    CGRect deleteButtonFrame = CGRectZero;
    deleteButtonFrame.size = [deleteConfirmationButton intrinsicContentSize];
    
    if (deleteConfirmationButtonWidth != MSCMoreOptionTableViewCellButtonWidthSizeToFit) {
        deleteButtonFrame.size.width = deleteConfirmationButtonWidth;
    } else if ([deleteConfirmationButton imageForState:UIControlStateNormal]){
        deleteButtonFrame.size.width += deleteConfirmationButton.imageEdgeInsets.left + deleteConfirmationButton.imageEdgeInsets.right;
    } else {
        deleteButtonFrame.size.width += deleteConfirmationButton.titleEdgeInsets.left + deleteConfirmationButton.titleEdgeInsets.right;
    }
    deleteButtonFrame.size.height = deleteConfirmationButtonHeight;
    
    // Get needed variables
    UIView *deleteConfirmationView = deleteConfirmationButton.superview;
    CGRect deleteConfirmationFrame = deleteConfirmationView.frame;
    CGFloat oldDeleteConfirmationFrameSuperViewWidth = deleteConfirmationFrame.origin.x + deleteConfirmationFrame.size.width;
    
    /*
     * Fix 'Delete' button's origin.x and set the frame
     *
     * origin.x must be relative to it's by UIKit calculated zero position - Weird but true.
     */
    deleteButtonFrame.origin.x = deleteConfirmationFrame.size.width - deleteButtonFrame.size.width;
    deleteConfirmationButton.frame = deleteButtonFrame;
    
    // Adjust the 'UITableViewCellDeleteConfirmationView's' frame to fit the new button sizes.
    deleteConfirmationFrame.size.width = self.moreOptionButton.frame.size.width + deleteConfirmationButton.frame.size.width;
    deleteConfirmationFrame.origin.x = oldDeleteConfirmationFrameSuperViewWidth - deleteConfirmationFrame.size.width;
    
    deleteConfirmationView.frame = deleteConfirmationFrame;
}

@end
