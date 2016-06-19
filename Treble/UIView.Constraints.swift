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
        self.constrain(.leading, .equal, to: view, .leading)
        self.constrain(.trailing, .equal, to: view, .trailing)
        self.constrain(.top, .equal, to: view, .top)
        self.constrain(.bottom, .equal, to: view, .bottom)
    }
    
    func constrainSize(to value: CGFloat) {
        self.constrain(.width, .equal, to: value)
        self.constrain(.height, .equal, to: value)
    }
    
    @discardableResult
    func constrain(_ attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to otherView: UIView, _ otherAttribute: NSLayoutAttribute, times multiplier: CGFloat = 1, plus constant: CGFloat = 0, atPriority priority: UILayoutPriority = UILayoutPriorityRequired, identifier: String? = nil, active: Bool = true) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: otherView, attribute: otherAttribute, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.isActive = active
        return constraint
    }
    
    @discardableResult
    func constrain(_ attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to constant: CGFloat, atPriority priority: UILayoutPriority = UILayoutPriorityRequired, identifier: String? = nil, active: Bool = true) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: constant)
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.isActive = active
        return constraint
    }
    
}
