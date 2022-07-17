//
//  YoutubeSearchPretenser.swift
//  YouTubeSearch
//
//  Created by Kiet Nguyen on 7/17/22.
//

import Foundation
import SwiftSoup
import WebKit

protocol YoutubeSearchView: AnyObject {
    func displayVideo()
    func startSearch()
    func showAlert(title: String, message: String)
}

protocol YoutubeSearchProtocol {
    var numbersVideoInSection: Int { get }
    func videoForRowIndexPath(indexPath: IndexPath) -> String?
    func movieIdForRowIndexPath(indexPath: IndexPath) -> String?
    func parseHtml(htmlString: String)
    func clearData()
}

final class YoutubeSearchPresenter {
    private var listVideo = [String]()
    private var listMovieId = [String]()
    private weak var view: YoutubeSearchView?
    
    init(view: YoutubeSearchView) {
        self.view = view
    }
}

extension YoutubeSearchPresenter: YoutubeSearchProtocol {
    var numbersVideoInSection: Int {
        return listVideo.count
    }
    
    func videoForRowIndexPath(indexPath: IndexPath) -> String? {
        if indexPath.row >= 0 &&
            indexPath.row < listVideo.count {
            return listVideo[indexPath.row]
        }
        return nil
    }
    
    func movieIdForRowIndexPath(indexPath: IndexPath) -> String? {
        if indexPath.row >= 0 &&
            indexPath.row < listMovieId.count {
            return listMovieId[indexPath.row]
        }
        return nil
    }
    
    func parseHtml(htmlString: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            self.listVideo.removeAll()
            do {
                let doc: Document = try SwiftSoup.parse(htmlString)
                let elementsLink = try doc.select("ytd-video-renderer").select("a[href][id=\"thumbnail\"]")
                let elements = try elementsLink.select("img[id=\"img\"][src]")
                
                for i in 0..<elements.count {
                    if let thumbnail = try? elements[i].attr("src") {
                        self.listVideo.append(thumbnail)
                    }
                    if let link = try? elementsLink[i].attr("href") {
                        let result = link.replacingOccurrences(of: "/watch?v=", with: "")
                        self.listMovieId.append(result)
                    }
                }
                
                DispatchQueue.main.async {
                    self.view?.displayVideo()
                }
                
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
        }
    }
    
    func clearData() {
        listVideo.removeAll()
        self.view?.displayVideo()
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          dataStore.removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            for: records.filter { $0.displayName.contains("youtube") }) {
                print("removed")
            }
        }
    }
}
