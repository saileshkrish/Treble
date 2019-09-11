//
//  PlayerViewController.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-09.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerViewController: UIViewController {
    private let mediaController = MediaController()

    private var playbackButton: UIButton!
    private var listButton: UIButton!
    private let backgroundImageView = UIImageView()
    private let albumImageView = UIImageView()
    private let songLabel = MarqueeLabel(frame: .zero, duration: 8, fadeLength: 8)
    private let albumLabel = MarqueeLabel(frame: .zero, duration: 8, fadeLength: 8)
    private var contentView: UIStackView!

    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        view.tintColor = .white
        
        // 1. setup the background
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let backgroundView = UIVisualEffectView(effect: blurEffect)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.backgroundColor = .secondarySystemBackground

        // 2. now create the album art image view
        albumImageView.isUserInteractionEnabled = true
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.layer.cornerRadius = 13
        albumImageView.layer.masksToBounds = true
        albumImageView.backgroundColor = .systemFill

        let imageContentView = UIView()
        imageContentView.backgroundColor = .clear
        imageContentView.addSubviewAndConstrain(toMarginsGuide: true, albumImageView)

        // 3. setup the buttons and controls
        playbackButton = createButton(
            systemName: "play.fill", action: #selector(didTapPlaybackButton), style: .largeTitle)
        let previousButton = createButton(
            systemName: "backward.fill", action: #selector(didTapPreviousButton), style: .title2)
        let nextButton = createButton(
            systemName: "forward.fill", action: #selector(didTapNextButton), style: .title2)
        let libraryButton = createButton(
            systemName: "music.note", action: #selector(didTapLibraryButton), style: .body)
        let cloudButton = createButton(
            systemName: "icloud.fill", action: #selector(didTapCloudButton), style: .body)
        listButton = createButton(
            systemName: "list.dash", action: #selector(didTapListButton), style: .body)

        let routePickerView = AVRoutePickerView()
        let volumeSlider = MPVolumeView()

        // 4. create the stack views
        let controlContentView = UIStackView(arrangedSubviews: [
            previousButton, playbackButton, nextButton
        ])
        controlContentView.distribution = .fillEqually
        controlContentView.alignment = .center
        controlContentView.axis = .horizontal

        let optionsContentView = UIStackView(arrangedSubviews: [
            listButton, libraryButton, cloudButton, routePickerView
        ])
        optionsContentView.distribution = .equalCentering
        optionsContentView.alignment = .fill
        optionsContentView.axis = .horizontal

        let innerContentView = UIStackView(arrangedSubviews: [
            songLabel,
            albumLabel,
            controlContentView,
            optionsContentView,
            volumeSlider
        ])
        innerContentView.setCustomSpacing(8, after: songLabel)
        innerContentView.axis = .vertical
        innerContentView.spacing = 24

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.layer.masksToBounds = false
        vibrancyView.contentView.layer.masksToBounds = false
        vibrancyView.contentView.addSubviewAndConstrain(innerContentView)

        contentView = UIStackView(arrangedSubviews: [imageContentView, vibrancyView])
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 32

        // the background image that is blurred
        view.addSubviewAndConstrain(backgroundImageView)
        // the blur view for the background image
        view.addSubviewAndConstrain(backgroundView)
        // the content view for the controls and album art
        view.addSubview(contentView)

        // 5. setup the other constraints
        let imageConstraint = imageContentView.widthAnchor.constraint(equalTo: imageContentView.heightAnchor)
        imageConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            imageConstraint,
            volumeSlider.heightAnchor.constraint(equalToConstant: 44),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            contentView.topAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        songLabel.text = "Welcome to Treble"
        songLabel.textAlignment = .center
        songLabel.type = .continuous
        songLabel.trailingBuffer = 16
        songLabel.font = roundedFont(for: .title1)

        albumLabel.text = "Play from your Apple Music Library, or from your iCloud Drive."
        albumLabel.textAlignment = .center
        albumLabel.type = .continuous
        albumLabel.trailingBuffer = 16
        albumLabel.font = roundedFont(for: .body)

        mediaController.mediaPlayer = SystemMediaPlayer(delegate: self)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            let isLandscape = UIDevice.current.orientation.isLandscape
            self.contentView.axis = isLandscape ? .horizontal : .vertical
        }, completion: nil)
    }

    @objc private func didTapPlaybackButton() {
        mediaController.togglePlayback()
    }

    @objc private func didTapPreviousButton() {
        mediaController.previousTrack()
    }

    @objc private func didTapNextButton() {
        mediaController.nextTrack()
    }

    @objc private func didTapListButton() {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        present(viewController, animated: true, completion: nil)
    }

    @objc private func didTapLibraryButton() {
        let picker = MPMediaPickerController(mediaTypes: .anyAudio)
        picker.delegate = self
        picker.allowsPickingMultipleItems = true
        picker.showsCloudItems = true
        present(picker, animated: true, completion: nil)
    }

    @objc private func didTapCloudButton() {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    // MARK: Helper methods

    private func createButton(systemName: String, action: Selector, style: UIFont.TextStyle) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(textStyle: style), forImageIn: .normal)
        return button
    }

    private func roundedFont(for style: UIFont.TextStyle) -> UIFont {
        let originalDescriptor = UIFont.preferredFont(forTextStyle: style).fontDescriptor
        let descriptor = originalDescriptor.withDesign(.rounded) ?? originalDescriptor
        return UIFont(descriptor: descriptor, size: descriptor.pointSize)
    }
}

extension PlayerViewController : MPMediaPickerControllerDelegate {

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }

    func mediaPicker(
        _ mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection)
    {
        mediaController.mediaPlayer = SystemMediaPlayer(queue: mediaItemCollection, delegate: self)
        listButton.isHidden = false
        mediaPicker.dismiss(animated: true) {
            self.mediaController.play()
        }
    }

}

extension PlayerViewController : UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard controller.documentPickerMode == .import else { return }
        let audioItem = AVPlayerItem(url: UIDocument(fileURL: url).presentedItemURL!)
        let player = AVPlayer(playerItem: audioItem)
        let url = url.deletingPathExtension()
        let fullName = url.lastPathComponent
        var fileName: String
        var artistName: String?
        if fullName.components(separatedBy: "-").count == 2 {
            let components = fullName.components(separatedBy: "-")
            artistName = components[0]
            fileName = components[1]
        } else {
            fileName = fullName
        }
        mediaController.mediaPlayer = FileMediaPlayer(
            player: player, fileName: fileName, artistName: artistName, delegate: self)
        listButton.isHidden = true
        controller.dismiss(animated: true) {
            self.mediaController.play()
        }
    }
}

extension PlayerViewController : MediaPlayerDelegate {

    func updatePlaybackState(isPlaying: Bool) {
        let image = isPlaying
            ? UIImage(systemName: "pause.fill")
            : UIImage(systemName: "play.fill")
        playbackButton.setImage(image, for: .normal)
        // update the constraints for the album art
        guard let contentView = albumImageView.superview else { return }
        let padding: CGFloat = !isPlaying ? 12 : 0
        let insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        contentView.layoutMargins = insets
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.8,
            options: .beginFromCurrentState,
            animations: contentView.layoutIfNeeded,
            completion: nil)
    }

    func updateTrackInfo(with trackInfo: TrackInfo) {
        albumImageView.image = trackInfo.albumArtwork
        backgroundImageView.image = trackInfo.albumArtwork
        songLabel.text = trackInfo.songTitle
        albumLabel.text = [trackInfo.albumTitle, trackInfo.artistName]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

}
