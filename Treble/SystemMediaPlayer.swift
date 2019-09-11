//
//  SystemMediaPlayer.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-09.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import MediaPlayer

class SystemMediaPlayer : MediaPlayer {
    let player: MPMusicPlayerController = .systemMusicPlayer
    weak var delegate: MediaPlayerDelegate?

    init(delegate: MediaPlayerDelegate?) {
        self.delegate = delegate

        updateNowPlaying()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNowPlaying),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil)
    }

    init(queue: MPMediaItemCollection, delegate: MediaPlayerDelegate?) {
        self.delegate = delegate
        player.setQueue(with: queue)
        updateNowPlaying()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNowPlaying),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil)
    }

    func togglePlayback() {
        switch player.playbackState {
        case .playing:
            pause()
        case .paused:
            play()
        default:
            break
        }
    }

    func play() {
        player.play()
        delegate?.updatePlaybackState(isPlaying: player.playbackState == .playing)
    }

    func pause() {
        player.pause()
        delegate?.updatePlaybackState(isPlaying: player.playbackState == .playing)
    }

    func previousTrack() {
        guard let _ = player.nowPlayingItem else { return }
        if player.currentPlaybackTime < 5.0 {
            player.skipToPreviousItem()
        } else {
            player.skipToBeginning()
        }
        delegate?.updatePlaybackState(isPlaying: player.playbackState == .playing)
    }

    func nextTrack() {
        player.skipToNextItem()
        delegate?.updatePlaybackState(isPlaying: player.playbackState == .playing)
    }

    @objc private func updateNowPlaying() {
        guard let item = player.nowPlayingItem else { return }
        let size = CGSize(width: 400, height: 400)
        let image = item.artwork?.image(at: size) ?? UIImage(named: "DefaultAlbumArt")!
        let trackInfo = TrackInfo(
            songTitle: item.title ?? "",
            albumTitle: item.albumTitle,
            artistName: item.artist,
            albumArtwork: image)
        delegate?.updateTrackInfo(with: trackInfo)
    }

}
