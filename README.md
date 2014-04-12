MSCMoreOptionTableViewCell
==========================

Drop-in solution to achieve the "More" button in an UITableView's "swipe to delete"-menu (as seen in the Mail.app) by extending Apple's own "swipe to delete"-implementation and not rewriting it, so UITableView's standard behaviour isn't changed.

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

If you are using **Storyboards** in your project then take a look at the demo project which includes a working example using a **Storyboard**.

## Add to your project

1. Add MSCMoreOptionTableViewCell.xcodeproj as subproject.
2. Add MSCMoreOptionTableViewCell's root folder to your project's header search paths.
3. Add MSCMoreOptionTableViewCell to your target's dependencies (Target >> Build Phases >> Target Dependencies).
4. Add MSCMoreOptionTableViewCell to your target's linked frameworks (Target >> Summary >> Linked Frameworks and Libraries).
5. Import "MSCMoreOptionTableViewCell.h" either in Prefix.pch or separately in any file you use it.

## Delegate

### Required

None.

### Optional

```objective-c
- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath;
```

```objective-c
- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
```

```objective-c
- (UIColor *)tableView:(UITableView *)tableView titleColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
```

```objective-c
- (UIColor *)tableView:(UITableView *)tableView backgroundColorForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
```

```objective-c
- (UIColor *)tableView:(UITableView *)tableView backgroundColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
```

```objective-c
- (UIColor *)tableView:(UITableView *)tableView titleColorForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath;
```

## Customizing

Both buttons can be customized using the optional delegate methods mentioned above.

## Compatibility and Requirements

* iOS 7 or newer
* Xcode 5 or newer

As many other solutions that extend existing functionalities MSCMoreOptionTableViewCell depends on existing vendor code, therefore if Apple change it's "swipe to delete"-implementation significant in future iOS releases, it could happen that the "More" button doesn't appear until MSCMoreOptionTableViewCell gets adopted. But it's important for you as developer to know that MSCMoreOptionTableViewCell can't break your App or UITableView's standard functionality because of changes on the "swipe to delete"-implementation from Apple.

## Alternative Solution

As [pointed out](https://gist.github.com/steipete/10541433) by [@steipete](https://twitter.com/steipete) there's a solution to achieve the "More" button without any third party code and private API usage. It's a pretty streamlined way but you have to consider that it's undocumented behaviour and the "Delete" and "More" buttons aren't customizable.

## Credits

MSCMoreOptionTableViewCell was created by [Manfred Scheiner](https://github.com/scheinem/) ([@scheinem](http://twitter.com/scheinem) - [scheinem.com](http://scheinem.com)). Of course there is also a [full list of all contributors](https://github.com/scheinem/MSCMoreOptionTableViewCell/graphs/contributors) available.

## License

MSCMoreOptionTableViewCell is available under the MIT license. See the LICENSE file for more info.
For usage without attribution contact [Manfred Scheiner](mailto:sayhi@scheinem.com).

## Apps using MSCMoreOptionTableViewCell

* [Fantastical 2](http://flexibits.com/fantastical-iphone)
* [SRB Mobile CRM](http://getmobile.srb.at)
* [An In-House application of Brau Union Österreich AG](https://www.youtube.com/watch?v=DEaJwoVzAaw)
* If your app is missing here just add it and send a pull request :)
