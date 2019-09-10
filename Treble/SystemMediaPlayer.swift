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
    }

    func pause() {
        player.pause()
    }

    func previousTrack() {
        guard let _ = player.nowPlayingItem else { return }
        if player.currentPlaybackTime < 5.0 {
            player.skipToPreviousItem()
        } else {
            player.skipToBeginning()
        }
    }

    func nextTrack() {
        player.skipToNextItem()
    }

}
