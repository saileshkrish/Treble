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
    private var currentMediaPlayer: MediaPlayer?

    override init() {
        super.init()
        // setup the remote
        let remote = MPRemoteCommandCenter.shared()
        remote.togglePlayPauseCommand.addTarget(togglePlayback)
        remote.playCommand.addTarget(play)
        remote.pauseCommand.addTarget(pause)
        remote.previousTrackCommand.addTarget(previousTrack)
        remote.nextTrackCommand.addTarget(nextTrack)
    }

    func update(player: MediaPlayer) {
        currentMediaPlayer = player
        player.play()
    }

    func togglePlayback() {
        currentMediaPlayer?.togglePlayback()
    }

    func play() {
        currentMediaPlayer?.play()
    }

    func pause() {
        currentMediaPlayer?.pause()
    }

    func previousTrack() {
        currentMediaPlayer?.previousTrack()
    }

    func nextTrack() {
        currentMediaPlayer?.nextTrack()
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
