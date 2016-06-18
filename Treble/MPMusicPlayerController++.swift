//
//  MPMusicPlayerController++.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import Foundation
import MediaPlayer

extension MPMusicPlayerController {
    
    var count: Int {
        return Int(self.numberOfItems())
    }
    
    var internalController: MPMediaItemCollection? {
        let internalController = self.value(forKey: "_internal")!
        let itemCollection = internalController.value(forKey: "_itemCollection")
        print(itemCollection, internalController.value(forKey: "_musicPlayerController"))
        return itemCollection as? MPMediaItemCollection
    }
    
    var query: MPMediaQuery {
        return self.queueAsQuery()
    }
    
}
