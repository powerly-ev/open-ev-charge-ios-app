//
//  WebViewController.swift
//  PowerShare
//
//  Created by admin on 30/11/21.

//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var headerString: String = ""
    var loadURL: String = ""
    var webView: WKWebView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var objActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var objWebView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.font = .robotoMedium(ofSize: 16)
        headerLabel.text = headerString
        webView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: objWebView.frame.size.width, height: objWebView.frame.size.height))
        objWebView.addSubview(webView)
        let url = URL(string: loadURL)
        var request: URLRequest?
        if let url = url {
            request = URLRequest(url: url)
        }
        if let request = request {
            webView.load(request)
        }
        webView.navigationDelegate = self
        webView.scrollView.contentInset = .zero
    }
    
    override func viewDidLayoutSubviews() {
        webView.frame = CGRect(x: 0.0, y: 0.0, width: objWebView.frame.size.width, height: objWebView.frame.size.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //frostedViewController.panGestureEnabled = false
    }
    
    
    @IBAction func didTap(onBackButton sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        objActivityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        objActivityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        objActivityIndicator.stopAnimating()
    }
}
