//
//  ViewController.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-04.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let songTitleLabel = UILabel()
    private let albumTitleLabel = UILabel()
    
    private let backgroundImageView = UIImageView()
    private var backgroundBlurView: UIVisualEffectView!
    private var vibrancyEffectView: UIVisualEffectView!
    
    private let playPauseButton = UIButton(type: .custom)
    private let nextTrackButton = UIButton(type: .custom)
    private let prevTrackButton = UIButton(type: .custom)
    private let musPickerButton = UIButton(type: .custom)
    private let volumeSlider: UISlider = {
        return MPVolumeView().subviews.filter { $0 is UISlider }.map { $0 as! UISlider }.first!
    }()
    
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var horizontalConstraints: [NSLayoutConstraint] = []
    
    private let musicQueueViewController = MusicQueueViewController()
    
    override func loadView() {
        super.loadView()
        
        let blurEffect = UIBlurEffect(style: .dark)
        backgroundBlurView = UIVisualEffectView(effect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.backgroundColor = .white()
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12.0
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .white()
        
        musPickerButton.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        musPickerButton.layer.masksToBounds = true
        
        
        self.view.addSubview(containerView) // add one so I can use constraints
        containerView.addSubview(backgroundImageView) // background image that is blurred
        containerView.addSubview(backgroundBlurView) // blur view that blurs the image
        containerView.addSubview(vibrancyEffectView) // the vibrancy view where everything else is added
        containerView.addSubview(volumeSlider) // add volume slider here so that it doesn't have the vibrancy effect
        containerView.addSubview(imageView)
        
        vibrancyEffectView.contentView.addSubview(musPickerButton)
        vibrancyEffectView.contentView.addSubview(songTitleLabel)
        vibrancyEffectView.contentView.addSubview(albumTitleLabel)
        vibrancyEffectView.contentView.addSubview(playPauseButton)
        vibrancyEffectView.contentView.addSubview(prevTrackButton)
        vibrancyEffectView.contentView.addSubview(nextTrackButton)
        
        [containerView, backgroundImageView, backgroundBlurView, vibrancyEffectView, imageView, musPickerButton, volumeSlider, songTitleLabel, albumTitleLabel, playPauseButton, prevTrackButton, nextTrackButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        containerView.constrain(to: self.view)
        backgroundBlurView.constrain(to: containerView)
        backgroundImageView.constrain(to: containerView)
        vibrancyEffectView.constrain(to: containerView)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: self.view.frame.width))
        let hole = CGRect(x: 0.0, y: self.view.frame.width-72.0, width: 48.0, height: 48.0)
        let buttonFrame = CGRect(x: 0.0, y: 0.0, width: 48.0, height: 48.0)
        
        self.imageView.layer.mask = {
            let mask = CAShapeLayer()
            let path = UIBezierPath(rect: rect)
            path.append(UIBezierPath(rect: hole).reversing())
            mask.path = path.cgPath
            return mask
        }()
        
        
        musPickerButton.layer.mask = {
            let path = UIBezierPath(roundedRect: buttonFrame, byRoundingCorners: .bottomLeft, cornerRadii: CGSize(width: 12, height: 12))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            return maskLayer
        }()
        
        self.verticalConstraints = [
            imageView.constrain(.height, .equal, to: containerView, .width, plus: -24.0, active: false),
            imageView.constrain(.width,  .equal, to: containerView, .width, plus: -24.0, active: false),
            imageView.constrain(.top, .equal, to: containerView, .top, plus: 24.0, active: false),
            imageView.constrain(.centerX, .equal, to: containerView, .centerX, active: false),
            songTitleLabel.constrain(.leading, .equal, to: imageView, .leading, active: false),
            songTitleLabel.constrain(.trailing, .equal, to: imageView, .trailing, active: false),
            songTitleLabel.constrain(.top, .equal, to: imageView, .bottom, plus: 28.0, active: false)
        ]
        
        self.horizontalConstraints = [
            imageView.constrain(.height, .equal, to: containerView, .height, plus: -24.0, active: false),
            imageView.constrain(.width,  .equal, to: containerView, .height, plus: -24.0, active: false),
            imageView.constrain(.leading, .equal, to: containerView, .leading, plus: 24.0, active: false),
            imageView.constrain(.centerY, .equal, to: containerView, .centerY, active: false),
            songTitleLabel.constrain(.leading, .equal, to: imageView, .trailing, plus: 24.0, active: false),
            songTitleLabel.constrain(.trailing, .equal, to: containerView, .trailing, plus: -24.0, active: false),
            songTitleLabel.constrain(.top, .equal, to: containerView, .top, plus: 64.0, active: false)
        ]
        
        let buttonSize: CGFloat = 48.0, margin: CGFloat = 24.0
        
        musPickerButton.constrainSize(to: buttonSize)
        playPauseButton.constrainSize(to: buttonSize)
        prevTrackButton.constrainSize(to: buttonSize)
        nextTrackButton.constrainSize(to: buttonSize)
        
        musPickerButton.constrain(.bottom, .equal, to: imageView, .bottom)
        musPickerButton.constrain(.left, .equal, to: imageView, .left)
        
        albumTitleLabel.constrain(.leading,  .equal, to: songTitleLabel, .leading)
        albumTitleLabel.constrain(.trailing, .equal, to: songTitleLabel, .trailing)
        albumTitleLabel.constrain(.top, .equal, to: songTitleLabel, .bottom, plus: 16.0)
        
        playPauseButton.constrain(.top, .equal, to: albumTitleLabel, .bottom, plus: margin)
        playPauseButton.constrain(.centerX, .equal, to: songTitleLabel, .centerX)
        
        nextTrackButton.constrain(.leading, .equal, to: playPauseButton, .trailing, plus: margin)
        nextTrackButton.constrain(.centerY, .equal, to: playPauseButton, .centerY)
        prevTrackButton.constrain(.trailing, .equal, to: playPauseButton, .leading, plus: -margin)
        prevTrackButton.constrain(.centerY, .equal, to: playPauseButton, .centerY)
        
        volumeSlider.constrain(.leading, .equal, to: albumTitleLabel, .leading, plus: margin)
        volumeSlider.constrain(.trailing, .equal, to: albumTitleLabel, .trailing, plus: -margin)
        volumeSlider.constrain(.top, .equal, to: playPauseButton, .bottom, plus: 64.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGestureRecognizerFired(_:)))
        tapGesture.cancelsTouchesInView = false
        self.imageView.addGestureRecognizer(tapGesture)
        
        playPauseButton.setImage(UIImage.Asset.Play.image, for: UIControlState())
        playPauseButton.addTarget(self, action: #selector(ViewController.togglePlayOrPause), for: .touchUpInside)
        
        nextTrackButton.setImage(UIImage.Asset.Next.image, for: UIControlState())
        nextTrackButton.addTarget(self, action: #selector(ViewController.toggleNextTrack), for: .touchUpInside)
        
        prevTrackButton.setImage(UIImage.Asset.Prev.image, for: UIControlState())
        prevTrackButton.addTarget(self, action: #selector(ViewController.togglePrevTrack), for: .touchUpInside)
        
        musPickerButton.setImage(UIImage.Asset.Music.image, for: UIControlState())
        
        songTitleLabel.font = .systemFont(ofSize: 20.0)
        songTitleLabel.textAlignment = .center
        
        albumTitleLabel.font = .systemFont(ofSize: 15.0, weight: UIFontWeightThin)
        albumTitleLabel.textAlignment = .center
        
        self.updateCurrentTrack()
        
        NotificationCenter.default().addObserver(self, selector: #selector(ViewController.updateCurrentTrack), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        NotificationCenter.default().addObserver(self, selector: #selector(ViewController.updatePlaybackState), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateViewConstraints()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func updateViewConstraints() {
        if self.view.traitCollection.verticalSizeClass == .regular {
            horizontalConstraints.forEach   { $0.isActive = false }
            verticalConstraints.forEach     { $0.isActive = true }
        } else {
            verticalConstraints.forEach     { $0.isActive = false }
            horizontalConstraints.forEach   { $0.isActive = true }
        }
        super.updateViewConstraints()
    }
    
    func tapGestureRecognizerFired(_ gestureRecognizer: UITapGestureRecognizer) {
        
        let locationInView = gestureRecognizer.location(in: self.view)
        
        guard !musPickerButton.frame.contains(locationInView) else {
            self.presentMusicPicker() // tapped on music picker button, present that instead
            return
        }
        
        if self.childViewControllers.isEmpty { // show albumList view
            self.addChildViewController(self.musicQueueViewController)
            self.musicQueueViewController.view.alpha = 0.0
            self.imageView.addSubview(self.musicQueueViewController.view)
            self.musicQueueViewController.view.frame = self.imageView.bounds
            UIView.animate(withDuration: 0.5, animations: {
                self.musicQueueViewController.view.alpha = 1.0
                self.imageView.willMove(toSuperview: self.vibrancyEffectView)
            }) { _ in
                self.musicQueueViewController.didMove(toParentViewController: self)
            }
        } else  { // hide albumList view
            UIView.animate(withDuration: 0.5, animations: {
                self.musicQueueViewController.view.alpha = 0.0
                self.imageView.willMove(toSuperview: self.view)
            }) { bool in
                self.musicQueueViewController.removeFromParentViewController()
                self.musicQueueViewController.view.removeFromSuperview()
                self.musicQueueViewController.didMove(toParentViewController: nil)
            }
        }

    }

    func updateCurrentTrack() {
        guard let songItem = musicPlayer.nowPlayingItem else { return }
        
        self.updatePlaybackState()
        self.musicQueueViewController.currentTrack = songItem
        self.songTitleLabel.text = songItem.value(forProperty: MPMediaItemPropertyTitle) as? String
        let albumTitle = songItem.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
        let artistTitle = songItem.value(forProperty: MPMediaItemPropertyArtist) as! String
        self.albumTitleLabel.text = "\(artistTitle) • \(albumTitle)"

        if let artwork = songItem.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork, let image = artwork.image(at: self.view.frame.size) {
            let isDarkColor = image.averageColor.isDarkColor
            let blurEffect = isDarkColor ? UIBlurEffect(style: .light) : UIBlurEffect(style: .dark)
            UIView.animate(withDuration: 0.8, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.imageView.image = image
                self.backgroundImageView.image = image
                self.backgroundBlurView.effect = blurEffect
                self.vibrancyEffectView.effect = UIVibrancyEffect(blurEffect: blurEffect)
                self.volumeSlider.tintColor = image.averageColor
                }) { bool in
                    self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    func togglePlayOrPause() {
        guard let _ = musicPlayer.nowPlayingItem else { return }
        switch musicPlayer.playbackState {
        case .playing: musicPlayer.pause()
        case .paused:  musicPlayer.play()
        default:       break
        }
        self.updatePlaybackState()
    }
    
    func updatePlaybackState() {
        switch musicPlayer.playbackState {
        case .playing: playPauseButton.setImage(UIImage.Asset.Pause.image, for: UIControlState())
        case .paused:  playPauseButton.setImage(UIImage.Asset.Play.image,  for: UIControlState())
        default:       break
        }
    }
    
    func toggleNextTrack() {
        guard let _ = musicPlayer.nowPlayingItem else { return }
        musicPlayer.skipToNextItem()
    }
    
    func togglePrevTrack() {
        guard let _ = musicPlayer.nowPlayingItem else { return }
        if musicPlayer.currentPlaybackTime < 5.0 {
            musicPlayer.skipToPreviousItem()
        } else {
            musicPlayer.skipToBeginning()
        }
    }
    
    func presentMusicPicker() {
        let musicPickerViewController = MPMediaPickerController(mediaTypes: .music)
        musicPickerViewController.delegate = self
        musicPickerViewController.allowsPickingMultipleItems = true
        self.present(musicPickerViewController, animated: true, completion: nil)
    }

}

extension ViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.musicPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true) {
            self.musicPlayer.play()
            self.updateCurrentTrack()
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
}
