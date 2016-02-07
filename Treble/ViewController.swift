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
    
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var horizontalConstraints: [NSLayoutConstraint] = []
    
    private let albumListViewController = AlbumListTableViewController()
    
    override func loadView() {
        super.loadView()
        
        let blurEffect = UIBlurEffect(style: .Dark)
        backgroundBlurView = UIVisualEffectView(effect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.backgroundColor = .whiteColor()
        
        imageView.userInteractionEnabled = true
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 12.0
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .whiteColor()
        musPickerButton.tintColor = .redColor()
        
        self.view.addSubview(containerView) // add one so I can use constraints
        containerView.addSubview(backgroundImageView) // background image that is blurred
        containerView.addSubview(backgroundBlurView) // blur view that blurs the image
        containerView.addSubview(vibrancyEffectView) // the vibrancy view where everything else is added
        containerView.addSubview(volumeSlider) // add volume slider here so that it doesn't have the vibrancy effect
        containerView.addSubview(imageView)
        containerView.addSubview(musPickerButton)
        
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
        
        self.verticalConstraints = [
            imageView.constrain(.Height, .Equal, to: containerView, .Width, plus: -24.0, active: false),
            imageView.constrain(.Width,  .Equal, to: containerView, .Width, plus: -24.0, active: false),
            imageView.constrain(.Top, .Equal, to: containerView, .Top, plus: 24.0, active: false),
            imageView.constrain(.CenterX, .Equal, to: containerView, .CenterX, active: false),
            songTitleLabel.constrain(.Leading, .Equal, to: imageView, .Leading, active: false),
            songTitleLabel.constrain(.Trailing, .Equal, to: imageView, .Trailing, active: false),
            songTitleLabel.constrain(.Top, .Equal, to: imageView, .Bottom, plus: 28.0, active: false)
        ]
        
        self.horizontalConstraints = [
            imageView.constrain(.Height, .Equal, to: containerView, .Height, plus: -24.0, active: false),
            imageView.constrain(.Width,  .Equal, to: containerView, .Height, plus: -24.0, active: false),
            imageView.constrain(.Leading, .Equal, to: containerView, .Leading, plus: 24.0, active: false),
            imageView.constrain(.CenterY, .Equal, to: containerView, .CenterY, active: false),
            songTitleLabel.constrain(.Leading, .Equal, to: imageView, .Trailing, plus: 24.0, active: false),
            songTitleLabel.constrain(.Trailing, .Equal, to: containerView, .Trailing, plus: -24.0, atPriority: 400, active: false),
            songTitleLabel.constrain(.Top, .Equal, to: containerView, .Top, plus: 64.0, active: false)
        ]
        
        let buttonSize: CGFloat = 48.0, margin: CGFloat = 24.0
        
        musPickerButton.constrainSize(to: buttonSize)
        playPauseButton.constrainSize(to: buttonSize)
        prevTrackButton.constrainSize(to: buttonSize)
        nextTrackButton.constrainSize(to: buttonSize)
        
        musPickerButton.constrain(.Bottom, .Equal, to: imageView, .Bottom)
        musPickerButton.constrain(.Left, .Equal, to: imageView, .Left)
        
        albumTitleLabel.constrain(.Leading,  .Equal, to: songTitleLabel, .Leading)
        albumTitleLabel.constrain(.Trailing, .Equal, to: songTitleLabel, .Trailing)
        albumTitleLabel.constrain(.Top, .Equal, to: songTitleLabel, .Bottom, plus: 16.0)
        
        playPauseButton.constrain(.Top, .Equal, to: albumTitleLabel, .Bottom, plus: margin)
        playPauseButton.constrain(.CenterX, .Equal, to: songTitleLabel, .CenterX)
        
        nextTrackButton.constrain(.Leading, .Equal, to: playPauseButton, .Trailing, plus: margin)
        nextTrackButton.constrain(.CenterY, .Equal, to: playPauseButton, .CenterY)
        prevTrackButton.constrain(.Trailing, .Equal, to: playPauseButton, .Leading, plus: -margin)
        prevTrackButton.constrain(.CenterY, .Equal, to: playPauseButton, .CenterY)
        
        volumeSlider.constrain(.Leading, .Equal, to: albumTitleLabel, .Leading, plus: margin)
        volumeSlider.constrain(.Trailing, .Equal, to: albumTitleLabel, .Trailing, plus: -margin)
        volumeSlider.constrain(.Top, .Equal, to: playPauseButton, .Bottom, plus: 64.0)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGestureRecognizerFired:")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        playPauseButton.setImage(UIImage.Asset.Play.image, forState: .Normal)
        playPauseButton.addTarget(self, action: "togglePlayOrPause", forControlEvents: .TouchUpInside)
        
        nextTrackButton.setImage(UIImage.Asset.Next.image, forState: .Normal)
        nextTrackButton.addTarget(self, action: "toggleNextTrack", forControlEvents: .TouchUpInside)
        
        prevTrackButton.setImage(UIImage.Asset.Prev.image, forState: .Normal)
        prevTrackButton.addTarget(self, action: "togglePrevTrack", forControlEvents: .TouchUpInside)
        
        musPickerButton.setImage(UIImage.Asset.Music.image, forState: .Normal)
        musPickerButton.addTarget(self, action: "presentMusicPicker", forControlEvents: .TouchUpInside)
        
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
        self.updateViewConstraints()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func updateViewConstraints() {
        if self.view.traitCollection.verticalSizeClass == .Regular {
            horizontalConstraints.forEach   { $0.active = false }
            verticalConstraints.forEach     { $0.active = true }
        } else {
            verticalConstraints.forEach     { $0.active = false }
            horizontalConstraints.forEach   { $0.active = true }
        }
        super.updateViewConstraints()
    }
    
    func tapGestureRecognizerFired(gestureRecognizer: UITapGestureRecognizer) {
        let locationInView = gestureRecognizer.locationInView(self.view)
        if imageView.frame.contains(locationInView) && self.childViewControllers.isEmpty {
            // show albumList view
            self.addChildViewController(self.albumListViewController)
            self.albumListViewController.view.alpha = 0.0
            self.imageView.addSubview(self.albumListViewController.view)
            self.albumListViewController.view.frame = self.imageView.bounds
            UIView.animateWithDuration(0.5, animations: {
                self.albumListViewController.view.alpha = 1.0
                self.imageView.willMoveToSuperview(self.vibrancyEffectView)
            }) { _ in
                self.albumListViewController.didMoveToParentViewController(self)
            }
        } else if !imageView.frame.contains(locationInView) && !self.childViewControllers.isEmpty {
            // hide albumList view
            UIView.animateWithDuration(0.5, animations: {
                self.albumListViewController.view.alpha = 0.0
                self.imageView.willMoveToSuperview(self.view)
            }) { bool in
                self.albumListViewController.removeFromParentViewController()
                self.albumListViewController.view.removeFromSuperview()
                self.albumListViewController.didMoveToParentViewController(nil)
            }

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
        case .Playing: playPauseButton.setImage(UIImage.Asset.Pause.image, forState: .Normal)
        case .Paused:  playPauseButton.setImage(UIImage.Asset.Play.image,  forState: .Normal)
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
