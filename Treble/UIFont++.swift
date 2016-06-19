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
        
        case Title1
        case Title2
        case Title3
        case Headline
        case Subheadline
        case Body
        case Callout
        case Footnote
        case Caption1
        case Caption2
        
        var rawValue: String {
            return "UICTFontTextStyle\(self)"
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
