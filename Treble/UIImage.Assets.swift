//
//  UIImage.Assets.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-06.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

extension UIImage {

    enum Asset: String {
        case Play
        case Pause
        case Next
        case Prev
        case Music
    }
    
    convenience init(asset: Asset) {
        self.init(named: asset.rawValue)!
    }
    
}

extension UIImage.Asset {
    
    var image: UIImage {
        return UIImage(asset: self).imageWithRenderingMode(.AlwaysTemplate)
    }
    
}