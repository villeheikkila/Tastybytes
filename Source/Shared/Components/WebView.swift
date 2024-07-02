import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIView(context _: Context) -> WKWebView {
        WKWebView()
    }

    public func updateUIView(_ webView: WKWebView, context _: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
