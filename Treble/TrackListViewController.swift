//
//  TrackListViewController.swift
//  Treble
//
//  Created by Andy Liang on 2016-02-05.
//  Copyright © 2016 Andy Liang. All rights reserved.
//

import UIKit
import MediaPlayer

private let reuseIdentifier = "reuseIdentifier"
class TrackListViewController: UITableViewController {
    
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    private var trackList: [MPMediaItem] = []
    
    var currentTrack: MPMediaItem! {
        didSet {
            defer {
                self.tableView.reloadData()
                self.updatePreferredContentSize()
            }
            
            self.trackList = []
            guard let album = currentTrack.albumTitle else { return }
            let predicate = MPMediaPropertyPredicate(value: album, forProperty: MPMediaItemPropertyAlbumTitle)
            self.trackList = MPMediaQuery(filterPredicates: [predicate]).items!
        }
    }
    
    override func loadView() {
        super.loadView()
        tableView.rowHeight = 48
        tableView.backgroundColor = .clear()
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TrackItemCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func updatePreferredContentSize() {
        let height = UIDevice.current().orientation == .portrait ? UIScreen.main().bounds.height*0.8 : UIScreen.main().bounds.width*0.8
        self.preferredContentSize = CGSize(width: UIDevice.current().userInterfaceIdiom == .pad ? 320 : self.tableView.frame.width,
                                           height: min(self.tableView.contentSize.height, height))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    var indexOfNowPlayingItem: Int {
        guard let title = musicPlayer.nowPlayingItem?.title else { return -1 }
        return self.trackList.map { $0.title! }.index(of: title) ?? -1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != self.indexOfNowPlayingItem else { return }
        let selectedTrack = trackList[indexPath.row]
        musicPlayer.setQueue(with: MPMediaItemCollection(items: trackList))
        self.musicPlayer.nowPlayingItem = selectedTrack
        self.dismiss(animated: true, completion: self.musicPlayer.play)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentTrack.albumTitle
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel!.text = indexPath.row == indexOfNowPlayingItem
            ? "▶︎ \(trackList[indexPath.row].title!)"
            : trackList[indexPath.row].title!
        return cell
    }

}

extension TrackListViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresentedViewController presented: UIViewController, presenting: UIViewController?, sourceViewController source: UIViewController) -> UIPresentationController? {
        return TrackListPresentationController(presentedViewController: presented, presenting: presenting)
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
