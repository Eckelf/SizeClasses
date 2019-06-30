# SizeClasses

[![CI Status](http://img.shields.io/travis/Eckelf/SizeClasses.svg?style=flat)](https://travis-ci.org/Eckelf/SizeClasses)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/SizeClasses.svg?style=flat)](http://cocoapods.org/pods/SizeClasses)
[![License](https://img.shields.io/cocoapods/l/SizeClasses.svg?style=flat)](http://cocoapods.org/pods/SizeClasses)
[![Platform](https://img.shields.io/cocoapods/p/SizeClasses.svg?style=flat)](http://cocoapods.org/pods/SizeClasses)

SizeClasses lets you adapt your programmatic layout to size class changes - use the good parts of storyboards while writing code!

## Usage

Let's start with a few examples:

```swift
// Base layout is the same in every size class
when(.any, .any, activate: [
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
])

// Use up the whole screen width in compact horizontal sizes
when(.compact, .any, activate: [
    label.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
    view.readableContentGuide.trailingAnchor.constraint(equalTo: label.trailingAnchor)
])

// Use only half of the readable content width in regular horizontal sizes
when(.regular, .any, activate: [
    label.centerXAnchor.constraint(equalTo: view.readableContentGuide.centerXAnchor),
    label.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor, multiplier: 0.5)
])

// Left align label in compact horizontal sizes
when(.compact, .any) {
    label.textAlignment = .left
}

// Center align label in regular horizontal sizes
when(.regular, .any) {
    label.textAlignment = .center
}
```

### Setup

Still interested?
Adopt the protocol `SizeClasses` in any [`UITraitEnvironment`](https://developer.apple.com/documentation/uikit/uitraitenvironment) (`UIViewController`, `UIView`, etc) and add the following snippet:

```swift
class MyViewController: UIViewController, SizeClasses {

    let sizeClassesManager = SizeClassesManager()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionDidChange()
    }

}
```

### Using in layout

SizeClasses currently supports `NSLayoutConstraint`s and closures.

Similar to Xcode's storyboards there are three size-class choices available:

```swift
public enum UserInterfaceSizeClassPredicate {
    case any
    case compact
    case regular
}
```

The `SizeClasses` protocol adds several helper functions to its instances:

```swift
func when(_ horizontalSizeClass: UserInterfaceSizeClassPredicate, _ verticalSizeClass: UserInterfaceSizeClassPredicate, activate constraints: [NSLayoutConstraint])

func when(_ horizontalSizeClass: UserInterfaceSizeClassPredicate, _ verticalSizeClass: UserInterfaceSizeClassPredicate, do action: @escaping () -> Void) -> Any

func remove(constraint: NSLayoutConstraint)

func remove(actionWith identifier: Any)
```

Review the code's documentation for more details.

## Installation

SizeClasses is available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

```ruby
github "Eckelf/SizeClasses"
```

SizeClasses is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SizeClasses"
```

## Author

Vincent Flecke, opensource@eckgen.com

## License

SizeClasses is available under the MIT license. See the LICENSE file for more info.
