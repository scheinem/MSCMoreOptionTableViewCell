//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"
#import "MSCMoreOptionTableViewCellViewLocator.h"

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) MSCMoreOptionTableViewCellViewLocator *viewLocator;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIButton *moreButton;
@end

@implementation MSCMoreOptionTableViewCell

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

- (void)initFromCoderOrWithStyle {
    _viewLocator = [[MSCMoreOptionTableViewCellViewLocator alloc] initWithCell:self];

    self.scrollView = [self.viewLocator scrollView];
	self.showMoreButton = YES;
	self.showDeleteButton = YES;
	
    [self.scrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.scrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}

- (UIButton*)deleteButton {
	return [self.viewLocator deleteConfirmationButton];
}

- (UIButton*)moreButton {
	if (!_moreButton) {
		_moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
		[_moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[_moreButton setTitle:@"More" forState:UIControlStateNormal];
		_moreButton.titleLabel.numberOfLines = 0;
		_moreButton.titleLabel.textAlignment =  NSTextAlignmentCenter;
		_moreButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
		_moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
		[_moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_moreButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
		_moreButton.backgroundColor = [UIColor lightGrayColor];
	}
	return _moreButton;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject(NSKeyValueObserving)
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sublayers"]) {
		if ([self.viewLocator deleteConfirmationView]) {
			
			if (self.showMoreButton && !self.moreButton.superview) {
				[[self.viewLocator deleteConfirmationView] addSubview:self.moreButton];
			}
			self.configureButtonsBlock(self.deleteButton, self.moreButton);

			[self sizeThingsToFit];
		}
		
		if ([self.viewLocator deleteConfirmationView] == nil) {
			[self.moreButton removeFromSuperview];
		}
    }
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Configurator
////////////////////////////////////////////////////////////////////////

- (void)sizeThingsToFit {
	UIButton *deleteButton = [self.viewLocator deleteConfirmationButton];

    CGRect moreButtonFrame = CGRectZero;
	moreButtonFrame.size = [self.moreButton intrinsicContentSize];
	if (self.moreWidth) {
		moreButtonFrame.size.width = self.moreWidth;
	} else {
		UIEdgeInsets insets = [self.moreButton imageForState:UIControlStateNormal] ? self.moreButton.imageEdgeInsets : self.moreButton.titleEdgeInsets;
		moreButtonFrame.size.width += insets.left + insets.right;
	}
    moreButtonFrame.size.height = deleteButton.frame.size.height ? deleteButton.frame.size.height : [self.viewLocator deleteConfirmationView].frame.size.height;
	self.moreButton.frame = moreButtonFrame;

	CGRect deleteButtonFrame = deleteButton.frame;
	if (self.deleteWidth || !self.showDeleteButton) {
		deleteButtonFrame.size.width = self.showDeleteButton ? self.deleteWidth : 0;
	} else {
		UIEdgeInsets insets = [self.deleteButton imageForState:UIControlStateNormal] ? self.deleteButton.imageEdgeInsets : self.deleteButton.titleEdgeInsets;
		deleteButtonFrame.size.width -= insets.left + insets.right;
	}
	deleteButtonFrame.origin.x = moreButtonFrame.size.width;
	
	UIView *deleteConfirmationView = [self.viewLocator deleteConfirmationView];
    CGRect deleteConfirmationFrame = deleteConfirmationView.frame;
	
    deleteConfirmationFrame.size.width = self.moreButton.frame.size.width + deleteButtonFrame.size.width; // expand by the size of the more button
    deleteConfirmationFrame.origin.x = self.frame.size.width - deleteConfirmationFrame.size.width; // make the more button on the left of the delete confirmation view by expanding to the left
	
    deleteConfirmationView.frame = deleteConfirmationFrame;

	deleteButton.frame = deleteButtonFrame;
}

- (void)moreButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tableView:moreButtonPressedInRowAtIndexPath:)]) {
        UITableView *tableView = [self.viewLocator tableView];
        [self.delegate tableView:tableView moreButtonPressedInRowAtIndexPath:[self.viewLocator indexPathInTableView]];
    }
}

@end
