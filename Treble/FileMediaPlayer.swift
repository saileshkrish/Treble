//  Copyright © 2020 Andy Liang. All rights reserved.

import MediaPlayer
import AVFoundation

class FileMediaPlayer : MediaPlayer {
    private let avPlayer: AVQueuePlayer
    private var itemUrls: [AVPlayerItem: URL] = [:]
    private var timeObserverToken: Any?
    weak var delegate: MediaPlayerDelegate?

    init?(itemUrls: [URL], delegate: MediaPlayerDelegate?) {
        guard !itemUrls.isEmpty else { return nil }
        let items = itemUrls.compactMap { UIDocument(fileURL: $0).presentedItemURL }.map { AVPlayerItem(url: $0) }
        avPlayer = AVQueuePlayer(items: items)
        avPlayer.actionAtItemEnd = .advance
        self.delegate = delegate
        for (url, item) in zip(itemUrls, items) {
            self.itemUrls[item] = url
        }
        configureMediaPlayerRemote()
        updateNowPlayingInfo()
        addPeriodicTimeObserver()
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
        avPlayer.play()
        updatePlaybackInfo()
    }

    func pause() {
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
        delegate?.updateTrackInfo(with: trackInfo, artwork: albumImage)
        updatePlaybackInfo()

        // Update the Now Playing Info
        var nowPlayingInfo: [String : Any] = [
            MPNowPlayingInfoPropertyElapsedPlaybackTime: 0 as NSNumber,
            MPNowPlayingInfoPropertyPlaybackRate: 1 as NSNumber,
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
        let progress = NowPlayingProgress(
            elapsedTime: avPlayer.currentTime().seconds,
            duration: avPlayer.currentItem?.asset.duration.seconds ?? 0.0
        )
        delegate?.updatePlaybackState(isPlaying: isPlaying, progress: progress)
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
        remote.changePlaybackPositionCommand.addTarget(self) { player in

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

    deinit {
        avPlayer.pause()
        removePeriodicTimeObserver()
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
