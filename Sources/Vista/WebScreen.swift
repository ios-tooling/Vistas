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
	var didFinishLoading: ((WKWebView, Error?) -> Void)?
	var isLoading: Binding<Bool>?
	
	public init(url: URL, isLoading: Binding<Bool>? = nil, didFinishLoading: ((WKWebView, Error?) -> Void)? = nil) {
		self.url = url
		self.html = nil
		self.didFinishLoading = didFinishLoading
		self.isLoading = isLoading
	}
	
	public init(html: String, isLoading: Binding<Bool>? = nil, didFinishLoading: ((WKWebView, Error?) -> Void)? = nil) {
		self.html = html
		self.url = nil
		self.didFinishLoading = didFinishLoading
		self.isLoading = isLoading
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
		if url != context.coordinator.url {
			context.coordinator.url = url
		}
	}
	
	public func makeCoordinator() -> Coordinator {
		Coordinator(url: url, html: html, isLoading: isLoading)
	}
	
	public class Coordinator: NSObject, WKNavigationDelegate {
		var url: URL? { didSet { updateWebView() }}
		var html: String?
		var webView: InternalWebView!
		var didFinishLoading: ((WKWebView, Error?) -> Void)?
		var isLoadingObserver: Any?
		let isLoading: Binding<Bool>?
		
		static var cachedWebViews: [URL: InternalWebView] = [:]
		
		init(url: URL?, html: String?, isLoading: Binding<Bool>?) {
			self.url = url
			self.html = html
			self.isLoading = isLoading
			super.init()
			
			if let url, let view = Self.cachedWebViews[url] {
				webView = view
			} else {
				webView = InternalWebView(frame: .zero)
				if let url { Self.cachedWebViews[url] = webView }
			}
			webView.navigationDelegate = self
			isLoadingObserver = webView.observe(\.isLoading) { [weak self] view, change in
				self?.isLoading?.wrappedValue = view.isLoading
			}
		}
				
		public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			didFinishLoading?(webView, nil)
		}
		
		public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
			didFinishLoading?(webView, error)
		}
		
		func updateWebView() {
			guard let url else { return }
			webView.load(.init(url: url))
		}
	}
	
	class InternalWebView: WKWebView {
		
	}
}

