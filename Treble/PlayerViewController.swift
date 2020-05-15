//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit
import AVKit
import MediaPlayer

class PlayerViewController : UIViewController {

    // MARK: - Data Properties
    private var mediaPlayer: MediaPlayer?

    // MARK: - UI Properties
    private let playbackButton = ActionButton(image: ImageAssets.play, style: .largeTitle, scale: .large)
    private let backwardButton = ActionButton(image: ImageAssets.backward, style: .largeTitle)
    private let forwardButton = ActionButton(image: ImageAssets.forward, style: .largeTitle)
    private let albumArtwork = AlbumArtworkView()
    private let backgroundArtwork = BackgroundArtworkView()
    private let progressBar = NowPlayingProgressBar()
    private let titleLabel = MarqueeLabel(frame: .zero, duration: 8, fadeLength: 8)
    private let subtitleLabel = MarqueeLabel(frame: .zero, duration: 8, fadeLength: 8)
    private let contentView = UIStackView()

    // MARK: - UIKit Methods

    override func loadView() {
        super.loadView()

        // Create background
        backgroundArtwork.backgroundColor = .systemGroupedBackground
        backgroundArtwork.frame = view.bounds
        backgroundArtwork.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundArtwork)

        // Main UI
        let libraryButton = ActionButton(image: ImageAssets.musicNote)
        let fileButton = ActionButton(image: ImageAssets.icloud)
        let routePickerButton = AVRoutePickerView()
        let volumeSlider = MPVolumeView()

        let playbackStackView = UIStackView(arrangedSubviews: [backwardButton, playbackButton, forwardButton])
        playbackStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        playbackStackView.setContentHuggingPriority(.required, for: .vertical)
        playbackStackView.distribution = .fillEqually
        playbackStackView.axis = .horizontal
        playbackStackView.alignment = .center

        let controlStackView = UIStackView(arrangedSubviews: [libraryButton, fileButton, routePickerButton])
        controlStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        controlStackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        controlStackView.distribution = .equalCentering
        controlStackView.axis = .horizontal
        controlStackView.alignment = .top

        let trackContentView = UIStackView(arrangedSubviews: [
            progressBar, titleLabel, subtitleLabel, playbackStackView, volumeSlider, controlStackView
        ])
        trackContentView.translatesAutoresizingMaskIntoConstraints = false
        trackContentView.spacing = 24
        trackContentView.setCustomSpacing(12, after: titleLabel)
        trackContentView.axis = .vertical

        let vibrancyEffect = UIVibrancyEffect(blurEffect: BackgroundArtworkView.blurEffect)
        let effectView = UIVisualEffectView(effect: vibrancyEffect)
        effectView.layer.masksToBounds = false
        effectView.contentView.layer.masksToBounds = false
        effectView.contentView.addSubview(trackContentView)

        contentView.addArrangedSubview(albumArtwork)
        contentView.addArrangedSubview(effectView)
        contentView.axis = .vertical
        contentView.spacing = 32
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentView)
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate([
            trackContentView.leadingAnchor.constraint(equalTo: effectView.leadingAnchor),
            trackContentView.trailingAnchor.constraint(equalTo: effectView.trailingAnchor),
            trackContentView.topAnchor.constraint(equalTo: effectView.topAnchor),
            trackContentView.bottomAnchor.constraint(equalTo: effectView.bottomAnchor),

            volumeSlider.heightAnchor.constraint(equalToConstant: 32),
            contentView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            contentView.topAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
        ])

        // Configure Button Actions
        fileButton.addAction { [unowned self] in
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
            documentPicker.allowsMultipleSelection = true
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }

        libraryButton.addAction { [unowned self] in
            let musicPicker = MPMediaPickerController(mediaTypes: .anyAudio)
            musicPicker.delegate = self
            musicPicker.allowsPickingMultipleItems = true
            musicPicker.showsCloudItems = true
            self.present(musicPicker, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup default data
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.type = .continuous
        titleLabel.trailingBuffer = 16
        titleLabel.font = .preferredFont(forTextStyle: .title1, design: .rounded)

        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.type = .continuous
        subtitleLabel.trailingBuffer = 16
        subtitleLabel.font = .preferredFont(forTextStyle: .body, design: .rounded)

        // progress bar
        progressBar.delegate = self

        // Setup Button Actions
        playbackButton.addAction { [unowned self] in self.mediaPlayer?.togglePlayback() }
        backwardButton.addAction { [unowned self] in self.mediaPlayer?.previousTrack()  }
        forwardButton.addAction  { [unowned self] in self.mediaPlayer?.nextTrack()      }

        // Setup Double Tap on Album Art
        albumArtwork.addDoubleTapAction { [unowned self] in
            self.mediaPlayer?.togglePlayback()
        }

        // Load the current media queue
        mediaPlayer = SystemMediaPlayer(delegate: self)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            let isLandscape =  UIDevice.current.orientation.isLandscape && UIDevice.current.userInterfaceIdiom == .phone
            self.contentView.axis = isLandscape ? .horizontal : .vertical
            self.contentView.alignment = isLandscape ? .center : .fill
            self.albumArtwork.isRegularWidth = isLandscape
        }, completion: nil)
    }
}

// MARK: NowPlayingProgressBarDelegate
extension PlayerViewController : NowPlayingProgressBarDelegate {
    func progressBarDidChangeValue(
        to time: TimeInterval, progressBar: NowPlayingProgressBar, completion: @escaping () -> Void
    ) {
        mediaPlayer?.seek(to: time, completion: completion)
    }
}

// MARK: MediaPlayerDelegate
extension PlayerViewController : MediaPlayerDelegate {
    func updatePlaybackProgress(elapsedTime: TimeInterval) {
        progressBar.elapsedTime = elapsedTime
    }

    func updateTrackInfo(with trackInfo: TrackInfo, artwork: UIImage) {
        titleLabel.text = trackInfo.title
        subtitleLabel.text = trackInfo.subtitleText
        albumArtwork.image = artwork
        backgroundArtwork.image = artwork
    }

    func updatePlaybackState(isPlaying: Bool, progress: NowPlayingProgress) {
        albumArtwork.isPlaying = isPlaying
        playbackButton.setImage(isPlaying ? ImageAssets.pause : ImageAssets.play, for: .normal)
        progressBar.progress = progress
    }
}

// MARK: MPMediaPickerControllerDelegate
extension PlayerViewController : MPMediaPickerControllerDelegate {
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }

    func mediaPicker(
        _ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection
    ) {
        mediaPlayer = SystemMediaPlayer(queue: mediaItemCollection, delegate: self)
        mediaPicker.dismiss(animated: true) {
            self.mediaPlayer?.play()
        }
    }
}

// MARK: UIDocumentPickerDelegate
extension PlayerViewController : UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import else { return }
        mediaPlayer = FileMediaPlayer(itemUrls: urls, delegate: self)
        controller.dismiss(animated: true) {
            self.mediaPlayer?.play()
        }
    }
}
