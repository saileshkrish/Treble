//
//  UIView.Constraints.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-06.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

extension UIView {
    
    func constrain(to view: UIView) {
        self.constrain(.Leading, .Equal, to: view, .Leading)
        self.constrain(.Trailing, .Equal, to: view, .Trailing)
        self.constrain(.Top, .Equal, to: view, .Top)
        self.constrain(.Bottom, .Equal, to: view, .Bottom)
    }
    
    func constrainSize(to value: CGFloat) {
        self.constrain(.Width, .Equal, to: value)
        self.constrain(.Height, .Equal, to: value)
    }
    
    func constrain(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to otherView: UIView, _ otherAttribute: NSLayoutAttribute, times multiplier: CGFloat = 1, plus constant: CGFloat = 0, atPriority priority: UILayoutPriority = UILayoutPriorityRequired, identifier: String? = nil, active: Bool = true) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: otherView, attribute: otherAttribute, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = active
        return constraint
    }
    
    func constrain(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to constant: CGFloat, atPriority priority: UILayoutPriority = UILayoutPriorityRequired, identifier: String? = nil) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: constant)
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = true
        return constraint
    }
    
}