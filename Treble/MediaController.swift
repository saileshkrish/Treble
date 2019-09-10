//
//  MediaController.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-10.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit
import MediaPlayer

enum MediaPlaybackType {
    case file(AVPlayerItem)
    case system
}

class MediaController: NSObject {
    private var currentMediaPlayer: MediaPlayer!

    var musicType: MediaPlaybackType = .system {
        didSet { updateMusicType() }
    }

    func setupRemote() {
        let remote = MPRemoteCommandCenter.shared()
        remote.togglePlayPauseCommand.addTarget(currentMediaPlayer.togglePlayback)
        remote.playCommand.addTarget(currentMediaPlayer.play)
        remote.pauseCommand.addTarget(currentMediaPlayer.pause)
        remote.previousTrackCommand.addTarget(currentMediaPlayer.previousTrack)
        remote.nextTrackCommand.addTarget(currentMediaPlayer.nextTrack)
    }

    func togglePlayback() {
        currentMediaPlayer.togglePlayback()
    }

    func play() {
        currentMediaPlayer.play()
    }

    func pause() {
        currentMediaPlayer.pause()
    }

    func previousTrack() {
        currentMediaPlayer.previousTrack()
    }

    func nextTrack() {
        currentMediaPlayer.nextTrack()
    }

    private func updateMusicType() {
    }

}

private extension MPRemoteCommand {

    func addTarget(_ handler: @escaping () -> Void) {
        isEnabled = true
        addTarget { _ in
            handler()
            return .success
        }
    }

}
