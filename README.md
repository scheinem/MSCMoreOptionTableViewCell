MSCMoreOptionTableViewCell
==========================

Drop-in solution to achieve the "More" button in an UITableView's "swipe to delete"-menu (as seen in the Mail.app) by extending Apple's own "swipe-to-delete"-implemtation and not rewriting it, so UITableView's standard behaviour isn't changed.

![Screenshot](https://raw.github.com/scheinem/MSCMoreOptionTableViewCell/master/MSCMoreOptionTableViewCell.png)

## Integration

If you are using a custom UITableViewCell subclass then change it to inherit from MSCMoreOptionTableViewCell instead of UITableViewCell. If your are using UITableViewCell itself just replace it with MSCMoreOptionTableViewCell (take a look at the following snippet for details). Then set the cell's delegate to your UITableViewController and you're ready to go!

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"MSCMoreOptionTableViewCell";
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MSCMoreOptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
    }
    cell.textLabel.text = @"Cell";
    
    return cell;
}
```

## Add to your project

1. Add MSCMoreOptionTableViewCell.xcodeproj as subproject.
2. Add MSCMoreOptionTableViewCell's root folder to your project's header search paths.
3. Add MSCMoreOptionTableViewCell to your target's dependencies (Target >> Build Phases >> Target Dependencies).
4. Add MSCMoreOptionTableViewCell to your target's linked frameworks (Target >> Summary >> Linked Frameworks and Libraries).
5. Import "MSCMoreOptionTableViewCell.h" either in Prefix.pch or seperatly in any file you use it.

## Delegate

### MSCMoreOptionTableViewCell's "More" button has been pressed

```objective-c
- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;
```

## Customizing

The 'More' button can be customized using the following three properties of MSCMoreOptionTableViewCell:

* NSString *moreOptionButtonTitle
* UIColor *moreOptionButtonBackgroundColor
* UIColor *moreOptionButtonTitleColor

## Credits

MSCMoreOptionTableViewCell was created by [Manfred Scheiner](https://github.com/scheinem/) ([@scheinem](http://twitter.com/scheinem) - [scheinem.com](http://scheinem.com)).

## License

MSCMoreOptionTableViewCell is available under the MIT license. See the LICENSE file for more info.
For usage without attribution contact [Manfred Scheiner](mailto:sayhi@scheinem.com).
