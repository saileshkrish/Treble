//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

struct NowPlayingProgress {
    var elapsedTime: Double = 0.0
    var duration: Double = 0.0
}

protocol NowPlayingProgressBarDelegate : class {
    func progressBarDidChangeValue(
        to time: TimeInterval, progressBar: NowPlayingProgressBar, completion: @escaping () -> Void
    )
}

class NowPlayingProgressBar : UIView {
    private static let thumbImage = UIImage(systemName: "circle.fill")!
    private let slider = UISlider()
    private let elapsedLabel = UILabel()
    private let remainingLabel = UILabel()
    private let adjustingSliderThumb = UIImageView(image: NowPlayingProgressBar.thumbImage)
    private var isAdjustingSlider = false {
        didSet { animateAdjustingThumb() }
    }

    weak var delegate: NowPlayingProgressBarDelegate? {
        didSet { slider.isEnabled = delegate != nil }
    }

    var elapsedTime: TimeInterval {
        get { progress.elapsedTime }
        set { progress.elapsedTime = newValue }
    }

    var progress = NowPlayingProgress() {
        didSet { updateProgressBar() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        elapsedLabel.font = .preferredFont(forTextStyle: .footnote, design: .monospaced)
        elapsedLabel.textColor = .secondaryLabel
        elapsedLabel.textAlignment = .left
        elapsedLabel.text = "0:00"

        remainingLabel.font = .preferredFont(forTextStyle: .footnote, design: .monospaced)
        remainingLabel.textColor = .secondaryLabel
        remainingLabel.textAlignment = .right
        remainingLabel.text = "-0:00"

        let config = UIImage.SymbolConfiguration(textStyle: .footnote, scale: .small)
        slider.setThumbImage(NowPlayingProgressBar.thumbImage.withConfiguration(config), for: .normal)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        adjustingSliderThumb.alpha = 0
        adjustingSliderThumb.transform = .minimal
        adjustingSliderThumb.preferredSymbolConfiguration = .init(textStyle: .largeTitle, scale: .large)
        addSubview(adjustingSliderThumb)

        let labels = UIStackView(arrangedSubviews: [elapsedLabel, remainingLabel])
        labels.axis = .horizontal
        labels.distribution = .fillEqually

        let contentView = UIStackView(arrangedSubviews: [slider, labels])
        contentView.axis = .vertical
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    private func updateProgressBar() {
        slider.minimumValue = 0.0
        slider.maximumValue = Float(progress.duration)
        guard !isAdjustingSlider else { return }
        updateLabels(with: progress.elapsedTime)
        slider.setValue(Float(progress.elapsedTime), animated: true)
        updateAdjustingThumbPosition()
    }

    private func updateLabels(with time: TimeInterval) {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        elapsedLabel.text = formatter.string(from: time)
        remainingLabel.text = formatter.string(from: progress.duration)
    }

    @objc private func sliderTouchDown() {
        isAdjustingSlider = true
    }

    @objc private func sliderTouchUp() {
        delegate?.progressBarDidChangeValue(to: Double(slider.value), progressBar: self) {
            self.isAdjustingSlider = false
        }
    }

    @objc private func sliderValueChanged() {
        updateAdjustingThumbPosition()
        updateLabels(with: Double(slider.value))
    }

    private func animateAdjustingThumb() {
        let targetAlpha: CGFloat = isAdjustingSlider ? 1.0 : 0.0
        let transform = isAdjustingSlider ? CGAffineTransform.fullSize : .minimal
        UIView.animate(
            withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8,
            options: .beginFromCurrentState, animations: {
                self.adjustingSliderThumb.transform = transform
                self.adjustingSliderThumb.alpha = targetAlpha
        }, completion: nil)
    }

    private func updateAdjustingThumbPosition() {
        let fractionalLocation = CGFloat(slider.value / (slider.maximumValue - slider.minimumValue))
        let thumbWidth = slider.currentThumbImage!.size.width
        let maximumWidth = slider.frame.width - thumbWidth
        let positionInSlider = CGPoint(x: thumbWidth/2 + fractionalLocation * maximumWidth, y: slider.frame.height / 2)
        adjustingSliderThumb.center = slider.convert(positionInSlider, to: self)
    }
}

private extension CGAffineTransform {
    static let minimal = CGAffineTransform(scaleX: 0.25, y: 0.25)
    static let fullSize = CGAffineTransform(scaleX: 1.25, y: 1.25)
}
