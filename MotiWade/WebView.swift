//
//  WebView.swift
//  MotiWade
//
//  Created by Mikhail Ivanov on 06.11.2020.
//

import SwiftUI
import UIKit
import WebKit

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
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let webView = WKWebView()
        
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
        
        if let urlReq = URL(string: url) {
            webView.load(URLRequest(url: urlReq))
        }
        
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.showsVerticalScrollIndicator = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
    
    }
    
    
}
