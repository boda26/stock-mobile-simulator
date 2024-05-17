//
//  WebViews.swift
//  StockApp
//
//  Created by Boda Song on 4/15/24.
//

import SwiftUI
import WebKit

struct HourlyWebView: UIViewRepresentable {
    var htmlFilename: String
    var javascript: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let filePath = Bundle.main.path(forResource: htmlFilename, ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            uiView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HourlyWebView

        init(_ parent: HourlyWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(parent.javascript) { result, error in
                if let error = error {
                    print("JavaScript Error: \(error.localizedDescription)")
                } else {
                    print("JavaScript Result: \(String(describing: result))")
                }
            }
        }
    }
}

struct HistoryWebView: UIViewRepresentable {
    var htmlFilename: String
    var javascript: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let filePath = Bundle.main.path(forResource: htmlFilename, ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            uiView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HistoryWebView

        init(_ parent: HistoryWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(parent.javascript) { result, error in
                if let error = error {
                    print("JavaScript Error: \(error.localizedDescription)")
                } else {
                    print("JavaScript Result: \(String(describing: result))")
                }
            }
        }
    }
}

struct TrendWebView: UIViewRepresentable {
    var htmlFilename: String
    var javascript: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let filePath = Bundle.main.path(forResource: htmlFilename, ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            uiView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: TrendWebView

        init(_ parent: TrendWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(parent.javascript) { result, error in
                if let error = error {
                    print("JavaScript Error: \(error.localizedDescription)")
                } else {
                    print("JavaScript Result: \(String(describing: result))")
                }
            }
        }
    }
}

struct EarningsWebView: UIViewRepresentable {
    var htmlFilename: String
    var javascript: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let filePath = Bundle.main.path(forResource: htmlFilename, ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            uiView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: EarningsWebView

        init(_ parent: EarningsWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(parent.javascript) { result, error in
                if let error = error {
                    print("JavaScript Error: \(error.localizedDescription)")
                } else {
                    print("JavaScript Result: \(String(describing: result))")
                }
            }
        }
    }
}


