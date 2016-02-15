//
//  MusicQueueItemCell.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

class MusicQueueItemCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clearColor()
        self.textLabel!.textColor = UIColor(white: 1.0, alpha: 0.5)
        self.detailTextLabel!.textColor = UIColor(white: 1.0, alpha: 0.5)
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView!.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
    }
    
}
