//
//  YoutubeSearchPretenser.swift
//  YouTubeSearch
//
//  Created by Kiet Nguyen on 7/17/22.
//

import Foundation
import SwiftSoup

protocol YoutubeSearchView: AnyObject {
    func displayVideo()
}

protocol YoutubeSearchProcol {
    var numbersVideoInSection: Int { get }
    func videoForRowIndexPath(indexPath: IndexPath) -> String?
    func parseHtml(htmlString: String)
}

final class YoutubeSearchPresenter {
    private var listVideos = [String]()
    private weak var view: YoutubeSearchView?
    
    init(view: YoutubeSearchView) {
        self.view = view
    }
}

extension YoutubeSearchPresenter: YoutubeSearchProcol {
    var numbersVideoInSection: Int {
        return listVideos.count
    }
    
    func videoForRowIndexPath(indexPath: IndexPath) -> String? {
        if indexPath.row >= 0 &&
            indexPath.row < listVideos.count {
            return listVideos[indexPath.row]
        }
        return nil
    }
    
    func parseHtml(htmlString: String) {
        do {
            let doc: Document = try SwiftSoup.parse(htmlString)
            let elements = try doc.select("ytd-video-renderer").select("a[href][id=\"thumbnail\"]").select("img[id=\"img\"][src]")
            
            for i in elements {
                print(try i.attr("src"))
                if let thumbnail = try? i.attr("src") {
                    listVideos.append(thumbnail)
                    view?.displayVideo()
                }
            }
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
}
