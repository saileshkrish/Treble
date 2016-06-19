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
        self.tableView.rowHeight = 64.0
        self.tableView.backgroundColor = .clear()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(MusicQueueItemCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.updatePreferredContentSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updatePreferredContentSize()
    }
    
    func updatePreferredContentSize() {
         self.preferredContentSize = CGSize(width: self.traitCollection.userInterfaceIdiom == .pad ? 320 : self.tableView.contentSize.width, height: min(self.tableView.contentSize.height, self.tableView.frame.height-100))
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
        
        return cell
    }

}

extension MusicQueueViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresentedViewController presented: UIViewController, presenting: UIViewController?, sourceViewController source: UIViewController) -> UIPresentationController? {
        return MusicQueuePresentationController(presentedViewController: presented, presenting: presenting)
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
