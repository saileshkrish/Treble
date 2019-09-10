//
//  MediaPlayer.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-10.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

protocol MediaPlayer {
    func togglePlayback()
    func play()
    func pause()
    func previousTrack()
    func nextTrack()
}
