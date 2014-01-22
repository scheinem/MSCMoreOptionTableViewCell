//
// Created by Robert Gilliam on 1/17/14.
// Copyright (c) 2014 Manfred Scheiner. All rights reserved.
//

#import "MSCMoreOptionTableViewCellViewLocator.h"
#import "MSCMoreOptionTableViewCell.h"


@implementation MSCMoreOptionTableViewCellViewLocator {
    UIScrollView *_scrollView;
}

@synthesize scrollView = _scrollView;

- (instancetype)initWithCell:(MSCMoreOptionTableViewCell *)cell
{
    self = [super init];
    if (self) {
        _cell = cell;

        _scrollView = [self findScrollView];
    }

    return self;
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

    for (CALayer *layer in _cell.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)layer.delegate;
        }
    }

    return nil;
}

- (UIView *)deleteConfirmationView
{
    return [[self swipeToDeleteLayer] delegate];
}

- (CALayer *)swipeToDeleteLayer
{
    for (CALayer *layer in [_scrollView.layer sublayers]) {
        if ([self layerIsSwipeToDeleteLayer:layer]) {
            return layer;
        }
    }

    return nil;
}

- (BOOL)layerIsSwipeToDeleteLayer:(CALayer *)layer
{
    NSString *className = NSStringFromClass([layer.delegate class]);
    return ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]);
}

- (UIButton *)deleteConfirmationButton
{
    for (UIButton *button in [[self deleteConfirmationView] subviews]) {
        if ([self buttonIsDeleteConfirmationButton:button]) {
            return button;
        }
    }
    return nil;
}

- (BOOL)buttonIsDeleteConfirmationButton:(UIButton *)button
{
    NSString *name = NSStringFromClass([button class]);
    return [name hasPrefix:@"UI"] && [name rangeOfString:@"Delete"].length > 0 && [name hasSuffix:@"Button"];
}

- (UILabel *)deleteButtonLabel
{
    for (UIView *view in [[self deleteConfirmationButton] subviews]) {
        if ([self viewIsDeleteButtonLabel:view]) {
            return (UILabel *)view;
        }
    }

    return nil;
}

- (BOOL)viewIsDeleteButtonLabel:(UIView *)view {
    return [view isKindOfClass:[UILabel class]];
}

- (UITableView *)tableView
{
    UIView *superview = self.cell.superview;
    while(superview) {
        if([superview isKindOfClass:[UITableView class]]) {
            return (UITableView *)superview;
        }else{
            superview = superview.superview;
        }
    }

    return nil;
}

- (NSIndexPath *)indexPathInTableView
{
   return [[self tableView] indexPathForCell:self.cell];
}

@end