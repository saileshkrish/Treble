//
//  MediaController.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-10.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import MediaPlayer

class MediaController: NSObject {
    var mediaPlayer: MediaPlayer?

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

    func togglePlayback() {
        mediaPlayer?.togglePlayback()
    }

    func play() {
        mediaPlayer?.play()
    }

    func pause() {
        mediaPlayer?.pause()
    }

    func previousTrack() {
        mediaPlayer?.previousTrack()
    }

    func nextTrack() {
        mediaPlayer?.nextTrack()
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
