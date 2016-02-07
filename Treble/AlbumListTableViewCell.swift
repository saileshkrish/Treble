//
//  AlbumListTableViewCell.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

class AlbumListTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clearColor()
        self.textLabel!.removeFromSuperview()
        self.detailTextLabel!.removeFromSuperview()
        
        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark)))
        vibrancyView.frame = self.bounds
        vibrancyView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.contentView.addSubview(vibrancyView)

        vibrancyView.contentView.addSubview(self.textLabel!)
        vibrancyView.contentView.addSubview(self.detailTextLabel!)
        
        self.textLabel!.textColor = UIColor(white: 1.0, alpha: 0.5)
        self.detailTextLabel!.textColor = UIColor(white: 1.0, alpha: 0.5)
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
