//
//  SizeClassesManager.swift
//  Pods
//
//  Created by Vincent Flecke on 2017-08-15.
//
//

import UIKit

fileprivate func ==(lhs: SizeClassesManager.SizeClassesSelection, rhs: SizeClassesManager.SizeClassesSelection) -> Bool {
    return lhs.horizontal == rhs.horizontal && lhs.vertical == rhs.vertical
}

fileprivate func ==(lhs: SizeClassesManager.ActionWrapper, rhs: SizeClassesManager.ActionWrapper) -> Bool {
    return lhs.identifier == rhs.identifier
}

public enum UserInterfaceSizeClassPredicate {
    case any, compact, regular
    
    func matches(sizeClass: UIUserInterfaceSizeClass) -> Bool {
        switch (self, sizeClass) {
        case (.any, _) : return true
        case (.compact, .compact): return true
        case (.regular, .regular): return true
        default: return false
        }
    }
}

public class SizeClassesManager {
    
    fileprivate struct SizeClassesSelection: Hashable {
        let horizontal: UserInterfaceSizeClassPredicate
        let vertical: UserInterfaceSizeClassPredicate
        
        func matches(horizontalSizeClass: UIUserInterfaceSizeClass, verticalSizeClass: UIUserInterfaceSizeClass) -> Bool {
            return horizontal.matches(sizeClass: horizontalSizeClass) && vertical.matches(sizeClass: verticalSizeClass)
        }
    }
    
    fileprivate struct ActionWrapper: Hashable {
        let action: () -> Void
        let identifier: UInt
        
        var hashValue: Int {
            return identifier.hashValue
        }
    }
    
    var traitCollection: UITraitCollection = UITraitCollection() {
        didSet {
            // Make sure that properties that interest us have actually changed
            guard oldValue.horizontalSizeClass != traitCollection.horizontalSizeClass
                || oldValue.verticalSizeClass != traitCollection.verticalSizeClass else { return }
            
            updateConstraints()
            updateActions()
        }
    }
    
    fileprivate var constraintMappings: [ NSLayoutConstraint: SizeClassesSelection ] = [:]
    fileprivate var deactivatedConstraints: [ SizeClassesSelection: [NSLayoutConstraint] ] = [:]
    fileprivate var activatedConstraints: [ SizeClassesSelection: [NSLayoutConstraint] ] = [:]
    
    fileprivate var actionIdMappings: [ UInt: ActionWrapper ] = [:]
    fileprivate var actionMappings: [ ActionWrapper: SizeClassesSelection ] = [:]
    fileprivate var inactiveActions: [ SizeClassesSelection: [ActionWrapper] ] = [:]
    fileprivate var activeActions: [ SizeClassesSelection: [ActionWrapper] ] = [:]
    
    fileprivate var actionCounter: UInt = 0
    
    public init() {
        
    }
    
}

// MARK: API
extension SizeClassesManager {
    
    /// Adds the `constraints` to its model and activates them whenever the provided size classes match the current environment.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// - Parameters:
    ///   - horizontalSizeClass: the relevant horizontal size class or any
    ///   - verticalSizeClass: the relevant vertical size class or any
    ///   - constraints: the constraints tied to the given size classes
    func add(_ horizontalSizeClass: UserInterfaceSizeClassPredicate, _ verticalSizeClass: UserInterfaceSizeClassPredicate, constraints: [NSLayoutConstraint]) {
        let selection = SizeClassesSelection(horizontal: horizontalSizeClass, vertical: verticalSizeClass)
        
        ensureDeactivatedConstraintsEntryExists(for: selection)
        deactivatedConstraints[selection]!.append(contentsOf: constraints)
        
        constraints.forEach { constraintMappings[$0] = selection }
        
        updateConstraints()
    }
    
    /// Adds the `action` to its model and executes it whenever the provided size classes match the current environment.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// - Parameters:
    ///   - horizontalSizeClass: the relevant horizontal size class or any
    ///   - verticalSizeClass: the relevant vertical size class or any
    ///   - action: the action to be executed tied to the given size classes
    /// - Returns: a unique identifier that can be used to remove the action again
    func add(_ horizontalSizeClass: UserInterfaceSizeClassPredicate, _ verticalSizeClass: UserInterfaceSizeClassPredicate, action: @escaping () -> Void) -> Any {
        let selection = SizeClassesSelection(horizontal: horizontalSizeClass, vertical: verticalSizeClass)
        
        let id = actionCounter
        actionCounter += 1
        
        let actionWrapper = ActionWrapper(action: action, identifier: id)
        
        ensureInactiveActionsEntryExists(for: selection)
        inactiveActions[selection]!.append(actionWrapper)
        
        actionIdMappings[actionWrapper.identifier] = actionWrapper
        actionMappings[actionWrapper] = selection
        
        updateActions()
        
        return actionWrapper.identifier
    }
    
    /// Removes the `constraint` from its model and deactivates it if necessary.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// - Parameters:
    ///   - constraint: the constraint to remove
    func remove(constraint: NSLayoutConstraint) {
        guard let selection = constraintMappings[constraint] else { return }
        
        if let index = deactivatedConstraints[selection]?.index(of: constraint) {
            deactivatedConstraints[selection]?.remove(at: index)
        } else if let index = activatedConstraints[selection]?.index(of: constraint) {
            constraint.isActive = false
            activatedConstraints[selection]?.remove(at: index)
        }
        
        constraintMappings.removeValue(forKey: constraint)
    }
    
    /// Removes the action with the given `identifier` from its model.
    ///
    /// **Important**: This function has to be called on the main queue.
    ///
    /// - Parameter identifier: the identifier of the action that was returned when adding the action
    func remove(actionWith identifier: Any) {
        // Make sure that identifier is usable
        guard let identifier = identifier as? UInt else { return }
        
        guard let actionWrapper = actionIdMappings[identifier], let selection = actionMappings[actionWrapper] else { return }
        
        if let index = inactiveActions[selection]?.index(where: { $0.identifier == identifier }) {
            inactiveActions[selection]?.remove(at: index)
        } else if let index = activeActions[selection]?.index(where: { $0.identifier == identifier }) {
            activeActions[selection]?.remove(at: index)
        }
        
        actionIdMappings.removeValue(forKey: identifier)
        actionMappings.removeValue(forKey: actionWrapper)
    }
    
}

// MARK: Model Management
private extension SizeClassesManager {
    
    func updateConstraints() {
        // No need to update when environment has not been defined yet; increases performance for initial setup as well
        guard traitCollection.horizontalSizeClass != .unspecified && traitCollection.verticalSizeClass != .unspecified else { return }
        
        // Deactivate constraints that are no longer relevant
        for (selection, constraints) in activatedConstraints.filter({ !$0.value.isEmpty && !$0.key.matches(horizontalSizeClass: traitCollection.horizontalSizeClass, verticalSizeClass: traitCollection.verticalSizeClass) }) {
            NSLayoutConstraint.deactivate(constraints)
            
            activatedConstraints[selection] = []
            
            ensureDeactivatedConstraintsEntryExists(for: selection)
            deactivatedConstraints[selection]!.append(contentsOf: constraints)
        }
        
        // Activate constraints that have become relevant
        for (selection, constraints) in deactivatedConstraints.filter({ !$0.value.isEmpty && $0.key.matches(horizontalSizeClass: traitCollection.horizontalSizeClass, verticalSizeClass: traitCollection.verticalSizeClass) }) {
            NSLayoutConstraint.activate(constraints)
            
            deactivatedConstraints[selection] = []
            
            ensureActivatedConstraintsEntryExists(for: selection)
            activatedConstraints[selection]!.append(contentsOf: constraints)
        }
    }
    
    func updateActions() {
        // No need to update when environment has not been defined yet; increases performance for initial setup as well
        guard traitCollection.horizontalSizeClass != .unspecified && traitCollection.verticalSizeClass != .unspecified else { return }
        
        // Mark actions that are no longer relevant as inactive
        for (selection, actions) in activeActions.filter({ !$0.value.isEmpty && !$0.key.matches(horizontalSizeClass: traitCollection.horizontalSizeClass, verticalSizeClass: traitCollection.verticalSizeClass) }) {
            activeActions[selection] = []
            
            ensureInactiveActionsEntryExists(for: selection)
            inactiveActions[selection]!.append(contentsOf: actions)
        }
        
        // Execute actions that have become relevant
        for (selection, actions) in inactiveActions.filter({ !$0.value.isEmpty && $0.key.matches(horizontalSizeClass: traitCollection.horizontalSizeClass, verticalSizeClass: traitCollection.verticalSizeClass) }) {
            actions.forEach { $0.action() }
            
            inactiveActions[selection] = []
            
            ensureActiveActionsEntryExists(for: selection)
            activeActions[selection]!.append(contentsOf: actions)
        }
    }
    
}

// MARK: Helper Functions
private extension SizeClassesManager {
    
    func ensureDeactivatedConstraintsEntryExists(for selection: SizeClassesSelection) {
        if deactivatedConstraints[selection] == nil {
            deactivatedConstraints[selection] = []
        }
    }
    
    func ensureInactiveActionsEntryExists(for selection: SizeClassesSelection) {
        if inactiveActions[selection] == nil {
            inactiveActions[selection] = []
        }
    }
    
    func ensureActivatedConstraintsEntryExists(for selection: SizeClassesSelection) {
        if activatedConstraints[selection] == nil {
            activatedConstraints[selection] = []
        }
    }
    
    func ensureActiveActionsEntryExists(for selection: SizeClassesSelection) {
        if activeActions[selection] == nil {
            activeActions[selection] = []
        }
    }
    
}
