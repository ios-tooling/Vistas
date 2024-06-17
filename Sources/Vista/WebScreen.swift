//
//  WebScreen.swift
//
//
//  Created by Ben Gottlieb on 6/17/24.
//

import SwiftUI
import WebKit
import CrossPlatformKit

public struct WebScreen: UXViewRepresentable {
	let url: URL?
	let html: String?
	var didFinishLoading: ((WKWebView) -> Void)?
	
	public init(url: URL, didFinishLoading: ((WKWebView) -> Void)? = nil) {
		self.url = url
		self.html = nil
		self.didFinishLoading = didFinishLoading
	}
	
	public init(html: String, didFinishLoading: ((WKWebView) -> Void)? = nil) {
		self.html = html
		self.url = nil
		self.didFinishLoading = didFinishLoading
	}
	
	public func makeUXView(context: Context) -> WKWebView {
		context.coordinator.didFinishLoading = didFinishLoading
		
		if let url {
			if url.isFileURL {
				context.coordinator.webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
			} else {
				context.coordinator.webView.load(URLRequest(url: url))
			}
		} else if let html {
			context.coordinator.webView.loadHTMLString(html, baseURL: nil)
		}
		return context.coordinator.webView
	}
	
	public func updateUXView(_ uiView: WKWebView, context: Context) {
		context.coordinator.didFinishLoading = didFinishLoading
	}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(url: url, html: html)
	}
	
	public class Coordinator: NSObject, WKNavigationDelegate {
		let url: URL?
		var html: String?
		var webView: InternalWebView!
		var didFinishLoading: ((WKWebView) -> Void)?
		
		static var cachedWebViews: [URL: InternalWebView] = [:]
		
		init(url: URL?, html: String?) {
			self.url = url
			self.html = html
			super.init()
			
			if let url, let view = Self.cachedWebViews[url] {
				webView = view
			} else {
				webView = InternalWebView(frame: .zero)
				if let url { Self.cachedWebViews[url] = webView }
			}
			webView.navigationDelegate = self
		}
		
		public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			didFinishLoading?(webView)
		}
	}
	
	class InternalWebView: WKWebView {
		
	}
}

