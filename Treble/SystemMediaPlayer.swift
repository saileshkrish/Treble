//  Copyright © 2020 Andy Liang. All rights reserved.

import MediaPlayer

class SystemMediaPlayer : MediaPlayer {
    private let player = MPMusicPlayerController.systemMusicPlayer
    private var previousTime = -1.0
    private var timer: Timer?
    private var lastPlaybackRate: PlaybackRate = .normal
    weak var delegate: MediaPlayerDelegate?

    var playbackRate: PlaybackRate {
        get { PlaybackRate(rate: player.currentPlaybackRate) }
        set {
            player.currentPlaybackRate = newValue.rate
            addPeriodicTimeObserver() 
            updatePlaybackState()
        }
    }

    init(queue: MPMediaItemCollection? = nil, delegate: MediaPlayerDelegate?) {
        self.delegate = delegate
        if let queue = queue {
            player.setQueue(with: queue)
        }
        updateNowPlaying()
        updatePlaybackState()
        // if we're already playing something, then setup the timer
        if case .playing = player.playbackState {
            addPeriodicTimeObserver()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNowPlaying),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlaybackState),
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: nil)
    }

    func togglePlayback() {
        switch player.playbackState {
        case .playing:
            pause()
        default:
            play()
        }
    }

    func play() {
        addPeriodicTimeObserver()
        playbackRate = lastPlaybackRate
        updatePlaybackState()
    }

    func pause() {
        removePeriodicTimeObserver()
        lastPlaybackRate = playbackRate
        player.pause()
        updatePlaybackState()
    }

    func previousTrack() {
        guard let _ = player.nowPlayingItem else { return }
        if player.currentPlaybackTime < 5.0 {
            player.skipToPreviousItem()
        } else {
            player.skipToBeginning()
        }
        updatePlaybackState()
    }

    func nextTrack() {
        player.skipToNextItem()
        updatePlaybackState()
    }

    func seek(to time: TimeInterval, completion: ActionHandler?) {
        player.currentPlaybackTime = time
        updatePlaybackState()
        completion?()
    }

    private func addPeriodicTimeObserver() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let time = self?.player.currentPlaybackTime, time != self?.previousTime else { return }
            self?.previousTime = time
            self?.delegate?.updatePlaybackProgress(elapsedTime: time)
        }
    }

    private func removePeriodicTimeObserver() {
        guard let timer = self.timer else { return }
        timer.invalidate()
        self.timer = nil
    }

    @objc private func updateNowPlaying() {
        guard let item = player.nowPlayingItem else { return }
        let size = CGSize(width: 400, height: 400)
        let image = item.artwork?.image(at: size) ?? ImageAssets.defaultAlbumArt
        let trackInfo = TrackInfo(title: item.title ?? "", album: item.albumTitle, artist: item.artist)
        delegate?.updateTrackInfo(with: trackInfo, artwork: image)
    }

    @objc private func updatePlaybackState() {
        let isPlaying = player.playbackState == .playing
        let progress = NowPlayingProgress(
            elapsedTime: player.currentPlaybackTime,
            duration: player.nowPlayingItem?.playbackDuration ?? 0.0)
        delegate?.updatePlaybackState(isPlaying: isPlaying, progress: progress)
    }

    deinit {
        removePeriodicTimeObserver()
    }
}
