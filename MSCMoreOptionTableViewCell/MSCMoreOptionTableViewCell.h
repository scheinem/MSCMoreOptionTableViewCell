//
//  MSCMoreOptionTableViewCell.h
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

@protocol MSCMoreOptionTableViewCellDelegate<NSObject>
@optional

/*
 * Tells the delegate that the "More" button for specified row was pressed.
 */
- (void)tableView:(UITableView *)tableView moreButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;

@end


typedef void (^MSCConfigureButtonsBlock)(UIButton *deleteButton, UIButton *moreButton);

@interface MSCMoreOptionTableViewCell : UITableViewCell 

@property (nonatomic, weak) id<MSCMoreOptionTableViewCellDelegate> delegate;
@property (nonatomic, copy) void (^configureButtonsBlock)(UIButton *deleteButton, UIButton *moreButton);
@property (nonatomic) BOOL showMoreButton;   // default: YES
@property (nonatomic) BOOL showDeleteButton; // default: YES
@property (nonatomic) CGFloat moreWidth;     // default: fitting size, obeying the titleInsets / imageInsets
@property (nonatomic) CGFloat deleteWidth;   // default: fitting size, obeying the titleInsets / imageInsets

@end
