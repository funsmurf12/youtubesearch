//
//  YoutubeSearchViewController.swift
//  YouTubeSearch
//
//  Created by Kiet Nguyen on 7/17/22.
//

import UIKit
import WebKit
import SwiftSoup

class YoutubeSearchViewController: UIViewController {
    
    var pagesLabel = "1"
    var contentSize: CGSize = .zero
    
    @IBOutlet weak var myWebView: WKWebView!
    var webView: WKWebView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var txtSearch: UISearchBar!
    var presenter: YoutubeSearchProcol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = YoutubeSearchPresenter(view: self)
        setupWebView()
    }
    
    private func setupWebView() {
        let link = URL(string:"https://www.youtube.com/results?search_query=ronaldo")!
        let request = URLRequest(url: link)
        myWebView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17"
        myWebView.navigationDelegate = self
        myWebView.allowsBackForwardNavigationGestures = true
        myWebView.scrollView.delegate = self
        myWebView.load(request)
        myWebView.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.register(nibWithCellClass: YoutubeSearchTableViewCell.self, at: Self.self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(UIScrollView.contentSize)) {
            let contentSize = myWebView.scrollView.contentSize
            
            if contentSize != self.contentSize {
                self.contentSize = contentSize
                print(contentSize.height)
                //need handle new data LoadMore
            }
        }
    }
    
    //Call when table will display last index
    private func needToLoadMore() {
        let offSet = CGPoint(x: self.myWebView.scrollView.contentOffset.x, y: self.myWebView.scrollView.contentSize.height - self.myWebView.scrollView.bounds.size.height + self.myWebView.scrollView.contentInset.bottom)
        self.myWebView.scrollView.setContentOffset(offSet, animated: true)
    }
}

extension YoutubeSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numbersVideoInSection ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: YoutubeSearchTableViewCell.identifier) as? YoutubeSearchTableViewCell else { return UITableViewCell() }
        if let movie = presenter?.videoForRowIndexPath(indexPath: indexPath) {
            cell.configCell(url: movie)
        }
        return cell
    }
    
    
}

extension YoutubeSearchViewController: YoutubeSearchView {
    func displayVideo() {
        DispatchQueue.main.async { [weak self] in
            self?.myTableView.reloadData()
        }
    }
}

extension YoutubeSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension YoutubeSearchViewController: UIScrollViewDelegate {
    // MARK: - webView Scroll View
    
    //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //        self.stoppedScrolling()
    //    }
    //
    //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //        if !decelerate {
    //            self.stoppedScrolling()
    //        }
    //    }
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        var currentPage = Int((myWebView.scrollView.contentOffset.x / myWebView.scrollView.frame.size.width) + 1)
    //        let pageCount = Int(myWebView.scrollView.contentSize.width / myWebView.scrollView.frame.size.width)
    //
    //        if currentPage == 0 {
    //            currentPage = 1
    //        } else {
    //
    //        }
    //
    //        if !myWebView.isHidden {
    //            pagesLabel = "\( currentPage ) - \( pageCount )"
    //        } else {
    //            pagesLabel = ""
    //        }
    //        print("My current page: \(pagesLabel)")
    //    }
    
    //    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    //        myWebView.scrollView.pinchGestureRecognizer?.isEnabled = false
    //    }
    
    //    func stoppedScrolling() {
    //        let pageToLoad = Int((myWebView.scrollView.contentOffset.x))
    //        UserDefaults.standard.set(pageToLoad, forKey: "pageToLoad")
    //    }
    
}

extension YoutubeSearchViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (value: Any!, error: Error!) -> Void in
            if error != nil {
                return
            }
            if let result = value as? String {
                self.presenter?.parseHtml(htmlString: result)
            }
        })
    }
}


extension YoutubeSearchViewController: UISearchBarDelegate {
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //        searchBar.resignFirstResponder()
    //    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let content = searchBar.text, content != "" {
            self.contentSize = .zero
            let url = URL(string:"https://www.youtube.com/results?search_query=\(content)")!
            self.myWebView.load(URLRequest(url: url))
            //Need to reset tableView data
        }
        
    }
}

extension UITableView {
    func register<T: UITableViewCell>(nibWithCellClass name: T.Type, at bundleClass: AnyClass? = nil) {
        let identifier = String(describing: name)
        var bundle: Bundle?
        
        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }
        
        register(UINib(nibName: identifier, bundle: bundle), forCellReuseIdentifier: identifier)
    }
}
