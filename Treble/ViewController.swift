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
    
    private let playPauseButton = UIButton(type: .Custom)
    private let nextTrackButton = UIButton(type: .Custom)
    private let prevTrackButton = UIButton(type: .Custom)
    private let musPickerButton = UIButton(type: .Custom)
    private let volumeSlider = UISlider()
    
    private let playImage = UIImage(named: "Play")!.imageWithRenderingMode(.AlwaysTemplate)
    private let pauseImage = UIImage(named: "Pause")!.imageWithRenderingMode(.AlwaysTemplate)
    private let nextImage = UIImage(named: "Next")!.imageWithRenderingMode(.AlwaysTemplate)
    private let prevImage = UIImage(named: "Prev")!.imageWithRenderingMode(.AlwaysTemplate)
    private let musicIcon = UIImage(named: "Music")!.imageWithRenderingMode(.AlwaysTemplate)
    
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var horizontalConstraints: [NSLayoutConstraint] = []
    
    private let albumListViewController = AlbumListTableViewController()
    private var isPresentingAlbumListView: Bool = false
    
    override func loadView() {
        super.loadView()
        let blurEffect = UIBlurEffect(style: .Dark)
        backgroundBlurView = UIVisualEffectView(effect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.backgroundColor = .whiteColor()
        
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 12.0
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .whiteColor()
        
        playPauseButton.setImage(playImage, forState: .Normal)
        playPauseButton.addTarget(self, action: "togglePlayOrPause", forControlEvents: .TouchUpInside)
        
        nextTrackButton.setImage(nextImage, forState: .Normal)
        nextTrackButton.addTarget(self, action: "toggleNextTrack", forControlEvents: .TouchUpInside)
        
        prevTrackButton.setImage(prevImage, forState: .Normal)
        prevTrackButton.addTarget(self, action: "togglePrevTrack", forControlEvents: .TouchUpInside)
        
        musPickerButton.setImage(musicIcon, forState: .Normal)
        musPickerButton.tintColor = .redColor()
        musPickerButton.addTarget(self, action: "presentMusicPicker", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(containerView)
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(backgroundBlurView)
        containerView.addSubview(vibrancyEffectView)
        containerView.addSubview(imageView)
        vibrancyEffectView.contentView.addSubview(songTitleLabel)
        vibrancyEffectView.contentView.addSubview(albumTitleLabel)
        vibrancyEffectView.contentView.addSubview(playPauseButton)
        vibrancyEffectView.contentView.addSubview(prevTrackButton)
        vibrancyEffectView.contentView.addSubview(nextTrackButton)
        containerView.addSubview(volumeSlider)
        imageView.addSubview(musPickerButton)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        songTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        albumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        prevTrackButton.translatesAutoresizingMaskIntoConstraints = false
        nextTrackButton.translatesAutoresizingMaskIntoConstraints = false
        musPickerButton.translatesAutoresizingMaskIntoConstraints = false
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.constrain(.Leading, .Equal, to: self.view, .Leading)
        containerView.constrain(.Trailing, .Equal, to: self.view, .Trailing)
        containerView.constrain(.Top, .Equal, to: self.view, .Top)
        containerView.constrain(.Bottom, .Equal, to: self.view, .Bottom)
        
        backgroundImageView.constrain(.Height, .Equal, to: containerView, .Height)
        backgroundImageView.constrain(.Width, .Equal, to: containerView, .Width)
        backgroundBlurView.constrain(.Height, .Equal, to: containerView, .Height)
        backgroundBlurView.constrain(.Width, .Equal, to: containerView, .Width)
        vibrancyEffectView.constrain(.Height, .Equal, to: containerView, .Height)
        vibrancyEffectView.constrain(.Width, .Equal, to: containerView, .Width)
        
        let buttonSize: CGFloat = 48.0, margin: CGFloat = 24.0
        
        self.verticalConstraints = [
            imageView.constrain(.Height, .Equal, to: containerView, .Width, plus: -24.0, active: false),
            imageView.constrain(.Width, .Equal, to: containerView, .Width, plus: -24.0, active: false),
            imageView.constrain(.CenterX, .Equal, to: containerView, .CenterX, active: false),
            imageView.constrain(.Top, .Equal, to: containerView, .Top, plus: 24.0, active: false),
            songTitleLabel.constrain(.Leading, .Equal, to: containerView, .Leading, active: false),
            songTitleLabel.constrain(.Trailing, .Equal, to: containerView, .Trailing, active: false),
            songTitleLabel.constrain(.Top, .Equal, to: imageView, .Bottom, plus: 32.0, active: false),
        ]
        
        self.horizontalConstraints = [
            imageView.constrain(.Height, .Equal, to: containerView, .Height, plus: -24.0, active: false),
            imageView.constrain(.Width, .Equal, to: containerView, .Height, plus: -24.0, active: false),
            imageView.constrain(.CenterY, .Equal, to: containerView, .CenterY, active: false),
            imageView.constrain(.Leading, .Equal, to: containerView, .Leading, plus: 24.0, active: false),
            songTitleLabel.constrain(.Leading, .Equal, to: imageView, .Trailing, active: false),
            songTitleLabel.constrain(.Trailing, .Equal, to: containerView, .Trailing, active: false),
            songTitleLabel.constrain(.Top, .Equal, to: containerView, .Top, plus: 48.0, active: false),
        ]
        
        musPickerButton.constrain(.Height, .Equal, to: buttonSize)
        musPickerButton.constrain(.Width, .Equal, to: buttonSize)
        musPickerButton.constrain(.Leading, .Equal, to: imageView, .Leading, plus: 8.0)
        musPickerButton.constrain(.Bottom, .Equal, to: imageView, .Bottom, plus: -8.0)
        
        playPauseButton.constrain(.Height, .Equal, to: buttonSize)
        playPauseButton.constrain(.Width, .Equal, to: buttonSize)
        prevTrackButton.constrain(.Height, .Equal, to: buttonSize)
        prevTrackButton.constrain(.Width, .Equal, to: buttonSize)
        nextTrackButton.constrain(.Height, .Equal, to: buttonSize)
        nextTrackButton.constrain(.Width, .Equal, to: buttonSize)
        
        albumTitleLabel.constrain(.Leading, .Equal, to: songTitleLabel, .Leading)
        albumTitleLabel.constrain(.Trailing, .Equal, to: songTitleLabel, .Trailing)
        albumTitleLabel.constrain(.CenterY, .Equal, to: songTitleLabel, .CenterY, plus: 28.0)
        
        playPauseButton.constrain(.Top, .Equal, to: albumTitleLabel, .Top, plus: 48.0)
        playPauseButton.constrain(.CenterX, .Equal, to: songTitleLabel, .CenterX)
        
        nextTrackButton.constrain(.Leading, .Equal, to: playPauseButton, .Trailing, plus: margin)
        nextTrackButton.constrain(.CenterY, .Equal, to: playPauseButton, .CenterY)
        prevTrackButton.constrain(.Trailing, .Equal, to: playPauseButton, .Leading, plus: -margin)
        prevTrackButton.constrain(.CenterY, .Equal, to: playPauseButton, .CenterY)
        
        volumeSlider.constrain(.CenterX, .Equal, to: albumTitleLabel, .CenterX)
        volumeSlider.constrain(.CenterY, .Equal, to: playPauseButton, .CenterY, plus: 64.0)
        volumeSlider.constrain(.Leading, .Equal, to: albumTitleLabel, .Leading, plus: margin)
        volumeSlider.constrain(.Trailing, .Equal, to: albumTitleLabel, .Trailing, plus: -margin)
        
        self.updateConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "showHideAlbumList")
        imageView.addGestureRecognizer(tapGesture)
        
        songTitleLabel.font = .systemFontOfSize(20.0)
        songTitleLabel.textAlignment = .Center
        
        albumTitleLabel.font = .systemFontOfSize(15.0, weight: UIFontWeightThin)
        albumTitleLabel.textAlignment = .Center
        
        volumeSlider.minimumValue = 0.0
        volumeSlider.maximumValue = 1.0
        volumeSlider.value = AVAudioSession.sharedInstance().outputVolume
        volumeSlider.addTarget(self, action: "adjustVolume:", forControlEvents: .ValueChanged)
        
        self.updateCurrentTrack()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCurrentTrack", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: musicPlayer)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePlaybackState", name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: musicPlayer)
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateConstraints()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func showHideAlbumList() {
        if isPresentingAlbumListView {
            UIView.animateWithDuration(0.5, animations: {
                self.albumListViewController.view.alpha = 0.0
                self.imageView.willMoveToSuperview(self.view)
            }) { bool in
                self.isPresentingAlbumListView = false
                self.albumListViewController.removeFromParentViewController()
                self.albumListViewController.view.removeFromSuperview()
                self.albumListViewController.didMoveToParentViewController(nil)
            }
        } else {
            self.addChildViewController(self.albumListViewController)
            self.albumListViewController.view.alpha = 0.0
            self.imageView.addSubview(self.albumListViewController.view)
            self.albumListViewController.view.frame = self.imageView.bounds
            UIView.animateWithDuration(0.5, animations: {
                self.albumListViewController.view.alpha = 1.0
                self.imageView.willMoveToSuperview(self.vibrancyEffectView)
            }) { _ in
                    self.albumListViewController.didMoveToParentViewController(self)
                    self.isPresentingAlbumListView = true
            }
        }
    }
    
    func updateConstraints() {
        if self.view.traitCollection.verticalSizeClass == .Regular {
            horizontalConstraints.forEach   { $0.active = false }
            verticalConstraints.forEach     { $0.active = true }
        } else {
            verticalConstraints.forEach     { $0.active = false }
            horizontalConstraints.forEach   { $0.active = true }
        }
    }
    
    func updateCurrentTrack() {
        guard let songItem = musicPlayer.nowPlayingItem else { return }
        
        self.updatePlaybackState()
        self.albumListViewController.currentTrack = songItem
        self.songTitleLabel.text = songItem.valueForProperty(MPMediaItemPropertyTitle) as? String
        let albumTitle = songItem.valueForProperty(MPMediaItemPropertyAlbumTitle) as! String
        let artistTitle = songItem.valueForProperty(MPMediaItemPropertyArtist) as! String
        self.albumTitleLabel.text = "\(artistTitle) • \(albumTitle)"

        if let artwork = songItem.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork, let image = artwork.imageWithSize(self.view.frame.size) {
            let isDarkColor = image.averageColor.isDarkColor
            let blurEffect = isDarkColor ? UIBlurEffect(style: .Light) : UIBlurEffect(style: .Dark)
            UIView.animateWithDuration(0.8, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.imageView.image = image
                self.backgroundImageView.image = image
                self.backgroundBlurView.effect = blurEffect
                self.vibrancyEffectView.effect = UIVibrancyEffect(forBlurEffect: blurEffect)
                self.volumeSlider.tintColor = image.averageColor
                }) { bool in
                    self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    func togglePlayOrPause() {
        guard let _ = musicPlayer.nowPlayingItem else { return }
        switch musicPlayer.playbackState {
        case .Playing: musicPlayer.pause()
        case .Paused:  musicPlayer.play()
        default:       break
        }
        self.updatePlaybackState()
    }
    
    func updatePlaybackState() {
        switch musicPlayer.playbackState {
        case .Playing: playPauseButton.setImage(pauseImage, forState: .Normal)
        case .Paused:  playPauseButton.setImage(playImage,  forState: .Normal)
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
        let musicPickerViewController = MPMediaPickerController(mediaTypes: .Music)
        musicPickerViewController.delegate = self
        musicPickerViewController.allowsPickingMultipleItems = true
        self.presentViewController(musicPickerViewController, animated: true, completion: nil)
    }
    
    func adjustVolume(slider: UISlider) {
        let currentVolume = slider.value
        for subview in MPVolumeView().subviews {
            guard let slider = subview as? UISlider else { continue }
            slider.setValue(currentVolume, animated: true)
            slider.sendActionsForControlEvents(.TouchUpInside)
        }
    }

}

extension ViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.musicPlayer.setQueueWithItemCollection(mediaItemCollection)
        mediaPicker.dismissViewControllerAnimated(true) {
            self.musicPlayer.play()
            self.updateCurrentTrack()
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

private extension UIView {
    
    func constrain(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to otherView: UIView, _ otherAttribute: NSLayoutAttribute, times multiplier: CGFloat = 1, plus constant: CGFloat = 0, atPriority priority: UILayoutPriority = UILayoutPriorityRequired, identifier: String? = nil, active: Bool = true) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: otherView, attribute: otherAttribute, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = active
        return constraint
    }
    
    func constrain(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to constant: CGFloat, atPriority priority: UILayoutPriority = UILayoutPriorityRequired, identifier: String? = nil) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: constant)
        constraint.priority = priority
        constraint.identifier = identifier
        constraint.active = true
        return constraint
    }
}


