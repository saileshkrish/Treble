//
//  UIImage.Assets.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-06.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

enum UIImageAsset: String {
    case Play
    case Pause
    case Next
    case Prev
    case Music
}

extension UIImage {
    
    static let Play:  UIImage = UIImage.asset(named: .Play)
    static let Pause: UIImage = UIImage.asset(named: .Pause)
    static let Next:  UIImage = UIImage.asset(named: .Next)
    static let Prev:  UIImage = UIImage.asset(named: .Prev)
    static let Music: UIImage = UIImage.asset(named: .Music)
    
    static func asset(named asset: UIImageAsset) -> UIImage {
        return UIImage(named: asset.rawValue)!.imageWithRenderingMode(.AlwaysTemplate)
    }
    
}