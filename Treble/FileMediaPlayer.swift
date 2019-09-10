//
//  FileMediaPlayer.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-10.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import AVFoundation

class FileMediaPlayer : MediaPlayer {
    let player = AVPlayer()

    func togglePlayback() {
        guard let _ = player.currentItem else { return }
        if player.rate == 0 {
            player.play()
        } else {
            player.pause()
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func previousTrack() {
        player.seek(to: .zero)
    }

    func nextTrack() {
        // no-op
    }
}
