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
    private let musQueueButton  = UIButton(type: .custom)
    
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
        vibrancyEffectView.contentView.addSubview(musQueueButton)
        
        let views = [containerView, backgroundImageView, backgroundBlurView, vibrancyEffectView, imageView, musPickerButton, volumeSlider, songTitleLabel, albumTitleLabel, playPauseButton, prevTrackButton, nextTrackButton, musQueueButton]
            
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        containerView.constrain(to: self.view)
        backgroundBlurView.constrain(to: containerView)
        backgroundImageView.constrain(to: containerView)
        vibrancyEffectView.constrain(to: containerView)
        
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
        
        musPickerButton.constrainSize(to: 36)
        musQueueButton.constrainSize (to: 36)
        playPauseButton.constrainSize(to: buttonSize)
        prevTrackButton.constrainSize(to: buttonSize)
        nextTrackButton.constrainSize(to: buttonSize)
        
        
        musPickerButton.constrain(.bottom, .equal, to: volumeSlider, .top, plus: -10)
        musPickerButton.constrain(.left, .equal, to: volumeSlider, .left)
        
        musQueueButton.constrain(.top, .equal, to: musPickerButton, .top)
        musQueueButton.constrain(.right, .equal, to: volumeSlider, .right)
        
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
        
        playPauseButton.setBackgroundImage(#imageLiteral(resourceName: "Play"), for: UIControlState())
        playPauseButton.addTarget(self, action: #selector(ViewController.togglePlayOrPause), for: .touchUpInside)
        
        nextTrackButton.setBackgroundImage(#imageLiteral(resourceName: "Next"), for: UIControlState())
        nextTrackButton.addTarget(self, action: #selector(ViewController.toggleNextTrack), for: .touchUpInside)
        
        prevTrackButton.setBackgroundImage(#imageLiteral(resourceName: "Prev"), for: UIControlState())
        prevTrackButton.addTarget(self, action: #selector(ViewController.togglePrevTrack), for: .touchUpInside)
        
        musPickerButton.setBackgroundImage(#imageLiteral(resourceName: "Music"), for: UIControlState())
        musPickerButton.addTarget(self, action: #selector(ViewController.presentMusicPicker), for: .touchUpInside)
        
        musQueueButton.setBackgroundImage(#imageLiteral(resourceName: "List"), for: UIControlState())
        musQueueButton.addTarget(self, action: #selector(ViewController.presentMusicQueueList), for: .touchUpInside)
        
        songTitleLabel.font = .systemFont(ofSize: 20.0)
        songTitleLabel.textAlignment = .center
        
        albumTitleLabel.font = .systemFont(ofSize: 15.0, weight: UIFontWeightThin)
        albumTitleLabel.textAlignment = .center
        
        musicQueueViewController.modalPresentationStyle = .custom
        musicQueueViewController.transitioningDelegate = musicQueueViewController
        
        self.updateCurrentTrack()
        
        NotificationCenter.default().addObserver(self, selector: #selector(ViewController.updateCurrentTrack), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        NotificationCenter.default().addObserver(self, selector: #selector(ViewController.updatePlaybackState), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
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
    
    func presentMusicQueueList() {
        self.present(musicQueueViewController, animated: true, completion: nil)
    }

    func updateCurrentTrack() {
        guard let songItem = musicPlayer.nowPlayingItem else { return }
        
        self.updatePlaybackState()
        self.musicQueueViewController.currentTrack = songItem
        self.songTitleLabel.text = songItem.title
        self.albumTitleLabel.text = "\(songItem.artist!) • \(songItem.albumTitle!)"

        guard let artwork = songItem.artwork, let image = artwork.image(at: self.view.frame.size) else { return }
        let isDarkColor = image.averageColor.isDarkColor
        let blurEffect = isDarkColor ? UIBlurEffect(style: .light) : UIBlurEffect(style: .dark)
        UIView.animate(withDuration: 0.8, animations: {
            self.imageView.image = image
            self.backgroundImageView.image = image
            self.backgroundBlurView.effect = blurEffect
            self.vibrancyEffectView.effect = UIVibrancyEffect(blurEffect: blurEffect)
            self.volumeSlider.tintColor = image.averageColor
        }) { bool in
            self.setNeedsStatusBarAppearanceUpdate()
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
        case .playing: playPauseButton.setBackgroundImage(#imageLiteral(resourceName: "Pause"), for: UIControlState())
        case .paused:  playPauseButton.setBackgroundImage(#imageLiteral(resourceName: "Play"),  for: UIControlState())
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
        let musicPickerViewController = MPMediaPickerController(mediaTypes: .anyAudio)
        musicPickerViewController.delegate = self
        musicPickerViewController.allowsPickingMultipleItems = true
        musicPickerViewController.showsCloudItems = true
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
