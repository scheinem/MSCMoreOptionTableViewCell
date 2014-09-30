//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2014 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"
#import <objc/message.h>

const CGFloat MSCMoreOptionTableViewCellButtonWidthSizeToFit = CGFLOAT_MIN;
static char kMSCMoreOptionTableViewCellKVOContext = 0;

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIButton *moreOptionButton;
@property (nonatomic, strong) UIScrollView *cellScrollView;

@end

@implementation MSCMoreOptionTableViewCell

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;
        
        [self setupObserving];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _moreOptionButton = nil;
        _cellScrollView = nil;
        
        [self setupObserving];
    }
    return self;
}

- (void)dealloc {
    [self.cellScrollView.layer removeObserver:self forKeyPath:@"sublayers" context:&kMSCMoreOptionTableViewCellKVOContext];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView | iOS 8 functionality
////////////////////////////////////////////////////////////////////////

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    NSString *className = NSStringFromClass(view.class);
    if ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]) {
        /*
         * Only provide 'MSCMoreOptionTableViewCell' functionality when iOS 8's new
         * 'tableView:editActionsForRowAtIndexPath:' isn't used.
         *
         * For a sample implementation of this new functionality take a look at:
         * https://gist.github.com/scheinem/e36835db07486e9f7e64
         */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if (![[self tableView].delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
#pragma clang diagnostic pop
            /*
             * Get '_UITableViewCellActionButton' instance which represents the "delete"
             * button. Therefore the parallel usage of 'tableView:editActionsForRowAtIndexPath:'
             * isn't possible because the "delete" button can't be distinguished from the other
             * action buttons.
             */
            __block UIButton *button = nil;
            [view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
                if ([NSStringFromClass(subview.class) hasPrefix:@"_"] &&
                    [NSStringFromClass(subview.class) hasSuffix:@"Button"]) {
                    button = (UIButton *)subview;
                    *stop = YES;
                }
            }];
            
            [self configureMoreOptionButtonForDeleteConfirmationView:view
                                        withDeleteConfirmationButton:button];
            
            /*
             * A little bit of obfuscation for the non public initializer 'initWithFrame:actionButtons:contentSize:'.
             * The initializer must be called because the property 'contentSize' isn't accessiable through a setter.
             */
            NSString *initializerSelectorName = [NSString stringWithFormat:@"%@%@:%@:", @"initWithFrame:actionButt", @"ons", @"contentSize"];
            ((void (*)(id, SEL, CGRect, NSArray *, CGSize))objc_msgSend)(view, NSSelectorFromString(initializerSelectorName), view.frame, @[button], CGSizeMake(button.frame.size.width + self.moreOptionButton.frame.size.width, button.frame.size.height));
        }
    }
    
    [super insertSubview:view atIndex:index];
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    // Set the 'more' button to nil if the 'swipe to delete' container view won't be visible anymore.
    NSString *className = NSStringFromClass(subview.class);
    if ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]) {
        self.moreOptionButton = nil;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject(NSKeyValueObserving) | iOS 7 functionality
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != &kMSCMoreOptionTableViewCellKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
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
                        UIButton *deleteConfirmationButton = nil;
                        
                        for (UIView *subview in deleteConfirmationView.subviews) {
                            NSString *subviewClass = NSStringFromClass([subview class]);
                            if ([subviewClass hasPrefix:@"UI"] &&
                                [subviewClass rangeOfString:@"Delete"].length > 0 &&
                                [subviewClass hasSuffix:@"Button"]) {
                                
                                deleteConfirmationButton = (UIButton *)subview;
                                break;
                            }
                        }
                        
                        [self configureMoreOptionButtonForDeleteConfirmationView:deleteConfirmationView
                                                    withDeleteConfirmationButton:deleteConfirmationButton];
                    }
                }
            }
            // Set the 'more' button to nil if the 'swipe to delete' container view isn't visible anymore.
            if (!swipeToDeleteControlVisible) {
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

- (void)configureMoreOptionButtonForDeleteConfirmationView:(UIView *)deleteConfirmationView
                              withDeleteConfirmationButton:(UIButton *)deleteConfirmationButton {
    UITableView *tableView = [self tableView];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    
    /*
     * 'Normalize' 'UITableViewCellDeleteConfirmationView's' title text implementation, because
     * under iOS 7 UIKit itself doesn't show the text using it's 'UIButtonLabel's' setTitle: but
     * using a seperate 'UILabel'.
     *
     * WHY Apple, WHY?
     *
     */
    [deleteConfirmationButton.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if ([view class] == [UILabel class]) {
            UILabel *titleLabel = (UILabel *)view;
            NSString *deleteConfirmationButtonTitle = titleLabel.text;
            [titleLabel removeFromSuperview];
            titleLabel = nil;
            
            [deleteConfirmationButton setTitle:deleteConfirmationButtonTitle forState:UIControlStateNormal];
            
            // Needed because otherwise the sizing algorithm wouldn't work for iOS 7
            deleteConfirmationButton.autoresizingMask = UIViewAutoresizingNone;
            
            *stop = YES;
        }
    }];
    // Set default titleEdgeInsets on 'delete' button
    [deleteConfirmationButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 15.f, 0.f, 15.f)];
    // Set clipsToBounds to YES on 'delete' button is necessary because otherwise it wouldn't
    // be possible to hide it settings it's frame's width to zero (the title would appear anyway).
    deleteConfirmationButton.clipsToBounds = YES;
    
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
            
            // Try to get 'more' edgeInsets from delegate (default: (0, 15, 0, 15))
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
            
            /* Try to get the 'more' minimum width and set the 'more' button's width to the
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
    
    // If created add the 'more' button to the cell's view hierarchy
    if (self.moreOptionButton) {
        [deleteConfirmationView addSubview:self.moreOptionButton];
    }
}

- (void)sizeMoreOptionButtonAndDeleteConfirmationButton:(UIButton *)deleteConfirmationButton
                          deleteConfirmationButtonWidth:(CGFloat)deleteConfirmationButtonWidth
                                  moreOptionButtonWidth:(CGFloat)moreOptionButtonWidth {
    
    // Get 'delete' button height calculated by UIKit.
    CGFloat deleteConfirmationButtonHeight = deleteConfirmationButton.frame.size.height;
    
    // Size 'more' button
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
    
    // Size 'delete' button
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
    
    // Fix 'delete' button's origin.x and set the frame
    deleteButtonFrame.origin.x = self.moreOptionButton.frame.origin.x + self.moreOptionButton.frame.size.width;
    deleteConfirmationButton.frame = deleteButtonFrame;
    
    // Adjust the 'UITableViewCellDeleteConfirmationView's' frame to fit the new button sizes.
    deleteConfirmationFrame.size.width = self.moreOptionButton.frame.size.width + deleteConfirmationButton.frame.size.width;
    deleteConfirmationFrame.origin.x = oldDeleteConfirmationFrameSuperViewWidth - deleteConfirmationFrame.size.width;
    
    deleteConfirmationView.frame = deleteConfirmationFrame;
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
    // Initialize the 'more' button.
    UIButton *freshMoreOptionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [freshMoreOptionButton addTarget:self action:@selector(moreOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set 'more' button's numberOfLines to 0 to enable support for multiline titles.
    freshMoreOptionButton.titleLabel.numberOfLines = 0;
    
    // Set clipsToBounds to YES is necessary because otherwise it wouldn't be possible
    // to hide it settings it's frame's width to zero (the title would appear anyway).
    freshMoreOptionButton.clipsToBounds = YES;
    
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
     * UIDeleteConfirmationView will get added to the cell directly.
     * So there is no need for KVO anymore and we can use
     * 'insertSubview:atIndex:' and 'willRemoveSubview:' instead.
     */
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            _cellScrollView = (UIScrollView *)layer.delegate;
            [_cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:&kMSCMoreOptionTableViewCellKVOContext];
            break;
        }
    }
}

@end
