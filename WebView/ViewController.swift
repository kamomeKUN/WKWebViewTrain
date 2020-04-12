//
//  ViewController.swift
//  WebView
//
//  Created by kamomeKUN on 2020/04/11.
// Copyright ©︎ 2020 kamomeKUN. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {

    @IBOutlet weak var mainView: UIView!
    
    let webView = WKWebView()
    // toolBar設定
    var toolBar: UIToolbar?
    var rewindButton = UIBarButtonItem()
    var fastForwardButton = UIBarButtonItem()
    var refreshButton = UIBarButtonItem()
    var openInSafari = UIBarButtonItem()
    // インジケーター
    var indicator = UIActivityIndicatorView()
    
    override func loadView() {
        super.loadView()
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
    }
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.configuration.userContentController.add(self, name: "callbackHandler")
                
        setupWKWebView()
        setupToolBar()
        setupIndicator()
        loadWKWebView()
        
    }
    
    private func setupWKWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.frame = CGRect(x: 0, y: 0,
                               width: mainView.frame.size.width, height: mainView.frame.size.height)
        webView.allowsBackForwardNavigationGestures = true
        self.mainView.addSubview(webView)
    }
    
    private func setupToolBar() {
        let width: CGFloat = mainView.frame.size.width
        let height: CGFloat = mainView.frame.size.height
        self.toolBar = createToolBar(frame: CGRect(x: 0, y: height-45, width: width, height: 45.0), position: CGPoint(x: width/2, y: height-22.5
        ))
        self.mainView.addSubview(self.toolBar!)
    }
    
    private func setupIndicator() {
        indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: mainView.frame.size.width/2-50,
                                 y: mainView.frame.size.height/2-50,
                                 width: 100, height: 100)
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = .green
        webView.addSubview(indicator)
    }
    
    private func createToolBar(frame: CGRect, position: CGPoint) -> UIToolbar {
        // UIWebViewのインスタンスを生成
        let _toolBar = UIToolbar()
        // ツールバーのサイズを決める
        _toolBar.frame = frame
        // ツールバーの位置を決める
        _toolBar.layer.position = position
        // 文字色を設定する
        _toolBar.tintColor = UIColor.black
        // 背景色を設定する
        _toolBar.backgroundColor = UIColor.white
        // 各ボタンを生成する
        let spacerEdge: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacerEdge.width = 16
        
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 42
        
        self.rewindButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 101)!, target: self, action: #selector(back(_:)) )
        
        self.fastForwardButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 102)!, target: self, action: #selector(foward(_:)) )
        
        self.refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        
        self.openInSafari = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(safari))
        
        let spacerRight: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        _toolBar.items = [spacerEdge, rewindButton, spacer, fastForwardButton, spacerRight, refreshButton, spacer, openInSafari, spacerEdge]
        
        return _toolBar
    }
    
    private func loadWKWebView() {
        guard let url = URL(string: "https://qiita.com/") else { return }
        let requset = URLRequest(url: url)
        webView.load(requset)
    }
    
    @objc func back(_: AnyObject) {
        self.webView.goBack()
    }
    
    @objc func foward(_: AnyObject) {
        self.webView.goForward()
    }
    
    @objc func refresh(_: AnyObject) {
        self.webView.reload()
    }
    
    @objc func safari(_: AnyObject) {
        let url = self.webView.url
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }


}


extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("Before Request")
        let url = navigationAction.request.url
        print("読み込むURL : \(url)")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("読み込み開始準備")
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("After Response")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("読み込み開始")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("読み込み完了")
        webView.evaluateJavaScript("document.readyState") { (complete, error) in
            
            if complete != nil {
                print("test : \(webView.scrollView.contentSize)")
            }
        }
        indicator.stopAnimating()
    }
            
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler"){
            print("\(message.body)")
        }
    }
}
