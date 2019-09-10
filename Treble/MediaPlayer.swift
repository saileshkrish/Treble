//
//  MediaPlayer.swift
//  Treble
//
//  Created by Andy Liang on 2019-09-10.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit

struct TrackInfo {
    let songTitle: String
    let albumTitle: String?
    let artistName: String?
    let albumArtwork: UIImage?
}

protocol MediaPlayerDelegate : class {
    func updatePlaybackState(isPlaying: Bool)
    func updateTrackInfo(with trackInfo: TrackInfo)
}

protocol MediaPlayer {
    var delegate: MediaPlayerDelegate? { get set }
    func togglePlayback()
    func play()
    func pause()
    func previousTrack()
    func nextTrack()
}
