import SwiftUI
import WebKit

struct WebView: View {
    @Environment(\.webViewTranslucentBackground) private var webViewTranslucentBackground
    let url: URL

    var body: some View {
        WebViewUIViewRepresentable(url: url, isTransparentBackground: webViewTranslucentBackground)
    }
}

struct WebViewUIViewRepresentable: UIViewRepresentable {
    let url: URL
    let isTransparentBackground: Bool

    public func makeUIView(context _: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)

        if isTransparentBackground {
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
        }

        return webView
    }

    public func updateUIView(_ webView: WKWebView, context _: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension EnvironmentValues {
    @Entry var webViewTranslucentBackground: Bool = false
}

public extension View {
    func webViewTranslucentBackground(_ enable: Bool) -> some View {
        environment(\.webViewTranslucentBackground, enable)
    }
}
