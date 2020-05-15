//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

class AlbumArtworkView: UIView {
    private static let pausedTransform = CGAffineTransform(scaleX: 0.85, y: 0.85)
    private let imageView = UIImageView()
    private var compactWidthConstraints: [NSLayoutConstraint] = []
    private var regularWidthConstraints: [NSLayoutConstraint] = []

    /// The current playback state of the media control
    var isPlaying = false {
        didSet {
            let transform = !isPlaying ? AlbumArtworkView.pausedTransform : .identity
            UIView.animate(
                withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8,
                options: .beginFromCurrentState, animations: { self.imageView.transform = transform },
                completion: nil)
        }
    }

    var isRegularWidth: Bool = false {
        willSet {
            guard isRegularWidth != newValue else { return }
            NSLayoutConstraint.deactivate(isRegularWidth ? regularWidthConstraints : compactWidthConstraints)
        } didSet {
            guard isRegularWidth != oldValue else { return }
            NSLayoutConstraint.activate(isRegularWidth ? regularWidthConstraints : compactWidthConstraints)
        }
    }

    /// The album artwork
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue ?? ImageAssets.defaultAlbumArt }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        // configure the image view
        image = nil
        imageView.layer.cornerRadius = 16
        imageView.layer.cornerCurve = .continuous
        imageView.layer.masksToBounds = true
        imageView.transform = AlbumArtworkView.pausedTransform

        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

        compactWidthConstraints = [
            imageView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ]

        regularWidthConstraints = [
            imageView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]

        NSLayoutConstraint.activate(compactWidthConstraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}