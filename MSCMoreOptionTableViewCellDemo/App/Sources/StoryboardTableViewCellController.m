//
//  CustomTableViewCellController.m
//  MSCMoreOptionTableViewCellDemo
//
//  Created by Manfred Scheiner (@scheinem) on 24.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "StoryboardTableViewCellController.h"
#import "MSCMoreOptionTableViewCell.h"

@interface StoryboardTableViewCellController () <MSCMoreOptionTableViewCellDelegate>

@end

@implementation StoryboardTableViewCellController

////////////////////////////////////////////////////////////////////////
#pragma mark - Initializer
////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MSCMoreOptionTableViewCell";
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MSCMoreOptionTableViewCell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    cell.textLabel.text = @"Cell";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Called when "DELETE" button is pushed.
    NSLog(@"DELETE button pushed in row at: %@", indexPath.description);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Delete";
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MSCMoreOptionTableViewCellDelegate
////////////////////////////////////////////////////////////////////////

- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath {
    // Called when "MORE" button is pushed.
    NSLog(@"MORE button pushed in row at: %@", indexPath.description);
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Move to Top";
}

- (CGFloat)tableView:(UITableView *)tableView widthForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *moveTo = @"Move To";
    UILabel *label = [[UILabel alloc] init];
    [label setText:moveTo];
    CGSize sizeThatFits = [label sizeThatFits:label.frame.size];
    return sizeThatFits.width + 30.f;
}

- (UIColor *)tableView:(UITableView *)tableView titleColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIColor redColor];
}

- (UIColor *)tableView:(UITableView *)tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIColor blackColor];
}

@end
