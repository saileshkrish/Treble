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
         return self.value(forKey: "_internal")!.value(forKey: "_itemCollection") as? MPMediaItemCollection
    }
    
    var query: MPMediaQuery {
        return self.queueAsQuery()
    }
    
}
