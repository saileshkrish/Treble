//
//  TrackItemCell.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit

class TrackItemCell: UITableViewCell {
    
    var indexString: String = "" {
        didSet {
            self.indexLabel.text = indexString
            self.indexLabel.textColor = Int(indexString) == nil ? .white() : UIColor(white: 1.0, alpha: 0.50)
            self.textLabel!.textColor = Int(indexString) == nil ? .white() : UIColor(white: 1.0, alpha: 0.75)
        }
    }
    
    let indexLabel: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear()
        selectedBackgroundView = UIView()
        selectedBackgroundView!.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        textLabel!.textColor = UIColor(white: 1.0, alpha: 0.75)
        textLabel!.font = .preferredFont(for: .body)
        
        contentView.addSubview(indexLabel)
        indexLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        indexLabel.font = .preferredFont(for: .title3)
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        indexLabel.textAlignment = .right
        indexLabel.constrain(.leading, .equal, to: contentView, .leading, plus: 8)
        indexLabel.constrain(.height, .equal, to: contentView, .height)
    }
    
}
