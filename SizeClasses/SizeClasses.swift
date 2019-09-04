//
//  SizeClasses.swift
//  Pods
//
//  Created by Vincent Flecke on 2017-08-15.
//
//

import UIKit


/// Usage in any `UITraitEnvironment` (`UIViewController`, `UIView`, etc):
///
/// ```
/// let sizeClassesManager = SizeClassesManager()
///
/// override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
///     super.traitCollectionDidChange(previousTraitCollection)
///
///     traitCollectionDidChange()
/// }
///
/// override func viewDidLoad() {
///     super.viewDidLoad()
///
///     // Make sure that traits are evaluated at startup
///     traitCollectionDidChange()
/// }
///
/// ```
public protocol SizeClasses {
    
    var sizeClassesManager: SizeClassesManager { get }
    
}

public extension SizeClasses where Self: UITraitEnvironment {
    
    /// Convenience function to update `traitCollection` of `sizeClassesManager`.
    func traitCollectionDidChange() {
        sizeClassesManager.traitCollection = traitCollection
    }
    
    /// Registers the `constraints` with the `sizeClassesManager` using the provided size classes.
    /// The constraints will be active whenever the size classes match the current environment.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// - Parameters:
    ///   - horizontalSizeClass: the horizontal size class or any
    ///   - verticalSizeClass: the vertical size class or any
    ///   - constraints: the constraints to activate when the size class conditions are met
    func when(_ horizontalSizeClass: UserInterfaceSizeClassPredicate, _ verticalSizeClass: UserInterfaceSizeClassPredicate, activate constraints: [NSLayoutConstraint]) {
        sizeClassesManager.add(horizontalSizeClass, verticalSizeClass, constraints: constraints)
    }
    
    /// Convenience function for `when(_:_:activate constraints:)`.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// You should activate constraints in bulk when possible to increase performance.
    func when(_ horizontalSizeClass: UserInterfaceSizeClassPredicate, _ verticalSizeClass: UserInterfaceSizeClassPredicate, activate constraint: NSLayoutConstraint) {
        when(horizontalSizeClass, verticalSizeClass, activate: [constraint])
    }
    
    /// Registers the `action` with the `sizeClassesManager` using the provided size classes.
    /// The action will be executed once whenever the size classes match the current environment and they didn't match before.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// - Parameters:
    ///   - horizontalSizeClass: the horizontal size class or any
    ///   - verticalSizeClass: the vertical size class or any
    ///   - action: the action closure to be executed when the size class conditions are met
    /// - Returns: a unique identifier that can be used to remove the action again
    @discardableResult func when(_ horizontalSizeClass: UserInterfaceSizeClassPredicate, _ verticalSizeClass: UserInterfaceSizeClassPredicate, do action: @escaping () -> Void) -> Any {
        return sizeClassesManager.add(horizontalSizeClass, verticalSizeClass, action: action)
    }
    
    /// Removes the `constraint` from the `sizeClassesManager` and deactivates it if necessary.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// - Parameters:
    ///   - constraint: the constraint to remove
    func remove(constraint: NSLayoutConstraint) {
        sizeClassesManager.remove(constraint: constraint)
    }
    
    /// Removes the action with the given `identifier` from the `sizeClassesManager`.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// - Parameter identifier: the identifier of the action that was returned when adding the action
    func remove(actionWith identifier: Any) {
        sizeClassesManager.remove(actionWith: identifier)
    }
    
}
