//  Copyright © 2020 Andy Liang. All rights reserved.

import MediaPlayer
import AVFoundation

class FileMediaPlayer : MediaPlayer {
    private let avPlayer: AVQueuePlayer
    private var itemUrls: [AVPlayerItem: URL] = [:]
    private var timeObserverToken: Any?
    private var lastPlaybackRate: PlaybackRate = .normal
    weak var delegate: MediaPlayerDelegate?
    
    // BEGIN SAILESH
    private var reps: Int = 0
    private var segment: Int = 0
    private var segmentTimes = [NSValue]()
    private var boundaryObserverToken: Any?
    private var pbState: PlaybackState = PlaybackState.Paused
    // END   SAILESH

    var playbackRate: PlaybackRate {
        get { PlaybackRate(rate: avPlayer.rate) }
        set {
            avPlayer.rate = newValue.rate
            updatePlaybackInfo()
        }
    }

    var nowPlayingProgress: NowPlayingProgress {
        return NowPlayingProgress(
            elapsedTime: avPlayer.currentTime().seconds,
            duration: avPlayer.currentItem?.asset.duration.seconds ?? 0.0
        )
    }

    init?(itemUrls: [URL], delegate: MediaPlayerDelegate?) {
        guard !itemUrls.isEmpty else { return nil }
        let items = itemUrls.compactMap { UIDocument(fileURL: $0).presentedItemURL }.map { AVPlayerItem(url: $0) }
        avPlayer = AVQueuePlayer(items: items)
        avPlayer.actionAtItemEnd = .advance
        self.delegate = delegate
        for (url, item) in zip(itemUrls, items) {
            self.itemUrls[item] = url
        }
        self.pbState = PlaybackState.Playing
        configureMediaPlayerRemote()
        updateNowPlayingInfo()
        addPeriodicTimeObserver()
        addBoundaryTimeObserver()
    }

    func appendItem(with url: URL?) {
        guard let url = url, let itemUrl = UIDocument(fileURL: url).presentedItemURL else { return }
        let item = AVPlayerItem(url: itemUrl)
        itemUrls[item] = itemUrl
        avPlayer.insert(item, after: nil)
    }

    func togglePlayback() {
        guard avPlayer.currentItem != nil else { return }
        if avPlayer.rate == 0.0 {
            play()
        } else {
            pause()
        }
    }

    func play() {
        playbackRate = lastPlaybackRate
        pbState = PlaybackState.Playing
        updatePlaybackInfo()
    }

    func pause() {
        lastPlaybackRate = playbackRate
        pbState = PlaybackState.Paused
        avPlayer.pause()
        updatePlaybackInfo()
    }
    
    func pause(pbState: PlaybackState) {
        lastPlaybackRate = playbackRate
        self.pbState = pbState
        avPlayer.pause()
        updatePlaybackInfo()
    }
    
    func previousTrack() {
        avPlayer.seek(to: .zero)
        updatePlaybackInfo()
    }

    @objc func nextTrack() {
        avPlayer.advanceToNextItem()
        updatePlaybackInfo()
        updateNowPlayingInfo()
    }

    func seek(to time: TimeInterval, completion: ActionHandler?) {
        avPlayer.seek(to: CMTime(seconds: time, preferredTimescale: 1000)) { [weak self] completed in
            completion?()
            guard completed else { return }
            self?.updateNowPlayingInfo()
        }
    }
    
    func seek(to time: CMTime, completion: ActionHandler?) {
        avPlayer.seek(to: time) { [weak self] completed in
            completion?()
            guard completed else { return }
            self?.updateNowPlayingInfo()
        }
    }

    private func updateNowPlayingInfo() {
        guard let currentItem = avPlayer.currentItem else {
            delegate?.updateTrackInfo(with: .defaultItem, artwork: ImageAssets.defaultAlbumArt)
            updatePlaybackInfo()
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var albumImage = ImageAssets.defaultAlbumArt
        var info: [MetadataKey: String] = [:]
        // Read the metadata from the file
        for format in currentItem.asset.availableMetadataFormats {
            for metadata in currentItem.asset.metadata(forFormat: format) {
                guard let key = metadata.commonKey else { continue }
                switch key {
                case .commonKeyArtist:
                    info[.artist] = metadata.value as? String
                case .commonKeyTitle:
                    info[.title] = metadata.value as? String
                case .commonKeyAlbumName:
                    info[.albumTitle] = metadata.value as? String
                case .commonKeyType:
                    info[.type] = metadata.value as? String
                case .commonKeyCreator:
                    info[.creator] = metadata.value as? String
                case .commonKeyArtwork:
                    guard let data: Data = metadata.value as? Data,
                        let image = UIImage(data: data) else { continue }
                    albumImage = image
                default:
                    print("Unknown Tag: \(key)")
                    break
                }
            }
        }

        let trackInfo: TrackInfo
        if let title = info[.title] {
            trackInfo = TrackInfo(title: title, album: info[.albumTitle], artist: info[.artist])
        } else {
            trackInfo = TrackInfo.parsedTrackInfo(from: itemUrls[currentItem]!)
        }

        // Update UI
        let progress = nowPlayingProgress
        let isPlaying = avPlayer.rate != 0
        delegate?.updateTrackInfo(with: trackInfo, artwork: albumImage)
        // delegate?.updatePlaybackState(isPlaying: isPlaying, progress: progress)
        delegate?.updatePlaybackState(isPlaying: isPlaying, pbState: pbState, progress: progress)

        
        // Update the Now Playing Info
        var nowPlayingInfo: [String : Any] = [
            MPNowPlayingInfoPropertyElapsedPlaybackTime: progress.elapsedTime as NSNumber,
            MPNowPlayingInfoPropertyPlaybackRate: avPlayer.rate as NSNumber,
            MPMediaItemPropertyTitle: trackInfo.title,
            MPMediaItemPropertyPlaybackDuration: currentItem.asset.duration.seconds,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: albumImage.size) { size in
                return UIGraphicsImageRenderer(size: size).image { _ in
                    albumImage.draw(in: CGRect(origin: .zero, size: size))
                }
            }
        ]
        if let album = trackInfo.album {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        }
        if let artist = trackInfo.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    @objc private func updatePlaybackInfo() {
        let isPlaying = avPlayer.rate != 0
        let progress = nowPlayingProgress
        // delegate?.updatePlaybackState(isPlaying: isPlaying, progress: progress)
        delegate?.updatePlaybackState(isPlaying: isPlaying, pbState: pbState, progress: progress)
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progress.elapsedTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = avPlayer.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func configureMediaPlayerRemote() {
        // Configure the Session
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(nextTrack),
                name: .AVPlayerItemDidPlayToEndTime,
                object: nil)
        } catch {
            print("Failed to activate the AVAudioSession: \(error)")
        }
        // Configure the Remote
        let remote = MPRemoteCommandCenter.shared()
        remote.togglePlayPauseCommand.addTarget(self) { $0.togglePlayback() }
        remote.playCommand.addTarget(self) { $0.play() }
        remote.pauseCommand.addTarget(self) { $0.pause() }
        remote.previousTrackCommand.addTarget(self) { $0.previousTrack() }
        remote.nextTrackCommand.addTarget(self) { $0.nextTrack() }
        // Support playback moving
        remote.changePlaybackPositionCommand.isEnabled = true
        remote.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let _self = self,
                  let event = event as? MPChangePlaybackPositionCommandEvent
            else { return .noSuchContent }
            _self.seek(to: event.positionTime) {}
            return .success
        }
    }

    private func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: time, queue: .main) {
            [weak self] time in // update player transport UI
            self?.delegate?.updatePlaybackProgress(elapsedTime: time.seconds)
        }
    }

    private func removePeriodicTimeObserver() {
        guard let token = timeObserverToken else { return }
        avPlayer.removeTimeObserver(token)
        timeObserverToken = nil
    }

    private func addBoundaryTimeObserver() {
         // Repeat every 5 second duration 5 times
         
         // Set initial time to zero
         var currentTime = CMTime.zero
         
         let asset = avPlayer.currentItem?.asset
         
         // Divide the asset's duration into quarters.
         let timeScale = CMTimeScale(NSEC_PER_SEC)
         let interval = CMTime(seconds: 5, preferredTimescale: timeScale)
         
         // Build boundary times for every 5 second interval
         while currentTime < asset!.duration {
             segmentTimes.append(NSValue(time: currentTime))
             currentTime = currentTime + interval
         }
         segmentTimes.append(NSValue(time: asset!.duration))
         
         self.reps = 0
         self.segment = 0
         
         // Add time observer. Observe boundary time changes on the main queue.
         boundaryObserverToken = avPlayer.addBoundaryTimeObserver(forTimes: segmentTimes, queue: .main)
             { [weak self] in
                 if (self!.segment < self!.segmentTimes.count) {
                     let currSegment = self?.segmentTimes[self!.segment].timeValue
                     let nextSegment = self?.segmentTimes[self!.segment + 1].timeValue
                     
                    print("Repeating segment ", String(self!.segment) , " ", String(self!.reps)," times")
                     if (self!.reps < 2) {
                        self!.reps += 1
                        self?.seek(to: currSegment!) { self?.pbState = PlaybackState.Repeating }
                     }
                     else {
                        self!.reps = 0
                        self?.pause(pbState:PlaybackState.Listening)
                        let seconds = nextSegment!.seconds - currSegment!.seconds + 1.0
                        self!.segment += 1
                        print("Listening for ", String(seconds), " seconds")
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                             // Put your code which should be executed with a delay here
                            print("Playing")
                            self?.play()
                        }
                     }
                 }
         }
     }

     private func removeBoundaryTimeObserver() {
         guard let token = boundaryObserverToken else { return }
         avPlayer.removeTimeObserver(token)
         boundaryObserverToken = nil
     }
     
    
    deinit {
        avPlayer.pause()
        removePeriodicTimeObserver()
        removeBoundaryTimeObserver()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            UIApplication.shared.endReceivingRemoteControlEvents()
        } catch {
            print("Failed to deactivate the AVAudioSession: \(error)")
        }
    }
}

private enum MetadataKey {
    case title
    case albumTitle
    case artist
    case type
    case creator
}

private extension MPRemoteCommand {
    func addTarget(_ player: FileMediaPlayer, handler: @escaping (FileMediaPlayer) -> Void) {
        isEnabled = true
        addTarget { [weak player] _ in
            guard let player = player else { return .noSuchContent }
            handler(player)
            return .success
        }
    }
}
