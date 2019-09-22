//
//  FileMediaPlayer.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-10.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

private enum MetadataKey {
    case title
    case albumTitle
    case artist
    case type
    case creator
}

class FileMediaPlayer : MediaPlayer {
    let player: AVPlayer
    let fileName: String
    let artistName: String?
    weak var delegate: MediaPlayerDelegate?

    init(player: AVPlayer, fileName: String, artistName: String?, delegate: MediaPlayerDelegate) {
        self.player = player
        self.delegate = delegate
        self.fileName = fileName
        self.artistName = artistName
        // setup the remote
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(restartPlayback),
                name: .AVPlayerItemDidPlayToEndTime,
                object: nil)
        } catch {
            print("Error Activating the AVAudioSession: \(error)")
        }
        updateNowPlaying()
    }

    func togglePlayback() {
        guard let _ = player.currentItem else { return }
        if player.rate == 0 {
            play()
        } else {
            pause()
        }
    }

    func play() {
        player.play()
        delegate?.updatePlaybackState(isPlaying: true)
    }

    func pause() {
        player.pause()
        delegate?.updatePlaybackState(isPlaying: false)
    }

    func previousTrack() {
        player.seek(to: .zero)
        delegate?.updatePlaybackState(isPlaying: player.rate > 0)
    }

    func nextTrack() {
        // no-op
    }

    private func updateNowPlaying() {
        guard let item = player.currentItem else { return }
        var albumImage = UIImage(named: "DefaultAlbumArt")!
        var info: [MetadataKey: String] = [:]

        for format in item.asset.availableMetadataFormats {
            for metadata in item.asset.metadata(forFormat: format) {
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

        let songTitle = info[.title] ?? fileName

        let trackInfo = TrackInfo(
            songTitle: songTitle,
            albumTitle: info[.albumTitle],
            artistName: info[.artist] ?? artistName,
            albumArtwork: albumImage)
        delegate?.updateTrackInfo(with: trackInfo)
        delegate?.updatePlaybackState(isPlaying: player.rate > 0)

        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: songTitle,
            MPMediaItemPropertyAlbumTitle: info[.albumTitle] ?? "",
            MPMediaItemPropertyArtist: info[.artist] ?? artistName ?? "",
            MPMediaItemPropertyPlaybackDuration: item.asset.duration.seconds,
            MPNowPlayingInfoPropertyPlaybackRate: 1 as NSNumber,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: albumImage.size) { size in
                UIGraphicsImageRenderer(size: size).image { _ in
                    albumImage.draw(in: CGRect(origin: .zero, size: size))
                }
            }
        ]
    }

    @objc private func restartPlayback() {
        guard player.currentItem != nil else { return }
        player.seek(to: .zero)
        player.play()
    }

    deinit {
        player.pause()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            UIApplication.shared.endReceivingRemoteControlEvents()
        } catch {
            print("Error Deactivating the AVAudioSession: \(error)")
        }
    }
}
