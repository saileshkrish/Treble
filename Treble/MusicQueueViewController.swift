//
//  MusicQueueViewController.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit
import MediaPlayer

private let reuseIdentifier = "reuseIdentifier"
class MusicQueueViewController: UITableViewController {
    
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    private var trackList: [MPMediaItem] = []
    
    var currentTrack: MPMediaItem! {
        didSet {
            self.trackList = musicPlayer.query.items ?? []
            self.tableView.reloadData()
        }
    }
    
    override func loadView() {
        super.loadView()
        self.tableView.backgroundColor = .clear()
        self.tableView.tableFooterView = UIView()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.tableView.backgroundView = blurView
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(MusicQueueItemCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != musicPlayer.indexOfNowPlayingItem else { return }
        let newItem = trackList[indexPath.row]
        musicPlayer.nowPlayingItem = newItem
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicPlayer.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MusicQueueItemCell
        if var title = trackList[indexPath.row].value(forProperty: MPMediaItemPropertyTitle) as? String,
            let currentTitle = musicPlayer.nowPlayingItem?.value(forKey: MPMediaItemPropertyTitle) as? String {
            
            if title == currentTitle {
                title = "▶︎ \(title)"
            }
            cell.textLabel!.text = title
        }
        
        if let duration = trackList[indexPath.row].value(forProperty: MPMediaItemPropertyPlaybackDuration) as? Double {
            cell.detailTextLabel!.text = duration.stringRepresentation
        }
        return cell
    }

}

private extension TimeInterval {
    
    var stringRepresentation: String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = interval / 3600
        return (hours > 0 ? "\(hours):" : "") + String(format: "%02d:%02d", minutes, seconds)
    }
    
}
