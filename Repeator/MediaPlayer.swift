//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

struct TrackInfo {
    var title: String
    var album: String? = nil
    var artist: String? = nil
    var trackNumber: Int = 0
    var fileType: String = "Audio File"

    var subtitleText: String {
        let subtitle = [album, artist].compactMap { $0 }.joined(separator: " - ")
        return !subtitle.isEmpty ? subtitle : fileType
    }

    static func parsedTrackInfo(from url: URL) -> TrackInfo {
        let pathExtension = url.pathExtension
        let fileName = url.deletingPathExtension().lastPathComponent
        let components = fileName.components(separatedBy: "-")
        let fileType = "\(pathExtension.uppercased()) File"

        switch components.count {
        case 2:
            if let number = Int(components[0]) {
                // first element is a track number
                return TrackInfo(title: components[1], trackNumber: number, fileType: fileType)
            } else {
                return TrackInfo(title: components[1], artist: components[0], fileType: fileType)
            }
        case 3:
            if let number = Int(components[0]) {
                // first element is a track number
                return TrackInfo(
                    title: components[2], artist: components[1], trackNumber: number, fileType: fileType
                )
            } else {
                return TrackInfo(title: components[1], artist: components[0], fileType: fileType)
            }
        default:
            return TrackInfo(title: fileName, fileType: fileType)
        }
    }
}

extension TrackInfo {
    static let defaultItem = TrackInfo(
        title: "Welcome to Repeator",
        album: "Choose from your Apple Music Library, or select an audio file from your iCloud Drive.")
}

protocol MediaPlayerDelegate : class {
    func updatePlaybackProgress(elapsedTime: TimeInterval)
    func updatePlaybackState(isPlaying: Bool, progress: NowPlayingProgress)
    func updateTrackInfo(with trackInfo: TrackInfo, artwork: UIImage)
}

protocol MediaPlayer {
    var delegate: MediaPlayerDelegate? { get set }
    var playbackRate: PlaybackRate { get set }
    func togglePlayback()
    func play()
    func pause()
    func previousTrack()
    func nextTrack()
    func seek(to time: TimeInterval, completion: ActionHandler?)
}
