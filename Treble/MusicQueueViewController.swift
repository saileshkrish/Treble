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
        self.tableView.backgroundColor = .clearColor()
        self.tableView.tableFooterView = UIView()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        self.tableView.backgroundView = blurView
        self.tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(MusicQueueItemCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard indexPath.row != musicPlayer.indexOfNowPlayingItem else { return }
        let newItem = trackList[indexPath.row]
        musicPlayer.nowPlayingItem = newItem
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicPlayer.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MusicQueueItemCell
        if let title = trackList[indexPath.row].valueForProperty(MPMediaItemPropertyTitle) as? String {
            cell.textLabel!.text = (indexPath.row == musicPlayer.indexOfNowPlayingItem ? "▶️ " : "") + "\(title)"
        }
        
        if let duration = trackList[indexPath.row].valueForProperty(MPMediaItemPropertyPlaybackDuration) as? Double {
            cell.detailTextLabel!.text = "\(duration.stringRepresentation)"
        }
        return cell
    }

}

private extension NSTimeInterval {
    
    var stringRepresentation: String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = interval / 3600
        return (hours > 0 ? "\(hours):" : "") + String(format: "%02d:%02d", minutes, seconds)
    }
    
}
