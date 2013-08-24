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

@implementation MSCMoreOptionTableViewCell

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
    [self.cellScrollView removeObserver:self forKeyPath:@"sublayers" context:nil];
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
                        
                        self.moreOptionButton = [[UIButton alloc] initWithFrame:CGRectZero];
                        [self.moreOptionButton addTarget:self action:@selector(moreOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        // Try to get title from delegate
                        if ([self.delegate respondsToSelector:@selector(tableView:titleForMoreOptionButtonForRowAtIndexPath:)]) {
                            [self setMoreOptionButtonTitle:[self.delegate tableView:[self tableView] titleForMoreOptionButtonForRowAtIndexPath:[[self tableView] indexPathForCell:self]] inDeleteConfirmationView:deleteConfirmationView];
                        }
                        else {
                            [self setMoreOptionButtonTitle:nil inDeleteConfirmationView:deleteConfirmationView];
                        }
                        
                        // Try to get titleColor from delegate
                        UIColor *titleColor = nil;
                        if ([self.delegate respondsToSelector:@selector(tableView:titleColorForMoreOptionButtonForRowAtIndexPath:)]) {
                            titleColor = [self.delegate tableView:[self tableView] titleColorForMoreOptionButtonForRowAtIndexPath:[[self tableView] indexPathForCell:self]];
                        }
                        if (titleColor == nil) {
                            titleColor = [UIColor whiteColor];
                        }
                        [self.moreOptionButton setTitleColor:titleColor forState:UIControlStateNormal];
                        
                        // Try to get backgroundColor from delegate
                        UIColor *backgroundColor = nil;
                        if ([self.delegate respondsToSelector:@selector(tableView:backgroundColorForMoreOptionButtonForRowAtIndexPath:)]) {
                            backgroundColor = [self.delegate tableView:[self tableView] backgroundColorForMoreOptionButtonForRowAtIndexPath:[[self tableView] indexPathForCell:self]];
                        }
                        if (backgroundColor == nil) {
                            backgroundColor = [UIColor lightGrayColor];
                        }
                        [self.moreOptionButton setBackgroundColor:backgroundColor];
                        
                        [deleteConfirmationView addSubview:self.moreOptionButton];
                        
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
#pragma mark - private methods
////////////////////////////////////////////////////////////////////////

- (void)moreOptionButtonPressed:(id)sender {
    if (self.delegate) {
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
    CGFloat priorMoreOptionButtonFrameWidth = self.moreOptionButton.frame.size.width;
    
    [self.moreOptionButton setTitle:title forState:UIControlStateNormal];
    [self.moreOptionButton sizeToFit];
    
    CGRect moreOptionButtonFrame = CGRectZero;
    moreOptionButtonFrame.size.width = self.moreOptionButton.frame.size.width + 30.f;
    moreOptionButtonFrame.size.height = deleteConfirmationView.frame.size.height;
    self.moreOptionButton.frame = moreOptionButtonFrame;
    
    CGRect rect = deleteConfirmationView.frame;
    rect.size.width = self.moreOptionButton.frame.origin.x + self.moreOptionButton.frame.size.width + (deleteConfirmationView.frame.size.width - priorMoreOptionButtonFrameWidth);
    rect.origin.x = deleteConfirmationView.superview.bounds.size.width - rect.size.width;
    deleteConfirmationView.frame = rect;
}

- (void)setupMoreOption {
    /*
     * Look for UITableViewCell's scrollView.
     * Any CALayer found here can only be generated by UITableViewCell's
     * 'initWithStyle:reuseIdentifier:', so there is no way adding custom
     * sublayers before. This means custom sublayers are no problem and
     * don't break MSCMoreOptionTableViewCell'S functionality.
     */
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            _cellScrollView = (UIScrollView *)layer.delegate;
            [_cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
            break;
        }
    }
}

@end
