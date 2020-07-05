//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

enum PlaybackState {
    case Paused, Playing, Repeating, Listening
}

class PlaybackButton : ActionButton {
    
    var isPlaying: Bool = false {
        didSet {
            // setImage(isPlaying ? ImageAssets.pause : ImageAssets.play, for: .normal)
        }
    }
    
    var pbState : PlaybackState = PlaybackState.Paused {
        didSet {
            switch (pbState) {
            case PlaybackState.Paused:
                setImage(ImageAssets.play, for: .normal)
                break;
            case PlaybackState.Playing:
                setImage(ImageAssets.pause, for: .normal)
                break;
            case PlaybackState.Repeating:
                setImage(ImageAssets.repeating, for: .normal)
                break;
            case PlaybackState.Listening:
                setImage(ImageAssets.waveform, for: .normal)
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        // We use one of the two images to be the intrinsic size so that button does
        // not resize when we switch images and causes the UI to jump.
        if let config = preferredSymbolConfigurationForImage(in: .normal) {
            return ImageAssets.play?.withConfiguration(config).size ?? super.intrinsicContentSize
        } else {
            return ImageAssets.play?.size ?? super.intrinsicContentSize
        }
    }

    convenience init(style: UIFont.TextStyle = .title3, scale: UIImage.SymbolScale = .default) {
        self.init(image: ImageAssets.play, style: style, scale: scale)
        pbState = PlaybackState.Paused
    }
}
