//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

extension UIFont {
    static func preferredFont(
        forTextStyle textStyle: UIFont.TextStyle, design: UIFontDescriptor.SystemDesign
    ) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: textStyle)
        let descriptor = font.fontDescriptor.withDesign(design) ?? font.fontDescriptor
        return UIFont(descriptor: descriptor, size: 0.0)
    }
}
