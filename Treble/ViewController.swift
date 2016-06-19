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
    private var backgroundView: UIVisualEffectView!
    private var vibrancyEffectView: UIVisualEffectView!
    
    private let playPauseButton = UIButton(type: .custom)
    private let nextTrackButton = UIButton(type: .custom)
    private let prevTrackButton = UIButton(type: .custom)
    private let musPickerButton = UIButton(type: .custom)
    private let trackListButton = UIButton(type: .custom)
    
    private let volumeSlider: UISlider = {
        return MPVolumeView().subviews.filter { $0 is UISlider }.map { $0 as! UISlider }.first!
    }()
    
    private var verticalConstraints: [NSLayoutConstraint] = []
    private var horizontalConstraints: [NSLayoutConstraint] = []
    private var containerConstraints: (top: NSLayoutConstraint, bottom: NSLayoutConstraint)!
    
    private lazy var trackListView: TrackListViewController = TrackListViewController()
    
    override func loadView() {
        super.loadView()
        
        let blurEffect = UIBlurEffect(style: .dark)
        backgroundView = UIVisualEffectView(effect: blurEffect)
        vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.backgroundColor = .white()
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12.0
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .white()
        
        self.view.addSubview(backgroundImageView) // background image that is blurred
        self.view.addSubview(backgroundView) // blur view that blurs the image
        self.view.addSubview(containerView) // add one so I can use constraints
        containerView.addSubview(vibrancyEffectView) // the vibrancy view where everything else is added
        containerView.addSubview(volumeSlider) // add volume slider here so that it doesn't have the vibrancy effect
        containerView.addSubview(imageView)
        
        vibrancyEffectView.contentView.addSubview(musPickerButton)
        vibrancyEffectView.contentView.addSubview(songTitleLabel)
        vibrancyEffectView.contentView.addSubview(albumTitleLabel)
        vibrancyEffectView.contentView.addSubview(playPauseButton)
        vibrancyEffectView.contentView.addSubview(prevTrackButton)
        vibrancyEffectView.contentView.addSubview(nextTrackButton)
        vibrancyEffectView.contentView.addSubview(trackListButton)
        
        let views = [containerView, backgroundImageView, backgroundView, vibrancyEffectView, imageView, musPickerButton, volumeSlider, songTitleLabel, albumTitleLabel, playPauseButton, prevTrackButton, nextTrackButton, trackListButton]
            
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        backgroundView.constrain(to: self.view)
        backgroundImageView.constrain(to: self.view)
        vibrancyEffectView.constrain(to: self.view)
        
        containerView.constrain(.leading, .equal, to: self.view, .leading)
        containerView.constrain(.trailing, .equal, to: self.view, .trailing)
        self.containerConstraints = (top:    containerView.constrain(.top, .equal, to: self.view, .top),
                                     bottom: containerView.constrain(.bottom, .equal, to: self.view, .bottom))
        
        self.verticalConstraints = [
            imageView.constrain(.top, .equal, to: containerView, .top, active: false),
            imageView.constrain(.width, .equal, to: containerView, .width, times: 0.85, active: false),
            imageView.constrain(.height, .equal, to: imageView, .width, active: false),
            imageView.constrain(.centerX, .equal, to: containerView, .centerX, active: false),
            songTitleLabel.constrain(.leading, .equal, to: imageView, .leading, active: false),
            songTitleLabel.constrain(.trailing, .equal, to: imageView, .trailing, active: false),
            songTitleLabel.constrain(.top, .equal, to: imageView, .bottom, plus: 28.0, active: false),
            playPauseButton.constrain(.centerX, .equal, to: songTitleLabel, .centerX, active: false)
        ]
        
        self.horizontalConstraints = [
            imageView.constrain(.height, .equal, to: containerView, .height, active: false),
            imageView.constrain(.width,  .equal, to: imageView, .height, atPriority: 900, active: false),
            imageView.constrain(.leading, .equal, to: containerView, .leading, plus: 24.0, active: false),
            imageView.constrain(.centerY, .equal, to: containerView, .centerY, active: false),
            songTitleLabel.constrain(.leading, .equal, to: imageView, .trailing, plus: 16, active: false),
            songTitleLabel.constrain(.trailing, .equal, to: containerView, .trailing, plus: -16, active: false),
            playPauseButton.constrain(.centerY, .equal, to: containerView, .centerY, active: false)
        ]
        
        let buttonSize: CGFloat = 48.0, margin: CGFloat = 24.0
        
        musPickerButton.constrainSize(to: 36)
        trackListButton.constrainSize (to: 36)
        playPauseButton.constrainSize(to: buttonSize)
        prevTrackButton.constrainSize(to: buttonSize)
        nextTrackButton.constrainSize(to: buttonSize)
        
        musPickerButton.constrain(.bottom, .equal, to: volumeSlider, .top, plus: -10)
        musPickerButton.constrain(.left, .equal, to: volumeSlider, .left)
        
        trackListButton.constrain(.top, .equal, to: musPickerButton, .top)
        trackListButton.constrain(.right, .equal, to: volumeSlider, .right)
        
        songTitleLabel.constrain(.bottom, .equal, to: albumTitleLabel, .top, plus: -16)
        
        albumTitleLabel.constrain(.leading,  .equal, to: songTitleLabel, .leading)
        albumTitleLabel.constrain(.trailing, .equal, to: songTitleLabel, .trailing)
        albumTitleLabel.constrain(.bottom, .equal, to: playPauseButton, .top, plus: -margin)
        
        playPauseButton.constrain(.centerX, .equal, to: albumTitleLabel, .centerX)
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
        
        trackListButton.setBackgroundImage(#imageLiteral(resourceName: "List"), for: UIControlState())
        trackListButton.addTarget(self, action: #selector(ViewController.presentMusicQueueList), for: .touchUpInside)
        
        songTitleLabel.font = .systemFont(ofSize: 20.0)
        songTitleLabel.textAlignment = .center
        
        albumTitleLabel.font = .systemFont(ofSize: 15.0, weight: UIFontWeightThin)
        albumTitleLabel.textAlignment = .center
        
        self.updateCurrentTrack()
        
        NotificationCenter.default().addObserver(self, selector: #selector(ViewController.updateCurrentTrack), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        NotificationCenter.default().addObserver(self, selector: #selector(ViewController.updatePlaybackState), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.updateViewConstraints()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func updateViewConstraints() {
        switch UIDevice.current().orientation {
        case .portrait:
            horizontalConstraints.forEach   { $0.isActive = false }
            verticalConstraints.forEach     { $0.isActive = true }
            self.containerConstraints!.top.constant = self.view.frame.height/12
            self.containerConstraints!.bottom.constant = -self.view.frame.height/12
        case .landscapeLeft, .landscapeRight:
            verticalConstraints.forEach     { $0.isActive = false }
            horizontalConstraints.forEach   { $0.isActive = true }
            self.containerConstraints!.top.constant = min(self.view.frame.width, self.view.frame.height)/8
            self.containerConstraints!.bottom.constant = -min(self.view.frame.width, self.view.frame.height)/8
        default:
            break
        }
        super.updateViewConstraints()
    }

    func updateCurrentTrack() {
        guard let songItem = musicPlayer.nowPlayingItem else { return }
        
        self.updatePlaybackState()
        self.songTitleLabel.text = songItem.title
        self.albumTitleLabel.text = "\(songItem.artist!) • \(songItem.albumTitle!)"

        guard let artwork = songItem.artwork, let image = artwork.image(at: self.view.frame.size) else { return }
        let isDarkColor = image.averageColor.isDarkColor
        let blurEffect = isDarkColor ? UIBlurEffect(style: .light) : UIBlurEffect(style: .dark)
        UIView.animate(withDuration: 0.5) {
            self.imageView.image = image
            self.backgroundImageView.image = image
            self.backgroundView.effect = blurEffect
            self.vibrancyEffectView.effect = UIVibrancyEffect(blurEffect: blurEffect)
            self.volumeSlider.tintColor = image.averageColor
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
    
    func presentMusicQueueList() {
        trackListView.currentTrack = musicPlayer.nowPlayingItem
        trackListView.modalPresentationStyle = UIDevice.current().userInterfaceIdiom == .pad ? .popover : .custom
        trackListView.popoverPresentationController?.backgroundColor = .clear()
        trackListView.popoverPresentationController?.sourceView = trackListButton
        trackListView.popoverPresentationController?.sourceRect = CGRect(x: 0, y: trackListButton.frame.height/2, width: 0, height: 0)
        trackListView.popoverPresentationController?.permittedArrowDirections = .any
        trackListView.transitioningDelegate = trackListView
        self.present(trackListView, animated: true, completion: nil)
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
