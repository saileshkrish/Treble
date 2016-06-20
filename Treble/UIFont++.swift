//
//  UIFont++.swift
//  Treble
//
//  Created by Andy Liang on 2016-06-19.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

extension UIFont {
    
    enum TextStyle: String {
        
        case title1
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption1
        case caption2
        
        var rawValue: String {
            return "UICTFontTextStyle\("\(self)".capitalized)"
        }

    }
    
    class func preferredFont(for textStyle: TextStyle) -> UIFont {
        return self.preferredFont(forTextStyle: textStyle.rawValue)
    }
    
    @available(iOS 10.0, *)
    class func preferredFont(for textStyle: TextStyle, compatibleWith traitCollection: UITraitCollection?) -> UIFont {
        return self.preferredFont(forTextStyle: textStyle.rawValue, compatibleWith: traitCollection)
    }
    
}
