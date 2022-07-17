//
//  YoutubeVideoDetailViewController.swift
//  YouTubeSearch
//
//  Created by Kiet Nguyen on 7/18/22.
//

import UIKit
import youtube_ios_player_helper

class YoutubeVideoDetailViewController: UIViewController {
    var videoId: String = ""
    @IBOutlet weak var playerView: YTPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.load(withVideoId: videoId, playerVars: ["playsinline" : 0])
    }

}
