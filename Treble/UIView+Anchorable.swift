//
//  UIView+Anchorable.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-10.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit

protocol Anchorable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView : Anchorable {}
extension UILayoutGuide : Anchorable {}

extension UIView {
    func addSubviewAndConstrain(toMarginsGuide: Bool = false, _ subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        let guide: Anchorable = toMarginsGuide ? layoutMarginsGuide : self
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            subview.topAnchor.constraint(equalTo: guide.topAnchor),
            subview.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
}
