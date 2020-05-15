//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

class BackgroundArtworkView: UIView {
    static let blurEffect = UIBlurEffect(style: .systemThinMaterial)
    private let imageView = UIImageView()

    /// The album artwork
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue ?? ImageAssets.defaultAlbumArt }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        image = nil // set the default image
        imageView.contentMode = .scaleAspectFill
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)

        let blurView = UIVisualEffectView(effect: type(of: self).blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
