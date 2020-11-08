//
//  WebView.swift
//  MotiWade
//
//  Created by Mikhail Ivanov on 06.11.2020.
//

import SwiftUI
import UIKit
import WebKit
import Combine
import Firebase

extension WKWebView: UIScrollViewDelegate {
    open override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}


struct WebView: UIViewRepresentable
{
    typealias UIViewType = WKWebView
    
    @State var url: String = ""
    @EnvironmentObject var webLoading: WebLoading
    
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "auth")
        
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        var url: String = ""
        if let path = Bundle.main.path(forResource: "secret", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                
                if let jsonResult = json as? Dictionary<String, AnyObject>, let u = jsonResult["url"] as? String {
                    url = u
                }
                
            } catch {
                print("Keke")
            }
        }
        
        if let urlReq = URL(string: url + self.url) {
            webView.load(URLRequest(url: urlReq))
            
        }
        
        UserDefaults.standard.restoreCookies(webView)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.showsVerticalScrollIndicator = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
       
        if webLoading.isUpdate && !webLoading.isLoaded{
            
            webLoading.isUpdate = false
            var url: String = ""
            if let path = Bundle.main.path(forResource: "secret", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    
                    
                    if let jsonResult = json as? Dictionary<String, AnyObject>, let u = jsonResult["url"] as? String {
                        url = u
                    }
                    
                } catch {
                    print("Keke")
                }
            }
            
            if let urlReq = URL(string: url + self.url) {
                uiView.load(URLRequest(url: urlReq))
                
            }
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, URLSessionDelegate, WKScriptMessageHandler {
        private var webLoading: WebLoading
        private var webView: WKWebView?
        public var isLoaded: Bool = false
        init(_ webLoading: WebLoading) {
            self.webLoading = webLoading
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            self.webLoading.isLoaded = true
            self.webView = webView
            webView.evaluateJavaScript("document.mobileAppInterop.setIsIosApp()", completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.webLoading.isOpacity = true
            self.webLoading.isLoaded = false
        }
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let message = message.body as? [String: AnyObject] else {
                print("Not message")
                return
            }
            
            guard let isAuthenticated = message["isAuthenticated"] as? Bool else {
                print("not auth")
                return
            }
            
            if isAuthenticated {
                
                guard let userId = message["userId"] as? String else {
                    print("not auth")
                    return
                }
                
                self.isLoaded = true
                
                if let webView = self.webView {
                    webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
                        UserDefaults.standard.storeCookies(cookies)
                    }
                    
                }
                
                Messaging.messaging().subscribe(toTopic: userId) { error in
                    print("Subscribed to \(userId) topic")
                }
                
                Messaging.messaging().subscribe(toTopic: "all") { error in
                    print("Subscribed to all topic")
                }
                
                
            } else if isLoaded {
                self.isLoaded = false
                let cookies: [HTTPCookie] = []
                UserDefaults.standard.storeCookies(cookies)
                self.webLoading.isOpacity = true
                self.webLoading.isLoaded = false
                self.webLoading.isUpdate = true
                self.webLoading.isWeb = false
            }
        }
    }
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(webLoading)
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        print("kek")
    }
}
