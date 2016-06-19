//
//  TrackItemCell.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

class TrackItemCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear()
        self.textLabel!.textColor = UIColor(white: 1.0, alpha: 0.75)
        self.textLabel!.font = .preferredFont(forTextStyle: UIFontTextStyleTitle3)
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView!.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
    }
    
}
