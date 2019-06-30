//
//  ViewController.swift
//  SizeClasses
//
//  Created by Vincent Flecke on 2017-08-15.
//  Copyright (c) 2017 Vincent Flecke. All rights reserved.
//

import SizeClasses
import UIKit

class ViewController: UIViewController, SizeClasses {
    
    let sizeClassesManager: SizeClassesManager = SizeClassesManager()
    
    private var removableCenterXConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let backgroundRectangle = UIView()
        backgroundRectangle.backgroundColor = .darkGray
        backgroundRectangle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundRectangle)
        
        let label = UILabel()
        label.text = "This label is left-aligned on compact and center-aligned on regular widths.\n\nIts text size changes with size-class changes as well.\n\nThe background rectangle extends over the full length in compact sizes."
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        let widthLabel = UILabel()
        widthLabel.textColor = .red
        widthLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        widthLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(widthLabel)
        
        let heightLabel = UILabel()
        heightLabel.textColor = .red
        heightLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        heightLabel.transform = heightLabel.transform.rotated(by: CGFloat(Double.pi / -2))
        heightLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(heightLabel)
        
        let removableConstraintExampleButton = UIButton()
        removableConstraintExampleButton.setTitle("Tap to toggle center x constraint", for: .normal)
        removableConstraintExampleButton.addTarget(self, action: #selector(onRemovableConstraintExampleButtonPressed), for: .touchUpInside)
        removableConstraintExampleButton.backgroundColor = .purple
        removableConstraintExampleButton.layer.cornerRadius = 4
        removableConstraintExampleButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
        removableConstraintExampleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(removableConstraintExampleButton)
        
        let removableConstraintExampleButtonFallbackLeadingConstraint = removableConstraintExampleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        // Set lower priority than center x constraint to prevent errors
        removableConstraintExampleButtonFallbackLeadingConstraint.priority = .defaultHigh
        
        removableCenterXConstraint = removableConstraintExampleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        
        // Base layout is the same in every size class
        when(.any, .any, activate: [
            backgroundRectangle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            widthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: widthLabel.bottomAnchor, constant: 4),
            
            heightLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: heightLabel.trailingAnchor, constant: -18),
            
            removableConstraintExampleButtonFallbackLeadingConstraint,
            removableCenterXConstraint,
            widthLabel.topAnchor.constraint(equalTo: removableConstraintExampleButton.bottomAnchor, constant: 20)
            ])
        
        // In compact widths the background rectangle and the label take on the full width; the label is inset by 20 points to its sides.
        when(.compact, .any, activate: [
            backgroundRectangle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: backgroundRectangle.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 20)
            ])
        
        // In regular widths the background rectangle doesn't extend past the readable width, the label not past half of the readable width
        when(.regular, .any, activate: [
            backgroundRectangle.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: backgroundRectangle.trailingAnchor),
            
            label.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor, multiplier: 0.5),
            label.centerXAnchor.constraint(equalTo: view.readableContentGuide.centerXAnchor)
            ])
        
        // In compact heights the background rectangle takes on the full height
        when(.any, .compact, activate: [
            backgroundRectangle.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: backgroundRectangle.bottomAnchor)
            ])
        
        // In regular heights the background rectangle wraps around the label
        when(.any, .regular, activate: [
            label.topAnchor.constraint(equalTo: backgroundRectangle.topAnchor, constant: 100),
            backgroundRectangle.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 100)
            ])
        
        // Use smaller font in compact widths
        when(.compact, .any) {
            label.font = .systemFont(ofSize: 17)
            label.textAlignment = .left
        }
        
        // Use bigger font in regular lengths
        when(.regular, .any) {
            label.font = .systemFont(ofSize: 24)
            label.textAlignment = .center
        }
        
        // Update axes' texts
        
        when(.compact, .any) {
            widthLabel.text = "compact"
        }
        
        when(.regular, .any) {
            widthLabel.text = "regular"
        }
        
        when(.any, .compact) {
            heightLabel.text = "compact"
        }
        
        when(.any, .regular) {
            heightLabel.text = "regular"
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        traitCollectionDidChange()
    }
    
    @objc func onRemovableConstraintExampleButtonPressed() {
        if removableCenterXConstraint.isActive {
            remove(constraint: removableCenterXConstraint)
        } else {
            when(.any, .any, activate: removableCenterXConstraint)
        }
    }
    
}
