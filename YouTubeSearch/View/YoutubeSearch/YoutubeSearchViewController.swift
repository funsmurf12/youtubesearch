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
    
    private var isLoadingMore: Bool = false
    private var isSearching: Bool = false
    
    @IBOutlet weak var myWebView: WKWebView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var txtSearch: UISearchBar!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var presenter: YoutubeSearchProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = YoutubeSearchPresenter(view: self)
        setupWebView()
        setupTableView()
    }
    
    private func setupWebView() {
        myWebView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17"
        myWebView.navigationDelegate = self
        myWebView.allowsBackForwardNavigationGestures = true
        myWebView.scrollView.delegate = self
        myWebView.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
    }
    
    private func setupTableView() {
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.register(nibWithCellClass: YoutubeSearchTableViewCell.self, at: Self.self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(UIScrollView.contentSize)) {
            let contentSize = myWebView.scrollView.contentSize
            
            if contentSize != self.contentSize && contentSize.height > self.contentSize.height && isLoadingMore {
                
                self.contentSize = contentSize
                print(contentSize.height)
                
                self.myWebView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (value: Any!, error: Error!) -> Void in
                    if error != nil {
                        return
                    }
                    if let result = value as? String {
                        self.presenter?.parseHtml(htmlString: result)
                        self.isLoadingMore = false
                    }
                })
                
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
            guard let `self` = self else { return }
            if self.isSearching {
                self.isSearching = false
            } else {
                self.indicatorView.stopAnimating()
            }
            self.myTableView.reloadData()
        }
    }
    
    func startSearch() {
        self.isSearching = true
        self.indicatorView.startAnimating()
        let searchString = YoutubeRouter.result.url + "?search_query=" + (txtSearch.text ?? "")
        self.isLoadingMore = true
        myWebView.evaluateJavaScript("window.location = '\(searchString)';") { _, _ in
            print("loaded")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension YoutubeSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let videoId = presenter?.movieIdForRowIndexPath(indexPath: indexPath) {
            let detailVC = YoutubeVideoDetailViewController(nibName: YoutubeVideoDetailViewController.name(), bundle: nil)
            detailVC.videoId = videoId
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            showAlert(title: "Notification", message: "An error occur with this video. Please try another one")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let numberCells = self.presenter?.numbersVideoInSection else { return }
        if indexPath.row == numberCells - 1 && numberCells > 0 {
            self.isLoadingMore = true
            self.indicatorView.startAnimating()
            self.needToLoadMore()
        }
    }
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        presenter?.clearData()
        startSearch()
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
